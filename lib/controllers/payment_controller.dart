// lib/controllers/payment_controller.dart
import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../services/storage/hive_service.dart';

class PaymentController extends GetxController {
  var isProcessing = false.obs;

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
        
        if (kDebugMode) {
          debugPrint('✅ Payment successful');
        }
      } else {
        Get.snackbar("Checkout Gagal", "${data["error_messages"]}");
        
        if (kDebugMode) {
          debugPrint('❌ Payment failed: ${data["error_messages"]}');
        }
      }
    } catch (e) {
      Get.snackbar("Checkout Error", e.toString());
      
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
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error saving order: $e');
      }
    }
  }
}
