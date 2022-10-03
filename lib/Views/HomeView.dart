import 'package:care_app/Controllers/HomeController.dart';
import 'package:care_app/Enums/Permissions.dart';
import 'package:care_app/Providers/UserProvider.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart' as easylocal;
import 'package:countup/countup.dart';

class HomeView extends StatefulWidget {
  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends StateMVC<HomeView> {

  //late AppStateMVC appState;
  late HomeController con;

  _HomeViewState() : super(HomeController()) {

    con = controller as HomeController;
  }

  void showConfAlert() async {
      await showDialog(context: context,
                  builder: (BuildContext context)
                  {
                      return AlertDialog(
                        title: new Text("Confirmation".tr(),style: TextStyle(fontWeight: FontWeight.bold,fontSize: ScreenUtil().setSp(20),color: Color.fromRGBO(28, 29, 48, 1)),textAlign: TextAlign.center),
                        content: new Text("Logout_msg".tr(),
                                          style: TextStyle(fontSize: ScreenUtil().setSp(18),fontWeight: FontWeight.w600),
                                          textAlign: TextAlign.center),
                        actions: <Widget>[
                          FlatButton(
                            color: Color.fromRGBO(227, 111, 30, 1),
                            child: new Text("YES".tr(),style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold)),
                            onPressed: () { con.logout(); },
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
    con.status_Msg = '';
    WidgetsBinding.instance?.addPostFrameCallback((_) async {
        await con.checkInternetConnection();
        await con.checkNfc();
        await con.initStatistics();
    });
  }

  @override
  void dispose() {
    con.status_Msg = '';
    con.isDisabled = false;
    con.nfcTurnedOff = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    ScreenUtil.init(context, designSize: Size(MediaQuery.of(context).size.width,
                                              MediaQuery.of(context).size.height),
                    minTextAdapt: true);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
          backgroundColor: Color.fromRGBO(227, 111, 30, 1),
          title: new Align(child: Text('E_Voucher'.tr()), alignment: Alignment.center),
          automaticallyImplyLeading:false,
          actions: [
            new PopupMenuButton(
                          enabled: !con.isDisabled,
                          itemBuilder: (context){
                            return [
                              PopupMenuItem<int>(
                                value: 0,
                                child: new Row(children:[
                                  new Padding(padding: EdgeInsets.only(right: 5,left: 5),child:Icon(Icons.translate,color: Colors.orange)),
                                  new Text('Translate'.tr())
                                ]),
                              ),
                              PopupMenuItem<int>(
                                value: 1,
                                child: new Row(children:[
                                  new Padding(padding: EdgeInsets.only(right: 5,left: 5),child:Icon(Icons.settings,color: Colors.orange)),
                                  new Text('Settings'.tr())
                                ]),
                              ),
                              PopupMenuItem<int>(
                                value: 2,
                                child: new Row(children:[
                                  new Padding(padding: EdgeInsets.only(right: 5,left: 5),child:Icon(Icons.logout,color: Colors.orange)),
                                  new Text('Logout'.tr())
                                ]),
                              ),
                            ];
                          },
                          onSelected:(value) {
                             switch(value) {
                               case 0:
                                 con.changeLanguage();
                                 break;
                               case 1:
                                 Navigator.pushReplacementNamed(context, '/Settings');
                                 break;
                               case 2:
                                 showConfAlert();
                                 break;
                             }
                          }
                      )
          ],
          leading: Icon(con.hasInternet ? Icons.wifi : Icons.wifi_off)
      ),
      body: WillPopScope(
            onWillPop: () async => false,
            child: new SingleChildScrollView(
                  child: new Form(
                    child: new Column(
                      children: <Widget>[
                        new Visibility(child: new Container(child:
                            new Padding(child:new Text("NFC_TURN_OFF".tr(), textAlign: TextAlign.center,
                                        style: TextStyle(color: Colors.white,fontWeight: FontWeight.w500,fontSize: ScreenUtil().setSp(18))),
                                        padding: const EdgeInsets.only(left: 15.0, right: 15.0, top: 15, bottom: 0)),
                                        color: Colors.red,height: 50,
                                        width: MediaQuery.of(context).size.width),
                            visible: con.nfcTurnedOff),
                        new SizedBox(height: 50,),

                        (UserProvider.currentRole == Permissions.CardReader.index ?
                          new Padding(padding: const EdgeInsets.only(left: 15.0, right: 15.0, top: 15, bottom: 0),
                            child :Container(
                              height: 50,
                              width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(
                                  color: Color.fromRGBO(227, 111, 30, 1)
                              ),
                              child: RaisedButton.icon(
                                color: Color.fromRGBO(28, 29, 48, 1),
                                onPressed: (con.isDisabled ? null : () { Navigator.pushReplacementNamed(context, '/ActivateCard'); }),//=> onLoginPressed(),
                                label: Text(
                                  'Activate_Card'.tr(),
                                  style: TextStyle(color: Colors.white, fontSize: ScreenUtil().setSp(25)),
                                ),
                                icon: Icon(Icons.credit_card,color: Colors.white),
                              ),
                            ),
                          ) : new SizedBox()),

                        //Meal check [ New Card ]
                        (UserProvider.currentRole == Permissions.MealCheck.index ?
                            new Padding(padding: const EdgeInsets.only(left: 15.0, right: 15.0, top: 15, bottom: 0),
                          child :Container(
                            height: 50,
                            width: MediaQuery.of(context).size.width,
                            decoration: BoxDecoration(
                                color: Color.fromRGBO(227, 111, 30, 1)
                            ),
                            child: RaisedButton.icon(
                              color: Color.fromRGBO(28, 29, 48, 1),
                              onPressed: (con.isDisabled ? null : () { Navigator.pushReplacementNamed(context, '/ApproveCard'); }),//=> onLoginPressed(),
                              label: Text(
                                'Approve_Card'.tr(),
                                style: TextStyle(color: Colors.white, fontSize: ScreenUtil().setSp(25)),
                              ),
                              icon: Icon(Icons.add_card,color: Colors.white),
                            ),
                          ),
                        )
                        : new SizedBox()),

                        (UserProvider.currentRole == Permissions.Distributioner.index ?
                            new Row(children: [
                              new Expanded(child: new Text('Vouchers',style: TextStyle(fontSize: ScreenUtil().setSp(15),fontFamily: "Fira Sans Condensed"),textAlign: TextAlign.center),flex: 1),
                              new Expanded(child: new Text('Received vouchers',style: TextStyle(fontSize: ScreenUtil().setSp(15),fontFamily: "Fira Sans Condensed"),textAlign: TextAlign.center),flex: 1),
                              new Expanded(child: new Text('Amount',style: TextStyle(fontSize: ScreenUtil().setSp(15),fontFamily: "Fira Sans Condensed"),textAlign: TextAlign.center),flex: 1),
                            ])
                        : new SizedBox()),

                      (UserProvider.currentRole == Permissions.Distributioner.index ?
                            new Row(children:[
                              new Expanded(child:Countup(
                                                begin: 0,
                                                end: con.vouchersCnt,
                                                duration: Duration(seconds: 3),
                                                separator: ',',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(fontSize: ScreenUtil().setSp(23)),
                                              ),
                                          ),
                              new Expanded(child:Countup(
                                                begin: 0,
                                                end: con.receivedVoucherCnt,
                                                duration: Duration(seconds: 3),
                                                separator: ',',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(fontSize: ScreenUtil().setSp(23)),
                                              ),
                                          ),
                              new Expanded(child:Countup(
                                                begin: 0,
                                                end: con.amountCnt,
                                                duration: Duration(seconds: 3),
                                                separator: ',',
                                                textAlign: TextAlign.center,
                                                suffix: ' \nUSD',
                                                style: TextStyle(fontSize: ScreenUtil().setSp(23)),
                                              ),
                                          ),
                            ])
                         : new SizedBox()),

                        //Distributioner [ Read card ]
                        (UserProvider.currentRole == Permissions.Distributioner.index ?
                            new Padding(padding: const EdgeInsets.only(left: 15.0, right: 15.0, top: 15, bottom: 0),
                              child :Container(
                                height: 50,
                                width: MediaQuery.of(context).size.width,
                                decoration: BoxDecoration(
                                    color: Color.fromRGBO(227, 111, 30, 1)
                                ),//borderRadius: BorderRadius.circular(20)),
                                child: RaisedButton.icon(
                                  color: Color.fromRGBO(28, 29, 48, 1),
                                  onPressed: (con.isDisabled ? null : () { Navigator.pushReplacementNamed(context, '/ReadCard'); }),//=> onLoginPressed(),
                                  label: Text(
                                    "Read_Card".tr(),
                                    style: TextStyle(color: Colors.white, fontSize: ScreenUtil().setSp(25)),
                                  ), icon: Icon(Icons.credit_card,color: Colors.white),
                                ),
                              ),
                            )
                        : new SizedBox()),

                        //Sync [ All data ]
                        new Padding(padding: const EdgeInsets.only(left: 15.0, right: 15.0, top: 15, bottom: 0),
                          child :Container(
                            height: 50,
                            width: MediaQuery.of(context).size.width,
                            decoration: BoxDecoration(
                                color: Color.fromRGBO(227, 111, 30, 1)
                            ),
                            child: RaisedButton.icon(
                              color: Color.fromRGBO(28, 29, 48, 1),
                              onPressed: (con.isDisabled ? null : con.onSyncPressed), //=> onLoginPressed(),
                              label: Text(
                                (con.isDisabled ? 'Syncing'.tr() : 'Sync'.tr()),
                                style: TextStyle(color: Colors.white, fontSize: ScreenUtil().setSp(25)),
                              ),
                              icon: Icon(Icons.sync,color: Colors.white),
                            ),
                          ),
                        ),

                        (con.status_Msg.isNotEmpty ?
                            new Padding(padding: const EdgeInsets.only(left: 15.0, right: 15.0, top: 15, bottom: 0),
                          child :Container(
                            alignment: Alignment.center,
                            width: MediaQuery.of(context).size.width,
                            child: new Text(con.status_Msg,style: TextStyle(fontSize: ScreenUtil().setSp(18)),),
                          ),
                        ) : new SizedBox()),
                         new SizedBox(height: 50)
                      ],
                    ),
                  )
              )
            ),
          );
  }
}
