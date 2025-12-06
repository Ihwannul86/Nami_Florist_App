// lib/services/api/api_benchmark_service.dart
import 'package:flutter/foundation.dart';
import 'dio_service.dart';
import 'http_service.dart';

class ApiBenchmarkService {
  /// Membandingkan performa HTTP vs Dio
  /// Untuk memenuhi TUGAS 2: Eksperimen Performa HTTP Library
  static Future<Map<String, dynamic>> compareLibraries(String url) async {
    final results = <String, dynamic>{};

    if (kDebugMode) {
      debugPrint('\n🔥 ===== STARTING API BENCHMARK =====');
      debugPrint('📍 URL: $url\n');
    }

    // ========== TEST 1: HTTP PACKAGE ========== //
    final httpStopwatch = Stopwatch()..start();
    final httpResult = await HttpService.get(url);
    httpStopwatch.stop();
    
    results['http'] = {
      'library': 'http',
      'duration_ms': httpStopwatch.elapsedMilliseconds,
      'success': httpResult['success'],
      'status_code': httpResult['statusCode'] ?? 'N/A',
      'error_handling': 'Manual try-catch',
      'logging': 'Manual debugPrint',
      'ease_of_use': 'Medium',
      'features': 'Basic HTTP only',
    };

    await Future.delayed(const Duration(milliseconds: 500)); // Delay antar test

    // ========== TEST 2: DIO PACKAGE ========== //
    final dioStopwatch = Stopwatch()..start();
    try {
      final dioResult = await DioService.get(url);
      dioStopwatch.stop();
      
      results['dio'] = {
        'library': 'dio',
        'duration_ms': dioStopwatch.elapsedMilliseconds,
        'success': dioResult.statusCode == 200,
        'status_code': dioResult.statusCode,
        'error_handling': 'Built-in DioException + Interceptor',
        'logging': 'LogInterceptor (automatic)',
        'ease_of_use': 'High',
        'features': 'Interceptors, Cancel Token, FormData, etc',
      };
    } catch (e) {
      dioStopwatch.stop();
      results['dio'] = {
        'library': 'dio',
        'duration_ms': dioStopwatch.elapsedMilliseconds,
        'success': false,
        'error': e.toString(),
        'error_handling': 'Built-in DioException',
        'logging': 'LogInterceptor (automatic)',
      };
    }

    // ========== PRINT COMPARISON TABLE ========== //
    if (kDebugMode) {
      _printComparisonTable(results);
    }

    return results;
  }

  static void _printComparisonTable(Map<String, dynamic> results) {
    debugPrint('\n📊 ===== BENCHMARK RESULTS TABLE =====\n');
    
    debugPrint('┌─────────────────────┬─────────────────┬─────────────────┐');
    debugPrint('│ Metric              │ HTTP Package    │ Dio Package     │');
    debugPrint('├─────────────────────┼─────────────────┼─────────────────┤');
    
    // Duration
    debugPrint('│ Duration (ms)       │ ${_padRight(results['http']['duration_ms'].toString(), 15)} │ ${_padRight(results['dio']['duration_ms'].toString(), 15)} │');
    
    // Success
    debugPrint('│ Success             │ ${_padRight(results['http']['success'].toString(), 15)} │ ${_padRight(results['dio']['success'].toString(), 15)} │');
    
    // Status Code
    debugPrint('│ Status Code         │ ${_padRight(results['http']['status_code'].toString(), 15)} │ ${_padRight(results['dio']['status_code'].toString(), 15)} │');
    
    // Error Handling
    debugPrint('│ Error Handling      │ ${_padRight('Manual', 15)} │ ${_padRight('Built-in', 15)} │');
    
    // Logging
    debugPrint('│ Logging             │ ${_padRight('Manual', 15)} │ ${_padRight('Auto', 15)} │');
    
    // Ease of Use
    debugPrint('│ Ease of Use         │ ${_padRight('Medium', 15)} │ ${_padRight('High', 15)} │');
    
    debugPrint('└─────────────────────┴─────────────────┴─────────────────┘\n');
    
    // Winner
    final httpDuration = results['http']['duration_ms'];
    final dioDuration = results['dio']['duration_ms'];
    
    if (httpDuration < dioDuration) {
      debugPrint('🏆 Winner: HTTP Package (${httpDuration}ms vs ${dioDuration}ms)');
    } else {
      debugPrint('🏆 Winner: Dio Package (${dioDuration}ms vs ${httpDuration}ms)');
    }
    
    debugPrint('\n💡 Conclusion:');
    debugPrint('   - Dio has better error handling & logging');
    debugPrint('   - HTTP is simpler for basic requests');
    debugPrint('   - Dio recommended for production apps');
    debugPrint('\n=====================================\n');
  }

  static String _padRight(String text, int width) {
    if (text.length >= width) return text.substring(0, width);
    return text + ' ' * (width - text.length);
  }
}
