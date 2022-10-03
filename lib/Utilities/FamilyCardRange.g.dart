// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'FamilyCardRange.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FamilyCardRange _$FamilyCardRangeFromJson(Map<String, dynamic> json) =>
    FamilyCardRange()
      ..min = json['min'] as int
      ..max = json['max'] as int
      ..missing = json['missing'] as List<dynamic>;

Map<String, dynamic> _$FamilyCardRangeToJson(FamilyCardRange instance) =>
    <String, dynamic>{
      'min': instance.min,
      'max': instance.max,
      'missing': instance.missing,
    };
