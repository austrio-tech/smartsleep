import '../../core/network/api_client.dart';
import '../../core/constants/api_constants.dart';
import '../models/derived_sleep_data.dart';
import '../models/recommendation.dart';

class AnalysisRepository {
  final ApiClient _apiClient;

  AnalysisRepository(this._apiClient);

  Future<DerivedSleepData> getLatestAnalysis() async {
    final response = await _apiClient.get(ApiConstants.sleepAnalysisLatest);
    return DerivedSleepData.fromJson(response.data);
  }

  Future<DerivedSleepData> submitFeedback(double userScore, String userClass) async {
    final response = await _apiClient.post(
      ApiConstants.sleepFeedback,
      data: {
        'user_score': userScore,
        'user_class': userClass,
      },
    );
    return DerivedSleepData.fromJson(response.data);
  }

  Future<List<Recommendation>> getRecommendations() async {
    final response = await _apiClient.get(ApiConstants.recommendations);
    return (response.data as List)
        .map((e) => Recommendation.fromJson(e))
        .toList();
  }
}
