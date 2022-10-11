part of 'DelegateOptionModel.dart';

DelegateOptionModel _$DelegateOptionModelFromJson(
    Map<String, dynamic> json) =>
    DelegateOptionModel()
      ..id = json['id'] as int
      ..listid = json['listid'] as int
      ..option = json['option'] as String?
      ..optionar = json['optionar'] as String?
      ..delegatedName = json['delegatedName'] as String?
      ..delegatedId = json['delegatedId'] as String?;

Map<String, dynamic> _$DelegateOptionModelToJson(
    DelegateOptionModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'listid': instance.listid,
      'option': instance.option,
      'optionar': instance.optionar,
      'delegatedName': instance.delegatedName,
      'delegatedId': instance.delegatedId
    };