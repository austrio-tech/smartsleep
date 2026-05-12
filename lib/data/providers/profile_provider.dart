// ─────────────────────────────────────────────────────────────────────────────
// profile_provider.dart  –  Riverpod providers for user profile data.
//
// profileRepositoryProvider: creates the ProfileRepository
// userProfileProvider:       fetches the current user's profile from the API
//                            and caches the result (FutureProvider handles this)
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/profile_repository.dart';
import '../models/user.dart';
import 'api_provider.dart';

/// Provides a [ProfileRepository] instance.
final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ProfileRepository(apiClient);
});

/// Fetches the current user's profile from the backend and caches the result.
///
/// FutureProvider is the Riverpod provider type for async data. It exposes
/// an AsyncValue<User> which can be in one of three states:
///   - AsyncLoading(): Request is in progress
///   - AsyncData(user): Success — the User object is available
///   - AsyncError(e, st): Request failed — error and stack trace available
///
/// Widgets use it like:
///   final profileAsync = ref.watch(userProfileProvider);
///   profileAsync.when(
///     data: (user) => Text(user.fullName ?? ''),
///     loading: () => CircularProgressIndicator(),
///     error: (e, _) => Text('Error: $e'),
///   );
///
/// To refresh the profile (e.g., after an update):
///   ref.invalidate(userProfileProvider);
final userProfileProvider = FutureProvider<User>((ref) async {
  final repository = ref.watch(profileRepositoryProvider);
  return await repository.getProfile();
});
