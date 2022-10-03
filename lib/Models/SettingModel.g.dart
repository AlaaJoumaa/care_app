// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'SettingModel.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SettingModel _$SettingModelFromJson(Map<String, dynamic> json) => SettingModel()
  ..id = json['id'] as int?
  ..key = json['key'] as String
  ..value = json['value'] as String;

Map<String, dynamic> _$SettingModelToJson(SettingModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'key': instance.key,
      'value': instance.value,
    };
