import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../models/air_quality.dart';
import '../models/app_settings.dart';
import '../services/air_quality_provider.dart';
import '../services/location_service.dart';
import '../theme/app_theme.dart';
import '../utils/aq_utils.dart';
import '../widgets/shimmer_loader.dart';

class ForecastScreen extends StatefulWidget {
  const ForecastScreen({super.key});

  @override
  State<ForecastScreen> createState() => _ForecastScreenState();
}

class _ForecastScreenState extends State<ForecastScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _locationCtrl = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  bool _isSearchingLocation = false;
  bool _showSuggestions = false;
  List<CityProfile> _suggestions = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _searchFocus.addListener(() {
      if (!_searchFocus.hasFocus) {
        Future.delayed(const Duration(milliseconds: 150), () {
          if (mounted) setState(() => _showSuggestions = false);
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _locationCtrl.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    setState(() {
      if (query.isEmpty) {
        _suggestions = CameroonCities.allCities;
        _showSuggestions = true;
      } else {
        _suggestions = CameroonCities.allCities
            .where((c) =>
                c.name.toLowerCase().contains(query.toLowerCase()) ||
                c.region.toLowerCase().contains(query.toLowerCase()))
            .toList();
        _showSuggestions = _suggestions.isNotEmpty;
      }
    });
  }

  void _selectCity(CityProfile city) {
    _locationCtrl.text = city.name;
    setState(() => _showSuggestions = false);
    _searchFocus.unfocus();
    _loadCity(city);
  }

  Future<void> _loadCity(CityProfile city) async {
    setState(() => _isSearchingLocation = true);
    await context.read<AirQualityProvider>().loadCity(city);
    if (mounted) setState(() => _isSearchingLocation = false);
  }

  Future<void> _useGpsLocation() async {
    setState(() {
      _isSearchingLocation = true;
      _showSuggestions = false;
      _locationCtrl.clear();
    });
    _searchFocus.unfocus();

    final locationSvc = LocationService();
    final position = await locationSvc.getCurrentPosition();

    if (position != null) {
      final nearest = locationSvc.findNearestCity(position.latitude, position.longitude);
      _locationCtrl.text = nearest.name;
      await context.read<AirQualityProvider>().loadCity(nearest);
    } else {
      // Permission refusée ou GPS off — utiliser initWithLocation qui gère le fallback
      await context.read<AirQualityProvider>().initWithLocation();
    }

    if (mounted) setState(() => _isSearchingLocation = false);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AirQualityProvider>();
    final settings = context.watch<AppSettings>();
    final ext = Theme.of(context).extension<AppThemeExtension>()!;
    final lang = settings.language;
    final forecastDays = settings.forecastDays;

    return Scaffold(
      backgroundColor: ext.bgColor,
      appBar: AppBar(
        backgroundColor: ext.bgColor,
        title: Text(
          lang == 'fr' ? 'Prévisions' : 'Forecast',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: ext.textColor),
        ),
        actions: [
          PopupMenuButton<int>(
            icon: Icon(Icons.tune_rounded, color: ext.textSecondary),
            color: ext.surfaceColor,
            onSelected: (days) => settings.setForecastDays(days),
            itemBuilder: (_) => [7, 10, 14].map((d) => PopupMenuItem(
              value: d,
              child: Text(
                '$d ${lang == 'fr' ? 'jours' : 'days'}',
                style: TextStyle(
                  color: forecastDays == d ? AppColors.primary : ext.textColor,
                  fontWeight: forecastDays == d ? FontWeight.w700 : FontWeight.w400,
                ),
              ),
            )).toList(),
          ),
          IconButton(
            icon: Icon(Icons.refresh_rounded, color: ext.textSecondary),
            onPressed: () => provider.refresh(forecastDays: forecastDays),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: Column(
            children: [
              // Barre de localisation avec suggestions
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 40,
                        decoration: BoxDecoration(
                          color: ext.cardColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _showSuggestions
                                ? AppColors.primary
                                : ext.borderColor,
                            width: _showSuggestions ? 1.5 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            const SizedBox(width: 10),
                            Icon(Icons.search_rounded, color: ext.textMuted, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                controller: _locationCtrl,
                                focusNode: _searchFocus,
                                style: TextStyle(fontSize: 13, color: ext.textColor),
                                decoration: InputDecoration(
                                  hintText: lang == 'fr'
                                      ? 'Entrer une ville...'
                                      : 'Enter a city...',
                                  hintStyle: TextStyle(fontSize: 13, color: ext.textMuted),
                                  border: InputBorder.none,
                                  isDense: true,
                                ),
                                onChanged: _onSearchChanged,
                                onTap: () {
                                  setState(() {
                                    _suggestions = CameroonCities.allCities;
                                    _showSuggestions = true;
                                  });
                                },
                                textInputAction: TextInputAction.search,
                              ),
                            ),
                            if (_isSearchingLocation)
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8),
                                child: SizedBox(
                                  width: 16, height: 16,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: AppColors.primary),
                                ),
                              )
                            else if (_locationCtrl.text.isNotEmpty)
                              GestureDetector(
                                onTap: () {
                                  _locationCtrl.clear();
                                  setState(() => _showSuggestions = false);
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                  child: Icon(Icons.close_rounded,
                                      size: 16, color: ext.textMuted),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Bouton GPS
                    GestureDetector(
                      onTap: _useGpsLocation,
                      child: Container(
                        height: 40, width: 40,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                        ),
                        child: const Icon(Icons.my_location_rounded,
                            color: AppColors.primary, size: 20),
                      ),
                    ),
                  ],
                ),
              ),
              TabBar(
                controller: _tabController,
                labelColor: AppColors.primary,
                unselectedLabelColor: ext.textMuted,
                indicatorColor: AppColors.primary,
                indicatorSize: TabBarIndicatorSize.label,
                labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                tabs: [
                  const Tab(text: 'PM2.5'),
                  Tab(text: lang == 'fr' ? 'Climat' : 'Climate'),
                ],
              ),
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          // Contenu principal
          provider.isLoading
              ? const ShimmerLoader()
              : provider.currentData == null
                  ? Center(
                      child: Text(
                        lang == 'fr' ? 'Aucune donnée' : 'No data',
                        style: TextStyle(color: ext.textMuted),
                      ),
                    )
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        _Pm25Tab(data: provider.currentData!, lang: lang, ext: ext, days: forecastDays),
                        _ClimateTab(data: provider.currentData!, lang: lang, ext: ext, days: forecastDays),
                      ],
                    ),

          // Liste de suggestions flottante
          if (_showSuggestions && _suggestions.isNotEmpty)
            Positioned(
              top: 0,
              left: 16,
              right: 64, // laisser place au bouton GPS
              child: Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(12),
                color: ext.surfaceColor,
                child: Container(
                  constraints: const BoxConstraints(maxHeight: 280),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: ListView.separated(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      itemCount: _suggestions.length,
                      separatorBuilder: (_, __) =>
                          Divider(color: ext.borderColor, height: 1),
                      itemBuilder: (_, i) {
                        final city = _suggestions[i];
                        return ListTile(
                          dense: true,
                          leading: Icon(Icons.location_city_rounded,
                              color: AppColors.primary, size: 18),
                          title: Text(city.name,
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: ext.textColor)),
                          subtitle: Text(city.region,
                              style: TextStyle(fontSize: 11, color: ext.textMuted)),
                          onTap: () => _selectCity(city),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── PM2.5 Tab ─────────────────────────────────────────────────────────────────
class _Pm25Tab extends StatelessWidget {
  final AirQualityData data;
  final String lang;
  final AppThemeExtension ext;
  final int days;

  const _Pm25Tab({required this.data, required this.lang, required this.ext, required this.days});

  @override
  Widget build(BuildContext context) {
    final forecasts = data.forecast.take(days).toList();
    final alertDays = forecasts.where((f) => f.pm25 > 25).toList();

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.location_on_rounded, size: 14, color: AppColors.primary),
            const SizedBox(width: 4),
            Text('${data.city}, ${data.region}',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: ext.textSecondary)),
          ]),
          const SizedBox(height: 12),
          if (alertDays.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.danger.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.danger.withOpacity(0.3)),
              ),
              child: Row(children: [
                const Icon(Icons.warning_amber_rounded, color: AppColors.danger, size: 20),
                const SizedBox(width: 10),
                Expanded(child: Text(
                  lang == 'fr'
                      ? '${alertDays.length} jour(s) avec PM2.5 > 25 µg/m³ prévu(s)'
                      : '${alertDays.length} day(s) with PM2.5 > 25 µg/m³ expected',
                  style: const TextStyle(fontSize: 12, color: AppColors.danger, fontWeight: FontWeight.w600),
                )),
              ]),
            ),
            const SizedBox(height: 12),
          ],
          Text(
            lang == 'fr' ? 'Évolution PM2.5 (µg/m³)' : 'PM2.5 Trend (µg/m³)',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: ext.textColor),
          ),
          const SizedBox(height: 12),
          _Pm25LineChart(forecasts: forecasts, ext: ext, lang: lang)
              .animate().fadeIn(delay: 100.ms),
          const SizedBox(height: 20),
          Text(
            lang == 'fr' ? 'Détail par jour' : 'Daily breakdown',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: ext.textColor),
          ),
          const SizedBox(height: 10),
          ...forecasts.asMap().entries.map((e) => _ForecastRow(
                forecast: e.value, lang: lang, ext: ext, index: e.key,
              ).animate().fadeIn(delay: (150 + e.key * 50).ms)),
        ],
      ),
    );
  }
}

class _Pm25LineChart extends StatelessWidget {
  final List<DailyForecast> forecasts;
  final AppThemeExtension ext;
  final String lang;

  const _Pm25LineChart({required this.forecasts, required this.ext, required this.lang});

  @override
  Widget build(BuildContext context) {
    final spots = forecasts.asMap().entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.pm25))
        .toList();
    final maxY = (forecasts.map((f) => f.pm25).fold(0.0, (a, b) => a > b ? a : b) + 5).ceilToDouble();

    return Container(
      padding: const EdgeInsets.fromLTRB(8, 16, 16, 8),
      height: 220,
      decoration: BoxDecoration(
        color: ext.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ext.borderColor),
      ),
      child: LineChart(LineChartData(
        minY: 0, maxY: maxY,
        gridData: FlGridData(
          show: true, drawVerticalLine: false, horizontalInterval: 10,
          getDrawingHorizontalLine: (_) => FlLine(color: ext.borderColor, strokeWidth: 0.5),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(sideTitles: SideTitles(
            showTitles: true, interval: 10, reservedSize: 32,
            getTitlesWidget: (v, _) => Text(v.toInt().toString(),
                style: TextStyle(fontSize: 9, color: ext.textMuted)),
          )),
          bottomTitles: AxisTitles(sideTitles: SideTitles(
            showTitles: true, interval: 1, reservedSize: 28,
            getTitlesWidget: (v, _) {
              final i = v.toInt();
              if (i >= forecasts.length) return const SizedBox();
              return Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(AQUtils.weekdayLabel(forecasts[i].date, lang),
                    style: TextStyle(fontSize: 9, color: ext.textMuted)),
              );
            },
          )),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        extraLinesData: ExtraLinesData(horizontalLines: [
          HorizontalLine(
            y: 15, color: AppColors.danger.withOpacity(0.5),
            strokeWidth: 1, dashArray: [6, 4],
            label: HorizontalLineLabel(
              show: true, alignment: Alignment.topRight,
              labelResolver: (_) => 'OMS 15',
              style: TextStyle(fontSize: 9, color: AppColors.danger.withOpacity(0.7)),
            ),
          ),
        ]),
        lineBarsData: [
          LineChartBarData(
            spots: spots, isCurved: true, curveSmoothness: 0.35,
            color: AppColors.primary, barWidth: 2.5, isStrokeCapRound: true,
            dotData: FlDotData(show: true, getDotPainter: (spot, _, __, ___) {
              final pm25 = spot.y;
              Color c;
              if (pm25 <= 12) c = AppColors.aqi_good;
              else if (pm25 <= 15) c = AppColors.aqi_moderate;
              else if (pm25 <= 25) c = AppColors.aqi_elevated;
              else if (pm25 <= 35) c = AppColors.aqi_high;
              else c = AppColors.aqi_very_high;
              return FlDotCirclePainter(radius: 4, color: c, strokeColor: Colors.white, strokeWidth: 1.5);
            }),
            belowBarData: BarAreaData(show: true, gradient: LinearGradient(
              begin: Alignment.topCenter, end: Alignment.bottomCenter,
              colors: [AppColors.primary.withOpacity(0.2), AppColors.primary.withOpacity(0.0)],
            )),
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => ext.cardColor,
            getTooltipItems: (spots) => spots.map((s) => LineTooltipItem(
              '${s.y.toStringAsFixed(1)} µg/m³',
              TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 12),
            )).toList(),
          ),
        ),
      )),
    );
  }
}

class _ForecastRow extends StatelessWidget {
  final DailyForecast forecast;
  final String lang;
  final AppThemeExtension ext;
  final int index;

  const _ForecastRow({required this.forecast, required this.lang, required this.ext, required this.index});

  @override
  Widget build(BuildContext context) {
    final color = AQUtils.levelColor(forecast.level);
    final label = AQUtils.levelLabel(forecast.level, lang);
    final isToday = index == 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: ext.cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isToday ? color.withOpacity(0.3) : ext.borderColor),
      ),
      child: Row(children: [
        SizedBox(width: 48, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
            isToday ? (lang == 'fr' ? 'Auj.' : 'Today') : AQUtils.weekdayLabel(forecast.date, lang),
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
                color: isToday ? color : ext.textColor),
          ),
          Text('${forecast.date.day}/${forecast.date.month}',
              style: TextStyle(fontSize: 10, color: ext.textMuted)),
        ])),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text('${forecast.pm25.toStringAsFixed(1)} µg/m³',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: color)),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(6)),
              child: Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: color)),
            ),
          ]),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (forecast.pm25 / 55).clamp(0.0, 1.0),
              minHeight: 5,
              backgroundColor: ext.borderColor,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ])),
        const SizedBox(width: 12),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Row(children: [
            const Icon(Icons.thermostat_rounded, size: 12, color: Color(0xFFFF9F0A)),
            Text('${forecast.tempMax.toStringAsFixed(0)}°',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: ext.textColor)),
          ]),
          Row(children: [
            Icon(Icons.air_rounded, size: 12, color: ext.textMuted),
            Text('${forecast.windSpeed.toStringAsFixed(0)}km/h',
                style: TextStyle(fontSize: 11, color: ext.textMuted)),
          ]),
          if (forecast.precipitation > 0)
            Row(children: [
              const Icon(Icons.water_drop_rounded, size: 12, color: AppColors.primary),
              Text('${forecast.precipitation.toStringAsFixed(0)}mm',
                  style: TextStyle(fontSize: 11, color: ext.textMuted)),
            ]),
        ]),
      ]),
    );
  }
}

// ── Climate Tab ───────────────────────────────────────────────────────────────
class _ClimateTab extends StatelessWidget {
  final AirQualityData data;
  final String lang;
  final AppThemeExtension ext;
  final int days;

  const _ClimateTab({required this.data, required this.lang, required this.ext, required this.days});

  @override
  Widget build(BuildContext context) {
    final forecasts = data.forecast.take(days).toList();

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.location_on_rounded, size: 14, color: AppColors.primary),
          const SizedBox(width: 4),
          Text('${data.city}, ${data.region}',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: ext.textSecondary)),
        ]),
        const SizedBox(height: 16),
        Text(lang == 'fr' ? 'Température (°C)' : 'Temperature (°C)',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: ext.textColor)),
        const SizedBox(height: 12),
        _LineChartWidget(
          forecasts: forecasts, getMaxValue: (f) => f.tempMax,
          getMinValue: (f) => f.tempMin, color: const Color(0xFFFF9F0A),
          ext: ext, lang: lang, unit: '°C',
        ).animate().fadeIn(delay: 100.ms),
        const SizedBox(height: 24),
        Text(lang == 'fr' ? 'Vitesse du vent (km/h)' : 'Wind speed (km/h)',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: ext.textColor)),
        const SizedBox(height: 12),
        _LineChartWidget(
          forecasts: forecasts, getMaxValue: (f) => f.windSpeed,
          color: AppColors.primary, ext: ext, lang: lang, unit: 'km/h',
        ).animate().fadeIn(delay: 200.ms),
        const SizedBox(height: 24),
        Text(lang == 'fr' ? 'Précipitations (mm)' : 'Precipitation (mm)',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: ext.textColor)),
        const SizedBox(height: 12),
        _BarChartWidget(
          forecasts: forecasts, getValue: (f) => f.precipitation,
          color: const Color(0xFF5AB3FF), ext: ext, lang: lang,
        ).animate().fadeIn(delay: 300.ms),
      ]),
    );
  }
}

class _LineChartWidget extends StatelessWidget {
  final List<DailyForecast> forecasts;
  final double Function(DailyForecast) getMaxValue;
  final double Function(DailyForecast)? getMinValue;
  final Color color;
  final AppThemeExtension ext;
  final String lang;
  final String unit;

  const _LineChartWidget({
    required this.forecasts, required this.getMaxValue, this.getMinValue,
    required this.color, required this.ext, required this.lang, required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    final maxSpots = forecasts.asMap().entries
        .map((e) => FlSpot(e.key.toDouble(), getMaxValue(e.value))).toList();
    final minSpots = getMinValue != null
        ? forecasts.asMap().entries
            .map((e) => FlSpot(e.key.toDouble(), getMinValue!(e.value))).toList()
        : null;

    final allValues = [
      ...forecasts.map(getMaxValue),
      if (getMinValue != null) ...forecasts.map(getMinValue!),
    ];
    final maxY = (allValues.fold(0.0, (a, b) => a > b ? a : b) * 1.15).ceilToDouble();
    final minY = getMinValue != null
        ? (allValues.fold(double.infinity, (a, b) => a < b ? a : b) - 2).floorToDouble()
        : 0.0;

    return Container(
      height: 180,
      padding: const EdgeInsets.fromLTRB(8, 16, 16, 8),
      decoration: BoxDecoration(
        color: ext.cardColor, borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ext.borderColor),
      ),
      child: LineChart(LineChartData(
        minY: minY, maxY: maxY,
        gridData: FlGridData(
          show: true, drawVerticalLine: false,
          getDrawingHorizontalLine: (_) => FlLine(color: ext.borderColor, strokeWidth: 0.5),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(sideTitles: SideTitles(
            showTitles: true, reservedSize: 34,
            getTitlesWidget: (v, _) => Text(v.toInt().toString(),
                style: TextStyle(fontSize: 9, color: ext.textMuted)),
          )),
          bottomTitles: AxisTitles(sideTitles: SideTitles(
            showTitles: true, interval: 1, reservedSize: 26,
            getTitlesWidget: (v, _) {
              final i = v.toInt();
              if (i >= forecasts.length) return const SizedBox();
              return Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(AQUtils.weekdayLabel(forecasts[i].date, lang),
                    style: TextStyle(fontSize: 9, color: ext.textMuted)),
              );
            },
          )),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: maxSpots, isCurved: true, curveSmoothness: 0.4,
            color: color, barWidth: 2.5, isStrokeCapRound: true,
            dotData: FlDotData(show: true, getDotPainter: (_, __, ___, ____) =>
                FlDotCirclePainter(radius: 3.5, color: color,
                    strokeColor: Colors.white, strokeWidth: 1.5)),
            belowBarData: minSpots == null
                ? BarAreaData(show: true, gradient: LinearGradient(
                    begin: Alignment.topCenter, end: Alignment.bottomCenter,
                    colors: [color.withOpacity(0.2), color.withOpacity(0.0)]))
                : BarAreaData(show: false),
          ),
          if (minSpots != null)
            LineChartBarData(
              spots: minSpots, isCurved: true, curveSmoothness: 0.4,
              color: color.withOpacity(0.5), barWidth: 1.5,
              isStrokeCapRound: true, dotData: const FlDotData(show: false),
              dashArray: [4, 4], belowBarData: BarAreaData(show: false),
            ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => ext.cardColor,
            getTooltipItems: (spots) => spots.map((s) => LineTooltipItem(
              '${s.y.toStringAsFixed(1)} $unit',
              TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 11),
            )).toList(),
          ),
        ),
      )),
    );
  }
}

class _BarChartWidget extends StatelessWidget {
  final List<DailyForecast> forecasts;
  final double Function(DailyForecast) getValue;
  final Color color;
  final AppThemeExtension ext;
  final String lang;

  const _BarChartWidget({
    required this.forecasts, required this.getValue,
    required this.color, required this.ext, required this.lang,
  });

  @override
  Widget build(BuildContext context) {
    final values = forecasts.map(getValue).toList();
    final maxVal = values.fold(0.0, (a, b) => a > b ? a : b);

    return Container(
      height: 160,
      padding: const EdgeInsets.fromLTRB(8, 12, 8, 8),
      decoration: BoxDecoration(
        color: ext.cardColor, borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ext.borderColor),
      ),
      child: BarChart(BarChartData(
        maxY: (maxVal * 1.2 + 1).ceilToDouble(),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) => ext.cardColor,
            getTooltipItem: (group, _, rod, __) => BarTooltipItem(
              '${rod.toY.toStringAsFixed(1)} mm',
              TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 11),
            ),
          ),
        ),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(sideTitles: SideTitles(
            showTitles: true, reservedSize: 22,
            getTitlesWidget: (v, _) {
              final i = v.toInt();
              if (i >= forecasts.length) return const SizedBox();
              return Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(AQUtils.weekdayLabel(forecasts[i].date, lang),
                    style: TextStyle(fontSize: 8, color: ext.textMuted)),
              );
            },
          )),
          leftTitles: AxisTitles(sideTitles: SideTitles(
            showTitles: true, reservedSize: 28,
            getTitlesWidget: (v, _) => Text(v.toInt().toString(),
                style: TextStyle(fontSize: 8, color: ext.textMuted)),
          )),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) => FlLine(color: ext.borderColor, strokeWidth: 0.5),
        ),
        borderData: FlBorderData(show: false),
        barGroups: forecasts.asMap().entries.map((e) => BarChartGroupData(
          x: e.key,
          barRods: [BarChartRodData(
            toY: getValue(e.value), color: color, width: 8,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
            backDrawRodData: BackgroundBarChartRodData(
              show: true, toY: (maxVal * 1.2 + 1).ceilToDouble(),
              color: color.withOpacity(0.07),
            ),
          )],
        )).toList(),
      )),
    );
  }
}
