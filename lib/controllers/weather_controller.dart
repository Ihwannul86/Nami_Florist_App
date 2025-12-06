// lib/controllers/weather_controller.dart
import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import '../services/weather_service.dart';
import '../services/api/api_benchmark_service.dart';
import '../app/constants/api_constants.dart';

class WeatherController extends GetxController {
  final weatherService = WeatherService();
  var temperature = 0.0.obs;
  var weatherDescription = ''.obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    getWeather();
    
    // Jalankan benchmark (untuk TUGAS 2) - Optional
    Future.delayed(const Duration(seconds: 2), () {
      if (kDebugMode) {
        runBenchmark();
      }
    });
  }

  /// Get weather data
  Future<void> getWeather() async {
    try {
      isLoading.value = true;

      if (kDebugMode) {
        debugPrint('🌤️ Fetching weather...');
      }

      final weatherData = await weatherService.fetchWeatherMalang();

      if (weatherData.list.isNotEmpty) {
        temperature.value = weatherData.list[0].main.temp;
        weatherDescription.value = weatherData.list[0].weather[0].description;

        if (kDebugMode) {
          debugPrint('✅ Weather: ${temperature.value}°C - ${weatherDescription.value}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Weather error: $e');
      }
      
      // ✅ Set default temperature jika gagal
      temperature.value = 27.0;
      weatherDescription.value = 'Clear sky';
      
      if (kDebugMode) {
        debugPrint('⚠️ Using default temperature: ${temperature.value}°C');
      }
    } finally {
      isLoading.value = false;
    }
  }

  /// Get weather by coordinates
  Future<void> getWeatherByCoordinates({
    required double lat,
    required double lon,
  }) async {
    try {
      isLoading.value = true;

      if (kDebugMode) {
        debugPrint('🌤️ Fetching weather for: $lat, $lon');
      }

      final weatherData = await weatherService.fetchWeatherByCoordinates(
        lat: lat,
        lon: lon,
      );

      if (weatherData.list.isNotEmpty) {
        temperature.value = weatherData.list[0].main.temp;
        weatherDescription.value = weatherData.list[0].weather[0].description;

        if (kDebugMode) {
          debugPrint('✅ Weather for coordinates: ${temperature.value}°C');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Weather error: $e');
      }
      
      // Fallback ke weather default Malang
      await getWeather();
    } finally {
      isLoading.value = false;
    }
  }

  /// Run API benchmark (untuk TUGAS 2: Eksperimen Performa HTTP Library)
  Future<void> runBenchmark() async {
    if (kDebugMode) {
      debugPrint('\n🔥 Running API Benchmark...\n');
      
      final url = "${ApiConstants.weatherBaseUrl}/forecast?q=Malang&appid=${ApiConstants.weatherApiKey}&units=metric";
      
      await ApiBenchmarkService.compareLibraries(url);
    }
  }
}
