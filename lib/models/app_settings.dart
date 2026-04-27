import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettings extends ChangeNotifier {
  static const _keyTheme = 'theme_mode';
  static const _keyLanguage = 'language';
  static const _keyNotifEnabled = 'notif_enabled';
  static const _keyNotifCity = 'notif_city';
  static const _keyForecastDays = 'forecast_days';
  static const _keyOnboardingDone = 'onboarding_done';
  static const _keyNotifHour = 'notif_hour';
  static const _keyNotifMinute = 'notif_minute';
  // Clé pour stocker le PM2.5 du lendemain en mémoire locale
  static const _keyTomorrowPm25 = 'tomorrow_pm25';
  static const _keyTomorrowCity = 'tomorrow_city';
  static const _keyTomorrowLevel = 'tomorrow_level';

  ThemeMode _themeMode = ThemeMode.dark;
  String _language = 'fr';
  bool _notificationsEnabled = true;
  String _notificationCity = '';
  int _forecastDays = 7;
  bool _onboardingDone = false;
  int _notifHour = 8;
  int _notifMinute = 0;
  double _tomorrowPm25 = 0.0;
  String _tomorrowCity = '';
  String _tomorrowLevel = '';

  ThemeMode get themeMode => _themeMode;
  String get language => _language;
  bool get notificationsEnabled => _notificationsEnabled;
  String get notificationCity => _notificationCity;
  int get forecastDays => _forecastDays;
  bool get onboardingDone => _onboardingDone;
  bool get isDark => _themeMode == ThemeMode.dark;
  int get notifHour => _notifHour;
  int get notifMinute => _notifMinute;
  double get tomorrowPm25 => _tomorrowPm25;
  String get tomorrowCity => _tomorrowCity;
  String get tomorrowLevel => _tomorrowLevel;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final themeStr = prefs.getString(_keyTheme) ?? 'dark';
    _themeMode = themeStr == 'light' ? ThemeMode.light : ThemeMode.dark;
    _language = prefs.getString(_keyLanguage) ?? 'fr';
    _notificationsEnabled = prefs.getBool(_keyNotifEnabled) ?? true;
    _notificationCity = prefs.getString(_keyNotifCity) ?? '';
    _forecastDays = prefs.getInt(_keyForecastDays) ?? 7;
    _onboardingDone = prefs.getBool(_keyOnboardingDone) ?? false;
    _notifHour = prefs.getInt(_keyNotifHour) ?? 8;
    _notifMinute = prefs.getInt(_keyNotifMinute) ?? 0;
    _tomorrowPm25 = prefs.getDouble(_keyTomorrowPm25) ?? 0.0;
    _tomorrowCity = prefs.getString(_keyTomorrowCity) ?? '';
    _tomorrowLevel = prefs.getString(_keyTomorrowLevel) ?? '';
    notifyListeners();
  }

  Future<void> setTheme(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyTheme, mode == ThemeMode.light ? 'light' : 'dark');
  }

  Future<void> setLanguage(String lang) async {
    _language = lang;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLanguage, lang);
  }

  Future<void> setNotificationsEnabled(bool value) async {
    _notificationsEnabled = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyNotifEnabled, value);
  }

  Future<void> setNotificationCity(String city) async {
    _notificationCity = city;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyNotifCity, city);
  }

  Future<void> setForecastDays(int days) async {
    _forecastDays = days;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyForecastDays, days);
  }

  Future<void> setOnboardingDone(bool value) async {
    _onboardingDone = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyOnboardingDone, value);
  }

  Future<void> setNotifTime(int hour, int minute) async {
    _notifHour = hour;
    _notifMinute = minute;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyNotifHour, hour);
    await prefs.setInt(_keyNotifMinute, minute);
  }

  /// Sauvegarder localement le PM2.5 du lendemain pour affichage dans la notif
  Future<void> saveTomorrowForecast({
    required String city,
    required double pm25,
    required String level,
  }) async {
    _tomorrowPm25 = pm25;
    _tomorrowCity = city;
    _tomorrowLevel = level;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keyTomorrowPm25, pm25);
    await prefs.setString(_keyTomorrowCity, city);
    await prefs.setString(_keyTomorrowLevel, level);
  }
}
