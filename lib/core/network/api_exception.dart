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
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiException(
          'Connection timed out. Please check your internet and try again.',
        );

      case DioExceptionType.connectionError:
        return ApiException(
          'Unable to connect. Please check your internet connection.',
        );

      // The server responded but with an error status code (4xx or 5xx).
      case DioExceptionType.badResponse:
        final data = error.response?.data;
        final statusCode = error.response?.statusCode;

        // FastAPI always wraps error messages in {"detail": "..."}.
        // Some endpoints may use {"message": "..."} as fallback.
        String? message;
        if (data is Map) {
          final raw = data['detail'] ?? data['message'];
          if (raw is String && raw.isNotEmpty) message = raw;
        }

        // Friendly fallbacks when the server body has no readable message
        message ??= switch (statusCode) {
          400  => 'Invalid request. Please check your input.',
          401  => 'Incorrect email or password.',
          403  => 'You do not have permission to do that.',
          404  => 'The requested resource was not found.',
          422  => 'Please check your input and try again.',
          429  => 'Too many requests. Please wait a moment.',
          500  => 'Server error. Please try again later.',
          502  => 'Service temporarily unavailable. Please try again.',
          503  => 'Service temporarily unavailable. Please try again.',
          _    => 'An error occurred. Please try again.',
        };

        return ApiException(message, statusCode: statusCode);

      default:
        return ApiException('An unexpected error occurred. Please try again.');
    }
  }
}
