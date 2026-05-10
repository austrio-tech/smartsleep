// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sleep_analysis_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

SleepAnalysisResult _$SleepAnalysisResultFromJson(Map<String, dynamic> json) {
  return _SleepAnalysisResult.fromJson(json);
}

/// @nodoc
mixin _$SleepAnalysisResult {
  String get date => throw _privateConstructorUsedError;
  DerivedSleepData get analysis => throw _privateConstructorUsedError;
  List<Recommendation> get recommendations =>
      throw _privateConstructorUsedError;

  /// Serializes this SleepAnalysisResult to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SleepAnalysisResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SleepAnalysisResultCopyWith<SleepAnalysisResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SleepAnalysisResultCopyWith<$Res> {
  factory $SleepAnalysisResultCopyWith(
    SleepAnalysisResult value,
    $Res Function(SleepAnalysisResult) then,
  ) = _$SleepAnalysisResultCopyWithImpl<$Res, SleepAnalysisResult>;
  @useResult
  $Res call({
    String date,
    DerivedSleepData analysis,
    List<Recommendation> recommendations,
  });

  $DerivedSleepDataCopyWith<$Res> get analysis;
}

/// @nodoc
class _$SleepAnalysisResultCopyWithImpl<$Res, $Val extends SleepAnalysisResult>
    implements $SleepAnalysisResultCopyWith<$Res> {
  _$SleepAnalysisResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SleepAnalysisResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? analysis = null,
    Object? recommendations = null,
  }) {
    return _then(
      _value.copyWith(
            date: null == date
                ? _value.date
                : date // ignore: cast_nullable_to_non_nullable
                      as String,
            analysis: null == analysis
                ? _value.analysis
                : analysis // ignore: cast_nullable_to_non_nullable
                      as DerivedSleepData,
            recommendations: null == recommendations
                ? _value.recommendations
                : recommendations // ignore: cast_nullable_to_non_nullable
                      as List<Recommendation>,
          )
          as $Val,
    );
  }

  /// Create a copy of SleepAnalysisResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $DerivedSleepDataCopyWith<$Res> get analysis {
    return $DerivedSleepDataCopyWith<$Res>(_value.analysis, (value) {
      return _then(_value.copyWith(analysis: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$SleepAnalysisResultImplCopyWith<$Res>
    implements $SleepAnalysisResultCopyWith<$Res> {
  factory _$$SleepAnalysisResultImplCopyWith(
    _$SleepAnalysisResultImpl value,
    $Res Function(_$SleepAnalysisResultImpl) then,
  ) = __$$SleepAnalysisResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String date,
    DerivedSleepData analysis,
    List<Recommendation> recommendations,
  });

  @override
  $DerivedSleepDataCopyWith<$Res> get analysis;
}

/// @nodoc
class __$$SleepAnalysisResultImplCopyWithImpl<$Res>
    extends _$SleepAnalysisResultCopyWithImpl<$Res, _$SleepAnalysisResultImpl>
    implements _$$SleepAnalysisResultImplCopyWith<$Res> {
  __$$SleepAnalysisResultImplCopyWithImpl(
    _$SleepAnalysisResultImpl _value,
    $Res Function(_$SleepAnalysisResultImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SleepAnalysisResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? analysis = null,
    Object? recommendations = null,
  }) {
    return _then(
      _$SleepAnalysisResultImpl(
        date: null == date
            ? _value.date
            : date // ignore: cast_nullable_to_non_nullable
                  as String,
        analysis: null == analysis
            ? _value.analysis
            : analysis // ignore: cast_nullable_to_non_nullable
                  as DerivedSleepData,
        recommendations: null == recommendations
            ? _value._recommendations
            : recommendations // ignore: cast_nullable_to_non_nullable
                  as List<Recommendation>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SleepAnalysisResultImpl implements _SleepAnalysisResult {
  const _$SleepAnalysisResultImpl({
    required this.date,
    required this.analysis,
    required final List<Recommendation> recommendations,
  }) : _recommendations = recommendations;

  factory _$SleepAnalysisResultImpl.fromJson(Map<String, dynamic> json) =>
      _$$SleepAnalysisResultImplFromJson(json);

  @override
  final String date;
  @override
  final DerivedSleepData analysis;
  final List<Recommendation> _recommendations;
  @override
  List<Recommendation> get recommendations {
    if (_recommendations is EqualUnmodifiableListView) return _recommendations;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_recommendations);
  }

  @override
  String toString() {
    return 'SleepAnalysisResult(date: $date, analysis: $analysis, recommendations: $recommendations)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SleepAnalysisResultImpl &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.analysis, analysis) ||
                other.analysis == analysis) &&
            const DeepCollectionEquality().equals(
              other._recommendations,
              _recommendations,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    date,
    analysis,
    const DeepCollectionEquality().hash(_recommendations),
  );

  /// Create a copy of SleepAnalysisResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SleepAnalysisResultImplCopyWith<_$SleepAnalysisResultImpl> get copyWith =>
      __$$SleepAnalysisResultImplCopyWithImpl<_$SleepAnalysisResultImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$SleepAnalysisResultImplToJson(this);
  }
}

abstract class _SleepAnalysisResult implements SleepAnalysisResult {
  const factory _SleepAnalysisResult({
    required final String date,
    required final DerivedSleepData analysis,
    required final List<Recommendation> recommendations,
  }) = _$SleepAnalysisResultImpl;

  factory _SleepAnalysisResult.fromJson(Map<String, dynamic> json) =
      _$SleepAnalysisResultImpl.fromJson;

  @override
  String get date;
  @override
  DerivedSleepData get analysis;
  @override
  List<Recommendation> get recommendations;

  /// Create a copy of SleepAnalysisResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SleepAnalysisResultImplCopyWith<_$SleepAnalysisResultImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
