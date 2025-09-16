// ignore_for_file: prefer_const_constructors, deprecated_member_use

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:se7en/core/theme/app_colors.dart';
import 'package:se7en/core/widgets/glass_container.dart';
import 'data/products_repo.dart';
import 'package:se7en/features/store/product_details_page.dart';
import 'package:se7en/widgets/price_text.dart';
import 'data/product_model.dart';
import 'package:se7en/core/layout/bottom_bar_utils.dart';

class SectionListingPage extends StatefulWidget {
  final String title;
  final ProductQuery query;
  const SectionListingPage({super.key, required this.title, required this.query});

  @override
  State<SectionListingPage> createState() => _SectionListingPageState();
}

class _SectionListingPageState extends State<SectionListingPage> {
  final _db = FirebaseFirestore.instance;
  late ProductQuery _q;
  final _sorts = const ['الأحدث', 'السعر: من الأقل', 'السعر: من الأعلى', 'الأعلى تقييماً'];

  @override
  void initState() {
    super.initState();
    _q = widget.query;
  }

  void _openFilters() async {
    String sort = _q.sort;

    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Directionality(
        textDirection: Directionality.of(context),
        child: DraggableScrollableSheet(
          initialChildSize: 0.5, minChildSize: 0.4, maxChildSize: 0.9,
          builder: (ctx, controller) {
            return Container(
              decoration: BoxDecoration(
                gradient: AppColors.appBgGradient,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: ListView(
                controller: controller,
                padding: const EdgeInsets.all(12),
                children: [
                  Center(child: Container(width: 44, height: 4,
                    decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(8)),
                  )),
                  const SizedBox(height: 12),
                  const Text('الترتيب', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    value: sort,
                    items: _sorts.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                    onChanged: (v)=> sort = v ?? sort,
                    decoration: const InputDecoration(border: OutlineInputBorder(), isDense: true),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.check_circle_outline),
                      label: const Text('تطبيق'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.orangeDeep, foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(46),
                      ),
                      onPressed: (){
                        Navigator.pop(ctx);
                        setState(() {
                          _q = ProductQuery(
                            category: _q.category,
                            sellerId: _q.sellerId,
                            badge: _q.badge,
                            sort: sort,
                            limit: _q.limit,
                          );
                        });
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ref = buildQuery(_q, _db);
    return Directionality(
      textDirection: Directionality.of(context),
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          actions: [
            IconButton(icon: const Icon(Icons.filter_list), onPressed: _openFilters),
          ],
          flexibleSpace: Container(decoration: const BoxDecoration(gradient: AppColors.appBgGradient)),
        ),
        body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: ref.snapshots(),
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final docs = snap.data?.docs ?? [];
            if (docs.isEmpty) {
              return const Center(child: Text('لا توجد منتجات في هذا القسم حالياً'));
            }
            final items = docs.map((d) => Product.fromMap(d.id, d.data())).toList();

            return WithBottomPadding(
              extra: 0,
              child: GridView.builder(
                padding: const EdgeInsets.all(12),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: .72,
                ),
                itemCount: items.length,
                itemBuilder: (_, i) {
                  final p = items[i];
                  return InkWell(
                    onTap: (){
                      Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailsPage(product: p)));
                    },
                    child: GlassContainer(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: AspectRatio(
                              aspectRatio: 1,
                              child: Image.network(p.imageUrl, fit: BoxFit.cover),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(p.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              PriceText(
                                p.price,
                                color: AppColors.orangeDeep,
                                iconSize: 20,
                              ),
                              const Spacer(),
                              const Icon(Icons.star, color: Colors.amber, size: 14),
                              const SizedBox(width: 2),
                              Text((p.avgRating ?? p.rating).toStringAsFixed(1)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.storefront_outlined, size: 14, color: Colors.white70),
                              const SizedBox(width: 4),
                              Expanded(child: Text(p.sellerName, style: const TextStyle(color: Colors.white70), maxLines: 1, overflow: TextOverflow.ellipsis)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
