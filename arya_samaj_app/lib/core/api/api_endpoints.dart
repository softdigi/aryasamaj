class ApiEndpoints {
  static const String base       = 'https://aryasamaj.site/app_api/api';
  static const String sendOtp    = '/send-otp';
  static const String verifyOtp  = '/verify-otp';
  static const String home       = '/home';
  static const String features   = '/features';
  static const String categories = '/categories';
  static const String contents   = '/contents';
  static const String donation   = '/donation';
  static const String feedback   = '/feedback';
  static const String profile    = '/profile';
  static const String myProfile  = '/my-profile';
  static const String logout     = '/logout';

  // Profile setup
  static const String saveProfile    = '/save-profile';
  static const String saveCategories = '/save-categories';
  static const String saveAbout      = '/save-about';
  static const String uploadImages   = '/upload-images';

  // Members
  static const String members           = '/members';
  static const String memberCategories  = '/member-categories';

  // FCM
  static const String fcmToken = '/user/fcm-token';

  // Events
  static const String events = '/events';

  // Donation payment (Razorpay)
  static const String donationPay = '/donation/pay';

  // Unified search
  static const String search = '/search';
}

