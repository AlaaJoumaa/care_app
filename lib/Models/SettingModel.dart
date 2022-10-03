import 'package:json_annotation/json_annotation.dart';
part 'SettingModel.g.dart';

@JsonSerializable()
class SettingModel {
  int? id = 0;
  String key= '';
  String value = '';

  SettingModel() { }

  factory SettingModel.fromJson(Map<String, dynamic> data) =>
      _$SettingModelFromJson(data);

  Map<String, dynamic> toJson() => _$SettingModelToJson(this);

  // SettingModel _$SettingModelFromJson(Map<String, dynamic> json) => SettingModel()
  //   ..id = json['id'] as int?
  //   ..key = json['key'] as String
  //   ..value = json['value'] as String;
  //
  // Map<String, dynamic> _$SettingModelToJson(SettingModel instance) =>
  //     <String, dynamic>{
  //       'id': instance.id,
  //       'key': instance.key,
  //       'value': instance.value,
  //     };
}