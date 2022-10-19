import 'dart:io';
import 'package:care_app/Enums/Permissions.dart';
import 'package:care_app/Enums/SettingKeys.dart';
import 'package:care_app/Models/ActivitiesReceivedModel.dart';
import 'package:care_app/Models/DelegateOptionModel.dart';
import 'package:care_app/Models/FamilyCardModel.dart';
import 'package:care_app/Models/OptionModel.dart';
import 'package:care_app/Providers/DistributionProvider.dart';
import 'package:care_app/Providers/FamilyCardProvider.dart';
import 'package:care_app/Providers/UserProvider.dart';
import 'package:care_app/Services/DatabaseHandler.dart';
import 'package:care_app/Views/HomeView.dart';
import 'package:care_app/main.dart';
import 'package:flutter/widgets.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'package:tuple/tuple.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:easy_localization/easy_localization.dart' as easylocal;

class HomeController extends ControllerMVC {

  factory HomeController([StateMVC? state]) => _this ??= HomeController._(state);

  //Inherit the (_) function.
  HomeController._(StateMVC? state) :
        _distributionProvider = new DistributionProvider(),
        _familyCardProvider = new FamilyCardProvider(),
        super(state);

  static HomeController? _this;
  DistributionProvider _distributionProvider;
  FamilyCardProvider _familyCardProvider;
  String status_Msg = '';
  bool isDisabled = false;
  bool hasInternet = false;
  bool nfcTurnedOff = false;

  double vouchersCnt = 0;
  double receivedVoucherCnt = 0;
  double amountCnt = 0;

  Future<void> _removeUnReceivedActivitiesLocally(final Database db) async {
    try {
      setState(() { status_Msg += ('\n' + 'Remove_UnReceived_Activities_Locally'.tr()); });
      await _distributionProvider.removeUnReceivedActivitiesLocally(
          UserProvider.currentUser!.id, db);
    }
    catch(ex) { status_Msg += ('\n' + 'ERROR: $ex'); }
  }

  //********* Activities received ***********

  Future<List<ActivitiesReceivedModel>> _downloadReceivedModels() async {
    //final homeState = stateOf<HomeView>();
    try {
      setState(() {
        status_Msg += ('\n' + 'Sync_Downloading_Activities'.tr());
      });
      Tuple2<List<ActivitiesReceivedModel>,
          int> result = await _distributionProvider
          .activitiesReceived(UserProvider.currentUser!.id,
                              UserProvider.currentUser!.token!);
      if (result.item2 == 401) { //Unauthorized access.
        setState(() {
          status_Msg += ('\n' + 'Unauthorized_Access'.tr());
        });
      }
      return result.item1;
    }
    catch(ex) { status_Msg += ('\n' + 'ERROR: $ex'); }
    return [];
  }

  Future<int> _saveLocalReceivedModels(List<ActivitiesReceivedModel> models,final Database db) async {

    var savedCount = 0;
    try {
      setState(() {
        status_Msg += ('\n' + 'Save_Activities_Locally'.tr());
      });
      var statusMessage = (status_Msg + '\n');
      var existedModels = await _distributionProvider
          .getActivitiesReceivedModelsByIds(models.map((e) => e.id).join(","),
                                            UserProvider.currentRole!,
                                            UserProvider.currentUser!.id, db);
      for (var i = 0; i < models.length; i++) {
        try {
          var rowsAffected = await _distributionProvider
              .saveReceivedModelLocally(
              existedModels, models[i],UserProvider.currentRole!, db);
          if (rowsAffected > 0) {
            savedCount++;
            setState(() {
              status_Msg = (statusMessage +
                  savedCount.toString() +
                  ' ' + 'Of'.tr() +
                  ' ' + models.length.toString() +
                  ' ' + "Activities_Saved_Successfully".tr());
            });
          }
        }
        catch(ex) {  }
      }
      setState(() {
        status_Msg += ('\n' + '$savedCount ' + 'Models_Saved'.tr());
      });
    }
    catch(ex) { status_Msg += ('\n' + 'ERROR: $ex'); }
    return savedCount;
  }

  Future<List<ActivitiesReceivedModel>> _getLocalReceivedModels(final Database db,int from, int to) async {
    List<ActivitiesReceivedModel> activities = [];
    try {
      activities = await _distributionProvider.getReceivedModelsLocally(
          UserProvider.currentUser!.id,UserProvider.currentRole!,from,to, db);
    }
    catch(ex) { status_Msg += ('\n' + 'ERROR: $ex'); }
    return activities;
  }

  Future<int> _getCountModelsLocally(final Database db) async {
    int receivedCount = 0;
    try {
      receivedCount = await _distributionProvider.getCountModelsLocally(
          UserProvider.currentUser!.id,UserProvider.currentRole!, db);
    }
    catch(ex) { status_Msg += ('\n' + 'ERROR: $ex'); }
    return receivedCount;
  }

  Future<bool> _uploadReceivedModels(List<ActivitiesReceivedModel> activitiesReceivedModels) async {
    try {
      var isMeal = true;
      if(UserProvider.currentRole == Permissions.Distributioner.index) { isMeal = false; }
      else if(UserProvider.currentRole == Permissions.MealCheck.index) { isMeal = true; }
      var gottenModels = activitiesReceivedModels.map((e) => DelegateOptionModel()
                                                                ..id = e.id
                                                                ..option =
                                                                DateFormat('yyyy-MM-dd HH:mm:ss')
                                                                    .format(isMeal ? DateTime.parse(e.mealChecked!) : DateTime.parse(e.distibution_date!))
                                                                ..optionar = isMeal ? e.comments : e.signImage
                                                                ..delegatedId = e.delegatedId
                                                                ..delegatedName = e.delegatedName)
                                                 .toList();
      var result = await _distributionProvider.putReceivedModels(gottenModels,UserProvider.currentRole!, UserProvider.currentUser!.token!);
      if (result.item2 == 401) { //Unauthorized access.
        setState(() { status_Msg += ('\n' + "Unauthorized_Access".tr()); });
      }
      return result.item1.success;
    }
    catch(ex) { status_Msg += ('\n' + 'ERROR: $ex'); }
    return false;
  }

  Future<int> _sendActivitiesReceivedLocally(List<ActivitiesReceivedModel> models,final Database db) async {
    var savedCount = 0;
    try {
      //setState(() { status_Msg += ('\n' + 'Updating_Activities_Locally'.tr()); });
      //var statusMessage = (status_Msg + '\n');
      for (var i = 0; i < models.length; i++) {
        var rowsAffected = await _distributionProvider
            .sendActivitiesReceivedLocally(
            models[i], UserProvider.currentRole!, db);
        if (rowsAffected > 0) {
          savedCount++;
        }
      }
    }
    catch (ex) {
      status_Msg += ('\n' + 'ERROR: $ex');
    }
    return savedCount;
  }

  //********* Family cards ***********

  Future<List<FamilyCardModel>> _downloadFamilyCardModels() async {
    try {
      setState(() {
        status_Msg += ('\n' + 'Sync_Downloading_F_C'.tr());
      });
      var result = await _familyCardProvider.familyCards(
          UserProvider.currentUser!.id,
          UserProvider.currentUser!.token!);
      if (result.item2 == 401) { //Unauthorized access.
        setState(() {
          status_Msg +=
          ('\n' + "Unauthorized_Access".tr());
        });
      }
      return result.item1;
    }
    catch(ex) { status_Msg += ('\n' + 'ERROR: $ex'); }
    return [];
  }

  Future _saveFamilyCardModels(List<FamilyCardModel> models,final Database db) async {
    try {
      setState(() {
        status_Msg += ('\n' + "Save_F_C_Locally".tr());
      });
      var savedCount = 0;
      var statusMessage = status_Msg + '\n';
      var existsModels = await _familyCardProvider.getFamilyCardModelsByIds(
          models.map((e) => e.id).join(","),
          db);
      for (var i = 0; i < models.length; i++) {
        await _familyCardProvider
            .saveFamilyCardModelsLocally(
            existsModels, models[i], (int rowsAffected) {
          if (rowsAffected > 0) {
            savedCount++;
            setState(() {
              status_Msg = (statusMessage +
                  savedCount.toString() +
                  ' ' + 'Of'.tr() +
                  ' ' + models.length.toString() +
                  ' ' + "F_C_Saved".tr());
            });
          }
        }, db);
      }
      setState(() {
        status_Msg += ('\n' + '$savedCount ' + 'Models_Saved'.tr());
      });
    }
    catch(ex) { status_Msg += ('\n' + 'ERROR: $ex'); }
  }

  Future<List<FamilyCardModel>> _getLocalFamilyCardModels(final Database db) async {
    List<FamilyCardModel> result = [];
    try {
      result = await _familyCardProvider.getFamilyCardModelsLocally(
          UserProvider.currentUser!.id,
          UserProvider.currentRole!, db);
    }
    catch(ex) { status_Msg += ('\n' + 'ERROR: $ex'); }
    return result;
  }

  Future _uploadFamilyCardModels(List<FamilyCardModel> familyCardModels) async {
    try {
      setState(() {
        status_Msg += ('\n' + 'Uploading_F_C'.tr());
      });
      var result = await _familyCardProvider.postFamilyCardModels(
          familyCardModels,
          UserProvider.currentRole!,
          UserProvider.currentUser!.token!);
      if (result.item2 == 401) { //Unauthorized access.
        setState(() {
          status_Msg +=
          ('\n' + 'Unauthorized_Access'.tr());
        });
      }
      setState(() {
        status_Msg += ('\n' + (result.item1.success ?
        (familyCardModels.length.toString() + ' ' + 'F_C_Uploaded'.tr()) :
        ("Cards_Checked".tr() + ': ' + result.item1.errorMessage!)));
      });
    }
    catch(ex) { status_Msg += ('\n' + 'ERROR: $ex'); }
  }

  Future _activateFamilyCardLocally(List<FamilyCardModel> models,final Database db) async {
    try {
      setState(() {
        status_Msg += ('\n' + 'Update_F_C_Locally'.tr());
      });
      var savedCount = 0;
      var statusMessage = (status_Msg + '\n');
      for (var i = 0; i < models.length; i++) {
        var rowsAffected = await _familyCardProvider.activateFamilyCardLocally(
            models[i],
            UserProvider.currentRole!, db);
        if (rowsAffected > 0) {
          savedCount++;
          setState(() {
            status_Msg = (statusMessage +
                savedCount.toString() +
                ' ' + 'Of'.tr() +
                ' ' + models.length.toString() +
                ' ' + "F_C_Updated".tr());
          });
        }
      }
      setState(() {
        status_Msg += ('\n' + '$savedCount ' + 'Models_Updated'.tr());
      });
    }
    catch(ex) { status_Msg += ('\n' + 'ERROR: $ex'); }
  }

  //********* Activities received cards ***********

  void onSyncPressed() async {
    try {
      final Database db = await DatabaseHandler.initializeDB();
      setState(() { status_Msg = ''; isDisabled = true; });
      //*********** Upload section ***********/

      //********* Note: No need to upload cards when the user is not a card reader *********
      if(UserProvider.currentRole == Permissions.CardReader.index) {
        //1- Get the local models for uploading.
        var familyCardModels = await _getLocalFamilyCardModels(db);
        //2- Uploading the local models.
        await _uploadFamilyCardModels(familyCardModels);
        //3- Uploading (status=Active) the family cards models.
        await _activateFamilyCardLocally(familyCardModels, db);
      }

      var pageSize = 1;
      var receivedCount = await _getCountModelsLocally(db);
      setState(() { status_Msg += ('\n' + 'Uploading_Activities'.tr()); });
      var statusMessage = ('\n' + status_Msg + '\n');
      var savedCount = 0;
      for (var i = 0; i < receivedCount; i += pageSize) { //Uploading (page size) of records.
        //4- Get the local models has been done received.
        var activitiesReceivedModels = await _getLocalReceivedModels(
            db, 0, pageSize);
        if (activitiesReceivedModels.length == 0) { break; }
        //5- Uploading (datesend=now()) the received models.
        var hasUploaded = await _uploadReceivedModels(
            activitiesReceivedModels);
        if (hasUploaded) {
          //6- Send activities received data.
          var sentCount = await _sendActivitiesReceivedLocally(
              activitiesReceivedModels, db);
          if (sentCount > 0) {
            savedCount += pageSize;
            setState(() {
              status_Msg = (statusMessage + savedCount.toString() +
                  ' ' + 'Of'.tr() + ' ' + receivedCount.toString() +
                  ' ' + 'Activities_Have_Recevied'.tr());
            });
          }
        }
      }

      //*********** Remove section ***********

      await _removeUnReceivedActivitiesLocally(db);

      //*********** Download section *********

      if(UserProvider.currentRole != Permissions.CardReader.index) { //Distributioner - MealCheck.
        //1- Downloading the activities received models.
        var downloadedReceivedModels = await _downloadReceivedModels();
        //2- Save the new models.
        await _saveLocalReceivedModels(downloadedReceivedModels, db);
      }
      //3- Downloading the family cards.
      var downloadedFamilyCardModels = await _downloadFamilyCardModels();
      //4- Save the new models.
      await _saveFamilyCardModels(downloadedFamilyCardModels, db);

      //***************************************

      //********* Activities received ***********
      // if(UserProvider.currentRole != Permissions.CardReader.index) { //Distributioner - MealCheck.
        //1- Downloading the activities received models.
        // var downloadedReceivedModels = await _downloadReceivedModels();
        // //********************** DELETE PROCESS **********************//
        // await _distributionProvider.removeUnReceivedActivitiesLocally(UserProvider.currentUser!.id,db);
        // //*************************************************************
        //2- Save the new models.
        // var pageSize = 1;
        // await _saveLocalReceivedModels(downloadedReceivedModels, db);
        //3- Get received models locally count.
        // var receivedCount = await _getCountModelsLocally(db);
        // setState(() {
        //   status_Msg += ('\n' + 'Uploading_Activities'.tr());
        // });
        // var statusMessage = ('\n' + status_Msg + '\n');
        // var savedCount = 0;
        // for (var i = 0; i < receivedCount; i += pageSize) { //Uploading (page size) of records.
        //   //4- Get the local models has been done received.
        //   var activitiesReceivedModels = await _getLocalReceivedModels(
        //       db, 0, pageSize);
        //   if (activitiesReceivedModels.length == 0) {
        //     break;
        //   }
        //   //5- Uploading (datesend=now()) the received models.
        //   var hasUploaded = await _uploadReceivedModels(
        //       activitiesReceivedModels);
        //   if (hasUploaded) {
        //     //6- Send activities received data.
        //     var sentCount = await _sendActivitiesReceivedLocally(
        //         activitiesReceivedModels, db);
        //     if (sentCount > 0) {
        //       savedCount += pageSize;
        //       setState(() {
        //         status_Msg = (statusMessage + savedCount.toString() +
        //             ' ' + 'Of'.tr() + ' ' + receivedCount.toString() +
        //             ' ' + 'Activities_Have_Recevied'.tr());
        //       });
        //     }
        //   }
        // }
      // }
      //********* Family cards & Activities received cards ***********
      // //1- Downloading the family cards.
      //var downloadedFamilyCardModels = await _downloadFamilyCardModels();
      //2- Save the new models.
      //await _saveFamilyCardModels(downloadedFamilyCardModels, db);
      // //********* Note: no need to just upload cards when the user is not a card reader *********
      // if(UserProvider.currentRole == Permissions.CardReader.index) {
      //   //3- Get the local models for uploading.
      //   var familyCardModels = await _getLocalFamilyCardModels(db);
      //   //4- Uploading the local models.
      //   await _uploadFamilyCardModels(familyCardModels);
      //   //5- Uploading (status=Active) the family cards models.
      //   await _activateFamilyCardLocally(familyCardModels, db);
      // }
      setState(() { isDisabled = false; });
      db.close();
      setState(() { status_Msg += '\n' + 'Sync_Done'.tr(); });
      await initStatistics();
    }
    catch(ex) {
      setState(() { status_Msg += "An_Error".tr() + ': $ex'; isDisabled = false; });
    }
  }

  void logout() async {
    try {
      final homeState = stateOf<HomeView>();
      final Database db = await DatabaseHandler.initializeDB();
      //Delete the setting row related to UserInfo key.
      var rowsAffected = await db.delete(
          "settings", where: 'key = ?', whereArgs: [SettingKeys.UserInfo.name]);
      db.close();
      if (rowsAffected > 0) {
        Navigator.pushReplacementNamed(homeState!.context, '/');
      }
    }
    catch(ex) { }
  }

  Future<void> initStatistics() async {
    try {
      if(UserProvider.currentRole! == Permissions.Distributioner.index) {
        final Database db = await DatabaseHandler.initializeDB();
        var allLst = await _distributionProvider.getAllReceivedModelsLocally(
            UserProvider.currentUser!.id, UserProvider.currentRole!, db);
        double amount = 0;
        double received = 0;
        double vouchers = allLst.length.toDouble();
        allLst.forEach((e) {
          if(e.distibution_date != null &&
            (DateFormat('yyyy-MM-dd').parse(e.distibution_date!) ==
             DateFormat('yyyy-MM-dd').parse(DateFormat('yyyy-MM-dd').format(DateTime.now())))) {
            amount += (e.received == true ? e.payment_USD! : 0);
            received += (e.received == true ? 1 : 0);
          }
        });
        setState(() {
          amountCnt = amount;
          vouchersCnt = vouchers;
          receivedVoucherCnt = received;
        });
        db.close();
      }
    } catch (err) { }
  }

  Future<void> checkInternetConnection() async {
    try {
      final response = await InternetAddress.lookup('www.google.com');
      if (response.isNotEmpty) {
        setState(() { hasInternet = true; });
      }
    } on SocketException catch (err) {
      setState(() { hasInternet = false; });
    }
  }

  Future<void> checkNfc() async {
    try {
      setState(() async {
        nfcTurnedOff = !await NfcManager.instance.isAvailable();
      });
    }
    catch(ex) { }
  }

  void changeLanguage() {
    final homeState = stateOf<HomeView>();
    var local = new Locale('en','US');
    if(MyApp.currentLang == "en") {
      local = new Locale("ar","SA");
      MyApp.currentLang = "ar";
    }
    else {
      MyApp.currentLang = "en";
    }
    setState(() { homeState!.context.locale = local;});
    //Phoenix.rebirth(context);
  }

}