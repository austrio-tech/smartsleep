import '../../core/network/api_client.dart';
import '../../core/constants/api_constants.dart';
import '../models/derived_sleep_data.dart';

class SleepDataRepository {
  final ApiClient _apiClient;

  SleepDataRepository(this._apiClient);

  Future<void> submitRawSleepData(Map<String, dynamic> data) async {
    // Fixed: Changed ApiConstants.sleepRaw to ApiConstants.sleepIngest
    // to match the constant defined in api_constants.dart and the endpoint /api/v1/sleep/ingest
    await _apiClient.post(ApiConstants.sleepIngest, data: data);
  }

  Future<List<DerivedSleepData>> getSleepHistory() async {
    final response = await _apiClient.get(ApiConstants.sleepHistory);
    return (response.data as List)
        .map((e) => DerivedSleepData.fromJson(e))
        .toList();
  }
}
