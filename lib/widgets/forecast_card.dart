import 'package:flutter/material.dart';
import '../models/air_quality.dart';
import '../theme/app_theme.dart';
import '../utils/aq_utils.dart';

class ForecastCard extends StatelessWidget {
  final DailyForecast forecast;
  final String lang;
  final bool isFirst;

  const ForecastCard({
    super.key,
    required this.forecast,
    required this.lang,
    this.isFirst = false,
  });

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<AppThemeExtension>()!;
    final color = AQUtils.levelColor(forecast.level);
    final label = isFirst
        ? (lang == 'fr' ? "Auj." : "Today")
        : AQUtils.weekdayLabel(forecast.date, lang);

    return Container(
      width: 90,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: isFirst ? color.withOpacity(0.12) : ext.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isFirst ? color.withOpacity(0.4) : ext.borderColor,
          width: isFirst ? 1.5 : 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isFirst ? color : ext.textSecondary,
            ),
          ),
          Text(
            '${forecast.date.day}/${forecast.date.month}',
            style: TextStyle(fontSize: 10, color: ext.textMuted),
          ),
          // PM2.5 indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${forecast.pm25.toStringAsFixed(1)}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ),
          Text(
            '\u00b5g/m\u00b3',
            style: TextStyle(fontSize: 9, color: ext.textMuted),
          ),
          // Temp range
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${forecast.tempMax.toStringAsFixed(0)}\u00b0',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: ext.textColor,
                ),
              ),
              Text(
                '/${forecast.tempMin.toStringAsFixed(0)}\u00b0',
                style: TextStyle(fontSize: 11, color: ext.textMuted),
              ),
            ],
          ),
          // Rain indicator
          if (forecast.precipitation > 0)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.water_drop_rounded,
                    size: 10, color: AppColors.primary),
                Text(
                  '${forecast.precipitation.toStringAsFixed(0)}mm',
                  style: TextStyle(fontSize: 9, color: ext.textMuted),
                ),
              ],
            )
          else
            Icon(Icons.wb_sunny_rounded,
                size: 14, color: const Color(0xFFFFD60A)),
        ],
      ),
    );
  }
}
