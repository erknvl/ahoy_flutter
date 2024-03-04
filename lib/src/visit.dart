import 'package:json_annotation/json_annotation.dart';

part 'visit.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, includeIfNull: false)
class Visit {
  final String visitorToken;
  final String visitToken;
  final String? userId;
  Map<String, dynamic>? additionalParams;

  Visit({
    required this.visitorToken,
    required this.visitToken,
    this.userId,
    this.additionalParams,
  });

  factory Visit.fromJson(Map<String, dynamic> json) => _$VisitFromJson(json);

  Map<String, dynamic> toJson() => _$VisitToJson(this);

  Visit copyWith({
    String? visitorToken,
    String? visitToken,
    String? userId,
    Map<String, dynamic>? additionalParams,
  }) {
    return Visit(
      visitorToken: visitorToken ?? this.visitorToken,
      visitToken: visitToken ?? this.visitToken,
      userId: userId ?? this.userId,
      additionalParams: additionalParams ?? this.additionalParams,
    );
  }
}
