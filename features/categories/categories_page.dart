import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import 'package:se7en/core/widgets/glass_container.dart';
import 'package:se7en/features/home/section_listing_page.dart';
import 'package:se7en/features/home/data/products_repo.dart';
import '../../core/theme/theme_controller.dart'; // ⬅️ للزر
import 'package:se7en/core/layout/bottom_bar_utils.dart';

class CategoryItem {
  final String name;
  final String image;
  final IconData icon;
  const CategoryItem({
    required this.name,
    required this.image,
    this.icon = Icons.category,
  });
}

class CategoriesPage extends StatelessWidget {
  const CategoriesPage({super.key});

  static final _cats = <CategoryItem>[
    CategoryItem(name: 'أزياء رجال', image: 'assets/cats/men.png', icon: Icons.male),
    CategoryItem(name: 'أزياء نساء', image: 'assets/cats/women.png', icon: Icons.female),
    CategoryItem(name: 'أزياء أطفال', image: 'assets/cats/kids.png', icon: Icons.child_care),
    CategoryItem(name: 'العناية الشخصية', image: 'assets/cats/personal_care.png', icon: Icons.spa),
    CategoryItem(name: 'الجمال', image: 'assets/cats/beauty.png', icon: Icons.brush),
    CategoryItem(name: 'الصحة والتغذية', image: 'assets/cats/health.png', icon: Icons.health_and_safety),
    CategoryItem(name: 'الأجهزة المنزلية', image: 'assets/cats/home.png', icon: Icons.home_filled),
    CategoryItem(name: 'الألعاب', image: 'assets/cats/games.png', icon: Icons.sports_esports),
    // أيقونات بديلة مناسبة
    CategoryItem(name: 'العطور', image: 'assets/cats/perfumes.png', icon: Icons.local_florist),
    CategoryItem(name: 'الساعات', image: 'assets/cats/watches.png', icon: Icons.watch),
    CategoryItem(name: 'النظارات', image: 'assets/cats/glasses.png', icon: Icons.visibility),
    CategoryItem(name: 'القرطاسية والمستلزمات المكتبية', image: 'assets/cats/stationery.png', icon: Icons.menu_book),
    CategoryItem(name: 'اختام', image: 'assets/cats/stamps.png', icon: Icons.verified_outlined),
    CategoryItem(name: 'أخرى', image: 'assets/cats/other.png', icon: Icons.category),
    CategoryItem(name: 'جوالات', image: 'assets/cats/phones.png', icon: Icons.phone_android),
    CategoryItem(name: 'لابتوبات', image: 'assets/cats/laptops.png', icon: Icons.laptop),
    CategoryItem(name: 'اكسسوارات', image: 'assets/cats/accessories.png', icon: Icons.extension),
    CategoryItem(name: 'تابلت', image: 'assets/cats/tablet.png', icon: Icons.tablet_android),
  ];

  void _openCategory(BuildContext context, String category) {
    final q = ProductQuery(category: category, sort: 'الأحدث', limit: 24);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => SectionListingPage(title: category, query: q)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBody: true, // مهم جداً عشان البودي يمتد تحت الشريط الزجاجي
      appBar: AppBar(
        title: const Text('Se7en'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => Navigator.pushNamed(context, '/search'),
          ),
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined),
            onPressed: () => Navigator.pushNamed(context, '/cart'),
          ),
          // ⬇️ زر النهاري/الليلي
          IconButton(
            tooltip: 'الوضع ${context.watch<ThemeController>().materialMode == ThemeMode.dark ? "النهاري" : "الليلي"}',
            icon: Icon(
              context.watch<ThemeController>().materialMode == ThemeMode.dark
                  ? Icons.wb_sunny_outlined
                  : Icons.nightlight_round,
            ),
            onPressed: () => context.read<ThemeController>().toggle(),
          ),
        ],
        systemOverlayStyle: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
        flexibleSpace: Container(decoration: const BoxDecoration(gradient: AppColors.appBgGradient)),
      ),
      body: WithBottomPadding(
        extra: 0,
        child: GridView.builder(
          padding: const EdgeInsets.all(12),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.0,
          ),
          itemCount: _cats.length,
          itemBuilder: (_, i) {
            final c = _cats[i];
            return CategoryCard(
              item: c,
              onTap: () => _openCategory(context, c.name),
            );
          },
        ),
      ),
    );
  }
}

class CategoryCard extends StatelessWidget {
  final CategoryItem item;
  final VoidCallback? onTap;
  const CategoryCard({super.key, required this.item, this.onTap});

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(16);

    return InkWell(
      onTap: onTap,
      borderRadius: radius,
      child: ClipRRect(
        borderRadius: radius,
        child: Stack(
          children: [
            // قاعدة بيضاء لتغطية أي شفافية (ما يبان الشطرنج)
            const Positioned.fill(child: ColoredBox(color: Colors.white)),

            // الصورة
            Positioned.fill(
              child: Image.asset(
                item.image,
                fit: BoxFit.cover,
                filterQuality: FilterQuality.low,
                gaplessPlayback: true,
                errorBuilder: (ctx, err, st) => Container(
                  alignment: Alignment.center,
                  color: Colors.black.withOpacity(0.08),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.image_not_supported_outlined, size: 36),
                      const SizedBox(height: 6),
                      Text('Missing: ${item.image}', textAlign: TextAlign.center, style: const TextStyle(fontSize: 11)),
                    ],
                  ),
                ),
              ),
            ),

            // تدرّج خفيف فقط لتحسين قراءة النص
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.20),
                    ],
                  ),
                ),
              ),
            ),

            // طبقة زجاجية خفيفة للنص والهوية
            Positioned.fill(
              child: GlassContainer(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                opacity: 0.10,
                blur: 0, // لا نطمّس الصورة
                borderRadius: BorderRadius.zero,
                tint: AppColors.blueLight,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(item.icon, size: 20),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            item.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                  ],
                ),
              ),
            ),

            // شارة عرض الكل
            PositionedDirectional(
              top: 8,
              start: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: Colors.white.withOpacity(0.25)),
                ),
                child: const Text('عرض الكل', style: TextStyle(fontSize: 11)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
