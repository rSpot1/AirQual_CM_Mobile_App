import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/air_quality.dart';
import '../theme/app_theme.dart';
import '../utils/aq_utils.dart';

class AqiGauge extends StatelessWidget {
  final double pm25;
  final AQILevel level;
  final double size;

  const AqiGauge({
    super.key,
    required this.pm25,
    required this.level,
    this.size = 120,
  });

  @override
  Widget build(BuildContext context) {
    final color = AQUtils.levelColor(level);
    final pct = AQUtils.pm25ToPercent(pm25);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background track
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: 1.0,
              strokeWidth: 10,
              color: Colors.white.withOpacity(0.08),
            ),
          ),
          // Animated fill
          SizedBox(
            width: size,
            height: size,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: pct),
              duration: const Duration(milliseconds: 1200),
              curve: Curves.easeOut,
              builder: (_, value, __) => CircularProgressIndicator(
                value: value,
                strokeWidth: 10,
                strokeCap: StrokeCap.round,
                color: color,
              ),
            ),
          ),
          // Glow effect
          Container(
            width: size * 0.65,
            height: size * 0.65,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  color.withOpacity(0.15),
                  Colors.transparent,
                ],
              ),
            ),
          )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scaleXY(begin: 0.9, end: 1.1, duration: 2000.ms),
          // Icon
          Icon(
            AQUtils.levelIcon(level),
            color: color,
            size: size * 0.32,
          ),
        ],
      ),
    );
  }
}
