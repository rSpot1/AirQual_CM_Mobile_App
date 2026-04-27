import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/aq_utils.dart';

class FactorChip extends StatelessWidget {
  final String factor;
  final String lang;

  const FactorChip({super.key, required this.factor, required this.lang});

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<AppThemeExtension>()!;
    final label = AQUtils.factorLabel(factor, lang);
    final icon = AQUtils.factorIcon(factor);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.warning.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.warning.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.warning),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: ext.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
