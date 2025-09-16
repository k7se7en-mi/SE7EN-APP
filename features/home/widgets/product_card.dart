import 'package:flutter/material.dart';
import '../../../core/widgets/glass_container.dart';
import '../../../core/widgets/rating_stars.dart';
import '../../../core/theme/app_colors.dart';
import '../data/product_model.dart';
import 'package:se7en/features/store/product_details_page.dart';

class ProductCard extends StatefulWidget {
  final Product product;
  const ProductCard({super.key, required this.product});

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  bool liked = false;

  @override
  Widget build(BuildContext context) {
    final p = widget.product;

    return SizedBox(
      width: 210, // كان 220
      child: InkWell(
        borderRadius: BorderRadius.circular(14), // كان 16
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ProductDetailsPage(product: p)),
          );
        },
        child: GlassContainer(
          padding: const EdgeInsets.all(8), // كان 10
          borderRadius: BorderRadius.circular(14), // تصغير عام
          // ✅ إطار أرفع
          border: Border.all(color: AppColors.glassBorder, width: 0.8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // صورة بإطار أصغر
              ClipRRect(
                borderRadius: BorderRadius.circular(10), // كان 12
                child: AspectRatio(
                  aspectRatio: 4 / 3,
                  child: Image.network(p.imageUrl, fit: BoxFit.cover),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                p.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  RatingStars(rating: p.rating, size: 13), // شوي أصغر
                  const SizedBox(width: 4),
                  Text('(${p.reviews})', style: const TextStyle(color: Colors.white70, fontSize: 11)),
                ],
              ),
              const Spacer(),
              Row(
                children: [
                  Text('${p.price} ر.س',
                      style: const TextStyle(
                        color: AppColors.orangeDeep,
                        fontWeight: FontWeight.w800,
                      )),
                  const SizedBox(width: 6),
                  if (p.oldPrice != null)
                    Text(
                      '${p.oldPrice} ر.س',
                      style: const TextStyle(
                        color: Colors.white54,
                        decoration: TextDecoration.lineThrough,
                        fontSize: 11,
                      ),
                    ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => setState(() => liked = !liked),
                    icon: Icon(liked ? Icons.favorite : Icons.favorite_border, size: 20),
                    tooltip: 'إعجاب',
                  ),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.orangeDeep,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      minimumSize: const Size(40, 36),
                    ),
                    child: const Icon(Icons.shopping_cart, size: 16),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
