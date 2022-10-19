import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:typed_data';
import 'dart:ui';
import 'package:care_app/main.dart';
import 'package:intl/intl.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:screenshot/screenshot.dart';
import 'package:care_app/Models/ActivitiesReceivedModel.dart';
import 'package:care_app/Models/FamilyCardModel.dart';
import 'package:care_app/Providers/DistributionProvider.dart';
import 'package:care_app/Providers/FamilyCardProvider.dart';
import 'package:care_app/Providers/NFCProvider.dart';
import 'package:care_app/Providers/UserProvider.dart';
import 'package:care_app/Services/DatabaseHandler.dart';
import 'package:flutter/material.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:sqflite/sqflite.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:easy_localization/easy_localization.dart' as easylocal;
//import 'package:signature/signature.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter/services.dart';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_signature_pad/flutter_signature_pad.dart';

class ReadCardController extends ControllerMVC {

  factory ReadCardController([StateMVC? state]) =>
      _this ??= ReadCardController._(state);

  //Inherit the (_) function.
  ReadCardController._(StateMVC? state)
      :
        bluetooth = BlueThermalPrinter.instance,
        _nfcProvider = new NFCProvider(),
        _familyCardProvider = new FamilyCardProvider(),
        _distributionProvider = new DistributionProvider(),
        selectedActivityModel = new ActivitiesReceivedModel(),
        selectFamilyCardModel = new FamilyCardModel(),
        screenshotCardController = new ScreenshotController(),
        delegatedIdController = new TextEditingController(),
        delegatedNameController = new TextEditingController(),
        suggestedActivityController = new TextEditingController(),
        message = '',
        delegatedName = null,
        delegatedId = null,
        super(state);

  TextEditingController delegatedIdController;
  TextEditingController delegatedNameController;
  TextEditingController suggestedActivityController;

  ScreenshotController screenshotCardController;
  static ReadCardController? _this;
  NFCProvider _nfcProvider;
  FamilyCardProvider _familyCardProvider;
  DistributionProvider _distributionProvider;
  String message = '';
  ActivitiesReceivedModel selectedActivityModel;
  FamilyCardModel selectFamilyCardModel;
  List<Uint8List?> identityImgs = [null];
  final signature = GlobalKey<SignatureState>();
  bool showPrint = false;
  bool cardWithAmount = false;
  Color cardWithAmountColor = Colors.black;
  bool showCardWithAmount = false;
  bool delegatedBy = false;
  String invoiceDate = '';

  BlueThermalPrinter bluetooth;
  List<BluetoothDevice> _devices = [];
  bool connected = false;

  String? delegatedName = null;
  String? delegatedId = null;
  List<ActivitiesReceivedModel> suggestedActivityModels = [];

  void clearSignature(){
    final sign = signature.currentState;
    if(sign != null) {
      sign.clear();
    }
  }

  // Widget getEnInvoice() {
  //   return new Row(children: [
  //           Expanded(child:
  //           new Padding(child:
  //           new Screenshot(child:
  //           new Card(color: Colors.white70,
  //               child: new Column(children: [
  //                 new Padding(child: new Row(children: [
  //                   new Expanded(child: new Text('Invoice'.tr(),
  //                     textAlign: TextAlign.center,)),
  //                 ]),
  //                     padding: const EdgeInsets.only(left: 10.0,
  //                         right: 10.0,
  //                         top: 10,
  //                         bottom: 10)
  //                 ),
  //                 new Padding(child:
  //                 new Row(children: [
  //                   new Expanded(child: new Text('Date'.tr())),
  //                   new Expanded(child: new Text(
  //                       DateFormat('EE MMM dd HH:mm:ss yyyy')
  //                           .format(new DateTime.now())), flex: 2),
  //                 ]),
  //                     padding: const EdgeInsets.only(left: 10.0,
  //                         right: 10.0,
  //                         top: 10,
  //                         bottom: 10)
  //                 ),
  //                 new Padding(child: new Row(children: [
  //                   new Expanded(child: new Text('Project'.tr(),
  //                       style: TextStyle(
  //                           fontSize: ScreenUtil().setSp(15)))),
  //                   new Expanded(child: new Text(
  //                       (MyApp.currentLang == "en" ? UserProvider
  //                           .currentUser!
  //                           .partner_info!
  //                           .split("##")
  //                           .first : UserProvider.currentUser!
  //                           .partner_info!.split("##").last) +
  //                           ' - ' + 'Project_Statement'.tr(),
  //                       style: TextStyle(
  //                           fontSize: ScreenUtil().setSp(15))),
  //                       flex: 2),
  //                 ]),
  //                     padding: const EdgeInsets.only(left: 10.0,
  //                         right: 10.0,
  //                         top: 10,
  //                         bottom: 10)),
  //                 new Padding(child: new Row(children: [
  //                   new Expanded(child: new Text('Vendor'.tr(),
  //                       style: TextStyle(
  //                           fontSize: ScreenUtil().setSp(15)))),
  //                   new Expanded(child: new Text(
  //                       UserProvider.currentUser!.email!,
  //                       style: TextStyle(
  //                           fontSize: ScreenUtil().setSp(15))),
  //                       flex: 2),
  //                 ]),
  //                     padding: const EdgeInsets.only(left: 10.0,
  //                         right: 10.0,
  //                         top: 10,
  //                         bottom: 10)),
  //                 new Padding(child: new Row(children: [
  //                   new Expanded(child: new Text('Beneficiary'.tr(),
  //                       style: TextStyle(
  //                           fontSize: ScreenUtil().setSp(15)))),
  //                   new Expanded(child: new Text(
  //                       selectedActivityModel.info1!,
  //                       style: TextStyle(
  //                           fontSize: ScreenUtil().setSp(15))),
  //                       flex: 2),
  //                 ]),
  //                     padding: const EdgeInsets.only(left: 10.0,
  //                         right: 10.0,
  //                         top: 10,
  //                         bottom: 10)),
  //                 new Padding(child: new DottedLine(
  //                   direction: Axis.horizontal,
  //                   lineLength: double.infinity,
  //                   lineThickness: 2.0,
  //                   dashLength: 4.0,
  //                   dashColor: Colors.black,
  //                   dashRadius: 0.0,
  //                   dashGapLength: 4.0,
  //                   dashGapRadius: 0.0,
  //                 ),
  //                     padding: const EdgeInsets.only(left: 15.0,
  //                         right: 15.0,
  //                         top: 10,
  //                         bottom: 10)),
  //                 new Padding(child:
  //                 new Row(children: [
  //                   new Expanded(child: new Text(
  //                       'Invoice_Number'.tr(), style: TextStyle(
  //                       fontSize: ScreenUtil().setSp(15)))),
  //                 ]),
  //                     padding: const EdgeInsets.only(left: 10.0,
  //                         right: 10.0,
  //                         top: 10,
  //                         bottom: 10)
  //                 ),
  //                 new Padding(child:
  //                 new Row(children: [
  //                   new Expanded(child: new Text(
  //                       (selectedActivityModel.key! + ' - ' +
  //                           selectedActivityModel.id
  //                               .toString()), style: TextStyle(
  //                       fontSize: ScreenUtil().setSp(15)))),
  //                 ]),
  //                     padding: const EdgeInsets.only(left: 10.0,
  //                         right: 10.0,
  //                         top: 10,
  //                         bottom: 10)),
  //                 new Padding(child:
  //                 new Row(children: [
  //                   new Expanded(child: new Text('Portfolio'.tr(),
  //                       style: TextStyle(
  //                           fontSize: ScreenUtil().setSp(15)))),
  //                   new Expanded(child: new Text(
  //                       (MyApp.currentLang == "en" ? UserProvider
  //                           .currentUser!
  //                           .partner_info!
  //                           .split("##")
  //                           .first : UserProvider.currentUser!
  //                           .partner_info!.split("##").last) +
  //                           ' - ' + 'Project_Statement'.tr(),
  //                       style: TextStyle(
  //                           fontSize: ScreenUtil().setSp(15))),
  //                       flex: 2),
  //                 ]),
  //                     padding: const EdgeInsets.only(left: 10.0,
  //                         right: 10.0,
  //                         top: 10,
  //                         bottom: 10)
  //                 ),
  //                 new Padding(child:
  //                 new Row(children: [
  //                   new Expanded(child: new Text('Payment_USD'.tr(),
  //                       style: TextStyle(
  //                           fontSize: ScreenUtil().setSp(15)))),
  //                   new Expanded(child: new Text(
  //                       (selectedActivityModel.payment_USD!
  //                           .toString() + "\$"), style: TextStyle(
  //                       fontSize: ScreenUtil().setSp(15))),
  //                       flex: 2),
  //                 ]),
  //                     padding: const EdgeInsets.only(left: 10.0,
  //                         right: 10.0,
  //                         top: 10,
  //                         bottom: 10)),
  //                 new Padding(child: new Row(children: [
  //                   new Text("Total", style: TextStyle(
  //                       fontSize: ScreenUtil().setSp(15))),
  //                 ]),
  //                     padding: const EdgeInsets.only(left: 10.0,
  //                         right: 10.0,
  //                         top: 10,
  //                         bottom: 10)),
  //                 new Row(children: [
  //                   new Expanded(child: new Padding(child: new Text(
  //                       selectedActivityModel!.payment_USD
  //                           .toString() + "\$", style: TextStyle(
  //                       fontSize: ScreenUtil().setSp(15)),
  //                       textAlign: (MyApp.currentLang == "en"
  //                           ? TextAlign.right
  //                           : TextAlign.left)),
  //                       padding: const EdgeInsets.only(left: 10.0,
  //                           right: 10.0,
  //                           top: 10,
  //                           bottom: 10))),
  //                 ]),
  //                 new Padding(child: new DottedLine(
  //                   direction: Axis.horizontal,
  //                   lineLength: double.infinity,
  //                   lineThickness: 2.0,
  //                   dashLength: 4.0,
  //                   dashColor: Colors.black,
  //                   dashRadius: 0.0,
  //                   dashGapLength: 4.0,
  //                   dashGapRadius: 0.0,
  //                 ),
  //                     padding: const EdgeInsets.only(left: 15.0,
  //                         right: 15.0,
  //                         top: 10,
  //                         bottom: 10)),
  //                 new Row(children: [
  //                   new Expanded(child: new Padding(child: new Text(
  //                       "Vendor_Sign".tr(), style: TextStyle(
  //                       fontSize: ScreenUtil().setSp(15),
  //                       fontWeight: FontWeight.bold),
  //                       textAlign: (MyApp.currentLang == "en"
  //                           ? TextAlign.left
  //                           : TextAlign.right)),
  //                       padding: const EdgeInsets.only(left: 10.0,
  //                           right: 10.0,
  //                           top: 10,
  //                           bottom: 10))),
  //                   new Expanded(child: new Padding(child: new Text(
  //                       "Beneficiary_Sign".tr(), style: TextStyle(
  //                       fontSize: ScreenUtil().setSp(15),
  //                       fontWeight: FontWeight.bold),
  //                       textAlign: (MyApp.currentLang == "en"
  //                           ? TextAlign.right
  //                           : TextAlign.left)),
  //                       padding: const EdgeInsets.only(left: 10.0,
  //                           right: 10.0,
  //                           top: 10,
  //                           bottom: 10))),
  //                 ]),
  //                 new SizedBox(height: 70),
  //               ])
  //           ), controller: screenshotCardController,
  //           ), padding: const EdgeInsets.only(left: 15.0, right: 15.0, top: 15, bottom: 0),
  //        )
  //      ),
  //   ]);
  // }
  //
  // Widget getArInvoice() {
  //   return new Row(children: [
  //     Expanded(child:
  //     new Padding(child:
  //     new Screenshot(child:
  //     new Card(color: Colors.white70,
  //         child: new Column(children: [
  //           new Padding(child: new Row(children: [
  //             new Expanded(child: new Text('الفاتورة',
  //               textAlign: TextAlign.center,)),
  //           ]),
  //               padding: const EdgeInsets.only(left: 10.0,
  //                   right: 10.0,
  //                   top: 10,
  //                   bottom: 10)
  //           ),
  //           new Padding(child:
  //           new Row(children: [
  //             new Expanded(child: new Text('التاريخ')),
  //             new Expanded(child: new Text(
  //                 DateFormat('EE MMM dd HH:mm:ss yyyy')
  //                     .format(new DateTime.now())), flex: 2),
  //           ]),
  //               padding: const EdgeInsets.only(left: 10.0,
  //                   right: 10.0,
  //                   top: 10,
  //                   bottom: 10)
  //           ),
  //           new Padding(child: new Row(children: [
  //                 new Expanded(child: new Text('المشروع',
  //                     style: TextStyle(
  //                         fontSize: ScreenUtil().setSp(15)))),
  //                 new Expanded(child: new Text(
  //                     (UserProvider.currentUser!.partner_info!.split("##").last) +
  //                         ' - ' + 'النقد مقابل الغذاء',
  //                     style: TextStyle(
  //                         fontSize: ScreenUtil().setSp(15))),
  //                     flex: 2),
  //               ]),
  //               padding: const EdgeInsets.only(left: 10.0,
  //                   right: 10.0,
  //                   top: 10,
  //                   bottom: 10)),
  //           new Padding(child: new Row(children: [
  //             new Expanded(child: new Text('المورد',
  //                 style: TextStyle(
  //                     fontSize: ScreenUtil().setSp(15)))),
  //             new Expanded(child: new Text(
  //                 UserProvider.currentUser!.email!,
  //                 style: TextStyle(
  //                     fontSize: ScreenUtil().setSp(15))),
  //                 flex: 2),
  //           ]),
  //               padding: const EdgeInsets.only(left: 10.0,
  //                   right: 10.0,
  //                   top: 10,
  //                   bottom: 10)),
  //           new Padding(child: new Row(children: [
  //             new Expanded(child: new Text('المستفيد',
  //                 style: TextStyle(
  //                     fontSize: ScreenUtil().setSp(15)))),
  //             new Expanded(child: new Text(
  //                 selectedActivityModel.info1!,
  //                 style: TextStyle(
  //                     fontSize: ScreenUtil().setSp(15))),
  //                 flex: 2),
  //           ]),
  //               padding: const EdgeInsets.only(left: 10.0,
  //                   right: 10.0,
  //                   top: 10,
  //                   bottom: 10)),
  //           new Padding(child: new DottedLine(
  //             direction: Axis.horizontal,
  //             lineLength: double.infinity,
  //             lineThickness: 2.0,
  //             dashLength: 4.0,
  //             dashColor: Colors.black,
  //             dashRadius: 0.0,
  //             dashGapLength: 4.0,
  //             dashGapRadius: 0.0,
  //           ),
  //               padding: const EdgeInsets.only(left: 15.0,
  //                   right: 15.0,
  //                   top: 10,
  //                   bottom: 10)),
  //           new Padding(child:
  //           new Row(children: [
  //             new Expanded(child: new Text(
  //                 'رقم الفاتورة', style: TextStyle(
  //                 fontSize: ScreenUtil().setSp(15)))),
  //           ]),
  //               padding: const EdgeInsets.only(left: 10.0,
  //                   right: 10.0,
  //                   top: 10,
  //                   bottom: 10)
  //           ),
  //           new Padding(child:
  //           new Row(children: [
  //             new Expanded(child: new Text(
  //                 (selectedActivityModel.key! + ' - ' +
  //                     selectedActivityModel.id
  //                         .toString()), style: TextStyle(
  //                 fontSize: ScreenUtil().setSp(15)))),
  //           ]),
  //               padding: const EdgeInsets.only(left: 10.0,
  //                   right: 10.0,
  //                   top: 10,
  //                   bottom: 10)),
  //           new Padding(child:
  //           new Row(children: [
  //             new Expanded(child: new Text('المحفظة',
  //                 style: TextStyle(
  //                     fontSize: ScreenUtil().setSp(15)))),
  //             new Expanded(child: new Text(
  //                 (UserProvider.currentUser!.partner_info!.split("##").last) +
  //                     ' - ' + 'النقد مقابل الغذاء',
  //                 style: TextStyle(
  //                     fontSize: ScreenUtil().setSp(15))),
  //                 flex: 2),
  //           ]),
  //               padding: const EdgeInsets.only(left: 10.0,
  //                   right: 10.0,
  //                   top: 10,
  //                   bottom: 10)
  //           ),
  //           new Padding(child:
  //           new Row(children: [
  //             new Expanded(child: new Text('الرصيد المتبقي',
  //                 style: TextStyle(
  //                     fontSize: ScreenUtil().setSp(15)))),
  //             new Expanded(child: new Text(
  //                 (selectedActivityModel.payment_USD!
  //                     .toString() + "\$"), style: TextStyle(
  //                 fontSize: ScreenUtil().setSp(15))),
  //                 flex: 2),
  //           ]),
  //               padding: const EdgeInsets.only(left: 10.0,
  //                   right: 10.0,
  //                   top: 10,
  //                   bottom: 10)),
  //           new Padding(child: new Row(children: [
  //             new Text("الاجمالي", style: TextStyle(
  //                 fontSize: ScreenUtil().setSp(15))),
  //           ]),
  //               padding: const EdgeInsets.only(left: 10.0,
  //                   right: 10.0,
  //                   top: 10,
  //                   bottom: 10)),
  //           new Row(children: [
  //             new Expanded(child: new Padding(child: new Text(
  //                 selectedActivityModel!.payment_USD
  //                     .toString() + "\$", style: TextStyle(
  //                 fontSize: ScreenUtil().setSp(15)),
  //                 textAlign: (TextAlign.left)),
  //                 padding: const EdgeInsets.only(left: 10.0,
  //                     right: 10.0,
  //                     top: 10,
  //                     bottom: 10))),
  //           ]),
  //           new Padding(child: new DottedLine(
  //             direction: Axis.horizontal,
  //             lineLength: double.infinity,
  //             lineThickness: 2.0,
  //             dashLength: 4.0,
  //             dashColor: Colors.black,
  //             dashRadius: 0.0,
  //             dashGapLength: 4.0,
  //             dashGapRadius: 0.0,
  //           ),
  //               padding: const EdgeInsets.only(left: 15.0,
  //                   right: 15.0,
  //                   top: 10,
  //                   bottom: 10)),
  //           new Row(children: [
  //             new Expanded(child: new Padding(child: new Text(
  //                 "توقيع البائع", style: TextStyle(
  //                 fontSize: ScreenUtil().setSp(15),
  //                 fontWeight: FontWeight.bold),
  //                 textAlign: TextAlign.right),
  //                 padding: const EdgeInsets.only(left: 10.0,
  //                     right: 10.0,
  //                     top: 10,
  //                     bottom: 10))),
  //             new Expanded(child: new Padding(child: new Text(
  //                 "توقيع المستفيد", style: TextStyle(
  //                 fontSize: ScreenUtil().setSp(15),
  //                 fontWeight: FontWeight.bold),
  //                 textAlign: TextAlign.left),
  //                 padding: const EdgeInsets.only(left: 10.0,
  //                     right: 10.0,
  //                     top: 10,
  //                     bottom: 10))),
  //           ]),
  //           new SizedBox(height: 70),
  //         ])
  //     ), controller: screenshotCardController,
  //     ), padding: const EdgeInsets.only(left: 15.0, right: 15.0, top: 15, bottom: 0),
  //     )
  //     ),
  //   ]);
  // }

  Future<Uint8List?> _saveInvoiceImage(showAlert(title, msg, AlertType type)) async {
    try {
      double pixelRatio = 1;
      //final readCardState = stateOf<ReadCardView>();
     // Widget widget = new Column(children: [ getEnInvoice(),getArInvoice() ]);
      //Uint8List? cardImage = await screenshotCardController.captureFromWidget(widget,pixelRatio: pixelRatio,context: readCardState!.context);
      Uint8List? cardImage = await screenshotCardController.capture(pixelRatio: pixelRatio);
      var compImage = await FlutterImageCompress.compressWithList(cardImage!, quality: 96, format: CompressFormat.png);
      // Directory? dir = await DownloadsPathProvider.downloadsDirectory;
      // String path = '${dir!.path}/Care_Evoucher/${selectedActivityModel.id}-${selectedActivityModel.key}.png';
      // if (await Permission.manageExternalStorage.request().isGranted &&
      //     await Permission.storage.request().isGranted) {
      //   try {
      //     var fileExists = await File(path).exists();
      //     if (!fileExists) {
      //       var imageFile = await File(path).create(recursive: true);
      //       await imageFile.writeAsBytes(compImage!);
      //     }
      //   }
      //   catch (ex) {
      //     showAlert(
      //         'Error'.tr(), "Can't_Save_Invoice_Image_Storage".tr(), AlertType.error);
      //   }
      // }
      return compImage;
    }
    catch(ex) {
      showAlert('Error'.tr(),ex,AlertType.error);
    }
    return null;
  }

  void readNFCData(showAlert(title, msg, AlertType type)) async {

    _nfcProvider.ReadData((String message, int code) async {
      try {
          switch (code) {
            case 1:
              final Database db = await DatabaseHandler.initializeDB();
              //1- Search the family card by hexId.
              var existedModels = await _familyCardProvider
                  .getFamilyCardModelsByHexId(message, db);
              if (existedModels.length > 0) {
                  var familyCardModel = existedModels.first;
                  var activityReceived = await _distributionProvider
                      .getActivityReceived(familyCardModel.familyKey!,
                      UserProvider.currentUser!.id, UserProvider.currentRole!, db);
                  if (activityReceived != null) {
                    setState(() {
                      selectedActivityModel = activityReceived;
                      selectFamilyCardModel = familyCardModel;
                      identityImgs = [null];
                      showPrint = false;
                      clearSignature();
                      initDetectedActivityModelVals();
                    });
                    initReceivedActivitiesModels();
                  }
                  else {
                    var ar = await _distributionProvider.getActivityByFamilyKey(familyCardModel.familyKey!,
                        UserProvider.currentUser!.id,
                        UserProvider.currentRole!,
                        db);
                    if(ar != null && ar.received) {
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
              db.close();
              break;
            case -4:
                  showAlert('Error'.tr(), 'Not_Supported_Card_Msg'.tr(), AlertType.error);
              break;
            default:
                  showAlert('Error'.tr(), 'An_Error'.tr() + ': $message', AlertType.error);
          }
      }
      catch (ex) {
          showAlert('Error'.tr(), 'An_Error'.tr() + ': $ex, ' + 'Enter_Page_Again'.tr(), AlertType.error);
      }
      readNFCData(showAlert);
    });
  }

  void receiveActivity(showAlert(title, msg, AlertType type)) async {
    try {
      if (signature.currentState!.hasPoints == false) {
        showAlert('Error'.tr(), 'signature_required'.tr(), AlertType.error);
        return;
      }
      if(identityImgs.length == 1) {
        showAlert('Error'.tr(), 'identity_Images_required'.tr(), AlertType.error);
        return;
      }
      final Database db = await DatabaseHandler.initializeDB();
      //Get the beneficiary signature.
      var signImage = await signature.currentState!.getData();
      var imageByteData = await signImage.toByteData(format: ImageByteFormat.png);
      var uint8ListData = imageByteData!.buffer.asUint8List(imageByteData.offsetInBytes,imageByteData.lengthInBytes);
      selectedActivityModel.signImage = base64.encode(uint8ListData);
      // var signCompImage = await FlutterImageCompress.compressWithList(uint8ListData, minHeight: 64, minWidth: 64, quality: 96);
      // selectedActivityModel.signImage = base64.encode(signCompImage!);
      //Compressing identity images.
      var compIdentityBase64Imgs = [];
      var availableImgs = identityImgs.where((element) => element != null).toList();
      for(var i = 0;i <availableImgs.length;i++) {
        var element = availableImgs[i];
        var compIdentityImg = await FlutterImageCompress.compressWithList(
            element!, minHeight: 300, minWidth: 300, quality: 96);
        compIdentityBase64Imgs.add(base64.encode(compIdentityImg));
      }
      selectedActivityModel.signImage = selectedActivityModel.signImage! +
                                        ("|" + compIdentityBase64Imgs.join("|"));
      var result = await _distributionProvider.receive(selectFamilyCardModel.familyKey!,
                                                       selectedActivityModel,
                                                       UserProvider.currentUser!.id,
                                                       db);
      if (result) {
        await _saveInvoiceImage(showAlert);
        showAlert('Success'.tr(), 'Activity_Received'.tr(), AlertType.success);
        //setState(() {
          //selectedActivityModel = new ActivitiesReceivedModel();
          //selectFamilyCardModel = new FamilyCardModel();
        //});
        //clearSignature();
        setState(() { showPrint = true; });
      }
      else {
        showAlert('Error'.tr(), "No_Cash_For_F_C".tr(), AlertType.error);
      }
      db.close();
    }
    catch (ex) {
      showAlert('Error'.tr(), 'An_Error'.tr() + ': $ex, ' + 'Enter_Page_Again'.tr(), AlertType.error);
    }
  }

  void stopNFC() async {
    _nfcProvider.StopNFC();
  }

  void print(showAlert(title, msg, AlertType type)) async {
    try {
      if (connected) {
        var bytes = await _saveInvoiceImage(showAlert);
        if(bytes == null) {
          showAlert('Error'.tr(),"Can't_generate_invoice".tr(),AlertType.error);
        }
        else {
          bluetooth.printImageBytes(bytes);
          bluetooth.printNewLine();
          bluetooth.printNewLine();
          bluetooth.printNewLine();
          bluetooth.printNewLine();
          bluetooth.paperCut();
        }
      }
      else {
        //The printer is not connected.
        showAlert('Error'.tr(), 'Printer_Not_Connected'.tr(), AlertType.error);
      }
    }
    catch (ex) {
      showAlert('Error'.tr(), ex, AlertType.error);
    }
  }

  void initBluePrinter() async {
    bluetooth.isConnected.then((value) async {
      try {
        if (value!) {
          setState(() { connected = true; });
        }
        else {
          List<BluetoothDevice> devices = [];
          try {
            if(await Permission.bluetooth.request().isGranted && await Permission.location.request().isGranted) {
              devices = await bluetooth.getBondedDevices();
            }
          } on PlatformException {
            /*No printers existed.*/
          }
          setState(() { _devices = devices; });
          bluetooth.onStateChanged().listen((state) {
            try {
              switch (state) {
                case BlueThermalPrinter.CONNECTED:
                  setState(() { connected = true; });
                  break;
                case BlueThermalPrinter.DISCONNECTED:
                  setState(() { connected = false; });
                  break;
                case BlueThermalPrinter.DISCONNECT_REQUESTED:
                  setState(() { connected = false; });
                  break;
                case BlueThermalPrinter.STATE_TURNING_OFF:
                  setState(() { connected = false; });
                  break;
                case BlueThermalPrinter.STATE_OFF:
                  setState(() { connected = false; });
                  break;
                case BlueThermalPrinter.STATE_ON:
                  setState(() { connected = false; });
                  break;
                case BlueThermalPrinter.STATE_TURNING_ON:
                  setState(() { connected = false; });
                  break;
                case BlueThermalPrinter.ERROR:
                  setState(() { connected = false; });
                  break;
                default:
                  break;
              }
            }
            catch(ex) {  }
          });
          if (_devices.length > 0) {
            await bluetooth.connect(_devices.first);
          }
        }
      }
      catch(ex) { }
    });
  }

  void takePhoto(int index) async {
    try {
      if(identityImgs.length <= 3) {
        if (await Permission.camera.request().isGranted) {
          final ImagePicker _picker = new ImagePicker();
          XFile? _identityFile = await _picker.pickImage(
              source: ImageSource.camera);
          if (_identityFile != null) {
            var image = await _identityFile.readAsBytes();
            setState(() {
              identityImgs[index] = image;
              if (index == identityImgs.length - 1) {
                identityImgs.add(null);
              }
            });
          }
        }
      }
    }
    catch(ex) { }
  }

  void onCardWithAmountChange(bool value) {
    setState(() {
      cardWithAmount = value;
    });
    Timer.periodic(new Duration(seconds: 1), (timer) {
      if (cardWithAmount) {
        setState(() {
          cardWithAmountColor =
          cardWithAmountColor == Colors.black ? Colors.red : Colors.black;
        });
      }
      else {
        setState(() {
          cardWithAmountColor = Colors.black;
        });
        timer.cancel();
      }
    });
    showCardWithAmount = cardWithAmount ? true : false;
  }

  void initDetectedActivityModelVals() {
    delegatedName = (selectedActivityModel.delegatedName == null ? "" : selectedActivityModel.delegatedName!);
    delegatedId = (selectedActivityModel.delegatedId == null ? "" : selectedActivityModel.delegatedId!);
    selectedActivityModel.delegatedName = null;
    selectedActivityModel.delegatedId = null;
    invoiceDate = DateFormat('EE MMM dd HH:mm:ss yyyy').format(new DateTime.now());
  }

  void initReceivedActivitiesModels() async {
    try {
      final Database db = await DatabaseHandler.initializeDB();
      var activityModels = await _distributionProvider.getAllReceivedModelsLocally(UserProvider.currentUser!.id, UserProvider.currentRole!, db);
      setState(() { suggestedActivityModels = activityModels; });
    }
    catch(ex) { }
  }

  void onDelegatedByChange(bool value) {
    setState(() {
      delegatedBy = value;
      if(value == true) {
        delegatedNameController.text = (delegatedName == null ? "" : delegatedName!);
        delegatedIdController.text = (delegatedId == null ? "" : delegatedId!);
        selectedActivityModel.delegatedName = (delegatedName == null ? "" : delegatedName!);
        selectedActivityModel.delegatedId = (delegatedId == null ? "" : delegatedId!);
      }
      else {
        delegatedNameController.text = '';
        delegatedIdController.text = '';
        selectedActivityModel.delegatedName = null;
        selectedActivityModel.delegatedId = null;
      }
    });
  }

  void onDelegatedIdChange(String? value) {
    setState(() { selectedActivityModel.delegatedId = value; });
  }

  void onDelegatedNameChange(String? value) {
    setState(() { selectedActivityModel.delegatedName = value; });
  }

  void init() {
    selectedActivityModel = new ActivitiesReceivedModel();
    selectFamilyCardModel = new FamilyCardModel();
    message = "NFC_Read".tr();
    stopNFC();
    if(connected) {
      bluetooth.disconnect();
    }
    connected = false;
    identityImgs =[null];
    cardWithAmount = false;
    cardWithAmountColor = Colors.black;
    showCardWithAmount = false;
    delegatedBy = false;
    delegatedNameController.text = '';
    delegatedIdController.text = '';
    delegatedName = null;
    delegatedId = null;
    suggestedActivityController.value = new TextEditingValue(text: '');
    invoiceDate = '';
  }

  void onSuggestionSelected(ActivitiesReceivedModel suggestion,showAlert(title, msg, AlertType type)) async {
    final Database db = await DatabaseHandler.initializeDB();
    var model = await _distributionProvider.getActivityByFamilyKey(suggestion.key!, UserProvider.currentUser!.id , UserProvider.currentRole!, db);
    if(model!.received == false) {
      init();
      setState(() { selectedActivityModel = model; });
    }
    else {
      setState(() {
        selectedActivityModel = new ActivitiesReceivedModel();
        selectFamilyCardModel = new FamilyCardModel();
      });
      showAlert('Error'.tr(),'F_C_received_voucher_amount'.tr(), AlertType.error);
    }
    setState(() { identityImgs = [null]; showPrint = false; initDetectedActivityModelVals(); });
    clearSignature();
  }

  Widget itemsBuilder(context, ActivitiesReceivedModel suggestion) {
    suggestion = suggestion == null
        ? new ActivitiesReceivedModel()
        : suggestion;
    return new ListTile(
        leading: Icon(suggestion.received ? Icons.check_circle : Icons.person),
        title: new Text(suggestion.info1!),
        iconColor: (suggestion.received ? Colors.green : Colors.grey),
        subtitle: new Text(suggestion.key! + (suggestion.delegatedName == null ? "" : ((" - ") + suggestion.delegatedName!)))
    );
  }

  List<ActivitiesReceivedModel> onSuggestionsCallback(String pattern) {
    return suggestedActivityModels.where((element) => (element.info1 != null ? element.info1!.contains(pattern) : false) ||
                                                      (element.info2 != null ? element.info2!.contains(pattern) : false) ||
                                                      (element.info3 != null ? element.info3!.contains(pattern) : false) ||
                                                      (element.delegatedName != null ? element.delegatedName!.contains(pattern) : false) ||
                                                      (element.delegatedId != null ? element.delegatedId!.contains(pattern) : false) ||
                                                       element.key!.contains(pattern))
                                  .toList();
  }
}