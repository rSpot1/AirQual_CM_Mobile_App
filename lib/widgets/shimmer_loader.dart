import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../theme/app_theme.dart';

class ShimmerLoader extends StatelessWidget {
  const ShimmerLoader({super.key});

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<AppThemeExtension>()!;
    final baseColor = ext.isDark ? const Color(0xFF21262D) : const Color(0xFFE5E9F0);
    final highlightColor = ext.isDark ? const Color(0xFF30363D) : const Color(0xFFF5F7FA);

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero shimmer
            Container(
              height: 340,
              color: ext.cardColor,
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _shimmerBox(height: 80, radius: 16),
                  const SizedBox(height: 16),
                  _shimmerBox(height: 20, width: 140),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _shimmerBox(height: 80, radius: 14)),
                      const SizedBox(width: 8),
                      Expanded(child: _shimmerBox(height: 80, radius: 14)),
                      const SizedBox(width: 8),
                      Expanded(child: _shimmerBox(height: 80, radius: 14)),
                      const SizedBox(width: 8),
                      Expanded(child: _shimmerBox(height: 80, radius: 14)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _shimmerBox(height: 160, radius: 16),
                  const SizedBox(height: 16),
                  _shimmerBox(height: 140, radius: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _shimmerBox(
      {required double height, double? width, double radius = 8}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
