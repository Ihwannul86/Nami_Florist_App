import 'package:flutter/material.dart';
import '../../services/storage/shared_prefs_service.dart';
import '../../services/storage/supabase_service.dart';
import '../../models/order_model.dart';

class OrderHistoryPage extends StatefulWidget {
  const OrderHistoryPage({super.key});

  @override
  State<OrderHistoryPage> createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends State<OrderHistoryPage> {
  bool _isLoading = true;
  List<OrderModel> _orders = [];

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    final email = await SharedPrefsService.getUserEmail();
    if (email == null) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email pengguna tidak ditemukan')),
      );
      return;
    }

    final data = await SupabaseService.getOrdersByEmail(email);
    if (!mounted) return;
    setState(() {
      _orders = data;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Pesanan'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _orders.isEmpty
              ? const Center(child: Text('Belum ada pesanan.'))
              : RefreshIndicator(
                  onRefresh: _loadOrders,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: _orders.length,
                    itemBuilder: (context, index) {
                      final order = _orders[index];
                      final items = order.items;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: const Icon(Icons.receipt_long),
                          title: Text(
                            order.id != null ? '#${order.id}' : 'Pesanan',
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (order.createdat != null)
                                Text(order.createdat.toString()),
                              Text(
                                order.status ?? 'pending',
                                style: TextStyle(
                                  color: (order.status ?? '') == 'sukses'
                                      ? Colors.green
                                      : Colors.orange,
                                ),
                              ),
                              if (items != null &&
                                  items is Map<String, dynamic> &&
                                  items['alamat_lengkap'] != null)
                                Text('Dikirim ke: ${items['alamat_lengkap']}'),
                            ],
                          ),
                          trailing: Text(
                            'Rp ${order.total?.toInt() ?? 0}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
