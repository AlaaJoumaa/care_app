import 'dart:async';
import 'package:care_app/Controllers/ReadCardController.dart';
import 'package:care_app/Models/ActivitiesReceivedModel.dart';
import 'package:care_app/Models/FamilyCardModel.dart';
import 'package:care_app/Providers/UserProvider.dart';
import 'package:care_app/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:intl/intl.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:easy_localization/easy_localization.dart' as easylocal;
//import 'package:signature/signature.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:screenshot/screenshot.dart';
import 'package:flutter_signature_pad/flutter_signature_pad.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

class ReadCardView extends StatefulWidget {
  @override
  _ReadCardViewState createState() => _ReadCardViewState();
}

class _ReadCardViewState extends StateMVC<ReadCardView> {

  //final sign = GlobalKey<SignatureState>();
  late ReadCardController con;
  bool alertOpened = false;
  //late BluetoothDevice _device;

  void showConfAlert(title,msg, AlertType type) async {
    await showDialog(context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: new Text(title,
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20,
                                  color: Color.fromRGBO(28, 29, 48, 1)),
                              textAlign: TextAlign.center),
                          content: new Text(
                              msg,
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                              textAlign: TextAlign.center),
                          actions: <Widget>[
                            FlatButton(
                              color: Color.fromRGBO(227, 111, 30, 1),
                              child: new Text("YES".tr(), style: TextStyle(
                                  color: Colors.white, fontWeight: FontWeight.bold)),
                              onPressed: () {
                                Navigator.of(context).pop();
                                con.receiveActivity(showAlert);
                              },
                            ),
                            FlatButton(
                              color: Color.fromRGBO(244, 178, 35, 1),
                              child: new Text("NO".tr(), style: TextStyle(
                                  color: Colors.white, fontWeight: FontWeight.bold)),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        );
                      });
  }

  void showAlert(title,msg, AlertType type) {
    if(!alertOpened) {
      Alert(
          context: context,
          type: type,
          title: title,
          desc: msg,
          style: AlertStyle(
              titleStyle: new TextStyle(color: Colors.black, fontSize: 18),
              descStyle: new TextStyle(color: Colors.black, fontSize: 13)
          ),
          buttons: [
            DialogButton(
              child: Text(
                  'Close'.tr(), style: TextStyle(color: Colors.white, fontSize: 13)),
              onPressed: () {  alertOpened = false; Navigator.pop(context); }, width: 120,
            )
          ]).show();
      alertOpened = true;
    }
  }

  void showImage(int index, AlertType type) {
    Alert(
        context: context,
        image: Image.memory(con.identityImgs[index]!, fit: BoxFit.contain,),
        buttons: [
          DialogButton(color: Color.fromRGBO(28, 29, 48, 1),
            child: Text('Close'.tr(), style: TextStyle(color: Colors.white, fontSize: 13)),
            onPressed: () { Navigator.pop(context); }, width: 120
          ),
          DialogButton(color: Color.fromRGBO(227, 111, 30, 1),
            child: Text('Remove'.tr(), style: TextStyle(color: Colors.white, fontSize: 13)),
            onPressed: () {
              if(con.identityImgs[index] !=  null) {
                setState(() { con.identityImgs.removeAt(index); });
              }
              Navigator.pop(context);
            }, width: 120
          )
        ]
    ).show();
  }

  _ReadCardViewState() : super(ReadCardController()) {

    con = controller as ReadCardController;
  }

  @override
  void initState() {
    super.initState();
    con.message = "NFC_Read".tr();
    WidgetsBinding.instance?.addPostFrameCallback((_) async {
         con.readNFCData(showAlert);
         con.clearSignature();
         con.initBluePrinter();
    });
  }

  Future<bool> onBack() async {
    await Navigator.pushReplacementNamed(context, '/Home');
    return true;
  }

  void onPrintPressed(){
    con.print(showAlert);
  }

  void onClearPressed(){
    con.clearSignature();
  }

  @override
  void dispose() {
    con.selectedActivityModel = new ActivitiesReceivedModel();
    con.selectFamilyCardModel = new FamilyCardModel();
    con.clearSignature();
    con.message = "NFC_Read".tr();
    con.stopNFC();
    if(con.connected) {
      con.bluetooth.disconnect();
    }
    con.connected = false;
    con.identityImgs =[null];
    con.cardWithAmount = false;
    con.cardWithAmountColor = Colors.black;
    con.showCardWithAmount = false;
    con.delegatedBy = false;
    con.delegatedNameController.text = '';
    con.delegatedIdController.text = '';
    con.delegatedName = null;
    con.delegatedId = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context,designSize: Size(MediaQuery.of(context).size.width, MediaQuery.of(context).size.height),
        minTextAdapt: true);
    return WillPopScope(
        onWillPop: onBack,
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Color.fromRGBO(227, 111, 30, 1),
            title: new Align(
                child: Text("Read_Card".tr()), alignment: Alignment.center),
            automaticallyImplyLeading: false,
            actions: [ new Padding(padding: EdgeInsets.only(left: 10, right: 10),
                  child: Icon(
                      con.connected ? Icons.print : Icons.print_disabled)) ],
            leading: IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => onBack()
            ),
          ),
          body: new SingleChildScrollView(
              child: new Form(
                child: new Column(
                  children: <Widget>[
                    new Padding(child: new Container(
                        child: new Text(
                        con.message, style: new TextStyle(color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Color.fromRGBO(28, 29, 48, 1),
                          boxShadow: [
                            BoxShadow(color: Color.fromRGBO(227, 111, 30, 1), spreadRadius: 3),
                          ],
                        ),
                        height: 50,
                        alignment: Alignment.center),
                      padding: const EdgeInsets.only(left: 10.0, right: 10.0, top: 20, bottom: 0),
                    ),

                    con.selectedActivityModel.key!.isNotEmpty ?
                    new Column(children: [
                      new Row(children: [
                        Expanded(child:
                        new Padding(child:
                            new Screenshot(child:
                                new Card(color: Colors.white70,
                                    child: new Column(children: [
                                        new Padding(child: new Row(children: [
                                          new Expanded(child: new Text('Invoice'.tr(),
                                            textAlign: TextAlign.center,)),
                                        ]),
                                            padding: const EdgeInsets.only(left: 10.0,
                                                right: 10.0,
                                                top: 10,
                                                bottom: 10)
                                        ),
                                        new Padding(child:
                                            new Row(children: [
                                          new Expanded(child: new Text('Date'.tr())),
                                          new Expanded(child: new Text(
                                              DateFormat('EE MMM dd HH:mm:ss yyyy')
                                                  .format(new DateTime.now())), flex: 2),
                                        ]),
                                              padding: const EdgeInsets.only(left: 10.0,
                                                right: 10.0,
                                                top: 10,
                                                bottom: 10)
                                        ),
                                        new Padding(child: new Row(children: [
                                          new Expanded(child: new Text('Project'.tr(),
                                              style: TextStyle(
                                                  fontSize: ScreenUtil().setSp(15)))),
                                          new Expanded(child: new Text(
                                              (MyApp.currentLang == "en" ? UserProvider
                                                  .currentUser!
                                                  .partner_info!
                                                  .split("##")
                                                  .first : UserProvider.currentUser!
                                                  .partner_info!.split("##").last) +
                                                  ' - ' + 'Project_Statement'.tr(),
                                              style: TextStyle(
                                                  fontSize: ScreenUtil().setSp(15))),
                                              flex: 2),
                                        ]),
                                            padding: const EdgeInsets.only(left: 10.0,
                                                right: 10.0,
                                                top: 10,
                                                bottom: 10)),
                                        new Padding(child: new Row(children: [
                                          new Expanded(child: new Text('Vendor'.tr(),
                                              style: TextStyle(
                                                  fontSize: ScreenUtil().setSp(15)))),
                                          new Expanded(child: new Text(
                                              UserProvider.currentUser!.email!,
                                              style: TextStyle(
                                                  fontSize: ScreenUtil().setSp(15))),
                                              flex: 2),
                                        ]),
                                            padding: const EdgeInsets.only(left: 10.0,
                                                right: 10.0,
                                                top: 10,
                                                bottom: 10)),
                                        new Padding(child: new Row(children: [
                                          new Expanded(child: new Text('Beneficiary'.tr(),
                                              style: TextStyle(
                                                  fontSize: ScreenUtil().setSp(15)))),
                                          new Expanded(child: new Text(
                                              con.selectedActivityModel.info1!,
                                              style: TextStyle(
                                                  fontSize: ScreenUtil().setSp(15))),
                                              flex: 2),
                                        ]),
                                            padding: const EdgeInsets.only(left: 10.0,
                                                right: 10.0,
                                                top: 10,
                                                bottom: 10)),
                                        new Padding(child: new DottedLine(
                                          direction: Axis.horizontal,
                                          lineLength: double.infinity,
                                          lineThickness: 2.0,
                                          dashLength: 4.0,
                                          dashColor: Colors.black,
                                          dashRadius: 0.0,
                                          dashGapLength: 4.0,
                                          dashGapRadius: 0.0,
                                        ),
                                            padding: const EdgeInsets.only(left: 15.0,
                                                right: 15.0,
                                                top: 10,
                                                bottom: 10)),
                                        new Padding(child:
                                          new Row(children: [
                                            new Expanded(child: new Text(
                                                'Invoice_Number'.tr(), style: TextStyle(
                                                fontSize: ScreenUtil().setSp(15)))),
                                          ]),
                                              padding: const EdgeInsets.only(left: 10.0,
                                                  right: 10.0,
                                                  top: 10,
                                                  bottom: 10)
                                        ),
                                        new Padding(child:
                                            new Row(children: [
                                              new Expanded(child: new Text(
                                                  (con.selectedActivityModel.key! + ' - ' +
                                                      con.selectedActivityModel.id
                                                          .toString()), style: TextStyle(
                                                  fontSize: ScreenUtil().setSp(15)))),
                                            ]),
                                            padding: const EdgeInsets.only(left: 10.0,
                                                right: 10.0,
                                                top: 10,
                                                bottom: 10)),
                                        new Padding(child:
                                            new Row(children: [
                                              new Expanded(child: new Text('Portfolio'.tr(),
                                                  style: TextStyle(
                                                      fontSize: ScreenUtil().setSp(15)))),
                                              new Expanded(child: new Text(
                                                  (MyApp.currentLang == "en" ? UserProvider
                                                      .currentUser!
                                                      .partner_info!
                                                      .split("##")
                                                      .first : UserProvider.currentUser!
                                                      .partner_info!.split("##").last) +
                                                      ' - ' + 'Project_Statement'.tr(),
                                                  style: TextStyle(
                                                      fontSize: ScreenUtil().setSp(15))),
                                                  flex: 2),
                                            ]),
                                            padding: const EdgeInsets.only(left: 10.0,
                                                right: 10.0,
                                                top: 10,
                                                bottom: 10)
                                        ),
                                        new Padding(child:
                                        new Row(children: [
                                          new Expanded(child: new Text('Payment_USD'.tr(),
                                              style: TextStyle(
                                                  fontSize: ScreenUtil().setSp(15)))),
                                          new Expanded(child: new Text(
                                              (con.selectedActivityModel.payment_USD!
                                                  .toString() + "\$"), style: TextStyle(
                                              fontSize: ScreenUtil().setSp(15))),
                                              flex: 2),
                                        ]),
                                            padding: const EdgeInsets.only(left: 10.0,
                                                right: 10.0,
                                                top: 10,
                                                bottom: 10)),
                                        new Padding(child: new Row(children: [
                                          new Text("Total".tr(), style: TextStyle(
                                              fontSize: ScreenUtil().setSp(15))),
                                        ]),
                                            padding: const EdgeInsets.only(left: 10.0,
                                                right: 10.0,
                                                top: 10,
                                                bottom: 10)),
                                        new Row(children: [
                                          new Expanded(child: new Padding(child: new Text(
                                              con.selectedActivityModel!.payment_USD
                                                  .toString() + "\$", style: TextStyle(
                                              fontSize: ScreenUtil().setSp(15)),
                                              textAlign: (MyApp.currentLang == "en"
                                                  ? TextAlign.right
                                                  : TextAlign.left)),
                                              padding: const EdgeInsets.only(left: 10.0,
                                                  right: 10.0,
                                                  top: 10,
                                                  bottom: 10))),
                                        ]),
                                        new Padding(child: new DottedLine(
                                          direction: Axis.horizontal,
                                          lineLength: double.infinity,
                                          lineThickness: 2.0,
                                          dashLength: 4.0,
                                          dashColor: Colors.black,
                                          dashRadius: 0.0,
                                          dashGapLength: 4.0,
                                          dashGapRadius: 0.0,
                                        ),
                                            padding: const EdgeInsets.only(left: 15.0,
                                                right: 15.0,
                                                top: 10,
                                                bottom: 10)),
                                        new Row(children: [
                                          new Expanded(child: new Padding(child: new Text(
                                              "Vendor_Sign".tr(), style: TextStyle(
                                              fontSize: ScreenUtil().setSp(15),
                                              fontWeight: FontWeight.bold),
                                              textAlign: (MyApp.currentLang == "en"
                                                  ? TextAlign.left
                                                  : TextAlign.right)),
                                              padding: const EdgeInsets.only(left: 10.0,
                                                  right: 10.0,
                                                  top: 10,
                                                  bottom: 10))),
                                          new Expanded(child: new Padding(child: new Text(
                                              "Beneficiary_Sign".tr(), style: TextStyle(
                                              fontSize: ScreenUtil().setSp(15),
                                              fontWeight: FontWeight.bold),
                                              textAlign: (MyApp.currentLang == "en"
                                                  ? TextAlign.right
                                                  : TextAlign.left)),
                                              padding: const EdgeInsets.only(left: 10.0,
                                                  right: 10.0,
                                                  top: 10,
                                                  bottom: 10))),
                                        ]),
                                        new SizedBox(height: 70),
                                    ])
                                ), controller: con.screenshotCardController,
                            ), padding: const EdgeInsets.only(left: 15.0, right: 15.0, top: 15, bottom: 0),
                          )
                        ),
                      ]),

                      new Padding(child: new Card(color: Colors.white70,
                          child: new Column(children: [
                            new Row(children: [
                              new Expanded(child: new Padding(
                                  child: new Checkbox(checkColor: Colors.white, activeColor: Colors.red, value: con.delegatedBy,
                                      onChanged: (bool? value) { con.onDelegatedByChange(value!);  }),
                                  padding: EdgeInsets.only(left:10,right:10,bottom: 10,top: 10)),flex: 1,),
                              new Expanded(child:  new Text('Delegated_By'.tr(), style: TextStyle(fontSize: ScreenUtil().setSp(17),fontWeight: FontWeight.bold)),flex: 6,)
                            ]),

                            new Row(children: [

                              new Expanded(child: new Padding(
                                  child: TextFormField(controller: con.delegatedIdController,
                                    onChanged: (value) { con.onDelegatedIdChange(value); },
                                    inputFormatters: [LengthLimitingTextInputFormatter(100)],
                                    enabled: con.delegatedBy,
                                    keyboardType: TextInputType.name,
                                    decoration: InputDecoration(
                                        border: OutlineInputBorder(),
                                        labelText: 'Delegated_Id'.tr(),
                                        hintText: 'Delegated_Id'.tr()),
                                  ),
                                  padding: EdgeInsets.only(left: 15,right: 15))
                                  ,flex: 2),

                              new Expanded(child: new Padding(
                                  child: TextFormField(controller: con.delegatedNameController,
                                    onChanged: (value) {  con.onDelegatedNameChange(value); },
                                    inputFormatters: [LengthLimitingTextInputFormatter(100)],
                                    enabled: con.delegatedBy,
                                    keyboardType: TextInputType.name,
                                    decoration: InputDecoration(
                                        border: OutlineInputBorder(),
                                        labelText: 'Delegated_Name'.tr(),
                                        hintText: 'Delegated_Name'.tr()),
                                  ),
                                  padding: EdgeInsets.only(left: 15,right: 15))
                                  ,flex: 2),

                            ]),

                            new SizedBox(height: 15),

                      ])),padding: const EdgeInsets.only(left: 15.0, right: 15.0, top: 15, bottom: 0)),



                      new Row(children: [
                        new Expanded(child: new Padding(child: new Card(color: Colors.grey,child: new Container(width: MediaQuery.of(context).size.width,height: 2,)),padding:EdgeInsets.only(top:5,left: 10,right: 10,bottom: 5))),
                      ]),

                      new Row(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            new Expanded(child:  Container(
                              //color: Colors.blue,
                              height: 80.0,
                              child: ListView.builder(
                                   scrollDirection: Axis.horizontal,
                                   itemExtent: 100,
                                   itemCount: con.identityImgs.length,
                                   shrinkWrap: true,
                                   itemBuilder: (BuildContext ctxt, int index) {

                                     if((index >= 0 && index < con.identityImgs.length)) {

                                         return new InkWell(child: Container(
                                                     child: (con.identityImgs[index] != null
                                                             ? Image.memory(
                                                             con.identityImgs[index]!, fit: BoxFit.fill)
                                                             : new Icon(Icons.photo_camera_outlined,
                                                               //size: MediaQuery.of(context).size.width / 1.5,
                                                               color: Colors.grey)
                                                     ),
                                                     margin: const EdgeInsets.only(
                                                         left: 15.0,
                                                         right: 15.0,
                                                         bottom: 5),
                                                     //padding: const EdgeInsets.only(left:3.0,),
                                                     decoration: BoxDecoration(
                                                         border: Border.all(
                                                             color: Colors.black)
                                                     ),
                                                   ),
                                                   onLongPress: () { if(con.identityImgs[index] != null) { showImage(index, AlertType.info); } },
                                                   onTap:() { con.takePhoto(index); });
                                     }
                                     return ListTile();
                                  }),
                              ),
                            ),
                          ]),

                      new Row(children: [
                        new Expanded(child: new Padding(child: new Card(color: Colors.grey,child: new Container(width: MediaQuery.of(context).size.width,height: 2,)),padding:EdgeInsets.only(top:5,left: 10,right: 10,bottom: 5))),
                      ]),

                      new Row(children: [
                        new Expanded(child:
                            new Padding(padding: EdgeInsets.only(right: 25,left: 25),child:
                              new Row(children: [
                                new Checkbox(checkColor: Colors.white, activeColor: Colors.red,
                                             value: con.cardWithAmount,
                                             onChanged: (bool? value) { con.onCardWithAmountChange(value!); }),
                                Visibility(child: new Text('Sign_Received_And_Card'.tr(),textAlign: TextAlign.center,
                                           style: TextStyle(fontWeight: FontWeight.bold,
                                           color: con.cardWithAmountColor, fontSize: ScreenUtil().setSp(15)))
                                          ,visible: con.showCardWithAmount)
                              ]),
                            )
                        )
                      ]),

                      new Row(children: [
                        new Expanded(
                            child: new Padding(child:
                            new Container(
                              child: Signature(
                                color: Colors.black,
                                strokeWidth: 5.0,
                                onSign: () { },
                                key: con.signature,
                              ),
                              width: 300,
                              height: 300,
                              margin: const EdgeInsets.only(left: 40.0,right: 40.0,bottom: 15.0),
                              padding: const EdgeInsets.only(left: 3.0,right: 3.0,bottom: 3.0),
                              decoration: BoxDecoration(border: Border.all(color: Colors.black)),
                            ),padding: EdgeInsets.only(top:5),),
                        ),
                      ]),

                      new Row(children: [
                        new Expanded(child: new Padding(child: new RaisedButton(
                              color: Color.fromRGBO(28, 29, 48, 1),
                              onPressed: onClearPressed, //=> onLoginPressed(),
                              child: Text(
                                'clear'.tr(),
                                style: TextStyle(color: Colors.white,
                                    fontSize: ScreenUtil().setSp(25)),
                              ),
                            ), padding: const EdgeInsets.only(
                                left: 15.0, right: 15.0, top: 0, bottom: 0))
                        ),
                      ]),

                      new Padding(child: new Card(color: Colors.white70,
                        child: new Column(children: [
                          new Row(children: [
                            new Expanded(child: new Padding(child: new Text(
                              'Card_Info'.tr(), textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: ScreenUtil().setSp(20),),),
                                padding: const EdgeInsets.only(left: 10.0,
                                    right: 10.0,
                                    top: 10,
                                    bottom: 0)))
                          ]),
                          new Row(children: [
                            new Expanded(child: new Padding(child: new Text(
                              'Hex_Id'.tr() + ': ' +
                                  con.selectFamilyCardModel.hexId!,
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.black,
                                fontSize: ScreenUtil().setSp(20),),),
                                padding: const EdgeInsets.only(left: 10.0,
                                    right: 10.0,
                                    top: 10,
                                    bottom: 0)))
                          ]),
                          new Row(children: [
                            Expanded(child: new Padding(child: new RaisedButton(
                              color: Color.fromRGBO(28, 29, 48, 1),
                              onPressed: (con.showPrint ? null : () { showConfAlert('Receive_Confirmation'.tr(),'Receive_Confirmation_Msg'.tr(),AlertType.warning); }),
                              child: Text(
                                'Receive'.tr(),
                                style: TextStyle(
                                    color: Colors.white, fontSize: 25),
                              ),
                            ),
                                padding: const EdgeInsets.only(left: 10.0,
                                    right: 10.0,
                                    top: 10,bottom: 5))
                            )
                          ]),
                         (con.showPrint ?
                              new Row(children: [
                                new Expanded(child: new Padding(child: new RaisedButton(
                                  color: Color.fromRGBO(28, 29, 48, 1),
                                  onPressed: onPrintPressed, //=> onLoginPressed(),
                                  child: Text(
                                    'Print'.tr(),
                                    style: TextStyle(color: Colors.white,
                                        fontSize: ScreenUtil().setSp(25)),
                                  ),
                                ), padding: const EdgeInsets.only(
                                    left: 10, right: 10, top: 0, bottom: 5))),
                              ])
                          : new SizedBox()),


                        ]),
                      ), padding: const EdgeInsets.only(
                              left: 10.0, right: 10.0, top: 10, bottom: 0))

                    ]) : new SizedBox(),
                    new SizedBox(height: 20),
                  ],
                ),
              )
          ),
        )
    );
  }
}
