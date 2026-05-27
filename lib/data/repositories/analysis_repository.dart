// ─────────────────────────────────────────────────────────────────────────────
// analysis_repository.dart  –  Data access layer for sleep analysis operations.
// ─────────────────────────────────────────────────────────────────────────────

import '../../core/network/api_client.dart';
import '../../core/constants/api_constants.dart';
import '../models/derived_sleep_data.dart';
import '../models/recommendation.dart';

/// Handles fetching sleep analysis results, submitting feedback,
/// retrieving personalised recommendations, and emailing data exports.
class AnalysisRepository {
  final ApiClient _apiClient;

  AnalysisRepository(this._apiClient);

  /// Fetches the most recent complete sleep analysis.
  ///
  /// Calls GET /api/v1/sleep/analysis/latest (authenticated).
  Future<DerivedSleepData> getLatestAnalysis() async {
    final response = await _apiClient.get(ApiConstants.sleepAnalysisLatest);
    return DerivedSleepData.fromJson(response.data);
  }

  /// Submits the user's self-reported sleep quality rating.
  ///
  /// Calls POST /api/v1/sleep/analysis/feedback (authenticated).
  /// Triggers the ML training pipeline server-side with this new labelled sample.
  Future<DerivedSleepData> submitFeedback(double userScore, String userClass) async {
    final response = await _apiClient.post(
      ApiConstants.sleepFeedback,
      data: {'user_score': userScore, 'user_class': userClass},
    );
    return DerivedSleepData.fromJson(response.data);
  }

  /// Fetches personalised sleep improvement recommendations.
  ///
  /// Pass [derivedId] to get recommendations for a specific history entry.
  /// Omit it (or pass null) to get recommendations based on the latest record.
  /// Calls GET /api/v1/insights/recommendations (authenticated).
  Future<List<Recommendation>> getRecommendations({String? derivedId}) async {
    final response = await _apiClient.get(
      ApiConstants.recommendations,
      queryParameters: derivedId != null ? {'derived_id': derivedId} : null,
    );
    return (response.data as List).map((e) => Recommendation.fromJson(e)).toList();
  }

  /// Requests a CSV export of the user's sleep history by email.
  ///
  /// Calls POST /api/v1/sleep/export (authenticated — JWT automatically added by ApiClient).
  ///
  /// The backend:
  ///   1. Queries derived_sleep_data filtered by the optional date range
  ///   2. Builds a CSV string with all sleep metrics
  ///   3. Renders the data_export.html email template
  ///   4. Sends the email via the Google Apps Script relay
  ///
  /// Parameters use Dart's "named optional" syntax: {String? startDate, String? endDate}
  ///   - Curly braces {} make them named (caller writes: emailExport(startDate: "2024-01-01"))
  ///   - The `?` makes them nullable (can be null → not required)
  ///   - If the caller doesn't pass them, they default to null
  ///
  /// Returns the server's success message, e.g. "Export sent to user@... (42 nights)".
  /// Throws an [ApiException] if the server returns an error.
  Future<String> emailExport({String? startDate, String? endDate}) async {
    // Build the request body as a mutable Map (key-value pairs → JSON object).
    // We start with an empty map and only add keys that were provided.
    // This is the "partial update" pattern — send only what you have.
    final Map<String, dynamic> body = {};

    // The `if (condition)` on its own line is a guard: skip the line if condition is false.
    if (startDate != null) body['start_date'] = startDate;  // e.g. {"start_date": "2024-01-01"}
    if (endDate != null)   body['end_date']   = endDate;    // e.g. {"end_date":   "2024-12-31"}
    // If both are null, body stays empty {} → server exports all records

    // Make the POST request. ApiClient automatically adds the Authorization header.
    final response = await _apiClient.post(
      ApiConstants.sleepExport,  // "/api/v1/sleep/export"
      data: body,                // JSON body sent to the server
    );

    // response.data is the parsed JSON response body (a Map<String, dynamic>).
    // The server returns: {"message": "Export sent to alice@example.com (42 nights)"}
    // We cast it to String because we know the "message" field is always a string.
    return response.data['message'] as String;
  }
}
