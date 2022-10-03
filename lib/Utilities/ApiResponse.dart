import 'package:json_annotation/json_annotation.dart';
part 'ApiResponse.g.dart';

@JsonSerializable()
class ApiResponse {
  int? code = 0;
  bool success=false;
  String? errorMessage = '';

  ApiResponse() { }

  factory ApiResponse.fromJson(Map<String, dynamic> data) =>
      _$ApiResponseFromJson(data);

  Map<String, dynamic> toJson() => _$ApiResponseToJson(this);
}