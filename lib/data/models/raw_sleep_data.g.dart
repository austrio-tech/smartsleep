// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'raw_sleep_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RawSleepDataImpl _$$RawSleepDataImplFromJson(Map<String, dynamic> json) =>
    _$RawSleepDataImpl(
      recordDate: json['record_date'] as String?,
      sleepTime: json['sleep_time'] as String?,
      wakeTime: json['wake_time'] as String?,
      awakenings: (json['awakenings'] as num?)?.toInt(),
      sleepLatencyMinutes: (json['sleep_latency_minutes'] as num?)?.toInt(),
      naps: (json['naps'] as num?)?.toInt(),
      heartRateRest: (json['hr_rest'] as num?)?.toInt(),
      hrv: (json['hrv'] as num?)?.toInt(),
      bodyTemp: (json['body_temp'] as num?)?.toDouble(),
      respiratoryRate: (json['resp_rate'] as num?)?.toInt(),
      caffeineTime: json['caffeine_time'] as String?,
      caffeineMg: (json['caffeine_mg'] as num?)?.toInt(),
      alcoholUnits: (json['alcohol_units'] as num?)?.toInt(),
      waterLiters: (json['water_liters'] as num?)?.toDouble(),
      steps: (json['steps'] as num?)?.toInt(),
      activityIntensity: json['activity_intensity'] as String?,
      screenMinutesBeforeBed: (json['screen_minutes_before_bed'] as num?)
          ?.toInt(),
      stress: (json['stress'] as num?)?.toInt(),
      mood: (json['mood'] as num?)?.toInt(),
      roomTemp: (json['room_temp'] as num?)?.toDouble(),
      noiseDb: (json['noise_db'] as num?)?.toInt(),
      lightLux: (json['light_lux'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$RawSleepDataImplToJson(_$RawSleepDataImpl instance) =>
    <String, dynamic>{
      'record_date': instance.recordDate,
      'sleep_time': instance.sleepTime,
      'wake_time': instance.wakeTime,
      'awakenings': instance.awakenings,
      'sleep_latency_minutes': instance.sleepLatencyMinutes,
      'naps': instance.naps,
      'hr_rest': instance.heartRateRest,
      'hrv': instance.hrv,
      'body_temp': instance.bodyTemp,
      'resp_rate': instance.respiratoryRate,
      'caffeine_time': instance.caffeineTime,
      'caffeine_mg': instance.caffeineMg,
      'alcohol_units': instance.alcoholUnits,
      'water_liters': instance.waterLiters,
      'steps': instance.steps,
      'activity_intensity': instance.activityIntensity,
      'screen_minutes_before_bed': instance.screenMinutesBeforeBed,
      'stress': instance.stress,
      'mood': instance.mood,
      'room_temp': instance.roomTemp,
      'noise_db': instance.noiseDb,
      'light_lux': instance.lightLux,
    };
