import 'package:flutter/material.dart';
import '../home/home_page.dart';
import '../cart/cart_page.dart';
import '../categories/categories_page.dart';
import '../deals/deals_page.dart';
import '../account/account_page.dart';
import 'package:se7en/core/theme/glass_bottom_nav.dart';
import 'package:se7en/core/localization/l10n.dart';

class MainHomePage extends StatefulWidget {
  const MainHomePage({super.key});
  static const route = '/home';

  @override
  State<MainHomePage> createState() => _MainHomePageState();
}

class _MainHomePageState extends State<MainHomePage> {
  int _index = 0;

  final _pages = const [
    HomePage(),
    CartPage(),
    CategoriesPage(),
    DealsPage(),
    MyAccountPage(),
  ];

  List<String> _labels(BuildContext context) => [
        L.of(context, 'home'),
        L.of(context, 'cart'),
        L.of(context, 'categories'),
        L.of(context, 'deals'),
        L.of(context, 'SE7EN'),
      ];

  @override
  Widget build(BuildContext context) {
    final labels = _labels(context);

    return Scaffold(
      appBar: AppBar(
        title: RichText(
          text: TextSpan(
            children: const [
              TextSpan(
                text: 'Se',
                style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
              ),
              TextSpan(
                text: '7',
                style: TextStyle(color: Colors.lightBlueAccent, fontWeight: FontWeight.w900),
              ),
              TextSpan(text: 'en', style: TextStyle(color: Colors.white)),
            ],
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
      ),
      body: _pages[_index],
      extendBody: true, // مهم جداً عشان البودي يمتد تحت الشريط الزجاجي
      bottomNavigationBar: GlassBottomNav(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        rtl: true, // ترتيب عربي من اليمين لليسار
        items: [
          const GlassNavItemData(icon: Icons.home_outlined,        label: ''), // سيُستبدل بالـ labels أدناه
          const GlassNavItemData(icon: Icons.shopping_cart_outlined, label: ''),
          const GlassNavItemData(icon: Icons.list_alt_outlined,     label: ''),
          const GlassNavItemData(icon: Icons.local_offer_outlined,  label: ''),
          const GlassNavItemData(icon: Icons.person_outline,        label: ''),
        ].asMap().entries.map((e) {
          // نحقن نصوص الترجمة حسب ترتيب صفحاتك
          final i = e.key;
          final d = e.value;
          return GlassNavItemData(icon: d.icon, label: labels[i]);
        }).toList(),
      ),
    );
  }
}
