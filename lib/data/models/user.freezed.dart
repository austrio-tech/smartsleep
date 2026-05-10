// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

User _$UserFromJson(Map<String, dynamic> json) {
  return _User.fromJson(json);
}

/// @nodoc
mixin _$User {
  @JsonKey(name: 'user_id')
  String get id => throw _privateConstructorUsedError;
  String get email => throw _privateConstructorUsedError;
  @JsonKey(name: 'full_name')
  String? get fullName => throw _privateConstructorUsedError;
  @JsonKey(name: 'email_confirmed')
  bool? get emailConfirmed => throw _privateConstructorUsedError;
  int? get age => throw _privateConstructorUsedError;
  String? get gender => throw _privateConstructorUsedError;
  @JsonKey(name: 'weight_kg')
  double? get weightKg => throw _privateConstructorUsedError;
  @JsonKey(name: 'height_cm')
  double? get heightCm => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  String? get createdAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserCopyWith<User> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserCopyWith<$Res> {
  factory $UserCopyWith(User value, $Res Function(User) then) =
      _$UserCopyWithImpl<$Res, User>;
  @useResult
  $Res call({
    @JsonKey(name: 'user_id') String id,
    String email,
    @JsonKey(name: 'full_name') String? fullName,
    @JsonKey(name: 'email_confirmed') bool? emailConfirmed,
    int? age,
    String? gender,
    @JsonKey(name: 'weight_kg') double? weightKg,
    @JsonKey(name: 'height_cm') double? heightCm,
    @JsonKey(name: 'created_at') String? createdAt,
  });
}

/// @nodoc
class _$UserCopyWithImpl<$Res, $Val extends User>
    implements $UserCopyWith<$Res> {
  _$UserCopyWithImpl(this._value, this._then);

  final $Val _value;
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? email = null,
    Object? fullName = freezed,
    Object? emailConfirmed = freezed,
    Object? age = freezed,
    Object? gender = freezed,
    Object? weightKg = freezed,
    Object? heightCm = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id ? _value.id : id as String,
            email: null == email ? _value.email : email as String,
            fullName: freezed == fullName ? _value.fullName : fullName as String?,
            emailConfirmed: freezed == emailConfirmed ? _value.emailConfirmed : emailConfirmed as bool?,
            age: freezed == age ? _value.age : age as int?,
            gender: freezed == gender ? _value.gender : gender as String?,
            weightKg: freezed == weightKg ? _value.weightKg : weightKg as double?,
            heightCm: freezed == heightCm ? _value.heightCm : heightCm as double?,
            createdAt: freezed == createdAt ? _value.createdAt : createdAt as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$UserImplCopyWith<$Res> implements $UserCopyWith<$Res> {
  factory _$$UserImplCopyWith(_$UserImpl value, $Res Function(_$UserImpl) then) =
      __$$UserImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'user_id') String id,
    String email,
    @JsonKey(name: 'full_name') String? fullName,
    @JsonKey(name: 'email_confirmed') bool? emailConfirmed,
    int? age,
    String? gender,
    @JsonKey(name: 'weight_kg') double? weightKg,
    @JsonKey(name: 'height_cm') double? heightCm,
    @JsonKey(name: 'created_at') String? createdAt,
  });
}

/// @nodoc
class __$$UserImplCopyWithImpl<$Res>
    extends _$UserCopyWithImpl<$Res, _$UserImpl>
    implements _$$UserImplCopyWith<$Res> {
  __$$UserImplCopyWithImpl(_$UserImpl _value, $Res Function(_$UserImpl) _then)
    : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? email = null,
    Object? fullName = freezed,
    Object? emailConfirmed = freezed,
    Object? age = freezed,
    Object? gender = freezed,
    Object? weightKg = freezed,
    Object? heightCm = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(
      _$UserImpl(
        id: null == id ? _value.id : id as String,
        email: null == email ? _value.email : email as String,
        fullName: freezed == fullName ? _value.fullName : fullName as String?,
        emailConfirmed: freezed == emailConfirmed ? _value.emailConfirmed : emailConfirmed as bool?,
        age: freezed == age ? _value.age : age as int?,
        gender: freezed == gender ? _value.gender : gender as String?,
        weightKg: freezed == weightKg ? _value.weightKg : weightKg as double?,
        heightCm: freezed == heightCm ? _value.heightCm : heightCm as double?,
        createdAt: freezed == createdAt ? _value.createdAt : createdAt as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$UserImpl implements _User {
  const _$UserImpl({
    @JsonKey(name: 'user_id') required this.id,
    required this.email,
    @JsonKey(name: 'full_name') this.fullName,
    @JsonKey(name: 'email_confirmed') this.emailConfirmed,
    this.age,
    this.gender,
    @JsonKey(name: 'weight_kg') this.weightKg,
    @JsonKey(name: 'height_cm') this.heightCm,
    @JsonKey(name: 'created_at') this.createdAt,
  });

  factory _$UserImpl.fromJson(Map<String, dynamic> json) => _$$UserImplFromJson(json);

  @override
  @JsonKey(name: 'user_id')
  final String id;
  @override
  final String email;
  @override
  @JsonKey(name: 'full_name')
  final String? fullName;
  @override
  @JsonKey(name: 'email_confirmed')
  final bool? emailConfirmed;
  @override
  final int? age;
  @override
  final String? gender;
  @override
  @JsonKey(name: 'weight_kg')
  final double? weightKg;
  @override
  @JsonKey(name: 'height_cm')
  final double? heightCm;
  @override
  @JsonKey(name: 'created_at')
  final String? createdAt;

  @override
  String toString() {
    return 'User(id: $id, email: $email, fullName: $fullName, emailConfirmed: $emailConfirmed, age: $age, gender: $gender, weightKg: $weightKg, heightCm: $heightCm, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.fullName, fullName) || other.fullName == fullName) &&
            (identical(other.emailConfirmed, emailConfirmed) || other.emailConfirmed == emailConfirmed) &&
            (identical(other.age, age) || other.age == age) &&
            (identical(other.gender, gender) || other.gender == gender) &&
            (identical(other.weightKg, weightKg) || other.weightKg == weightKg) &&
            (identical(other.heightCm, heightCm) || other.heightCm == heightCm) &&
            (identical(other.createdAt, createdAt) || other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, email, fullName, emailConfirmed, age, gender, weightKg, heightCm, createdAt);

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserImplCopyWith<_$UserImpl> get copyWith =>
      __$$UserImplCopyWithImpl<_$UserImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserImplToJson(this);
  }
}

abstract class _User implements User {
  const factory _User({
    @JsonKey(name: 'user_id') required final String id,
    required final String email,
    @JsonKey(name: 'full_name') final String? fullName,
    @JsonKey(name: 'email_confirmed') final bool? emailConfirmed,
    final int? age,
    final String? gender,
    @JsonKey(name: 'weight_kg') final double? weightKg,
    @JsonKey(name: 'height_cm') final double? heightCm,
    @JsonKey(name: 'created_at') final String? createdAt,
  }) = _$UserImpl;

  factory _User.fromJson(Map<String, dynamic> json) = _$UserImpl.fromJson;

  @override
  @JsonKey(name: 'user_id')
  String get id;
  @override
  String get email;
  @override
  @JsonKey(name: 'full_name')
  String? get fullName;
  @override
  @JsonKey(name: 'email_confirmed')
  bool? get emailConfirmed;
  @override
  int? get age;
  @override
  String? get gender;
  @override
  @JsonKey(name: 'weight_kg')
  double? get weightKg;
  @override
  @JsonKey(name: 'height_cm')
  double? get heightCm;
  @override
  @JsonKey(name: 'created_at')
  String? get createdAt;

  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserImplCopyWith<_$UserImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
