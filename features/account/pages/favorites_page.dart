import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final u = FirebaseAuth.instance.currentUser!;
    final q = FirebaseFirestore.instance.collection('favorites').where('uid', isEqualTo: u.uid).orderBy('createdAt', descending: true);

    return Scaffold(
      appBar: AppBar(title: const Text('المفضلة')),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: q.snapshots(),
        builder: (_, s) {
          if (s.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          final docs = s.data?.docs ?? [];
          if (docs.isEmpty) return const Center(child: Text('قائمة المفضلة فارغة'));
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            separatorBuilder: (_, __)=> const SizedBox(height: 8),
            itemBuilder: (_, i) {
              final m = docs[i].data();
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.favorite, color: Colors.pink),
                  title: Text(m['name']?.toString() ?? 'منتج'),
                  subtitle: Text(m['productId']?.toString() ?? ''),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => docs[i].reference.delete(),
                  ),
                  onTap: () {
                    // TODO: افتح تفاصيل المنتج productId
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}