// ignore_for_file: constant_identifier_names
// ============================================================
// models/air_quality.dart - Data models for AirQual CM
// ============================================================

class AirQualityData {
  final String city;
  final String region;
  final double latitude;
  final double longitude;
  final double pm25;
  final double temperature;
  final double windSpeed;
  final double precipitation;
  final double humidity;
  final double radiation;
  final DateTime timestamp;
  final AQILevel level;
  final List<String> aggravatingFactors;
  final List<DailyForecast> forecast;

  AirQualityData({
    required this.city,
    required this.region,
    required this.latitude,
    required this.longitude,
    required this.pm25,
    required this.temperature,
    required this.windSpeed,
    required this.precipitation,
    required this.humidity,
    required this.radiation,
    required this.timestamp,
    required this.level,
    required this.aggravatingFactors,
    required this.forecast,
  });

  static AQILevel levelFromPm25(double pm25) {
    if (pm25 <= 12) return AQILevel.good;
    if (pm25 <= 15) return AQILevel.moderate;
    if (pm25 <= 25) return AQILevel.elevated;
    if (pm25 <= 35) return AQILevel.high;
    if (pm25 <= 55) return AQILevel.veryHigh;
    return AQILevel.hazardous;
  }
}

class DailyForecast {
  final DateTime date;
  final double tempMax;
  final double tempMin;
  final double precipitation;
  final double windSpeed;
  final double radiation;
  final double pm25;
  final AQILevel level;

  DailyForecast({
    required this.date,
    required this.tempMax,
    required this.tempMin,
    required this.precipitation,
    required this.windSpeed,
    required this.radiation,
    required this.pm25,
    required this.level,
  });
}

enum AQILevel {
  good,
  moderate,
  elevated,
  high,
  veryHigh,
  hazardous,
}

class CityProfile {
  final String name;
  final String region;
  final double latitude;
  final double longitude;
  final double avgPm25;
  final double avgTemp;
  final double avgWind;

  CityProfile({
    required this.name,
    required this.region,
    required this.latitude,
    required this.longitude,
    required this.avgPm25,
    required this.avgTemp,
    required this.avgWind,
  });
}

// -- Cameroon cities -----------------------------------------------------------
class CameroonCities {
  static const List<Map<String, dynamic>> cities = [
    {'name': 'Maroua',       'display': 'Maroua',        'region': 'Extreme-Nord', 'regionDisplay': 'Extrême-Nord',  'lat': 10.5903, 'lon': 14.3147},
    {'name': 'Garoua',       'display': 'Garoua',        'region': 'Nord',         'regionDisplay': 'Nord',           'lat': 9.3017,  'lon': 13.3921},
    {'name': 'Ngaoundere',   'display': 'Ngaoundéré',    'region': 'Adamaoua',     'regionDisplay': 'Adamaoua',       'lat': 7.3167,  'lon': 13.5833},
    {'name': 'Yaounde',      'display': 'Yaoundé',       'region': 'Centre',       'regionDisplay': 'Centre',         'lat': 3.8667,  'lon': 11.5167},
    {'name': 'Douala',       'display': 'Douala',        'region': 'Littoral',     'regionDisplay': 'Littoral',       'lat': 4.0511,  'lon': 9.7679},
    {'name': 'Bafoussam',    'display': 'Bafoussam',     'region': 'Ouest',        'regionDisplay': 'Ouest',          'lat': 5.4737,  'lon': 10.4175},
    {'name': 'Bamenda',      'display': 'Bamenda',       'region': 'Nord-Ouest',   'regionDisplay': 'Nord-Ouest',     'lat': 5.9601,  'lon': 10.1456},
    {'name': 'Bertoua',      'display': 'Bertoua',       'region': 'Est',          'regionDisplay': 'Est',            'lat': 4.5833,  'lon': 13.6833},
    {'name': 'Ebolowa',      'display': 'Ebolowa',       'region': 'Sud',          'regionDisplay': 'Sud',            'lat': 2.9000,  'lon': 11.1500},
    {'name': 'Buea',         'display': 'Buea',          'region': 'Sud-Ouest',    'regionDisplay': 'Sud-Ouest',      'lat': 4.1527,  'lon': 9.2408},
    {'name': 'Kumba',        'display': 'Kumba',         'region': 'Sud-Ouest',    'regionDisplay': 'Sud-Ouest',      'lat': 4.6364,  'lon': 9.4467},
    {'name': 'Limbe',        'display': 'Limbe',         'region': 'Sud-Ouest',    'regionDisplay': 'Sud-Ouest',      'lat': 4.0161,  'lon': 9.2172},
    {'name': 'Nkongsamba',   'display': 'Nkongsamba',    'region': 'Littoral',     'regionDisplay': 'Littoral',       'lat': 4.9500,  'lon': 9.9500},
    {'name': 'Edea',         'display': 'Edéa',          'region': 'Littoral',     'regionDisplay': 'Littoral',       'lat': 3.7833,  'lon': 10.1333},
    {'name': 'Kribi',        'display': 'Kribi',         'region': 'Sud',          'regionDisplay': 'Sud',            'lat': 2.9400,  'lon': 9.9100},
    {'name': 'Dschang',      'display': 'Dschang',       'region': 'Ouest',        'regionDisplay': 'Ouest',          'lat': 5.4500,  'lon': 10.0500},
    {'name': 'Foumban',      'display': 'Foumban',       'region': 'Ouest',        'regionDisplay': 'Ouest',          'lat': 5.7167,  'lon': 10.9000},
    {'name': 'Tibati',       'display': 'Tibati',        'region': 'Adamaoua',     'regionDisplay': 'Adamaoua',       'lat': 6.4667,  'lon': 12.6333},
    {'name': 'Meiganga',     'display': 'Meiganga',      'region': 'Adamaoua',     'regionDisplay': 'Adamaoua',       'lat': 6.5167,  'lon': 14.3000},
    {'name': 'Mora',         'display': 'Mora',          'region': 'Extreme-Nord', 'regionDisplay': 'Extrême-Nord',   'lat': 11.0439, 'lon': 14.1439},
    {'name': 'Kousseri',     'display': 'Kousséri',      'region': 'Extreme-Nord', 'regionDisplay': 'Extrême-Nord',   'lat': 12.0764, 'lon': 15.0306},
    {'name': 'Guider',       'display': 'Guider',        'region': 'Nord',         'regionDisplay': 'Nord',           'lat': 9.9333,  'lon': 13.9500},
    {'name': 'Lagdo',        'display': 'Lagdo',         'region': 'Nord',         'regionDisplay': 'Nord',           'lat': 9.0500,  'lon': 13.7167},
    {'name': 'Poli',         'display': 'Poli',          'region': 'Nord',         'regionDisplay': 'Nord',           'lat': 8.4833,  'lon': 13.2333},
    {'name': 'Batouri',      'display': 'Batouri',       'region': 'Est',          'regionDisplay': 'Est',            'lat': 4.4333,  'lon': 14.3667},
    {'name': 'Abong-Mbang',  'display': 'Abong-Mbang',   'region': 'Est',          'regionDisplay': 'Est',            'lat': 3.9833,  'lon': 13.1667},
    {'name': 'Mbalmayo',     'display': 'Mbalmayo',      'region': 'Centre',       'regionDisplay': 'Centre',         'lat': 3.5167,  'lon': 11.5000},
    {'name': 'Obala',        'display': 'Obala',         'region': 'Centre',       'regionDisplay': 'Centre',         'lat': 4.1667,  'lon': 11.5333},
    {'name': 'Bafia',        'display': 'Bafia',         'region': 'Centre',       'regionDisplay': 'Centre',         'lat': 4.7500,  'lon': 11.2333},
    {'name': 'Sangmelima',   'display': 'Sangmélima',    'region': 'Sud',          'regionDisplay': 'Sud',            'lat': 2.9333,  'lon': 11.9833},
    {'name': 'Ambam',        'display': 'Ambam',         'region': 'Sud',          'regionDisplay': 'Sud',            'lat': 2.3833,  'lon': 11.2833},
    {'name': 'Wum',          'display': 'Wum',           'region': 'Nord-Ouest',   'regionDisplay': 'Nord-Ouest',     'lat': 6.3667,  'lon': 10.0667},
    {'name': 'Nkambe',       'display': 'Nkambe',        'region': 'Nord-Ouest',   'regionDisplay': 'Nord-Ouest',     'lat': 6.6500,  'lon': 10.6667},
    {'name': 'Kumbo',        'display': 'Kumbo',         'region': 'Nord-Ouest',   'regionDisplay': 'Nord-Ouest',     'lat': 6.1833,  'lon': 10.6833},
    {'name': 'Muyuka',       'display': 'Muyuka',        'region': 'Sud-Ouest',    'regionDisplay': 'Sud-Ouest',      'lat': 4.2833,  'lon': 9.3833},
    {'name': 'Mamfe',        'display': 'Mamfe',         'region': 'Sud-Ouest',    'regionDisplay': 'Sud-Ouest',      'lat': 5.7667,  'lon': 9.2833},
    {'name': 'Wouri',        'display': 'Wouri',         'region': 'Littoral',     'regionDisplay': 'Littoral',       'lat': 4.0167,  'lon': 9.7000},
    {'name': 'Loum',         'display': 'Loum',          'region': 'Littoral',     'regionDisplay': 'Littoral',       'lat': 4.7167,  'lon': 9.7333},
    {'name': 'Mbanga',       'display': 'Mbanga',        'region': 'Littoral',     'regionDisplay': 'Littoral',       'lat': 4.5000,  'lon': 9.5667},
    {'name': 'Tiko',         'display': 'Tiko',          'region': 'Sud-Ouest',    'regionDisplay': 'Sud-Ouest',      'lat': 4.0728,  'lon': 9.3672},
  ];

  static List<CityProfile> get allCities => cities.map((c) => CityProfile(
    name:     c['display'] as String,
    region:   c['regionDisplay'] as String,
    latitude:  c['lat'] as double,
    longitude: c['lon'] as double,
    avgPm25:   _estimatePm25(c['region'] as String),
    avgTemp:   _estimateTemp(c['region'] as String),
    avgWind:   10.0,
  )).toList();

  /// Moyenne nationale PM2.5 calculée à partir de toutes les villes
  static double get nationalAveragePm25 {
    final values = cities.map((c) => _estimatePm25(c['region'] as String)).toList();
    return values.reduce((a, b) => a + b) / values.length;
  }

  static CityProfile? findByName(String name) {
    for (final c in cities) {
      if (c['name'] == name || c['display'] == name) {
        return CityProfile(
          name:     c['display'] as String,
          region:   c['regionDisplay'] as String,
          latitude:  c['lat'] as double,
          longitude: c['lon'] as double,
          avgPm25:   _estimatePm25(c['region'] as String),
          avgTemp:   _estimateTemp(c['region'] as String),
          avgWind:   10.0,
        );
      }
    }
    return null;
  }

  static double _estimatePm25(String region) {
    const Map<String, double> pm25ByRegion = {
      'Extreme-Nord': 28.5,
      'Nord':         24.8,
      'Adamaoua':     18.2,
      'Centre':       16.4,
      'Littoral':     15.8,
      'Ouest':        14.2,
      'Nord-Ouest':   13.5,
      'Est':          12.8,
      'Sud':          12.0,
      'Sud-Ouest':    13.2,
    };
    return pm25ByRegion[region] ?? 18.0;
  }

  static double _estimateTemp(String region) {
    const Map<String, double> tempByRegion = {
      'Extreme-Nord': 31.5,
      'Nord':         30.9,
      'Adamaoua':     22.4,
      'Centre':       24.8,
      'Littoral':     26.5,
      'Ouest':        20.2,
      'Nord-Ouest':   19.8,
      'Est':          24.2,
      'Sud':          23.8,
      'Sud-Ouest':    25.1,
    };
    return tempByRegion[region] ?? 25.0;
  }
}
