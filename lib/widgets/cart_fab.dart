// lib/widgets/cart_fab.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/cart_controller.dart';
import '../app/routes/app_routes.dart';

class CartFAB extends StatelessWidget {
  const CartFAB({super.key});

  @override
  Widget build(BuildContext context) {
    final CartController cartController = Get.find<CartController>();

    return Obx(() {
      return FloatingActionButton.extended(
        onPressed: () {
          Get.toNamed(AppRoutes.cart);
        },
        backgroundColor: Colors.purple[400],
        icon: Stack(
          children: [
            const Icon(Icons.shopping_cart),
            // ✅ FIX: Gunakan cartItems
            if (cartController.cartItems.isNotEmpty)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Text(
                    '${cartController.itemCount}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
        label: Text('Keranjang (${cartController.itemCount})'),
      );
    });
  }
}
