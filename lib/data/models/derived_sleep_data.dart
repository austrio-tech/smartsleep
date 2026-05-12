// ─────────────────────────────────────────────────────────────────────────────
// derived_sleep_data.dart  –  Immutable model for one night's sleep analysis.
//
// This model mirrors the derived_sleep_data table in Supabase.
// Fields are populated in two stages:
//   1. Stub row created after pre-sleep phase (only id, user_id, raw_id, date)
//   2. Full analysis added after post-sleep phase (all feature/scoring fields)
//
// Hence, most fields are Optional — they may be null in the stub stage.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:freezed_annotation/freezed_annotation.dart';

part 'derived_sleep_data.freezed.dart';
part 'derived_sleep_data.g.dart';

/// Represents the computed analysis result for one night of sleep.
///
/// Created by the backend's sleep analysis pipeline after both
/// the pre-sleep (evening) and post-sleep (morning) phases are submitted.
@freezed
class DerivedSleepData with _$DerivedSleepData {
  const factory DerivedSleepData({
    // ── Record identification ─────────────────────────────────────────────
    @JsonKey(name: 'derived_id') String? id,      // Unique ID of this derived record
    @JsonKey(name: 'user_id')    String? userId,  // Which user this belongs to
    @JsonKey(name: 'raw_id')     String? rawId,   // Which raw_sleep_data record this came from
    required String date,                          // Sleep session date (YYYY-MM-DD)

    // ── Step 2: Core sleep metrics ────────────────────────────────────────
    double? tib,   // Time in Bed (hours) — total time from sleep to wake
    double? tst,   // Total Sleep Time (hours) — actual sleep, excluding awakenings
    @JsonKey(name: 'sleep_eff') double? sleepEfficiency,       // TST / TIB (0-1)
    @JsonKey(name: 'interrupt_index') double? interruptIndex,  // Awakenings per sleep hour
    @JsonKey(name: 'consistency_7d') double? consistency7d,   // 7-day schedule consistency (0-1)

    // ── Step 3: Lifestyle factors ─────────────────────────────────────────
    @JsonKey(name: 'caff_gap_hours') double? caffeineGapHours, // Hours from last caffeine to sleep
    @JsonKey(name: 'caff_impact')    double? caffeineImpact,   // Caffeine impact score (0.1/0.5/1.0)
    @JsonKey(name: 'screen_impact')  double? screenImpact,     // Screen exposure impact (0-1)
    @JsonKey(name: 'act_gap_hours')  double? activityGapHours, // Activity intensity impact (0/0.5/1.0)

    // ── Steps 4-6: Bio / Psych / Environmental composite scores ──────────
    @JsonKey(name: 'bio_ready')  double? biologicalReady,    // Biometric readiness vs personal baseline (0-1)
    @JsonKey(name: 'psych_load') double? psychologicalLoad,  // Stress + mood composite (0-1)
    @JsonKey(name: 'env_score')  double? environmentScore,   // Room temp, noise, light quality (0-1)

    // ── Scoring breakdown (Steps 8, 10, 16) ──────────────────────────────
    double? penalty,                                     // Total rule-based penalty points deducted
    @JsonKey(name: 'base_score')      double? baseScore, // Rule-based score (0-1)
    @JsonKey(name: 'ml_score')        double? mlScore,   // ML-predicted score (0-100)
    @JsonKey(name: 'final_score_raw') double? finalScoreRaw, // Blended score before clamping
    @JsonKey(name: 'final_score')     int?    finalScore,    // Final clamped score (0-100)

    // ── User feedback (set when user rates their sleep) ───────────────────
    @JsonKey(name: 'user_score') double? userScore, // User's self-reported quality (0-100)
    @JsonKey(name: 'user_class') String? userClass, // "Poor" / "Fair" / "Good" / "Excellent"

    @JsonKey(name: 'created_at') String? createdAt, // When this record was created
  }) = _DerivedSleepData;

  /// Creates a [DerivedSleepData] from a JSON map (from the API response).
  factory DerivedSleepData.fromJson(Map<String, dynamic> json) =>
      _$DerivedSleepDataFromJson(json);
}
