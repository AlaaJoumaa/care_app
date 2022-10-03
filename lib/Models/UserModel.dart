import 'package:json_annotation/json_annotation.dart';
part 'UserModel.g.dart';

@JsonSerializable()
class UserModel {

  int id = 0;
  int partner = 0;
  int position = 0;
  String? partner_info;
  String? status;
  String? lastSeen;
  String? location;
  String? phone;
  String? email;
  String? pass;
  String? permission;
  String? lastActivity;
  String? token;
  String? expiration;
  int version = 0;
  bool enable = false;
  bool gender = false;
  int sector = 0;
  int lastSN = 0;

  UserModel() {  }

  factory UserModel.fromJson(Map<String, dynamic> data) =>
      _$UserModelFromJson(data);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  // UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel()
  //   ..id = json['id'] as int
  //   ..partner = json['partner'] as int
  //   ..position = json['position'] as int
  //   ..partner_info = json['partner_info'] as String?
  //   ..status = json['status'] as String?
  //   ..lastSeen = json['lastSeen'] as String?
  //   ..location = json['location'] as String?
  //   ..phone = json['phone'] as String?
  //   ..email = json['email'] as String?
  //   ..pass = json['pass'] as String?
  //   ..permission = json['permission'] as String?
  //   ..lastActivity = json['lastActivity'] as String?
  //   ..token = json['token'] as String?
  //   ..expiration = json['expiration'] as String?
  //   ..version = json['version'] as int
  //   ..enable = json['enable'] as bool
  //   ..gender = json['gender'] as bool
  //   ..sector = json['sector'] as int
  //   ..lastSN = json['lastSN'] as int;
  //
  // Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
  //   'id': instance.id,
  //   'partner': instance.partner,
  //   'position': instance.position,
  //   'partner_info': instance.partner_info,
  //   'status': instance.status,
  //   'lastSeen': instance.lastSeen,
  //   'location': instance.location,
  //   'phone': instance.phone,
  //   'email': instance.email,
  //   'pass': instance.pass,
  //   'permission': instance.permission,
  //   'lastActivity': instance.lastActivity,
  //   'token': instance.token,
  //   'expiration': instance.expiration,
  //   'version': instance.version,
  //   'enable': instance.enable,
  //   'gender': instance.gender,
  //   'sector': instance.sector,
  //   'lastSN': instance.lastSN
  // };
}