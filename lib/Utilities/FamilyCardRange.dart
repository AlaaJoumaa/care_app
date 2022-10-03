import 'package:json_annotation/json_annotation.dart';
part 'FamilyCardRange.g.dart';

@JsonSerializable()
class FamilyCardRange {

  int min = 0;
  int max = 0;
  List missing = [];

  FamilyCardRange() { }

  factory FamilyCardRange.fromJson(Map<String, dynamic> data) =>
      _$FamilyCardRangeFromJson(data);

  Map<String, dynamic> toJson() => _$FamilyCardRangeToJson(this);
}