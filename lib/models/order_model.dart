import 'package:uuid/uuid.dart';

class OrderModel {
  String? id;
  String? email;
  Map<String, dynamic>? items;
  double? total;
  String? paymentmethod;
  String? status;
  DateTime? createdat;

  OrderModel({
    this.id,
    this.email,
    this.items,
    this.total,
    this.paymentmethod,
    this.status,
    this.createdat,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] as String?,
      email: json['email'] as String?,
      items: json['items'] as Map<String, dynamic>?,
      total: (json['total'] as num?)?.toDouble(),
      paymentmethod: json['paymentmethod'] as String?,
      status: json['status'] as String?,
      createdat: json['createdat'] != null
          ? DateTime.parse(json['createdat'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final generatedId = id ?? const Uuid().v4(); // 🔹 buat id jika null
    return {
      'id': generatedId,
      'email': email,
      'items': items,
      'total': total,
      'paymentmethod': paymentmethod,
      'status': status,
      'createdat': createdat?.toIso8601String(),
    };
  }
}
