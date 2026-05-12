// ─────────────────────────────────────────────────────────────────────────────
// api_provider.dart  –  Root-level Riverpod providers for shared services.
//
// These two providers are the foundation of the dependency injection chain:
//
//   secureStorageProvider → provides SecureStorage to everything that needs it
//   apiClientProvider     → provides ApiClient (using SecureStorage) to repositories
//
// By defining them as Riverpod providers instead of singletons or static instances,
// we can easily swap them out in tests (e.g., inject a mock storage).
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/api_client.dart';
import '../../core/storage/secure_storage.dart';

/// Provides a single shared [SecureStorage] instance to the entire app.
///
/// All providers and widgets that need to read/write encrypted storage
/// should get it through this provider, not create their own instance.
final secureStorageProvider = Provider<SecureStorage>((ref) {
  return SecureStorage();
});

/// Provides a single shared [ApiClient] instance configured with secure storage.
///
/// The ApiClient is injected with the SecureStorage instance so its
/// AuthInterceptor can read the JWT token for every HTTP request.
/// All repository providers watch this to get the HTTP client.
final apiClientProvider = Provider<ApiClient>((ref) {
  // `ref.watch` means: if secureStorageProvider ever changes (e.g., in tests),
  // re-create this apiClientProvider with the new storage instance.
  final storage = ref.watch(secureStorageProvider);
  return ApiClient(storage);
});
