import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class ChatRoomPage extends StatefulWidget {
  final DocumentReference<Map<String, dynamic>> chatRef;
  final String peerId; // الطرف الآخر
  const ChatRoomPage({super.key, required this.chatRef, required this.peerId});

  @override
  State<ChatRoomPage> createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  final _msg = TextEditingController();
  final _scroll = ScrollController();
  final _picker = ImagePicker();

  bool _sending = false;

  String get uid => FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    _markAsRead();
    _setTyping(true);
  }

  @override
  void dispose() {
    _setTyping(false);
    _msg.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _markAsRead() async {
    await widget.chatRef.update({'unread.$uid': 0});
  }

  Future<void> _setTyping(bool v) async {
    await widget.chatRef.update({'typing.$uid': v});
  }

  Future<void> _sendText() async {
    final text = _msg.text.trim();
    if (text.isEmpty || _sending) return;
    setState(() => _sending = true);

    final now = FieldValue.serverTimestamp();
    await widget.chatRef.collection('messages').add({
      'senderId': uid,
      'text': text,
      'imageUrl': null,
      'createdAt': now,
      'status': 'sent',
    });

    await widget.chatRef.update({
      'lastMessage': text,
      'lastSender': uid,
      'updatedAt': now,
      'unread.${widget.peerId}': FieldValue.increment(1),
    });

    _msg.clear();
    setState(() => _sending = false);
    await _scrollToBottom();
  }

  // ====== الإرفاق بالمعرض/الكاميرا عبر BottomSheet ======
  Future<void> _openImagePicker() async {
    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('اختيار من المعرض'),
              onTap: () async {
                Navigator.pop(context);
                final file = await _picker.pickImage(
                  source: ImageSource.gallery,
                  imageQuality: 75,
                  maxWidth: 1920,
                  maxHeight: 1920,
                );
                if (file != null) await _uploadAndSendImage(file);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('التصوير بالكاميرا'),
              onTap: () async {
                Navigator.pop(context);
                final file = await _picker.pickImage(
                  source: ImageSource.camera,
                  imageQuality: 75,
                  maxWidth: 1920,
                  maxHeight: 1920,
                );
                if (file != null) await _uploadAndSendImage(file);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _uploadAndSendImage(XFile file) async {
    try {
      setState(() => _sending = true);

      final storageRef = FirebaseStorage.instance.ref(
        'chat_images/${widget.chatRef.id}/${DateTime.now().millisecondsSinceEpoch}_${file.name}',
      );
      await storageRef.putFile(File(file.path));
      final url = await storageRef.getDownloadURL();

      final now = FieldValue.serverTimestamp();
      await widget.chatRef.collection('messages').add({
        'senderId': uid,
        'text': '',
        'imageUrl': url,
        'createdAt': now,
        'status': 'sent',
      });

      await widget.chatRef.update({
        'lastMessage': '📷 صورة',
        'lastSender': uid,
        'updatedAt': now,
        'unread.${widget.peerId}': FieldValue.increment(1),
      });

      await _scrollToBottom();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تعذر رفع الصورة: $e')),
      );
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }
  // ===============================================

  Future<void> _scrollToBottom() async {
    await Future.delayed(const Duration(milliseconds: 120));
    if (!_scroll.hasClients) return;
    _scroll.animateTo(
      _scroll.position.minScrollExtent,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final messagesQ = widget.chatRef
        .collection('messages')
        .orderBy('createdAt', descending: true)
        .limit(40);

    return Scaffold(
      appBar: AppBar(
        title: Text('محادثة مع: ${widget.peerId.substring(0, 6)}...'),
        actions: [
          // مؤشر كتابة الطرف الآخر
          StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            stream: widget.chatRef.snapshots(),
            builder: (_, s) {
              final typing = (s.data?.data()?['typing'] ?? {}) as Map<String, dynamic>;
              final peerTyping = (typing[widget.peerId] ?? false) as bool;
              return peerTyping
                  ? const Padding(
                      padding: EdgeInsets.only(right: 16),
                      child: Center(child: Text('يكتب...')),
                    )
                  : const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: messagesQ.snapshots(),
              builder: (_, s) {
                if (s.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final docs = s.data?.docs ?? [];
                if (docs.isEmpty) {
                  return const Center(child: Text('ابدأ المحادثة'));
                }
                return ListView.builder(
                  controller: _scroll,
                  reverse: true, // أحدث رسالة تحت
                  padding: const EdgeInsets.all(12),
                  itemCount: docs.length,
                  itemBuilder: (_, i) {
                    final m = docs[i].data();
                    final mine = m['senderId'] == uid;
                    final hasImage = (m['imageUrl'] ?? '').toString().isNotEmpty;
                    final hasText = (m['text'] ?? '').toString().isNotEmpty;

                    return Align(
                      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 280),
                        child: Card(
                          color: mine ? Colors.deepOrange.shade400 : null,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (hasImage)
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.network(
                                      m['imageUrl'],
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) =>
                                          const Icon(Icons.broken_image),
                                    ),
                                  ),
                                if (hasText) ...[
                                  if (hasImage) const SizedBox(height: 6),
                                  Text(m['text']),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: _sending ? null : _openImagePicker,
                    icon: const Icon(Icons.attach_file),
                    tooltip: 'إرفاق صورة',
                  ),
                  Expanded(
                    child: TextField(
                      controller: _msg,
                      onChanged: (_) => _setTyping(_msg.text.trim().isNotEmpty),
                      decoration: const InputDecoration(
                        hintText: 'اكتب رسالة...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: _sending ? null : _sendText,
                    child: const Text('إرسال'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}