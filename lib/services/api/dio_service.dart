// lib/services/api/dio_service.dart
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../app/constants/api_constants.dart';

class DioService {
  static final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: ApiConstants.connectTimeout,
      receiveTimeout: ApiConstants.receiveTimeout,
      headers: {'Content-Type': 'application/json'},
    ),
  );

  static Dio get instance {
    // Add interceptor for logging (hanya di debug mode)
    if (kDebugMode) {
      _dio.interceptors.clear(); // Clear dulu biar tidak duplicate
      _dio.interceptors.add(LogInterceptor(
        request: true,
        requestHeader: true,
        requestBody: true,
        responseHeader: false,
        responseBody: true,
        error: true,
        logPrint: (obj) => debugPrint('🔵 DIO: $obj'),
      ));
    }
    return _dio;
  }

  // GET request dengan error handling otomatis
  static Future<Response> get(String url) async {
    try {
      final stopwatch = Stopwatch()..start();
      final response = await _dio.get(url);
      stopwatch.stop();
      
      if (kDebugMode) {
        debugPrint('⏱️ DIO Duration: ${stopwatch.elapsedMilliseconds}ms');
      }
      
      return response;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // POST request dengan error handling otomatis
  static Future<Response> post(String url, {Map<String, dynamic>? data}) async {
    try {
      final stopwatch = Stopwatch()..start();
      final response = await _dio.post(url, data: data);
      stopwatch.stop();
      
      if (kDebugMode) {
        debugPrint('⏱️ DIO Duration: ${stopwatch.elapsedMilliseconds}ms');
      }
      
      return response;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // Error handler built-in
  static String _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return 'Connection timeout - Please check your internet';
      case DioExceptionType.sendTimeout:
        return 'Send timeout';
      case DioExceptionType.receiveTimeout:
        return 'Receive timeout - Server not responding';
      case DioExceptionType.badResponse:
        return 'Bad response: ${e.response?.statusCode} - ${e.response?.statusMessage}';
      case DioExceptionType.cancel:
        return 'Request cancelled';
      case DioExceptionType.connectionError:
        return 'No internet connection';
      default:
        return 'Network error: ${e.message}';
    }
  }
}
