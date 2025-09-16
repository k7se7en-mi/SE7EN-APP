class Product {
  final String id;
  final String title;
  final String imageUrl;
  final String sellerName;
  final double price;
  final double? oldPrice;
  final double rating; // 0..5
  final int reviews;
  final String description;

  // مضافة لتوافق HomePage
  final String? category; // فئة اختيارية
  final DateTime createdAt; // للترتيب بالأحدث

  const Product({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.sellerName,
    required this.price,
    this.oldPrice,
    required this.rating,
    required this.reviews,
    required this.description,
    this.category,
    required this.createdAt,
  });
}

// أقسام الصفحة
const homeSections = <String>[
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

// بيانات تجريبية متكررة
final _categories = <String>[
  'لابتوبات',
  'جوالات',
  'إكسسوارات',
  'العناية الشخصية',
  'العطور',
  'النظارات',
  'الأزياء',
];

final sampleProducts = List<Product>.generate(12, (i) {
  return Product(
    id: 'p$i',
    title: 'حافظة ماك بوك ${i + 1}',
    imageUrl: 'https://picsum.photos/seed/se7en$i/400/300',
    sellerName: 'مسحوق الصخور',
    price: 69.80,
    oldPrice: i.isEven ? 128.0 : null,
    rating: 4.6,
    reviews: 97 + i,
    description:
        'وصف المنتج التجريبي رقم ${i + 1}. خامات ممتازة، حماية عالية، وضمان استرجاع خلال 15 يوم.',
    category: _categories[i % _categories.length],
    createdAt: DateTime.now().subtract(Duration(days: i)),
  );
});

// مساعد بسيط لتزويد الصفحة بالبيانات حسب القسم
class MockData {
  static List<Product> productsFor(String section) {
    // نعيد نسخة جديدة لكل قسم لتفادي التعديل على المصدر الأصلي
    return List<Product>.from(sampleProducts);
  }
}
