// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SecurityPage extends StatelessWidget {
  const SecurityPage({super.key});

  Future<void> _changePassword(BuildContext context) async {
    final ctrl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('تغيير كلمة السر'),
        content: TextField(controller: ctrl, obscureText: true, decoration: const InputDecoration(labelText: 'كلمة سر جديدة')),
        actions: [
          TextButton(onPressed: ()=> Navigator.pop(context, false), child: const Text('إلغاء')),
          FilledButton(onPressed: ()=> Navigator.pop(context, true), child: const Text('تأكيد')),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await FirebaseAuth.instance.currentUser?.updatePassword(ctrl.text.trim());
      // قد يتطلب re-auth في بعض الحالات
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم التغيير')));
    } catch (e) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطأ: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;
    return Scaffold(
      appBar: AppBar(title: const Text('الأمان')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(title: const Text('البريد'), subtitle: Text(user.email ?? '---')),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.password),
            title: const Text('تغيير كلمة السر'),
            onTap: ()=> _changePassword(context),
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: const Text('جلسات/أجهزة الدخول (عرض لاحقًا)'),
          ),
        ],
      ),
    );
  }
}