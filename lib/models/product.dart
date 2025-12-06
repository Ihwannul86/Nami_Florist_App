// lib/models/product.dart
class Product {
  final String name;
  final int price;
  final String image;

  Product({
    required this.name,
    required this.price,
    required this.image,
  });

  // Convert to Map (untuk Hive storage)
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'image': image,
    };
  }

  // Create from Map
  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      name: map['name'] ?? '',
      price: map['price'] ?? 0,
      image: map['image'] ?? '',
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() => {
    'name': name,
    'price': price,
    'image': image,
  };

  // Create from JSON
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      name: json['name'] ?? '',
      price: json['price'] ?? 0,
      image: json['image'] ?? '',
    );
  }
}
