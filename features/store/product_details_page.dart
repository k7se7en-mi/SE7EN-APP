// ignore_for_file: unnecessary_string_interpolations, use_build_context_synchronously, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_container.dart';
import '../../core/widgets/rating_stars.dart';
import 'package:se7en/widgets/price_text.dart';
import 'package:se7en/features/home/data/product_model.dart';
import '../reviews/services/review_provider.dart';
import '../reviews/services/review_repo.dart';
import 'package:se7en/core/layout/bottom_bar_utils.dart';
import '../cart/data/cart_repo.dart';

class ProductDetailsPage extends StatelessWidget {
  final Product product;
  const ProductDetailsPage({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final docRef = FirebaseFirestore.instance.collection('products').doc(product.id);

    return Directionality(
      textDirection: Directionality.of(context),
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              backgroundColor: Colors.transparent,
              elevation: 0,
              expandedHeight: 280,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
              actions: [
                IconButton(
                  tooltip: 'مشاركة',
                  icon: const Icon(Icons.share_outlined),
                  onPressed: () {},
                ),
                IconButton(
                  tooltip: 'المفضلة',
                  icon: const Icon(Icons.favorite_border),
                  onPressed: () {},
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(product.imageUrl, fit: BoxFit.cover),
                    Container(color: Colors.black.withValues(alpha: 0.25)),
                  ],
                ),
              ),
            ),

            // عنوان + سعر + تاجر + فئة + تقييم مباشر من المستند
            SliverToBoxAdapter(
              child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                stream: docRef.snapshots(),
                builder: (context, snap) {
                  final d = snap.data?.data();
                  final price = (d?['price'] ?? product.price).toDouble();
                  final oldPrice = (d?['oldPrice'] as num?)?.toDouble() ?? product.oldPrice;
                  final avg = (d?['avgRating'] ?? product.rating).toDouble();
                  final cnt = (d?['reviewsCount'] ?? product.reviews) as int;

                  return Padding(
                    padding: const EdgeInsets.all(12),
                    child: GlassContainer(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(product.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(Icons.storefront_outlined, size: 18, color: Colors.white70),
                              const SizedBox(width: 6),
                              Text(product.sellerName, style: const TextStyle(color: Colors.white70)),
                              const Spacer(),
                              if (product.category != null && product.category!.isNotEmpty)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(999),
                                    color: Colors.white.withValues(alpha: 0.08),
                                  ),
                                  child: Text(product.category!),
                                ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              // سعر بالويدجت الموحد
                              PriceText(
                                price,
                                iconSize: 18,
                                color: AppColors.orangeDeep,
                              ),
                              const SizedBox(width: 8),
                              if (oldPrice != null)
                                Text(
                                  '${oldPrice.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                    color: Colors.white54,
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                              const Spacer(),
  RatingStars(rating: avg, size: 16),
                              const SizedBox(width: 6),
                              Text('${avg.toStringAsFixed(1)} • $cnt مراجعة', style: const TextStyle(color: Colors.white70)),
                            ],
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                try {
    await CartRepo().addOrInc(
      productId: product.id,
      title: product.title,
      imageUrl: product.imageUrl,
      price: product.price,
      qty: 1,
    );
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('أُضيف للسلة 🛒')));
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطأ: $e')));
  }
},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.orangeDeep,
                                foregroundColor: Colors.white,
                                minimumSize: const Size.fromHeight(46),
                              ),
                              icon: const Icon(Icons.add_shopping_cart),
                              label: const Text('أضف للسلة'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // قسم: التعليقات والمراجعات
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    const Text('التقييمات والتعليقات', style: TextStyle(fontWeight: FontWeight.bold)),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: () => _showAddReviewSheet(context, product.id),
                      icon: const Icon(Icons.rate_review_outlined),
                      label: const Text('أضف مراجعة'),
                    ),
                  ],
                ),
              ),
            ),

            // قائمة التعليقات (Stream)
            SliverToBoxAdapter(
              child: _ReviewsList(productId: product.id),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),
            // مسافة آمنة أسفل الشريط الزجاجي
            const SliverToBoxAdapter(child: BottomBarSpacer(extra: 0)),
          ],
        ),
      ),
    );
  }

  void _showAddReviewSheet(BuildContext context, String productId) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _AddReviewSheet(productId: productId),
    );
  }
}

class _ReviewsList extends StatelessWidget {
  final String productId;
  const _ReviewsList({required this.productId});

  @override
  Widget build(BuildContext context) {
    final repo = ReviewProvider.of();

    return StreamBuilder<List<ReviewItem>>(
      stream: repo.streamReviews(productId, limit: 50),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final items = snap.data ?? [];
        if (items.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Text('لا توجد تعليقات بعد — كن أول من يقيّم ✨', textAlign: TextAlign.center),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (_, i) {
            final r = items[i];
            return GlassContainer(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CircleAvatar(radius: 18, child: Icon(Icons.person)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Expanded(child: Text(r.userName, style: const TextStyle(fontWeight: FontWeight.w600))),
                          RatingStars(rating: r.rating, size: 14),
                          const SizedBox(width: 6),
                          Text(_formatDate(r.createdAt), style: const TextStyle(fontSize: 11, color: Colors.white60)),
                        ]),
                        const SizedBox(height: 6),
                        Text(r.comment.isEmpty ? '—' : r.comment),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  String _formatDate(DateTime d) {
    final now = DateTime.now();
    final diff = now.difference(d);
    if (diff.inMinutes < 1) return 'الآن';
    if (diff.inHours < 1) return '${diff.inMinutes} د';
    if (diff.inDays < 1) return '${diff.inHours} س';
    if (diff.inDays < 7) return '${diff.inDays} يوم';
    return '${d.year}/${d.month.toString().padLeft(2, '0')}/${d.day.toString().padLeft(2, '0')}';
  }
}

class _AddReviewSheet extends StatefulWidget {
  final String productId;
  const _AddReviewSheet({required this.productId});

  @override
  State<_AddReviewSheet> createState() => _AddReviewSheetState();
}

class _AddReviewSheetState extends State<_AddReviewSheet> {
  double _rating = 5.0;
  final _textCtrl = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _textCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Directionality(
      textDirection: Directionality.of(context),
      child: Padding(
        padding: EdgeInsets.only(bottom: bottom),
        child: Container(
          decoration: BoxDecoration(
            gradient: AppColors.appBgGradient,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
          ),
          padding: const EdgeInsets.all(16),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(8))),
                const SizedBox(height: 10),
                const Text('أضف مراجعتك', style: TextStyle(fontWeight: FontWeight.bold)),

                const SizedBox(height: 12),
                _StarPicker(
                  value: _rating,
                  onChanged: (v) => setState(() => _rating = v),
                ),

                const SizedBox(height: 10),
                TextField(
                  controller: _textCtrl,
                  minLines: 2,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    hintText: 'اكتب تعليقك (اختياري)…',
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _sending ? null : _submit,
                    icon: _sending
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.send),
                    label: const Text('إرسال'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.orangeDeep,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(46),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('سجل الدخول أولًا لإضافة مراجعة')));
      return;
    }
    setState(() => _sending = true);
    try {
      final repo = ReviewProvider.of();
      await repo.addReview(
        productId: widget.productId,
        userName: user.displayName ?? (user.email ?? 'مستخدم'),
        rating: _rating,
        comment: _textCtrl.text.trim(),
        userId: user.uid,
      );
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تمت إضافة مراجعتك ✅')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطأ: $e')));
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }
}

class _StarPicker extends StatelessWidget {
  final double value;
  final ValueChanged<double> onChanged;
  const _StarPicker({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      children: List.generate(5, (i) {
        final idx = i + 1;
        final filled = value >= idx;
        return InkWell(
          onTap: () => onChanged(idx.toDouble()),
          child: Icon(filled ? Icons.star : Icons.star_border, size: 28, color: Colors.amber),
        );
      }),
    );
  }
}
