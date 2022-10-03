// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'OptionModel.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OptionModel _$OptionModelFromJson(Map<String, dynamic> json) => OptionModel()
  ..id = json['id'] as int
  ..listid = json['listid'] as int
  ..option = json['option'] as String?
  ..optionar = json['optionar'] as String?;

Map<String, dynamic> _$OptionModelToJson(OptionModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'listid': instance.listid,
      'option': instance.option,
      'optionar': instance.optionar,
    };
