import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../models/air_quality.dart';
import '../models/app_settings.dart';
import '../services/air_quality_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/city_search_sheet.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  CityProfile? _selectedCity;
  bool _loadingPredictions = false;

  @override
  void initState() {
    super.initState();
    // Charger les prédictions PM2.5 pour toutes les villes en arrière-plan
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadAllPredictions());
  }

  Future<void> _loadAllPredictions() async {
    if (_loadingPredictions) return;
    setState(() => _loadingPredictions = true);
    final provider = context.read<AirQualityProvider>();
    final cities = CameroonCities.allCities;
    // Charger par batch de 5 pour ne pas surcharger l'API
    for (int i = 0; i < cities.length; i += 5) {
      final batch = cities.skip(i).take(5);
      await Future.wait(
        batch.map((c) => provider.fetchPredictedPm25ForCity(c)),
      );
      if (mounted) setState(() {});
      await Future.delayed(const Duration(milliseconds: 500));
    }
    if (mounted) setState(() => _loadingPredictions = false);
  }

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<AppThemeExtension>()!;
    final lang = context.watch<AppSettings>().language;
    final provider = context.watch<AirQualityProvider>();
    final cities = CameroonCities.allCities;
    final cache = provider.cityPm25Cache;

    return Scaffold(
      backgroundColor: ext.bgColor,
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: const LatLng(5.5, 12.5),
              initialZoom: 5.5,
              minZoom: 4.0,
              maxZoom: 14.0,
              onTap: (_, __) => setState(() => _selectedCity = null),
            ),
            children: [
              TileLayer(
                urlTemplate: ext.isDark
                    ? 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png'
                    : 'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png',
                subdomains: const ['a', 'b', 'c', 'd'],
                userAgentPackageName: 'cm.alphainfera.airqual',
              ),
              CircleLayer(
                circles: cities.map((city) {
                  final pm25 = cache[city.name] ?? city.avgPm25;
                  final color = _pm25Color(pm25);
                  return CircleMarker(
                    point: LatLng(city.latitude, city.longitude),
                    radius: _pm25Radius(pm25),
                    color: color.withOpacity(0.3),
                    borderColor: color,
                    borderStrokeWidth: 1.5,
                    useRadiusInMeter: false,
                  );
                }).toList(),
              ),
              MarkerLayer(
                markers: cities.map((city) {
                  final pm25 = cache[city.name] ?? city.avgPm25;
                  final color = _pm25Color(pm25);
                  final isSelected = _selectedCity?.name == city.name;
                  return Marker(
                    point: LatLng(city.latitude, city.longitude),
                    width: isSelected ? 140 : 36,
                    height: isSelected ? 60 : 36,
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedCity = city),
                      child: isSelected
                          ? _SelectedMarker(city: city, pm25: pm25, color: color, lang: lang)
                          : _DotMarker(color: color, pm25: pm25),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),

          // Top bar recherche
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (_) => const CitySearchSheet(),
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: ext.surfaceColor.withOpacity(0.95),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: ext.borderColor),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 12)],
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.search_rounded, color: ext.textMuted, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              lang == 'fr' ? 'Rechercher une ville...' : 'Search a city...',
                              style: TextStyle(fontSize: 14, color: ext.textMuted),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (_loadingPredictions) ...[
                    const SizedBox(width: 10),
                    const SizedBox(
                      width: 20, height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Légende
          Positioned(
            bottom: 24,
            left: 16,
            child: _Legend(lang: lang, ext: ext)
                .animate().fadeIn(delay: 300.ms).slideY(begin: 0.3, end: 0),
          ),

          // Card ville sélectionnée
          if (_selectedCity != null)
            Positioned(
              bottom: 24,
              right: 16,
              left: 160,
              child: _CityDetailCard(
                city: _selectedCity!,
                pm25: cache[_selectedCity!.name] ?? _selectedCity!.avgPm25,
                lang: lang,
                ext: ext,
                onClose: () => setState(() => _selectedCity = null),
                onLoad: () {
                  context.read<AirQualityProvider>().loadCity(_selectedCity!);
                  setState(() => _selectedCity = null);
                  _navigateToHome(context);
                },
              ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.3, end: 0),
            ),
        ],
      ),
    );
  }

  void _navigateToHome(BuildContext context) {
    final controller = MainShellController.of(context);
    if (controller != null) {
      controller.goToTab(0);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.read<AppSettings>().language == 'fr'
                ? 'Données chargées. Retournez à l\'accueil.'
                : 'Data loaded. Go back to Home.',
          ),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  double _pm25Radius(double pm25) {
    if (pm25 <= 12) return 8;
    if (pm25 <= 15) return 10;
    if (pm25 <= 25) return 13;
    if (pm25 <= 35) return 16;
    return 20;
  }

  Color _pm25Color(double pm25) {
    if (pm25 <= 12) return AppColors.aqi_good;
    if (pm25 <= 15) return AppColors.aqi_moderate;
    if (pm25 <= 25) return AppColors.aqi_elevated;
    if (pm25 <= 35) return AppColors.aqi_high;
    return AppColors.aqi_very_high;
  }
}

class _DotMarker extends StatelessWidget {
  final Color color;
  final double pm25;
  const _DotMarker({required this.color, required this.pm25});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30, height: 30,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(0.9),
        border: Border.all(color: Colors.white, width: 1.5),
        boxShadow: [BoxShadow(color: color.withOpacity(0.4), blurRadius: 8)],
      ),
      child: Center(
        child: Text(
          pm25.toStringAsFixed(0),
          style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w700, color: Colors.white),
        ),
      ),
    );
  }
}

class _SelectedMarker extends StatelessWidget {
  final CityProfile city;
  final double pm25;
  final Color color;
  final String lang;
  const _SelectedMarker({required this.city, required this.pm25, required this.color, required this.lang});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [BoxShadow(color: color.withOpacity(0.5), blurRadius: 12)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(city.name,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white)),
          Text('${pm25.toStringAsFixed(1)} µg/m³',
              style: TextStyle(fontSize: 10, color: Colors.white.withOpacity(0.85))),
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  final String lang;
  final AppThemeExtension ext;
  const _Legend({required this.lang, required this.ext});

  @override
  Widget build(BuildContext context) {
    final items = [
      (AppColors.aqi_good,     lang == 'fr' ? 'Bon (≤12)'       : 'Good (≤12)'),
      (AppColors.aqi_moderate, lang == 'fr' ? 'Modéré (≤15)'    : 'Moderate (≤15)'),
      (AppColors.aqi_elevated, lang == 'fr' ? 'Élevé (≤25)'     : 'Elevated (≤25)'),
      (AppColors.aqi_high,     lang == 'fr' ? 'Haut (≤35)'      : 'High (≤35)'),
      (AppColors.aqi_very_high,lang == 'fr' ? 'Dangereux (>35)' : 'Dangerous (>35)'),
    ];
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ext.surfaceColor.withOpacity(0.95),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ext.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('PM2.5 µg/m³',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: ext.textColor)),
          const SizedBox(height: 6),
          ...items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 10, height: 10,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: item.$1)),
                const SizedBox(width: 6),
                Text(item.$2, style: TextStyle(fontSize: 10, color: ext.textSecondary)),
              ],
            ),
          )),
        ],
      ),
    );
  }
}

class _CityDetailCard extends StatelessWidget {
  final CityProfile city;
  final double pm25;
  final String lang;
  final AppThemeExtension ext;
  final VoidCallback onClose;
  final VoidCallback onLoad;

  const _CityDetailCard({
    required this.city, required this.pm25, required this.lang,
    required this.ext, required this.onClose, required this.onLoad,
  });

  @override
  Widget build(BuildContext context) {
    final color = _pm25Color(pm25);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: ext.surfaceColor.withOpacity(0.97),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 16)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(city.name,
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: ext.textColor)),
              ),
              GestureDetector(onTap: onClose,
                  child: Icon(Icons.close_rounded, size: 18, color: ext.textMuted)),
            ],
          ),
          Text(city.region, style: TextStyle(fontSize: 11, color: ext.textMuted)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'PM2.5 ${pm25.toStringAsFixed(1)} µg/m³',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onLoad,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
              child: Text(lang == 'fr' ? 'Voir détails' : 'View details'),
            ),
          ),
        ],
      ),
    );
  }

  Color _pm25Color(double pm25) {
    if (pm25 <= 12) return AppColors.aqi_good;
    if (pm25 <= 15) return AppColors.aqi_moderate;
    if (pm25 <= 25) return AppColors.aqi_elevated;
    if (pm25 <= 35) return AppColors.aqi_high;
    return AppColors.aqi_very_high;
  }
}

// ── MainShellController ───────────────────────────────────────────────────────
class MainShellController extends InheritedWidget {
  final void Function(int) goToTab;

  const MainShellController({
    super.key,
    required this.goToTab,
    required super.child,
  });

  static MainShellController? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<MainShellController>();
  }

  @override
  bool updateShouldNotify(MainShellController oldWidget) => false;
}
