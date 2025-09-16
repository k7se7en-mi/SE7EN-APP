import 'package:cloud_firestore/cloud_firestore.dart';

/// نموذج المراجعة/التقييم
class ReviewItem {
  final String id;
  final String userId;
  final String userName;
  final double rating;       // 0..5
  final String comment;      // اختياري
  final DateTime createdAt;

  ReviewItem({
    required this.id,
    required this.userId,
    required this.userName,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  factory ReviewItem.fromDoc(DocumentSnapshot<Map<String, dynamic>> d) {
    final m = d.data()!;
    DateTime created;
    final ts = m['createdAt'];
    if (ts is Timestamp) {
      created = ts.toDate();
    } else if (ts is DateTime) {
      created = ts;
    } else {
      created = DateTime.now();
    }
    return ReviewItem(
      id: d.id,
      userId: (m['userId'] ?? '').toString(),
      userName: (m['userName'] ?? 'مستخدم').toString(),
      rating: (m['rating'] ?? 0).toDouble(),
      comment: (m['comment'] ?? '').toString(),
      createdAt: created,
    );
  }

  Map<String, dynamic> toMap() => {
        'userId': userId,
        'userName': userName,
        'rating': rating,
        'comment': comment,
        'createdAt': FieldValue.serverTimestamp(),
      };
}

/// واجهة المستودع
abstract class ReviewRepo {
  /// بث التعليقات لمنتج معيّن (الأحدث أولاً)
  Stream<List<ReviewItem>> streamReviews(String productId, {int limit = 50});

  /// إضافة مراجعة + تحديث متوسط التقييم وعدد المراجعات على مستند المنتج ضمن معاملة (Transaction)
  Future<void> addReview({
    required String productId,
    required String userId,
    required String userName,
    required double rating,
    String comment = '',
  });
}

/// تنفيذ Firestore
class FirestoreReviewRepo implements ReviewRepo {
  final FirebaseFirestore _db;
  FirestoreReviewRepo({FirebaseFirestore? db}) : _db = db ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _productCol() => _db.collection('products');

  @override
  Stream<List<ReviewItem>> streamReviews(String productId, {int limit = 50}) {
    final ref = _productCol()
        .doc(productId)
        .collection('reviews')
        .orderBy('createdAt', descending: true)
        .limit(limit);
    return ref.snapshots().map((s) => s.docs.map((d) => ReviewItem.fromDoc(d)).toList());
  }

  @override
  Future<void> addReview({
    required String productId,
    required String userId,
    required String userName,
    required double rating,
    String comment = '',
  }) async {
    if (rating < 0 || rating > 5) {
      throw ArgumentError('التقييم يجب أن يكون بين 0 و 5');
    }

    final productRef = _productCol().doc(productId);
    final reviewsRef = productRef.collection('reviews').doc(); // id عشوائي

    await _db.runTransaction((tx) async {
      // 1) أضف مراجعة
      tx.set(reviewsRef, {
        'userId': userId,
        'userName': userName,
        'rating': rating,
        'comment': comment,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // 2) حدّث ملخص المنتج (avgRating, reviewsCount) بصورة تراكمية
      final snap = await tx.get(productRef);
      final data = snap.data() ?? <String, dynamic>{};
      final curAvg = (data['avgRating'] ?? data['rating'] ?? 0).toDouble();
      final curCount = (data['reviewsCount'] ?? data['reviews'] ?? 0) is int
          ? (data['reviewsCount'] ?? data['reviews'] ?? 0) as int
          : int.tryParse((data['reviewsCount'] ?? data['reviews'] ?? '0').toString()) ?? 0;

      final newCount = curCount + 1;
      final newAvg = newCount == 0 ? 0 : ((curAvg * curCount) + rating) / newCount;

      tx.set(
        productRef,
        {
          'avgRating': double.parse(newAvg.toStringAsFixed(3)), // تقليل الضجيج
          'reviewsCount': newCount,
        },
        SetOptions(merge: true),
      );
    });
  }
}
