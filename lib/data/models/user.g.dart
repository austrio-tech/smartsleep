// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserImpl _$$UserImplFromJson(Map<String, dynamic> json) => _$UserImpl(
  id: json['user_id'] as String,
  email: json['email'] as String,
  fullName: json['full_name'] as String?,
  emailConfirmed: json['email_confirmed'] as bool?,
  age: (json['age'] as num?)?.toInt(),
  gender: json['gender'] as String?,
  weightKg: (json['weight_kg'] as num?)?.toDouble(),
  heightCm: (json['height_cm'] as num?)?.toDouble(),
  createdAt: json['created_at'] as String?,
);

Map<String, dynamic> _$$UserImplToJson(_$UserImpl instance) =>
    <String, dynamic>{
      'user_id': instance.id,
      'email': instance.email,
      'full_name': instance.fullName,
      'email_confirmed': instance.emailConfirmed,
      'age': instance.age,
      'gender': instance.gender,
      'weight_kg': instance.weightKg,
      'height_cm': instance.heightCm,
      'created_at': instance.createdAt,
    };
