// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ActivitiesReceivedCardModel.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ActivitiesReceivedCardModel _$ActivitiesReceivedCardModelFromJson(
        Map<String, dynamic> json) =>
    ActivitiesReceivedCardModel()
      ..activityReceived_Id = json['activityReceived_Id'] as int
      ..familyCard_Id = json['familyCard_Id'] as int
      ..createdDate = json['createdDate'] == null
          ? null
          : DateTime.parse(json['createdDate'] as String);

Map<String, dynamic> _$ActivitiesReceivedCardModelToJson(
        ActivitiesReceivedCardModel instance) =>
    <String, dynamic>{
      'activityReceived_Id': instance.activityReceived_Id,
      'familyCard_Id': instance.familyCard_Id,
      'createdDate': instance.createdDate?.toIso8601String(),
    };
