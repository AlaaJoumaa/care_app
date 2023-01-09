import 'package:flutter/material.dart';
import 'package:care_app/Views/ApproveCardView.dart';
import 'package:care_app/Views/HomeView.dart';
import 'package:care_app/Views/ReadCardView.dart';
import 'package:care_app/Views/SettingsView.dart';
import 'package:care_app/Views/LoginView.dart';
import 'package:easy_localization/easy_localization.dart' as easylocal;
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'Views/ActivateCardView.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(Phoenix(child: easylocal.EasyLocalization(
                 supportedLocales: [Locale('en', 'US'), Locale('ar', 'SA')],
                 path: 'assets/translations',
                 fallbackLocale: Locale('ar', 'SA'),
                 saveLocale: true,
                 startLocale: Locale('ar', 'SA'),
                 child: const MyApp())
                )
        );
}

class MyApp extends StatelessWidget {

  static String currentLang = "ar";
  const MyApp({Key? key}) : super(key: key);

  static void _initLanguage(BuildContext context) {
    var local = context.locale;
    if (local != null) {
      MyApp.currentLang = local.languageCode;
    }
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    _initLanguage(context);
    return MaterialApp(
        // localizationsDelegates: [
        //    GlobalMaterialLocalizations.delegate,
        //    GlobalWidgetsLocalizations.delegate,
        //    GlobalCupertinoLocalizations.delegate
        // ],
        localizationsDelegates:context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,
        title: 'E_Voucher'.tr(),
        theme: ThemeData(fontFamily: (MyApp.currentLang == "en" ? "Fira Sans Condensed" : "Questv1")),
        routes: {
          '/':(BuildContext context) => LoginView(),
          '/Home':(BuildContext context) => HomeView(),
          '/ActivateCard': (BuildContext context) => ActivateCardView(),
          '/ApproveCard':(BuildContext context) => ApproveCardView(),
          '/ReadCard':(BuildContext context) => ReadCardView(),
          '/Settings':(BuildContext context) => SettingsView(),
        }
    );
  }
}