import '../../core/network/api_client.dart';
import '../../core/constants/api_constants.dart';
import '../models/user.dart';

class ProfileRepository {
  final ApiClient _apiClient;

  ProfileRepository(this._apiClient);

  Future<User> getProfile() async {
    final response = await _apiClient.get(ApiConstants.profile);
    return User.fromJson(response.data);
  }

  Future<User> updateProfile(Map<String, dynamic> profileData) async {
    final response = await _apiClient.put(ApiConstants.profile, data: profileData);
    return User.fromJson(response.data);
  }
}
