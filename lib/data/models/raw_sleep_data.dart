// ─────────────────────────────────────────────────────────────────────────────
// raw_sleep_data.dart  –  Immutable model for raw sleep input from the user.
//
// This model holds the data entered by the user in the two-phase check-in:
//   Phase 1 (Evening): caffeine, alcohol, activity, stress, screen time
//   Phase 2 (Morning): sleep/wake times, biometrics, mood, environment
//
// Not all fields are filled at once — the two phases fill different subsets.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:freezed_annotation/freezed_annotation.dart';

part 'raw_sleep_data.freezed.dart';
part 'raw_sleep_data.g.dart';

/// Raw sleep data entered by the user across two daily check-ins.
///
/// Used as the state for the pre-sleep form (preSleepFormProvider)
/// and serialised to JSON before being submitted to the /ingest endpoint.
@freezed
class RawSleepData with _$RawSleepData {
  const factory RawSleepData({
    // ── Record metadata ───────────────────────────────────────────────────
    @JsonKey(name: 'record_date') String? recordDate,  // Date: "YYYY-MM-DD"

    // ── Phase 2 (Morning): Sleep timing ───────────────────────────────────
    @JsonKey(name: 'sleep_time') String? sleepTime,    // When the user went to bed: "HH:MM:SS"
    @JsonKey(name: 'wake_time')  String? wakeTime,     // When the user woke up: "HH:MM:SS"
    int? awakenings,                                    // Number of times woken during night
    @JsonKey(name: 'sleep_latency_minutes') int? sleepLatencyMinutes, // Minutes to fall asleep
    int? naps,                                          // Number of daytime naps

    // ── Phase 2 (Morning): Biometrics ─────────────────────────────────────
    @JsonKey(name: 'hr_rest') int? heartRateRest,       // Resting heart rate (BPM)
    int? hrv,                                           // Heart Rate Variability (milliseconds)
    @JsonKey(name: 'body_temp') double? bodyTemp,       // Body temperature (Celsius)
    @JsonKey(name: 'resp_rate') int? respiratoryRate,   // Breaths per minute

    // ── Phase 1 (Evening): Lifestyle factors ──────────────────────────────
    @JsonKey(name: 'caffeine_time') String? caffeineTime, // Time of last caffeine: "HH:MM:SS"
    @JsonKey(name: 'caffeine_mg')   int? caffeineMg,      // Caffeine amount in milligrams
    @JsonKey(name: 'alcohol_units') int? alcoholUnits,    // Alcoholic drinks consumed
    @JsonKey(name: 'water_liters')  double? waterLiters,  // Water intake in litres
    int? steps,                                           // Total daily step count
    @JsonKey(name: 'activity_intensity') String? activityIntensity, // "Low", "Medium", "High"
    @JsonKey(name: 'screen_minutes_before_bed') int? screenMinutesBeforeBed, // Screen time before bed

    // ── Phase 1 (Evening): Subjective state ───────────────────────────────
    int? stress, // Stress level on 1-10 scale (1=very relaxed, 10=extremely stressed)
    int? mood,   // Mood on 1-10 scale (1=very bad, 10=excellent)

    // ── Phase 2 (Morning): Environment ────────────────────────────────────
    @JsonKey(name: 'room_temp') double? roomTemp, // Room temperature in Celsius
    @JsonKey(name: 'noise_db')  int? noiseDb,     // Average noise level in decibels
    @JsonKey(name: 'light_lux') int? lightLux,    // Average light level in lux
  }) = _RawSleepData;

  /// Creates a [RawSleepData] from a JSON map.
  factory RawSleepData.fromJson(Map<String, dynamic> json) => _$RawSleepDataFromJson(json);

  /// Creates an empty [RawSleepData] with all fields set to null.
  ///
  /// Used to initialise the preSleepFormProvider at app start so we
  /// have a blank slate for the user to fill in.
  factory RawSleepData.empty() => const RawSleepData();
}
