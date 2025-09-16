// ignore_for_file: unused_element_parameter, unused_import

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:se7en/core/theme/app_colors.dart';
import 'package:se7en/widgets/price_text.dart';
import 'package:se7en/features/chat/widgets/contact_seller_button.dart';
import 'package:se7en/core/layout/bottom_bar_utils.dart';

class DealsPage extends StatefulWidget {
  const DealsPage({super.key});

  @override
  State<DealsPage> createState() => _DealsPageState();
}

class _DealsPageState extends State<DealsPage> {
  final _search = TextEditingController();
  String _selectedCategory = 'الكل';
  double _minRating = 0;
  RangeValues _price = const RangeValues(0, 5000);

  final _categories = const [
    'الكل','ملابس','عطور','إلكترونيات','جوالات','أجهزة منزلية','مكياج','إكسسوارات'
  ];

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Query<Map<String, dynamic>> _baseQuery() {
    return FirebaseFirestore.instance
        .collection('deals') // 🟠 الكولكشن اسمه deals
        .orderBy('createdAt', descending: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('العروض')),
      body: WithBottomPadding(
        extra: 0,
        child: SafeArea(
          bottom: false,
          child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: _SearchAndFilters(
                controller: _search,
                categories: _categories,
                selectedCategory: _selectedCategory,
                onCategory: (v) => setState(() => _selectedCategory = v),
                rating: _minRating,
                onRating: (v) => setState(() => _minRating = v),
                price: _price,
                onPrice: (v) => setState(() => _price = v),
                onChanged: () => setState(() {}),
              
              ),
            ),
            
            const SizedBox(height: 8),
            Expanded(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: _baseQuery().snapshots(),
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snap.hasError) {
                    return Center(child: Text('خطأ: ${snap.error}'));
                  }
                  final docs = snap.data?.docs ?? [];
                  if (docs.isEmpty) {
                    return const Center(child: Text('لا توجد عروض حالياً'));
                  }

                  final q = _search.text.trim().toLowerCase();
                  final filtered = docs.map((d) => d.data()).where((m) {
                    final title = (m['title'] ?? '').toString();
                    final store = (m['store'] ?? '').toString();
                    final cat = (m['category'] ?? '').toString();
                    final price = (m['price'] ?? 0).toDouble();
                    final rating = (m['rating'] ?? 0).toDouble();

                    final okSearch = q.isEmpty ||
                        title.toLowerCase().contains(q) ||
                        store.toLowerCase().contains(q) ||
                        cat.toLowerCase().contains(q);

                    final okCat = _selectedCategory == 'الكل' || cat == _selectedCategory;
                    final okPrice = price >= _price.start && price <= _price.end;
                    final okRate = rating >= _minRating;

                    return okSearch && okCat && okPrice && okRate;
                  }).toList();

                  if (filtered.isEmpty) {
                    return const Center(child: Text('لا توجد نتائج مطابقة للفلاتر'));
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                    itemCount: filtered.length,
                    itemBuilder: (_, i) => _DealCard(map: filtered[i]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}

class _SearchAndFilters extends StatelessWidget {
  final TextEditingController controller;
  final List<String> categories;
  final String selectedCategory;
  final void Function(String) onCategory;
  final double rating;
  final void Function(double) onRating;
  final RangeValues price;
  final void Function(RangeValues) onPrice;
  final VoidCallback onChanged;

  const _SearchAndFilters({
    super.key,
    required this.controller,
    required this.categories,
    required this.selectedCategory,
    required this.onCategory,
    required this.rating,
    required this.onRating,
    required this.price,
    required this.onPrice,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: controller,
          onChanged: (_) => onChanged(),
          decoration: InputDecoration(
            hintText: 'ابحث حسب الاسم، المتجر، الفئة...',
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemCount: categories.length,
            itemBuilder: (_, i) {
              final c = categories[i];
              final sel = c == selectedCategory;
              return ChoiceChip(
                label: Text(c),
                selected: sel,
                onSelected: (_) => onCategory(c),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            const Text('التقييم:'),
            Expanded(
              child: Slider(
                value: rating,
                min: 0,
                max: 5,
                divisions: 5,
                label: rating.toStringAsFixed(1),
                onChanged: onRating,
              ),
            ),
            Text(rating.toStringAsFixed(1)),
          ],
        ),
        Row(
          children: [
            const Text('السعر:'),
            Expanded(
              child: RangeSlider(
                values: price,
                min: 0,
                max: 5000,
                divisions: 50,
                labels: RangeLabels(
                  price.start.toInt().toString(),
                  price.end.toInt().toString(),
                ),
                onChanged: onPrice,
              ),
            ),
            Text('${price.start.toInt()} - ${price.end.toInt()}'),
          ],
        ),
      ],
    );
  }
}

class _DealCard extends StatelessWidget {
  final Map<String, dynamic> map;
  const _DealCard({required this.map});

  @override
  Widget build(BuildContext context) {
    final title = (map['title'] ?? '').toString();
    final store = (map['store'] ?? '').toString();
    final img = (map['imageUrl'] ?? '').toString();
    final price = (map['price'] ?? 0).toDouble();
    final old = (map['oldPrice'] ?? price).toDouble();
    final rating = (map['rating'] ?? 0).toDouble();
    final discount =
        old > 0 ? (((old - price) / old) * 100).clamp(0, 95).toInt() : 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          // TODO: افتح صفحة تفاصيل العرض
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
                child: Image.network(
                  img,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const ColoredBox(
                    color: Colors.black12,
                    child: Center(child: Icon(Icons.broken_image)),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    if (discount > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.deepOrange,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text('خصم $discount%'),
                      ),
                    const Spacer(),
                    Row(children: [
                      const Icon(Icons.star, size: 18),
                      const SizedBox(width: 4),
                      Text(rating.toStringAsFixed(1)),
                    ]),
                  ]),
                  const SizedBox(height: 8),
                  Text(title,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(store, style: TextStyle(color: Colors.grey.shade600)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      PriceText(
                        price,
                        color: AppColors.orangeDeep,
                        iconSize: 20,
                      ),
                      const SizedBox(width: 8),
                      if (old > price)
                        Text('${old.toStringAsFixed(0)}',
                            style: const TextStyle(
                                decoration: TextDecoration.lineThrough)),
                      const Spacer(),
                      IconButton(
                          onPressed: () {}, icon: const Icon(Icons.favorite)),
                      ElevatedButton(
                          onPressed: () {}, child: const Text('أضف للسلة')),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      );
  }
}
