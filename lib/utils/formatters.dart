// lib/utils/formatters.dart
import 'package:intl/intl.dart';

class Formatters {
  /// Format currency (Rupiah)
  static String currency(int amount) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  /// Format date
  static String date(DateTime date) {
    final formatter = DateFormat('dd MMMM yyyy', 'id_ID');
    return formatter.format(date);
  }

  /// Format datetime
  static String datetime(DateTime date) {
    final formatter = DateFormat('dd MMM yyyy HH:mm', 'id_ID');
    return formatter.format(date);
  }

  /// Format phone number
  static String phone(String phone) {
    // Remove non-numeric characters
    final cleaned = phone.replaceAll(RegExp(r'\D'), '');
    
    // Format: 0812-3456-7890
    if (cleaned.length >= 10) {
      return '${cleaned.substring(0, 4)}-${cleaned.substring(4, 8)}-${cleaned.substring(8)}';
    }
    
    return cleaned;
  }
}
