import 'package:json_annotation/json_annotation.dart';
part 'OptionModel.g.dart';

@JsonSerializable()
class OptionModel {
  int id = 0;
  int listid = 0;
  String? option;
  String? optionar;

  OptionModel() {  }

  factory OptionModel.fromJson(Map<String, dynamic> data) =>
      _$OptionModelFromJson(data);

  Map<String, dynamic> toJson() => _$OptionModelToJson(this);

  // OptionModel _$OptionModelFromJson(Map<String, dynamic> json) => OptionModel()
  //   ..id = json['id'] as int
  //   ..listid = json['listid'] as int
  //   ..option = json['option'] as String?
  //   ..optionar = json['optionar'] as String?;
  //
  // Map<String, dynamic> _$OptionModelToJson(OptionModel instance) =>
  //     <String, dynamic>{
  //       'id': instance.id,
  //       'listid': instance.listid,
  //       'option': instance.option,
  //       'optionar': instance.optionar,
  //     };
}