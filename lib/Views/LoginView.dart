import 'package:care_app/Controllers/LoginController.dart';
import 'package:care_app/Views/Shared/Progress.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:easy_localization/easy_localization.dart' as easylocal;
import 'package:rflutter_alert/rflutter_alert.dart';

class LoginView extends StatefulWidget {
  @override
  _LoginViewState createState() => _LoginViewState();
}

class _LoginViewState extends StateMVC<LoginView> {

    final GlobalKey _screenKey = GlobalKey();
    late LoginController con;
    double _height = 0;

    void initHeight() {

      if (_height == 0.0) {
        _height = MediaQuery.of(context).size.height;
        if (_screenKey != null &&  _screenKey.currentContext != null) {
          var formContainer = _screenKey.currentContext
              ?.findRenderObject() as RenderBox;
          _height = formContainer.size.height;
        }
      }
    }

    _LoginViewState() : super(LoginController()) {
      con = controller as LoginController;
    }

    @override
    void initState() {
      super.initState();
      WidgetsBinding.instance?.addPostFrameCallback((_) async {
        initHeight();
        con.initDatabase();
      });
    }

    void onLoginPressed() async {
      await con.login(showLoginErrorAlert);
    }

    void showLoginErrorAlert(msg) {
        Alert(
          context: context, type: AlertType.error,
          title: 'Login_Error'.tr(), desc: msg,
          style: AlertStyle(
              titleStyle: new TextStyle(color: Colors.black, fontSize: 18),
              descStyle: new TextStyle(color: Colors.black, fontSize: 13)
          ),
          buttons: [
            DialogButton(
              child: Text('Close'.tr(), style: TextStyle(color: Colors.white, fontSize: 13)),
              onPressed: () => Navigator.pop(context), width: 120,
            )
          ]).show();
    }

    @override
    void dispose() {
      super.dispose();
    }

    @override
    Widget build(BuildContext context) {

      return Scaffold(backgroundColor: Colors.white,
                        appBar: AppBar(
                          backgroundColor: Color.fromRGBO(227, 111, 30, 1),
                          title: new Align(child: Text('Login'.tr()), alignment: Alignment.center),
                          actions: [
                              IconButton(onPressed: con.changeLanguage, icon: Icon(Icons.translate)),
                          ],
                          leading: new Padding(padding: EdgeInsets.only(left: 10,right: 10), child: new IconButton(onPressed: con.copy, icon: Icon(Icons.copy))),
                          //leading: Icon(Icons.key),
                          automaticallyImplyLeading:false
                        ),
                        body:WillPopScope(
                            onWillPop: () async => false,
                            //onWillPop: onBack,
                            child: new SingleChildScrollView(child: new Stack(children: [
                                                            new Container(
                                                                key: _screenKey,
                                                                child: new Form(
                                                                  key: con.formKey,
                                                                  child: new Column(
                                                                      children: <Widget>[
                                                                        Padding(
                                                                          padding: const EdgeInsets.only(top: 60.0),
                                                                          child: Center(
                                                                            child: Container(
                                                                                width: 200,
                                                                                height: 150,
                                                                                child: SvgPicture.asset(
                                                                                    'assets/images/logo.svg',
                                                                                    color: Color.fromRGBO(227, 111, 30, 1),
                                                                                    semanticsLabel: 'A care logo',

                                                                                )
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        Padding(
                                                                          padding: EdgeInsets.symmetric(horizontal: 15),
                                                                          child: TextFormField(
                                                                            controller: con.emailController,
                                                                            inputFormatters: [LengthLimitingTextInputFormatter(100)],
                                                                            keyboardType: TextInputType.emailAddress,
                                                                            decoration: InputDecoration(
                                                                                border: OutlineInputBorder(),
                                                                                labelText: 'Email'.tr(),
                                                                                hintText: 'Email'.tr()),
                                                                            validator: (String? value) => con.emailValidator(value),
                                                                          ),
                                                                        ),
                                                                        Padding(
                                                                          padding: const EdgeInsets.only(
                                                                              left: 15.0, right: 15.0, top: 15, bottom: 0),
                                                                          child: TextFormField(
                                                                              controller: con.passController,
                                                                              inputFormatters: [LengthLimitingTextInputFormatter(100)],
                                                                              keyboardType: TextInputType.visiblePassword,
                                                                              obscureText: true,
                                                                              decoration: InputDecoration(
                                                                                  border: OutlineInputBorder(),
                                                                                  labelText: 'Password'.tr(),
                                                                                  hintText: 'Password'.tr()),
                                                                              validator: (String? value) => con.passwordValidator(value) //(String? value) {
                                                                          ),
                                                                        ),
                                                                        Padding(padding: const EdgeInsets.only(left: 15.0, right: 15.0, top: 15, bottom: 0),
                                                                          child :Container(
                                                                            height: 50,
                                                                            width: MediaQuery.of(context).size.width,
                                                                            decoration: BoxDecoration(
                                                                                color: Color.fromRGBO(227, 111, 30, 1)
                                                                            ),//borderRadius: BorderRadius.circular(20)),
                                                                            child: RaisedButton(
                                                                              color: Color.fromRGBO(28, 29, 48, 1),
                                                                              onPressed: () => onLoginPressed(),
                                                                              child: Text(
                                                                                'Login'.tr(),
                                                                                style: TextStyle(color: Colors.white, fontSize: 25),
                                                                              ),
                                                                            ),
                                                                          ),),
                                                                      ]),
                                                                )
                                                            ),
                                                            new Container(child: Progress(con.progress, _height),)
                                                          ])
                                                       )
                     )
                );
    }
}
