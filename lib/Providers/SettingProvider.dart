import 'package:care_app/Enums/SettingKeys.dart';
import 'package:care_app/Models/SettingModel.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';


class SettingProvider {

  Future<bool> add(SettingModel setting,final Database db) async {
    var affectedRows = await db.insert("settings", setting.toJson());
    if (affectedRows > 0) {
      return true;
    }
    return false;
  }

  Future<SettingModel?> read(SettingKeys settingKey,final Database db) async {
    var rows = await db.query("settings", where: "key= ?", whereArgs: [describeEnum(settingKey)]);
    if(rows.length > 0) {
      var settingModel = SettingModel.fromJson(rows.first);
      return settingModel;
    }
    return null;
  }

  Future<int> update(SettingKeys settingKey, SettingModel settingModel, final Database db) async {
    var rows = await db.query("settings", where: "key= ?", whereArgs: [describeEnum(settingKey)]);
    if (rows.length > 0) {
      var rowsAffected = await db.update("settings", settingModel.toJson(),
                                          where: "key= ?",
                                          whereArgs: [describeEnum(settingKey)]);
      return rowsAffected;
    }
    return 0;
  }
}