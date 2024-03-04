// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'visit_request_input.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VisitRequestInput _$VisitRequestInputFromJson(Map<String, dynamic> json) =>
    VisitRequestInput(
      visitorToken: json['visitor_token'] as String,
      visitToken: json['visit_token'] as String,
      platform: json['platform'] as String,
      appVersion: json['app_version'] as String,
      osVersion: json['os_version'] as String,
      additionalParams: json['additional_params'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$VisitRequestInputToJson(VisitRequestInput instance) {
  final val = <String, dynamic>{
    'visitor_token': instance.visitorToken,
    'visit_token': instance.visitToken,
    'platform': instance.platform,
    'app_version': instance.appVersion,
    'os_version': instance.osVersion,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('additional_params', instance.additionalParams);
  return val;
}
