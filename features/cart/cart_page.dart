// ignore_for_file: use_build_context_synchronously, prefer_const_constructors, unnecessary_string_interpolations, unused_element, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_container.dart';
import 'package:se7en/core/layout/bottom_bar_utils.dart';

// ✅ استخدم النسخة المشتركة من الريبو
import 'data/cart_repo.dart';
import 'data/cart_item_model.dart';

import '../checkout/checkout_page.dart';
import 'package:se7en/features/store/product_details_page.dart';
import '../home/data/product_model.dart';
import '../reviews/services/review_provider.dart';
import 'package:se7en/widgets/price_text.dart';
import '../reviews/services/review_repo.dart';

// لو ما عندك ثابت للضريبة، فعّله هنا (احذف السطرين لو عندك ثابت جاهز)
const double kVatRate = 0.15; // 15%

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  // ❌ كان هنا new CartRepo()
  // final _repo = CartRepo();

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: Directionality.of(context),
      child: Scaffold(
        extendBody: true, // مهم جداً عشان البودي يمتد تحت الشريط الزجاجي
        appBar: AppBar(
          title: const Text('سلة التسوّق'),
          actions: [
            IconButton(
              tooltip: 'تفريغ',
              icon: const Icon(Icons.delete_sweep_outlined),
              onPressed: () async {
                // تأكيد قبل التفريغ
                final ok = await showDialog<bool>(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('تفريغ السلة'),
                        content: const Text('هل أنت متأكد من تفريغ السلة؟'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('إلغاء')),
                          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('تأكيد')),
                        ],
                      ),
                    ) ??
                    false;
                if (!ok) return;

                // ✅ النسخة المشتركة
                cartRepo.clear();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('تم تفريغ السلة')),
                  );
                }
              },
            ),
          ],
          flexibleSpace:
              Container(decoration: const BoxDecoration(gradient: AppColors.appBgGradient)),
        ),
        body: WithBottomPadding(
          extra: 0,
          child: StreamBuilder<List<CartItem>>(
          // ✅ لو عندك stream داخل الريبو، استعمله
          stream: cartRepo.streamItems?.call(),
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final items = snap.data ?? cartRepo.items; // fallback لو stream null
            if (items.isEmpty) {
              return const Center(child: Text('السلة فارغة حالياً'));
            }

            final sub = items.fold<double>(0, (p, e) => p + (e.price * e.qty));
            final vat = sub * kVatRate;
            final totalNoCod = sub + vat;

            return Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, i) {
                      final it = items[i];
                      return GlassContainer(
                        padding: const EdgeInsets.all(10),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: SizedBox(
                                width: 72,
                                height: 72,
                                child: (it.imageUrl != null && it.imageUrl!.isNotEmpty)
                                    ? Image.network(it.imageUrl!, fit: BoxFit.cover)
                                    : Container(
                                        color: Colors.white.withOpacity(0.08),
                                        child: const Icon(Icons.image_outlined),
                                      ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(it.title,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 4),
                                  PriceText(
                                    it.price,
                                    color: AppColors.orangeDeep,
                                    iconSize: 20,
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      IconButton(
                                        onPressed: () {
                                          final next = it.qty - 1;
                                          if (next <= 0) {
                                            // احذف بدل ما يطلع صفر
                                            cartRepo.removeFromCart.call(it.id);
                                          } else {
                                            cartRepo.updateQty(it.id, next);
                                          }
                                        },
                                        icon: const Icon(Icons.remove_circle_outline),
                                      ),
                                      Text('${it.qty}',
                                          style: const TextStyle(fontWeight: FontWeight.bold)),
                                      IconButton(
                                        onPressed: () => cartRepo.updateQty(it.id, it.qty + 1),
                                        icon: const Icon(Icons.add_circle_outline),
                                      ),
                                      const Spacer(),
                                      TextButton.icon(
                                        onPressed: () => _openQuickLook(context, it.id),
                                        icon: const Icon(Icons.info_outline),
                                        label: const Text('تفاصيل'),
                                      ),
                                      IconButton(
                                        tooltip: 'حذف',
                                        onPressed: () => cartRepo.removeFromCart.call(it.id),
                                        icon: const Icon(Icons.delete_outline),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                // الملخص
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                  child: GlassContainer(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Text('المجموع الفرعي'),
                            const Spacer(),
                            PriceText(sub, color: Colors.white),
                          ],
                        ),
                        Row(
                          children: [
                            const Text('ضريبة القيمة المضافة (15%)'),
                            const Spacer(),
                            PriceText(vat, color: Colors.white),
                          ],
                        ),
                        const Divider(height: 16),
                        Row(
                          children: [
                            const Text('الإجمالي (بدون رسوم الاستلام)', style: TextStyle(fontWeight: FontWeight.w700)),
                            const Spacer(),
                            PriceText(totalNoCod, color: Colors.white),
                          ],
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => CheckoutPage(
                                    initialSub: sub,
                                    initialVat: vat,
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(Icons.payment),
                            label: const Text('إتمام الشراء'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.orangeDeep,
                              foregroundColor: Colors.white,
                              minimumSize: const Size.fromHeight(48),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
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

  void _openQuickLook(BuildContext context, String productId) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _ProductQuickLookSheet(productId: productId),
    );
  }
}

/// ===== BottomSheet: تفاصيل المنتج + تعليقات + مشابه =====
class _ProductQuickLookSheet extends StatelessWidget {
  final String productId;
  const _ProductQuickLookSheet({required this.productId});

  @override
  Widget build(BuildContext context) {
    final db = FirebaseFirestore.instance;
    final docRef = db.collection('products').doc(productId);

    return Directionality(
      textDirection: Directionality.of(context),
      child: DraggableScrollableSheet(
        initialChildSize: 0.86,
        minChildSize: 0.5,
        maxChildSize: 0.96,
        builder: (_, controller) => Container(
          decoration: BoxDecoration(
            gradient: AppColors.appBgGradient,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
          ),
          child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            stream: docRef.snapshots(),
            builder: (context, snap) {
              if (!snap.hasData) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24.0),
                    child: CircularProgressIndicator(),
                  ),
                );
              }
              final m = snap.data!.data() ?? {};
              final p = Product.fromMap(productId, m);

              final desc = (m['description'] ?? '').toString();
              final num? avgNum = (m['avgRating'] ?? m['rating']) as num?;
              final double avg = (avgNum?.toDouble()) ?? 0.0;
              final int cnt = ((m['reviewsCount'] ?? m['reviews']) as num?)?.toInt() ?? 0;

              return ListView(
                controller: controller,
                padding: const EdgeInsets.all(12),
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      const Spacer(),
                      IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // صورة + عنوان + سعر
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: SizedBox(
                          width: 110,
                          height: 110,
                          child: (p.imageUrl.isNotEmpty)
                              ? Image.network(p.imageUrl, fit: BoxFit.cover)
                              : Container(
                                  color: Colors.white.withOpacity(0.08),
                                  child: const Icon(Icons.image_outlined),
                                ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(p.title, style: const TextStyle(fontWeight: FontWeight.w700)),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(Icons.storefront_outlined, size: 16, color: Colors.white70),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    (p.sellerName),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(color: Colors.white70),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                               PriceText(
                                 p.price,
                                 color: AppColors.orangeDeep,
                                 iconSize: 20,
                               ),
                                
                                const SizedBox(width: 6),
                                if (p.oldPrice != null)
                                  Text(
                                    '${p.oldPrice!.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                      color: Colors.white54,
                                      decoration: TextDecoration.lineThrough,
                                    ),
                                  ),
                                const Spacer(),
                                const Icon(Icons.star, color: Colors.amber, size: 16),
                                const SizedBox(width: 4),
                                Text('${avg.toStringAsFixed(1)} • $cnt'),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  if (desc.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    const Text('الوصف', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Text(desc),
                  ],

                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 8),

                  // تعليقات العملاء (أحدث أولاً)
                  const Text('تعليقات العملاء', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  _ReviewsListCompact(productId: p.id),

                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 8),

                  // منتجات مشابهة (نفس الفئة)
                  if ((p.category ?? '').isNotEmpty) ...[
                    const Text('منتجات مشابهة', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 210,
                      child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                        stream: db
                            .collection('products')
                            .where('category', isEqualTo: p.category)
                            .orderBy('createdAt', descending: true)
                            .limit(12)
                            .snapshots(),
                        builder: (context, ss) {
                          final docs = (ss.data?.docs ?? []).where((d) => d.id != p.id).toList();
                          if (docs.isEmpty) {
                            return const Center(child: Text('لا توجد منتجات مشابهة حالياً'));
                          }
                          final list = docs.map((d) => Product.fromMap(d.id, d.data())).toList();
                          return ListView.separated(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            itemBuilder: (_, i) {
                              final sp = list[i];
                              return InkWell(
                                onTap: () {
                                  Navigator.pop(context);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => ProductDetailsPage(product: sp)),
                                  );
                                },
                                child: SizedBox(
                                  width: 150,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: AspectRatio(
                                          aspectRatio: 4 / 3,
                                          child: (sp.imageUrl.isNotEmpty)
                                              ? Image.network(sp.imageUrl, fit: BoxFit.cover)
                                              : Container(
                                                  color: Colors.white.withOpacity(0.08),
                                                  child: const Icon(Icons.image_outlined),
                                                ),
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(sp.title, maxLines: 2, overflow: TextOverflow.ellipsis),
                                      const SizedBox(height: 4),
                                      PriceText(
                                        sp.price,
                                        color: AppColors.orangeDeep,
                                        iconSize: 20,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                            separatorBuilder: (_, __) => const SizedBox(width: 10),
                            itemCount: list.length,
                          );
                        },
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ReviewsListCompact extends StatelessWidget {
  final String productId;
  const _ReviewsListCompact({required this.productId});

  @override
  Widget build(BuildContext context) {
    final repo = ReviewProvider.of();
    return StreamBuilder<List<ReviewItem>>(
      stream: repo.streamReviews(productId, limit: 10),
      builder: (context, snap) {
        final items = snap.data ?? [];
        if (items.isEmpty) {
          return const Text('لا توجد تعليقات بعد.');
        }
        return Column(
          children: items
              .map(
                (r) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const CircleAvatar(radius: 14, child: Icon(Icons.person, size: 16)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(children: [
                              Expanded(
                                child: Text(r.userName, style: const TextStyle(fontWeight: FontWeight.w600)),
                              ),
                              const Icon(Icons.star, color: Colors.amber, size: 14),
                              const SizedBox(width: 4),
                              Text(r.rating.toStringAsFixed(1), style: const TextStyle(fontSize: 12)),
                            ]),
                            const SizedBox(height: 4),
                            Text(r.comment.isEmpty ? '—' : r.comment),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        );
      },
    );
  }
}
