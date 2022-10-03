import 'package:care_app/Models/ActivitiesReceivedModel.dart';
import 'package:care_app/Models/FamilyCardModel.dart';
import 'package:care_app/Providers/DistributionProvider.dart';
import 'package:care_app/Providers/FamilyCardProvider.dart';
import 'package:care_app/Providers/NFCProvider.dart';
import 'package:care_app/Providers/UserProvider.dart';
import 'package:care_app/Services/DatabaseHandler.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:sqflite/sqflite.dart';
import 'package:easy_localization/easy_localization.dart' as easylocal;

class NewCardController extends ControllerMVC {

   factory NewCardController([StateMVC? state]) => _this ??= NewCardController._(state);

   NewCardController._(StateMVC? state) :
         _distributionProvider = new DistributionProvider(),
         _nfcProvider = new NFCProvider(),
         selectedModel = new ActivitiesReceivedModel(),
         _familyCardProvider = new FamilyCardProvider(),
         commentController = new TextEditingController(),
         familyCard = new FamilyCardModel(),
         cardIdentifier = '',
         super(state);

   static NewCardController? _this;
   DistributionProvider _distributionProvider;
   FamilyCardProvider _familyCardProvider;
   NFCProvider _nfcProvider;
   ActivitiesReceivedModel selectedModel;
   FamilyCardModel familyCard;
   String cardIdentifier = '';
   TextEditingController commentController;

   // void readData(int code,String message,showAlert(title,msg, AlertType type)) async {
   //   try {
   //     final Database db = await DatabaseHandler.initializeDB();
   //
   //   }
   //   catch(ex) {
   //     showAlert('Error'.tr(),'An_Error'.tr() + ": $ex, Please re-enter this page again.",AlertType.error);
   //   }
   // }

   void approve(showAlert(title,msg, AlertType type)) async {
       try{
         final Database db = await DatabaseHandler.initializeDB();
         var familyCard = new FamilyCardModel();
         familyCard.familyKey = selectedModel.key;
         familyCard.hexId = cardIdentifier;
         //Approve the card.
         await _distributionProvider.approve(familyCard, commentController.value.text,
                                         UserProvider.currentUser!.id,
                                         (int code) async
                                         {
                                             switch(code) {
                                               case 1:
                                                 setState(() {
                                                    cardIdentifier = '';
                                                    selectedModel = new ActivitiesReceivedModel();
                                                    familyCard = new FamilyCardModel();
                                                 });
                                                  showAlert('Success'.tr(),'Card_Approved_Successfully'.tr(),AlertType.success);
                                               break;
                                               case -1:
                                                  showAlert('Error'.tr(),"Can't_Approve_The_Card_Msg".tr(),AlertType.error);
                                               break;
                                               case -5:
                                                 showAlert('Error'.tr(),"No_Activities_Receive".tr(),AlertType.error);
                                               break;
                                             }
                                             await db.close();
                                         }, db);
         readNFCData(showAlert);
       }
       catch(ex) {
         showAlert('Error'.tr(),'An_Error'.tr() + ': $ex',AlertType.error);
       }
   }

   void stopNFC() async {
      _nfcProvider.StopNFC();
   }

   void readNFCData(showAlert(title,msg, AlertType type)) async {
     //final readCardState = stateOf<ReadCardView>();
     _nfcProvider.ReadData((String message, int code) async {
       try {
         switch (code) {
           case 1:
             final Database db = await DatabaseHandler.initializeDB();
             //1- Search the family card by hexId.
             var existedModels = await _familyCardProvider.getFamilyCardModelsByHexId(message, db);
             if(existedModels.length > 0) {
               var familyCardModel = existedModels.first;
               var activityReceived = await _distributionProvider.getActivityReceived(familyCardModel.familyKey!,
                                                                                      UserProvider.currentUser!.id,
                                                                                      UserProvider.currentRole!,
                                                                                      db);
               if(activityReceived != null) {
                 commentController.clear();
                 setState(() { selectedModel = activityReceived; familyCard = familyCardModel; });
                 switch (code) {
                   case 1:
                     setState(() { cardIdentifier = message; });
                     break;
                   case -4:
                     showAlert('Error'.tr(), 'Not_Supported_Card_Msg'.tr(), AlertType.error);
                     break;
                   default:
                     showAlert('Error'.tr(), 'An_Error'.tr() + ': $message', AlertType.error);
                 }
                 //await db.close();
               }
               else {
                 var ar = await _distributionProvider.getActivityByFamilyKey(familyCardModel.familyKey!,
                                                                             UserProvider.currentUser!.id,
                                                                             UserProvider.currentRole!,
                                                                             db);
                 if(ar != null && !ar!.mealChecked!.isEmpty) {
                   //Activity has been received before.
                   showAlert('Error'.tr(),'F_C_received_voucher_amount'.tr(), AlertType.error);
                 }
                 else {
                   //No activity assigned to this family.
                   showAlert('Error'.tr(),'Card_not_in_distribution_list'.tr(), AlertType.error);
                 }
               }
             }
             else {
               //Card is not exists.
               showAlert('Error'.tr(),'Card_not_in_distribution_list'.tr(), AlertType.error);
             }
             await db.close();
             break;
           case -4:
             showAlert('Error'.tr(),'Not_Supported_Card_Msg'.tr(),AlertType.error);
             break;
           default:
             showAlert('Error'.tr(),'An_Error'.tr() + ': $message',AlertType.error);
         }
       }
       catch(ex) {
         showAlert('Error'.tr(),'An_Error'.tr() + ': $ex, '+ 'Enter_Page_Again'.tr(),AlertType.error);
       }
       readNFCData(showAlert);
     });
   }
}