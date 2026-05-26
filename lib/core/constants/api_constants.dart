// ─────────────────────────────────────────────────────────────────────────────
// api_constants.dart  –  All backend API URLs and timeout configuration.
//
// Centralising API paths here means if the backend URL ever changes,
// we only need to update it in one place.
// ─────────────────────────────────────────────────────────────────────────────

/// Contains all API endpoint paths and network configuration constants.
///
/// The paths are relative to [baseUrl]. The Dio HTTP client in api_client.dart
/// is configured with [baseUrl] as its base, so you only need the path portion.
class ApiConstants {
  /// The base URL of the deployed backend server (hosted on Render.com).
  static const String baseUrl = 'https://smartsleep-backend.onrender.com/';

  // ── Authentication endpoints ──────────────────────────────────────────────
  static const String signup             = '/api/v1/auth/signup';
  static const String login              = '/api/v1/auth/login';
  static const String resetPassword      = '/api/v1/auth/reset-password';
  static const String changePassword     = '/api/v1/auth/change-password';
  static const String confirmEmail       = '/api/v1/auth/confirm-email';
  static const String resendConfirmation = '/api/v1/auth/resend-confirmation';

  // ── Profile endpoints ─────────────────────────────────────────────────────
  static const String profile = '/api/v1/profile/me';  // GET and PUT use the same path

  // ── Sleep data endpoints ──────────────────────────────────────────────────
  static const String sleepIngest        = '/api/v1/sleep/ingest';          // POST both pre and post phases
  static const String sleepHistory       = '/api/v1/sleep/history';         // GET all past records
  static const String sleepAnalysisLatest = '/api/v1/sleep/analysis/latest'; // GET most recent analysis
  static const String sleepFeedback      = '/api/v1/sleep/analysis/feedback'; // POST user rating

  // ── Insights endpoints ────────────────────────────────────────────────────
  static const String recommendations = '/api/v1/insights/recommendations'; // GET personalised tips

  // ── Export endpoint ───────────────────────────────────────────────────────
  // Called by AnalysisRepository.emailExport().
  // The backend queries the database, builds the CSV, and emails it to the user.
  // Request body (both fields optional):
  //   { "start_date": "YYYY-MM-DD", "end_date": "YYYY-MM-DD" }
  // If the body is empty {}, the server exports ALL of the user's records.
  static const String sleepExport = '/api/v1/sleep/export';

  // ── Network timeouts ──────────────────────────────────────────────────────
  // The Render.com free tier "sleeps" inactive deployments. The first request
  // after inactivity can take up to 30s while Render wakes the server.
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
