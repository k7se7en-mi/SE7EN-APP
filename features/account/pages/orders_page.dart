import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:se7en/core/localization/l10n.dart';

// أضف الودجت القابل لإعادة الاستخدام
import '/features/chat/widgets/contact_seller_button.dart'; // عدّل المسار حسب مشروعك

class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final u = FirebaseAuth.instance.currentUser!;
    final q = FirebaseFirestore.instance
        .collection('orders')
        .where('uid', isEqualTo: u.uid)
        .orderBy('createdAt', descending: true);

    return Scaffold(
      appBar: AppBar(title: Text(L.of(context, 'my_orders'))),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: q.snapshots(),
        builder: (_, s) {
          if (s.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = s.data?.docs ?? [];
          if (docs.isEmpty) {
            return Center(child: Text(L.of(context, 'no_orders')));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (_, i) {
              final m = docs[i].data();
              final orderId = docs[i].id;
              final status = (m['status'] ?? 'processing').toString();
              final total = (m['total'] ?? 0).toString();
              final sellerId = (m['sellerId'] ?? '').toString(); // ← مهم

              return Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  title: Text('طلب #${orderId.substring(0, 6)}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('الحالة: $status • الإجمالي: $total ر.س'),
                      if ((m['items'] is List) && (m['items'] as List).isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text('عناصر: ${(m['items'] as List).length}'),
                      ],
                    ],
                  ),
                  // زر تواصل مع التاجر في كل طلب
                  trailing: (sellerId.isNotEmpty)
                      ? ContactSellerButton(
                          sellerId: sellerId,
                          orderId: orderId,
                          label: 'دردشة',
                          icon: Icons.chat_bubble_outline,
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            minimumSize: const Size(0, 36),
                          ),
                        )
                      : const Tooltip(
                          message: 'لا يوجد معرف تاجر في هذا الطلب',
                          child: Icon(Icons.chat_bubble_outline, color: Colors.grey),
                        ),
                  onTap: () {
                    // TODO: افتح صفحة تفاصيل الطلب
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
