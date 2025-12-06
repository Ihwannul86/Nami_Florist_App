// lib/services/api/http_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class HttpService {
  // GET request dengan error handling manual dan logging
  static Future<Map<String, dynamic>> get(String url) async {
    try {
      final startTime = DateTime.now();
      
      if (kDebugMode) {
        debugPrint('🟢 HTTP GET Request: $url');
      }
      
      final response = await http.get(Uri.parse(url));
      
      final endTime = DateTime.now();
      final duration = endTime.difference(startTime).inMilliseconds;
      
      if (kDebugMode) {
        debugPrint('⏱️ HTTP Duration: ${duration}ms');
        debugPrint('📊 HTTP Status: ${response.statusCode}');
      }

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': jsonDecode(response.body),
          'duration': duration,
          'statusCode': response.statusCode,
        };
      } else {
        throw Exception('HTTP Error: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ HTTP Error: $e');
      }
      return {
        'success': false,
        'error': e.toString(),
        'duration': 0,
      };
    }
  }

  // POST request dengan error handling manual
  static Future<Map<String, dynamic>> post(
    String url, {
    Map<String, dynamic>? body,
  }) async {
    try {
      final startTime = DateTime.now();
      
      if (kDebugMode) {
        debugPrint('🟢 HTTP POST Request: $url');
        debugPrint('📤 Body: $body');
      }
      
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );
      
      final endTime = DateTime.now();
      final duration = endTime.difference(startTime).inMilliseconds;
      
      if (kDebugMode) {
        debugPrint('⏱️ HTTP Duration: ${duration}ms');
        debugPrint('📊 HTTP Status: ${response.statusCode}');
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'data': jsonDecode(response.body),
          'duration': duration,
          'statusCode': response.statusCode,
        };
      } else {
        throw Exception('HTTP Error: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ HTTP Error: $e');
      }
      return {
        'success': false,
        'error': e.toString(),
        'duration': 0,
      };
    }
  }
}
