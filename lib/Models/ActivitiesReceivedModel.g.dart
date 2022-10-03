// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ActivitiesReceivedModel.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ActivitiesReceivedModel _$ActivitiesReceivedModelFromJson(
    Map<String, dynamic> json) =>
    ActivitiesReceivedModel()
      ..id = json['id'] as int
      ..activityId = json['activityId'] as int
      ..key = json['key'] as String?
      ..distibution_date = json['distibution_date'] as String?
      ..userid = json['userid'] as int?
      ..received = json['received'] as bool
      ..isSend = json['isSend'] as bool
      ..info1 = json['info1'] as String?
      ..info2 = json['info2'] as String?
      ..info3 = json['info3'] as String?
      ..comments = json['comments'] as String?
      ..payment_USD = json['payment_USD'] as int?
      ..card_Id = json['card_Id'] as int?
      ..datesend = json['datesend'] as String?
      ..mealUser = json['mealUser'] as int?
      ..mealChecked = json['mealChecked'] as String?
      ..mealCheckedSend = json['mealCheckedSend'] as String?
      ..signImage = json['signImage'] as String?;

Map<String, dynamic> _$ActivitiesReceivedModelToJson(
    ActivitiesReceivedModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'activityId': instance.activityId,
      'key': instance.key,
      'distibution_date': instance.distibution_date,
      'userid': instance.userid,
      'received': instance.received,
      'isSend': instance.isSend,
      'info1': instance.info1,
      'info2': instance.info2,
      'info3': instance.info3,
      'payment_USD': instance.payment_USD,
      'comments' : instance.comments,
      'card_Id': instance.card_Id,
      'datesend': instance.datesend,
      'mealUser': instance.mealUser,
      'mealChecked': instance.mealChecked,
      'mealCheckedSend': instance.mealCheckedSend,
      'signImage': instance.signImage,
    };

ActivitiesReceivedModel _$ActivitiesReceivedModelsqliteFromJson(
    Map<String, dynamic> json) =>
    ActivitiesReceivedModel()
      ..id = json['id'] as int
      ..activityId = json['activityId'] as int
      ..key = json['key'] as String?
      ..distibution_date = json['distibution_date'] as String?
      ..userid = json['userid'] as int?
      ..received = (json['received'] as int == 1 ? true: false)
      ..isSend = (json['isSend'] as int == 1 ? true : false)
      ..info1 = json['info1'] as String?
      ..info2 = json['info2'] as String?
      ..info3 = json['info3'] as String?
      ..comments = json['comments'] as String?
      ..payment_USD = json['payment_USD'] as int?
      ..card_Id = json['card_Id'] as int?
      ..datesend = json['datesend'] as String?
    //Data for meal validator.
      ..mealUser = json['mealUser'] as int?
      ..mealChecked = json['mealChecked'] as String?
      ..mealCheckedSend = json['mealCheckedSend'] as String?
      ..signImage = json['signImage'] as String?;