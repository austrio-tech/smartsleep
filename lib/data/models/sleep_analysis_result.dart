import 'package:freezed_annotation/freezed_annotation.dart';
import 'derived_sleep_data.dart';
import 'recommendation.dart';

part 'sleep_analysis_result.freezed.dart';
part 'sleep_analysis_result.g.dart';

@freezed
class SleepAnalysisResult with _$SleepAnalysisResult {
  const factory SleepAnalysisResult({
    required String date,
    required DerivedSleepData analysis,
    required List<Recommendation> recommendations,
  }) = _SleepAnalysisResult;

  factory SleepAnalysisResult.fromJson(Map<String, dynamic> json) => _$SleepAnalysisResultFromJson(json);
}
