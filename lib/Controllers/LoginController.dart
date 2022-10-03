import 'dart:convert';
import 'dart:io';
import 'package:care_app/Enums/Permissions.dart';
import 'package:care_app/Enums/SettingKeys.dart';
import 'package:care_app/Models/SettingModel.dart';
import 'package:care_app/Models/UserModel.dart';
import 'package:care_app/Providers/DistributionProvider.dart';
import 'package:care_app/Providers/SettingProvider.dart';
import 'package:care_app/Providers/UserProvider.dart';
import 'package:care_app/Services/DatabaseHandler.dart';
import 'package:care_app/Utilities/FamilyCardRange.dart';
import 'package:care_app/Views/LoginView.dart';
import 'package:care_app/main.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:email_validator/email_validator.dart';
import 'package:easy_localization/easy_localization.dart' as easylocal;
import '/Utilities/FamilyCardRange.dart';
//import 'package:device_info/device_info.dart';
import 'package:platform_device_id/platform_device_id.dart';
import 'package:clipboard/clipboard.dart';

class LoginController extends ControllerMVC {

  factory LoginController([StateMVC? state]) => _this ??= LoginController._(state);

  //Inherit the (_) function.
  LoginController._(StateMVC? state) :
        _userProvider = new UserProvider(),
        _distributionProvider = new DistributionProvider(),
        _settingProvider = new SettingProvider(),
        emailController = new TextEditingController(),
        passController = new TextEditingController(),
        super(state);

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  static LoginController? _this;
  UserProvider _userProvider;
  SettingProvider _settingProvider;
  DistributionProvider _distributionProvider;

  //For login info.
  TextEditingController emailController;
  TextEditingController passController;
  bool progress = false;

  Future<bool> setPermission(UserModel userModel) async {
    if (userModel.permission!.contains(
        describeEnum(Permissions.Distributioner.toString()))) {
      UserProvider.currentRole = Permissions.Distributioner.index;
    }
    else if (userModel.permission!.contains(
        describeEnum(Permissions.MealCheck.toString()))) {
      UserProvider.currentRole = Permissions.MealCheck.index;
    }
    else if(userModel.permission!.contains(describeEnum(Permissions.CardReader.toString()))) {
      UserProvider.currentRole = Permissions.CardReader.index;
    }
    else {
      return false;
    }
    return true;
  }

  Future<bool> setCardRange(UserModel userModel) async {
    if (UserProvider.currentRole == Permissions.CardReader.index) {
      if (UserProvider.currentUser!.location! != null) {
        var familyCardRange = jsonDecode(UserProvider.currentUser!.location!);
        UserProvider.currentRange = FamilyCardRange.fromJson(familyCardRange);
      }
      else {
        return false;
      }
    }
    return true;
  }

  Future<bool> checkDevice(UserModel userModel) async {
    //User device checked.
    String? identifier = await PlatformDeviceId.getDeviceId;
    if(userModel.phone != identifier) {
      return false;
    }
    return true;
  }

  //(1) Successfully access.
  //(0) Incorrect login info.
  //(-1) Not authorized access.
  //(-2) Data is not vaild.
  //(-3) Another user data included.
  //(-4) Card range didn't populated.
  //(-5) Incorrect device (SN).
  Future<int> login(void showLoginErrorAlert(msg)) async {
    try {
      if (!formKey.currentState!.validate()) {
        return -1;
      }
      setState(() { progress = true; });
      final loginState = stateOf<LoginView>();
      if (loginState != null) {
        var userModel = await _userProvider.login(emailController.value.text,
            passController.value.text);

        setState(() { progress = false; });
        if (userModel != null) {
          //- Check the device.
          if(!await checkDevice(userModel)) {
            showLoginErrorAlert('Incorrect_Login_Device'.tr());
            return -5;
          }
          //- Check the permission.
          if(!await setPermission(userModel)) {
            showLoginErrorAlert('Login_Not_Permitted'.tr());
            return -2;
          }
          //- Add user model to the settings.
          UserProvider.currentUser = userModel;
          //- Check the cards range has filled.
          if(!await setCardRange(userModel)) {
            showLoginErrorAlert("cards_range_didnt_filled".tr());
            return -4;
          }
          //- Store the user in setting table.
          var db = await DatabaseHandler.initializeDB();
          await _settingProvider.add(new SettingModel()
            ..id = null
            ..key = describeEnum(SettingKeys.UserInfo)
            ..value = jsonEncode(UserProvider.currentUser), db);
          //Check the activities received data - add the last user id setting if it's not exists.
          var lastUserSetting = await _settingProvider.read(SettingKeys.LastUserId, db);
          if (lastUserSetting == null) {
            await _settingProvider.add(new SettingModel()
              ..id = null
              ..key = describeEnum(SettingKeys.LastUserId)
              ..value = userModel.id.toString(), db);
          }
          else if (lastUserSetting != null &&
              lastUserSetting.value != userModel.id.toString()) {
            db.close();
            showLoginErrorAlert("another_user_data_msg".tr());
            return -3;
          }
          db.close();
          //- Redirect to the [ Home ] page.
          Navigator.pushReplacementNamed(loginState.context, '/Home');
          return 1;
        }
      }
    }
    catch(ex) { showLoginErrorAlert('An_Error'.tr() + ': $ex'); return -4; }
    showLoginErrorAlert('Incorrect_Login'.tr());
    return 0;
  }

  String? emailValidator(String? value) {
    if(!EmailValidator.validate(value!)) {
      return 'Enter_Valid_Email'.tr();
    }
  }

  String? passwordValidator(String? value) {
    if (value!.isEmpty || value!.length < 2) {
      return 'Enter_Valid_Pass'.tr();
    }
  }

  Future initDatabase() async {
    setState(() { progress = true; });
    final loginState = stateOf<LoginView>();
    var db = await DatabaseHandler.initializeDB();
    var settingModel = await _settingProvider.read(SettingKeys.UserInfo, db);
    if(settingModel != null) {
      //1- Set the user info in the user provider.
      UserProvider.currentUser = UserModel.fromJson(jsonDecode(settingModel.value) as Map<String,dynamic>);
      //2- Set the user role in the user provider.
      await setPermission(UserProvider.currentUser!);
      await setCardRange(UserProvider.currentUser!);
      //- Redirect to the [ Home ] page.
      Navigator.pushReplacementNamed(loginState!.context, '/Home');
    }
    db.close();
    setState(() { progress = false; });
  }

  void changeLanguage() {
    final loginState = stateOf<LoginView>();
    var local = new Locale('en','US');
    if(MyApp.currentLang == "en") {
      local = new Locale("ar","SA");
      MyApp.currentLang = "ar";
    }
    else {
      MyApp.currentLang = "en";
    }
    setState(() {  loginState!.context.locale = local;});
    //Phoenix.rebirth(context);
  }

  void copy() async {
    String? identifier = await PlatformDeviceId.getDeviceId;
    await FlutterClipboard.copy(identifier!);
  }

}