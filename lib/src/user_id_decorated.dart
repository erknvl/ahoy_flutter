import 'package:json_annotation/json_annotation.dart';

part 'user_id_decorated.g.dart';

@JsonSerializable(
  fieldRename: FieldRename.snake,
  includeIfNull: false,
  genericArgumentFactories: true,
)
class UserIdDecorated<T> {
  String? userId;
  T wrapped;

  UserIdDecorated({
    this.userId,
    required this.wrapped,
  });

  factory UserIdDecorated.fromJson(
    Map<String, dynamic> json,
    dynamic dataFromJson,
  ) {
    return _$UserIdDecoratedFromJson(json, dataFromJson);
  }

  Map<String, dynamic> toJson(Map<String, dynamic>? Function(T value) wrapped) {
    return _$UserIdDecoratedToJson(
      this,
      wrapped,
    );
  }
}
