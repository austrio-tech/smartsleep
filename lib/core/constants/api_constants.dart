class ApiConstants {
  static const String baseUrl = 'https://smartsleep-backend.onrender.com/';  // REAL Link

  // Auth
  static const String signup = '/api/v1/auth/signup';
  static const String login = '/api/v1/auth/login';
  static const String resetPassword = '/api/v1/auth/reset-password';
  static const String confirmEmail = '/api/v1/auth/confirm-email';
  static const String resendConfirmation = '/api/v1/auth/resend-confirmation';
  
  // Profile
  static const String profile = '/api/v1/profile/me';
  
  // Sleep Data
  static const String sleepIngest = '/api/v1/sleep/ingest';
  static const String sleepHistory = '/api/v1/sleep/history';
  static const String sleepAnalysisLatest = '/api/v1/sleep/analysis/latest';
  static const String sleepFeedback = '/api/v1/sleep/analysis/feedback';
  
  // Insights
  static const String recommendations = '/api/v1/insights/recommendations';

  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
