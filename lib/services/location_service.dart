import 'package:geolocator/geolocator.dart';
import '../models/air_quality.dart';

class LocationService {
  /// Request location permission and get current position
  Future<Position?> getCurrentPosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return null;
    }
    if (permission == LocationPermission.deniedForever) return null;

    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 10),
      );
    } catch (_) {
      return null;
    }
  }

  /// Find nearest city from coordinates
  CityProfile findNearestCity(double lat, double lon) {
    final cities = CameroonCities.allCities;
    CityProfile? nearest;
    double minDist = double.infinity;

    for (final city in cities) {
      final dist = _distance(lat, lon, city.latitude, city.longitude);
      if (dist < minDist) {
        minDist = dist;
        nearest = city;
      }
    }

    return nearest ?? cities.first;
  }

  double _distance(double lat1, double lon1, double lat2, double lon2) {
    return ((lat1 - lat2) * (lat1 - lat2) + (lon1 - lon2) * (lon1 - lon2));
  }
}
