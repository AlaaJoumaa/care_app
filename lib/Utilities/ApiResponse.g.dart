// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ApiResponse.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApiResponse _$ApiResponseFromJson(Map<String, dynamic> json) => ApiResponse()
  ..code = json['code'] as int?
  ..success = json['success'] as bool
  ..errorMessage = json['errorMessage'] as String?;

Map<String, dynamic> _$ApiResponseToJson(ApiResponse instance) =>
    <String, dynamic>{
      'code': instance.code,
      'success': instance.success,
      'errorMessage': instance.errorMessage,
    };
