// ─────────────────────────────────────────────────────────────────────────────
// app_constants.dart  –  Application-wide configuration constants.
//
// These values are used in multiple places across the app. Defining them here
// makes the code easier to maintain and refactor.
// ─────────────────────────────────────────────────────────────────────────────

/// Application-wide constant values.
class AppConstants {
  /// The display name of the app (shown in window titles, loading messages, etc.)
  static const String appName = 'SmartSleep';

  // ── Sleep Score Thresholds ────────────────────────────────────────────────
  // These thresholds define the colour-coded quality tiers shown in the UI:
  // ≥75 → Green (Good), 50-74 → Yellow (Fair), <50 → Red (Poor)
  static const int scoreGood   = 75; // Score at or above this is "Good"
  static const int scoreMedium = 50; // Score at or above this is "Fair"

  // ── Secure Storage Keys ───────────────────────────────────────────────────
  // These are the key strings used when reading/writing from the device's
  // secure storage (like the iOS Keychain or Android Keystore).
  static const String tokenKey = 'jwt_token';  // Key for storing the JWT access token
  static const String userKey  = 'user_data';  // Key for caching user profile JSON
}
