import 'package:flutter/material.dart';

class AppColors {
  // Brand colors - Deep teal/blue inspired by clean air and health
  static const Color primary = Color(0xFF0A84FF);
  static const Color primaryDark = Color(0xFF0065CC);
  static const Color primaryLight = Color(0xFF5AB3FF);

  static const Color secondary = Color(0xFF30D158);
  static const Color accent = Color(0xFFFF9F0A);
  static const Color danger = Color(0xFFFF453A);
  static const Color warning = Color(0xFFFFD60A);
  static const Color purple = Color(0xFFBF5AF2);

  // AQI level colors
  static const Color aqi_good = Color(0xFF30D158);
  static const Color aqi_moderate = Color(0xFFFFD60A);
  static const Color aqi_elevated = Color(0xFFFF9F0A);
  static const Color aqi_high = Color(0xFFFF453A);
  static const Color aqi_very_high = Color(0xFFBF5AF2);
  static const Color aqi_hazardous = Color(0xFF8B0000);

  // Dark theme
  static const Color darkBg = Color(0xFF0D1117);
  static const Color darkSurface = Color(0xFF161B22);
  static const Color darkCard = Color(0xFF21262D);
  static const Color darkBorder = Color(0xFF30363D);
  static const Color darkText = Color(0xFFE6EDF3);
  static const Color darkTextSecondary = Color(0xFF8B949E);
  static const Color darkTextMuted = Color(0xFF6E7681);

  // Light theme
  static const Color lightBg = Color(0xFFF5F7FA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightBorder = Color(0xFFE5E9F0);
  static const Color lightText = Color(0xFF1A1F2E);
  static const Color lightTextSecondary = Color(0xFF667085);
  static const Color lightTextMuted = Color(0xFF98A2B3);

  // Gradients
  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0D1B2E), Color(0xFF0A2944), Color(0xFF0D3B6E)],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1A2535), Color(0xFF1E2D42)],
  );
}

class AppTheme {
  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      surface: AppColors.darkSurface,
      background: AppColors.darkBg,
      error: AppColors.danger,
    ),
    scaffoldBackgroundColor: AppColors.darkBg,
    cardColor: AppColors.darkCard,
    textTheme: _buildTextTheme(AppColors.darkText, AppColors.darkTextSecondary),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.darkBg,
      foregroundColor: AppColors.darkText,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.darkText,
        fontFamily: 'Poppins',
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.darkSurface,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.darkTextMuted,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),
    iconTheme: const IconThemeData(color: AppColors.darkTextSecondary),
    dividerColor: AppColors.darkBorder,
    extensions: const [AppThemeExtension(isDark: true)],
  );

  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      surface: AppColors.lightSurface,
      background: AppColors.lightBg,
      error: AppColors.danger,
    ),
    scaffoldBackgroundColor: AppColors.lightBg,
    cardColor: AppColors.lightCard,
    textTheme: _buildTextTheme(AppColors.lightText, AppColors.lightTextSecondary),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.lightBg,
      foregroundColor: AppColors.lightText,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.lightText,
        fontFamily: 'Poppins',
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.lightSurface,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.lightTextMuted,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),
    iconTheme: const IconThemeData(color: AppColors.lightTextSecondary),
    dividerColor: AppColors.lightBorder,
    extensions: const [AppThemeExtension(isDark: false)],
  );

  static TextTheme _buildTextTheme(Color primary, Color secondary) => TextTheme(
    displayLarge: TextStyle(fontSize: 48, fontWeight: FontWeight.w700, color: primary, fontFamily: 'Poppins'),
    displayMedium: TextStyle(fontSize: 36, fontWeight: FontWeight.w600, color: primary, fontFamily: 'Poppins'),
    displaySmall: TextStyle(fontSize: 28, fontWeight: FontWeight.w600, color: primary, fontFamily: 'Poppins'),
    headlineLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: primary, fontFamily: 'Poppins'),
    headlineMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: primary, fontFamily: 'Poppins'),
    headlineSmall: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: primary, fontFamily: 'Poppins'),
    titleLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: primary, fontFamily: 'Poppins'),
    titleMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: primary, fontFamily: 'Poppins'),
    titleSmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: secondary, fontFamily: 'Poppins'),
    bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: primary, fontFamily: 'Poppins'),
    bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: primary, fontFamily: 'Poppins'),
    bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: secondary, fontFamily: 'Poppins'),
    labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: primary, fontFamily: 'Poppins'),
    labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: primary, fontFamily: 'Poppins'),
    labelSmall: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: secondary, fontFamily: 'Poppins'),
  );
}

class AppThemeExtension extends ThemeExtension<AppThemeExtension> {
  final bool isDark;
  const AppThemeExtension({required this.isDark});

  Color get bgColor => isDark ? AppColors.darkBg : AppColors.lightBg;
  Color get surfaceColor => isDark ? AppColors.darkSurface : AppColors.lightSurface;
  Color get cardColor => isDark ? AppColors.darkCard : AppColors.lightCard;
  Color get borderColor => isDark ? AppColors.darkBorder : AppColors.lightBorder;
  Color get textColor => isDark ? AppColors.darkText : AppColors.lightText;
  Color get textSecondary => isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
  Color get textMuted => isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted;

  @override
  AppThemeExtension copyWith({bool? isDark}) =>
      AppThemeExtension(isDark: isDark ?? this.isDark);

  @override
  AppThemeExtension lerp(AppThemeExtension? other, double t) => this;
}