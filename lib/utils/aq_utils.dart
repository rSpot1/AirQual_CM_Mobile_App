import 'package:flutter/material.dart';
import '../models/air_quality.dart';
import '../theme/app_theme.dart';

class AQUtils {
  static Color levelColor(AQILevel level) => switch (level) {
    AQILevel.good => AppColors.aqi_good,
    AQILevel.moderate => AppColors.aqi_moderate,
    AQILevel.elevated => AppColors.aqi_elevated,
    AQILevel.high => AppColors.aqi_high,
    AQILevel.veryHigh => AppColors.aqi_very_high,
    AQILevel.hazardous => AppColors.aqi_hazardous,
  };

  static String levelLabel(AQILevel level, String lang) {
    if (lang == 'fr') {
      return switch (level) {
        AQILevel.good => 'Bon',
        AQILevel.moderate => 'Mod\u00e9r\u00e9',
        AQILevel.elevated => '\u00c9lev\u00e9',
        AQILevel.high => 'Tr\u00e8s \u00e9lev\u00e9',
        AQILevel.veryHigh => 'Dangereux',
        AQILevel.hazardous => 'Extr\u00eamement dangereux',
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

  static String levelEmoji(AQILevel level) => switch (level) {
    AQILevel.good => '\u2705',
    AQILevel.moderate => '\u1f7e1',
    AQILevel.elevated => '\u1f7e0',
    AQILevel.high => '\u1f534',
    AQILevel.veryHigh => '\u1f7e3',
    AQILevel.hazardous => '\u26d4',
  };

  static IconData levelIcon(AQILevel level) => switch (level) {
    AQILevel.good => Icons.check_circle_rounded,
    AQILevel.moderate => Icons.info_rounded,
    AQILevel.elevated => Icons.warning_amber_rounded,
    AQILevel.high => Icons.dangerous_rounded,
    AQILevel.veryHigh => Icons.crisis_alert_rounded,
    AQILevel.hazardous => Icons.emergency_rounded,
  };

  static String healthAdvice(AQILevel level, String lang) {
    if (lang == 'fr') {
      return switch (level) {
        AQILevel.good =>
          'La qualit\u00e9 de l\'air est satisfaisante. Profitez des activit\u00e9s ext\u00e9rieures.',
        AQILevel.moderate =>
          'Qualit\u00e9 acceptable. Les personnes tr\u00e8s sensibles devraient limiter les efforts prolong\u00e9s \u00e0 l\'ext\u00e9rieur.',
        AQILevel.elevated =>
          'Groupes sensibles (enfants, personnes \u00e2g\u00e9es, asthmatiques) : limitez les activit\u00e9s ext\u00e9rieures prolong\u00e9es.',
        AQILevel.high =>
          'Mauvaise qualit\u00e9 de l\'air. Tout le monde devrait r\u00e9duire les activit\u00e9s physiques intenses \u00e0 l\'ext\u00e9rieur.',
        AQILevel.veryHigh =>
          'Dangereux pour la sant\u00e9. \u00c9vitez toute activit\u00e9 \u00e0 l\'ext\u00e9rieur. Portez un masque si vous devez sortir.',
        AQILevel.hazardous =>
          'Situation d\'urgence sanitaire. Restez \u00e0 l\'int\u00e9rieur, fermez les fen\u00eatres. Consultez un m\u00e9decin si sympt\u00f4mes.',
      };
    } else {
      return switch (level) {
        AQILevel.good =>
          'Air quality is satisfactory. Enjoy outdoor activities.',
        AQILevel.moderate =>
          'Acceptable quality. Very sensitive people should limit prolonged outdoor exertion.',
        AQILevel.elevated =>
          'Sensitive groups (children, elderly, asthmatics): limit prolonged outdoor activities.',
        AQILevel.high =>
          'Poor air quality. Everyone should reduce intense outdoor physical activity.',
        AQILevel.veryHigh =>
          'Health hazard. Avoid all outdoor activity. Wear a mask if you must go out.',
        AQILevel.hazardous =>
          'Health emergency. Stay indoors, close windows. Consult a doctor if symptoms appear.',
      };
    }
  }

  static String factorLabel(String factor, String lang) {
    if (lang == 'fr') {
      return switch (factor) {
        'low_wind' => 'Vents faibles',
        'high_temp' => 'Chaleur \u00e9lev\u00e9e',
        'no_rain' => 'Absence de pluie',
        'high_radiation' => 'Radiation \u00e9lev\u00e9e',
        'harmattan' => 'Saison Harmattan',
        _ => factor,
      };
    } else {
      return switch (factor) {
        'low_wind' => 'Low winds',
        'high_temp' => 'High temperature',
        'no_rain' => 'No rainfall',
        'high_radiation' => 'High radiation',
        'harmattan' => 'Harmattan season',
        _ => factor,
      };
    }
  }

  static IconData factorIcon(String factor) => switch (factor) {
    'low_wind' => Icons.air_rounded,
    'high_temp' => Icons.thermostat_rounded,
    'no_rain' => Icons.water_drop_outlined,
    'high_radiation' => Icons.wb_sunny_rounded,
    'harmattan' => Icons.storm_rounded,
    _ => Icons.warning_amber_rounded,
  };

  static String weekdayLabel(DateTime date, String lang) {
    if (lang == 'fr') {
      const days = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
      return days[date.weekday - 1];
    } else {
      const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return days[date.weekday - 1];
    }
  }

  static String monthLabel(int month, String lang) {
    if (lang == 'fr') {
      const months = ['Jan', 'F\u00e9v', 'Mar', 'Avr', 'Mai', 'Jun', 'Jul', 'Ao\u00fb', 'Sep', 'Oct', 'Nov', 'D\u00e9c'];
      return months[month - 1];
    } else {
      const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return months[month - 1];
    }
  }

  // WHO guideline PM2.5 = 15 \u00b5g/m\u00b3
  static const double whoGuideline = 15.0;

  static double pm25ToPercent(double pm25) => (pm25 / 55.0).clamp(0.0, 1.0);
}
