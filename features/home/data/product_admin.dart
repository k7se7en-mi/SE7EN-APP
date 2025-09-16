// lib/features/home/data/product_admin.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class ProductAdmin {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('products');

  /// يضيف منتجًا واحدًا بالحقول القياسية
  Future<String> addProduct({
    required String title,
    required String sellerName,
    String? sellerId,
    required String category,
    required String imageUrl,
    required double price,
    double? oldPrice,
    required double rating,
    required int reviews,
    List<String> keywords = const [], // كلمات بحث إضافية (اختياري)
  }) async {
    _assert(price >= 0, 'السعر يجب أن يكون رقمًا موجبًا');
    _assert(rating >= 0 && rating <= 5, 'التقييم بين 0 و 5');
    _assert(reviews >= 0, 'عدد المقيّمين لا يمكن أن يكون سالبًا');

    final cleanTitle = _clean(title);
    final cleanSeller = _clean(sellerName);
    final cleanCat = _clean(category);

    final data = <String, dynamic>{
      'title': cleanTitle,
      'sellerName': cleanSeller,
      'sellerId': sellerId?.trim(),
      'category': cleanCat,
      'imageUrl': imageUrl.trim(),
      'price': price,
      'oldPrice': oldPrice,
      'rating': rating,
      'reviews': reviews,
      'createdAt': FieldValue.serverTimestamp(), // ✅
      'searchable': _buildSearchable(
        title: cleanTitle,
        seller: cleanSeller,
        category: cleanCat,
        keywords: keywords,
      ), // ✅
    };

    final doc = await _col.add(data);
    return doc.id;
  }

  /// يعدّل منتجًا موجودًا (مرّر فقط الحقول التي تريد تغييرها)
  Future<void> updateProduct(
    String productId, {
    String? title,
    String? sellerName,
    String? sellerId,
    String? category,
    String? imageUrl,
    double? price,
    double? oldPrice,
    double? rating,
    int? reviews,
    List<String>? keywords,
  }) async {
    final updates = <String, dynamic>{};

    if (title != null) updates['title'] = _clean(title);
    if (sellerName != null) updates['sellerName'] = _clean(sellerName);
    if (sellerId != null) updates['sellerId'] = sellerId.trim().isEmpty ? null : sellerId.trim();
    if (category != null) updates['category'] = _clean(category);
    if (imageUrl != null) updates['imageUrl'] = imageUrl.trim();
    if (price != null) {
      _assert(price >= 0, 'السعر يجب أن يكون رقمًا موجبًا');
      updates['price'] = price;
    }
    if (oldPrice != null) updates['oldPrice'] = oldPrice;
    if (rating != null) {
      _assert(rating >= 0 && rating <= 5, 'التقييم بين 0 و 5');
      updates['rating'] = rating;
    }
    if (reviews != null) {
      _assert(reviews >= 0, 'عدد المقيّمين لا يمكن أن يكون سالبًا');
      updates['reviews'] = reviews;
    }

    // حدّث searchable لو تغيّر العنوان/البائع/الفئة/الكلمات
    if (title != null || sellerName != null || category != null || keywords != null) {
      final snap = await _col.doc(productId).get();
      final cur = snap.data() ?? {};
      final t = _clean(title ?? (cur['title'] ?? ''));
      final s = _clean(sellerName ?? (cur['sellerName'] ?? ''));
      final c = _clean(category ?? (cur['category'] ?? ''));
      final extra = keywords ?? <String>[];
      updates['searchable'] = _buildSearchable(
        title: t, seller: s, category: c, keywords: extra,
      );
    }

    if (updates.isNotEmpty) {
      await _col.doc(productId).set(updates, SetOptions(merge: true));
    }
  }

  /// يحذف منتجًا
  Future<void> deleteProduct(String productId) async {
    await _col.doc(productId).delete();
  }

  /// إدخال دفعة عيّنات (Batch)
  Future<void> addSampleProducts(List<Map<String, dynamic>> items) async {
    final batch = _db.batch();
    for (final m in items) {
      final doc = _col.doc();

      final title = _clean(m['title'] as String? ?? '');
      final seller = _clean(m['sellerName'] as String? ?? '');
      final category = _clean(m['category'] as String? ?? '');
      final imageUrl = (m['imageUrl'] as String? ?? '').trim();
      final price = (m['price'] as num).toDouble();
      final oldPrice = (m['oldPrice'] as num?)?.toDouble();
      final rating = (m['rating'] as num).toDouble();
      final reviews = (m['reviews'] as num).toInt();
      final sellerId = (m['sellerId'] as String?)?.trim();
      final keywords = (m['keywords'] as List?)?.map((e) => e.toString()).toList() ?? const <String>[];

      _assert(price >= 0, 'السعر يجب أن يكون رقمًا موجبًا');
      _assert(rating >= 0 && rating <= 5, 'التقييم بين 0 و 5');
      _assert(reviews >= 0, 'عدد المقيّمين لا يمكن أن يكون سالبًا');

      final data = <String, dynamic>{
        'title': title,
        'sellerName': seller,
        'sellerId': sellerId,
        'category': category,
        'imageUrl': imageUrl,
        'price': price,
        'oldPrice': oldPrice,
        'rating': rating,
        'reviews': reviews,
        'createdAt': FieldValue.serverTimestamp(),
        'searchable': _buildSearchable(
          title: title, seller: seller, category: category, keywords: keywords),
      };

      batch.set(doc, data);
    }
    await batch.commit();
  }

  // ----------------- أدوات مساعدة -----------------

  String _buildSearchable({
    required String title,
    required String seller,
    required String category,
    List<String> keywords = const [],
  }) {
    final parts = <String>[
      title, seller, category, ...keywords,
    ]
        .where((e) => e.trim().isNotEmpty)
        .map((e) => e.toLowerCase().trim())
        .toList();
    // إزالة تكرارات وتوحيد المسافات
    return parts.join(' ').replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  String _clean(String v) => v.replaceAll(RegExp(r'\s+'), ' ').trim();

  Never _assert(bool cond, String msg) {
    if (!cond) {
      // ترمي خطأ واضح عند الاستخدام الخاطئ
      throw ArgumentError(msg);
    }
    // Dart يحتاج نوع Never ليعرف أننا ما نرجع قيمة
    throw StateError('Unreachable');
  }
}
// ignore_for_file: dead_code
