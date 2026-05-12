// ─────────────────────────────────────────────────────────────────────────────
// secure_storage.dart  –  Encrypted local storage for sensitive data.
//
// The JWT token (our "login credential") must not be stored in plain text.
// FlutterSecureStorage uses:
//   - iOS:     Keychain Services (hardware-backed encryption)
//   - Android: Android Keystore System (hardware-backed encryption)
//   - Web:     localStorage encrypted with a session key
//
// This wrapper class provides a clean API for the specific data our app stores.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/app_constants.dart';

/// Provides type-safe access to the device's encrypted key-value storage.
///
/// All sensitive data (JWT tokens, user profile cache) should be stored
/// through this class, never using shared_preferences or file storage.
class SecureStorage {
  // The underlying FlutterSecureStorage instance.
  // `const` constructor means a single shared instance is reused.
  final _storage = const FlutterSecureStorage();

  // ── JWT Token ─────────────────────────────────────────────────────────────

  /// Saves the JWT access token to secure storage.
  ///
  /// Called after a successful login or signup. The token is later read
  /// and attached to every API request by the AuthInterceptor.
  Future<void> writeToken(String token) async {
    await _storage.write(key: AppConstants.tokenKey, value: token);
  }

  /// Reads the stored JWT access token.
  ///
  /// Returns null if the user has never logged in or has been logged out.
  /// Used by the auth flow on app startup to check if the user is already logged in.
  Future<String?> readToken() async {
    return await _storage.read(key: AppConstants.tokenKey);
  }

  /// Deletes the stored JWT access token.
  ///
  /// Called during logout and when a 401 Unauthorized response is received
  /// (indicating the token has expired).
  Future<void> deleteToken() async {
    await _storage.delete(key: AppConstants.tokenKey);
  }

  // ── User Profile Cache ────────────────────────────────────────────────────

  /// Caches the user's profile data as a JSON string.
  ///
  /// This allows the app to show the user's name/details immediately on
  /// launch without waiting for a network request to complete.
  Future<void> saveUserData(String userDataJson) async {
    await _storage.write(key: AppConstants.userKey, value: userDataJson);
  }

  /// Reads the cached user profile JSON string.
  ///
  /// Returns null if no profile has been cached yet.
  Future<String?> getUserData() async {
    return await _storage.read(key: AppConstants.userKey);
  }

  // ── Full Wipe ─────────────────────────────────────────────────────────────

  /// Deletes ALL data from secure storage.
  ///
  /// Called when the user logs out to ensure no sensitive data persists
  /// on the device after the session ends.
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
