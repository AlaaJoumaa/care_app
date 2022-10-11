import 'package:care_app/Models/OptionModel.dart';
import 'package:json_annotation/json_annotation.dart';
part 'DelegateOptionModel.g.dart';

@JsonSerializable()
class DelegateOptionModel extends OptionModel {

  String? delegatedName;
  String? delegatedId;

  DelegateOptionModel() { }

  factory DelegateOptionModel.fromJson(Map<String, dynamic> data) =>
  _$DelegateOptionModelFromJson(data);

  Map<String, dynamic> toJson() => _$DelegateOptionModelToJson(this);

}