// lib/services/storage/shared_prefs_service.dart
import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsService {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Login State
  static Future<void> setLoggedIn(bool value) async {
    await _prefs?.setBool('isLoggedIn', value);
  }

  static Future<bool> isLoggedIn() async {
    return _prefs?.getBool('isLoggedIn') ?? false;
  }

  // User Email
  static Future<void> setUserEmail(String email) async {
    await _prefs?.setString('userEmail', email);
  }

  static Future<String?> getUserEmail() async {
    return _prefs?.getString('userEmail');
  }

  // User Name
  static Future<void> setUserName(String name) async {
    await _prefs?.setString('userName', name);
  }

  static Future<String?> getUserName() async {
    return _prefs?.getString('userName');
  }

  // User Role (✅ TAMBAHAN UNTUK CEK ADMIN)
  static Future<void> setUserRole(String role) async {
    await _prefs?.setString('userRole', role);
  }

  static Future<String?> getUserRole() async {
    return _prefs?.getString('userRole');
  }

  static Future<bool> isAdmin() async {
    final role = await getUserRole();
    return role == 'admin';
  }

  // Clear all user data
  static Future<void> clearUserData() async {
    await _prefs?.remove('isLoggedIn');
    await _prefs?.remove('userEmail');
    await _prefs?.remove('userName');
    await _prefs?.remove('userRole');
  }
}
