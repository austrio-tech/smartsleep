import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/analysis_repository.dart';
import '../models/derived_sleep_data.dart';
import '../models/recommendation.dart';
import 'api_provider.dart';

final analysisRepositoryProvider = Provider<AnalysisRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AnalysisRepository(apiClient);
});

final latestAnalysisProvider = FutureProvider<DerivedSleepData>((ref) async {
  final repository = ref.watch(analysisRepositoryProvider);
  return await repository.getLatestAnalysis();
});

final recommendationsProvider = FutureProvider<List<Recommendation>>((ref) async {
  final repository = ref.watch(analysisRepositoryProvider);
  return await repository.getRecommendations();
});
