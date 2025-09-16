// ignore_for_file: unnecessary_string_interpolations, deprecated_member_use, prefer_if_null_operators, unused_field

import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_container.dart';
import '../../core/widgets/rating_stars.dart';
import 'package:se7en/core/layout/bottom_bar_utils.dart';
import '../../services/firestore_service.dart';
import 'data/product_model.dart';
import 'data/products_repo.dart';
import 'package:se7en/services/products_service.dart';
import 'data/products_repo_firestore.dart';
import 'section_listing_page.dart';
import 'package:se7en/widgets/price_text.dart';
import 'package:se7en/features/store/product_details_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _products = ProductsService();
  final _repo = ProductsRepoFirestore();
  final _fs = FirestoreService();
  final _searchCtrl = TextEditingController();
  Timer? _debounce;

  String _query = '';
  String? _category;
  double? _minPrice;
  double? _maxPrice;
  double? _minRating;
  String _sort = 'الأحدث';

  final List<String> _sections = const [
    'منتجات مميزة',
    'عروض مميزة',
    'أفضل العروض على اللابتوبات',
    'أفضل العروض على الجوالات',
    'أفضل العروض على الإكسسوارات',
    'أفضل العروض على العناية الشخصية',
    'أفضل العروض على العطور',
    'أفضل العروض على النظارات',
    'توفير أكثر',
    'أفضل العروض على الأزياء',
    'عروض ترند',
    'أزياء رجال',
    'أزياء نساء',
    'أزياء أطفال',
    'الجمال',
    'الصحة والتغذية',
    'أجهزة منزلية',
    'الألعاب',
    'الساعات',
    'مستلزمات رياضة',
    'القرطاسية والمستلزمات المكتبية',
  ];

  @override
  void initState() {
    super.initState();
    // إنشاء/تحديث وثيقة المستخدم + تفعيل مستمع البحث
    _fs.ensureUserDoc();     // ينشئ/يحدّث وثيقة المستخدم
    // _fs.addDummyProduct(); // اختياري: يضيف منتج تجريبي
    _searchCtrl.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      setState(() => _query = _searchCtrl.text.trim());
    });
  }

  void _openAdvancedFilters() async {
    final vals = await showModalBottomSheet<_AdvancedFiltersResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AdvancedFiltersSheet(
        category: _category,
        minPrice: _minPrice,
        maxPrice: _maxPrice,
        minRating: _minRating,
        sort: _sort,
      ),
    );
    if (vals != null) {
      setState(() {
        _category = vals.category;
        _minPrice = vals.minPrice;
        _maxPrice = vals.maxPrice;
        _minRating = vals.minRating;
        _sort = vals.sort;
      });
    }
  }

  void _clearFilters() {
    setState(() {
      _category = null; _minPrice = null; _maxPrice = null; _minRating = null; _sort = 'الأحدث';
      _searchCtrl.clear(); _query = '';
    });
  }

  ProductQuery _qForSection(String section) => ProductQuery(
        section: section,
        category: _category,
        search: _query.isEmpty ? null : _query,
        minPrice: _minPrice,
        maxPrice: _maxPrice,
        minRating: _minRating,
        sort: _sort,
        limit: 12,
      );

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: Directionality.of(context),
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true, floating: true, elevation: 0, backgroundColor: Colors.lightBlue,
              flexibleSpace: Container(decoration: const BoxDecoration(gradient: AppColors.appBgGradient)),
              expandedHeight: 140,
              title: Row(
                children: [

                  const Spacer(),
                  IconButton(onPressed: _clearFilters, tooltip: 'مسح الفلاتر', icon: const Icon(Icons.refresh)),
                ],
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(84),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                  child: Column(
                    children: [
                      GlassContainer(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        child: Row(
                          children: [
                            const Icon(Icons.search),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                controller: _searchCtrl,
                                decoration: const InputDecoration(
                                  hintText: 'ابحث حسب الاسم، المتجر، الفئة…',
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                            if (_query.isNotEmpty)
                              IconButton(onPressed: () { _searchCtrl.clear(); FocusScope.of(context).unfocus(); },
                                  icon: const Icon(Icons.close), tooltip: 'مسح'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 36,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            _FilterChip(label: _sort, icon: Icons.sort, onTap: _openAdvancedFilters),
                            const SizedBox(width: 8),
                            _FilterChip(label: _category == null ? 'الفئة' : 'فئة: ${_category!}', icon: Icons.category_outlined, onTap: _openAdvancedFilters),
                            const SizedBox(width: 8),
                            _FilterChip(
                              label: (_minPrice == null && _maxPrice == null)
                                  ? 'السعر'
                                  : 'سعر: ${_minPrice?.toStringAsFixed(0) ?? 0} - ${_maxPrice?.toStringAsFixed(0) ?? '∞'}',
                              icon: Icons.attach_money, onTap: _openAdvancedFilters),
                            const SizedBox(width: 8),
                            _FilterChip(label: _minRating == null ? 'التقييم' : 'تقييم +${_minRating!.toStringAsFixed(1)}', icon: Icons.star_rate_rounded, onTap: _openAdvancedFilters),
                            const SizedBox(width: 8),
                            _FilterChip(label: 'فلترة متقدمة', icon: Icons.tune, onTap: _openAdvancedFilters),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Text(_query.isEmpty ? 'اكتشف أفضل العروض المختارة لك ✨' : 'نتائج لـ “$_query”',
                    style: const TextStyle(color: Colors.orange)),
              ),
            ),

            for (final section in _sections)
  SliverToBoxAdapter(
    child: _SectionStreamRow(
      title: section,
      stream: _repo.streamSection(_qForSection(section)),
      onProductTap: (p) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ProductDetailsPage(product: p)),
        );
      },
      onShowAll: () {
        final q = _qForSection(section); // نفس فلاترك الحالية
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SectionListingPage(title: section, query: q),
          ),
        );
      },
    ),
  ),

            // مسافة آمنة أسفل الشريط الزجاجي بدون زيادة
            const SliverToBoxAdapter(child: BottomBarSpacer(extra: 0)),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label; final IconData icon; final VoidCallback onTap;
  const _FilterChip({required this.label, required this.icon, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: GlassContainer(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Row(children: [Icon(icon, size: 16), const SizedBox(width: 6), Text(label, style: const TextStyle(fontSize: 12))]),
      ),
    );
  }
}

class _SectionStreamRow extends StatelessWidget {
  final String title;
  final Stream<List<Product>> stream;
  final ValueChanged<Product> onProductTap;
  final VoidCallback onShowAll; // ✅ جديد

  const _SectionStreamRow({
    required this.title,
    required this.stream,
    required this.onProductTap,
    required this.onShowAll,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: StreamBuilder<List<Product>>(
        stream: stream,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const SizedBox(height: 260, child: Center(child: CircularProgressIndicator()));
          }
          final products = snap.data ?? [];
          if (products.isEmpty) return const SizedBox.shrink();

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: Row(
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                    const Spacer(),
                    TextButton(
                      onPressed: onShowAll, // ✅ هنا التبديل
                      child: const Text('عرض الكل'),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 250,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  scrollDirection: Axis.horizontal,
                  itemCount: products.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (_, i) => _ProductCard(
                    product: products[i],
                    onTap: onProductTap,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Product product; final ValueChanged<Product> onTap;
  const _ProductCard({required this.product, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(product),
      child: SizedBox(
        width: 180,
        child: GlassContainer(
          padding: const EdgeInsets.all(8),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: AspectRatio(aspectRatio: 4 / 3, child: Image.network(product.imageUrl, fit: BoxFit.cover)),
            ),
            const SizedBox(height: 8),
            Text(product.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600)),
            Row(children: [
              const Icon(Icons.storefront_outlined, size: 16, color: Colors.white70),
              const SizedBox(width: 4),
              Expanded(child: Text(product.sellerName, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white70, fontSize: 12))),
            ]),
            const SizedBox(height: 4),
            Row(children: [
              RatingStars(rating: product.rating, size: 14),
              const SizedBox(width: 6),
              Text(product.rating.toStringAsFixed(1), style: const TextStyle(fontSize: 12, color: Colors.white70)),
            ]),
            const Spacer(),
            Row(children: [
              PriceText(
  product.price,
  color: AppColors.orangeDeep,
  iconSize: 20,
),
              const SizedBox(width: 6),
              if (product.oldPrice != null) Text('${product.oldPrice!.toStringAsFixed(0)}', style: const TextStyle(color: Colors.white54, decoration: TextDecoration.lineThrough, fontSize: 12)),
              const Spacer(),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.add_shopping_cart, size: 18),
                tooltip: 'إضافة للسلة',
                padding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
                splashRadius: 18,
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              ),
            ]),
          ]),
        ),
      ),
    );
  }
}

// نتيجة الفلاتر المتقدمة
class _AdvancedFiltersResult {
  final String? category;
  final double? minPrice;
  final double? maxPrice;
  final double? minRating;
  final String sort;

  const _AdvancedFiltersResult({
    required this.category,
    required this.minPrice,
    required this.maxPrice,
    required this.minRating,
    required this.sort,
  });
}

// شيت الفلاتر المتقدمة
class _AdvancedFiltersSheet extends StatefulWidget {
  final String? category;
  final double? minPrice;
  final double? maxPrice;
  final double? minRating;
  final String sort;

  const _AdvancedFiltersSheet({
    required this.category,
    required this.minPrice,
    required this.maxPrice,
    required this.minRating,
    required this.sort,
  });

  @override
  State<_AdvancedFiltersSheet> createState() => _AdvancedFiltersSheetState();
}

class _AdvancedFiltersSheetState extends State<_AdvancedFiltersSheet> {
  late String? _category = widget.category;
  late double? _minPrice = widget.minPrice;
  late double? _maxPrice = widget.maxPrice;
  late double? _minRating = widget.minRating;
  late String _sort = widget.sort;

  final _minCtrl = TextEditingController();
  final _maxCtrl = TextEditingController();

  final _sortOptions = const ['الأحدث', 'الأرخص', 'الأغلى', 'الأعلى تقييماً'];
  final _categories = const [
    null,
    'لابتوبات',
    'جوالات',
    'إكسسوارات',
    'العناية الشخصية',
    'العطور',
    'النظارات',
    'الأزياء',
  ];

  @override
  void initState() {
    super.initState();
    if (_minPrice != null) _minCtrl.text = _minPrice!.toStringAsFixed(0);
    if (_maxPrice != null) _maxCtrl.text = _maxPrice!.toStringAsFixed(0);
  }

  @override
  void dispose() {
    _minCtrl.dispose();
    _maxCtrl.dispose();
    super.dispose();
  }

  void _apply() {
    final minP = double.tryParse(_minCtrl.text.trim());
    final maxP = double.tryParse(_maxCtrl.text.trim());
    Navigator.of(context).pop(_AdvancedFiltersResult(
      category: _category,
      minPrice: minP,
      maxPrice: maxP,
      minRating: _minRating,
      sort: _sort,
    ));
  }

  void _reset() {
    setState(() {
      _category = null;
      _minPrice = null;
      _maxPrice = null;
      _minRating = null;
      _sort = 'الأحدث';
      _minCtrl.clear();
      _maxCtrl.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: Directionality.of(context),
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xFF14161A),
            borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
          ),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text('فلترة متقدمة', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const Spacer(),
                  IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.close), tooltip: 'إغلاق'),
                ],
              ),
              const SizedBox(height: 8),

              const Text('الترتيب'),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: _sortOptions.contains(_sort) ? _sort : _sortOptions.first,
                decoration: const InputDecoration(border: OutlineInputBorder()),
                items: _sortOptions.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                onChanged: (v) => setState(() => _sort = v ?? 'الأحدث'),
              ),
              const SizedBox(height: 12),

              const Text('الفئة'),
              const SizedBox(height: 6),
              DropdownButtonFormField<String?>(
                value: _category,
                decoration: const InputDecoration(border: OutlineInputBorder()),
                items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c == null ? 'الكل' : c))).toList(),
                onChanged: (v) => setState(() => _category = v),
              ),
              const SizedBox(height: 12),

              const Text('السعر (من - إلى)'),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _minCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'من'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _maxCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'إلى'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              const Text('الحد الأدنى للتقييم'),
              const SizedBox(height: 6),
              Row(children: [
                Expanded(
                  child: Slider(
                    value: (_minRating ?? 0).clamp(0, 5),
                    min: 0, max: 5, divisions: 10,
                    label: ((_minRating ?? 0)).toStringAsFixed(1),
                    onChanged: (v) => setState(() => _minRating = v),
                  ),
                ),
                Text((_minRating ?? 0).toStringAsFixed(1)),
              ]),

              const SizedBox(height: 12),
              Row(children: [
                TextButton.icon(onPressed: _reset, icon: const Icon(Icons.refresh), label: const Text('إعادة ضبط')),
                const Spacer(),
                ElevatedButton.icon(onPressed: _apply, icon: const Icon(Icons.check), label: const Text('تطبيق')),
              ]),
            ],
          ),
        ),
      ),
    );
  }
}
