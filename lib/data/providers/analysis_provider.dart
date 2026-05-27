// ─────────────────────────────────────────────────────────────────────────────
// analysis_provider.dart  –  Riverpod providers for sleep analysis data.
//
// analysisRepositoryProvider: creates the AnalysisRepository
// latestAnalysisProvider:     fetches the most recent sleep analysis
// recommendationsProvider:    fetches personalised sleep recommendations
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/analysis_repository.dart';
import '../models/derived_sleep_data.dart';
import '../models/recommendation.dart';
import 'api_provider.dart';

/// Provides an [AnalysisRepository] instance.
final analysisRepositoryProvider = Provider<AnalysisRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AnalysisRepository(apiClient);
});

/// Fetches the most recent completed sleep analysis for the current user.
///
/// Used by the Home screen to display the "Last Sleep Score" card.
/// Returns an AsyncValue<DerivedSleepData> (loading/data/error).
///
/// Use `ref.invalidate(latestAnalysisProvider)` to force a refresh.
final latestAnalysisProvider = FutureProvider<DerivedSleepData>((ref) async {
  final repository = ref.watch(analysisRepositoryProvider);
  return await repository.getLatestAnalysis();
});

/// Fetches personalised sleep improvement recommendations for the current user.
///
/// Based on the most recent sleep analysis metrics.
/// Returns an AsyncValue<List<Recommendation>> (loading/data/error).
final recommendationsProvider = FutureProvider<List<Recommendation>>((ref) async {
  final repository = ref.watch(analysisRepositoryProvider);
  return await repository.getRecommendations();
});

/// Fetches recommendations for a specific history record by its [derivedId].
///
/// Used by the sleep history detail screen so each entry shows its own
/// recommendations rather than the latest entry's.
final recommendationsByIdProvider =
    FutureProvider.family<List<Recommendation>, String>((ref, derivedId) async {
  final repository = ref.watch(analysisRepositoryProvider);
  return await repository.getRecommendations(derivedId: derivedId);
});
