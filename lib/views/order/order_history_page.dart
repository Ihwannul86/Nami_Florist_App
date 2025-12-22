// lib/views/order/order_history_page.dart
import 'package:flutter/material.dart';

class OrderHistoryPage extends StatelessWidget {
  const OrderHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    // sementara dummy data, nanti bisa diisi dari Supabase
    final orders = [
      {
        'id': '#INV-001',
        'tanggal': '22-12-2025 10:15',
        'total': 'Rp120.000',
        'status': 'Selesai',
      },
      {
        'id': '#INV-002',
        'tanggal': '22-12-2025 11:30',
        'total': 'Rp75.000',
        'status': 'Diproses',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Pesanan'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final o = orders[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: const Icon(Icons.receipt_long),
              title: Text(o['id']!),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(o['tanggal']!),
                  Text(
                    o['status']!,
                    style: TextStyle(
                      color: o['status'] == 'Selesai'
                          ? Colors.green
                          : Colors.orange,
                    ),
                  ),
                ],
              ),
              trailing: Text(
                o['total']!,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          );
        },
      ),
    );
  }
}
