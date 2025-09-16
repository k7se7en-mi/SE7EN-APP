// lib/cart/data/cart_item_model.dart
class CartItem {
  final String id;       // productId
  final String title;
  final double price;
  final int qty;
  final String? imageUrl;

  CartItem({
    required this.id,
    required this.title,
    required this.price,
    this.qty = 1,
    this.imageUrl,
  });

  CartItem copyWith({
    String? id,
    String? title,
    double? price,
    int? qty,
    String? imageUrl,
  }) {
    return CartItem(
      id: id ?? this.id,
      title: title ?? this.title,
      price: price ?? this.price,
      qty: qty ?? this.qty,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': id,
      'title': title,
      'price': price,
      'qty': qty,
      'imageUrl': imageUrl,
    };
  }

  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      id: map['productId'] ?? '',
      title: map['title'] ?? '',
      price: (map['price'] is num) ? (map['price'] as num).toDouble() : 0.0,
      qty: map['qty'] ?? 1,
      imageUrl: map['imageUrl'],
    );
  }
}
