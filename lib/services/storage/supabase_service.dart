// lib/services/storage/supabase_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

/// Service untuk mengelola Supabase (cloud storage)
/// Untuk TUGAS 3: Implementasi Supabase untuk auth dan database
class SupabaseService {
  static final SupabaseClient _client = Supabase.instance.client;

  // Get Supabase client
  static SupabaseClient get client => _client;

  // ========== AUTHENTICATION ========== //
  
  /// Sign in dengan email dan password
  static Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      
      if (kDebugMode) {
        debugPrint('✅ Login successful: ${response.user?.email}');
      }
      
      return response;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Login error: $e');
      }
      rethrow;
    }
  }

  /// Sign up dengan email dan password
  static Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
    Map<String, dynamic>? data,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: data,
      );
      
      if (kDebugMode) {
        debugPrint('✅ Sign up successful: ${response.user?.email}');
      }
      
      return response;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Sign up error: $e');
      }
      rethrow;
    }
  }

  /// Sign out
  static Future<void> signOut() async {
    try {
      await _client.auth.signOut();
      if (kDebugMode) {
        debugPrint('✅ Sign out successful');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Sign out error: $e');
      }
      rethrow;
    }
  }

  /// Get current user
  static User? getCurrentUser() {
    return _client.auth.currentUser;
  }

  /// Check if user is logged in
  static bool isLoggedIn() {
    return _client.auth.currentUser != null;
  }

  // ========== DATABASE OPERATIONS ========== //
  
  /// Insert data ke table
  static Future<void> insertData({
    required String table,
    required Map<String, dynamic> data,
  }) async {
    try {
      await _client.from(table).insert(data);
      if (kDebugMode) {
        debugPrint('✅ Data inserted to $table');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Insert error: $e');
      }
      rethrow;
    }
  }

  /// Get data dari table
  static Future<List<Map<String, dynamic>>> getData({
    required String table,
    String? orderBy,
    bool ascending = true,
  }) async {
    try {
      // ✅ FIX: Jangan re-assign, langsung chain method
      final response = await _client
          .from(table)
          .select()
          .order(orderBy ?? 'id', ascending: ascending);
      
      if (kDebugMode) {
        debugPrint('✅ Got ${response.length} rows from $table');
      }
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Get data error: $e');
      }
      rethrow;
    }
  }

  /// Update data di table
  static Future<void> updateData({
    required String table,
    required Map<String, dynamic> data,
    required String column,
    required dynamic value,
  }) async {
    try {
      await _client
          .from(table)
          .update(data)
          .eq(column, value);
      
      if (kDebugMode) {
        debugPrint('✅ Data updated in $table');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Update error: $e');
      }
      rethrow;
    }
  }

  /// Delete data dari table
  static Future<void> deleteData({
    required String table,
    required String column,
    required dynamic value,
  }) async {
    try {
      await _client
          .from(table)
          .delete()
          .eq(column, value);
      
      if (kDebugMode) {
        debugPrint('✅ Data deleted from $table');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Delete error: $e');
      }
      rethrow;
    }
  }

  // ========== ADVANCED QUERIES ========== //
  
  /// Get data dengan filter
  static Future<List<Map<String, dynamic>>> getDataWithFilter({
    required String table,
    required String column,
    required dynamic value,
    String? orderBy,
    bool ascending = true,
  }) async {
    try {
      final response = await _client
        .from(table)
        .select()
        .order(orderBy ?? 'id', ascending: ascending);
      
      //final response = await query;
      
      if (kDebugMode) {
        debugPrint('✅ Got ${response.length} filtered rows from $table');
      }
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Get filtered data error: $e');
      }
      rethrow;
    }
  }

  /// Get data dengan limit
  static Future<List<Map<String, dynamic>>> getDataWithLimit({
    required String table,
    int limit = 10,
    String? orderBy,
    bool ascending = true,
  }) async {
    try {
      var query = _client.from(table).select().limit(limit);
      
      if (orderBy != null) {
        query = query.order(orderBy, ascending: ascending);
      }
      
      final response = await query;
      
      if (kDebugMode) {
        debugPrint('✅ Got ${response.length} rows (limit: $limit) from $table');
      }
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Get limited data error: $e');
      }
      rethrow;
    }
  }
}
