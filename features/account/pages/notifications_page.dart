import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});
  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  bool orders = true, offers = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final u = FirebaseAuth.instance.currentUser!;
    final d = await FirebaseFirestore.instance.collection('users').doc(u.uid).get();
    final m = d.data() ?? {};
    setState(() {
      orders = (m['notif_orders'] ?? true) as bool;
      offers = (m['notif_offers'] ?? true) as bool;
    });
  }

  Future<void> _save() async {
    final u = FirebaseAuth.instance.currentUser!;
    await FirebaseFirestore.instance.collection('users').doc(u.uid)
      .set({'notif_orders': orders, 'notif_offers': offers}, SetOptions(merge: true));
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم الحفظ')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الإشعارات')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SwitchListTile(
            title: const Text('إشعارات الطلبات'),
            value: orders, onChanged: (v)=> setState(()=> orders=v),
          ),
          SwitchListTile(
            title: const Text('إشعارات العروض'),
            value: offers, onChanged: (v)=> setState(()=> offers=v),
          ),
          const SizedBox(height: 12),
          FilledButton(onPressed: _save, child: const Text('حفظ')),
        ],
      ),
    );
  }
}