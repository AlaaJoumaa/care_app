import 'package:care_app/Providers/DistributionProvider.dart';
import 'package:care_app/Providers/UserProvider.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:sqflite/sqflite.dart';
import 'package:care_app/Services/DatabaseHandler.dart';

class SettingsController extends ControllerMVC {

  factory SettingsController([StateMVC? state]) => _this ??= SettingsController._(state);

  SettingsController._(StateMVC? state) :
        _distributionProvider = new DistributionProvider(),
        super(state);

  DistributionProvider _distributionProvider;
  bool showRemoveActivitiesProgress = false;
  bool showRemoveCardsProgress = false;
  static SettingsController? _this;


  void removeUnReceivedActivities() async {
    try {
      setState(() { showRemoveActivitiesProgress = true; });
      final Database db = await DatabaseHandler.initializeDB();
      _distributionProvider.removeUnReceivedActivitiesLocally(UserProvider.currentUser!.id, db);
      setState(() { showRemoveActivitiesProgress = false; });
    }
    catch(ex) { }
  }

  void removeRangeCards() async {
    try {
      setState(() { showRemoveCardsProgress = true; });
      final Database db = await DatabaseHandler.initializeDB();
      _distributionProvider.removeRangeCardsLocally(UserProvider.currentRange!.min,UserProvider.currentRange!.max,UserProvider.currentUser!.id, db);
      setState(() { showRemoveCardsProgress = false; });
    }
    catch(ex) { }
  }
}