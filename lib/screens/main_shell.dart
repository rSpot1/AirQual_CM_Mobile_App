import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/app_settings.dart';
import '../services/air_quality_provider.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';
import 'map_screen.dart';
import 'forecast_screen.dart';
import 'settings_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AirQualityProvider>().initWithLocation();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNavTap(int index) {
    HapticFeedback.lightImpact();
    setState(() => _currentIndex = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettings>();
    final ext = Theme.of(context).extension<AppThemeExtension>()!;
    final lang = settings.language;

    final tabs = [
      _Tab(icon: Icons.home_rounded, label: lang == 'fr' ? 'Accueil' : 'Home'),
      _Tab(icon: Icons.map_rounded, label: lang == 'fr' ? 'Carte' : 'Map'),
      _Tab(icon: Icons.timeline_rounded, label: lang == 'fr' ? 'Prévisions' : 'Forecast'),
      _Tab(icon: Icons.settings_rounded, label: lang == 'fr' ? 'Paramètres' : 'Settings'),
    ];

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: settings.isDark
          ? SystemUiOverlayStyle.light.copyWith(
              statusBarColor: Colors.transparent,
              systemNavigationBarColor: ext.surfaceColor,
            )
          : SystemUiOverlayStyle.dark.copyWith(
              statusBarColor: Colors.transparent,
              systemNavigationBarColor: ext.surfaceColor,
            ),
      // Expose goToTab aux descendants (ex: MapScreen → bouton "Voir détails")
      child: MainShellController(
        goToTab: _onNavTap,
        child: Scaffold(
          body: PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            children: const [
              HomeScreen(),
              MapScreen(),
              ForecastScreen(),
              SettingsScreen(),
            ],
          ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: ext.surfaceColor,
              border: Border(top: BorderSide(color: ext.borderColor, width: 0.5)),
            ),
            child: SafeArea(
              child: SizedBox(
                height: 62,
                child: Row(
                  children: List.generate(tabs.length, (i) {
                    final tab = tabs[i];
                    final selected = _currentIndex == i;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => _onNavTap(i),
                        behavior: HitTestBehavior.opaque,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 6),
                                decoration: BoxDecoration(
                                  color: selected
                                      ? AppColors.primary.withOpacity(0.15)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  tab.icon,
                                  size: 22,
                                  color: selected ? AppColors.primary : ext.textMuted,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                tab.label,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight:
                                      selected ? FontWeight.w600 : FontWeight.w400,
                                  color: selected ? AppColors.primary : ext.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Tab {
  final IconData icon;
  final String label;
  const _Tab({required this.icon, required this.label});
}
