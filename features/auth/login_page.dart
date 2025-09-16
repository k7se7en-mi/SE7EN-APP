// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/widgets/glass_container.dart';
import '../../core/theme/app_colors.dart';
import '../main_home/main_home_page.dart';
import 'auth_service.dart';
import 'register_page.dart';
import 'package:se7en/features/auth/otp_reset_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  static const route = '/login';

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _svc = AuthService();
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _pass  = TextEditingController();
  bool _loading = false;
  bool _obscure = true;

  @override
  void dispose() {
    _email.dispose();
    _pass.dispose();
    super.dispose();
  }

  Future<void> _onLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await _svc.signIn(email: _email.text, password: _pass.text);
      if (!mounted) return;
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainHomePage()));
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message ?? e.code)));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: Directionality.of(context),
      child: Scaffold(
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: GlassContainer(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // الشعار
                      Image.asset('assets/se7en_logo.png', height: 200),
                      const SizedBox(height: 12),
                      const Text('مرحبًا بك في Se7en', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      const Text(
  '“تسوق بزجاجية… أناقة وسرعة على ذوق”',
  style: TextStyle(fontSize: 14, color: Colors.lightBlue, fontStyle: FontStyle.italic),
  textAlign: TextAlign.center,
),
const SizedBox(height: 16),
// ...

                      TextFormField(
                        controller: _email,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'الإيميل',
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                        validator: (v) => (v == null || !v.contains('@')) ? 'أدخل بريدًا صحيحًا' : null,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _pass,
                        obscureText: _obscure,
                        decoration: InputDecoration(
                          labelText: 'كلمة المرور',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
                            onPressed: () => setState(() => _obscure = !_obscure),
                          ),
                        ),
                        validator: (v) => (v == null || v.length < 6) ? '6 أحرف على الأقل' : null,
                      ),
                      const SizedBox(height: 12),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _loading ? null : _onLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.orangeDeep, foregroundColor: Colors.white,
                            minimumSize: const Size.fromHeight(46),
                          ),
                          child: _loading
                              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                              : const Text('تسجيل الدخول'),
                        ),
                      ),

                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton(
                          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OtpResetPage())),
                          child: const Text('نسيت كلمة المرور؟'),
                        ),
                      ),

const SizedBox(height: 16),
const Text(
  'تابعنا على Se7en Media',
  style: TextStyle(color: Colors.lightBlue, fontSize: 14),
),
const SizedBox(height: 8),
Row(
  mainAxisAlignment: MainAxisAlignment.center,
  children: const [
    Icon(Icons.facebook, size: 32, color: Colors.lightBlue),
    SizedBox(width: 20),
    Icon(Icons.camera_alt_outlined, size: 32, color: Colors.lightBlue),
    SizedBox(width: 20),
    Icon(Icons.snapchat, size: 32, color: Colors.lightBlue),
  ],
),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterPage())),
                        child: const Text('ليس لديك حساب؟ إنشاء حساب'),
                      ),

                      const SizedBox(height: 12),
                      const Text('© 2025 Se7en — جميع الحقوق محفوظة', style: TextStyle(color: Colors.lightBlue, fontSize: 12)),
                      const SizedBox(height: 9),
                      
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
