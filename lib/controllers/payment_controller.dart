// lib/controllers/payment_controller.dart
import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../services/storage/hive_service.dart';
import '../services/notification_service.dart'; // ✅ TAMBAHKAN IMPORT INI

class PaymentController extends GetxController {
  var isProcessing = false.obs;
  final NotificationService _notificationService = NotificationService(); // ✅ TAMBAHKAN INSTANCE INI

  Future<void> checkout(List<Product> cart) async {
    try {
      isProcessing.value = true;

      // Simulasi total harga
      int total = cart.fold(0, (sum, item) => sum + item.price);

      // === SANDBOX MIDTRANS ===
      const serverKey = 'SB-Mid-server-yourSandboxKeyHere'; // Ganti dengan key kamu
      const apiUrl = 'https://api.sandbox.midtrans.com/v2/charge';

      // Untuk demo, kalau key belum diisi, skip panggilan API
      if (serverKey.contains('yourSandboxKeyHere')) {
        Get.snackbar(
          'Checkout Simulasi',
          'Total pembayaran Rp$total berhasil (Demo Mode)',
        );
        
        // ✅ TAMBAHKAN NOTIFIKASI PEMBAYARAN BERHASIL (DEFAULT SOUND)
        await _notificationService.showNotification(
          id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
          title: '✅ Pembayaran Berhasil',
          body: 'Transaksi sebesar Rp${_formatCurrency(total)} telah berhasil diproses',
          payload: 'payment_success',
          soundFileName: null, // ✅ NULL = pakai default sound (bukan custom)
        );
        
        if (kDebugMode) {
          debugPrint('✅ Payment notification sent with DEFAULT sound');
        }
        
        isProcessing.value = false;
        return;
      }

      // Buat payload pembayaran
      final payload = {
        "payment_type": "bank_transfer",
        "transaction_details": {
          "order_id": DateTime.now().millisecondsSinceEpoch.toString(),
          "gross_amount": total,
        },
        "bank_transfer": {"bank": "bca"},
      };

      if (kDebugMode) {
        debugPrint('💳 Processing payment...');
        debugPrint('📦 Total: Rp$total');
      }

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Basic ${base64Encode(utf8.encode('$serverKey:'))}",
        },
        body: jsonEncode(payload),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        Get.snackbar("Checkout Berhasil", "Transaksi berhasil diproses!");
        
        // ✅ TAMBAHKAN NOTIFIKASI PEMBAYARAN BERHASIL (DEFAULT SOUND)
        await _notificationService.showNotification(
          id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
          title: '✅ Pembayaran Berhasil',
          body: 'Transaksi sebesar Rp${_formatCurrency(total)} telah berhasil diproses',
          payload: 'payment_success',
          soundFileName: null, // ✅ NULL = pakai default sound
        );
        
        if (kDebugMode) {
          debugPrint('✅ Payment successful');
          debugPrint('✅ Payment notification sent with DEFAULT sound');
        }
      } else {
        Get.snackbar("Checkout Gagal", "${data["error_messages"]}");
        
        // ✅ TAMBAHKAN NOTIFIKASI PEMBAYARAN GAGAL (DEFAULT SOUND)
        await _notificationService.showNotification(
          id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
          title: '❌ Pembayaran Gagal',
          body: 'Terjadi kesalahan: ${data["error_messages"]}',
          payload: 'payment_failed',
          soundFileName: null, // ✅ NULL = pakai default sound
        );
        
        if (kDebugMode) {
          debugPrint('❌ Payment failed: ${data["error_messages"]}');
        }
      }
    } catch (e) {
      Get.snackbar("Checkout Error", e.toString());
      
      // ✅ TAMBAHKAN NOTIFIKASI ERROR (DEFAULT SOUND)
      await _notificationService.showNotification(
        id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title: '⚠️ Error Pembayaran',
        body: 'Terjadi kesalahan saat memproses pembayaran',
        payload: 'payment_error',
        soundFileName: null, // ✅ NULL = pakai default sound
      );
      
      if (kDebugMode) {
        debugPrint('❌ Payment error: $e');
      }
    } finally {
      isProcessing.value = false;
    }
  }

  /// Save order to Hive (order history)
  Future<void> saveOrderHistory({
    required String customerName,
    required int totalAmount,
    required String paymentMethod,
    required List<Product> items,
  }) async {
    try {
      final order = {
        'order_id': 'ORD${DateTime.now().millisecondsSinceEpoch}',
        'customer_name': customerName,
        'total_amount': totalAmount,
        'payment_method': paymentMethod,
        'items': items.map((e) => {
          'name': e.name,
          'price': e.price,
        }).toList(),
        'date': DateTime.now().toIso8601String(),
      };

      await HiveService.saveOrder(order);

      if (kDebugMode) {
        debugPrint('💾 Order saved to history');
      }
      
      // ✅ OPTIONAL: Kirim notifikasi bahwa order history tersimpan
      await _notificationService.showNotification(
        id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title: '📦 Pesanan Tersimpan',
        body: 'Riwayat pesanan Anda telah tersimpan',
        payload: 'order_saved',
        soundFileName: null, // ✅ NULL = pakai default sound
      );
      
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error saving order: $e');
      }
    }
  }

  /// ✅ FUNGSI HELPER: Format currency ke format Rupiah
  String _formatCurrency(int amount) {
    return amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  /// ✅ FUNGSI TAMBAHAN: Test Custom Sound Notification (untuk debugging)
  Future<void> testCustomSoundNotification() async {
    await _notificationService.showNotification(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: '🔊 Test Custom Sound',
      body: 'Ini notifikasi dengan custom sound notif1.mp3',
      payload: 'test_custom_sound',
      soundFileName: 'notif1.mp3', // ✅ CUSTOM SOUND
    );
    
    if (kDebugMode) {
      debugPrint('✅ Custom sound notification sent');
    }
  }

  /// ✅ FUNGSI TAMBAHAN: Test Default Sound Notification (untuk debugging)
  Future<void> testDefaultSoundNotification() async {
    await _notificationService.showNotification(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: '🔔 Test Default Sound',
      body: 'Ini notifikasi dengan default sound',
      payload: 'test_default_sound',
      soundFileName: null, // ✅ NULL = DEFAULT SOUND
    );
    
    if (kDebugMode) {
      debugPrint('✅ Default sound notification sent');
    }
  }
}
