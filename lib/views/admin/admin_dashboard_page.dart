import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/order_model.dart';
import '../../models/user_model.dart';
import '../../services/storage/shared_prefs_service.dart';
import '../../services/storage/supabase_service.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  bool _isLoading = true;
  List<OrderModel> _orders = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final email = await SharedPrefsService.getUserEmail();
    if (email == null) {
      if (mounted) {
        Get.back();
      }
      return;
    }

    final user = await SupabaseService.getUserByEmail(email);

    if (!mounted) return;

    // Guard: hanya admin
    if (user == null || !user.isAdmin) {
      Get.snackbar(
        'Akses ditolak',
        'Halaman ini hanya untuk admin.',
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
      );
      Get.back();
      return;
    }

    // Ambil semua orders
    final rows = await SupabaseService.getData(
      table: 'orders',
      orderBy: 'createdat',
      ascending: false,
    );

    setState(() {
      _orders = rows.map((e) => OrderModel.fromJson(e)).toList();
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: Colors.purple[400],
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _orders.isEmpty
              ? const Center(child: Text('Belum ada order.'))
              : ListView.builder(
                  itemCount: _orders.length,
                  itemBuilder: (context, index) {
                    final order = _orders[index];
                    final items = order.items;

                    return Card(
                      margin: const EdgeInsets.all(8),
                      child: ListTile(
                        title: Text(items['nama'] ?? 'Tanpa nama'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Email: ${items['email']}'),
                            Text('Produk: ${items['nama_produk']}'),
                            Text('Total produk: ${items['total_produk']}'),
                            Text('Total bayar: Rp ${order.total.toInt()}'),
                            Text('Metode: ${order.paymentmethod}'),
                            Text('Status: ${order.status ?? 'pending'}'),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
