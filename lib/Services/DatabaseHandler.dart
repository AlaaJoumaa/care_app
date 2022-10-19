import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHandler {

  static Future<Database> initializeDB() async {
    String path = await getDatabasesPath();
    return await openDatabase(
      join(path, 'e_voucher.db'),
      // onConfigure: (database) async {
      // },
      //onDowngrade: ,
      //onOpen: ,
      // onUpgrade: (database, oldVersion, newVersion) async {
      // },
      onCreate: (database, version) async {
        await database.execute("CREATE TABLE IF NOT EXISTS activitiesReceived" +
                               "(id INTEGER NOT NULL," +
                                "activityId INTEGER," +
                                "key TEXT NOT NULL," +
                                "distibution_date NVARCHAR(50)," +
                                "userid INTEGER," +
                                "received BOOLEAN," +
                                "isSend BOOLEAN, " +
                                "info1 TEXT," +
                                "info2 TEXT, " +
                                "info3 TEXT," +
                                "payment_USD INTEGER," +
                                "comments NVARCHAR(255),"
                                "datesend NVARCHAR(50)," +
                                "card_Id INTEGER," +
                                "mealUser INTEGER," +
                                "mealChecked NVARCHAR(50)," +
                                "mealCheckedSend NVARCHAR(50)," +
                                "signImage TEXT," +
                                "delegatedName NVARCHAR(50)," +
                                "delegatedId NVARCHAR(50)"
                                ")");
        await database.execute("CREATE TABLE IF NOT EXISTS activityReceivedCards" +
                              "(activityReceived_Id INTEGER NOT NULL," +
                               "familyCard_Id INTEGER," +
                               "createdDate DATE)");
        await database.execute("CREATE TABLE IF NOT EXISTS familyCards" +
                               "(id INTEGER NOT NULL," +
                                "hexId NVARCHAR(50)," +
                                "familyKey NVARCHAR(30)," +
                                "status INTEGER," +
                                "createdDate DATE," +
                                "addBy INTEGER," +
                                "sn INTEGER NOT NULL," +
                                "notice NVARCHAR(500))");
        await database.execute("CREATE TABLE IF NOT EXISTS settings " +
                               "(id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, " +
                                "key NVARCHAR(100), " +
                                "value TEXT)");
        // await database.execute("CREATE TABLE IF NOT EXISTS logs " +
        //                        "(id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL," +
        //                         "type INTEGER," +
        //                         "value NVARCHAR(4000)," +
        //                         "createdDate DATE)");
      },
      version: 1,
    );
  }
}