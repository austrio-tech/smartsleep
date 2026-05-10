// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'derived_sleep_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DerivedSleepDataImpl _$$DerivedSleepDataImplFromJson(
  Map<String, dynamic> json,
) => _$DerivedSleepDataImpl(
  id: json['derived_id'] as String?,
  userId: json['user_id'] as String?,
  rawId: json['raw_id'] as String?,
  date: json['date'] as String,
  tib: (json['tib'] as num?)?.toDouble(),
  tst: (json['tst'] as num?)?.toDouble(),
  sleepEfficiency: (json['sleep_eff'] as num?)?.toDouble(),
  interruptIndex: (json['interrupt_index'] as num?)?.toDouble(),
  consistency7d: (json['consistency_7d'] as num?)?.toDouble(),
  caffeineGapHours: (json['caff_gap_hours'] as num?)?.toDouble(),
  caffeineImpact: (json['caff_impact'] as num?)?.toDouble(),
  screenImpact: (json['screen_impact'] as num?)?.toDouble(),
  activityGapHours: (json['act_gap_hours'] as num?)?.toDouble(),
  biologicalReady: (json['bio_ready'] as num?)?.toDouble(),
  psychologicalLoad: (json['psych_load'] as num?)?.toDouble(),
  environmentScore: (json['env_score'] as num?)?.toDouble(),
  penalty: (json['penalty'] as num?)?.toDouble(),
  baseScore: (json['base_score'] as num?)?.toDouble(),
  mlScore: (json['ml_score'] as num?)?.toDouble(),
  finalScoreRaw: (json['final_score_raw'] as num?)?.toDouble(),
  finalScore: (json['final_score'] as num?)?.toInt(),
  userScore: (json['user_score'] as num?)?.toDouble(),
  userClass: json['user_class'] as String?,
  createdAt: json['created_at'] as String?,
);

Map<String, dynamic> _$$DerivedSleepDataImplToJson(
  _$DerivedSleepDataImpl instance,
) => <String, dynamic>{
  'derived_id': instance.id,
  'user_id': instance.userId,
  'raw_id': instance.rawId,
  'date': instance.date,
  'tib': instance.tib,
  'tst': instance.tst,
  'sleep_eff': instance.sleepEfficiency,
  'interrupt_index': instance.interruptIndex,
  'consistency_7d': instance.consistency7d,
  'caff_gap_hours': instance.caffeineGapHours,
  'caff_impact': instance.caffeineImpact,
  'screen_impact': instance.screenImpact,
  'act_gap_hours': instance.activityGapHours,
  'bio_ready': instance.biologicalReady,
  'psych_load': instance.psychologicalLoad,
  'env_score': instance.environmentScore,
  'penalty': instance.penalty,
  'base_score': instance.baseScore,
  'ml_score': instance.mlScore,
  'final_score_raw': instance.finalScoreRaw,
  'final_score': instance.finalScore,
  'user_score': instance.userScore,
  'user_class': instance.userClass,
  'created_at': instance.createdAt,
};
