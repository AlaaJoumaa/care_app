import 'dart:async';
import 'package:care_app/Controllers/ApproveCardController.dart';
import 'package:care_app/Models/ActivitiesReceivedModel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart' as easylocal;
import 'package:flutter_typeahead/flutter_typeahead.dart';


class ApproveCardView extends StatefulWidget {
  @override
  _ApproveCardViewState createState() => _ApproveCardViewState();
}

class _ApproveCardViewState extends StateMVC<ApproveCardView> {

  bool alertOpened = false;
  late ApproveCardController con;

  _ApproveCardViewState() : super(ApproveCardController()) {

    con = controller as ApproveCardController;
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

  void showConfAlert(title,msg, AlertType type) async {
    await showDialog(context: context,
        builder: (BuildContext context)
        {
          return AlertDialog(
            title: new Text(title,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20,
                    color: Color.fromRGBO(28, 29, 48, 1)),
                textAlign: TextAlign.center),
            content: new Text(
                msg, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center),
            actions: <Widget>[
              FlatButton(
                color: Color.fromRGBO(227, 111, 30, 1),
                child: new Text("YES".tr(), style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
                onPressed: () {
                  Navigator.of(context).pop();
                  con.approve(showAlert);
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      con.readNFCData(showAlert);
      con.initReceivedActivitiesModels();
    });
  }

  void onApprovePressed() {
    con.approve(showAlert);
  }

  Future<bool> onBack() async {
    await Navigator.pushReplacementNamed(context, '/Home');
    return true;
  }

  @override
  void dispose() {
    con.init();
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
        title: new Align(child: Text('Approve_Card'.tr()), alignment: Alignment.center),
        automaticallyImplyLeading: false,
        actions: [ new Padding(padding: EdgeInsets.only(left: 10,right: 10),child:new Icon(null)) ],
        leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => onBack()
        ),
      ),
      body: new SingleChildScrollView(
          child: new Form(
            child: new Column(
              children: <Widget>[

                  new Padding(child: new TypeAheadField(
                      textFieldConfiguration: TextFieldConfiguration(
                          controller: con.suggestedActivityController,
                          autofocus: true,
                          style: DefaultTextStyle.of(context).style.copyWith(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 15,height: 1),
                          decoration: InputDecoration(border: OutlineInputBorder())
                      ),
                      suggestionsBoxDecoration: SuggestionsBoxDecoration(elevation: 0.0),
                      autoFlipDirection: true,
                      itemBuilder: con.itemsBuilder,
                      onSuggestionSelected: (ActivitiesReceivedModel suggestion) { con.onSuggestionSelected(suggestion,showAlert); },
                      suggestionsCallback: con.onSuggestionsCallback,
                    ),
                    padding: const EdgeInsets.only(left: 10.0, right: 10.0, top: 20, bottom: 0),
                  ),

                  new Row(children: [
                    new Expanded(child: new Padding(child: new Container(
                        child: new Text(
                            "NFC_Activation".tr(), style: new TextStyle(color: Colors.white,
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
                        height: 60,
                        alignment: Alignment.center),
                      padding: const EdgeInsets.only(left: 10.0, right: 10.0, top: 20, bottom: 0),
                    ))
                  ]),

                  con.selectedActivityModel.key!.isNotEmpty ?
                    new Column(children: [

                        con.selectFamilyCardModel.hexId!.isNotEmpty ?
                          new Padding(child: new Card(color: Colors.white70,
                            child: new Column(children: [
                                new Row(children: [
                                  Expanded(child: new Padding(child:new Text('Card_Info'.tr(),textAlign: TextAlign.center,style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: ScreenUtil().setSp(20),),),
                                      padding: const EdgeInsets.only(left: 10.0, right: 10.0, top: 10, bottom: 0)))
                                ]),
                                new Row(children: [
                                  Expanded(child: new Padding(child:new Text('Hex_Id'.tr() + ': ' + con.selectFamilyCardModel.hexId!,textAlign: TextAlign.center,style: TextStyle(color: Colors.black,fontSize: ScreenUtil().setSp(20),),),
                                      padding: const EdgeInsets.only(left: 10.0, right: 10.0, top: 10, bottom: 0)))
                                ]),
                                new Row(children: [
                                  Expanded(child: new Padding(child: new RaisedButton(
                                    color: Color.fromRGBO(28, 29, 48, 1),
                                    onPressed:() { showConfAlert('Approve confirmation'.tr(),'Approve_Confirmation_Msg'.tr(),AlertType.warning); },//=> onLoginPressed(),
                                    child: Text('Approve'.tr(), style: TextStyle(color: Colors.white, fontSize: ScreenUtil().setSp(25))),
                                  ),padding: const EdgeInsets.only(left: 10.0, right: 10.0, top: 10, bottom: 5)))
                                ])
                              ]),
                            ), padding: const EdgeInsets.only(left: 10.0, right: 10.0, top: 10, bottom: 0))
                        : new SizedBox(),

                        new Row(children: [
                          new Expanded(child:
                              new Padding(child:
                                // new Screenshot(controller: con.screenshotCardController, child:
                                    new Card(color: Colors.white70,
                                      child: new Column(children: [
                                                new Row(children: [
                                                  new Expanded(child:new Padding(child: new Text('Card_Num'.tr() + ': '+ con.selectFamilyCardModel.sn.toString(),style: TextStyle(fontSize: ScreenUtil().setSp(15))), padding: const EdgeInsets.only(left: 10.0, right: 10.0, top: 10, bottom: 10))),
                                                ]),

                                                new Row(children: [
                                                  new Expanded(child:new Padding(child: new Text('Family_Key'.tr() + ': '+ con.selectedActivityModel.key!,style: TextStyle(fontSize: ScreenUtil().setSp(15))), padding: const EdgeInsets.only(left: 10.0, right: 10.0, top: 10, bottom: 10))),
                                                ]),

                                                new Row(children: [
                                                  new Expanded(child:new Padding(child: new Text('Info_1'.tr() + ': ' + con.selectedActivityModel.info1!,style: TextStyle(fontSize: ScreenUtil().setSp(15),fontWeight: FontWeight.bold)), padding: const EdgeInsets.only(left: 10.0, right: 10.0, top: 10, bottom: 10))),
                                                ]),

                                                new Row(children: [
                                                  new Expanded(child: new Padding(child:  new Text('Info_2'.tr() + ': ' + con.selectedActivityModel.info2!,style: TextStyle(fontSize: ScreenUtil().setSp(15),fontWeight: FontWeight.bold)), padding: const EdgeInsets.only(left: 10.0, right: 10.0, top: 10, bottom: 10))),
                                                ]),

                                                new Row(children: [
                                                  new Expanded(child:new Padding(child: new Text('Info 3'.tr() + ': ' + con.selectedActivityModel.info3!,style: TextStyle(fontSize: ScreenUtil().setSp(15),fontWeight: FontWeight.bold)), padding: const EdgeInsets.only(left: 10.0, right: 10.0, top: 10, bottom: 10))),
                                                ]),

                                                new Row(children: [
                                                  new Expanded(child:new Padding(child: new Text('Payment_USD'.tr() + ': ' + (con.selectedActivityModel.payment_USD!.toString() + 'USD'.tr()),style: TextStyle(fontSize: ScreenUtil().setSp(15),fontWeight: FontWeight.bold,color: Colors.green)), padding: const EdgeInsets.only(left: 10.0, right: 10.0, top: 10, bottom: 10))),
                                                ]),
                                          ])
                                    ),
                                // ),
                                padding: const EdgeInsets.only(left: 15.0, right: 15.0, top: 15, bottom: 0),)
                          ),
                        ]),

                        new Padding(child: new Row(children: [
                          new Expanded(child: TextFormField(
                            controller: con.commentController,
                            initialValue: con.selectedActivityModel.comments,
                            inputFormatters: [LengthLimitingTextInputFormatter(255)],
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'Leave_Comment'.tr(),
                            ),
                            maxLength: 255
                          ))
                        ]), padding: const EdgeInsets.only(left: 17.0, right: 17.0, top: 10, bottom: 0)),

                        new SizedBox(height: 50)

                    ]) : new SizedBox()
              ],
            ),
          )
      ),
    )
    );
  }
}
