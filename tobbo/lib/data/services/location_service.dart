import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

class GeoPoint {
  const GeoPoint(this.latitude, this.longitude);

  final double latitude;
  final double longitude;
}

class LocationService {
  GeoPoint? _cached;
  DateTime? _cachedAt;

  Future<GeoPoint?> getCurrentPosition({bool requestIfNeeded = false}) async {
    if (_cached != null &&
        _cachedAt != null &&
        DateTime.now().difference(_cachedAt!) < const Duration(seconds: 30)) {
      return _cached;
    }

    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied && requestIfNeeded) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever ||
        permission == LocationPermission.unableToDetermine) {
      return null;
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: _settings(),
      );
      _cached = GeoPoint(position.latitude, position.longitude);
      _cachedAt = DateTime.now();
      return _cached;
    } catch (_) {
      final last = await Geolocator.getLastKnownPosition();
      if (last == null) return null;
      return GeoPoint(last.latitude, last.longitude);
    }
  }

  Future<GeoPoint?> getIfPermitted() async {
    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever ||
        permission == LocationPermission.unableToDetermine) {
      return null;
    }
    return getCurrentPosition(requestIfNeeded: false);
  }

  /// Coarse location is enough for 1–10 km nearby. Avoid Google Fused Location
  /// so Android does not keep prompting to turn on Location Accuracy.
  LocationSettings _settings() {
    const timeLimit = Duration(seconds: 15);
    if (defaultTargetPlatform == TargetPlatform.android) {
      return AndroidSettings(
        accuracy: LocationAccuracy.low,
        timeLimit: timeLimit,
        forceLocationManager: true,
      );
    }
    return const LocationSettings(
      accuracy: LocationAccuracy.low,
      timeLimit: timeLimit,
    );
  }
}
