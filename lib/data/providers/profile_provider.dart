import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/profile_repository.dart';
import '../models/user.dart';
import 'api_provider.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ProfileRepository(apiClient);
});

final userProfileProvider = FutureProvider<User>((ref) async {
  final repository = ref.watch(profileRepositoryProvider);
  return await repository.getProfile();
});
