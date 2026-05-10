import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';
import '../../core/constants/api_constants.dart';
import '../../core/storage/secure_storage.dart';

class AuthRepository {
  final ApiClient _apiClient;
  final SecureStorage _storage;

  AuthRepository(this._apiClient, this._storage);

  Future<void> login(String email, String password) async {
    final response = await _apiClient.post(
      ApiConstants.login,
      data: {
        'username': email,
        'password': password,
      },
      options: Options(
        contentType: Headers.formUrlEncodedContentType,
      ),
    );
    final token = response.data['access_token'];
    await _storage.writeToken(token);
  }

  Future<void> signup(Map<String, dynamic> userData) async {
    final response = await _apiClient.post(ApiConstants.signup, data: userData);
    final token = response.data['access_token'];
    if (token != null) {
      await _storage.writeToken(token);
    }
  }

  Future<void> logout() async {
    await _storage.deleteToken();
  }

  Future<bool> isLoggedIn() async {
    final token = await _storage.readToken();
    return token != null;
  }
}
