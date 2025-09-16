import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../chat_room_page.dart';

/// helper: إنشاء/جلب محادثة بين العميل والبائع
Future<DocumentReference<Map<String, dynamic>>> getOrCreateChat({
  required String customerId,
  required String sellerId,
  String? orderId,
}) async {
  final chats = FirebaseFirestore.instance.collection('chats');

  // نبحث عن محادثة بين نفس العميل والبائع
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
    'unread': { customerId: 0, sellerId: 0 },
    'typing': { customerId: false, sellerId: false },
    'meta': {
      'sellerId': sellerId,
      'customerId': customerId,
      if (orderId != null) 'orderId': orderId,
    },
  });
  return ref;
}

/// زر تواصل مع التاجر.
/// استخدمه أينما توفر sellerId (من مستند المنتج/الطلب…)
class ContactSellerButton extends StatefulWidget {
  final String sellerId;
  final String? orderId;
  final String label;     // النص على الزر (مثلاً: تواصل مع التاجر)
  final IconData icon;    // الأيقونة (افتراض: chat)
  final ButtonStyle? style;

  const ContactSellerButton({
    super.key,
    required this.sellerId,
    this.orderId,
    this.label = 'تواصل مع التاجر',
    this.icon = Icons.chat,
    this.style,
  });

  @override
  State<ContactSellerButton> createState() => _ContactSellerButtonState();
}

class _ContactSellerButtonState extends State<ContactSellerButton> {
  bool _loading = false;

  Future<void> _openChat() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء تسجيل الدخول أولاً')),
      );
      return;
    }
    try {
      setState(() => _loading = true);
      final ref = await getOrCreateChat(
        customerId: user.uid,
        sellerId: widget.sellerId,
        orderId: widget.orderId,
      );
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatRoomPage(chatRef: ref, peerId: widget.sellerId),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تعذر فتح المحادثة: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: _loading ? null : _openChat,
      style: widget.style,
      icon: _loading
          ? const SizedBox(
              width: 18, height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Icon(widget.icon),
      label: Text(_loading ? 'جارٍ الفتح...' : widget.label),
    );
  }
}