// lib/controllers/cart_controller.dart
import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../services/storage/hive_service.dart';

class CartController extends GetxController {
  var cartItems = <Product>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadCartFromHive();
  }

  /// Load cart dari Hive (persistent storage)
  void loadCartFromHive() {
    try {
      final items = HiveService.getAllCartItems();
      cartItems.value = items.map((item) {
        return Product(
          name: item['name'],
          price: item['price'],
          image: item['image'],
        );
      }).toList();

      if (kDebugMode) {
        debugPrint('🛒 Loaded ${cartItems.length} items from Hive');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error loading cart from Hive: $e');
      }
    }
  }

  /// Add product to cart
  void addToCart(Product product) {
    cartItems.add(product);
    
    // Save to Hive
    saveCartToHive();

    if (kDebugMode) {
      debugPrint('✅ Added to cart: ${product.name}');
      debugPrint('🛒 Total items: ${cartItems.length}');
    }
  }

  /// Remove product from cart
  void removeFromCart(Product product) {
    cartItems.remove(product);
    
    // Save to Hive
    saveCartToHive();

    if (kDebugMode) {
      debugPrint('🗑️ Removed from cart: ${product.name}');
    }
  }

  /// Clear all cart items
  void clearCart() {
    cartItems.clear();
    HiveService.clearCart();

    if (kDebugMode) {
      debugPrint('🗑️ Cart cleared');
    }
  }

  /// Save cart to Hive
  void saveCartToHive() {
    try {
      HiveService.clearCart();
      
      for (var i = 0; i < cartItems.length; i++) {
        final product = cartItems[i];
        HiveService.saveCartItem('item_$i', {
          'name': product.name,
          'price': product.price,
          'image': product.image,
        });
      }

      if (kDebugMode) {
        debugPrint('💾 Cart saved to Hive');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error saving cart to Hive: $e');
      }
    }
  }

  /// Get total price
  int get totalPrice => cartItems.fold(0, (sum, item) => sum + item.price);

  /// Get total items count
  int get itemCount => cartItems.length;
}
