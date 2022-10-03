// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'FamilyCardModel.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FamilyCardModel _$FamilyCardModelFromJson(Map<String, dynamic> json) =>
    FamilyCardModel()
      ..id = json['id'] as int?
      ..hexId = json['hexId'] as String?
      ..familyKey = json['familyKey'] as String?
      ..status = json['status'] as int?
      ..createdDate = json['createdDate'] == null
          ? null
          : DateTime.parse(json['createdDate'] as String)
      ..addBy = json['addBy'] as int?
      ..notice = json['notice'] as String?
      ..sn = json['sn'] as int
      ..activityReceivedCards = (json['activityReceivedCards'] == null ? [] : json['activityReceivedCards'] as List<dynamic>?)
          ?.map((e) => ActivitiesReceivedCardModel.fromJson(e as Map<String, dynamic>))
          .toList();

Map<String, dynamic> _$FamilyCardModelToJson(FamilyCardModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'hexId': instance.hexId,
      'familyKey': instance.familyKey,
      'status': instance.status,
      'createdDate': instance.createdDate?.toIso8601String(),
      'addBy': instance.addBy,
      'notice': instance.notice,
      'sn':instance.sn
    };
