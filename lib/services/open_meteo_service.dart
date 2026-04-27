import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/air_quality.dart';

/// URL du backend FastAPI AlphaInfera.
/// - \u00c9mulateur Android   : 'http://10.0.2.2:8000'
/// - Device physique LAN : 'http://192.168.X.X:8000'
/// - Production          : 'https://ton-backend.onrender.com'
const String _kBackendUrl = 'https://airqual-cm-api.onrender.com';

class OpenMeteoService {
  static const String _openMeteoUrl = 'https://api.open-meteo.com/v1/forecast';

  Future<AirQualityData?> fetchForLocation({
    required double lat,
    required double lon,
    required String city,
    required String region,
    int forecastDays = 14,
  }) async {
    try {
      final days = forecastDays.clamp(7, 16);
      final meteoUri = Uri.parse(_openMeteoUrl).replace(queryParameters: {
        'latitude': lat.toString(),
        'longitude': lon.toString(),
        'current': [
          'temperature_2m','relative_humidity_2m','precipitation',
          'wind_speed_10m','wind_gusts_10m','shortwave_radiation',
        ].join(','),
        'daily': [
          'temperature_2m_max','temperature_2m_min','precipitation_sum',
          'wind_speed_10m_max','wind_gusts_10m_max','shortwave_radiation_sum',
          'et0_fao_evapotranspiration','sunshine_duration','daylight_duration',
        ].join(','),
        'timezone': 'Africa/Douala',
        'forecast_days': days.toString(),
      });

      final meteoResp = await http.get(meteoUri).timeout(const Duration(seconds: 15));
      if (meteoResp.statusCode != 200) return _demoData(city, region, lat, lon);

      final meteoData = json.decode(meteoResp.body) as Map<String, dynamic>;
      final current   = meteoData['current'] as Map<String, dynamic>? ?? {};
      final daily     = meteoData['daily']   as Map<String, dynamic>? ?? {};

      final temp      = _d(current['temperature_2m'],       25.0);
      final wind      = _d(current['wind_speed_10m'],        8.0);
      final windGust  = _d(current['wind_gusts_10m'],       12.0);
      final rain      = _d(current['precipitation'],         0.0);
      final humidity  = _d(current['relative_humidity_2m'], 60.0);
      final radiation = _d(current['shortwave_radiation'],  15.0);

      final dailyTMax = _dailyList(daily['temperature_2m_max']);
      final dailyTMin = _dailyList(daily['temperature_2m_min']);
      final dailyPrec = _dailyList(daily['precipitation_sum']);
      final dailyWind = _dailyList(daily['wind_speed_10m_max']);
      final dailyRad  = _dailyList(daily['shortwave_radiation_sum']);
      final dailyEt0  = _dailyList(daily['et0_fao_evapotranspiration']);
      final dailySun  = _dailyList(daily['sunshine_duration']);
      final dailyDay  = _dailyList(daily['daylight_duration']);

      final tempMax = dailyTMax.isNotEmpty ? dailyTMax[0] : temp + 5;
      final tempMin = dailyTMin.isNotEmpty ? dailyTMin[0] : temp - 5;
      final et0     = dailyEt0.isNotEmpty  ? dailyEt0[0]  : 4.0;
      final sunDur  = dailySun.isNotEmpty  ? dailySun[0]  : 36000.0;
      final dayDur  = dailyDay.isNotEmpty  ? dailyDay[0]  : 43200.0;

      // -- Pr\u00e9diction PM2.5 via backend RF ---------------------------------
      double pm25;
      List<String> factors;
      try {
        final rfResult = await _callBackendPredict(
          lat: lat, lon: lon, city: city, region: region,
          tempMean: temp, tempMax: tempMax, tempMin: tempMin,
          precip: rain, wind: wind, windGust: windGust,
          radiation: radiation, et0: et0,
          sunshineDuration: sunDur, daylightDuration: dayDur,
        );
        pm25    = rfResult['pm25'] as double;
        factors = List<String>.from(rfResult['aggravating_factors'] as List);
      } catch (_) {
        // Fallback : formule proxy exacte du notebook AlphaInfera
        pm25    = _notebookProxy(temp, radiation, et0, wind, rain, DateTime.now().month);
        factors = _computeFactors(temp, wind, rain, radiation);
      }

      // -- Pr\u00e9visions journali\u00e8res ------------------------------------------
      final times = daily['time'] as List? ?? [];
      final n     = [times.length, days].reduce((a, b) => a < b ? a : b);
      final forecasts = await _buildForecast(
        city: city, region: region, lat: lat, lon: lon,
        n: n, times: times,
        tempsMax: dailyTMax, tempsMin: dailyTMin,
        precips: dailyPrec, winds: dailyWind,
        rads: dailyRad, et0List: dailyEt0,
      );

      return AirQualityData(
        city: city, region: region, latitude: lat, longitude: lon,
        pm25: pm25, temperature: temp, windSpeed: wind,
        precipitation: rain, humidity: humidity, radiation: radiation,
        timestamp: DateTime.now(), level: _level(pm25),
        aggravatingFactors: factors, forecast: forecasts,
      );
    } catch (_) {
      return _demoData(city, region, lat, lon);
    }
  }

  // -- Backend RF /predict ---------------------------------------------------
  Future<Map<String, dynamic>> _callBackendPredict({
    required double lat, required double lon,
    required String city, required String region,
    required double tempMean, required double tempMax, required double tempMin,
    required double precip, required double wind, required double windGust,
    required double radiation, required double et0,
    required double sunshineDuration, required double daylightDuration,
  }) async {
    final resp = await http.post(
      Uri.parse('$_kBackendUrl/predict'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'temperature_2m_mean':        tempMean,
        'temperature_2m_max':         tempMax,
        'temperature_2m_min':         tempMin,
        'precipitation_sum':          precip,
        'wind_speed_10m_max':         wind,
        'wind_gusts_10m_max':         windGust,
        'shortwave_radiation_sum':    radiation,
        'et0_fao_evapotranspiration': et0,
        'sunshine_duration':          sunshineDuration,
        'daylight_duration':          daylightDuration,
        'latitude':  lat,
        'longitude': lon,
        'city':      city,
        'region':    region,
      }),
    ).timeout(const Duration(seconds: 8));

    if (resp.statusCode == 200) return json.decode(resp.body) as Map<String, dynamic>;
    throw Exception('Backend ${resp.statusCode}');
  }

  // -- Backend RF /forecast --------------------------------------------------
  Future<List<DailyForecast>> _buildForecast({
    required String city, required String region,
    required double lat, required double lon,
    required int n, required List times,
    required List<double> tempsMax, required List<double> tempsMin,
    required List<double> precips,  required List<double> winds,
    required List<double> rads,     required List<double> et0List,
  }) async {
    if (n == 0) return _demoForecast(20.0);

    // Essai backend RF
    try {
      final resp = await http.post(
        Uri.parse('$_kBackendUrl/forecast'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'city': city, 'region': region,
          'latitude': lat, 'longitude': lon,
          'days': n,
          'daily_temps_max': tempsMax.take(n).toList(),
          'daily_temps_min': tempsMin.take(n).toList(),
          'daily_precip':    precips.take(n).toList(),
          'daily_wind':      winds.take(n).toList(),
          'daily_radiation': rads.take(n).toList(),
          'daily_et0':       et0List.take(n).toList(),
        }),
      ).timeout(const Duration(seconds: 10));

      if (resp.statusCode == 200) {
        final data = json.decode(resp.body) as Map<String, dynamic>;
        return (data['forecast'] as List).map((item) {
          final m    = item as Map<String, dynamic>;
          final pm25 = _d(m['pm25'], 15.0);
          return DailyForecast(
            date:          DateTime.parse(m['date'] as String),
            tempMax:       _d(m['temp_max'],  30.0),
            tempMin:       _d(m['temp_min'],  20.0),
            precipitation: _d(m['precip'],     0.0),
            windSpeed:     _d(m['wind'],        8.0),
            radiation:     _d(m['radiation'], 15.0),
            pm25: pm25, level: _level(pm25),
          );
        }).toList();
      }
    } catch (_) {}

    // Fallback formule proxy notebook
    return List.generate(n, (i) {
      final tMax = tempsMax.length > i ? tempsMax[i] : 30.0;
      final tMin = tempsMin.length > i ? tempsMin[i] : 20.0;
      final prec = precips.length  > i ? precips[i]  : 0.0;
      final wind = winds.length    > i ? winds[i]    : 8.0;
      final rad  = rads.length     > i ? rads[i]     : 15.0;
      final et0  = et0List.length  > i ? et0List[i]  : 4.0;
      final date = DateTime.now().add(Duration(days: i + 1));
      final pm25 = _notebookProxy((tMax + tMin) / 2, rad, et0, wind, prec, date.month);
      return DailyForecast(
        date: date, tempMax: tMax, tempMin: tMin,
        precipitation: prec, windSpeed: wind, radiation: rad,
        pm25: pm25, level: _level(pm25),
      );
    });
  }

  /// Formule proxy EXACTE du notebook AlphaInfera :
  /// pm25_proxy = 0.35*temp_mean + 0.25*radiation + 0.20*et0
  ///            + 8.0*is_no_wind + 5.0*is_no_rain + 4.0*is_dry_season
  double _notebookProxy(double temp, double rad, double et0,
      double wind, double rain, int month) {
    final isNoWind    = wind < 5   ? 1.0 : 0.0;
    final isNoRain    = rain < 0.1 ? 1.0 : 0.0;
    final isDrySeason = [11, 12, 1, 2, 3].contains(month) ? 1.0 : 0.0;
    return (0.35 * temp + 0.25 * rad + 0.20 * et0
          + 8.0 * isNoWind + 5.0 * isNoRain + 4.0 * isDrySeason)
        .clamp(0.0, 80.0);
  }

  List<String> _computeFactors(double temp, double wind, double rain, double rad) {
    final f = <String>[];
    if (wind < 5)  f.add('low_wind');
    if (rain < 0.1) f.add('no_rain');
    if (temp > 35) f.add('high_temp');
    if (rad > 20)  f.add('high_radiation');
    if ([11, 12, 1, 2, 3].contains(DateTime.now().month)) f.add('harmattan');
    return f;
  }

  // -- Helpers ---------------------------------------------------------------
  double _d(dynamic v, double fallback) => (v as num?)?.toDouble() ?? fallback;

  List<double> _dailyList(dynamic raw) {
    if (raw is! List) return [];
    return raw.map((e) => (e as num?)?.toDouble() ?? 0.0).toList();
  }

  AQILevel _level(double pm25) {
    if (pm25 <= 12) return AQILevel.good;
    if (pm25 <= 15) return AQILevel.moderate;
    if (pm25 <= 25) return AQILevel.elevated;
    if (pm25 <= 35) return AQILevel.high;
    if (pm25 <= 55) return AQILevel.veryHigh;
    return AQILevel.hazardous;
  }

  AirQualityData _demoData(String city, String region, double lat, double lon) {
    final pm25 = _regionDefaultPm25(region);
    return AirQualityData(
      city: city, region: region, latitude: lat, longitude: lon,
      pm25: pm25, temperature: 28.5, windSpeed: 8.0,
      precipitation: 0.0, humidity: 55.0, radiation: 18.0,
      timestamp: DateTime.now(), level: _level(pm25),
      aggravatingFactors: ['high_temp', 'low_wind'],
      forecast: _demoForecast(pm25),
    );
  }

  List<DailyForecast> _demoForecast(double base) => List.generate(14, (i) {
    final pm25 = (base + (i % 3 - 1) * 2.5).clamp(2.0, 75.0);
    return DailyForecast(
      date: DateTime.now().add(Duration(days: i + 1)),
      tempMax: 30 + (i % 4 - 1).toDouble(), tempMin: 20 + (i % 3).toDouble(),
      precipitation: i % 4 == 0 ? 5.0 : 0.0,
      windSpeed: 8.0 + (i % 3).toDouble(), radiation: 18.0,
      pm25: pm25, level: _level(pm25),
    );
  });

  double _regionDefaultPm25(String region) => const {
    'Extr\u00eame-Nord': 28.5, 'Nord': 24.8, 'Adamaoua': 18.2,
    'Centre': 16.4, 'Littoral': 15.8, 'Ouest': 14.2,
    'Nord-Ouest': 13.5, 'Est': 12.8, 'Sud': 12.0, 'Sud-Ouest': 13.2,
  }[region] ?? 18.0;
}
