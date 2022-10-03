import 'package:json_annotation/json_annotation.dart';
part 'ActivitiesReceivedCardModel.g.dart';

@JsonSerializable()
class ActivitiesReceivedCardModel {

  int activityReceived_Id = 0;
  int familyCard_Id = 0;
  DateTime? createdDate;

  ActivitiesReceivedCardModel() { }

  factory ActivitiesReceivedCardModel.fromJson(Map<String, dynamic> data) =>
      _$ActivitiesReceivedCardModelFromJson(data);

  Map<String, dynamic> toJson() => _$ActivitiesReceivedCardModelToJson(this);


  // ActivitiesReceivedCardModel _$ActivitiesReceivedCardModelFromJson(
  //     Map<String, dynamic> json) =>
  //     ActivitiesReceivedCardModel()
  //       ..activityReceived_Id = json['activityReceived_Id'] as int
  //       ..familyCard_Id = json['familyCard_Id'] as int
  //       ..createdDate = json['createdDate'] == null
  //           ? null
  //           : DateTime.parse(json['createdDate'] as String);
  //
  // Map<String, dynamic> _$ActivitiesReceivedCardModelToJson(
  //     ActivitiesReceivedCardModel instance) =>
  //     <String, dynamic>{
  //       'activityReceived_Id': instance.activityReceived_Id,
  //       'familyCard_Id': instance.familyCard_Id,
  //       'createdDate': instance.createdDate?.toIso8601String(),
  //     };
}