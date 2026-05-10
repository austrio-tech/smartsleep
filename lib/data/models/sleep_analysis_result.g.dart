// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sleep_analysis_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SleepAnalysisResultImpl _$$SleepAnalysisResultImplFromJson(
  Map<String, dynamic> json,
) => _$SleepAnalysisResultImpl(
  date: json['date'] as String,
  analysis: DerivedSleepData.fromJson(json['analysis'] as Map<String, dynamic>),
  recommendations: (json['recommendations'] as List<dynamic>)
      .map((e) => Recommendation.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$$SleepAnalysisResultImplToJson(
  _$SleepAnalysisResultImpl instance,
) => <String, dynamic>{
  'date': instance.date,
  'analysis': instance.analysis,
  'recommendations': instance.recommendations,
};
