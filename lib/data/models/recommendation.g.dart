// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recommendation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RecommendationImpl _$$RecommendationImplFromJson(Map<String, dynamic> json) =>
    _$RecommendationImpl(
      category: json['category'] as String,
      message: json['message'] as String,
      priority: json['priority'] as String,
    );

Map<String, dynamic> _$$RecommendationImplToJson(
  _$RecommendationImpl instance,
) => <String, dynamic>{
  'category': instance.category,
  'message': instance.message,
  'priority': instance.priority,
};
