import 'package:cloud_firestore/cloud_firestore.dart';
import 'review_repo.dart';

/// مزوّد Singleton بسيط للوصول إلى الريبو من أي مكان
class ReviewProvider {
  ReviewProvider._internal();

  static final ReviewRepo _instance =
      FirestoreReviewRepo(db: FirebaseFirestore.instance);

  /// استدعِها من الصفحات: `final repo = ReviewProvider.of();`
  static ReviewRepo of() => _instance;
}