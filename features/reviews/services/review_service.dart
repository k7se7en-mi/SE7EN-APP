import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/review.dart';

class ReviewService {
  final _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _reviewsCol(String productId) =>
      _db.collection('products').doc(productId).collection('reviews');

  DocumentReference<Map<String, dynamic>> _productDoc(String productId) =>
      _db.collection('products').doc(productId);

  Stream<List<Review>> streamReviews(String productId, {int limit = 50}) {
    return _reviewsCol(productId)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => Review.fromMap(d.id, d.data()))
            .toList());
  }

  /// يضيف مراجعة ويحدّث المتوسط والعدد داخل Transaction
  Future<void> addReview({
    required String productId,
    required String userName,
    required double rating,
    required String comment,
    String userId = 'guest',
  }) async {
    final prodRef = _productDoc(productId);
    final reviewsRef = _reviewsCol(productId).doc();

    await _db.runTransaction((tx) async {
      final prodSnap = await tx.get(prodRef);

      double avg = 0;
      int cnt = 0;

      if (prodSnap.exists) {
        avg = (prodSnap.data()?['avgRating'] ?? 0).toDouble();
        cnt = (prodSnap.data()?['reviewsCount'] ?? 0) as int;
      }

      // المتوسط الجديد
      final newCount = cnt + 1;
      final newAvg = ((avg * cnt) + rating) / newCount;

      // اكتب المراجعة
      tx.set(reviewsRef, {
        'productId': productId,
        'userId': userId,
        'userName': userName.trim().isEmpty ? 'مستخدم' : userName.trim(),
        'rating': rating,
        'comment': comment.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      // حدّث ملخص المنتج
      tx.set(prodRef, {
        'avgRating': newAvg,
        'reviewsCount': newCount,
      }, SetOptions(merge: true));
    });
  }

  /// يجلب الملخص (متوسط + عدد)
  Stream<Map<String, dynamic>> streamProductSummary(String productId) {
    return _productDoc(productId).snapshots().map((snap) {
      final d = snap.data() ?? {};
      return {
        'avgRating': (d['avgRating'] ?? 0).toDouble(),
        'reviewsCount': (d['reviewsCount'] ?? 0) as int,
      };
    });
  }
}