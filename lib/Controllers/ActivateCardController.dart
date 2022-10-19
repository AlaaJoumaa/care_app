import 'package:care_app/Enums/FamilyCardStatuses.dart';
import 'package:care_app/Enums/Permissions.dart';
import 'package:care_app/Models/FamilyCardModel.dart';
import 'package:care_app/Providers/FamilyCardProvider.dart';
import 'package:care_app/Providers/NFCProvider.dart';
import 'package:care_app/Providers/UserProvider.dart';
import 'package:care_app/Services/DatabaseHandler.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:sqflite/sqflite.dart';
import 'package:easy_localization/easy_localization.dart' as easylocal;

class ActivateCardController extends ControllerMVC {

  factory ActivateCardController([StateMVC? state]) => _this ??= ActivateCardController._(state);

  ActivateCardController._(StateMVC? state) :
        _nfcProvider = new NFCProvider(),
        _familyCardProvider = new FamilyCardProvider(),
        result = '',
        resultColor = Colors.red,
        super(state);

  static ActivateCardController? _this;
  FamilyCardProvider _familyCardProvider;
  NFCProvider _nfcProvider;
  String result = '';
  Color resultColor = Colors.red;
  int SN = 0;
  List<int> range = [];
  int index = 0;
  bool exeeded = false;
  String SN_Lst = '';

  void setNewSN() {
    try {
      if(index < range.length && index >= 0) {
        setState(() { SN = range[index]; exeeded = false; });
      }
      else {
        //Max range exceeded.
        setState(() {
          result = 'max_range_exceeded'.tr();
          resultColor = Colors.red;
          exeeded = true;
        });
      }
    }
    catch (ex) {
      setState(() {
        result = ex.toString();
        resultColor = Colors.red;
      });
    }
  }

  Future<bool> _active(cardIdentifier) async {
    var hasActivated = false;
    try{
      final Database db = await DatabaseHandler.initializeDB();
      var familyCard = new FamilyCardModel();
      familyCard.id = SN;
      familyCard.familyKey = null;
      familyCard.hexId = cardIdentifier;
      familyCard.status = FamilyCardStatuses.New.index;
      familyCard.addBy = UserProvider.currentUser!.id;
      familyCard.createdDate = DateTime.now();
      familyCard.sn = SN;
      //Activate the card.
      var rowsAffected = await _familyCardProvider.addFamilyCardLocally(familyCard,Permissions.CardReader.index,db);
      if(rowsAffected > 0) { hasActivated = true; }
      else { hasActivated = false; }
      await db.close();
    }
    catch(ex) {
      setState(() { result = 'An_Error'.tr() + ': $ex'; resultColor = Colors.red; });
    }
    return hasActivated;
  }

  void stopNFC() async {
    _nfcProvider.StopNFC();
  }

  void readNFCData() async {
    //final readCardState = stateOf<ReadCardView>();
    _nfcProvider.ReadData((String message, int code) async {
      try {
        switch (code) {
          case 1:
            final Database db = await DatabaseHandler.initializeDB();
            //1- Search the family card by hexId.
            var existedModels = await _familyCardProvider.getFamilyCardModelsByHexId(message, db);
            if(existedModels.length > 0) {
              setState(() {
                result = 'card_already_exists'.tr();
                resultColor = Colors.red;
              });
            }
            else if(!exeeded) {
              //Activate the card.
              var hasActivated = await _active(message);
              if(hasActivated) {
                setState(() { result = 'Card_Added_Successfully'.tr(); resultColor = Colors.green;index++; });
                SN_Lst = (SN.toString() + '\n' + SN_Lst);
                setNewSN();
              }
              else {
                setState(() {
                  result = "Can't_Activate_New_Card_Msg".tr();
                  resultColor = Colors.red;
                });
              }
            }
            else{
              setState(() {
                result = 'max_range_exceeded'.tr();
                resultColor = Colors.red;
                exeeded = true;
              });
            }
            db.close();
            break;
          case -4:
            setState(() { result = 'Not_Supported_Card_Msg'.tr(); resultColor = Colors.red; });
            break;
          default:
            setState(() { result = 'An_Error'.tr(); resultColor = Colors.red; });
        }
        readNFCData();
      }
      catch(ex) {
        setState(() { result = 'An_Error'.tr() + ': $ex, '+ 'Enter_Page_Again'.tr(); resultColor = Colors.red; });
      }
    });
  }

  void initLastSN() async {
    try {
      final Database db = await DatabaseHandler.initializeDB();
      var lastSN = await _familyCardProvider.getLastSNLocally(
          UserProvider.currentUser!.id, UserProvider.currentRole!, db);
      var finished = false;
      if (lastSN == 0) {
        SN = UserProvider.currentRange!.min;
      }
      else {
        finished =(lastSN + 1) > UserProvider.currentRange!.max ? true : false;
        SN = lastSN + 1;
      }
      if(!finished) {
        //1- Add all SN's.
        for (int i = SN; i <= UserProvider.currentRange!.max; i++) {
          range.add(i);
        }
        //2- Remove the missings.
        for (int i = 0; i < UserProvider.currentRange!.missing.length; i++) {
          var elements = range.where((element) =>
          element == UserProvider.currentRange!.missing[i])
              .toList();
          if (elements.length > 0) {
            range.remove(elements.first);
          }
        }
      }
      setNewSN();
    }
    catch (ex) {
      setState(() { result = 'An_Error'.tr() + ': $ex'; resultColor = Colors.red; });
    }
  }

  void skipSN() async {
    try {
      if(!exeeded) {
        setState(() {  SN_Lst = (range[index].toString() + ' Skipped' + '\n' + SN_Lst); });
        setState(() { index++; });
        setNewSN();
      }
    }
    catch(ex) { setState(() { result = 'An_Error'.tr() + ': $ex'; resultColor = Colors.red; }); }
  }

  void undoSN() async {
    try {
      if(index > 0) {
        final Database db = await DatabaseHandler.initializeDB();
        var rowsAffected = await _familyCardProvider.removeFamilyCardLocally(UserProvider.currentUser!.id,range[index-1],db);
        if(rowsAffected > 0) {
          setState(() { index--; });
          setNewSN();
          setState(() {  SN_Lst = (range[index].toString() + ' Removed' + '\n' + SN_Lst); });
        }
        await db.close();
      }
    }
    catch(ex) { setState(() { result = 'An_Error'.tr() + ': $ex'; resultColor = Colors.red; }); }
  }
}