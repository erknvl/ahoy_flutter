// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_request_input.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EventRequestInput _$EventRequestInputFromJson(Map<String, dynamic> json) =>
    EventRequestInput(
      visitorToken: json['visitor_token'] as String,
      visitToken: json['visit_token'] as String,
      events: fromJsonEvents(json['events'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$EventRequestInputToJson(EventRequestInput instance) =>
    <String, dynamic>{
      'visitor_token': instance.visitorToken,
      'visit_token': instance.visitToken,
      'events': toJsonEvents(instance.events),
    };
