// lib/services/weather_service.dart
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../models/weather_model.dart';
import '../app/constants/api_constants.dart';

/// Service untuk mengambil data cuaca dari OpenWeatherMap API
class WeatherService {
  /// Fetch weather data untuk kota Malang
  Future<WeatherApi> fetchWeatherMalang() async {
    final url =
        "${ApiConstants.weatherBaseUrl}/forecast?q=Malang&appid=${ApiConstants.weatherApiKey}&units=metric";

    if (kDebugMode) {
      debugPrint('🌤️ Fetching weather for Malang...');
    }

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        if (kDebugMode) {
          debugPrint('✅ Weather data received');
        }
        return weatherApiFromJson(response.body);
      } else {
        if (kDebugMode) {
          debugPrint('❌ Weather API error: ${response.statusCode}');
        }
        throw Exception("Gagal memuat data cuaca: ${response.statusCode}");
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Weather service error: $e');
      }
      rethrow;
    }
  }

  /// Fetch weather berdasarkan koordinat (untuk location-based weather)
  Future<WeatherApi> fetchWeatherByCoordinates({
    required double lat,
    required double lon,
  }) async {
    final url =
        "${ApiConstants.weatherBaseUrl}/forecast?lat=$lat&lon=$lon&appid=${ApiConstants.weatherApiKey}&units=metric";

    if (kDebugMode) {
      debugPrint('🌤️ Fetching weather for coordinates: $lat, $lon');
    }

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        if (kDebugMode) {
          debugPrint('✅ Weather data received for coordinates');
        }
        return weatherApiFromJson(response.body);
      } else {
        throw Exception("Gagal memuat data cuaca: ${response.statusCode}");
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Weather service error: $e');
      }
      rethrow;
    }
  }
}
