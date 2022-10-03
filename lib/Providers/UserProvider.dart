import 'dart:convert';
import 'dart:io';
import 'package:care_app/Models/UserModel.dart';
import 'package:care_app/Utilities/FamilyCardRange.dart';
import 'package:care_app/Utilities/Settings.dart';
import 'package:http/http.dart' as http;


class UserProvider {

   static UserModel? currentUser = null;
   static int? currentRole = null;
   static FamilyCardRange? currentRange = null;
   String _readUserUrl = '/api/Authenticate/login';

   Future<UserModel?> login(String userName, String password) async {
      UserModel? userModel = null;
      try {
        final headers = { HttpHeaders.contentTypeHeader: 'application/json' };
        final data = jsonEncode({ "UserName": userName, "Password": password});
        var url = Uri.http(Settings.apiDomain, _readUserUrl);
        http.Response response = await http.post(url, body: data, headers: headers);
        if (response.statusCode == 200) {
          var responseMap = jsonDecode(response.body) as Map<String, dynamic>;
          userModel = UserModel.fromJson(responseMap);
        }
      }
      catch(ex) { }
      return userModel;
  }

}