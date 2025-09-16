class Product {
  final String id;
  final String title;
  final String sellerName;
  final String? sellerId;
  final String? category;          // مثال: "جوالات"
  final String imageUrl;
  final double price;
  final double? oldPrice;
  final double rating;             // 0..5
  final int reviews;
  final DateTime createdAt;
  final String description;        // وصف المنتج (اختياري من Firestore)
  final double? avgRating;         // متوسط تقييم (لو مخزن مسبقًا)

  Product({
    required this.id,
    required this.title,
    required this.sellerName,
    this.sellerId,
    required this.imageUrl,
    required this.price,
    this.oldPrice,
    required this.rating,
    required this.reviews,
    required this.createdAt,
    this.category,
    this.description = '',
    this.avgRating,
  });

  factory Product.fromMap(String id, Map<String, dynamic> m) {
    final ts = m['createdAt'];
    DateTime created;
    if (ts is DateTime) {
      created = ts;
    } else if (ts != null && ts.toString().isNotEmpty) {
      // Timestamp from Firestore
      created = DateTime.tryParse(ts.toString()) ?? DateTime.now();
    } else {
      created = DateTime.now();
    }
    return Product(
      id: id,
      title: (m['title'] ?? '').toString(),
      sellerName: (m['sellerName'] ?? '').toString(),
      sellerId: m['sellerId']?.toString(),
      category: m['category']?.toString(),
      imageUrl: (m['imageUrl'] ?? '').toString(),
      price: (m['price'] ?? 0).toDouble(),
      oldPrice: (m['oldPrice'] == null) ? null : (m['oldPrice']).toDouble(),
      rating: (m['rating'] ?? 0).toDouble(),
      reviews: (m['reviews'] ?? 0) as int,
      createdAt: created,
      description: (m['description'] ?? '').toString(),
      avgRating: (m['avgRating'] as num?)?.toDouble(),
    );
  }
}
