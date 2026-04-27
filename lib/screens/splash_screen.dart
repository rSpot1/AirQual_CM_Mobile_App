import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';
import 'main_shell.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 3));
    _controller.forward();

    Future.delayed(const Duration(milliseconds: 3200), () {
      if (mounted) {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 800),
            pageBuilder: (_, __, ___) => const MainShell(),
            transitionsBuilder: (_, animation, __, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.heroGradient),
        child: Stack(
          children: [
            // Animated background circles
            Positioned(
              top: -100,
              right: -100,
              child: Container(
                width: 350,
                height: 350,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.primary.withOpacity(0.15),
                      Colors.transparent,
                    ],
                  ),
                ),
              )
                  .animate(controller: _controller)
                  .scale(begin: const Offset(0, 0), end: const Offset(1, 1), duration: 2000.ms)
                  .fade(begin: 0, end: 1, duration: 1500.ms),
            ),
            Positioned(
              bottom: -80,
              left: -80,
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.secondary.withOpacity(0.12),
                      Colors.transparent,
                    ],
                  ),
                ),
              )
                  .animate(controller: _controller)
                  .scale(begin: const Offset(0, 0), end: const Offset(1, 1), duration: 2000.ms, delay: 300.ms)
                  .fade(begin: 0, end: 1, duration: 1500.ms, delay: 300.ms),
            ),

            // Main content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // App logo/icon
                  Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [AppColors.primary, AppColors.primaryLight],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.4),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.air_rounded,
                      color: Colors.white,
                      size: 60,
                    ),
                  )
                      .animate(controller: _controller)
                      .scale(
                        begin: const Offset(0.3, 0.3),
                        end: const Offset(1, 1),
                        duration: 700.ms,
                        curve: Curves.elasticOut,
                      )
                      .fade(begin: 0, end: 1, duration: 500.ms),

                  const SizedBox(height: 28),

                  // App name
                  Text(
                    'AirQual CM',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 1.5,
                      shadows: [
                        Shadow(
                          color: AppColors.primary.withOpacity(0.5),
                          blurRadius: 20,
                        ),
                      ],
                    ),
                  )
                      .animate(controller: _controller)
                      .fadeIn(delay: 600.ms, duration: 700.ms)
                      .slideY(begin: 0.3, end: 0, delay: 600.ms, duration: 700.ms),

                  const SizedBox(height: 10),

                  // Tagline
                  Text(
                    'Qualit\u00e9 de l\'air \u00b7 Cameroun',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withOpacity(0.6),
                      letterSpacing: 2.0,
                    ),
                  )
                      .animate(controller: _controller)
                      .fadeIn(delay: 900.ms, duration: 700.ms),

                  const SizedBox(height: 60),

                  // Air quality indicators animation
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _AirParticle(color: AppColors.aqi_good, delay: 1200),
                      _AirParticle(color: AppColors.aqi_moderate, delay: 1350),
                      _AirParticle(color: AppColors.aqi_elevated, delay: 1500),
                      _AirParticle(color: AppColors.aqi_high, delay: 1650),
                      _AirParticle(color: AppColors.aqi_very_high, delay: 1800),
                    ],
                  ),

                  const SizedBox(height: 40),

                  // Loading indicator
                  SizedBox(
                    width: 120,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        backgroundColor: Colors.white.withOpacity(0.1),
                        valueColor:
                            const AlwaysStoppedAnimation<Color>(AppColors.primary),
                        minHeight: 3,
                      ),
                    ),
                  )
                      .animate(controller: _controller)
                      .fadeIn(delay: 1500.ms, duration: 500.ms),
                ],
              ),
            ),

            // Bottom branding
            Positioned(
              bottom: 48,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  Text(
                    'AlphaInfera',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withOpacity(0.4),
                      letterSpacing: 3.0,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'IndabaX Cameroon 2026',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white.withOpacity(0.25),
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              )
                  .animate(controller: _controller)
                  .fadeIn(delay: 2000.ms, duration: 800.ms),
            ),
          ],
        ),
      ),
    );
  }
}

class _AirParticle extends StatelessWidget {
  final Color color;
  final int delay;

  const _AirParticle({required this.color, required this.delay});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 12,
      height: 12,
      margin: const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [BoxShadow(color: color.withOpacity(0.6), blurRadius: 8)],
      ),
    )
        .animate(delay: Duration(milliseconds: delay))
        .fadeIn(duration: 400.ms)
        .scale(begin: const Offset(0, 0), end: const Offset(1, 1), duration: 400.ms)
        .then()
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .scaleY(begin: 1, end: 1.3, duration: 800.ms);
  }
}
