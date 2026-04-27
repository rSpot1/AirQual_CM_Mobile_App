import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzdata;
import '../models/air_quality.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    tzdata.initializeTimeZones();

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(settings);
    _initialized = true;
  }

  Future<bool> requestPermission() async {
    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      final granted = await androidPlugin.requestNotificationsPermission();
      return granted ?? false;
    }
    final iosPlugin = _plugin
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
    if (iosPlugin != null) {
      final granted = await iosPlugin.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }
    return true;
  }

  AndroidNotificationDetails _androidDetails(String channelId, String channelName, Color color) {
    return AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: 'AirQual CM - Alertes qualité de l\'air',
      importance: Importance.high,
      priority: Priority.high,
      color: color,
      icon: '@mipmap/ic_launcher',
      styleInformation: const BigTextStyleInformation(''),
    );
  }

  /// Envoyer une notification immédiate avec PM2.5 de la ville
  Future<void> sendDailyAlert({
    required String city,
    required double pm25,
    required AQILevel level,
    required String lang,
  }) async {
    await initialize();
    final (title, body) = _buildNotifContent(city, pm25, level, lang, isForecast: false);
    final color = _levelColor(level);

    await _plugin.show(
      1001,
      title,
      body,
      NotificationDetails(
        android: _androidDetails('airqual_daily', 'Alertes quotidiennes', color),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }

  /// Envoyer alerte prévision si PM2.5 élevé attendu
  Future<void> sendForecastAlert({
    required String city,
    required List<DailyForecast> forecasts,
    required String lang,
  }) async {
    await initialize();
    final highDays = forecasts
        .where((f) => f.pm25 > 25 && f.date.isAfter(DateTime.now()))
        .take(7)
        .toList();
    if (highDays.isEmpty) return;

    final nextHigh = highDays.first;
    final isFr = lang == 'fr';
    final dateStr = _formatDate(nextHigh.date, isFr);

    final title = isFr
        ? '⚠️ Alerte prévision - $city'
        : '⚠️ Forecast Alert - $city';
    final body = isFr
        ? 'PM2.5 élevé prévu le $dateStr : ${nextHigh.pm25.toStringAsFixed(1)} µg/m³. Préparez-vous!'
        : 'High PM2.5 expected on $dateStr: ${nextHigh.pm25.toStringAsFixed(1)} µg/m³. Be prepared!';

    await _plugin.show(
      1002,
      title,
      body,
      NotificationDetails(
        android: _androidDetails('airqual_forecast', 'Alertes prévisions', const Color(0xFFFF9F0A)),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }

  /// Planifier notification quotidienne à l'heure choisie (GMT+1)
  /// Inclut la valeur PM2.5 du lendemain si disponible en cache local.
  Future<void> scheduleDailyNotification({
    required String city,
    required String lang,
    int hour = 8,
    int minute = 0,
    double? tomorrowPm25,
    String? tomorrowLevel,
  }) async {
    await initialize();
    await _plugin.cancelAll();

    final location = tz.getLocation('Africa/Douala'); // GMT+1
    final now = tz.TZDateTime.now(location);
    var scheduled = tz.TZDateTime(location, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    final isFr = lang == 'fr';

    String title;
    String body;

    // Si on a la valeur PM2.5 du lendemain en cache, l'afficher dans la notification
    if (tomorrowPm25 != null && tomorrowPm25 > 0 && tomorrowLevel != null) {
      title = isFr
          ? '🌬️ AirQual CM - Rapport $city'
          : '🌬️ AirQual CM - Report $city';
      body = isFr
          ? 'PM2.5 prévu demain : ${tomorrowPm25.toStringAsFixed(1)} µg/m³ ($tomorrowLevel). Restez informé!'
          : 'Tomorrow\'s PM2.5: ${tomorrowPm25.toStringAsFixed(1)} µg/m³ ($tomorrowLevel). Stay informed!';
    } else {
      title = isFr ? '🌬️ AirQual CM - Rapport quotidien' : '🌬️ AirQual CM - Daily Report';
      body = isFr
          ? 'Consultez l\'état de la qualité de l\'air à $city aujourd\'hui.'
          : 'Check today\'s air quality in $city.';
    }

    await _plugin.zonedSchedule(
      1000,
      title,
      body,
      scheduled,
      NotificationDetails(
        android: _androidDetails('airqual_scheduled', 'Rapport quotidien', const Color(0xFF0A84FF)),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> cancelAll() async {
    await initialize();
    await _plugin.cancelAll();
  }

  (String, String) _buildNotifContent(
    String city,
    double pm25,
    AQILevel level,
    String lang, {
    required bool isForecast,
  }) {
    final isFr = lang == 'fr';
    final levelStr = _levelLabel(level, isFr);
    final emoji = _levelEmoji(level);

    final title = '$emoji AirQual CM - $city';
    final body = isFr
        ? 'PM2.5 : ${pm25.toStringAsFixed(1)} µg/m³ · État : $levelStr'
        : 'PM2.5: ${pm25.toStringAsFixed(1)} µg/m³ · Status: $levelStr';

    return (title, body);
  }

  String _levelLabel(AQILevel level, bool isFr) {
    if (isFr) {
      return switch (level) {
        AQILevel.good => 'Bon',
        AQILevel.moderate => 'Modéré',
        AQILevel.elevated => 'Élevé',
        AQILevel.high => 'Très élevé',
        AQILevel.veryHigh => 'Dangereux',
        AQILevel.hazardous => 'Extrêmement dangereux',
      };
    } else {
      return switch (level) {
        AQILevel.good => 'Good',
        AQILevel.moderate => 'Moderate',
        AQILevel.elevated => 'Elevated',
        AQILevel.high => 'High',
        AQILevel.veryHigh => 'Very High',
        AQILevel.hazardous => 'Hazardous',
      };
    }
  }

  String _levelEmoji(AQILevel level) => switch (level) {
    AQILevel.good => '✅',
    AQILevel.moderate => '🟡',
    AQILevel.elevated => '🟠',
    AQILevel.high => '🔴',
    AQILevel.veryHigh => '🟣',
    AQILevel.hazardous => '⚫',
  };

  Color _levelColor(AQILevel level) => switch (level) {
    AQILevel.good => const Color(0xFF30D158),
    AQILevel.moderate => const Color(0xFFFFD60A),
    AQILevel.elevated => const Color(0xFFFF9F0A),
    AQILevel.high => const Color(0xFFFF453A),
    AQILevel.veryHigh => const Color(0xFFBF5AF2),
    AQILevel.hazardous => const Color(0xFF8B0000),
  };

  String _formatDate(DateTime date, bool isFr) {
    final monthsFr = ['jan', 'fév', 'mar', 'avr', 'mai', 'jun', 'jul', 'aoû', 'sep', 'oct', 'nov', 'déc'];
    final monthsEn = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    if (isFr) return '${date.day} ${monthsFr[date.month - 1]}';
    return '${monthsEn[date.month - 1]} ${date.day}';
  }
}