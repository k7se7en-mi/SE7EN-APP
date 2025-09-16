import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'order_model.dart';

class OrdersRepo {
  final _db = FirebaseFirestore.instance;
  String get _uid => FirebaseAuth.instance.currentUser!.uid;
  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('orders').doc(_uid).collection('userOrders');

  Stream<List<UserOrder>> streamMyOrders({int limit = 50}) {
    return _col
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((s) => s.docs.map(_fromDoc).toList());
  }

  Future<UserOrder?> getById(String id) async {
    final d = await _col.doc(id).get();
    if (!d.exists) return null;
    return _fromDoc(d);
  }

  UserOrder _fromDoc(DocumentSnapshot<Map<String, dynamic>> d) {
    final m = d.data() ?? {};
    DateTime created;
    final ts = m['createdAt'];
    if (ts is Timestamp) {
      created = ts.toDate();
    } else if (ts is DateTime) {
      created = ts;
    } else {
      created = DateTime.now();
    }
    final items = (m['items'] as List? ?? [])
        .map((e) => OrderItemLine.fromMap((e as Map).cast<String, dynamic>()))
        .toList();

    final addr = (m['address'] as Map?)?.cast<String, dynamic>() ?? {};
    return UserOrder(
      id: d.id,
      userId: (m['userId'] ?? '').toString(),
      createdAt: created,
      paymentMethod: (m['paymentMethod'] ?? 'COD').toString(),
      status: (m['status'] ?? 'pending').toString(),
      subTotal: (m['subTotal'] as num).toDouble(),
      vat: (m['vat'] as num).toDouble(),
      codFee: (m['codFee'] as num?)?.toDouble() ?? 0,
      total: (m['total'] as num).toDouble(),
      addressId: (m['addressId'] as String?),
      name: (addr['name'] ?? '').toString(),
      phone: (addr['phone'] ?? '').toString(),
      city: (addr['city'] ?? '').toString(),
      details: (addr['details'] ?? '').toString(),
      items: items,
    );
  }
}