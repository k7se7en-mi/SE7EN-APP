import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'chat_room_page.dart';

class ChatListPage extends StatelessWidget {
  const ChatListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final q = FirebaseFirestore.instance.collection('chats')
      .where('participants', arrayContains: uid)
      .orderBy('updatedAt', descending: true);

    return Scaffold(
      appBar: AppBar(title: const Text('المحادثات')),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: q.snapshots(),
        builder: (_, s) {
          if (s.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = s.data?.docs ?? [];
          if (docs.isEmpty) return const Center(child: Text('لا توجد محادثات بعد'));

          return ListView.separated(
            padding: const EdgeInsets.all(8),
            itemCount: docs.length,
            separatorBuilder: (_, __)=> const Divider(height: 1),
            itemBuilder: (_, i) {
              final d = docs[i];
              final m = d.data();
              final last = (m['lastMessage'] ?? '') as String;
              final unread = (m['unread']?[uid] ?? 0) as int;
              final otherId = (m['participants'] as List).firstWhere((x) => x != uid);

              return ListTile(
                leading: CircleAvatar(child: Text(otherId.toString().substring(0,2))),
                title: Text('شات مع: $otherId', maxLines: 1, overflow: TextOverflow.ellipsis),
                subtitle: Text(last.isEmpty ? 'ابدأ المحادثة' : last, maxLines: 1, overflow: TextOverflow.ellipsis),
                trailing: unread > 0 ? CircleAvatar(radius: 12, child: Text('$unread')) : null,
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(
                    builder: (_)=> ChatRoomPage(chatRef: d.reference, peerId: otherId),
                  ));
                },
              );
            },
          );
        },
      ),
    );
  }
}