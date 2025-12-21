// lib/models/cart_item.dart
import 'product.dart';

class CartItem {
  final Product product;
  int quantity;

  CartItem({
    required this.product,
    this.quantity = 1,
  });

  int get totalPrice => product.price * quantity;

  Map<String, dynamic> toMap() {
    return {
      'name': product.name,
      'price': product.price,
      'image': product.image,
      'quantity': quantity,
    };
  }

  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      product: Product(
        name: map['name'],
        price: map['price'],
        image: map['image'],
      ),
      quantity: map['quantity'] ?? 1,
    );
  }
}
