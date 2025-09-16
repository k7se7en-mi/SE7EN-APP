// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/widgets/glass_container.dart';
import '../../core/theme/app_colors.dart';

class OtpResetPage extends StatefulWidget {
  const OtpResetPage({super.key});

  @override
  State<OtpResetPage> createState() => _OtpResetPageState();
}

class _OtpResetPageState extends State<OtpResetPage> {
  final _auth = FirebaseAuth.instance;

  // Controllers
  final _phoneCtrl = TextEditingController();     // مثال: +9665XXXXXXXX
  final _codeCtrl  = TextEditingController();     // كود OTP
  final _pass1Ctrl = TextEditingController();     // كلمة المرور الجديدة
  final _pass2Ctrl = TextEditingController();     // تأكيد كلمة المرور

  // State
  String? _verificationId;
  int? _resendToken;
  bool _sendingCode = false;
  bool _verifying   = false;
  bool _canResend   = false;
  bool _showPassForm = false;
  int _seconds = 60;
  Timer? _timer;

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _codeCtrl.dispose();
    _pass1Ctrl.dispose();
    _pass2Ctrl.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() {
      _seconds = 60;
      _canResend = false;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_seconds <= 1) {
        t.cancel();
        setState(() => _canResend = true);
      } else {
        setState(() => _seconds--);
      }
    });
  }

  Future<void> _sendCode({bool isResend = false}) async {
    final phone = _phoneCtrl.text.trim();
    if (phone.isEmpty || !phone.startsWith('+')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('أدخل رقم جوال بصيغة دولية، مثال: +9665XXXXXXXX')),
      );
      return;
    }
    setState(() { _sendingCode = true; });

    await _auth.verifyPhoneNumber(
      phoneNumber: phone,
      forceResendingToken: isResend ? _resendToken : null,
      timeout: const Duration(seconds: 60),
      verificationCompleted: (PhoneAuthCredential credential) async {
        // على بعض الأجهزة قد يتم التحقق تلقائياً
        try {
          await _auth.signInWithCredential(credential);
          setState(() {
            _showPassForm = true; // جاهزين لتعيين كلمة المرور
          });
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('فشل التحقق التلقائي: $e')));
        }
      },
      verificationFailed: (FirebaseAuthException e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('فشل الإرسال: ${e.message ?? e.code}')));
        setState(() { _sendingCode = false; });
      },
      codeSent: (String verificationId, int? resendToken) {
        setState(() {
          _verificationId = verificationId;
          _resendToken = resendToken;
          _sendingCode = false;
        });
        _startTimer();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم إرسال رمز التحقق')));
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        // يحتفظ بالـ verificationId إن انتهى الوقت
        setState(() {
          _verificationId = verificationId;
          _sendingCode = false;
          _canResend = true;
        });
      },
    );
  }

  Future<void> _verifyCode() async {
    if (_verificationId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('أرسل الكود أولاً')));
      return;
    }
    final smsCode = _codeCtrl.text.trim();
    if (smsCode.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('أدخل رمز تحقق صحيح')));
      return;
    }
    setState(() { _verifying = true; });
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: smsCode,
      );
      // تسجيل دخول (أو ربطセشن) بهذا الاعتماد
      await _auth.signInWithCredential(credential);

      // الآن المستخدم مسجّل دخول ويمكنه تعيين كلمة مرور
      setState(() {
        _showPassForm = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم التحقق بنجاح')));
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('فشل التحقق: ${e.message ?? e.code}')));
    } finally {
      if (mounted) setState(() { _verifying = false; });
    }
  }

  Future<void> _setNewPassword() async {
    final p1 = _pass1Ctrl.text.trim();
    final p2 = _pass2Ctrl.text.trim();
    if (p1.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('كلمة المرور يجب أن تكون 6 أحرف على الأقل')));
      return;
    }
    if (p1 != p2) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('التأكيد لا يطابق كلمة المرور')));
      return;
    }
    final user = _auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('لم يتم تسجيل الدخول بعد التحقق')));
      return;
    }
    try {
      await user.updatePassword(p1);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم تعيين كلمة المرور الجديدة بنجاح ✅')));
      if (mounted) Navigator.pop(context); // رجوع للصفحة السابقة (مثلاً شاشة الدخول)
    } on FirebaseAuthException catch (e) {
      // في حال احتاج "تسجيل دخول حديث" يفترض أنّنا تونا موقّعين بالهاتف.
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطأ: ${e.message ?? e.code}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: Directionality.of(context),
      child: Scaffold(
        appBar: AppBar(title: const Text('إعادة تعيين عبر OTP')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            GlassContainer(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('الخطوة ١: أدخل رقم جوالك', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _phoneCtrl,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'رقم الجوال (بصيغة دولية) مثال: +9665XXXXXXXX',
                      prefixIcon: Icon(Icons.phone_iphone),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _sendingCode ? null : () => _sendCode(isResend: false),
                          icon: _sendingCode
                              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                              : const Icon(Icons.sms),
                          label: const Text('إرسال الكود'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.orangeDeep,
                            foregroundColor: Colors.white,
                            minimumSize: const Size.fromHeight(46),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton(
                        onPressed: (_canResend && _verificationId != null)
                            ? () => _sendCode(isResend: true)
                            : null,
                        child: Text(_canResend ? 'إعادة الإرسال' : 'انتظر $_seconds ث'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // الخطوة ٢: إدخال الكود
            GlassContainer(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('الخطوة ٢: أدخل رمز التحقق (OTP)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _codeCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'أدخل الكود',
                      prefixIcon: Icon(Icons.verified_outlined),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _verifying ? null : _verifyCode,
                      icon: _verifying
                          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.check_circle_outline),
                      label: const Text('تحقق'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.blueLight,
                        foregroundColor: Colors.black,
                        minimumSize: const Size.fromHeight(46),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // الخطوة ٣: تعيين كلمة مرور جديدة
            if (_showPassForm)
              GlassContainer(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('الخطوة ٣: عيّن كلمة مرور جديدة', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _pass1Ctrl,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'كلمة المرور الجديدة',
                        prefixIcon: Icon(Icons.lock_outline),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _pass2Ctrl,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'تأكيد كلمة المرور',
                        prefixIcon: Icon(Icons.lock_outline),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _setNewPassword,
                        icon: const Icon(Icons.save_alt),
                        label: const Text('حفظ كلمة المرور'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.orangeDeep,
                          foregroundColor: Colors.white,
                          minimumSize: const Size.fromHeight(46),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
