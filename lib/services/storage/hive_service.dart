// lib/services/storage/hive_service.dart
import 'package:hive_flutter/hive_flutter.dart';

/// Service untuk mengelola Hive (local database)
/// Untuk TUGAS 3: Implementasi Hive untuk data terstruktur
class HiveService {
  static const String cartBoxName = 'cart_box';
  static const String favoritesBoxName = 'favorites_box';
  static const String orderHistoryBoxName = 'order_history_box';

  // Initialize Hive
  static Future<void> init() async {
    await Hive.initFlutter();
    
    // Open boxes
    await Hive.openBox(cartBoxName);
    await Hive.openBox(favoritesBoxName);
    await Hive.openBox(orderHistoryBoxName);
  }

  // ========== CART OPERATIONS ========== //
  static Box getCartBox() => Hive.box(cartBoxName);
  
  static Future<void> saveCartItem(String key, Map<String, dynamic> value) async {
    final box = getCartBox();
    await box.put(key, value);
  }

  static Map<String, dynamic>? getCartItem(String key) {
    final box = getCartBox();
    final value = box.get(key);
    return value != null ? Map<String, dynamic>.from(value) : null;
  }

  static List<Map<String, dynamic>> getAllCartItems() {
    final box = getCartBox();
    return box.values
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
  }

  static Future<void> removeCartItem(String key) async {
    final box = getCartBox();
    await box.delete(key);
  }

  static Future<void> clearCart() async {
    final box = getCartBox();
    await box.clear();
  }

  // ========== FAVORITES OPERATIONS ========== //
  static Box getFavoritesBox() => Hive.box(favoritesBoxName);
  
  static Future<void> addFavorite(Map<String, dynamic> product) async {
    final box = getFavoritesBox();
    await box.add(product);
  }

  static Future<void> removeFavorite(int index) async {
    final box = getFavoritesBox();
    await box.deleteAt(index);
  }

  static List<Map<String, dynamic>> getAllFavorites() {
    final box = getFavoritesBox();
    return box.values
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
  }

  static bool isFavorite(String productName) {
    final box = getFavoritesBox();
    return box.values.any((e) => 
      (e as Map)['name'] == productName
    );
  }

  // ========== ORDER HISTORY ========== //
  static Box getOrderHistoryBox() => Hive.box(orderHistoryBoxName);
  
  static Future<void> saveOrder(Map<String, dynamic> order) async {
    final box = getOrderHistoryBox();
    await box.add(order);
  }

  static List<Map<String, dynamic>> getAllOrders() {
    final box = getOrderHistoryBox();
    return box.values
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
  }

  static Future<void> clearOrderHistory() async {
    final box = getOrderHistoryBox();
    await box.clear();
  }
}
