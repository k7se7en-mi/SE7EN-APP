import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ReturnsPage extends StatelessWidget {
  const ReturnsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final u = FirebaseAuth.instance.currentUser!;
    final q = FirebaseFirestore.instance.collection('returns')
      .where('uid', isEqualTo: u.uid).orderBy('createdAt', descending: true);

    return Scaffold(
      appBar: AppBar(title: const Text('المرتجعات')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showDialog(context: context, builder: (_)=> const _CreateReturnDialog()),
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: q.snapshots(),
        builder: (_, s) {
          if (s.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          final docs = s.data?.docs ?? [];
          if (docs.isEmpty) return const Center(child: Text('لا توجد طلبات إرجاع'));
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            separatorBuilder: (_, __)=> const SizedBox(height: 8),
            itemBuilder: (_, i) {
              final m = docs[i].data();
              return Card(
                child: ListTile(
                  title: Text('إرجاع لطلب: ${m['orderId'] ?? ''}'),
                  subtitle: Text('الحالة: ${m['status'] ?? 'review'} • السبب: ${m['reason'] ?? ''}'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _CreateReturnDialog extends StatefulWidget {
  const _CreateReturnDialog();
  @override
  State<_CreateReturnDialog> createState() => _CreateReturnDialogState();
}

class _CreateReturnDialogState extends State<_CreateReturnDialog> {
  final _order = TextEditingController();
  final _reason = TextEditingController();

  @override
  void dispose() { _order.dispose(); _reason.dispose(); super.dispose(); }

  Future<void> _create() async {
    final u = FirebaseAuth.instance.currentUser!;
    await FirebaseFirestore.instance.collection('returns').add({
      'orderId': _order.text.trim(),
      'uid': u.uid,
      'reason': _reason.text.trim(),
      'images': [],
      'status': 'review',
      'createdAt': FieldValue.serverTimestamp(),
    });
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('طلب إرجاع'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(controller: _order, decoration: const InputDecoration(labelText: 'رقم الطلب')),
          TextField(controller: _reason, decoration: const InputDecoration(labelText: 'السبب')),
        ],
      ),
      actions: [
        TextButton(onPressed: ()=> Navigator.pop(context), child: const Text('إلغاء')),
        FilledButton(onPressed: _create, child: const Text('إرسال')),
      ],
    );
  }
}