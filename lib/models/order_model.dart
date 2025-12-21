// lib/models/order_model.dart
class OrderModel {
  final String? id; // ✅ GANTI: dari int? ke String?
  final Map<String, dynamic> items;
  final double total;
  final String paymentmethod;
  final String? status;
  final DateTime? createdat;

  OrderModel({
    this.id,
    required this.items,
    required this.total,
    required this.paymentmethod,
    this.status,
    this.createdat,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id']?.toString(), // ✅ TAMBAH: konversi ke String
      items: json['items'] as Map<String, dynamic>,
      total: (json['total'] as num).toDouble(),
      paymentmethod: json['paymentmethod'],
      status: json['status'],
      createdat: json['createdat'] != null 
          ? DateTime.parse(json['createdat']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'items': items,
      'total': total,
      'paymentmethod': paymentmethod,
      'status': status ?? 'pending',
      if (createdat != null) 'createdat': createdat!.toIso8601String(),
    };
  }
}
