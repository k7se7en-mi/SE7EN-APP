// ignore_for_file: prefer_const_declarations, duplicate_ignore, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:se7en/core/localization/locale_controller.dart';
import 'package:se7en/core/localization/l10n.dart';

class CountryLanguagePage extends StatefulWidget {
  const CountryLanguagePage({super.key});
  @override
  State<CountryLanguagePage> createState() => _CountryLanguagePageState();
}

class _CountryLanguagePageState extends State<CountryLanguagePage> {
  String country = 'SA';
  String language = 'ar';

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
      country = (m['country'] ?? 'SA').toString();
      language = (m['language'] ?? 'ar').toString();
    });
  }

  Future<void> _save() async {
    final u = FirebaseAuth.instance.currentUser!;
    await FirebaseFirestore.instance.collection('users').doc(u.uid).set({
      'country': country,
      'language': language,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    // Update app locale immediately
    await LocaleController.instance.setLanguage(language);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(L.of(context, 'saved'))));
    }
  }

  @override
  Widget build(BuildContext context) {
    // ignore: prefer_const_declarations
    final countries = const ['SA','AE','KW','QA','BH','OM','EG','SD'];
    final languages = const ['ar','en'];

    return Scaffold(
      appBar: AppBar(title: Text(L.of(context, 'country_language'))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(L.of(context, 'country')),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: country,
            items: countries.map((c)=> DropdownMenuItem(value: c, child: Text(c))).toList(),
            onChanged: (v)=> setState(()=> country = v ?? country),
          ),
          const SizedBox(height: 16),
          Text(L.of(context, 'language')),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: language,
            items: languages.map((l)=> DropdownMenuItem(value: l, child: Text(l=='ar' ? L.of(context, 'arabic') : L.of(context, 'english')))).toList(),
            onChanged: (v)=> setState(()=> language = v ?? language),
          ),
          const SizedBox(height: 16),
          FilledButton(onPressed: _save, child: Text(L.of(context, 'save'))),
        ],
      ),
    );
  }
}
