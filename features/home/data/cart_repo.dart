import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'cart_item_model.dart';

const double kVatRate = 0.15;   // 15%
const double kCodFee  = 19.0;   // رسوم الدفع عند الاستلام

class CartRepo {
  final _db = FirebaseFirestore.instance;
  String get _uid => FirebaseAuth.instance.currentUser!.uid;
  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('carts').doc(_uid).collection('items');

  Stream<List<CartItem>> streamItems() {
    return _col.snapshots().map((s) => s.docs.map((d) => CartItem.fromMap(d.data())).toList());
  }

  Future<void> addOrInc({
    required String productId,
    required String title,
    required String imageUrl,
    required double price,
    int qty = 1,
  }) async {
    final doc = _col.doc(productId);
    await _db.runTransaction((tx) async {
      final snap = await tx.get(doc);
      if (!snap.exists) {
        tx.set(doc, CartItem(productId: productId, title: title, imageUrl: imageUrl, price: price, qty: qty).toMap());
      } else {
        final cur = CartItem.fromMap(snap.data()!);
        tx.update(doc, {'qty': cur.qty + qty});
      }
    });
  }

  Future<void> updateQty(String productId, int qty) async {
    if (qty <= 0) {
      await remove(productId);
    } else {
      await _col.doc(productId).update({'qty': qty});
    }
  }

  Future<void> remove(String productId) => _col.doc(productId).delete();
  Future<void> clear() async {
    final batch = _db.batch();
    final docs = await _col.get();
    for (final d in docs.docs) { batch.delete(d.reference); }
    await batch.commit();
  }

  // حساب المجاميع
  Future<({double subTotal, double vat, double totalBase})> totalsOnce() async {
    final docs = await _col.get();
    final items = docs.docs.map((d) => CartItem.fromMap(d.data())).toList();
    final sub = items.fold<double>(0, (p, e) => p + e.lineTotal);
    final vat  = sub * kVatRate;
    final totalBase = sub + vat;
    return (subTotal: sub, vat: vat, totalBase: totalBase);
  }
}
