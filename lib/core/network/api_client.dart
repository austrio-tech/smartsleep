// ─────────────────────────────────────────────────────────────────────────────
// api_client.dart  –  HTTP client for all backend API requests.
//
// We use the Dio library (like Axios for Flutter) to make HTTP requests.
// Dio supports "interceptors" — middleware that runs before every request
// and after every response. We use two interceptors:
//
//   1. AuthInterceptor: Automatically adds the JWT to every request header.
//   2. LogInterceptor:  Prints request/response details to the debug console.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import '../storage/secure_storage.dart';
import 'api_exception.dart';

/// HTTP client wrapper around Dio for making authenticated API requests.
///
/// All network calls in the app should go through this class rather than
/// using Dio directly. This ensures every request automatically gets:
/// - The correct base URL
/// - The JWT Authorization header (if the user is logged in)
/// - Consistent timeout settings
class ApiClient {
  late final Dio _dio; // `late` means the value is assigned before first use
  final SecureStorage _storage;

  /// Creates an ApiClient with a Dio instance configured for the SmartSleep backend.
  ///
  /// [storage] is injected (passed in) rather than created here, which makes
  /// the class easier to test and follows the Dependency Injection pattern.
  ApiClient(this._storage) {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: ApiConstants.connectTimeout,
      receiveTimeout: ApiConstants.receiveTimeout,
      headers: {'Content-Type': 'application/json'},
    ));

    // Add the auth interceptor (injects JWT into every request)
    _dio.interceptors.add(AuthInterceptor(_storage));

    // Add the log interceptor (prints HTTP traffic to the debug console)
    _dio.interceptors.add(LogInterceptor(responseBody: true));
  }

  /// Performs an HTTP GET request.
  ///
  /// [queryParameters] are added to the URL as ?key=value pairs.
  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      return await _dio.get(path, queryParameters: queryParameters);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// Performs an HTTP POST request.
  ///
  /// [data] is the request body (will be JSON-encoded automatically).
  /// [options] can override headers, content type, etc. for this specific request.
  Future<Response> post(String path, {dynamic data, Options? options}) async {
    try {
      return await _dio.post(path, data: data, options: options);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// Performs an HTTP PUT request (full or partial resource update).
  Future<Response> put(String path, {dynamic data}) async {
    try {
      return await _dio.put(path, data: data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// Performs an HTTP DELETE request.
  Future<Response> delete(String path, {dynamic data}) async {
    try {
      return await _dio.delete(path, data: data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}

/// Dio interceptor that automatically adds the JWT Bearer token to every request.
///
/// An interceptor is a hook that runs before the request is sent (onRequest)
/// or after the response is received (onError). This one:
/// - Reads the stored JWT and adds it as an Authorization header before each request.
/// - Clears the stored token and notifies the app if a 401 response is received.
class AuthInterceptor extends Interceptor {
  final SecureStorage storage;
  AuthInterceptor(this.storage);

  /// Called before every HTTP request — adds the JWT to the Authorization header.
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await storage.readToken();
    if (token != null) {
      // The HTTP Authorization header format for JWT: "Bearer <token>"
      options.headers['Authorization'] = 'Bearer $token';
    }
    // `handler.next` passes the modified request on to the actual HTTP layer
    handler.next(options);
  }

  /// Called when the server returns an error response.
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      // 401 Unauthorized: our token has expired or been invalidated.
      // Clear the stored token so the next launch correctly shows the login screen.
      await storage.deleteToken();
      // Notify the global session-expired listener (set in main.dart) to log the user out.
      onSessionExpiredCallback?.call();
    }
    // Pass the error along so it can be caught by the calling code
    handler.next(err);
  }
}

/// Global callback invoked when the server returns 401 (session expired).
///
/// Set in main.dart to call the auth notifier's logout() method.
/// Defined as a top-level nullable function so api_client.dart doesn't
/// need to import Riverpod (which would create a circular dependency).
void Function()? onSessionExpiredCallback;
