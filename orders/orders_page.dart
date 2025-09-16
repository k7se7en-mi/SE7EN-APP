// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/theme/app_colors.dart';
import '../core/widgets/glass_container.dart';
import 'package:se7en/core/localization/l10n.dart';
import 'package:se7en/features/home/data/cart_repo.dart';
import 'package:se7en/features/home/data/order_model.dart';
import 'package:se7en/features/home/data/orders_repo.dart';
import 'order_details_page.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  final _repo = OrdersRepo();
  final _fmt = DateFormat('yyyy/MM/dd  HH:mm');

  // فلترة
  final _statuses = const <String>[
    'الكل', 'pending_cod', 'pending_payment', 'paid', 'shipped', 'delivered', 'canceled'
  ];
  String _status = 'الكل';
  DateTimeRange? _range;

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

  // فلترة محلية بعد الجلب (أبسط وأسرع الآن)
  List<UserOrder> _applyFilters(List<UserOrder> src) {
    var list = src;
    if (_status != 'الكل') {
      list = list.where((o) => o.status == _status).toList();
    }
    if (_range != null) {
      final s = _range!.start;
      final e = _range!.end.add(const Duration(days: 1)); // تضمين اليوم الأخير
      list = list.where((o) => o.createdAt.isAfter(s) && o.createdAt.isBefore(e)).toList();
    }
    return list;
  }

  Future<void> _pickDateRange() async {
    final now = DateTime.now();
    final lastMonth = now.subtract(const Duration(days: 30));
    final res = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2023, 1, 1),
      lastDate: DateTime(now.year + 1),
      initialDateRange: _range ?? DateTimeRange(start: lastMonth, end: now),
      locale: Localizations.localeOf(context),
      helpText: 'اختر نطاق التاريخ',
    );
    if (res != null) setState(() => _range = res);
  }

  Future<void> _reorder(UserOrder o) async {
    try {
      final cart = CartRepo();
      for (final it in o.items) {
        await cart.addOrInc(
          productId: it.productId,
          title: it.title,
          imageUrl: it.imageUrl,
          price: it.price,
          qty: it.qty,
        );
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تمت إضافة عناصر الطلب إلى السلة ✅')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تعذّرت إعادة الطلب: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: Directionality.of(context),
      child: Scaffold(
        appBar: AppBar(
          title: Text(L.of(context, 'my_orders')),
          flexibleSpace: Container(decoration: const BoxDecoration(gradient: AppColors.appBgGradient)),
          actions: [
            IconButton(
              tooltip: L.of(context, 'clear_filters'),
              onPressed: () => setState(() { _status = 'الكل'; _range = null; }),
              icon: const Icon(Icons.filter_alt_off),
            ),
          ],
        ),
        body: Column(
          children: [
            // شريط الفلاتر
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
              child: Row(
                children: [
                  // حالة الطلب
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _status,
                      decoration: InputDecoration(
                        labelText: L.of(context, 'status'),
                        border: const OutlineInputBorder(),
                        isDense: true,
                      ),
                      items: _statuses
                          .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                          .toList(),
                      onChanged: (v) => setState(() => _status = v ?? 'الكل'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // التاريخ
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pickDateRange,
                      icon: const Icon(Icons.date_range),
                      label: Text(
                        _range == null
                            ? L.of(context, 'date_all')
                            : '${DateFormat('yyyy/MM/dd').format(_range!.start)} - ${DateFormat('yyyy/MM/dd').format(_range!.end)}',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // القائمة
            Expanded(
              child: StreamBuilder<List<UserOrder>>(
                stream: _repo.streamMyOrders(limit: 200),
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final all = snap.data ?? [];
                  final orders = _applyFilters(all);
                  if (orders.isEmpty) {
                    return Center(child: Text(L.of(context, 'no_matching_orders')));
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: orders.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (_, i) {
                      final o = orders[i];
                      return InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => OrderDetailsPage(orderId: o.id)),
                          );
                        },
                        borderRadius: BorderRadius.circular(14),
                        child: GlassContainer(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Header
                              Row(
                                children: [
                                  Text('#${o.id.substring(0, 6)}', style: const TextStyle(fontWeight: FontWeight.bold)),
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
                              const SizedBox(height: 10),

                              // Items preview
                              SizedBox(
                                height: 70,
                                child: ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: o.items.length,
                                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                                  itemBuilder: (_, j) => ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.network(o.items[j].imageUrl, width: 70, height: 70, fit: BoxFit.cover),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),

                              // Totals + payment + Reorder
                              Row(
                                children: [
                                  Expanded(child: Text('${L.of(context, 'total')}: ${o.total.toStringAsFixed(0)} ر.س',
                                      style: const TextStyle(fontWeight: FontWeight.w600))),
                                  const SizedBox(width: 8),
                                  Text(_payLabel(o.paymentMethod), style: const TextStyle(color: Colors.white70)),
                                  const SizedBox(width: 8),
                                  OutlinedButton.icon(
                                    onPressed: () => _reorder(o),
                                    icon: const Icon(Icons.shopping_cart_checkout),
                                    label: Text(L.of(context, 'reorder')),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
