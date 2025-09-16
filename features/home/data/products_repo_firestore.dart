// ignore_for_file: unnecessary_brace_in_string_interps

import 'package:cloud_firestore/cloud_firestore.dart';
import 'product_model.dart';
import 'products_repo.dart';

class ProductsRepoFirestore implements ProductsRepo {
  final _db = FirebaseFirestore.instance;

  // ملاحظة: يمكنك تخزين الأقسام في الحقل section أو إنشاء mapping بالواجهة
  CollectionReference<Map<String, dynamic>> get _col => _db.collection('products');

  @override
  Stream<List<Product>> streamSection(ProductQuery q) {
    Query<Map<String, dynamic>> ref = _col;

    // بحث نصي بسيط (prefix) باستعمال searchable (lowercase)
    if (q.search != null && q.search!.trim().isNotEmpty) {
      final s = q.search!.trim().toLowerCase();
      // يتطلب وجود حقل searchable يبدأ بالكلمة (يمكنك أيضا استخدام Algolia لاحقا)
      ref = ref
        .where('searchable', isGreaterThanOrEqualTo: s)
        .where('searchable', isLessThan: '${s}\uf8ff');
    }

    if (q.category != null && q.category!.isNotEmpty) {
      ref = ref.where('category', isEqualTo: q.category);
    }

    if (q.minRating != null) {
      ref = ref.where('rating', isGreaterThanOrEqualTo: q.minRating);
    }

    // نطاق السعر (يتطلب فهرس مركب غالبًا)
    if (q.minPrice != null) ref = ref.where('price', isGreaterThanOrEqualTo: q.minPrice);
    if (q.maxPrice != null) ref = ref.where('price', isLessThanOrEqualTo: q.maxPrice);

    // ترتيب
    switch (q.sort) {
      case 'الأرخص':
        ref = ref.orderBy('price', descending: false);
        break;
      case 'الأغلى':
        ref = ref.orderBy('price', descending: true);
        break;
      case 'الأعلى تقييماً':
        ref = ref.orderBy('rating', descending: true).orderBy('reviews', descending: true);
        break;
      case 'الأحدث':
      default:
        ref = ref.orderBy('createdAt', descending: true);
    }

    ref = ref.limit(q.limit);

    return ref.snapshots().map((snap) =>
        snap.docs.map((d) => Product.fromMap(d.id, d.data())).toList());
  }
}
