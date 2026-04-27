import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'models/app_settings.dart';
import 'services/air_quality_provider.dart';
import 'services/notification_service.dart';
import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Load settings
  final settings = AppSettings();
  await settings.load();

  // Init notifications
  await NotificationService().initialize();

  // Schedule notifications if enabled
  if (settings.notificationsEnabled) {
    final city = settings.notificationCity.isEmpty
        ? 'Yaound\u00e9'
        : settings.notificationCity;
    await NotificationService().scheduleDailyNotification(
      city: city,
      lang: settings.language,
    );
  }

  // Créer le provider et lui injecter les settings
  final provider = AirQualityProvider();
  provider.attachSettings(settings);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: settings),
        ChangeNotifierProvider.value(value: provider),
      ],
      child: const AirQualApp(),
    ),
  );
}

class AirQualApp extends StatelessWidget {
  const AirQualApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettings>();

    return MaterialApp(
      title: 'AirQual CM',
      debugShowCheckedModeBanner: false,
      themeMode: settings.themeMode,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      locale: Locale(settings.language),
      supportedLocales: const [Locale('fr'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const SplashScreen(),
    );
  }
}
