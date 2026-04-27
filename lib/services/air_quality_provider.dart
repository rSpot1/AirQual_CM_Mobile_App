import 'package:flutter/material.dart';
import '../models/air_quality.dart';
import '../models/app_settings.dart';
import '../services/open_meteo_service.dart';
import '../services/location_service.dart';
import '../utils/aq_utils.dart';

enum LoadingState { idle, loading, loaded, error }

class AirQualityProvider extends ChangeNotifier {
  final OpenMeteoService _api = OpenMeteoService();
  final LocationService _locationService = LocationService();
  AppSettings? _settings;

  void attachSettings(AppSettings settings) => _settings = settings;

  AirQualityData? _currentData;
  LoadingState _state = LoadingState.idle;
  String _errorMessage = '';
  CityProfile? _selectedCity;
  bool _usingLocation = false;

  // Cache PM2.5 prédits par ville (pour la carte)
  final Map<String, double> _cityPm25Cache = {};

  AirQualityData? get currentData => _currentData;
  LoadingState get state => _state;
  String get errorMessage => _errorMessage;
  CityProfile? get selectedCity => _selectedCity;
  bool get usingLocation => _usingLocation;
  bool get isLoading => _state == LoadingState.loading;
  Map<String, double> get cityPm25Cache => _cityPm25Cache;

  Future<void> initWithLocation() async {
    _state = LoadingState.loading;
    _usingLocation = true;
    notifyListeners();

    try {
      final position = await _locationService.getCurrentPosition();
      if (position != null) {
        final nearestCity = _locationService.findNearestCity(
            position.latitude, position.longitude);
        _selectedCity = nearestCity;
        await _fetchData(
          lat: position.latitude,
          lon: position.longitude,
          city: nearestCity.name,
          region: nearestCity.region,
        );
      } else {
        await _loadDefaultCity();
      }
    } catch (_) {
      await _loadDefaultCity();
    }
  }

  Future<void> _loadDefaultCity() async {
    final maroua = CameroonCities.allCities.firstWhere(
      (c) => c.name == 'Maroua',
      orElse: () => CameroonCities.allCities.first,
    );
    _selectedCity = maroua;
    _usingLocation = false;
    await _fetchData(
      lat: maroua.latitude,
      lon: maroua.longitude,
      city: maroua.name,
      region: maroua.region,
    );
  }

  Future<void> loadCity(CityProfile city, {int forecastDays = 14}) async {
    _selectedCity = city;
    _usingLocation = false;
    _state = LoadingState.loading;
    notifyListeners();
    await _fetchData(
      lat: city.latitude,
      lon: city.longitude,
      city: city.name,
      region: city.region,
      forecastDays: forecastDays,
    );
  }

  Future<void> refresh({int forecastDays = 14}) async {
    if (_selectedCity == null) {
      await initWithLocation();
      return;
    }
    _state = LoadingState.loading;
    notifyListeners();
    await _fetchData(
      lat: _selectedCity!.latitude,
      lon: _selectedCity!.longitude,
      city: _selectedCity!.name,
      region: _selectedCity!.region,
      forecastDays: forecastDays,
    );
  }

  /// Récupère le PM2.5 prédit pour une ville sans changer la ville courante
  Future<double> fetchPredictedPm25ForCity(CityProfile city) async {
    if (_cityPm25Cache.containsKey(city.name)) {
      return _cityPm25Cache[city.name]!;
    }
    try {
      final data = await _api.fetchForLocation(
        lat: city.latitude,
        lon: city.longitude,
        city: city.name,
        region: city.region,
        forecastDays: 7,
      );
      if (data != null) {
        final pm25 = data.forecast.isNotEmpty ? data.forecast[0].pm25 : data.pm25;
        _cityPm25Cache[city.name] = pm25;
        notifyListeners();
        return pm25;
      }
    } catch (_) {}
    final fallback = city.avgPm25;
    _cityPm25Cache[city.name] = fallback;
    return fallback;
  }

  Future<void> _fetchData({
    required double lat,
    required double lon,
    required String city,
    required String region,
    int forecastDays = 14,
  }) async {
    try {
      final data = await _api.fetchForLocation(
        lat: lat,
        lon: lon,
        city: city,
        region: region,
        forecastDays: forecastDays,
      );
      if (data != null) {
        // PM2.5 affiché = forecast[0] (valeur prédite aujourd'hui par le modèle)
        // = même valeur que dans l'onglet Prévisions
        final displayPm25 = data.forecast.isNotEmpty
            ? data.forecast[0].pm25
            : data.pm25;

        final corrected = AirQualityData(
          city: data.city,
          region: data.region,
          latitude: data.latitude,
          longitude: data.longitude,
          pm25: displayPm25,
          temperature: data.temperature,
          windSpeed: data.windSpeed,
          precipitation: data.precipitation,
          humidity: data.humidity,
          radiation: data.radiation,
          timestamp: data.timestamp,
          level: AirQualityData.levelFromPm25(displayPm25),
          aggravatingFactors: data.aggravatingFactors,
          forecast: data.forecast,
        );

        _currentData = corrected;
        _cityPm25Cache[city] = displayPm25;
        _state = LoadingState.loaded;

        if (_settings != null && data.forecast.length > 1) {
          final tomorrow = data.forecast[1];
          await _settings!.saveTomorrowForecast(
            city: data.city,
            pm25: tomorrow.pm25,
            level: AQUtils.levelLabel(tomorrow.level, _settings!.language),
          );
        }
      } else {
        _state = LoadingState.error;
        _errorMessage = 'Données indisponibles';
      }
    } catch (e) {
      _state = LoadingState.error;
      _errorMessage = e.toString();
    }
    notifyListeners();
  }
}
