// ─────────────────────────────────────────────────────────────────────────────
// auth_repository.dart  –  Data access layer for authentication operations.
//
// The Repository pattern separates the "how to get data" (this file) from
// "what to do with data" (providers/state management). Benefits:
//   - The provider doesn't care if data comes from the API, cache, or database
//   - Easy to write tests by swapping the repository with a mock
//   - All API endpoint details are contained here, not scattered in UI code
// ─────────────────────────────────────────────────────────────────────────────

import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';
import '../../core/constants/api_constants.dart';
import '../../core/storage/secure_storage.dart';

/// Handles all authentication-related API calls and token storage.
///
/// This class is the single source of truth for:
/// - Sending login/signup requests to the backend
/// - Storing and reading the JWT token
/// - Determining if the user is currently logged in
class AuthRepository {
  final ApiClient _apiClient;
  final SecureStorage _storage;

  AuthRepository(this._apiClient, this._storage);

  /// Authenticates the user and stores the returned JWT token.
  ///
  /// The login endpoint expects form-encoded data (not JSON) with
  /// `username` and `password` fields — this is the OAuth2 password flow.
  /// Our "username" is actually an email address.
  ///
  /// Throws an [ApiException] if credentials are wrong or the server errors.
  Future<void> login(String email, String password) async {
    final response = await _apiClient.post(
      ApiConstants.login,
      data: {
        'username': email,    // OAuth2 form field name must be 'username'
        'password': password,
      },
      options: Options(
        // Override the default JSON content type — this endpoint requires form data
        contentType: Headers.formUrlEncodedContentType,
      ),
    );

    // Extract the JWT from the response and save it securely on the device
    final token = response.data['access_token'];
    await _storage.writeToken(token);
  }

  /// Creates a new user account and stores the returned JWT token.
  ///
  /// On success, the backend returns a JWT so the user is immediately
  /// usable (though they still need to confirm their email).
  Future<void> signup(Map<String, dynamic> userData) async {
    final response = await _apiClient.post(ApiConstants.signup, data: userData);
    final token = response.data['access_token'];
    if (token != null) {
      await _storage.writeToken(token);
    }
  }

  /// Logs out the user by deleting the stored JWT token.
  ///
  /// No API call is needed — we just delete the local token.
  /// The backend uses stateless JWT, so there is no server-side session to end.
  Future<void> logout() async {
    await _storage.deleteToken();
  }

  /// Checks if the user is currently logged in (has a stored JWT token).
  ///
  /// Note: This only checks whether a token EXISTS on the device.
  /// It does NOT verify that the token is still valid (non-expired).
  /// The actual validity check happens when the token is used in an API request.
  Future<bool> isLoggedIn() async {
    final token = await _storage.readToken();
    return token != null;
  }
}
