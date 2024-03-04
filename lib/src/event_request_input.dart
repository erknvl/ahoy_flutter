import 'package:ahoy_flutter/ahoy.dart';
import 'package:ahoy_flutter/src/event.dart';
import 'package:ahoy_flutter/src/user_id_decorated.dart';
import 'package:json_annotation/json_annotation.dart';

part 'event_request_input.g.dart';

@JsonSerializable(
  fieldRename: FieldRename.snake,
  includeIfNull: false,
  createFactory: true,
  createToJson: true,
)
class EventRequestInput {
  String visitorToken;
  String visitToken;
  @JsonKey(
    fromJson: fromJsonEvents,
    toJson: toJsonEvents,
  )
  List<UserIdDecorated<Event>> events;

  EventRequestInput({
    required this.visitorToken,
    required this.visitToken,
    required this.events,
  });

  factory EventRequestInput.fromJson(Map<String, dynamic> json) {
    return _$EventRequestInputFromJson(json);
  }

  Map<String, dynamic> toJson() => _$EventRequestInputToJson(this);
}

List<UserIdDecorated<Event>> fromJsonEvents(Map<String, dynamic> json) {
  return (json['events'] as List)
      .map((e) => UserIdDecorated<Event>.fromJson(e, Event.fromJson))
      .toList();
}

List<Map<String, dynamic>> toJsonEvents(List<UserIdDecorated<Event>> events) {
  return events.map((e) => e.toJson(e.wrapped.toJson())).toList();
}
