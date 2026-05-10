// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'raw_sleep_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

RawSleepData _$RawSleepDataFromJson(Map<String, dynamic> json) {
  return _RawSleepData.fromJson(json);
}

/// @nodoc
mixin _$RawSleepData {
  @JsonKey(name: 'record_date')
  String? get recordDate => throw _privateConstructorUsedError;
  @JsonKey(name: 'sleep_time')
  String? get sleepTime => throw _privateConstructorUsedError;
  @JsonKey(name: 'wake_time')
  String? get wakeTime => throw _privateConstructorUsedError;
  int? get awakenings => throw _privateConstructorUsedError;
  @JsonKey(name: 'sleep_latency_minutes')
  int? get sleepLatencyMinutes => throw _privateConstructorUsedError;
  int? get naps => throw _privateConstructorUsedError;
  @JsonKey(name: 'hr_rest')
  int? get heartRateRest => throw _privateConstructorUsedError;
  int? get hrv => throw _privateConstructorUsedError;
  @JsonKey(name: 'body_temp')
  double? get bodyTemp => throw _privateConstructorUsedError;
  @JsonKey(name: 'resp_rate')
  int? get respiratoryRate => throw _privateConstructorUsedError;
  @JsonKey(name: 'caffeine_time')
  String? get caffeineTime => throw _privateConstructorUsedError;
  @JsonKey(name: 'caffeine_mg')
  int? get caffeineMg => throw _privateConstructorUsedError;
  @JsonKey(name: 'alcohol_units')
  int? get alcoholUnits => throw _privateConstructorUsedError;
  @JsonKey(name: 'water_liters')
  double? get waterLiters => throw _privateConstructorUsedError;
  int? get steps => throw _privateConstructorUsedError;
  @JsonKey(name: 'activity_intensity')
  String? get activityIntensity => throw _privateConstructorUsedError;
  @JsonKey(name: 'screen_minutes_before_bed')
  int? get screenMinutesBeforeBed => throw _privateConstructorUsedError;
  int? get stress => throw _privateConstructorUsedError;
  int? get mood => throw _privateConstructorUsedError;
  @JsonKey(name: 'room_temp')
  double? get roomTemp => throw _privateConstructorUsedError;
  @JsonKey(name: 'noise_db')
  int? get noiseDb => throw _privateConstructorUsedError;
  @JsonKey(name: 'light_lux')
  int? get lightLux => throw _privateConstructorUsedError;

  /// Serializes this RawSleepData to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RawSleepData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RawSleepDataCopyWith<RawSleepData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RawSleepDataCopyWith<$Res> {
  factory $RawSleepDataCopyWith(
    RawSleepData value,
    $Res Function(RawSleepData) then,
  ) = _$RawSleepDataCopyWithImpl<$Res, RawSleepData>;
  @useResult
  $Res call({
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
  });
}

/// @nodoc
class _$RawSleepDataCopyWithImpl<$Res, $Val extends RawSleepData>
    implements $RawSleepDataCopyWith<$Res> {
  _$RawSleepDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RawSleepData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? recordDate = freezed,
    Object? sleepTime = freezed,
    Object? wakeTime = freezed,
    Object? awakenings = freezed,
    Object? sleepLatencyMinutes = freezed,
    Object? naps = freezed,
    Object? heartRateRest = freezed,
    Object? hrv = freezed,
    Object? bodyTemp = freezed,
    Object? respiratoryRate = freezed,
    Object? caffeineTime = freezed,
    Object? caffeineMg = freezed,
    Object? alcoholUnits = freezed,
    Object? waterLiters = freezed,
    Object? steps = freezed,
    Object? activityIntensity = freezed,
    Object? screenMinutesBeforeBed = freezed,
    Object? stress = freezed,
    Object? mood = freezed,
    Object? roomTemp = freezed,
    Object? noiseDb = freezed,
    Object? lightLux = freezed,
  }) {
    return _then(
      _value.copyWith(
            recordDate: freezed == recordDate
                ? _value.recordDate
                : recordDate // ignore: cast_nullable_to_non_nullable
                      as String?,
            sleepTime: freezed == sleepTime
                ? _value.sleepTime
                : sleepTime // ignore: cast_nullable_to_non_nullable
                      as String?,
            wakeTime: freezed == wakeTime
                ? _value.wakeTime
                : wakeTime // ignore: cast_nullable_to_non_nullable
                      as String?,
            awakenings: freezed == awakenings
                ? _value.awakenings
                : awakenings // ignore: cast_nullable_to_non_nullable
                      as int?,
            sleepLatencyMinutes: freezed == sleepLatencyMinutes
                ? _value.sleepLatencyMinutes
                : sleepLatencyMinutes // ignore: cast_nullable_to_non_nullable
                      as int?,
            naps: freezed == naps
                ? _value.naps
                : naps // ignore: cast_nullable_to_non_nullable
                      as int?,
            heartRateRest: freezed == heartRateRest
                ? _value.heartRateRest
                : heartRateRest // ignore: cast_nullable_to_non_nullable
                      as int?,
            hrv: freezed == hrv
                ? _value.hrv
                : hrv // ignore: cast_nullable_to_non_nullable
                      as int?,
            bodyTemp: freezed == bodyTemp
                ? _value.bodyTemp
                : bodyTemp // ignore: cast_nullable_to_non_nullable
                      as double?,
            respiratoryRate: freezed == respiratoryRate
                ? _value.respiratoryRate
                : respiratoryRate // ignore: cast_nullable_to_non_nullable
                      as int?,
            caffeineTime: freezed == caffeineTime
                ? _value.caffeineTime
                : caffeineTime // ignore: cast_nullable_to_non_nullable
                      as String?,
            caffeineMg: freezed == caffeineMg
                ? _value.caffeineMg
                : caffeineMg // ignore: cast_nullable_to_non_nullable
                      as int?,
            alcoholUnits: freezed == alcoholUnits
                ? _value.alcoholUnits
                : alcoholUnits // ignore: cast_nullable_to_non_nullable
                      as int?,
            waterLiters: freezed == waterLiters
                ? _value.waterLiters
                : waterLiters // ignore: cast_nullable_to_non_nullable
                      as double?,
            steps: freezed == steps
                ? _value.steps
                : steps // ignore: cast_nullable_to_non_nullable
                      as int?,
            activityIntensity: freezed == activityIntensity
                ? _value.activityIntensity
                : activityIntensity // ignore: cast_nullable_to_non_nullable
                      as String?,
            screenMinutesBeforeBed: freezed == screenMinutesBeforeBed
                ? _value.screenMinutesBeforeBed
                : screenMinutesBeforeBed // ignore: cast_nullable_to_non_nullable
                      as int?,
            stress: freezed == stress
                ? _value.stress
                : stress // ignore: cast_nullable_to_non_nullable
                      as int?,
            mood: freezed == mood
                ? _value.mood
                : mood // ignore: cast_nullable_to_non_nullable
                      as int?,
            roomTemp: freezed == roomTemp
                ? _value.roomTemp
                : roomTemp // ignore: cast_nullable_to_non_nullable
                      as double?,
            noiseDb: freezed == noiseDb
                ? _value.noiseDb
                : noiseDb // ignore: cast_nullable_to_non_nullable
                      as int?,
            lightLux: freezed == lightLux
                ? _value.lightLux
                : lightLux // ignore: cast_nullable_to_non_nullable
                      as int?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$RawSleepDataImplCopyWith<$Res>
    implements $RawSleepDataCopyWith<$Res> {
  factory _$$RawSleepDataImplCopyWith(
    _$RawSleepDataImpl value,
    $Res Function(_$RawSleepDataImpl) then,
  ) = __$$RawSleepDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
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
  });
}

/// @nodoc
class __$$RawSleepDataImplCopyWithImpl<$Res>
    extends _$RawSleepDataCopyWithImpl<$Res, _$RawSleepDataImpl>
    implements _$$RawSleepDataImplCopyWith<$Res> {
  __$$RawSleepDataImplCopyWithImpl(
    _$RawSleepDataImpl _value,
    $Res Function(_$RawSleepDataImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of RawSleepData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? recordDate = freezed,
    Object? sleepTime = freezed,
    Object? wakeTime = freezed,
    Object? awakenings = freezed,
    Object? sleepLatencyMinutes = freezed,
    Object? naps = freezed,
    Object? heartRateRest = freezed,
    Object? hrv = freezed,
    Object? bodyTemp = freezed,
    Object? respiratoryRate = freezed,
    Object? caffeineTime = freezed,
    Object? caffeineMg = freezed,
    Object? alcoholUnits = freezed,
    Object? waterLiters = freezed,
    Object? steps = freezed,
    Object? activityIntensity = freezed,
    Object? screenMinutesBeforeBed = freezed,
    Object? stress = freezed,
    Object? mood = freezed,
    Object? roomTemp = freezed,
    Object? noiseDb = freezed,
    Object? lightLux = freezed,
  }) {
    return _then(
      _$RawSleepDataImpl(
        recordDate: freezed == recordDate
            ? _value.recordDate
            : recordDate // ignore: cast_nullable_to_non_nullable
                  as String?,
        sleepTime: freezed == sleepTime
            ? _value.sleepTime
            : sleepTime // ignore: cast_nullable_to_non_nullable
                  as String?,
        wakeTime: freezed == wakeTime
            ? _value.wakeTime
            : wakeTime // ignore: cast_nullable_to_non_nullable
                  as String?,
        awakenings: freezed == awakenings
            ? _value.awakenings
            : awakenings // ignore: cast_nullable_to_non_nullable
                  as int?,
        sleepLatencyMinutes: freezed == sleepLatencyMinutes
            ? _value.sleepLatencyMinutes
            : sleepLatencyMinutes // ignore: cast_nullable_to_non_nullable
                  as int?,
        naps: freezed == naps
            ? _value.naps
            : naps // ignore: cast_nullable_to_non_nullable
                  as int?,
        heartRateRest: freezed == heartRateRest
            ? _value.heartRateRest
            : heartRateRest // ignore: cast_nullable_to_non_nullable
                  as int?,
        hrv: freezed == hrv
            ? _value.hrv
            : hrv // ignore: cast_nullable_to_non_nullable
                  as int?,
        bodyTemp: freezed == bodyTemp
            ? _value.bodyTemp
            : bodyTemp // ignore: cast_nullable_to_non_nullable
                  as double?,
        respiratoryRate: freezed == respiratoryRate
            ? _value.respiratoryRate
            : respiratoryRate // ignore: cast_nullable_to_non_nullable
                  as int?,
        caffeineTime: freezed == caffeineTime
            ? _value.caffeineTime
            : caffeineTime // ignore: cast_nullable_to_non_nullable
                  as String?,
        caffeineMg: freezed == caffeineMg
            ? _value.caffeineMg
            : caffeineMg // ignore: cast_nullable_to_non_nullable
                  as int?,
        alcoholUnits: freezed == alcoholUnits
            ? _value.alcoholUnits
            : alcoholUnits // ignore: cast_nullable_to_non_nullable
                  as int?,
        waterLiters: freezed == waterLiters
            ? _value.waterLiters
            : waterLiters // ignore: cast_nullable_to_non_nullable
                  as double?,
        steps: freezed == steps
            ? _value.steps
            : steps // ignore: cast_nullable_to_non_nullable
                  as int?,
        activityIntensity: freezed == activityIntensity
            ? _value.activityIntensity
            : activityIntensity // ignore: cast_nullable_to_non_nullable
                  as String?,
        screenMinutesBeforeBed: freezed == screenMinutesBeforeBed
            ? _value.screenMinutesBeforeBed
            : screenMinutesBeforeBed // ignore: cast_nullable_to_non_nullable
                  as int?,
        stress: freezed == stress
            ? _value.stress
            : stress // ignore: cast_nullable_to_non_nullable
                  as int?,
        mood: freezed == mood
            ? _value.mood
            : mood // ignore: cast_nullable_to_non_nullable
                  as int?,
        roomTemp: freezed == roomTemp
            ? _value.roomTemp
            : roomTemp // ignore: cast_nullable_to_non_nullable
                  as double?,
        noiseDb: freezed == noiseDb
            ? _value.noiseDb
            : noiseDb // ignore: cast_nullable_to_non_nullable
                  as int?,
        lightLux: freezed == lightLux
            ? _value.lightLux
            : lightLux // ignore: cast_nullable_to_non_nullable
                  as int?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$RawSleepDataImpl implements _RawSleepData {
  const _$RawSleepDataImpl({
    @JsonKey(name: 'record_date') this.recordDate,
    @JsonKey(name: 'sleep_time') this.sleepTime,
    @JsonKey(name: 'wake_time') this.wakeTime,
    this.awakenings,
    @JsonKey(name: 'sleep_latency_minutes') this.sleepLatencyMinutes,
    this.naps,
    @JsonKey(name: 'hr_rest') this.heartRateRest,
    this.hrv,
    @JsonKey(name: 'body_temp') this.bodyTemp,
    @JsonKey(name: 'resp_rate') this.respiratoryRate,
    @JsonKey(name: 'caffeine_time') this.caffeineTime,
    @JsonKey(name: 'caffeine_mg') this.caffeineMg,
    @JsonKey(name: 'alcohol_units') this.alcoholUnits,
    @JsonKey(name: 'water_liters') this.waterLiters,
    this.steps,
    @JsonKey(name: 'activity_intensity') this.activityIntensity,
    @JsonKey(name: 'screen_minutes_before_bed') this.screenMinutesBeforeBed,
    this.stress,
    this.mood,
    @JsonKey(name: 'room_temp') this.roomTemp,
    @JsonKey(name: 'noise_db') this.noiseDb,
    @JsonKey(name: 'light_lux') this.lightLux,
  });

  factory _$RawSleepDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$RawSleepDataImplFromJson(json);

  @override
  @JsonKey(name: 'record_date')
  final String? recordDate;
  @override
  @JsonKey(name: 'sleep_time')
  final String? sleepTime;
  @override
  @JsonKey(name: 'wake_time')
  final String? wakeTime;
  @override
  final int? awakenings;
  @override
  @JsonKey(name: 'sleep_latency_minutes')
  final int? sleepLatencyMinutes;
  @override
  final int? naps;
  @override
  @JsonKey(name: 'hr_rest')
  final int? heartRateRest;
  @override
  final int? hrv;
  @override
  @JsonKey(name: 'body_temp')
  final double? bodyTemp;
  @override
  @JsonKey(name: 'resp_rate')
  final int? respiratoryRate;
  @override
  @JsonKey(name: 'caffeine_time')
  final String? caffeineTime;
  @override
  @JsonKey(name: 'caffeine_mg')
  final int? caffeineMg;
  @override
  @JsonKey(name: 'alcohol_units')
  final int? alcoholUnits;
  @override
  @JsonKey(name: 'water_liters')
  final double? waterLiters;
  @override
  final int? steps;
  @override
  @JsonKey(name: 'activity_intensity')
  final String? activityIntensity;
  @override
  @JsonKey(name: 'screen_minutes_before_bed')
  final int? screenMinutesBeforeBed;
  @override
  final int? stress;
  @override
  final int? mood;
  @override
  @JsonKey(name: 'room_temp')
  final double? roomTemp;
  @override
  @JsonKey(name: 'noise_db')
  final int? noiseDb;
  @override
  @JsonKey(name: 'light_lux')
  final int? lightLux;

  @override
  String toString() {
    return 'RawSleepData(recordDate: $recordDate, sleepTime: $sleepTime, wakeTime: $wakeTime, awakenings: $awakenings, sleepLatencyMinutes: $sleepLatencyMinutes, naps: $naps, heartRateRest: $heartRateRest, hrv: $hrv, bodyTemp: $bodyTemp, respiratoryRate: $respiratoryRate, caffeineTime: $caffeineTime, caffeineMg: $caffeineMg, alcoholUnits: $alcoholUnits, waterLiters: $waterLiters, steps: $steps, activityIntensity: $activityIntensity, screenMinutesBeforeBed: $screenMinutesBeforeBed, stress: $stress, mood: $mood, roomTemp: $roomTemp, noiseDb: $noiseDb, lightLux: $lightLux)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RawSleepDataImpl &&
            (identical(other.recordDate, recordDate) ||
                other.recordDate == recordDate) &&
            (identical(other.sleepTime, sleepTime) ||
                other.sleepTime == sleepTime) &&
            (identical(other.wakeTime, wakeTime) ||
                other.wakeTime == wakeTime) &&
            (identical(other.awakenings, awakenings) ||
                other.awakenings == awakenings) &&
            (identical(other.sleepLatencyMinutes, sleepLatencyMinutes) ||
                other.sleepLatencyMinutes == sleepLatencyMinutes) &&
            (identical(other.naps, naps) || other.naps == naps) &&
            (identical(other.heartRateRest, heartRateRest) ||
                other.heartRateRest == heartRateRest) &&
            (identical(other.hrv, hrv) || other.hrv == hrv) &&
            (identical(other.bodyTemp, bodyTemp) ||
                other.bodyTemp == bodyTemp) &&
            (identical(other.respiratoryRate, respiratoryRate) ||
                other.respiratoryRate == respiratoryRate) &&
            (identical(other.caffeineTime, caffeineTime) ||
                other.caffeineTime == caffeineTime) &&
            (identical(other.caffeineMg, caffeineMg) ||
                other.caffeineMg == caffeineMg) &&
            (identical(other.alcoholUnits, alcoholUnits) ||
                other.alcoholUnits == alcoholUnits) &&
            (identical(other.waterLiters, waterLiters) ||
                other.waterLiters == waterLiters) &&
            (identical(other.steps, steps) || other.steps == steps) &&
            (identical(other.activityIntensity, activityIntensity) ||
                other.activityIntensity == activityIntensity) &&
            (identical(other.screenMinutesBeforeBed, screenMinutesBeforeBed) ||
                other.screenMinutesBeforeBed == screenMinutesBeforeBed) &&
            (identical(other.stress, stress) || other.stress == stress) &&
            (identical(other.mood, mood) || other.mood == mood) &&
            (identical(other.roomTemp, roomTemp) ||
                other.roomTemp == roomTemp) &&
            (identical(other.noiseDb, noiseDb) || other.noiseDb == noiseDb) &&
            (identical(other.lightLux, lightLux) ||
                other.lightLux == lightLux));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
    runtimeType,
    recordDate,
    sleepTime,
    wakeTime,
    awakenings,
    sleepLatencyMinutes,
    naps,
    heartRateRest,
    hrv,
    bodyTemp,
    respiratoryRate,
    caffeineTime,
    caffeineMg,
    alcoholUnits,
    waterLiters,
    steps,
    activityIntensity,
    screenMinutesBeforeBed,
    stress,
    mood,
    roomTemp,
    noiseDb,
    lightLux,
  ]);

  /// Create a copy of RawSleepData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RawSleepDataImplCopyWith<_$RawSleepDataImpl> get copyWith =>
      __$$RawSleepDataImplCopyWithImpl<_$RawSleepDataImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RawSleepDataImplToJson(this);
  }
}

abstract class _RawSleepData implements RawSleepData {
  const factory _RawSleepData({
    @JsonKey(name: 'record_date') final String? recordDate,
    @JsonKey(name: 'sleep_time') final String? sleepTime,
    @JsonKey(name: 'wake_time') final String? wakeTime,
    final int? awakenings,
    @JsonKey(name: 'sleep_latency_minutes') final int? sleepLatencyMinutes,
    final int? naps,
    @JsonKey(name: 'hr_rest') final int? heartRateRest,
    final int? hrv,
    @JsonKey(name: 'body_temp') final double? bodyTemp,
    @JsonKey(name: 'resp_rate') final int? respiratoryRate,
    @JsonKey(name: 'caffeine_time') final String? caffeineTime,
    @JsonKey(name: 'caffeine_mg') final int? caffeineMg,
    @JsonKey(name: 'alcohol_units') final int? alcoholUnits,
    @JsonKey(name: 'water_liters') final double? waterLiters,
    final int? steps,
    @JsonKey(name: 'activity_intensity') final String? activityIntensity,
    @JsonKey(name: 'screen_minutes_before_bed')
    final int? screenMinutesBeforeBed,
    final int? stress,
    final int? mood,
    @JsonKey(name: 'room_temp') final double? roomTemp,
    @JsonKey(name: 'noise_db') final int? noiseDb,
    @JsonKey(name: 'light_lux') final int? lightLux,
  }) = _$RawSleepDataImpl;

  factory _RawSleepData.fromJson(Map<String, dynamic> json) =
      _$RawSleepDataImpl.fromJson;

  @override
  @JsonKey(name: 'record_date')
  String? get recordDate;
  @override
  @JsonKey(name: 'sleep_time')
  String? get sleepTime;
  @override
  @JsonKey(name: 'wake_time')
  String? get wakeTime;
  @override
  int? get awakenings;
  @override
  @JsonKey(name: 'sleep_latency_minutes')
  int? get sleepLatencyMinutes;
  @override
  int? get naps;
  @override
  @JsonKey(name: 'hr_rest')
  int? get heartRateRest;
  @override
  int? get hrv;
  @override
  @JsonKey(name: 'body_temp')
  double? get bodyTemp;
  @override
  @JsonKey(name: 'resp_rate')
  int? get respiratoryRate;
  @override
  @JsonKey(name: 'caffeine_time')
  String? get caffeineTime;
  @override
  @JsonKey(name: 'caffeine_mg')
  int? get caffeineMg;
  @override
  @JsonKey(name: 'alcohol_units')
  int? get alcoholUnits;
  @override
  @JsonKey(name: 'water_liters')
  double? get waterLiters;
  @override
  int? get steps;
  @override
  @JsonKey(name: 'activity_intensity')
  String? get activityIntensity;
  @override
  @JsonKey(name: 'screen_minutes_before_bed')
  int? get screenMinutesBeforeBed;
  @override
  int? get stress;
  @override
  int? get mood;
  @override
  @JsonKey(name: 'room_temp')
  double? get roomTemp;
  @override
  @JsonKey(name: 'noise_db')
  int? get noiseDb;
  @override
  @JsonKey(name: 'light_lux')
  int? get lightLux;

  /// Create a copy of RawSleepData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RawSleepDataImplCopyWith<_$RawSleepDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
