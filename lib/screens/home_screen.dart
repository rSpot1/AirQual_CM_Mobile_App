import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../models/air_quality.dart';
import '../models/app_settings.dart';
import '../services/air_quality_provider.dart';
import '../theme/app_theme.dart';
import '../utils/aq_utils.dart';
import '../widgets/aqi_gauge.dart';
import '../widgets/forecast_card.dart';
import '../widgets/factor_chip.dart';
import '../widgets/city_search_sheet.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AirQualityProvider>();
    final settings = context.watch<AppSettings>();
    final ext = Theme.of(context).extension<AppThemeExtension>()!;
    final lang = settings.language;

    // Rafraîchissement silencieux : pendant le chargement initial, afficher Maroua par défaut
    final displayData = provider.currentData ?? _buildMarouaDefault();
    final isRefreshing = provider.isLoading;

    if (provider.currentData == null && !provider.isLoading) {
      return _ErrorView(onRetry: () => provider.refresh(), lang: lang);
    }

    return _HomeContent(
      data: displayData,
      lang: lang,
      ext: ext,
      isRefreshing: isRefreshing,
    );
  }

  static AirQualityData _buildMarouaDefault() {
    final now = DateTime.now();
    final forecasts = List.generate(14, (i) {
      final date = now.add(Duration(days: i));
      final pm25 = 28.5 + (i % 3 == 0 ? 4.0 : -2.0);
      return DailyForecast(
        date: date,
        tempMax: 37.2,
        tempMin: 27.0,
        precipitation: 0.0,
        windSpeed: 12.0,
        radiation: 228.0,
        pm25: pm25,
        level: AQILevel.elevated,
      );
    });

    return AirQualityData(
      city: 'Maroua',
      region: 'Extrême-Nord',
      latitude: 10.5903,
      longitude: 14.3147,
      pm25: 28.5,
      temperature: 35.2,
      windSpeed: 12.0,
      precipitation: 0.0,
      humidity: 28.0,
      radiation: 820.0,
      timestamp: now,
      level: AQILevel.elevated,
      aggravatingFactors: ['Harmattan', 'Sécheresse'],
      forecast: forecasts,
    );
  }
}

class _HomeContent extends StatelessWidget {
  final AirQualityData data;
  final String lang;
  final AppThemeExtension ext;
  final bool isRefreshing;

  const _HomeContent({
    required this.data,
    required this.lang,
    required this.ext,
    this.isRefreshing = false,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.read<AirQualityProvider>();

    return Scaffold(
      backgroundColor: ext.bgColor,
      body: RefreshIndicator(
        onRefresh: () => provider.refresh(),
        color: AppColors.primary,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverAppBar(
              expandedHeight: 340,
              collapsedHeight: 60,
              pinned: true,
              backgroundColor: const Color(0xFF0A1628),
              flexibleSpace: FlexibleSpaceBar(
                background: _HeroHeader(data: data, lang: lang, isRefreshing: isRefreshing),
              ),
              // Nom de l'app à gauche 
              title: Row(
                children: [
                  const Text(
                    'AirQual CM',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
              actions: [
                // Icône rafraîchissement animée (tourne pendant le chargement)
                isRefreshing
                    ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white.withOpacity(0.7),
                            ),
                          ),
                        ).animate(onPlay: (c) => c.repeat())
                            .rotate(duration: 1000.ms),
                      )
                    : IconButton(
                        icon: const Icon(Icons.refresh_rounded, color: Colors.white70),
                        onPressed: () => provider.refresh(),
                      ),
                IconButton(
                  icon: const Icon(Icons.search_rounded, color: Colors.white70),
                  onPressed: () => _showCitySearch(context),
                ),
              ],
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),

                    // PM2.5 moyen national
                    _NationalAverageBanner(lang: lang, ext: ext)
                        .animate().fadeIn(delay: 100.ms).slideY(begin: 0.2, end: 0),

                    const SizedBox(height: 10),

                    // Health advice banner
                    _HealthBanner(data: data, lang: lang)
                        .animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),

                    const SizedBox(height: 20),

                    // Conditions météo — 2×2
                    _SectionTitle(
                      title: lang == 'fr' ? 'Conditions météo' : 'Weather conditions',
                      ext: ext,
                    ),
                    const SizedBox(height: 12),
                    _WeatherKpiGrid(data: data, ext: ext)
                        .animate().fadeIn(delay: 300.ms).slideY(begin: 0.2, end: 0),

                    const SizedBox(height: 24),

                    // Facteurs aggravants
                    if (data.aggravatingFactors.isNotEmpty) ...[
                      _SectionTitle(
                        title: lang == 'fr'
                            ? 'Facteurs aggravants'
                            : 'Aggravating factors',
                        ext: ext,
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: data.aggravatingFactors
                            .map((f) => FactorChip(factor: f, lang: lang))
                            .toList(),
                      ).animate().fadeIn(delay: 400.ms),
                      const SizedBox(height: 24),
                    ],

                    // 7-day forecast
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _SectionTitle(
                          title: lang == 'fr' ? 'Prévisions 7 jours' : '7-Day Forecast',
                          ext: ext,
                        ),
                        TextButton(
                          onPressed: () {},
                          child: Text(
                            lang == 'fr' ? 'Voir tout' : 'See all',
                            style: const TextStyle(color: AppColors.primary, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 160,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: data.forecast.take(7).length,
                        separatorBuilder: (_, __) => const SizedBox(width: 10),
                        itemBuilder: (context, i) {
                          final f = data.forecast[i];
                          return ForecastCard(
                            forecast: f,
                            lang: lang,
                            isFirst: i == 0,
                          ).animate().fadeIn(delay: (500 + i * 80).ms);
                        },
                      ),
                    ),

                    const SizedBox(height: 24),

                    _Pm25TrendChart(data: data, lang: lang, ext: ext)
                        .animate().fadeIn(delay: 600.ms),

                    const SizedBox(height: 24),

                    _WhoCard(lang: lang, ext: ext)
                        .animate().fadeIn(delay: 700.ms),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCitySearch(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const CitySearchSheet(),
    );
  }
}

// ── Bannière PM2.5 national ───────────────────────────────────────────────────
class _NationalAverageBanner extends StatelessWidget {
  final String lang;
  final AppThemeExtension ext;

  const _NationalAverageBanner({required this.lang, required this.ext});

  @override
  Widget build(BuildContext context) {
    final avg = CameroonCities.nationalAveragePm25;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.12),
            AppColors.secondary.withOpacity(0.06),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.public_rounded, color: AppColors.primary, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              lang == 'fr'
                  ? 'PM2.5 moy. nationale : ${avg.toStringAsFixed(1)} µg/m³'
                  : 'National avg PM2.5: ${avg.toStringAsFixed(1)} µg/m³',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: ext.textColor,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.aqi_elevated.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Cameroun',
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: AppColors.aqi_elevated,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Hero Header ───────────────────────────────────────────────────────────────
class _HeroHeader extends StatelessWidget {
  final AirQualityData data;
  final String lang;
  final bool isRefreshing;

  const _HeroHeader({required this.data, required this.lang, this.isRefreshing = false});

  @override
  Widget build(BuildContext context) {
    final levelColor = AQUtils.levelColor(data.level);
    final levelLabel = AQUtils.levelLabel(data.level, lang);
    final now = DateTime.now().toUtc().add(const Duration(hours: 1));
    final timeStr = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')} GMT+1';

    return Stack(
      fit: StackFit.expand,
      children: [
        // Fond gradient professionnel (remplacé par assets/images/hero_bg.png si présent)
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF0A1628), Color(0xFF0D2347), Color(0xFF0A1628)],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                top: -40, right: -30,
                child: Container(
                  width: 200, height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary.withOpacity(0.06),
                  ),
                ),
              ),
              Positioned(
                bottom: 20, left: -30,
                child: Container(
                  width: 150, height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: levelColor.withOpacity(0.05),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Image pro (si disponible via assets)
        Image.asset(
          'assets/images/hero_bg.png',
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const SizedBox.shrink(),
        ),
        // Overlay pour lisibilité
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.3),
                Colors.black.withOpacity(0.5),
              ],
            ),
          ),
        ),
        // Contenu
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Location & time / refresh indicator
                Row(
                  children: [
                    Icon(Icons.location_on_rounded,
                        size: 16, color: Colors.white.withOpacity(0.7)),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        '${data.city}, ${data.region}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withOpacity(0.8),
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isRefreshing)
                      Row(
                        children: [
                          SizedBox(
                            width: 12, height: 12,
                            child: CircularProgressIndicator(
                              strokeWidth: 1.5,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white.withOpacity(0.6),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            lang == 'fr' ? 'Actualisation...' : 'Updating...',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.white.withOpacity(0.5),
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      )
                    else
                      Row(
                        children: [
                          Icon(Icons.access_time_rounded,
                              size: 14, color: Colors.white.withOpacity(0.5)),
                          const SizedBox(width: 4),
                          Text(
                            timeStr,
                            style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.5)),
                          ),
                        ],
                      ),
                  ],
                ),

                const SizedBox(height: 24),

                // Gauge + PM2.5
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    AqiGauge(pm25: data.pm25, level: data.level),
                    const SizedBox(width: 24),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'PM2.5',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.5),
                              letterSpacing: 1.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                data.pm25.toStringAsFixed(1),
                                style: const TextStyle(
                                  fontSize: 44,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  height: 1,
                                ),
                              )
                                  .animate()
                                  .fadeIn(duration: 600.ms)
                                  .slideY(begin: 0.5, end: 0),
                              const SizedBox(width: 6),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Text(
                                  'µg/m³',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white.withOpacity(0.6),
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                            decoration: BoxDecoration(
                              color: levelColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: levelColor.withOpacity(0.4)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 8, height: 8,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: levelColor,
                                    boxShadow: [BoxShadow(color: levelColor, blurRadius: 6)],
                                  ),
                                )
                                    .animate(onPlay: (c) => c.repeat(reverse: true))
                                    .scaleXY(begin: 0.8, end: 1.2, duration: 900.ms),
                                const SizedBox(width: 6),
                                Text(
                                  levelLabel,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: levelColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── Health Banner ─────────────────────────────────────────────────────────────
class _HealthBanner extends StatelessWidget {
  final AirQualityData data;
  final String lang;

  const _HealthBanner({required this.data, required this.lang});

  @override
  Widget build(BuildContext context) {
    final color = AQUtils.levelColor(data.level);
    final advice = AQUtils.healthAdvice(data.level, lang);
    final icon = AQUtils.levelIcon(data.level);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.withOpacity(0.15), color.withOpacity(0.05)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lang == 'fr' ? 'Conseil santé' : 'Health advice',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: color.withOpacity(0.8),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  advice,
                  style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context)
                        .extension<AppThemeExtension>()!
                        .textColor
                        .withOpacity(0.85),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Weather KPI Grid 2×2 ──────────────────────────────────────────────────────
class _WeatherKpiGrid extends StatelessWidget {
  final AirQualityData data;
  final AppThemeExtension ext;

  const _WeatherKpiGrid({required this.data, required this.ext});

  @override
  Widget build(BuildContext context) {
    final lang = context.read<AppSettings>().language;

    final kpis = [
      _KpiItem(
        icon: Icons.thermostat_rounded,
        color: const Color(0xFFFF9F0A),
        label: lang == 'fr' ? 'Température' : 'Temperature',
        value: '${data.temperature.toStringAsFixed(1)}°C',
      ),
      _KpiItem(
        icon: Icons.air_rounded,
        color: AppColors.primary,
        label: lang == 'fr' ? 'Vent' : 'Wind',
        value: '${data.windSpeed.toStringAsFixed(0)} km/h',
      ),
      _KpiItem(
        icon: Icons.water_drop_rounded,
        color: const Color(0xFF5AB3FF),
        label: lang == 'fr' ? 'Humidité' : 'Humidity',
        value: '${data.humidity.toStringAsFixed(0)}%',
      ),
      _KpiItem(
        icon: Icons.wb_sunny_rounded,
        color: const Color(0xFFFFD60A),
        label: lang == 'fr' ? 'Radiation' : 'Radiation',
        value: '${data.radiation.toStringAsFixed(0)} W/m²',
      ),
    ];

    return Column(
      children: [
        Row(
          children: [
            _KpiCard(kpi: kpis[0], ext: ext),
            const SizedBox(width: 10),
            _KpiCard(kpi: kpis[1], ext: ext),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            _KpiCard(kpi: kpis[2], ext: ext),
            const SizedBox(width: 10),
            _KpiCard(kpi: kpis[3], ext: ext),
          ],
        ),
      ],
    );
  }
}

class _KpiCard extends StatelessWidget {
  final _KpiItem kpi;
  final AppThemeExtension ext;

  const _KpiCard({required this.kpi, required this.ext});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: ext.cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: ext.borderColor),
        ),
        child: Row(
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: kpi.color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(kpi.icon, color: kpi.color, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    kpi.value,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: ext.textColor,
                    ),
                  ),
                  Text(
                    kpi.label,
                    style: TextStyle(fontSize: 10, color: ext.textMuted),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _KpiItem {
  final IconData icon;
  final Color color;
  final String label;
  final String value;
  const _KpiItem({required this.icon, required this.color, required this.label, required this.value});
}

// ── PM2.5 Trend Chart ─────────────────────────────────────────────────────────
class _Pm25TrendChart extends StatelessWidget {
  final AirQualityData data;
  final String lang;
  final AppThemeExtension ext;

  const _Pm25TrendChart({required this.data, required this.lang, required this.ext});

  @override
  Widget build(BuildContext context) {
    final maxPm25 = data.forecast.take(7).map((f) => f.pm25).fold(0.0, (a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ext.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ext.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            lang == 'fr' ? 'Tendance PM2.5 (7 jours)' : 'PM2.5 Trend (7 days)',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: ext.textColor),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 80,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: data.forecast.take(7).toList().asMap().entries.map((e) {
                final f = e.value;
                final pct = maxPm25 > 0 ? (f.pm25 / maxPm25) : 0.0;
                final color = AQUtils.levelColor(f.level);
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(f.pm25.toStringAsFixed(1), style: TextStyle(fontSize: 8, color: ext.textMuted)),
                        const SizedBox(height: 3),
                        AnimatedContainer(
                          duration: Duration(milliseconds: 500 + e.key * 100),
                          curve: Curves.easeOut,
                          height: (pct * 60).clamp(8.0, 60.0),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [color, color.withOpacity(0.4)],
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          AQUtils.weekdayLabel(f.date, lang),
                          style: TextStyle(fontSize: 9, color: ext.textMuted),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                width: 8, height: 8,
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.danger.withOpacity(0.6), width: 1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 4),
              Text(
                lang == 'fr' ? 'Seuil OMS : 15 µg/m³' : 'WHO limit: 15 µg/m³',
                style: TextStyle(fontSize: 10, color: ext.textMuted),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── WHO Card ──────────────────────────────────────────────────────────────────
class _WhoCard extends StatelessWidget {
  final String lang;
  final AppThemeExtension ext;

  const _WhoCard({required this.lang, required this.ext});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary.withOpacity(0.12), AppColors.primary.withOpacity(0.04)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.health_and_safety_rounded, color: AppColors.primary, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lang == 'fr' ? 'Directive OMS' : 'WHO Guideline',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: ext.textColor),
                ),
                const SizedBox(height: 4),
                Text(
                  lang == 'fr'
                      ? 'L\'OMS recommande un maximum de 15 µg/m³ de PM2.5 par an pour protéger la santé humaine.'
                      : 'WHO recommends a maximum of 15 µg/m³ PM2.5 annually to protect human health.',
                  style: TextStyle(fontSize: 12, color: ext.textSecondary, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Section Title ─────────────────────────────────────────────────────────────
class _SectionTitle extends StatelessWidget {
  final String title;
  final AppThemeExtension ext;

  const _SectionTitle({required this.title, required this.ext});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: ext.textColor),
    );
  }
}

// ── Error View ────────────────────────────────────────────────────────────────
class _ErrorView extends StatelessWidget {
  final VoidCallback onRetry;
  final String lang;

  const _ErrorView({required this.onRetry, required this.lang});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).extension<AppThemeExtension>()!.bgColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off_rounded, size: 64, color: AppColors.primary),
            const SizedBox(height: 16),
            Text(
              lang == 'fr' ? 'Impossible de charger les données' : 'Failed to load data',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(lang == 'fr' ? 'Réessayer' : 'Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
