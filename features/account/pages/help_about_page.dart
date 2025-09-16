import 'package:flutter/material.dart';

class HelpAboutPage extends StatelessWidget {
  const HelpAboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('المساعدة و عن التطبيق')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          ListTile(
            leading: Icon(Icons.help_outline),
            title: Text('الأسئلة الشائعة'),
            subtitle: Text('س: كيف أتابع طلبي؟ ج: من صفحة الطلبات...'),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.mail_outline),
            title: Text('تواصل معنا'),
            subtitle: Text('support@se7en.app'),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.privacy_tip_outlined),
            title: Text('سياسة الخصوصية'),
            subtitle: Text('نحترم خصوصيتك ولا نشارك بياناتك دون إذن.'),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.description_outlined),
            title: Text('الشروط والأحكام'),
            subtitle: Text('استخدامك للتطبيق يعني موافقتك على الشروط.'),
          ),
        ],
      ),
    );
  }
}