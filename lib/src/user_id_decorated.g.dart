// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_id_decorated.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserIdDecorated<T> _$UserIdDecoratedFromJson<T>(
  Map<String, dynamic> json,
  T Function(Object? json) fromJsonT,
) =>
    UserIdDecorated<T>(
      userId: json['user_id'] as String?,
      wrapped: fromJsonT(json['wrapped']),
    );

Map<String, dynamic> _$UserIdDecoratedToJson<T>(
  UserIdDecorated<T> instance,
  Object? Function(T value) toJsonT,
) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('user_id', instance.userId);
  val['wrapped'] = toJsonT(instance.wrapped);
  return val;
}
