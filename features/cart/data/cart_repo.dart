// lib/features/cart/data/cart_repo.dart
// تهيئة نسخة محلية خفيفة للسلة تتوافق مع الصفحات دون تعديلها.
import 'dart:async';
import 'cart_item_model.dart';

class CartRepo {
  CartRepo._();
  static final CartRepo _instance = CartRepo._();
  factory CartRepo() => _instance; // يضمن Singleton حتى عند الاستدعاء بـ CartRepo()

  final List<CartItem> _items = [];
  final StreamController<List<CartItem>> _ctrl = StreamController.broadcast();

  // تُستخدم في الصفحات كـ cartRepo.streamItems?.call()
  // نعيد دالة غير null لكن الموقّع قابل للإلغاء حتى لا نعدّل الصفحات.
  Stream<List<CartItem>> Function()? get streamItems => () => _ctrl.stream;

  List<CartItem> get items => List.unmodifiable(_items);

  void _emit() {
    if (!_ctrl.isClosed) {
      // أرسل نسخة غير قابلة للتعديل
      _ctrl.add(List.unmodifiable(_items));
    }
  }

  /// إضافة منتج إلى السلة (تجميعي)
  void addToCart(CartItem item) {
    final index = _items.indexWhere((i) => i.id == item.id);
    if (index >= 0) {
      final existing = _items[index];
      _items[index] = existing.copyWith(qty: existing.qty + item.qty);
    } else {
      _items.add(item);
    }
    _emit();
  }

  /// واجهة متوافقة مع الصفحات الأخرى (تطابق Firestore النسخة)
  Future<void> addOrInc({
    required String productId,
    required String title,
    required String imageUrl,
    required double price,
    int qty = 1,
  }) async {
    final index = _items.indexWhere((i) => i.id == productId);
    if (index >= 0) {
      final existing = _items[index];
      _items[index] = existing.copyWith(qty: existing.qty + qty);
    } else {
      _items.add(CartItem(id: productId, title: title, price: price, qty: qty, imageUrl: imageUrl));
    }
    _emit();
  }

  /// إزالة منتج تمامًا
  bool removeFromCart(String productId) {
    final before = _items.length;
    _items.removeWhere((i) => i.id == productId);
    final changed = _items.length != before;
    if (changed) _emit();
    return changed;
  }

  /// تماشيًا مع بعض الصفحات التي تستدعي remove
  bool remove(String productId) => removeFromCart(productId);

  /// تحديث كمية منتج (تزيد/تنقص)
  void updateQty(String productId, int qty) {
    final index = _items.indexWhere((i) => i.id == productId);
    if (index >= 0) {
      if (qty <= 0) {
        _items.removeAt(index);
      } else {
        _items[index] = _items[index].copyWith(qty: qty);
      }
      _emit();
    }
  }

  /// إفراغ السلة
  void clear() {
    _items.clear();
    _emit();
  }

  double get total => _items.fold(0.0, (sum, i) => sum + (i.price * i.qty));
  int get count => _items.fold(0, (sum, i) => sum + i.qty);
}

// نسخة مشتركة للوصول المباشر كما هو مستخدم في الصفحات
final cartRepo = CartRepo();
