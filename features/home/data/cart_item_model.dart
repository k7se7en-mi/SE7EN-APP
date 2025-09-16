class CartItem {
  final String productId;
  final String title;
  final String imageUrl;
  final double price;     // سعر الوحدة وقت الإضافة
  final int qty;

  CartItem({
    required this.productId,
    required this.title,
    required this.imageUrl,
    required this.price,
    required this.qty,
  });

  double get lineTotal => price * qty;

  factory CartItem.fromMap(Map<String, dynamic> m) => CartItem(
    productId: m['productId'],
    title: m['title'],
    imageUrl: m['imageUrl'],
    price: (m['price'] as num).toDouble(),
    qty: (m['qty'] as num).toInt(),
  );

  Map<String, dynamic> toMap() => {
    'productId': productId,
    'title': title,
    'imageUrl': imageUrl,
    'price': price,
    'qty': qty,
  };
}