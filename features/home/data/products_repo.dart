import 'package:cloud_firestore/cloud_firestore.dart';
import 'product_model.dart';

class ProductQuery {
  // أساسية
  final String? section;   // اسم القسم (للتقسيم في الواجهة)
  final String? category;  // فئة المنتج
  final String? sellerId;  // فلترة حسب متجر
  final String? badge;     // ختم/ترند... الخ

  // بحث/فلترة رقمية
  final String? search;    // نص البحث (prefix)
  final double? minPrice;
  final double? maxPrice;
  final double? minRating;

  // ترتيب وحدود
  final String sort;       // 'الأحدث' | 'السعر: من الأقل' | 'السعر: من الأعلى' | 'الأعلى تقييماً'
  final int limit;

  const ProductQuery({
    this.section,
    this.category,
    this.sellerId,
    this.badge,
    this.search,
    this.minPrice,
    this.maxPrice,
    this.minRating,
    this.sort = 'الأحدث',
    this.limit = 24,
  });
}

abstract class ProductsRepo {
  Stream<List<Product>> streamSection(ProductQuery query);
}

Query<Map<String, dynamic>> buildQuery(ProductQuery q, FirebaseFirestore db) {
  var ref = db.collection('products').where('title', isGreaterThan: ''); // anchor

  if (q.category != null && q.category!.isNotEmpty) {
    ref = ref.where('category', isEqualTo: q.category);
  }
  if (q.sellerId != null && q.sellerId!.isNotEmpty) {
    ref = ref.where('sellerId', isEqualTo: q.sellerId);
  }
  if (q.badge != null && q.badge!.isNotEmpty) {
    ref = ref.where('badges', arrayContains: q.badge);
  }

  switch (q.sort) {
    case 'السعر: من الأقل':
      ref = ref.orderBy('price').orderBy('createdAt', descending: true);
      break;
    case 'السعر: من الأعلى':
      ref = ref.orderBy('price', descending: true).orderBy('createdAt', descending: true);
      break;
    case 'الأعلى تقييماً':
      ref = ref.orderBy('avgRating', descending: true).orderBy('createdAt', descending: true);
      break;
    case 'الأحدث':
    default:
      ref = ref.orderBy('createdAt', descending: true);
  }

  return ref.limit(q.limit);
}
