import 'dart:math' as math;
import 'dart:ui' show Offset, Size; // needed for cityToCanvas()
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import '../constants/app_constants.dart';

/// Service for GPS location detection and distance calculations.
/// Falls back gracefully if permission is denied.
class LocationService {
  static final LocationService _instance = LocationService._();
  static LocationService get instance => _instance;
  LocationService._();

  Position? _lastPosition;
  Position? get lastPosition => _lastPosition;

  // ─── PERMISSION ──────────────────────────────────────────────────────────

  Future<bool> requestPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      debugPrint('>>> Location services disabled');
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return false;
    }
    if (permission == LocationPermission.deniedForever) return false;
    return true;
  }

  // ─── GET GPS POSITION ────────────────────────────────────────────────────

  Future<Position?> getCurrentPosition() async {
    try {
      final hasPermission = await requestPermission();
      if (!hasPermission) return null;

      // Use desiredAccuracy (compatible with all geolocator versions)
      _lastPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
      );
      return _lastPosition;
    } catch (e) {
      debugPrint('>>> GPS error: $e');
      return null;
    }
  }

  // ─── NEAREST CITY ────────────────────────────────────────────────────────

  String nearestCity(double lat, double lon) {
    String closest = AppConstants.chadCities.first;
    double minDist = double.infinity;

    for (final city in AppConstants.chadCities) {
      final coords = AppConstants.cityCoordinates[city];
      if (coords == null) continue;
      final d = haversineKm(lat, lon, coords[0], coords[1]);
      if (d < minDist) {
        minDist = d;
        closest = city;
      }
    }
    return closest;
  }

  Future<String?> detectNearestCity() async {
    final pos = await getCurrentPosition();
    if (pos == null) return null;
    return nearestCity(pos.latitude, pos.longitude);
  }

  // ─── HAVERSINE ───────────────────────────────────────────────────────────

  static double haversineKm(
      double lat1, double lon1, double lat2, double lon2) {
    const r = 6371.0;
    final dLat = _toRad(lat2 - lat1);
    final dLon = _toRad(lon2 - lon1);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRad(lat1)) *
            math.cos(_toRad(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return r * c;
  }

  static double _toRad(double d) => d * math.pi / 180;

  // ─── CITY → CANVAS COORDINATE ────────────────────────────────────────────

  /// Maps a Chad city name to a pixel [Offset] within a canvas of [canvasSize].
  /// Uses the geographic bounding box of Chad to normalise coordinates.
  static Offset cityToCanvas(String city, Size canvasSize) {
    // Chad approximate bounding box
    const minLat = 7.5,  maxLat = 23.5;
    const minLon = 13.5, maxLon = 24.0;

    final coords = AppConstants.cityCoordinates[city];
    if (coords == null) {
      return Offset(canvasSize.width / 2, canvasSize.height / 2);
    }

    final lat = coords[0];
    final lon = coords[1];

    // Longitude → x, latitude → y (flipped: higher lat = higher on screen)
    final x = ((lon - minLon) / (maxLon - minLon)) * canvasSize.width;
    final y = ((maxLat - lat) / (maxLat - minLat)) * canvasSize.height;

    return Offset(
      x.clamp(20.0, canvasSize.width  - 20.0),
      y.clamp(20.0, canvasSize.height - 20.0),
    );
  }
}