import 'dart:async';
import 'package:care_app/Controllers/ActivateCardController.dart';
import 'package:care_app/Models/ActivitiesReceivedModel.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart' as easylocal;


class ActivateCardView extends StatefulWidget {
  @override
  _ActivateCardViewState createState() => _ActivateCardViewState();
}

class _ActivateCardViewState extends StateMVC<ActivateCardView> {

  bool alertOpened = false;
  late ActivateCardController con;

  _ActivateCardViewState() : super(ActivateCardController()) {
    con = controller as ActivateCardController;
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      con.initLastSN();
      con.readNFCData();
      setState(() { con.resultColor = Colors.green; });
    });
  }

  Future<bool> onBack() async {
    await Navigator.pushReplacementNamed(context, '/Home');
    return true;
  }

  @override
  void dispose() {
    con.result = '';
    con.resultColor = Colors.red;
    con.SN = 0;
    con.range = [];
    con.index = 0;
    con.exeeded = false;
    con.SN_Lst = '';
    con.stopNFC();
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
            title: new Align(child: Text('Activate_Card'.tr()), alignment: Alignment.center),
            automaticallyImplyLeading:false,
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
                    new Row(children: [
                      new Expanded(child:
                        new Padding(child: new Container(
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
                        )
                      )
                    ]),

                    new Row(children: [
                      new Expanded(child: new SizedBox(),flex: 1,),

                      new Expanded(child:
                          new Padding(child: new Container(
                              child: new FlatButton(onPressed: con.undoSN, child: new Icon(Icons.arrow_back,color: Colors.white,),height: 60),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Color.fromRGBO(28, 29, 48, 1),
                                boxShadow: [
                                  BoxShadow(color: Color.fromRGBO(227, 111, 30, 1), spreadRadius: 3),
                                ],
                              ),
                              height: 60,
                              width: 60,
                              alignment: Alignment.center),
                            padding: const EdgeInsets.only(top: 20),
                      ),flex: 1),

                      new Expanded(child:
                        new Padding(child: new Container(
                            child: new Text(con.SN.toString(), style: new TextStyle(color: Colors.white,
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
                            width: 60,
                            alignment: Alignment.center),
                          padding: const EdgeInsets.only(left: 10.0, right: 10.0, top: 20, bottom: 0),
                        ),flex: 2,
                      ),

                      new Expanded(child:
                        new Padding(child: new Container(
                            child: new FlatButton(onPressed: con.skipSN, child: new Icon(Icons.arrow_forward,color: Colors.white,),height: 60),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Color.fromRGBO(28, 29, 48, 1),
                              boxShadow: [
                                BoxShadow(color: Color.fromRGBO(227, 111, 30, 1), spreadRadius: 3),
                              ],
                            ),
                            height: 60,
                            width: 60,
                            alignment: Alignment.center),
                          padding: const EdgeInsets.only(top: 20),
                        ),flex: 1),

                      new Expanded(child: new SizedBox(),flex: 1,)
                    ]),

                    new Row(children: [
                      new Expanded(child:new Padding(child: new Container(
                          child: new Column(children: [
                              new Row(children: [
                                  new Expanded(child:
                                      new Padding(child:new Text(con.result,
                                      style: new TextStyle(color: con.resultColor,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                      textAlign: TextAlign.center),padding: EdgeInsets.all(5))
                                  ),
                              ],),

                              new Row(children: [
                                  new Expanded(child:
                                      new Padding(child:new Text(con.SN_Lst.toString(),
                                      style: new TextStyle(color: Colors.black,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                      textAlign: TextAlign.center),padding: EdgeInsets.all(5))
                                  ),
                              ])
                          ]),
                          //height: MediaQuery.of(context).size.height/2,
                          width: 50,
                          alignment: Alignment.center),padding: EdgeInsets.all(15),))
                    ]),
                  ],
                ),
              )
          ),
        )
    );
  }
}
