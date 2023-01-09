import 'package:care_app/Enums/Permissions.dart';
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

class ApproveCardController extends ControllerMVC {

   factory ApproveCardController([StateMVC? state]) => _this ??= ApproveCardController._(state);

   ApproveCardController._(StateMVC? state) :
         _distributionProvider = new DistributionProvider(),
         _nfcProvider = new NFCProvider(),
         selectedActivityModel = new ActivitiesReceivedModel(),
         _familyCardProvider = new FamilyCardProvider(),
         commentController = new TextEditingController(),
         selectFamilyCardModel = new FamilyCardModel(),
         suggestedActivityController = new TextEditingController(),
         cardIdentifier = '',
         super(state);

   static ApproveCardController? _this;
   DistributionProvider _distributionProvider;
   FamilyCardProvider _familyCardProvider;
   NFCProvider _nfcProvider;
   ActivitiesReceivedModel selectedActivityModel;
   FamilyCardModel selectFamilyCardModel;
   String cardIdentifier = '';
   TextEditingController commentController;

   List<ActivitiesReceivedModel> suggestedActivityModels = [];
   TextEditingController suggestedActivityController;
   bool _searchByName = false;

   void approve(showAlert(title,msg, AlertType type)) async {
       try{
         final Database db = await DatabaseHandler.initializeDB();
         var familyCard = new FamilyCardModel();
         familyCard.familyKey = selectedActivityModel.key;
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
                                                    selectedActivityModel = new ActivitiesReceivedModel();
                                                    familyCard = new FamilyCardModel();
                                                 });
                                                 initReceivedActivitiesModels();//Refresh the names list.
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
                                         }, db,_searchByName);
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
                 setState(() { selectedActivityModel = activityReceived; selectFamilyCardModel = familyCardModel; });
                 switch (code) {
                   case 1:
                     setState(() { cardIdentifier = message; _searchByName = false; });
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
                 if(ar != null && ar.mealChecked != null && !ar.mealChecked!.isEmpty) {
                   //Activity has been received before.
                   showAlert('Error'.tr(),'F_C_approved_voucher_amount'.tr(), AlertType.error);
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

   //*********** Search by name functions ***********

   Widget itemsBuilder(context, ActivitiesReceivedModel suggestion) {
     suggestion = suggestion == null
         ? new ActivitiesReceivedModel()
         : suggestion;
     return new ListTile(
         leading: Icon(suggestion.mealChecked != null ? Icons.check_circle : Icons.person),
         title: new Column(children: [
           new Row(children: [new Text(suggestion.info1!)]),
           new Row(children: [new Text(suggestion.info2!)])//,
           //new Row(children: [new Text(suggestion.info3!)])
         ]),
         iconColor: (suggestion.mealChecked != null ? Colors.green : Colors.grey),
         subtitle: new Text(suggestion.key! + (suggestion.delegatedName == null ? "" : ((" - ") + suggestion.delegatedName!)))
     );
   }

   void onSuggestionSelected(ActivitiesReceivedModel suggestion,showAlert(title, msg, AlertType type)) async {
     final Database db = await DatabaseHandler.initializeDB();
     //Get activity received model.
     var model = await _distributionProvider.getActivityByFamilyKey(suggestion.key!, UserProvider.currentUser!.id , UserProvider.currentRole!, db);
     if(UserProvider.currentRole == Permissions.Distributioner.index) {
       if (model!.received == false) {
         init();
         setState(() {
           selectedActivityModel = model;
         });
       }
       else {
         setState(() {
           selectedActivityModel = new ActivitiesReceivedModel();
           selectFamilyCardModel = new FamilyCardModel();
         });
         showAlert(
             'Error'.tr(), 'F_C_received_voucher_amount'.tr(), AlertType.error);
       }
     }
     else if(UserProvider.currentRole == Permissions.MealCheck.index) {
       if(model!.mealChecked == null) {
         init();
         setState(() {
           selectedActivityModel = model;
         });
       }
       else {
         setState(() {
           selectedActivityModel = new ActivitiesReceivedModel();
           selectFamilyCardModel = new FamilyCardModel();
         });
         showAlert('Error'.tr(),'F_C_received_voucher_amount'.tr(), AlertType.error);
       }
     }
     //Get family cards.
     var existedModels = await _familyCardProvider.getFamilyCardModelsByActivityId(selectedActivityModel.id, db);
     if(existedModels.length > 0) {
       setState(() {
         selectFamilyCardModel = existedModels.first;
       });
     }
     setState(() { _searchByName = true; });
   }

   void init() {
     selectedActivityModel = new ActivitiesReceivedModel();
     selectFamilyCardModel = new FamilyCardModel();
     cardIdentifier = '';
     commentController.clear();
     stopNFC();
   }

   List<ActivitiesReceivedModel> onSuggestionsCallback(String pattern) {
     return suggestedActivityModels.where((element) => (element.info1 != null ? element.info1!.contains(pattern) : false) ||
         (element.info2 != null ? element.info2!.contains(pattern) : false) ||
         //(element.info3 != null ? element.info3!.contains(pattern) : false) ||
         (element.delegatedName != null ? element.delegatedName!.contains(pattern) : false) ||
         (element.delegatedId != null ? element.delegatedId!.contains(pattern) : false) ||
         element.key!.contains(pattern))
         .toList();
   }

   void initReceivedActivitiesModels() async {
     try {
       final Database db = await DatabaseHandler.initializeDB();
       var activityModels = await _distributionProvider.getAllReceivedModelsLocally(UserProvider.currentUser!.id, UserProvider.currentRole!, db);
       setState(() { suggestedActivityModels = activityModels; });
     }
     catch(ex) { }
   }

   //************************************************

}