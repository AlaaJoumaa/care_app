import 'dart:async';
import 'package:care_app/Controllers/SettingsController.dart';
import 'package:care_app/Enums/Permissions.dart';
import 'package:care_app/Providers/UserProvider.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart' as easylocal;

class SettingsView extends StatefulWidget {
  @override
  _SettingsViewState createState() => _SettingsViewState();
}

class _SettingsViewState extends StateMVC<SettingsView> {

  //late AppStateMVC appState;
  late SettingsController con;

  _SettingsViewState() : super(SettingsController()) {
    con = controller as SettingsController;
  }

  void showConfAlert(int type) async {

    var msg = '';
    var call = null;
    switch(type){
      case 1:
        msg = 'remove_msg'.tr();
        call = con.removeUnReceivedActivities;
        break;
      case 2:
        msg = 'remove_cards_msg'.tr();
        call = con.removeRangeCards;
        break;
    }
    await showDialog(context: context,
        builder: (BuildContext context)
        {
          return AlertDialog(
            title: new Text("Confirmation".tr(),
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20,
                             color: Color.fromRGBO(28, 29, 48, 1)),
                             textAlign: TextAlign.center),
            content: new Text(msg, style: TextStyle(fontSize: 18,fontWeight: FontWeight.w600),
                              textAlign: TextAlign.center),
            actions: <Widget>[
              FlatButton(
                color: Color.fromRGBO(227, 111, 30, 1),
                child: new Text("YES".tr(),style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold)),
                onPressed: () { call(); Navigator.of(context).pop(); },
              ),
              FlatButton(
                color: Color.fromRGBO(244, 178, 35, 1),
                child: new Text("NO".tr(),style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold)),
                onPressed: () { Navigator.of(context).pop(); },
              ),
            ],
          );
        });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {

    });
  }

  Future<bool> onBack() async {
    await Navigator.pushReplacementNamed(context, '/Home');
    return true;
  }

  @override
  void dispose() {
    con.showRemoveActivitiesProgress = false;
    con.showRemoveCardsProgress = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    // ScreenUtil.init(
    //     BoxConstraints(
    //         maxWidth: MediaQuery.of(context).size.width,
    //         maxHeight: MediaQuery.of(context).size.height),
    //     designSize: Size(MediaQuery.of(context).size.width, MediaQuery.of(context).size.height),
    //     context: context,
    //     minTextAdapt: true,
    //     orientation: Orientation.portrait);
    ScreenUtil.init(context,designSize: Size(MediaQuery.of(context).size.width, MediaQuery.of(context).size.height),
        minTextAdapt: true);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
          backgroundColor: Color.fromRGBO(227, 111, 30, 1),
          title: new Align(child: Text('Settings'.tr()), alignment: Alignment.center),
          automaticallyImplyLeading:false,
          actions: [ new Padding(padding: EdgeInsets.only(left: 10,right: 10),child:new Icon(null)) ],
          leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => onBack()
          ),
      ),
      body: WillPopScope(
          onWillPop: onBack,
          child: new SingleChildScrollView(
              child: new Form(
                child: new Column(
                  children: <Widget>[
                      new InkWell(child:
                          (UserProvider.currentRole == Permissions.Distributioner.index ?
                              new Row(children: [
                                new Visibility(child: new Padding(child: new CircularProgressIndicator(valueColor:AlwaysStoppedAnimation<Color>(Colors.black), strokeWidth: 2),padding: EdgeInsets.all(10)),visible: con.showRemoveActivitiesProgress,),
                                new Expanded(child:
                                      new Padding(padding: EdgeInsets.all(0),
                                          child: new Container(child: new Center(child:new Text('Remove unreceived activities'.tr(),
                                                               style: TextStyle(fontSize: ScreenUtil().setSp(16),
                                                               fontWeight: FontWeight.bold,
                                                               color: Color.fromRGBO(28, 29, 48, 1)))),
                                                               height: 100),
                                      ), flex: 6),
                                new Expanded(child: Icon(Icons.recycling,size: 50,color: Color.fromRGBO(28, 29, 48, 1))),
                              ])
                          : new SizedBox()),
                          onTap:() { showConfAlert(1); },
                      ),

                      new InkWell(child:
                        (UserProvider.currentRole == Permissions.CardReader.index ?
                        new Row(children: [
                          new Visibility(child: new Padding(child: new CircularProgressIndicator(valueColor:AlwaysStoppedAnimation<Color>(Colors.black), strokeWidth: 2),padding: EdgeInsets.all(10)),visible: con.showRemoveCardsProgress,),
                          new Expanded(child:
                          new Padding(padding: EdgeInsets.all(0),
                            child: new Container(child: new Center(child:new Text('remove_range_cards'.tr(),
                                style: TextStyle(fontSize: ScreenUtil().setSp(16),
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromRGBO(28, 29, 48, 1)))),
                                height: 100),
                          ), flex: 6),
                          new Expanded(child: Icon(Icons.recycling,size: 50,color: Color.fromRGBO(28, 29, 48, 1))),
                        ]) : new SizedBox()),
                        onTap:() { showConfAlert(2); },
                      ),
                     //const Divider(height: 0,thickness: 1,indent: 0,endIndent: 0,color: Colors.black,),
                  ],
                ),
              )
          )
      ),
    );
  }
}
