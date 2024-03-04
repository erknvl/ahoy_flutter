// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'visit.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Visit _$VisitFromJson(Map<String, dynamic> json) => Visit(
      visitorToken: json['visitor_token'] as String,
      visitToken: json['visit_token'] as String,
      userId: json['user_id'] as String?,
      additionalParams: json['additional_params'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$VisitToJson(Visit instance) {
  final val = <String, dynamic>{
    'visitor_token': instance.visitorToken,
    'visit_token': instance.visitToken,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('user_id', instance.userId);
  writeNotNull('additional_params', instance.additionalParams);
  return val;
}
