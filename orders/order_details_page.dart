import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/theme/app_colors.dart';
import '../core/widgets/glass_container.dart';
import 'package:se7en/features/home/data/order_model.dart';
import 'package:se7en/features/home/data/orders_repo.dart';

class OrderDetailsPage extends StatelessWidget {
  final String orderId;
  OrderDetailsPage({super.key, required this.orderId});

  final _repo = OrdersRepo();
  final _fmt = DateFormat('yyyy/MM/dd  HH:mm');

  Color _statusColor(String s) {
    switch (s) {
      case 'paid': return Colors.green;
      case 'shipped': return Colors.blueAccent;
      case 'delivered': return Colors.teal;
      case 'canceled': return Colors.redAccent;
      case 'pending_payment': return Colors.orange;
      case 'pending_cod':
      default: return Colors.amber;
    }
  }

  String _payLabel(String p) {
    switch (p) {
      case 'COD': return 'عند الاستلام';
      case 'TAMARA': return 'تمارا';
      case 'TABBY': return 'تابي';
      case 'APPLE': return 'Apple Pay';
      case 'SAMSUNG': return 'Samsung Pay';
      case 'STCPAY': return 'STC Pay';
      case 'CARD': return 'بطاقة';
      default: return p;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: Directionality.of(context),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('تفاصيل الطلب'),
          flexibleSpace: Container(decoration: const BoxDecoration(gradient: AppColors.appBgGradient)),
        ),
        body: FutureBuilder<UserOrder?>(
          future: _repo.getById(orderId),
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final o = snap.data;
            if (o == null) {
              return const Center(child: Text('الطلب غير موجود'));
            }

            return ListView(
              padding: const EdgeInsets.all(12),
              children: [
                GlassContainer(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text('#${o.id}'),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: _statusColor(o.status).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(o.status, style: TextStyle(color: _statusColor(o.status))),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(_fmt.format(o.createdAt), style: const TextStyle(color: Colors.white70, fontSize: 12)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.payment, size: 18, color: Colors.white70),
                          const SizedBox(width: 6),
                          Text(_payLabel(o.paymentMethod)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // العنوان
                GlassContainer(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('العنوان', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      Text(o.name),
                      Text(o.phone),
                      Text('${o.city} — ${o.details}'),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // العناصر
                GlassContainer(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('العناصر', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      for (final it in o.items) ...[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(it.imageUrl, width: 64, height: 64, fit: BoxFit.cover),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(it.title, maxLines: 2, overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 4),
                                  Text('الكمية: ${it.qty}'),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text('${it.lineTotal.toStringAsFixed(0)} ر.س'),
                          ],
                        ),
                        const Divider(height: 16),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // المبالغ
                GlassContainer(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      _row('المجموع الفرعي', '${o.subTotal.toStringAsFixed(0)} ر.س'),
                      _row('ضريبة القيمة المضافة (15%)', '${o.vat.toStringAsFixed(0)} ر.س'),
                      if (o.codFee > 0) _row('رسوم الاستلام', '${o.codFee.toStringAsFixed(0)} ر.س'),
                      const Divider(height: 16),
                      _row('الإجمالي', '${o.total.toStringAsFixed(0)} ر.س', isBold: true),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _row(String a, String b, {bool isBold = false}) {
    final st = TextStyle(fontWeight: isBold ? FontWeight.w700 : FontWeight.w400);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(children: [Text(a, style: st), const Spacer(), Text(b, style: st)]),
    );
  }
}
