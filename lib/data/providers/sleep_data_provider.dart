import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smartsleep/data/providers/analysis_provider.dart';
import '../repositories/sleep_data_repository.dart';
import '../models/raw_sleep_data.dart';
import '../models/derived_sleep_data.dart';
import 'api_provider.dart';

final sleepDataRepositoryProvider = Provider<SleepDataRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return SleepDataRepository(apiClient);
});

final preSleepFormProvider = StateProvider<RawSleepData>((ref) {
  return RawSleepData.empty();
});

final sleepHistoryProvider = FutureProvider<List<DerivedSleepData>>((ref) async {
  final repository = ref.watch(sleepDataRepositoryProvider);
  return await repository.getSleepHistory();
});

enum LoggingStage { 
  waitingForPreSleep, 
  waitingForPostSleep, 
  waitingForFeedback 
}

final loggingStageProvider = Provider<LoggingStage>((ref) {
  // Use sleepHistoryProvider as the source of truth for the workflow sequence
  final historyAsync = ref.watch(sleepHistoryProvider);
  
  return historyAsync.maybeWhen(
    data: (records) {
      if (records.isEmpty) return LoggingStage.waitingForPreSleep;
      
      final latest = records.first;
      
      // Stage 1: If the most recent night has user feedback, start a new day.
      if (latest.userScore != null) {
        return LoggingStage.waitingForPreSleep;
      }
      
      // Stage 2: If the record exists but has no metrics (tst), we are in "Morning Check-in" phase.
      if (latest.tst == null || latest.tst == 0) {
        return LoggingStage.waitingForPostSleep;
      }
      
      // Stage 3: Sleep metrics logged (Analysis exists), but user hasn't rated it yet.
      return LoggingStage.waitingForFeedback;
    },
    // On loading or error, default to waiting for pre-sleep to allow data entry
    orElse: () => LoggingStage.waitingForPreSleep,
  );
});

final activeSleepRecordProvider = Provider<DerivedSleepData?>((ref) {
  final historyAsync = ref.watch(sleepHistoryProvider);
  return historyAsync.maybeWhen(
    data: (records) => records.isNotEmpty ? records.first : null,
    orElse: () => null,
  );
});
