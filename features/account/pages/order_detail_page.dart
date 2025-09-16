// ignore_for_file: prefer_const_declarations

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

// ✅ عدّل المسار حسب مشروعك
import '/features/chat/widgets/contact_seller_button.dart';

class OrderDetailPage extends StatelessWidget {
  final String orderId;
  const OrderDetailPage({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    final ref = FirebaseFirestore.instance.collection('orders').doc(orderId);

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: ref.snapshots(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (!snap.hasData || !snap.data!.exists) {
          return const Scaffold(
            body: Center(child: Text('الطلب غير موجود')),
          );
        }

        final m = snap.data!.data()!;
        final sellerId = (m['sellerId'] ?? '').toString();
        final status = (m['status'] ?? 'processing').toString();
        final total = _asNum(m['total']).toStringAsFixed(2);
        final createdAt = _formatTs(m['createdAt']);
        final items = (m['items'] as List?) ?? const [];
        final address = (m['address'] as Map?) ?? const {};

        return Scaffold(
          appBar: AppBar(title: Text('تفاصيل الطلب #${orderId.substring(0, 6)}')),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _SectionCard(
                title: 'الملخّص',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _kv('الحالة', _arabicStatus(status)),
                    _kv('الإجمالي', '$total ر.س'),
                    _kv('تاريخ الإنشاء', createdAt ?? '—'),
                    if (m['sellerName'] != null)
                      _kv('التاجر', m['sellerName'].toString()),
                    if (m['paymentMethod'] != null)
                      _kv('الدفع', m['paymentMethod'].toString()),
                    if (m['orderNote'] != null && m['orderNote'].toString().isNotEmpty)
                      _kv('ملاحظة', m['orderNote'].toString()),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              _SectionCard(
                title: 'العنوان',
                child: Text(_formatAddress(address)),
              ),
              const SizedBox(height: 12),

              _SectionCard(
                title: 'العناصر (${items.length})',
                child: Column(
                  children: items.isEmpty
                      ? [const Text('لا توجد عناصر')]
                      : items.map((e) => _ItemTile(map: (e as Map).cast())).toList(),
                ),
              ),
              const SizedBox(height: 12),

              _SectionCard(
                title: 'تتبّع الحالة',
                child: _StatusTimeline(current: status),
              ),
              const SizedBox(height: 80), // مساحة تحت للزر السفلي
            ],
          ),

          // زر الدردشة بأسفل الصفحة
          bottomNavigationBar: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: sellerId.isNotEmpty
                  ? ContactSellerButton(
                      sellerId: sellerId,
                      orderId: orderId,
                      label: 'دردشة مع التاجر',
                      icon: Icons.chat_bubble_outline,
                      style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                    )
                  : FilledButton.icon(
                      onPressed: null,
                      icon: const Icon(Icons.chat_bubble_outline),
                      label: const Text('لا يمكن فتح الدردشة (لا يوجد sellerId)'),
                    ),
            ),
          ),
        );
      },
    );
  }

  static double _asNum(dynamic v) {
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v) ?? 0;
    return 0;
  }

  static String? _formatTs(dynamic ts) {
    try {
      if (ts is Timestamp) return DateFormat('yyyy/MM/dd • HH:mm').format(ts.toDate());
      if (ts is DateTime) return DateFormat('yyyy/MM/dd • HH:mm').format(ts);
      return null;
    } catch (_) {
      return null;
    }
  }

  static String _formatAddress(Map addr) {
    final parts = [
      addr['label'],
      addr['city'],
      addr['district'],
      addr['street'],
      addr['building'],
      addr['postalCode'],
      addr['country'],
    ].where((e) => e != null && e.toString().isNotEmpty).map((e) => e.toString()).toList();
    return parts.isEmpty ? '—' : parts.join('، ');
  }

  static String _arabicStatus(String s) {
    switch (s) {
      case 'processing': return 'قيد المعالجة';
      case 'shipped': return 'شُحن';
      case 'out_for_delivery': return 'في طريقه للتسليم';
      case 'delivered': return 'تم التسليم';
      case 'cancelled': return 'أُلغي';
      default: return s;
    }
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            child,
          ],
        ),
      ),
    );
  }
}

class _ItemTile extends StatelessWidget {
  final Map<String, dynamic> map;
  const _ItemTile({required this.map});

  @override
  Widget build(BuildContext context) {
    final name = (map['name'] ?? map['title'] ?? 'عنصر').toString();
    final qty = (map['qty'] ?? 1).toString();
    final price = OrderDetailPage._asNum(map['price']).toStringAsFixed(2);
    final total = (OrderDetailPage._asNum(map['price']) * (double.tryParse(qty) ?? 1))
        .toStringAsFixed(2);
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.check_box_outline_blank),
      title: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text('الكمية: $qty • السعر: $price ر.س'),
      trailing: Text(total),
      onTap: () {
        // TODO: فتح تفاصيل المنتج إن توفر productId
      },
    );
  }
}

// عنصر مساعد لعرض زوج (عنوان: قيمة) بدون تعديل على استدعاءاته
Widget _kv(String label, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.start,
            overflow: TextOverflow.visible,
          ),
        ),
      ],
    ),
  );
}

class _StatusTimeline extends StatelessWidget {
  final String current;
  const _StatusTimeline({required this.current});

  @override
  Widget build(BuildContext context) {
    final steps = const [
      ['processing', 'قيد المعالجة', Icons.pending_outlined],
      ['shipped', 'شُحن', Icons.local_shipping_outlined],
      ['out_for_delivery', 'في الطريق', Icons.delivery_dining],
      ['delivered', 'تم التسليم', Icons.check_circle_outline],
    ];

    int currentIndex = steps.indexWhere((e) => e[0] == current);
    if (current == 'cancelled') currentIndex = -1;

    return Column(
      children: [
        if (current == 'cancelled')
          const ListTile(
            leading: Icon(Icons.cancel_outlined, color: Colors.red),
            title: Text('أُلغي'),
          )
        else
          ...List.generate(steps.length, (i) {
            final done = i <= currentIndex;
            return ListTile(
              leading: Icon(
                steps[i][2] as IconData,
                color: done ? Colors.green : null,
              ),
              title: Text(steps[i][1] as String,
                  style: TextStyle(
                    fontWeight: done ? FontWeight.w600 : FontWeight.normal,
                    color: done ? Colors.green : null,
                  )),
            );
          }),
      ],
    );
  }
}
