// lib/controllers/landing_controller.dart
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/foundation.dart';
import '../services/location/location_service.dart';
import 'weather_controller.dart';

class LandingController extends GetxController {
  final weatherController = Get.find<WeatherController>();

  var position = Rx<Position?>(null);
  var isLoading = false.obs;
  var locationError = ''.obs;

  @override
  void onInit() {
    super.onInit();
    // Delay sedikit untuk memastikan semua controller ready
    Future.delayed(const Duration(milliseconds: 500), () {
      getCurrentLocation();
    });
  }

  /// Get current GPS position
  Future<void> getCurrentLocation() async {
    try {
      isLoading.value = true;
      locationError.value = '';

      if (kDebugMode) {
        debugPrint('📍 Getting current location...');
      }

      final pos = await LocationService.getCurrentPosition();
      position.value = pos;

      // Update weather based on location
      await weatherController.getWeatherByCoordinates(
        lat: pos.latitude,
        lon: pos.longitude,
      );

      if (kDebugMode) {
        debugPrint('✅ Location obtained: ${pos.latitude}, ${pos.longitude}');
      }
    } catch (e) {
      locationError.value = e.toString();

      if (kDebugMode) {
        debugPrint('❌ Location error: $e');
      }

      // ✅ Fallback: Gunakan location default (Malang) jika GPS gagal
      if (kDebugMode) {
        debugPrint('⚠️ Using fallback location (Malang)');
      }
      
      // Set default position (Malang, Indonesia)
      position.value = Position(
        latitude: -7.9666,
        longitude: 112.6326,
        timestamp: DateTime.now(),
        accuracy: 0,
        altitude: 0,
        altitudeAccuracy: 0,
        heading: 0,
        headingAccuracy: 0,
        speed: 0,
        speedAccuracy: 0,
      );

      // Get weather untuk Malang
      await weatherController.getWeather();
    } finally {
      isLoading.value = false;
    }
  }

  /// Open device location settings
  Future<void> openSettings() async {
    await LocationService.openLocationSettings();
  }
}
