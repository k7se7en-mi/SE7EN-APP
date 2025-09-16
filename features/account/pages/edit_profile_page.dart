import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditProfilePage extends StatefulWidget {
  final Map<String, dynamic>? initial;
  const EditProfilePage({super.key, this.initial});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _photo = TextEditingController();

  @override
  void initState() {
    super.initState();
    _name.text  = widget.initial?['name']?.toString() ?? '';
    _phone.text = widget.initial?['phone']?.toString() ?? '';
    _photo.text = widget.initial?['photoUrl']?.toString() ?? '';
  }

  @override
  void dispose() { _name.dispose(); _phone.dispose(); _photo.dispose(); super.dispose(); }

  Future<void> _save() async {
    final u = FirebaseAuth.instance.currentUser;
    if (u == null) return;
    await FirebaseFirestore.instance.collection('users').doc(u.uid).set({
      'name': _name.text.trim(),
      'phone': _phone.text.trim(),
      'photoUrl': _photo.text.trim().isEmpty ? null : _photo.text.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تعديل الملف الشخصي')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(controller: _name, decoration: const InputDecoration(labelText: 'الاسم')),
          const SizedBox(height: 8),
          TextField(controller: _phone, decoration: const InputDecoration(labelText: 'الجوال'), keyboardType: TextInputType.phone),
          const SizedBox(height: 8),
          TextField(controller: _photo, decoration: const InputDecoration(labelText: 'رابط الصورة (اختياري)')),
          const SizedBox(height: 16),
          FilledButton(onPressed: _save, child: const Text('حفظ')),
        ],
      ),
    );
  }
}