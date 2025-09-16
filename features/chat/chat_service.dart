import 'package:cloud_firestore/cloud_firestore.dart';

class ChatService {
  ChatService._();
  static final instance = ChatService._();

  /// إنشاء أو جلب محادثة بين العميل والبائع
  Future<DocumentReference<Map<String, dynamic>>> getOrCreateChat({
    required String customerId,
    required String sellerId,
    String? orderId,
    Map<String, dynamic>? extraMeta,
  }) async {
    final chats = FirebaseFirestore.instance.collection('chats');

    // نبحث عن محادثة سابقة بين نفس العميل والبائع
    final q = await chats
        .where('participants', arrayContains: customerId)
        .where('meta.sellerId', isEqualTo: sellerId)
        .limit(1)
        .get();

    if (q.docs.isNotEmpty) return q.docs.first.reference;

    final ref = chats.doc();
    await ref.set({
      'participants': [customerId, sellerId],
      'lastMessage': '',
      'lastSender': null,
      'updatedAt': FieldValue.serverTimestamp(),
      'unread': {customerId: 0, sellerId: 0},
      'typing': {customerId: false, sellerId: false},
      'meta': {
        'sellerId': sellerId,
        'customerId': customerId,
        if (orderId != null) 'orderId': orderId,
        if (extraMeta != null) ...extraMeta,
      },
    });
    return ref;
  }
}
