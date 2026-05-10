import 'package:freezed_annotation/freezed_annotation.dart';

part 'derived_sleep_data.freezed.dart';
part 'derived_sleep_data.g.dart';

@freezed
class DerivedSleepData with _$DerivedSleepData {
  const factory DerivedSleepData({
    @JsonKey(name: 'derived_id') String? id,
    @JsonKey(name: 'user_id') String? userId,
    @JsonKey(name: 'raw_id') String? rawId,
    required String date,

    // Sleep Metrics
    double? tib,
    double? tst,
    @JsonKey(name: 'sleep_eff') double? sleepEfficiency,
    @JsonKey(name: 'interrupt_index') double? interruptIndex,
    @JsonKey(name: 'consistency_7d') double? consistency7d,

    // Lifestyle Factors
    @JsonKey(name: 'caff_gap_hours') double? caffeineGapHours,
    @JsonKey(name: 'caff_impact') double? caffeineImpact,
    @JsonKey(name: 'screen_impact') double? screenImpact,
    @JsonKey(name: 'act_gap_hours') double? activityGapHours,

    // Composite Scores
    @JsonKey(name: 'bio_ready') double? biologicalReady,
    @JsonKey(name: 'psych_load') double? psychologicalLoad,
    @JsonKey(name: 'env_score') double? environmentScore,

    // Scoring Breakdown
    double? penalty,
    @JsonKey(name: 'base_score') double? baseScore,
    @JsonKey(name: 'ml_score') double? mlScore,
    @JsonKey(name: 'final_score_raw') double? finalScoreRaw,
    @JsonKey(name: 'final_score') int? finalScore,
    
    // Feedback & Personalization
    @JsonKey(name: 'user_score') double? userScore,
    @JsonKey(name: 'user_class') String? userClass,
    
    @JsonKey(name: 'created_at') String? createdAt,
  }) = _DerivedSleepData;

  factory DerivedSleepData.fromJson(Map<String, dynamic> json) => _$DerivedSleepDataFromJson(json);
}
