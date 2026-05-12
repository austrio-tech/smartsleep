// ─────────────────────────────────────────────────────────────────────────────
// sleep_data_repository.dart  –  Data access layer for sleep data operations.
// ─────────────────────────────────────────────────────────────────────────────

import '../../core/network/api_client.dart';
import '../../core/constants/api_constants.dart';
import '../models/derived_sleep_data.dart';

/// Handles submitting raw sleep data and fetching sleep history via the API.
class SleepDataRepository {
  final ApiClient _apiClient;

  SleepDataRepository(this._apiClient);

  /// Submits raw sleep data for one phase (pre or post sleep).
  ///
  /// Calls POST /api/v1/sleep/ingest. The [data] map must include a `phase`
  /// field set to either "pre" (evening) or "post" (morning).
  ///
  /// After a successful "post" phase submission, the backend automatically
  /// runs the full sleep analysis pipeline and updates the derived record.
  Future<void> submitRawSleepData(Map<String, dynamic> data) async {
    await _apiClient.post(ApiConstants.sleepIngest, data: data);
  }

  /// Fetches the full sleep history for the current user.
  ///
  /// Calls GET /api/v1/sleep/history (authenticated).
  /// Returns a list of [DerivedSleepData] objects ordered newest-first.
  /// Each object represents one night's computed sleep analysis.
  Future<List<DerivedSleepData>> getSleepHistory() async {
    final response = await _apiClient.get(ApiConstants.sleepHistory);

    // `response.data` is a JSON array. We cast it to List and map each element
    // through DerivedSleepData.fromJson() to get typed Dart objects.
    return (response.data as List)
        .map((e) => DerivedSleepData.fromJson(e))
        .toList();
  }
}
