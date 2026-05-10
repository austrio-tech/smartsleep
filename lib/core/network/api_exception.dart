import 'package:dio/dio.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';

  factory ApiException.fromDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiException('Connection timed out');
      case DioExceptionType.badResponse:
        final data = error.response?.data;
        final message = data is Map ? data['message'] ?? error.message : error.message;
        return ApiException(message ?? 'Server error', statusCode: error.response?.statusCode);
      default:
        return ApiException('An unexpected error occurred');
    }
  }
}
