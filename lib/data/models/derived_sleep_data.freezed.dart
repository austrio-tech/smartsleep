// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'derived_sleep_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

DerivedSleepData _$DerivedSleepDataFromJson(Map<String, dynamic> json) {
  return _DerivedSleepData.fromJson(json);
}

/// @nodoc
mixin _$DerivedSleepData {
  @JsonKey(name: 'derived_id')
  String? get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'user_id')
  String? get userId => throw _privateConstructorUsedError;
  @JsonKey(name: 'raw_id')
  String? get rawId => throw _privateConstructorUsedError;
  String get date => throw _privateConstructorUsedError; // Sleep Metrics
  double? get tib => throw _privateConstructorUsedError;
  double? get tst => throw _privateConstructorUsedError;
  @JsonKey(name: 'sleep_eff')
  double? get sleepEfficiency => throw _privateConstructorUsedError;
  @JsonKey(name: 'interrupt_index')
  double? get interruptIndex => throw _privateConstructorUsedError;
  @JsonKey(name: 'consistency_7d')
  double? get consistency7d => throw _privateConstructorUsedError; // Lifestyle Factors
  @JsonKey(name: 'caff_gap_hours')
  double? get caffeineGapHours => throw _privateConstructorUsedError;
  @JsonKey(name: 'caff_impact')
  double? get caffeineImpact => throw _privateConstructorUsedError;
  @JsonKey(name: 'screen_impact')
  double? get screenImpact => throw _privateConstructorUsedError;
  @JsonKey(name: 'act_gap_hours')
  double? get activityGapHours => throw _privateConstructorUsedError; // Composite Scores
  @JsonKey(name: 'bio_ready')
  double? get biologicalReady => throw _privateConstructorUsedError;
  @JsonKey(name: 'psych_load')
  double? get psychologicalLoad => throw _privateConstructorUsedError;
  @JsonKey(name: 'env_score')
  double? get environmentScore => throw _privateConstructorUsedError; // Scoring Breakdown
  double? get penalty => throw _privateConstructorUsedError;
  @JsonKey(name: 'base_score')
  double? get baseScore => throw _privateConstructorUsedError;
  @JsonKey(name: 'ml_score')
  double? get mlScore => throw _privateConstructorUsedError;
  @JsonKey(name: 'final_score_raw')
  double? get finalScoreRaw => throw _privateConstructorUsedError;
  @JsonKey(name: 'final_score')
  int? get finalScore => throw _privateConstructorUsedError; // Feedback & Personalization
  @JsonKey(name: 'user_score')
  double? get userScore => throw _privateConstructorUsedError;
  @JsonKey(name: 'user_class')
  String? get userClass => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  String? get createdAt => throw _privateConstructorUsedError;

  /// Serializes this DerivedSleepData to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DerivedSleepData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DerivedSleepDataCopyWith<DerivedSleepData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DerivedSleepDataCopyWith<$Res> {
  factory $DerivedSleepDataCopyWith(
    DerivedSleepData value,
    $Res Function(DerivedSleepData) then,
  ) = _$DerivedSleepDataCopyWithImpl<$Res, DerivedSleepData>;
  @useResult
  $Res call({
    @JsonKey(name: 'derived_id') String? id,
    @JsonKey(name: 'user_id') String? userId,
    @JsonKey(name: 'raw_id') String? rawId,
    String date,
    double? tib,
    double? tst,
    @JsonKey(name: 'sleep_eff') double? sleepEfficiency,
    @JsonKey(name: 'interrupt_index') double? interruptIndex,
    @JsonKey(name: 'consistency_7d') double? consistency7d,
    @JsonKey(name: 'caff_gap_hours') double? caffeineGapHours,
    @JsonKey(name: 'caff_impact') double? caffeineImpact,
    @JsonKey(name: 'screen_impact') double? screenImpact,
    @JsonKey(name: 'act_gap_hours') double? activityGapHours,
    @JsonKey(name: 'bio_ready') double? biologicalReady,
    @JsonKey(name: 'psych_load') double? psychologicalLoad,
    @JsonKey(name: 'env_score') double? environmentScore,
    double? penalty,
    @JsonKey(name: 'base_score') double? baseScore,
    @JsonKey(name: 'ml_score') double? mlScore,
    @JsonKey(name: 'final_score_raw') double? finalScoreRaw,
    @JsonKey(name: 'final_score') int? finalScore,
    @JsonKey(name: 'user_score') double? userScore,
    @JsonKey(name: 'user_class') String? userClass,
    @JsonKey(name: 'created_at') String? createdAt,
  });
}

/// @nodoc
class _$DerivedSleepDataCopyWithImpl<$Res, $Val extends DerivedSleepData>
    implements $DerivedSleepDataCopyWith<$Res> {
  _$DerivedSleepDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DerivedSleepData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? userId = freezed,
    Object? rawId = freezed,
    Object? date = null,
    Object? tib = freezed,
    Object? tst = freezed,
    Object? sleepEfficiency = freezed,
    Object? interruptIndex = freezed,
    Object? consistency7d = freezed,
    Object? caffeineGapHours = freezed,
    Object? caffeineImpact = freezed,
    Object? screenImpact = freezed,
    Object? activityGapHours = freezed,
    Object? biologicalReady = freezed,
    Object? psychologicalLoad = freezed,
    Object? environmentScore = freezed,
    Object? penalty = freezed,
    Object? baseScore = freezed,
    Object? mlScore = freezed,
    Object? finalScoreRaw = freezed,
    Object? finalScore = freezed,
    Object? userScore = freezed,
    Object? userClass = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: freezed == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String?,
            userId: freezed == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String?,
            rawId: freezed == rawId
                ? _value.rawId
                : rawId // ignore: cast_nullable_to_non_nullable
                      as String?,
            date: null == date
                ? _value.date
                : date // ignore: cast_nullable_to_non_nullable
                      as String,
            tib: freezed == tib
                ? _value.tib
                : tib // ignore: cast_nullable_to_non_nullable
                      as double?,
            tst: freezed == tst
                ? _value.tst
                : tst // ignore: cast_nullable_to_non_nullable
                      as double?,
            sleepEfficiency: freezed == sleepEfficiency
                ? _value.sleepEfficiency
                : sleepEfficiency // ignore: cast_nullable_to_non_nullable
                      as double?,
            interruptIndex: freezed == interruptIndex
                ? _value.interruptIndex
                : interruptIndex // ignore: cast_nullable_to_non_nullable
                      as double?,
            consistency7d: freezed == consistency7d
                ? _value.consistency7d
                : consistency7d // ignore: cast_nullable_to_non_nullable
                      as double?,
            caffeineGapHours: freezed == caffeineGapHours
                ? _value.caffeineGapHours
                : caffeineGapHours // ignore: cast_nullable_to_non_nullable
                      as double?,
            caffeineImpact: freezed == caffeineImpact
                ? _value.caffeineImpact
                : caffeineImpact // ignore: cast_nullable_to_non_nullable
                      as double?,
            screenImpact: freezed == screenImpact
                ? _value.screenImpact
                : screenImpact // ignore: cast_nullable_to_non_nullable
                      as double?,
            activityGapHours: freezed == activityGapHours
                ? _value.activityGapHours
                : activityGapHours // ignore: cast_nullable_to_non_nullable
                      as double?,
            biologicalReady: freezed == biologicalReady
                ? _value.biologicalReady
                : biologicalReady // ignore: cast_nullable_to_non_nullable
                      as double?,
            psychologicalLoad: freezed == psychologicalLoad
                ? _value.psychologicalLoad
                : psychologicalLoad // ignore: cast_nullable_to_non_nullable
                      as double?,
            environmentScore: freezed == environmentScore
                ? _value.environmentScore
                : environmentScore // ignore: cast_nullable_to_non_nullable
                      as double?,
            penalty: freezed == penalty
                ? _value.penalty
                : penalty // ignore: cast_nullable_to_non_nullable
                      as double?,
            baseScore: freezed == baseScore
                ? _value.baseScore
                : baseScore // ignore: cast_nullable_to_non_nullable
                      as double?,
            mlScore: freezed == mlScore
                ? _value.mlScore
                : mlScore // ignore: cast_nullable_to_non_nullable
                      as double?,
            finalScoreRaw: freezed == finalScoreRaw
                ? _value.finalScoreRaw
                : finalScoreRaw // ignore: cast_nullable_to_non_nullable
                      as double?,
            finalScore: freezed == finalScore
                ? _value.finalScore
                : finalScore // ignore: cast_nullable_to_non_nullable
                      as int?,
            userScore: freezed == userScore
                ? _value.userScore
                : userScore // ignore: cast_nullable_to_non_nullable
                      as double?,
            userClass: freezed == userClass
                ? _value.userClass
                : userClass // ignore: cast_nullable_to_non_nullable
                      as String?,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$DerivedSleepDataImplCopyWith<$Res>
    implements $DerivedSleepDataCopyWith<$Res> {
  factory _$$DerivedSleepDataImplCopyWith(
    _$DerivedSleepDataImpl value,
    $Res Function(_$DerivedSleepDataImpl) then,
  ) = __$$DerivedSleepDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'derived_id') String? id,
    @JsonKey(name: 'user_id') String? userId,
    @JsonKey(name: 'raw_id') String? rawId,
    String date,
    double? tib,
    double? tst,
    @JsonKey(name: 'sleep_eff') double? sleepEfficiency,
    @JsonKey(name: 'interrupt_index') double? interruptIndex,
    @JsonKey(name: 'consistency_7d') double? consistency7d,
    @JsonKey(name: 'caff_gap_hours') double? caffeineGapHours,
    @JsonKey(name: 'caff_impact') double? caffeineImpact,
    @JsonKey(name: 'screen_impact') double? screenImpact,
    @JsonKey(name: 'act_gap_hours') double? activityGapHours,
    @JsonKey(name: 'bio_ready') double? biologicalReady,
    @JsonKey(name: 'psych_load') double? psychologicalLoad,
    @JsonKey(name: 'env_score') double? environmentScore,
    double? penalty,
    @JsonKey(name: 'base_score') double? baseScore,
    @JsonKey(name: 'ml_score') double? mlScore,
    @JsonKey(name: 'final_score_raw') double? finalScoreRaw,
    @JsonKey(name: 'final_score') int? finalScore,
    @JsonKey(name: 'user_score') double? userScore,
    @JsonKey(name: 'user_class') String? userClass,
    @JsonKey(name: 'created_at') String? createdAt,
  });
}

/// @nodoc
class __$$DerivedSleepDataImplCopyWithImpl<$Res>
    extends _$DerivedSleepDataCopyWithImpl<$Res, _$DerivedSleepDataImpl>
    implements _$$DerivedSleepDataImplCopyWith<$Res> {
  __$$DerivedSleepDataImplCopyWithImpl(
    _$DerivedSleepDataImpl _value,
    $Res Function(_$DerivedSleepDataImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DerivedSleepData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? userId = freezed,
    Object? rawId = freezed,
    Object? date = null,
    Object? tib = freezed,
    Object? tst = freezed,
    Object? sleepEfficiency = freezed,
    Object? interruptIndex = freezed,
    Object? consistency7d = freezed,
    Object? caffeineGapHours = freezed,
    Object? caffeineImpact = freezed,
    Object? screenImpact = freezed,
    Object? activityGapHours = freezed,
    Object? biologicalReady = freezed,
    Object? psychologicalLoad = freezed,
    Object? environmentScore = freezed,
    Object? penalty = freezed,
    Object? baseScore = freezed,
    Object? mlScore = freezed,
    Object? finalScoreRaw = freezed,
    Object? finalScore = freezed,
    Object? userScore = freezed,
    Object? userClass = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(
      _$DerivedSleepDataImpl(
        id: freezed == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String?,
        userId: freezed == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String?,
        rawId: freezed == rawId
            ? _value.rawId
            : rawId // ignore: cast_nullable_to_non_nullable
                  as String?,
        date: null == date
            ? _value.date
            : date // ignore: cast_nullable_to_non_nullable
                  as String,
        tib: freezed == tib
            ? _value.tib
            : tib // ignore: cast_nullable_to_non_nullable
                  as double?,
        tst: freezed == tst
            ? _value.tst
            : tst // ignore: cast_nullable_to_non_nullable
                  as double?,
        sleepEfficiency: freezed == sleepEfficiency
            ? _value.sleepEfficiency
            : sleepEfficiency // ignore: cast_nullable_to_non_nullable
                  as double?,
        interruptIndex: freezed == interruptIndex
            ? _value.interruptIndex
            : interruptIndex // ignore: cast_nullable_to_non_nullable
                  as double?,
        consistency7d: freezed == consistency7d
            ? _value.consistency7d
            : consistency7d // ignore: cast_nullable_to_non_nullable
                  as double?,
        caffeineGapHours: freezed == caffeineGapHours
            ? _value.caffeineGapHours
            : caffeineGapHours // ignore: cast_nullable_to_non_nullable
                  as double?,
        caffeineImpact: freezed == caffeineImpact
            ? _value.caffeineImpact
            : caffeineImpact // ignore: cast_nullable_to_non_nullable
                  as double?,
        screenImpact: freezed == screenImpact
            ? _value.screenImpact
            : screenImpact // ignore: cast_nullable_to_non_nullable
                  as double?,
        activityGapHours: freezed == activityGapHours
            ? _value.activityGapHours
            : activityGapHours // ignore: cast_nullable_to_non_nullable
                  as double?,
        biologicalReady: freezed == biologicalReady
            ? _value.biologicalReady
            : biologicalReady // ignore: cast_nullable_to_non_nullable
                  as double?,
        psychologicalLoad: freezed == psychologicalLoad
            ? _value.psychologicalLoad
            : psychologicalLoad // ignore: cast_nullable_to_non_nullable
                  as double?,
        environmentScore: freezed == environmentScore
            ? _value.environmentScore
            : environmentScore // ignore: cast_nullable_to_non_nullable
                  as double?,
        penalty: freezed == penalty
            ? _value.penalty
            : penalty // ignore: cast_nullable_to_non_nullable
                  as double?,
        baseScore: freezed == baseScore
            ? _value.baseScore
            : baseScore // ignore: cast_nullable_to_non_nullable
                  as double?,
        mlScore: freezed == mlScore
            ? _value.mlScore
            : mlScore // ignore: cast_nullable_to_non_nullable
                  as double?,
        finalScoreRaw: freezed == finalScoreRaw
            ? _value.finalScoreRaw
            : finalScoreRaw // ignore: cast_nullable_to_non_nullable
                  as double?,
        finalScore: freezed == finalScore
            ? _value.finalScore
            : finalScore // ignore: cast_nullable_to_non_nullable
                  as int?,
        userScore: freezed == userScore
            ? _value.userScore
            : userScore // ignore: cast_nullable_to_non_nullable
                  as double?,
        userClass: freezed == userClass
            ? _value.userClass
            : userClass // ignore: cast_nullable_to_non_nullable
                  as String?,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$DerivedSleepDataImpl implements _DerivedSleepData {
  const _$DerivedSleepDataImpl({
    @JsonKey(name: 'derived_id') this.id,
    @JsonKey(name: 'user_id') this.userId,
    @JsonKey(name: 'raw_id') this.rawId,
    required this.date,
    this.tib,
    this.tst,
    @JsonKey(name: 'sleep_eff') this.sleepEfficiency,
    @JsonKey(name: 'interrupt_index') this.interruptIndex,
    @JsonKey(name: 'consistency_7d') this.consistency7d,
    @JsonKey(name: 'caff_gap_hours') this.caffeineGapHours,
    @JsonKey(name: 'caff_impact') this.caffeineImpact,
    @JsonKey(name: 'screen_impact') this.screenImpact,
    @JsonKey(name: 'act_gap_hours') this.activityGapHours,
    @JsonKey(name: 'bio_ready') this.biologicalReady,
    @JsonKey(name: 'psych_load') this.psychologicalLoad,
    @JsonKey(name: 'env_score') this.environmentScore,
    this.penalty,
    @JsonKey(name: 'base_score') this.baseScore,
    @JsonKey(name: 'ml_score') this.mlScore,
    @JsonKey(name: 'final_score_raw') this.finalScoreRaw,
    @JsonKey(name: 'final_score') this.finalScore,
    @JsonKey(name: 'user_score') this.userScore,
    @JsonKey(name: 'user_class') this.userClass,
    @JsonKey(name: 'created_at') this.createdAt,
  });

  factory _$DerivedSleepDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$DerivedSleepDataImplFromJson(json);

  @override
  @JsonKey(name: 'derived_id')
  final String? id;
  @override
  @JsonKey(name: 'user_id')
  final String? userId;
  @override
  @JsonKey(name: 'raw_id')
  final String? rawId;
  @override
  final String date;
  // Sleep Metrics
  @override
  final double? tib;
  @override
  final double? tst;
  @override
  @JsonKey(name: 'sleep_eff')
  final double? sleepEfficiency;
  @override
  @JsonKey(name: 'interrupt_index')
  final double? interruptIndex;
  @override
  @JsonKey(name: 'consistency_7d')
  final double? consistency7d;
  // Lifestyle Factors
  @override
  @JsonKey(name: 'caff_gap_hours')
  final double? caffeineGapHours;
  @override
  @JsonKey(name: 'caff_impact')
  final double? caffeineImpact;
  @override
  @JsonKey(name: 'screen_impact')
  final double? screenImpact;
  @override
  @JsonKey(name: 'act_gap_hours')
  final double? activityGapHours;
  // Composite Scores
  @override
  @JsonKey(name: 'bio_ready')
  final double? biologicalReady;
  @override
  @JsonKey(name: 'psych_load')
  final double? psychologicalLoad;
  @override
  @JsonKey(name: 'env_score')
  final double? environmentScore;
  // Scoring Breakdown
  @override
  final double? penalty;
  @override
  @JsonKey(name: 'base_score')
  final double? baseScore;
  @override
  @JsonKey(name: 'ml_score')
  final double? mlScore;
  @override
  @JsonKey(name: 'final_score_raw')
  final double? finalScoreRaw;
  @override
  @JsonKey(name: 'final_score')
  final int? finalScore;
  // Feedback & Personalization
  @override
  @JsonKey(name: 'user_score')
  final double? userScore;
  @override
  @JsonKey(name: 'user_class')
  final String? userClass;
  @override
  @JsonKey(name: 'created_at')
  final String? createdAt;

  @override
  String toString() {
    return 'DerivedSleepData(id: $id, userId: $userId, rawId: $rawId, date: $date, tib: $tib, tst: $tst, sleepEfficiency: $sleepEfficiency, interruptIndex: $interruptIndex, consistency7d: $consistency7d, caffeineGapHours: $caffeineGapHours, caffeineImpact: $caffeineImpact, screenImpact: $screenImpact, activityGapHours: $activityGapHours, biologicalReady: $biologicalReady, psychologicalLoad: $psychologicalLoad, environmentScore: $environmentScore, penalty: $penalty, baseScore: $baseScore, mlScore: $mlScore, finalScoreRaw: $finalScoreRaw, finalScore: $finalScore, userScore: $userScore, userClass: $userClass, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DerivedSleepDataImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.rawId, rawId) || other.rawId == rawId) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.tib, tib) || other.tib == tib) &&
            (identical(other.tst, tst) || other.tst == tst) &&
            (identical(other.sleepEfficiency, sleepEfficiency) ||
                other.sleepEfficiency == sleepEfficiency) &&
            (identical(other.interruptIndex, interruptIndex) ||
                other.interruptIndex == interruptIndex) &&
            (identical(other.consistency7d, consistency7d) ||
                other.consistency7d == consistency7d) &&
            (identical(other.caffeineGapHours, caffeineGapHours) ||
                other.caffeineGapHours == caffeineGapHours) &&
            (identical(other.caffeineImpact, caffeineImpact) ||
                other.caffeineImpact == caffeineImpact) &&
            (identical(other.screenImpact, screenImpact) ||
                other.screenImpact == screenImpact) &&
            (identical(other.activityGapHours, activityGapHours) ||
                other.activityGapHours == activityGapHours) &&
            (identical(other.biologicalReady, biologicalReady) ||
                other.biologicalReady == biologicalReady) &&
            (identical(other.psychologicalLoad, psychologicalLoad) ||
                other.psychologicalLoad == psychologicalLoad) &&
            (identical(other.environmentScore, environmentScore) ||
                other.environmentScore == environmentScore) &&
            (identical(other.penalty, penalty) || other.penalty == penalty) &&
            (identical(other.baseScore, baseScore) ||
                other.baseScore == baseScore) &&
            (identical(other.mlScore, mlScore) || other.mlScore == mlScore) &&
            (identical(other.finalScoreRaw, finalScoreRaw) ||
                other.finalScoreRaw == finalScoreRaw) &&
            (identical(other.finalScore, finalScore) ||
                other.finalScore == finalScore) &&
            (identical(other.userScore, userScore) ||
                other.userScore == userScore) &&
            (identical(other.userClass, userClass) ||
                other.userClass == userClass) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
    runtimeType,
    id,
    userId,
    rawId,
    date,
    tib,
    tst,
    sleepEfficiency,
    interruptIndex,
    consistency7d,
    caffeineGapHours,
    caffeineImpact,
    screenImpact,
    activityGapHours,
    biologicalReady,
    psychologicalLoad,
    environmentScore,
    penalty,
    baseScore,
    mlScore,
    finalScoreRaw,
    finalScore,
    userScore,
    userClass,
    createdAt,
  ]);

  /// Create a copy of DerivedSleepData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DerivedSleepDataImplCopyWith<_$DerivedSleepDataImpl> get copyWith =>
      __$$DerivedSleepDataImplCopyWithImpl<_$DerivedSleepDataImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$DerivedSleepDataImplToJson(this);
  }
}

abstract class _DerivedSleepData implements DerivedSleepData {
  const factory _DerivedSleepData({
    @JsonKey(name: 'derived_id') final String? id,
    @JsonKey(name: 'user_id') final String? userId,
    @JsonKey(name: 'raw_id') final String? rawId,
    required final String date,
    final double? tib,
    final double? tst,
    @JsonKey(name: 'sleep_eff') final double? sleepEfficiency,
    @JsonKey(name: 'interrupt_index') final double? interruptIndex,
    @JsonKey(name: 'consistency_7d') final double? consistency7d,
    @JsonKey(name: 'caff_gap_hours') final double? caffeineGapHours,
    @JsonKey(name: 'caff_impact') final double? caffeineImpact,
    @JsonKey(name: 'screen_impact') final double? screenImpact,
    @JsonKey(name: 'act_gap_hours') final double? activityGapHours,
    @JsonKey(name: 'bio_ready') final double? biologicalReady,
    @JsonKey(name: 'psych_load') final double? psychologicalLoad,
    @JsonKey(name: 'env_score') final double? environmentScore,
    final double? penalty,
    @JsonKey(name: 'base_score') final double? baseScore,
    @JsonKey(name: 'ml_score') final double? mlScore,
    @JsonKey(name: 'final_score_raw') final double? finalScoreRaw,
    @JsonKey(name: 'final_score') final int? finalScore,
    @JsonKey(name: 'user_score') final double? userScore,
    @JsonKey(name: 'user_class') final String? userClass,
    @JsonKey(name: 'created_at') final String? createdAt,
  }) = _$DerivedSleepDataImpl;

  factory _DerivedSleepData.fromJson(Map<String, dynamic> json) =
      _$DerivedSleepDataImpl.fromJson;

  @override
  @JsonKey(name: 'derived_id')
  String? get id;
  @override
  @JsonKey(name: 'user_id')
  String? get userId;
  @override
  @JsonKey(name: 'raw_id')
  String? get rawId;
  @override
  String get date; // Sleep Metrics
  @override
  double? get tib;
  @override
  double? get tst;
  @override
  @JsonKey(name: 'sleep_eff')
  double? get sleepEfficiency;
  @override
  @JsonKey(name: 'interrupt_index')
  double? get interruptIndex;
  @override
  @JsonKey(name: 'consistency_7d')
  double? get consistency7d; // Lifestyle Factors
  @override
  @JsonKey(name: 'caff_gap_hours')
  double? get caffeineGapHours;
  @override
  @JsonKey(name: 'caff_impact')
  double? get caffeineImpact;
  @override
  @JsonKey(name: 'screen_impact')
  double? get screenImpact;
  @override
  @JsonKey(name: 'act_gap_hours')
  double? get activityGapHours; // Composite Scores
  @override
  @JsonKey(name: 'bio_ready')
  double? get biologicalReady;
  @override
  @JsonKey(name: 'psych_load')
  double? get psychologicalLoad;
  @override
  @JsonKey(name: 'env_score')
  double? get environmentScore; // Scoring Breakdown
  @override
  double? get penalty;
  @override
  @JsonKey(name: 'base_score')
  double? get baseScore;
  @override
  @JsonKey(name: 'ml_score')
  double? get mlScore;
  @override
  @JsonKey(name: 'final_score_raw')
  double? get finalScoreRaw;
  @override
  @JsonKey(name: 'final_score')
  int? get finalScore; // Feedback & Personalization
  @override
  @JsonKey(name: 'user_score')
  double? get userScore;
  @override
  @JsonKey(name: 'user_class')
  String? get userClass;
  @override
  @JsonKey(name: 'created_at')
  String? get createdAt;

  /// Create a copy of DerivedSleepData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DerivedSleepDataImplCopyWith<_$DerivedSleepDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
