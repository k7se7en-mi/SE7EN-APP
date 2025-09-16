// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddProductPage extends StatefulWidget {
  const AddProductPage({super.key});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _priceController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _sellerNameController = TextEditingController();

  String _category = 'ختم'; // القيمة الافتراضية

  Future<void> _addProduct() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      await FirebaseFirestore.instance.collection('products').add({
        'title': _titleController.text.trim(),
        'price': double.parse(_priceController.text.trim()),
        'imageUrl': _imageUrlController.text.trim(),
        'sellerName': _sellerNameController.text.trim(),
        'category': _category,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ تم إضافة المنتج بنجاح')),
        );
        _formKey.currentState!.reset();
        setState(() => _category = 'ختم');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ خطأ: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: Directionality.of(context),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('إضافة منتج'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'اسم المنتج'),
                  validator: (v) => v!.isEmpty ? 'أدخل اسم المنتج' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _priceController,
                  decoration: const InputDecoration(labelText: 'السعر'),
                  keyboardType: TextInputType.number,
                  validator: (v) => v!.isEmpty ? 'أدخل السعر' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _imageUrlController,
                  decoration: const InputDecoration(labelText: 'رابط الصورة'),
                  validator: (v) => v!.isEmpty ? 'أدخل رابط الصورة' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _sellerNameController,
                  decoration: const InputDecoration(labelText: 'اسم التاجر'),
                  validator: (v) => v!.isEmpty ? 'أدخل اسم التاجر' : null,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _category,
                  decoration: const InputDecoration(labelText: 'القسم'),
                  items: const [
                    DropdownMenuItem(value: 'ختم', child: Text('ختم')),
                    DropdownMenuItem(value: 'أخرى', child: Text('أخرى')),
                  ],
                  onChanged: (v) => setState(() => _category = v ?? 'ختم'),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('إضافة المنتج'),
                  onPressed: _addProduct,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
