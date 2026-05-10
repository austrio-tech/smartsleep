import 'package:freezed_annotation/freezed_annotation.dart';

part 'raw_sleep_data.freezed.dart';
part 'raw_sleep_data.g.dart';

@freezed
class RawSleepData with _$RawSleepData {
  const factory RawSleepData({
    @JsonKey(name: 'record_date') String? recordDate,
    @JsonKey(name: 'sleep_time') String? sleepTime,
    @JsonKey(name: 'wake_time') String? wakeTime,
    int? awakenings,
    @JsonKey(name: 'sleep_latency_minutes') int? sleepLatencyMinutes,
    int? naps,
    @JsonKey(name: 'hr_rest') int? heartRateRest,
    int? hrv,
    @JsonKey(name: 'body_temp') double? bodyTemp,
    @JsonKey(name: 'resp_rate') int? respiratoryRate,
    @JsonKey(name: 'caffeine_time') String? caffeineTime,
    @JsonKey(name: 'caffeine_mg') int? caffeineMg,
    @JsonKey(name: 'alcohol_units') int? alcoholUnits,
    @JsonKey(name: 'water_liters') double? waterLiters,
    int? steps,
    @JsonKey(name: 'activity_intensity') String? activityIntensity,
    @JsonKey(name: 'screen_minutes_before_bed') int? screenMinutesBeforeBed,
    int? stress,
    int? mood,
    @JsonKey(name: 'room_temp') double? roomTemp,
    @JsonKey(name: 'noise_db') int? noiseDb,
    @JsonKey(name: 'light_lux') int? lightLux,
  }) = _RawSleepData;

  factory RawSleepData.fromJson(Map<String, dynamic> json) => _$RawSleepDataFromJson(json);

  factory RawSleepData.empty() => const RawSleepData();
}
