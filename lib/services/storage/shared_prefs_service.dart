// lib/services/storage/shared_prefs_service.dart
import 'package:shared_preferences/shared_preferences.dart';

/// Service untuk mengelola SharedPreferences
/// Untuk TUGAS 3: Implementasi penyimpanan lokal
class SharedPrefsService {
  static SharedPreferences? _prefs;

  // Initialize SharedPreferences
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // ========== LOGIN STATE ========== //
  static Future<void> setLoggedIn(bool value) async {
    await _prefs?.setBool('logged_in', value);
  }

  static bool getLoggedIn() {
    return _prefs?.getBool('logged_in') ?? false;
  }

  // ========== USER DATA ========== //
  static Future<void> setUserName(String name) async {
    await _prefs?.setString('user_name', name);
  }

  static String? getUserName() {
    return _prefs?.getString('user_name');
  }

  static Future<void> setUserEmail(String email) async {
    await _prefs?.setString('user_email', email);
  }

  static String? getUserEmail() {
    return _prefs?.getString('user_email');
  }

  // ========== THEME PREFERENCE (untuk tugas 3) ========== //
  static Future<void> setThemeMode(String mode) async {
    await _prefs?.setString('theme_mode', mode);
  }

  static String getThemeMode() {
    return _prefs?.getString('theme_mode') ?? 'system';
  }

  static Future<void> setDarkMode(bool value) async {
    await _prefs?.setBool('dark_mode', value);
  }

  static bool getDarkMode() {
    return _prefs?.getBool('dark_mode') ?? false;
  }

  // ========== APP SETTINGS ========== //
  static Future<void> setNotificationsEnabled(bool value) async {
    await _prefs?.setBool('notifications_enabled', value);
  }

  static bool getNotificationsEnabled() {
    return _prefs?.getBool('notifications_enabled') ?? true;
  }

  // ========== CLEAR DATA ========== //
  static Future<void> clearAll() async {
    await _prefs?.clear();
  }

  static Future<void> clearUserData() async {
    await _prefs?.remove('user_name');
    await _prefs?.remove('user_email');
    await _prefs?.remove('logged_in');
  }
}
