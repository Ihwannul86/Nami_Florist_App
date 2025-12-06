// lib/controllers/plant_controller.dart
import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import '../services/plant_api_service.dart';
import 'weather_controller.dart';

class PlantController extends GetxController {
  final plantService = PlantApiService();
  final weatherController = Get.find<WeatherController>();

  var plants = <dynamic>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    
    // ✅ Wait for weather data ready, kemudian load plants
    ever(weatherController.temperature, (temp) {
      if (temp > 0) {
        loadPlantsBasedOnWeather();
      }
    });

    // ✅ Trigger manual load setelah delay (fallback)
    Future.delayed(const Duration(seconds: 3), () {
      if (plants.isEmpty && !isLoading.value) {
        if (kDebugMode) {
          debugPrint('⚠️ Triggering manual plant load');
        }
        loadPlantsBasedOnWeather();
      }
    });
  }

  /// Load plants berdasarkan suhu cuaca (Chained API call untuk TUGAS 2)
  Future<void> loadPlantsBasedOnWeather() async {
    try {
      isLoading.value = true;

      final temp = weatherController.temperature.value;

      if (kDebugMode) {
        debugPrint('🌿 Loading plants for temperature: $temp°C');
      }

      // ✅ Gunakan default temp jika belum ada
      final actualTemp = temp > 0 ? temp : 27.0;

      // === CHAINED API CALL (TUGAS 2) ===
      // 1. First call: Get weather (sudah ada di WeatherController)
      // 2. Second call: Get plant recommendations based on weather
      final plantData = await plantService.fetchPlantsByTemperature(actualTemp);

      plants.value = plantData;

      if (kDebugMode) {
        debugPrint('✅ Loaded ${plants.length} plant recommendations');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Plant loading error: $e');
      }
      
      // ✅ Set empty list untuk menghindari infinite loading
      plants.value = [];
    } finally {
      isLoading.value = false;
    }
  }

  /// Manual refresh
  Future<void> refresh() async {
    await loadPlantsBasedOnWeather();
  }
}
