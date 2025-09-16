class OrderItemLine {
  final String productId;
  final String title;
  final String imageUrl;
  final double price;
  final int qty;
  final double lineTotal;

  OrderItemLine({
    required this.productId,
    required this.title,
    required this.imageUrl,
    required this.price,
    required this.qty,
    required this.lineTotal,
  });

  factory OrderItemLine.fromMap(Map<String, dynamic> m) => OrderItemLine(
        productId: (m['productId'] ?? '').toString(),
        title: (m['title'] ?? '').toString(),
        imageUrl: (m['imageUrl'] ?? '').toString(),
        price: (m['price'] as num).toDouble(),
        qty: (m['qty'] as num).toInt(),
        lineTotal: (m['lineTotal'] as num).toDouble(),
      );
}

class UserOrder {
  final String id;
  final String userId;
  final DateTime createdAt;
  final String paymentMethod; // COD / TAMARA / ...
  final String status;        // pending_cod | pending_payment | paid | shipped | delivered | canceled
  final double subTotal;
  final double vat;
  final double codFee;
  final double total;
  final String? addressId;
  final String name;
  final String phone;
  final String city;
  final String details;
  final List<OrderItemLine> items;

  UserOrder({
    required this.id,
    required this.userId,
    required this.createdAt,
    required this.paymentMethod,
    required this.status,
    required this.subTotal,
    required this.vat,
    required this.codFee,
    required this.total,
    required this.addressId,
    required this.name,
    required this.phone,
    required this.city,
    required this.details,
    required this.items,
  });
}
