// lib/views/product/product_card.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/product.dart';
import '../../controllers/cart_controller.dart';
import 'detail_page.dart';

/// ProductCard dengan ANIMASI IMPLISIT & EKSPLISIT (TUGAS 1)
class ProductCard extends StatefulWidget {
  final Product product;
  const ProductCard({super.key, required this.product});

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard>
    with SingleTickerProviderStateMixin {
  bool isAdded = false;
  bool isTapped = false;
  
  // === ANIMASI EKSPLISIT (TUGAS 1) === //
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  final cartController = Get.find<CartController>();

  @override
  void initState() {
    super.initState();
    
    // Setup AnimationController untuk kontrol manual
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
      lowerBound: 0.0,
      upperBound: 0.05,
    );
    
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.95)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void goToDetail() {
    // === PAGE ROUTE TRANSITION (TUGAS 1) === //
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 700),
        pageBuilder: (_, __, ___) => DetailPage(product: widget.product),
        transitionsBuilder: (_, animation, __, child) {
          final offsetAnim =
              Tween(begin: const Offset(0, 1), end: Offset.zero).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
          );
          return SlideTransition(
            position: offsetAnim,
            child: FadeTransition(opacity: animation, child: child),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnim,
      child: GestureDetector(
        onTapDown: (_) {
          setState(() => isTapped = true);
          _controller.forward(); // Manual start animation
        },
        onTapUp: (_) {
          setState(() => isTapped = false);
          _controller.reverse(); // Manual reverse animation
          goToDetail();
        },
        onTapCancel: () {
          setState(() => isTapped = false);
          _controller.reverse();
        },
        child: AnimatedContainer(
          // === ANIMASI IMPLISIT (TUGAS 1) === //
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color: isTapped ? Colors.blue[50] : Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: isTapped ? 2 : 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Gambar produk - Menggunakan Expanded untuk fleksibilitas
              Expanded(
                flex: 6,
                child: ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(20)),
                  child: Image.asset(
                    widget.product.image,
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                ),
              ),
              // Informasi produk - Bagian bawah
              Expanded(
                flex: 4,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Nama produk
                      Text(
                        widget.product.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          height: 1.1,
                        ),
                      ),
                      // Harga
                      Text(
                        "Rp${widget.product.price}",
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      // Tombol tambah dengan ukuran tetap
                      SizedBox(
                        height: 32,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            setState(() => isAdded = !isAdded);
                            cartController.addToCart(widget.product);
                          },
                          icon: Icon(
                            isAdded ? Icons.check : Icons.add_shopping_cart,
                            size: 14,
                          ),
                          label: Text(
                            isAdded ? "Ditambahkan" : "Tambah",
                            style: const TextStyle(fontSize: 12),
                          ),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            backgroundColor: Colors.purple[100],
                            foregroundColor: Colors.purple[800],
                            minimumSize: const Size(0, 32),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
