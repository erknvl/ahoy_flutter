// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expiring_persisted.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DatedStorageContainer<T> _$DatedStorageContainerFromJson<T>(
        Map<String, dynamic> json) =>
    DatedStorageContainer<T>(
      storageDate: DateTime.parse(json['storage_date'] as String),
      value: DatedStorageContainer._fromJson(json['value']),
    );

Map<String, dynamic> _$DatedStorageContainerToJson<T>(
    DatedStorageContainer<T> instance) {
  final val = <String, dynamic>{
    'storage_date': instance.storageDate.toIso8601String(),
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('value', DatedStorageContainer._toJson(instance.value));
  return val;
}
