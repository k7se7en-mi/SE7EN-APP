import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'pages/edit_profile_page.dart';
import 'pages/orders_page.dart';
import 'pages/returns_page.dart';
import 'pages/addresses_page.dart';
import 'pages/payment_methods_page.dart';
import 'pages/favorites_page.dart';
import 'pages/notifications_page.dart';
import 'pages/security_page.dart';
import 'package:se7en/features/chat/chat_list_page.dart';
import 'pages/country_language_page.dart';
import 'pages/help_about_page.dart';
import '../auth/login_page.dart';
import 'package:se7en/core/localization/l10n.dart';
import 'package:se7en/core/layout/bottom_bar_utils.dart';

class MyAccountPage extends StatelessWidget {
  const MyAccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Scaffold(
        extendBody: true, // مهم جداً عشان البودي يمتد تحت الشريط الزجاجي
        appBar: AppBar(title: Text(L.of(context, 'my_account'))),
        body: WithBottomPadding(
          extra: 0,
          child: Center(
            child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.person_outline, size: 72),
                const SizedBox(height: 12),
                Text(L.of(context, 'please_login')),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginPage()),
                    );
                  },
                  child: Text(L.of(context, 'login')),
                ),
              ],
            ),
            ),
          ),
        ),
      );
    }

    final doc = FirebaseFirestore.instance.collection('users').doc(user.uid);

    return Scaffold(
      appBar: AppBar(title: Text(L.of(context, 'my_account'))),
      body: WithBottomPadding(
        extra: 0,
        child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: doc.snapshots(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final data = snap.data?.data() ?? {};
          final name = (data['name'] ?? user.displayName ?? 'مستخدم Se7en').toString();
          final email = (data['email'] ?? user.email ?? '---').toString();
          final photoUrl = (data['photoUrl'] ?? user.photoURL)?.toString();

          final items = <_AccountItem>[
            // ✅ قسم الملف الشخصي برمز شخص
            _AccountItem(L.of(context, 'profile'), Icons.person, () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EditProfilePage(initial: {
                    'name': name,
                    'email': email,
                    'photoUrl': photoUrl,
                    'phone': data['phone'],
                    'country': data['country'],
                    'language': data['language'],
                  }),
                ),
              );
            }),
            _AccountItem(L.of(context, 'my_orders'), Icons.receipt_long, () => Navigator.push(context, MaterialPageRoute(builder: (_)=> const OrdersPage()))),
            _AccountItem(L.of(context, 'returns'), Icons.assignment_return, () => Navigator.push(context, MaterialPageRoute(builder: (_)=> const ReturnsPage()))),
            _AccountItem(L.of(context, 'addresses'), Icons.location_on, () => Navigator.push(context, MaterialPageRoute(builder: (_)=> const AddressesPage()))),
            _AccountItem(L.of(context, 'payment_cards'), Icons.credit_card, () => Navigator.push(context, MaterialPageRoute(builder: (_)=> const PaymentMethodsPage()))),
            _AccountItem(L.of(context, 'favorites'), Icons.favorite, () => Navigator.push(context, MaterialPageRoute(builder: (_)=> const FavoritesPage()))),
            _AccountItem(L.of(context, 'notifications'), Icons.notifications, () => Navigator.push(context, MaterialPageRoute(builder: (_)=> const NotificationsPage()))),
            _AccountItem(L.of(context, 'security'), Icons.lock, () => Navigator.push(context, MaterialPageRoute(builder: (_)=> const SecurityPage()))),
            _AccountItem(L.of(context, 'country_language'), Icons.language, () => Navigator.push(context, MaterialPageRoute(builder: (_)=> const CountryLanguagePage()))),
            _AccountItem(L.of(context, 'help_about'), Icons.help_outline, () => Navigator.push(context, MaterialPageRoute(builder: (_)=> const HelpAboutPage()))),
            _AccountItem(L.of(context, 'chats'), Icons.chat, () => Navigator.push(context, MaterialPageRoute(builder: (_)=> const ChatListPage()))),
          ];

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _ProfileHeader(name: name, email: email, photoUrl: photoUrl),
              const SizedBox(height: 12),
              ...items.map((e)=> AccountTile(e)).toList(),
              const SizedBox(height: 8),
              FilledButton.icon(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  if (!context.mounted) return;
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    LoginPage.route,
                    (route) => false,
                  );
                },
                icon: const Icon(Icons.logout),
                label: Text(L.of(context, 'logout')),
              ),
              const SizedBox(height: 24),
            ],
          );
        },
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final String name, email;
  final String? photoUrl;
  const _ProfileHeader({required this.name, required this.email, this.photoUrl});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            CircleAvatar(
              radius: 34,
              backgroundImage: (photoUrl!=null && photoUrl!.isNotEmpty) ? NetworkImage(photoUrl!) : null,
              child: (photoUrl==null || photoUrl!.isEmpty) ? const Icon(Icons.person, size: 34) : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(email, style: TextStyle(color: Colors.grey.shade600)),
                ],
              ),
            ),
            IconButton(
              onPressed: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_)=> EditProfilePage(initial: {'name': name, 'email': email, 'photoUrl': photoUrl}),
                  ),
                );
              },
              icon: const Icon(Icons.edit),
            ),
          ],
        ),
      ),
    );
  }
}

class _AccountItem {
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  _AccountItem(this.title, this.icon, this.onTap);
}

class AccountTile extends StatelessWidget {
  final _AccountItem item;
  const AccountTile(this.item, {super.key});
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: Icon(item.icon),
        title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.w600)),
        trailing: Icon(
          Directionality.of(context) == TextDirection.rtl
              ? Icons.chevron_left
              : Icons.chevron_right,
        ),
        onTap: item.onTap,
      ),
    );
  }
}
