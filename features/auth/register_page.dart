import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/widgets/glass_container.dart';
import '../../core/theme/app_colors.dart';
import '../main_home/main_home_page.dart';
import 'auth_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _svc = AuthService();
  final _formKey = GlobalKey<FormState>();

  final _name  = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _pass1 = TextEditingController();
  final _pass2 = TextEditingController();

  bool _loading = false;
  bool _hide1 = true;
  bool _hide2 = true;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _pass1.dispose();
    _pass2.dispose();
    super.dispose();
  }

  String? _validateName(String? v) {
    if (v == null || v.trim().isEmpty) return 'الاسم مطلوب';
    if (v.trim().split(' ').length < 2) return 'اكتب اسمًا ثنائيًا';
    if (v.trim().length < 3) return 'أدخل اسمًا صحيحًا';
    return null;
  }

  String? _validateEmail(String? v) {
    if (v == null || v.trim().isEmpty) return 'الإيميل مطلوب';
    if (!v.contains('@') || !v.contains('.')) return 'أدخل بريدًا صحيحًا';
    return null;
  }

  String? _validatePhone(String? v) {
    if (v == null || v.trim().isEmpty) return null; // اختياري
    final p = v.replaceAll(' ', '');
    if (!(p.startsWith('+') || RegExp(r'^[0-9]+$').hasMatch(p))) {
      return 'أدخل رقمًا صحيحًا (يفضل بصيغة دولية +966…)';
    }
    if (p.length < 8) return 'رقم قصير';
    return null;
  }

  String? _validatePass1(String? v) {
    if (v == null || v.isEmpty) return 'كلمة المرور مطلوبة';
    if (v.length < 6) return '6 أحرف على الأقل';
    return null;
  }

  String? _validatePass2(String? v) {
    if (v == null || v.isEmpty) return 'أعد كتابة كلمة المرور';
    if (v != _pass1.text) return 'التأكيد لا يطابق كلمة المرور';
    return null;
  }

  Future<void> _onRegister() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await _svc.signUp(
        name: _name.text,
        email: _email.text,
        password: _pass1.text,
        phone: _phone.text,
      );
      if (!mounted) return;
      // بعد النجاح ننتقل للرئيسية
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MainHomePage()),
        (_) => false,
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message ?? e.code)));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('خطأ غير متوقع: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: Directionality.of(context),
      child: Scaffold(
        appBar: AppBar(title: const Text('إنشاء حساب')),
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
                      TextFormField(
                        controller: _name,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: 'الاسم الثنائي',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                        validator: _validateName,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _email,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: 'الإيميل',
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                        validator: _validateEmail,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _phone,
                        keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: 'رقم الجوال',
                          prefixIcon: Icon(Icons.phone_iphone),
                        ),
                        validator: _validatePhone,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _pass1,
                        obscureText: _hide1,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          labelText: 'كلمة المرور',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            onPressed: () => setState(() => _hide1 = !_hide1),
                            icon: Icon(_hide1 ? Icons.visibility : Icons.visibility_off),
                          ),
                        ),
                        validator: _validatePass1,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _pass2,
                        obscureText: _hide2,
                        decoration: InputDecoration(
                          labelText: 'تأكيد كلمة المرور',
                          prefixIcon: const Icon(Icons.lock_reset_outlined),
                          suffixIcon: IconButton(
                            onPressed: () => setState(() => _hide2 = !_hide2),
                            icon: Icon(_hide2 ? Icons.visibility : Icons.visibility_off),
                          ),
                        ),
                        validator: _validatePass2,
                      ),
                      const SizedBox(height: 14),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _loading ? null : _onRegister,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.orangeDeep,
                            foregroundColor: Colors.white,
                            minimumSize: const Size.fromHeight(46),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _loading
                              ? const SizedBox(
                                  width: 20, height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white))
                              : const Text('إنشاء الحساب'),
                        ),
                      ),

                      const SizedBox(height: 8),
                      const Text(
                        'بإنشائك حسابًا فأنت توافق على الشروط وسياسة الخصوصية.',
                        style: TextStyle(fontSize: 12, color: Colors.white70),
                        textAlign: TextAlign.center,
                      ),
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
