// lib/views/payment/checkout_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/cart_controller.dart';
import '../../controllers/payment_controller.dart';
import '../../models/product.dart';
import '../../services/storage/shared_prefs_service.dart';
import '../../services/storage/supabase_service.dart';
import '../../models/order_model.dart';
import '../../app/routes/app_routes.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final cart = Get.find<CartController>();
  final payment = Get.find<PaymentController>();

  // Form controllers
  final _namaController = TextEditingController();
  final _emailController = TextEditingController();
  final _noHpController = TextEditingController();
  final _alamatController = TextEditingController();

  String _selectedPaymentMethod = 'BCA Virtual Account';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _namaController.dispose();
    _emailController.dispose();
    _noHpController.dispose();
    _alamatController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final email = await SharedPrefsService.getUserEmail();
    final name = await SharedPrefsService.getUserName();

    if (email != null) {
      _emailController.text = email;

      // Ambil data user dari Supabase
      final userData = await SupabaseService.getUserByEmail(email);
      if (userData != null) {
        _namaController.text = userData.nama;
        _emailController.text = userData.email;
        _noHpController.text = userData.noHp ?? '';
        _alamatController.text = userData.alamatLengkap ?? '';
      } else if (name != null) {
        _namaController.text = name;
      }
    }
  }

  Future<void> _processCheckout() async {
    // Validasi form
    if (_namaController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _noHpController.text.isEmpty ||
        _alamatController.text.isEmpty) {
      Get.snackbar(
        'Data Tidak Lengkap',
        'Mohon lengkapi semua data',
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Ambil email login dari SharedPrefs (lebih aman untuk filter riwayat)
      final loginEmail = await SharedPrefsService.getUserEmail();
      if (loginEmail == null) {
        throw Exception('Email pengguna tidak ditemukan, silakan login ulang.');
      }

      // Ambil data dari cart
      final List<Product> cartItems = List<Product>.from(cart.cartItems);
      final totalPembayaran = cart.totalPrice.toDouble();

      // Hitung quantity produk (grouping produk yang sama)
      Map<String, int> productQuantities = {};
      for (var product in cartItems) {
        productQuantities[product.name] =
            (productQuantities[product.name] ?? 0) + 1;
      }

      // Format nama produk dengan quantity
      final namaProduk = productQuantities.entries
          .map((entry) => '${entry.key} x${entry.value}')
          .join(', ');

      final totalProduk = cartItems.length;

      // Buat order dengan struktur sesuai table Supabase
      final order = OrderModel(
        email: loginEmail, // <- kolom email di tabel orders
        items: {
          'email': _emailController.text.trim(),
          'nama': _namaController.text.trim(),
          'no_hp': _noHpController.text.trim(),
          'alamat_lengkap': _alamatController.text.trim(),
          'nama_produk': namaProduk,
          'total_produk': totalProduk,
        },
        total: totalPembayaran,
        paymentmethod: _selectedPaymentMethod,
        status: 'pending',
        createdat: DateTime.now(),
      );

      // Simpan order ke Supabase
      final result = await SupabaseService.createOrder(order);

      if (result != null) {
        debugPrint('✅ Order berhasil disimpan dengan ID: ${result.id}');

        // Simpan riwayat lokal (Hive) kalau masih dipakai
        await payment.saveOrderHistory(
          customerName: _namaController.text,
          totalAmount: cart.totalPrice,
          paymentMethod: _selectedPaymentMethod,
          items: cartItems,
        );

        // Clear cart
        cart.clearCart();

        setState(() => _isLoading = false);

        // Navigate ke success page
        Get.offNamed(
          AppRoutes.paymentSuccess,
          arguments: _namaController.text.trim(),
        );
      } else {
        throw Exception('Gagal menyimpan order');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      Get.snackbar(
        'Checkout Gagal',
        e.toString(),
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
      );
      debugPrint('❌ Error creating order: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        backgroundColor: Colors.purple[400],
        foregroundColor: Colors.white,
      ),
      body: Obx(() {
        if (cart.cartItems.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.shopping_cart_outlined,
                  size: 80,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Keranjang Kosong',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Belum ada produk di keranjang',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Get.back(),
                  child: const Text('Belanja Sekarang'),
                ),
              ],
            ),
          );
        }

        // Grouping produk untuk hitung quantity
        Map<String, Map<String, dynamic>> groupedItems = {};
        for (var product in cart.cartItems) {
          if (groupedItems.containsKey(product.name)) {
            groupedItems[product.name]!['quantity']++;
          } else {
            groupedItems[product.name] = {
              'product': product,
              'quantity': 1,
            };
          }
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // SECTION: Ringkasan Pesanan
              const Text(
                'Ringkasan Pesanan',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: groupedItems.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (context, index) {
                    final entry = groupedItems.entries.elementAt(index);
                    final Product product = entry.value['product'];
                    final int quantity = entry.value['quantity'];
                    final int subtotal = product.price * quantity;

                    return Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                'Qty: $quantity',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          'Rp $subtotal',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),

              // SECTION: Data Pembeli
              const Text(
                'Data Pembeli',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              // Nama
              TextField(
                controller: _namaController,
                decoration: InputDecoration(
                  labelText: 'Nama Lengkap',
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Email
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 12),

              // No HP
              TextField(
                controller: _noHpController,
                decoration: InputDecoration(
                  labelText: 'Nomor HP',
                  prefixIcon: const Icon(Icons.phone_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),

              // Alamat
              TextField(
                controller: _alamatController,
                decoration: InputDecoration(
                  labelText: 'Alamat Lengkap',
                  prefixIcon: const Icon(Icons.home_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),

              // SECTION: Metode Pembayaran
              const Text(
                'Metode Pembayaran',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              ...[
                'BCA Virtual Account',
                'Mandiri Virtual Account',
                'BNI Virtual Account',
                'GoPay',
                'OVO',
                'ShopeePay',
              ].map((method) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: RadioListTile<String>(
                    value: method,
                    groupValue: _selectedPaymentMethod,
                    onChanged: (value) {
                      setState(() {
                        _selectedPaymentMethod = value!;
                      });
                    },
                    title: Text(method),
                    secondary: Icon(
                      method.contains('Virtual')
                          ? Icons.account_balance
                          : Icons.payment,
                      color: Colors.purple,
                    ),
                    activeColor: Colors.purple,
                  ),
                );
              }).toList(),
              const SizedBox(height: 24),

              // SECTION: Total
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.purple[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.purple[200]!),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total Pembayaran',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Rp ${cart.totalPrice}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.purple[700],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // BUTTON: Bayar
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _processCheckout,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple[400],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Bayar Sekarang',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
