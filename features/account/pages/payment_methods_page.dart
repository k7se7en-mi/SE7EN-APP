import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentMethodsPage extends StatelessWidget {
  const PaymentMethodsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final u = FirebaseAuth.instance.currentUser!;
    final col = FirebaseFirestore.instance.collection('users').doc(u.uid).collection('payments');

    return Scaffold(
      appBar: AppBar(title: const Text('بطاقات الدفع')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showDialog(context: context, builder: (_)=> const _AddCardDialog()),
        child: const Icon(Icons.add_card),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: col.snapshots(),
        builder: (_, s) {
          if (s.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          final docs = s.data?.docs ?? [];
          if (docs.isEmpty) return const Center(child: Text('لا توجد بطاقات محفوظة'));
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            separatorBuilder: (_, __)=> const SizedBox(height: 8),
            itemBuilder: (_, i) {
              final m = docs[i].data();
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.credit_card),
                  title: Text('${m['brand'] ?? 'Card'} •••• ${m['last4'] ?? '----'}'),
                  subtitle: Text(m['holder'] ?? ''),
                  trailing: Switch(
                    value: (m['isDefault'] ?? false) as bool,
                    onChanged: (v) async {
                      final all = await col.get();
                      final batch = FirebaseFirestore.instance.batch();
                      for (final d in all.docs) {
                        batch.update(d.reference, {'isDefault': d.id == docs[i].id ? v : false});
                      }
                      await batch.commit();
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _AddCardDialog extends StatefulWidget {
  const _AddCardDialog();

  @override
  State<_AddCardDialog> createState() => _AddCardDialogState();
}

class _AddCardDialogState extends State<_AddCardDialog> {
  final _holder = TextEditingController();
  final _brand = TextEditingController(text: 'Visa');
  final _last4 = TextEditingController();

  @override
  void dispose() { _holder.dispose(); _brand.dispose(); _last4.dispose(); super.dispose(); }

  Future<void> _add() async {
    final u = FirebaseAuth.instance.currentUser!;
    await FirebaseFirestore.instance.collection('users').doc(u.uid).collection('payments').add({
      'holder': _holder.text.trim(),
      'brand': _brand.text.trim(),
      'last4': _last4.text.trim(),
      'token': 'pm_tok_demo', // استبدلها بالتوكن من مزود الدفع لاحقًا
      'isDefault': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('إضافة بطاقة'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(controller: _holder, decoration: const InputDecoration(labelText: 'اسم حامل البطاقة')),
          TextField(controller: _brand, decoration: const InputDecoration(labelText: 'النوع (Visa/Master...)')),
          TextField(controller: _last4, decoration: const InputDecoration(labelText: 'آخر 4 أرقام'), keyboardType: TextInputType.number),
        ],
      ),
      actions: [
        TextButton(onPressed: ()=> Navigator.pop(context), child: const Text('إلغاء')),
        FilledButton(onPressed: _add, child: const Text('حفظ')),
      ],
    );
  }
}