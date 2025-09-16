// lib/services/products_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart'; // تأكد من المسار

class ProductsService {
  final _db = FirebaseFirestore.instance;

  // بث مباشر للواجهة الرئيسية
  Stream<List<Product>> streamLatest({int limit = 50}) {
    return _db.collection('products')
      .orderBy('createdAt', descending: true)
      .limit(limit)
      .snapshots()
      .map((s) => s.docs.map((d) => Product.fromMap(d.id, d.data())).toList());
  }

  // جلب مرة واحدة (لو تحتاجه للبحث/الفلاتر)
  Future<List<Product>> fetchLatest({int limit = 50}) async {
    final q = await _db.collection('products')
      .orderBy('createdAt', descending: true)
      .limit(limit)
      .get();
    return q.docs.map((d) => Product.fromMap(d.id, d.data())).toList();
  }
}