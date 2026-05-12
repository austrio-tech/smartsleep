// ─────────────────────────────────────────────────────────────────────────────
// sleep_data_provider.dart  –  Riverpod providers for sleep logging workflow.
//
// This file defines the providers for the two-phase sleep logging workflow:
//
//   Pre-sleep (evening)  →  Post-sleep (morning)  →  Feedback
//      waitingForPreSleep  →  waitingForPostSleep  →  waitingForFeedback
//
// loggingStageProvider reads the sleep history and derives which stage
// the user is currently in. The Home screen uses this to enable/disable
// the correct check-in button.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smartsleep/data/providers/analysis_provider.dart';
import '../repositories/sleep_data_repository.dart';
import '../models/raw_sleep_data.dart';
import '../models/derived_sleep_data.dart';
import 'api_provider.dart';

/// Provides a [SleepDataRepository] instance.
final sleepDataRepositoryProvider = Provider<SleepDataRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return SleepDataRepository(apiClient);
});

/// Holds the partially-filled pre-sleep form data while the user fills in fields.
///
/// StateProvider is the simplest Riverpod provider for mutable state.
/// It's like a global variable that widgets can read and write.
/// Initialised with an empty [RawSleepData] object.
final preSleepFormProvider = StateProvider<RawSleepData>((ref) {
  return RawSleepData.empty();
});

/// Fetches the full sleep history (all derived_sleep_data records) for the user.
///
/// Returns AsyncValue<List<DerivedSleepData>> (loading/data/error).
/// This is the source of truth used by [loggingStageProvider] to determine
/// the current workflow stage.
final sleepHistoryProvider = FutureProvider<List<DerivedSleepData>>((ref) async {
  final repository = ref.watch(sleepDataRepositoryProvider);
  return await repository.getSleepHistory();
});

/// The three stages of the daily sleep logging workflow.
enum LoggingStage {
  waitingForPreSleep,   // Evening check-in not yet done
  waitingForPostSleep,  // Evening done, waiting for morning check-in
  waitingForFeedback,   // Both phases done, waiting for user to rate their sleep
}

/// Derives the current logging stage from the sleep history.
///
/// This is a computed provider — it watches sleepHistoryProvider and derives
/// the current stage from the most recent record's state. No network call needed.
///
/// Logic:
///   - No records, OR latest record has user feedback → waitingForPreSleep (start fresh)
///   - Latest record has no TST (metrics) → waitingForPostSleep (morning entry pending)
///   - Latest record has metrics but no user rating → waitingForFeedback
final loggingStageProvider = Provider<LoggingStage>((ref) {
  // Watch the sleep history async value
  final historyAsync = ref.watch(sleepHistoryProvider);

  // .maybeWhen() handles only the cases we specify, with an `orElse` fallback.
  return historyAsync.maybeWhen(
    data: (records) {
      // No sleep records yet — definitely waiting to start the first evening check-in
      if (records.isEmpty) return LoggingStage.waitingForPreSleep;

      final latest = records.first; // History is ordered newest-first

      // Stage check 1: If the latest record already has user feedback,
      // the previous cycle is complete — start a new day with a new pre-sleep entry.
      if (latest.userScore != null) {
        return LoggingStage.waitingForPreSleep;
      }

      // Stage check 2: If tst (Total Sleep Time) is null or 0, the post-sleep
      // phase hasn't been submitted yet — the derived stub was created by pre-sleep,
      // but no actual analysis has been run (morning check-in is pending).
      if (latest.tst == null || latest.tst == 0) {
        return LoggingStage.waitingForPostSleep;
      }

      // Stage check 3: Full analysis exists but no user rating — prompt for feedback.
      return LoggingStage.waitingForFeedback;
    },
    // On loading or error, default to pre-sleep so the user can always enter data
    orElse: () => LoggingStage.waitingForPreSleep,
  );
});

/// Returns the most recent derived sleep record, or null if none exist.
///
/// The Home screen uses this to display the latest sleep score card.
final activeSleepRecordProvider = Provider<DerivedSleepData?>((ref) {
  final historyAsync = ref.watch(sleepHistoryProvider);
  return historyAsync.maybeWhen(
    data: (records) => records.isNotEmpty ? records.first : null,
    orElse: () => null,
  );
});
