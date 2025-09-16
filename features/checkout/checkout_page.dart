// ignore_for_file: unused_import, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:se7en/services/orders_service.dart';
import 'package:se7en/features/cart/data/cart_item_model.dart';// تأكد من المسار
import 'package:se7en/features/cart/data/cart_repo.dart'; // تأكد من المسار

class CheckoutPage extends StatefulWidget {
  final double initialSub;
  final double initialVat;
  const CheckoutPage({super.key, this.initialSub = 0, this.initialVat = 0});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _orders = OrdersService();
  final _cartRepo = CartRepo(); // مصدر بيانات السلة عندك

  final _fullNameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();

  bool _loading = false;

  @override
  void dispose() {
    _fullNameCtrl.dispose();
    _phoneCtrl.dispose();
    _cityCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  Future<void> _placeOrder() async {
    final cartItems = _cartRepo.items; // تأكد أن عندك getter اسمه items
    if (cartItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('السلة فارغة ❌')),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      // تجهيز عناصر السلة
      final items = cartItems.map((i) => {
            'productId': i.id,
            'title': i.title,
            'price': i.price,
            'qty': i.qty,
            'imageUrl': i.imageUrl,
          }).toList();

      final total =
          cartItems.fold<double>(0, (s, i) => s + i.price * i.qty);

      // إنشاء الطلب في Firestore
      final orderId = await _orders.placeOrder(
        items: items,
        total: total,
        shippingAddress: {
          'name': _fullNameCtrl.text,
          'phone': _phoneCtrl.text,
          'city': _cityCtrl.text,
          'address': _addressCtrl.text,
        },
      );

      // نجاح
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تم إنشاء الطلب #$orderId ✅')),
      );

      _cartRepo.clear();

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/orders');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل إنشاء الطلب: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("إتمام الشراء")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _fullNameCtrl,
            decoration: const InputDecoration(labelText: "الاسم الكامل"),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _phoneCtrl,
            decoration: const InputDecoration(labelText: "رقم الهاتف"),
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _cityCtrl,
            decoration: const InputDecoration(labelText: "المدينة"),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _addressCtrl,
            decoration: const InputDecoration(labelText: "العنوان"),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 48,
            child: ElevatedButton.icon(
              onPressed: _loading ? null : _placeOrder,
              icon: _loading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.check),
              label: Text(_loading ? "جاري المعالجة..." : "إتمام الشراء"),
            ),
          ),
        ],
      ),
    );
  }
}
