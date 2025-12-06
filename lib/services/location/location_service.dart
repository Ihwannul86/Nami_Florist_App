// lib/services/location/location_service.dart
import 'package:geolocator/geolocator.dart';
import 'package:flutter/foundation.dart';

/// Service untuk mengelola Location (GPS, Network Location, Live Location)
/// Untuk TUGAS 4: Implementasi Location Services
class LocationService {
  /// Check apakah location service aktif
  static Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Check dan request location permission
  static Future<LocationPermission> checkPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
        if (kDebugMode) {
          debugPrint('❌ Location permission denied');
        }
        throw Exception('Location permission denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (kDebugMode) {
        debugPrint('❌ Location permission denied forever');
      }
      throw Exception('Location permission denied forever');
    }

    if (kDebugMode) {
      debugPrint('✅ Location permission granted');
    }

    return permission;
  }

  /// Get current position default (biasanya GPS + Network, high accuracy)
  static Future<Position> getCurrentPosition() async {
    // Check service
    bool serviceEnabled = await isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location service is disabled');
    }

    // Check permission
    await checkPermission();

    if (kDebugMode) {
      debugPrint('📍 Getting current position (default high accuracy)...');
    }

    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    if (kDebugMode) {
      debugPrint('✅ Position obtained:');
      debugPrint('   Lat: ${position.latitude}');
      debugPrint('   Lon: ${position.longitude}');
      debugPrint('   Accuracy: ${position.accuracy}m');
      debugPrint('   Altitude: ${position.altitude}m');
      debugPrint('   Speed: ${position.speed}m/s');
    }

    return position;
  }

  /// Get posisi dengan preferensi Network / low accuracy
  static Future<Position> getNetworkPosition() async {
    bool serviceEnabled = await isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location service is disabled');
    }

    await checkPermission();

    if (kDebugMode) {
      debugPrint('📡 Getting NETWORK position (low accuracy)...');
    }

    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.low, // cenderung pakai Network/WiFi
    );

    if (kDebugMode) {
      debugPrint('✅ Network position: '
          'lat=${position.latitude}, lon=${position.longitude}, acc=${position.accuracy}m');
    }

    return position;
  }

  /// Get posisi dengan preferensi GPS / high accuracy
  static Future<Position> getGpsPosition() async {
    bool serviceEnabled = await isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location service is disabled');
    }

    await checkPermission();

    if (kDebugMode) {
      debugPrint('📡 Getting GPS position (high accuracy)...');
    }

    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high, // paksa akurasi tinggi (GPS)
    );

    if (kDebugMode) {
      debugPrint('✅ GPS position: '
          'lat=${position.latitude}, lon=${position.longitude}, acc=${position.accuracy}m');
    }

    return position;
  }

  /// Get live location stream (untuk real-time tracking)
  static Stream<Position> getPositionStream() {
    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10, // Update setiap 10 meter
    );

    return Geolocator.getPositionStream(locationSettings: locationSettings);
  }

  /// Calculate distance between two points (dalam meter)
  static double calculateDistance({
    required double startLat,
    required double startLon,
    required double endLat,
    required double endLon,
  }) {
    return Geolocator.distanceBetween(
      startLat,
      startLon,
      endLat,
      endLon,
    );
  }

  /// Get location accuracy description
  static String getAccuracyDescription(double accuracy) {
    if (accuracy < 10) return 'Excellent';
    if (accuracy < 30) return 'Good';
    if (accuracy < 50) return 'Fair';
    return 'Poor';
  }

  /// Open location settings
  static Future<bool> openLocationSettings() async {
    return await Geolocator.openLocationSettings();
  }
}
