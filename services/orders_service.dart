// lib/services/orders_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OrdersService {
  final _db = FirebaseFirestore.instance;

  Future<String> placeOrder({
    required List<Map<String, dynamic>> items, // [{productId,title,price,qty,imageUrl}]
    required double total,
    String currency = 'SAR',
    String status = 'pending',
    Map<String, dynamic>? shippingAddress,
  }) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final doc = await _db.collection('orders').add({
      'userId': uid,
      'items': items,
      'total': total,
      'currency': currency,
      'status': status, // pending / paid / shipped / delivered
      'createdAt': FieldValue.serverTimestamp(),
      if (shippingAddress != null) 'shipping': shippingAddress,
    });

    return doc.id;
  }

  Stream<List<Map<String, dynamic>>> streamMyOrders() {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return _db.collection('orders')
      .where('userId', isEqualTo: uid)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((s) => s.docs.map((d) => {'id': d.id, ...d.data()}).toList());
  }
}