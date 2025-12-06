// lib/views/payment/payment_success_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../home/landing_page.dart';

class PaymentSuccessPage extends StatelessWidget {
  final String customerName;
  final int totalAmount;
  final String paymentMethod;

  const PaymentSuccessPage({
    super.key,
    required this.customerName,
    required this.totalAmount,
    required this.paymentMethod,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon Success
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle,
                  size: 80,
                  color: Colors.green[400],
                ),
              ),
              const SizedBox(height: 32),

              // Judul
              const Text(
                'Pembayaran Berhasil!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),

              // Deskripsi
              Text(
                'Terima kasih $customerName,\npesanan Anda sedang diproses',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Detail Transaksi
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      _buildDetailRow(
                        'Nomor Order',
                        'ORD${DateTime.now().millisecondsSinceEpoch}',
                      ),
                      const Divider(height: 24),
                      _buildDetailRow(
                        'Metode Pembayaran',
                        paymentMethod,
                      ),
                      const Divider(height: 24),
                      _buildDetailRow(
                        'Total Pembayaran',
                        'Rp$totalAmount',
                        isTotal: true,
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),

              // Tombol Kembali
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Get.offAll(() => LandingPage());
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple[400],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Kembali ke Beranda',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  Get.snackbar(
                    'Info',
                    'Fitur riwayat pesanan akan segera hadir!',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                },
                child: const Text(
                  'Lihat Riwayat Pesanan',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.purple,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: Colors.grey[700],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 18 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
            color: isTotal ? Colors.purple : Colors.black87,
          ),
        ),
      ],
    );
  }
}
