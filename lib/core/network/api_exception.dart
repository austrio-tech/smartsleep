// ─────────────────────────────────────────────────────────────────────────────
// api_exception.dart  –  Typed exception for HTTP/network errors.
//
// Rather than letting raw DioExceptions propagate to the UI, we convert them
// to ApiExceptions with human-readable messages. This keeps error handling
// clean in the UI layer — it just checks for ApiException and reads .message.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:dio/dio.dart';

/// Custom exception class for all API/network errors.
///
/// Thrown by repositories when an HTTP request fails. The UI layer catches
/// this exception and displays the [message] to the user.
class ApiException implements Exception {
  /// A human-readable description of what went wrong.
  final String message;

  /// The HTTP status code returned by the server (e.g., 400, 401, 404, 500).
  /// Null for network errors where no response was received (e.g., timeout).
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  /// Returns a debug-friendly string representation of this exception.
  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';

  /// Factory constructor that converts a Dio error into a friendly ApiException.
  ///
  /// Dio categorises errors by type. We map each type to a readable message:
  /// - Timeout errors → "Connection timed out"
  /// - Server response errors → the error message from the JSON body
  /// - Other errors → "An unexpected error occurred"
  factory ApiException.fromDioError(DioException error) {
    switch (error.type) {
      // The connection took too long to establish or the server didn't respond in time.
      // Common on free Render.com deployments that "sleep" when inactive.
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiException('Connection timed out');

      // The server responded but with an error status code (4xx or 5xx).
      case DioExceptionType.badResponse:
        // Try to extract the "detail" or "message" field from the JSON error body
        final data = error.response?.data;
        final message = data is Map ? data['message'] ?? error.message : error.message;
        return ApiException(message ?? 'Server error', statusCode: error.response?.statusCode);

      // Catch-all for unexpected error types (SSL errors, bad URLs, etc.)
      default:
        return ApiException('An unexpected error occurred');
    }
  }
}
