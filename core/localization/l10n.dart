import 'package:flutter/widgets.dart';
import 'locale_controller.dart';

class L {
  static final Map<String, Map<String, String>> _m = {
    // General
    'save': {'ar': 'حفظ', 'en': 'Save'},
    'saved': {'ar': 'تم الحفظ', 'en': 'Saved'},

    // Navigation / Tabs
    'home': {'ar': 'الرئيسية', 'en': 'Home'},
    'cart': {'ar': 'السلة', 'en': 'Cart'},
    'categories': {'ar': 'القائمة', 'en': 'Categories'},
    'deals': {'ar': 'العروض', 'en': 'Deals'},
    'account': {'ar': 'SE7EN', 'en': 'SE7EN'},

    // Explicit English labels (used by bottom nav)
    'Home': {'ar': 'Home', 'en': 'Home'},
    'Cart': {'ar': 'Cart', 'en': 'Cart'},
    'Categories': {'ar': 'Categories', 'en': 'Categories'},
    'Deals': {'ar': 'Deals', 'en': 'Deals'},
    'Se7en': {'ar': 'Se7en', 'en': 'Se7en'},

    // Account
    'my_account': {'ar': 'حسابي', 'en': 'My Account'},
    'please_login': {
      'ar': 'الرجاء تسجيل الدخول للوصول لحسابك',
      'en': 'Please log in to access your account',
    },
    'login': {'ar': 'تسجيل الدخول', 'en': 'Log in'},
    'logout': {'ar': 'تسجيل الخروج', 'en': 'Log out'},
    'profile': {'ar': 'الملف الشخصي', 'en': 'Profile'},
    'my_orders': {'ar': 'طلباتي', 'en': 'My Orders'},
    'returns': {'ar': 'المرتجعات', 'en': 'Returns'},
    'addresses': {'ar': 'العناوين', 'en': 'Addresses'},
    'payment_cards': {'ar': 'بطاقات الدفع', 'en': 'Payment Cards'},
    'favorites': {'ar': 'المفضلة', 'en': 'Favorites'},
    'notifications': {'ar': 'الإشعارات', 'en': 'Notifications'},
    'security': {'ar': 'الأمان', 'en': 'Security'},
    'country_language': {'ar': 'البلد واللغة', 'en': 'Country & Language'},
    'help_about': {'ar': 'المساعدة و عن التطبيق', 'en': 'Help & About'},
    'chats': {'ar': 'المحادثات', 'en': 'Chats'},

    // Country & Language Page
    'country': {'ar': 'البلد', 'en': 'Country'},
    'language': {'ar': 'اللغة', 'en': 'Language'},
    'arabic': {'ar': 'العربية', 'en': 'Arabic'},
    'english': {'ar': 'الإنجليزية', 'en': 'English'},

    // Orders
    'clear_filters': {'ar': 'مسح الفلاتر', 'en': 'Clear filters'},
    'status': {'ar': 'الحالة', 'en': 'Status'},
    'date_all': {'ar': 'التاريخ: الكل', 'en': 'Date: All'},
    'no_matching_orders': {
      'ar': 'لا توجد طلبات مطابقة للفلاتر',
      'en': 'No orders match the filters',
    },
    'total': {'ar': 'الإجمالي', 'en': 'Total'},
    'reorder': {'ar': 'إعادة الطلب', 'en': 'Reorder'},

    // Generic
    'no_orders': {'ar': 'لا توجد طلبات', 'en': 'No orders'},

    // Search & Filters
    'search_hint': {
      'ar': 'ابحث حسب الاسم، المتجر، الفئة',
      'en': 'Search by name, store, category',
    },
    'clear': {'ar': 'مسح', 'en': 'Clear'},
    'category': {'ar': 'الفئة', 'en': 'Category'},
    'price': {'ar': 'السعر', 'en': 'Price'},
    'price_plain': {'ar': 'سعر', 'en': 'Price'},
    'rating': {'ar': 'التقييم', 'en': 'Rating'},
    'rate': {'ar': 'تقييم', 'en': 'Rate'},
    'advanced_filters': {'ar': 'فلترة متقدمة', 'en': 'Advanced filters'},

    // Addresses
    'no_addresses_yet': {'ar': 'لا توجد عناوين بعد', 'en': 'No addresses yet'},
    'address': {'ar': 'عنوان', 'en': 'Address'},
    'home_address': {'ar': 'البيت', 'en': 'Home'},
    'add_address': {'ar': 'اضافة عنوان', 'en': 'Add address'},

    // Profile
    'edit_profile': {'ar': 'تعديل الملف الشخصي', 'en': 'Edit profile'},
    'name': {'ar': 'الاسم', 'en': 'Name'},
    'phone': {'ar': 'الجوال', 'en': 'Phone'},
    'email': {'ar': 'الإيميل', 'en': 'Email'},

    // Products / Favorites
    'product': {'ar': 'منتج', 'en': 'Product'},
    'favorites_empty': {
      'ar': 'قائمة المفضلة فارغة',
      'en': 'Favorites list is empty',
    },

    // Legal & Info
    'terms_and_conditions': {'ar': 'الشروط والأحكام', 'en': 'Terms & Conditions'},
    'terms_consent': {
      'ar': 'استخدامك للتطبيق يعني موافقتك على الشروط',
      'en': 'By using the app you agree to the terms',
    },
    'privacy_policy': {'ar': 'سياسة الخصوصية', 'en': 'Privacy Policy'},
    'privacy_note': {
      'ar': 'نحترم خصوصيتك ولا نشارك بياناتك دون إذن',
      'en': 'We respect your privacy and do not share data without permission',
    },
    'contact_us': {'ar': 'تواصل معنا', 'en': 'Contact us'},
    'faq': {'ar': 'الأسئلة الشائعة', 'en': 'FAQ'},
    'faq_track_order': {
      'ar': 'س: كيف أتابع طلبي؟ ج: من صفحة الطلبات',
      'en': 'Q: How do I track my order? A: From the Orders page',
    },

    // Notifications
    'promo_notifications': {'ar': 'اشعارات العروض', 'en': 'Deals notifications'},

    // Order Statuses
    'processing': {'ar': 'قيد المعالجة', 'en': 'Processing'},
    'shipped': {'ar': 'شُحن', 'en': 'Shipped'},
    'in_transit': {'ar': 'في الطريق', 'en': 'In transit'},
    'delivered': {'ar': 'تم التسليم', 'en': 'Delivered'},
    'cancelled': {'ar': 'أُلغي', 'en': 'Cancelled'},

    // Chat / Tracking
    'chat_with_merchant': {'ar': 'دردشة مع التاجر', 'en': 'Chat with the merchant'},
    'track_status': {'ar': 'تتبّع الحالة', 'en': 'Track status'},

    // Order details
    'items': {'ar': 'العناصر', 'en': 'Items'},
    'no_items': {'ar': 'لا  توجد عناصر', 'en': 'No items'},
    'order_details': {'ar': 'تفاصيل الطلب', 'en': 'Order details'},
    'summary': {'ar': 'الملخّص', 'en': 'Summary'},
    'note': {'ar': 'ملاحظة', 'en': 'Note'},
    'payment': {'ar': 'الدفع', 'en': 'Payment'},
    'merchant': {'ar': 'التاجر', 'en': 'Merchant'},
    'created_at': {'ar': 'تاريخ الإنشاء', 'en': 'Created at'},
    'order_not_found': {'ar': 'الطلب غير موجود', 'en': 'Order not found'},

    // Cards
    'no_saved_cards': {'ar': 'لا  توجد بطاقات محفوظة', 'en': 'No saved cards'},
    'add_card': {'ar': 'اضافة بطاقة', 'en': 'Add card'},

    // Returns
    'return_for_order': {'ar': 'ارجاع لطلب', 'en': 'Return for order'},
    'reason': {'ar': 'السبب', 'en': 'Reason'},
    'no_return_requests': {
      'ar': 'لا  توجد طلبات إرجاع',
      'en': 'No return requests',
    },
    'return_request': {'ar': 'طلب إرجاع', 'en': 'Return request'},
    'order_number': {'ar': 'رقم الطلب', 'en': 'Order number'},
    'cancel': {'ar': 'إلغاء', 'en': 'Cancel'},
    'submit': {'ar': 'إرسال', 'en': 'Submit'},

    // Security / Password
    'change_password': {'ar': 'تغيير كلمة السر', 'en': 'Change password'},
    'new_password': {'ar': 'كلمة سر جديدة', 'en': 'New password'},
    'confirm': {'ar': 'تأكيد', 'en': 'Confirm'},
    'error': {'ar': 'خطأ', 'en': 'Error'},
    'updated': {'ar': 'تم التغيير', 'en': 'Updated'},
    'sessions_devices_coming_soon': {
      'ar': 'جلسات/أجهزة الدخول (عرض لاحقًا)',
      'en': 'Sessions/Devices (to be shown later)',
    },

    // Marketing / Welcome
    'glass_shopping_tagline': {
      'ar': 'تسوق بزجاجية… أناقة وسرعة على ذوق',
      'en': 'Shop with glass… elegance and speed, your way',
    },
    'welcome_to': {'ar': 'مرحبًا بك في', 'en': 'Welcome to'},

    // Auth common
    'password': {'ar': 'كلمة المرور', 'en': 'Password'},
    'forgot_password': {'ar': 'نسيت كلمة المرور؟', 'en': 'Forgot password?'},
    'follow_us_on': {'ar': 'تابعنا على', 'en': 'Follow us on'},
    'no_account_create': {
      'ar': 'ليس لديك حساب؟ إنشاء حساب',
      'en': "Don't have an account? Create one",
    },
    'all_rights_reserved': {'ar': 'جميع الحقوق محفوظة', 'en': 'All rights reserved'},
    'enter_intl_phone_example': {
      'ar': 'ادخل رقم جوال بصيغة دولية، مثال: +9665X',
      'en': 'Enter an international phone number, e.g., +9665X',
    },

    // OTP / Verification / Reset
    'auto_verification_failed': {'ar': 'فشل التحقق التلقائي', 'en': 'Automatic verification failed'},
    'sending_failed': {'ar': 'فشل الإرسال', 'en': 'Sending failed'},
    'code_sent': {'ar': 'تم إرسال رمز التحقق', 'en': 'Verification code sent'},
    'send_code_first': {'ar': 'ارسل الكود أولاً', 'en': 'Send the code first'},
    'enter_valid_code': {'ar': 'ادخل رمز تحقق صحيح', 'en': 'Enter a valid verification code'},
    'verified_success': {'ar': 'تم التحقق بنجاح', 'en': 'Verified successfully'},
    'verification_failed': {'ar': 'فشل التحقق', 'en': 'Verification failed'},
    'password_min': {
      'ar': 'كلمة المرور يجب أن تكون 6 أحرف على الأقل',
      'en': 'Password must be at least 6 characters',
    },
    'confirm_mismatch': {
      'ar': 'التأكيد لا يطابق كلمة المرور',
      'en': 'Confirmation does not match the password',
    },
    'not_logged_in_after_verify': {
      'ar': 'لم يتم تسجيل الدخول بعد التحقق',
      'en': 'Not logged in after verification',
    },
    'password_set_success': {
      'ar': 'تم تعيين كلمة المرور الجديدة بنجاح',
      'en': 'New password set successfully',
    },
    'reset_via': {'ar': 'اعادة تعيين عبر', 'en': 'Reset via'},
    'step1_enter_phone': {
      'ar': 'الخطوة ١: أدخل رقم جوالك',
      'en': 'Step 1: Enter your phone number',
    },
    'phone_hint': {
      'ar': 'رقم الجوال (بصيغة دولية) مثال: +9665X',
      'en': 'Phone number (international) e.g., +9665X',
    },
    'send_code': {'ar': 'أرسل الكود', 'en': 'Send code'},
    'resend_wait': {'ar': 'إعادة الإرسال: انتظر', 'en': 'Resend: wait'},
    'step2_enter_code': {
      'ar': 'الخطوة ٢: أدخل رمز التحقق',
      'en': 'Step 2: Enter the verification code',
    },
    'enter_code': {'ar': 'ادخل الكود', 'en': 'Enter the code'},
    'verify': {'ar': 'تحقق', 'en': 'Verify'},
    'step3_set_password': {
      'ar': 'الخطوة ٣: عيّن كلمة مرور جديدة',
      'en': 'Step 3: Set a new password',
    },
    'confirm_password': {'ar': 'تأكيد كلمة المرور', 'en': 'Confirm password'},
    'save_password': {'ar': 'حفظ كلمة المرور', 'en': 'Save password'},
    'name_required': {'ar': 'الاسم مطلوب', 'en': 'Name is required'},
    'enter_full_name': {'ar': 'اكتب اسمًا ثنائيًا', 'en': 'Enter first and last name'},
    'enter_valid_name': {'ar': 'ادخل اسمًا صحيحًا', 'en': 'Enter a valid name'},
    'email_required': {'ar': 'الإيميل مطلوب', 'en': 'Email is required'},
    'enter_valid_email': {'ar': 'ادخل بريدًا صحيحًا', 'en': 'Enter a valid email'},
    'enter_valid_phone_intl': {
      'ar': 'ادخل رقمًا صحيحًا (يفضل بصيغة دولية +966…)',
      'en': 'Enter a valid number (preferably international +966…)'
    },
    'password_required': {'ar': 'كلمة المرور مطلوبة', 'en': 'Password is required'},
    'chars_at_least': {'ar': 'احرف على الأقل', 'en': 'At least characters'},
    'retype_password': {'ar': 'اعد كتابة كلمة المرور', 'en': 'Re-type password'},
    'unexpected_error': {'ar': 'خطأ غير متوقع:', 'en': 'Unexpected error:'},
    'create_account': {'ar': 'انشاء حساب', 'en': 'Create account'},
    'two_part_name': {'ar': 'الاسم الثنائي', 'en': 'Full name'},
    'phone_number': {'ar': 'رقم الجوال', 'en': 'Phone number'},
    'register': {'ar': 'انشاء الحساب', 'en': 'Create account'},
    'agree_terms_privacy': {
      'ar': 'بإنشائك حسابًا فأنت توافق على الشروط وسياسة الخصوصية.',
      'en': 'By creating an account, you agree to the Terms and Privacy Policy.',
    },
  };

  static String of(BuildContext context, String key) {
    final code = LocaleController.instance.code;
    final byKey = _m[key];
    if (byKey == null) return key;
    return byKey[code] ?? byKey['en'] ?? key;
  }
}
