// lib/widgets/cart_fab.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/cart_controller.dart';
import '../views/cart/cart_page.dart';

class CartFAB extends StatelessWidget {
  const CartFAB({super.key});

  @override
  Widget build(BuildContext context) {
    final CartController cartController = Get.find<CartController>();

    return Obx(() => FloatingActionButton.extended(
          onPressed: () {
            Get.to(() => const CartPage());
          },
          icon: Stack(
            children: [
              const Icon(Icons.shopping_cart),
              if (cartController.cartItems.isNotEmpty)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
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
          backgroundColor: Colors.purple[400],
          foregroundColor: Colors.white,
        ));
  }
}
