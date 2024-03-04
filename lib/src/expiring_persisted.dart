import 'dart:async';
import 'dart:convert';
import 'package:meta/meta_meta.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

part 'expiring_persisted.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, includeIfNull: false)
class DatedStorageContainer<T> {
  final DateTime storageDate;

  @JsonKey(fromJson: _fromJson, toJson: _toJson)
  final T value;

  DatedStorageContainer({required this.storageDate, required this.value});

  factory DatedStorageContainer.fromJson(Map<String, dynamic> json) =>
      _$DatedStorageContainerFromJson(json);

  Map<String, dynamic> toJson() => _$DatedStorageContainerToJson(this);

  static T _fromJson<T>(dynamic json) => json as T;
  static dynamic _toJson<T>(T object) => object;
}

class ExpiringPersisted<T> {
  final String key;
  final Duration? expiryPeriod;

  const ExpiringPersisted({
    required this.key,
    this.expiryPeriod,
  });

  Future<T> get value async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(key);
    if (data == null) {
      final container = DatedStorageContainer(
        storageDate: DateTime.now(),
        value: const Uuid().v4() as T,
      );
      prefs.setString(key, jsonEncode(container.toJson()));
      return container.value;
    }
    final container = DatedStorageContainer.fromJson(jsonDecode(data));
    if (expiryPeriod != null &&
        DateTime.now().isAfter(
          container.storageDate.add(expiryPeriod!),
        )) {
      final newContainer = DatedStorageContainer<T>(
        storageDate: DateTime.now(),
        value: const Uuid().v4() as T,
      );
      await prefs.setString(key, jsonEncode(newContainer.toJson()));
      return newContainer.value;
    }
    return container.value;
  }
}

class GenericJsonConverter<T> implements JsonConverter<T, dynamic> {
  const GenericJsonConverter();

  @override
  T fromJson(dynamic json) => json as T;

  @override
  dynamic toJson(T object) => object;
}
