import 'package:json_annotation/json_annotation.dart';

part 'visit_request_input.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, includeIfNull: false)
class VisitRequestInput {
  String visitorToken;
  String visitToken;
  String platform;
  String appVersion;
  String osVersion;
  Map<String, dynamic>? additionalParams;

  VisitRequestInput({
    required this.visitorToken,
    required this.visitToken,
    required this.platform,
    required this.appVersion,
    required this.osVersion,
    this.additionalParams,
  });

  factory VisitRequestInput.fromJson(Map<String, dynamic> json) =>
      _$VisitRequestInputFromJson(json);

  Map<String, dynamic> toJson() => _$VisitRequestInputToJson(this);
}
