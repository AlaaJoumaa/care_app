import 'dart:convert';
import 'dart:io';
import 'package:care_app/Enums/Permissions.dart';
import 'package:care_app/Models/ActivitiesReceivedCardModel.dart';
import 'package:care_app/Models/ActivitiesReceivedModel.dart';
import 'package:care_app/Models/FamilyCardModel.dart';
import 'package:care_app/Models/OptionModel.dart';
import 'package:care_app/Providers/UserProvider.dart';
import 'package:care_app/Utilities/ApiResponse.dart';
import 'package:care_app/Utilities/Settings.dart';
import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart';
import 'package:tuple/tuple.dart';

class DistributionProvider {

    String _readDistributionUrl = '/api/activitiesReceiveds/{userId}';
    String _putDistributionReceivedUrl = '/api/PutActivitiesReceiveds';

    //********* Sync operations ***********

    Future<Tuple2<List<ActivitiesReceivedModel>,int>> activitiesReceived(int userId,String token) async {

      var statusCode = 200;//Unauthorized access.
      List<ActivitiesReceivedModel> activitiesReceivedModels = [];
      try {
        final headers = {
                          HttpHeaders.contentTypeHeader: 'application/json',
                          HttpHeaders.authorizationHeader: 'Bearer ' + token
                        };
        var url = Uri.http(Settings.apiDomain, _readDistributionUrl.replaceAll("{userId}", userId.toString()));
        http.Response response = await http.get(url, headers: headers);
        if (response.statusCode == 200) {
          var dataList = jsonDecode(response.body) as List;
          activitiesReceivedModels = dataList.map((elem) => ActivitiesReceivedModel.fromJson(elem)).toList();
        }
        statusCode = response.statusCode;
      }
      catch(ex) { }
      return new Tuple2(activitiesReceivedModels,statusCode);
   }

    Future<List<ActivitiesReceivedModel>> getActivitiesReceivedModelsByIds(String ids,int permission, int userId, final Database db) async {
      List<ActivitiesReceivedModel> existedModels = [];
      try{
        String query = '';
        if(permission == Permissions.Distributioner.index) {
          //query = 'SELECT * FROM activitiesReceived WHERE id IN (' + ids + ') AND userid = ' + userId.toString();
          query = 'SELECT ${ActivitiesReceivedModel.selectWithoutImg} FROM activitiesReceived WHERE id IN (' + ids + ') AND userid = ' + userId.toString();
        }
        else {
          //query = 'SELECT * FROM activitiesReceived WHERE id IN (' + ids + ') AND mealUser = ' + userId.toString();
          query = 'SELECT ${ActivitiesReceivedModel.selectWithoutImg} FROM activitiesReceived WHERE id IN (' + ids + ') AND mealUser = ' + userId.toString();
        }
        List rows = await db.rawQuery(query);
        existedModels = rows.map((e) => ActivitiesReceivedModel.sqliteFromJson(e)).toList();
      }
      catch(ex) {  }
      return existedModels;
    }

    Future<int> saveReceivedModelLocally(List<ActivitiesReceivedModel> existedModels,
                                         ActivitiesReceivedModel activitiesReceivedModel,
                                         int permission,
                                         final Database db) async {
      var rowsAffected = 0;
      try {
        if (existedModels.any((element) =>
        element.id == activitiesReceivedModel.id)) {
          rowsAffected = 1;
        }
        else {
          rowsAffected = await db.insert(
              'activitiesReceived', activitiesReceivedModel.toJson());
        }
      }
      catch (ex) {
        var x = 5;
      }
      return rowsAffected;
    }

    Future<int> getCountModelsLocally(int userid,int permission,final Database db) async {
      int count = 0;
      try {
        String query ='';
        if(permission == Permissions.MealCheck.index) {
          query = 'SELECT COUNT(*) as cnt FROM activitiesReceived WHERE mealChecked is not null AND mealCheckedSend is null AND mealUser =' + userid.toString();
        }
        else {
          query = 'SELECT COUNT(*) as cnt FROM activitiesReceived WHERE received = 1 AND datesend is null AND userid =' + userid.toString();
        }
        List rows = await db.rawQuery(query);
        count = rows.map((elem) => elem['cnt'] as int).first;
      }
      catch (ex) { }
      return count;
    }

    Future<List<ActivitiesReceivedModel>> getReceivedModelsLocally(int userid,int permission,int from, int to,final Database db) async {
      List<ActivitiesReceivedModel> models = [];
      try {
        String query ='';
        if(permission == Permissions.MealCheck.index) {
          query = 'SELECT * FROM activitiesReceived WHERE mealChecked is not null AND mealCheckedSend is null AND mealUser =' + userid.toString() + ' LIMIT ${to} OFFSET ${from}';
        }
        else {
          query = 'SELECT * FROM activitiesReceived WHERE received = 1 AND datesend is null AND userid =' + userid.toString() + ' LIMIT ${to} OFFSET ${from}';
        }
        List rows = await db.rawQuery(query);
        models = rows.map((elem) => ActivitiesReceivedModel.sqliteFromJson(elem)).toList();
      }
      catch (ex) { }
      return models;
    }

    Future<Tuple2<ApiResponse,int>> putReceivedModels(List<OptionModel> options,int permission, String token) async {
      var statusCode = 200;//Unauthorized access.
      var apiResponse = new ApiResponse();
      try {
        final headers = {
          HttpHeaders.contentTypeHeader: 'application/json',
          HttpHeaders.authorizationHeader: 'Bearer ' + token
        };
        var url = Uri.http(Settings.apiDomain, _putDistributionReceivedUrl);
        http.Response response = await http.put(url, headers: headers,body: jsonEncode(options),encoding: Encoding.getByName('utf-8'));
        if (response.statusCode == 200) {
          var responseMap = jsonDecode(response.body) as Map<String, dynamic>;
          apiResponse =  ApiResponse.fromJson(responseMap);
        }
        statusCode = response.statusCode;
      }
      catch(ex) { }
      return new Tuple2(apiResponse,statusCode);
    }

    Future<int> sendActivitiesReceivedLocally(ActivitiesReceivedModel activitiesReceivedModel,int permission,final Database db) async {
      var rowsAffected = 0;
      try {
          if(permission == Permissions.MealCheck.index) {
            activitiesReceivedModel.mealCheckedSend = DateTime.now().toIso8601String();
          }
          else {
            activitiesReceivedModel.datesend = DateTime.now().toIso8601String();
          }
          rowsAffected = await db.update('activitiesReceived',
                                          activitiesReceivedModel.toJson(),
                                          where: "id= ?",
                                          whereArgs: [activitiesReceivedModel.id]);
      }
      catch (ex) { }
      return rowsAffected;
    }

    //********* New card operations ***********

    Future<List<ActivitiesReceivedModel>> search(ActivitiesReceivedModel activitiesReceivedModel, int userId,int permission,final Database db) async {
      List<ActivitiesReceivedModel> models = [];
      try {
        var familyKey = activitiesReceivedModel.key;
        var name = activitiesReceivedModel.info1;
        var identity = activitiesReceivedModel.info2;
        var userCondition = (permission == Permissions.MealCheck.index ? (" mealUser = " + userId.toString() + " AND mealChecked is null") : (" userid = " +  userId.toString() + " AND (received is null OR received = 0)"));
        List rows = await db.rawQuery("SELECT * FROM activitiesReceived " +
                                      " WHERE ([key] like '%$familyKey%' " +
                                      " OR info1 like '%$name%' " +
                                      " OR info2 like '%$identity%')" +
                                      " AND " + userCondition);
        models = rows.map((elem) => ActivitiesReceivedModel.sqliteFromJson(elem)).toList();
      }
      catch (ex) { }
      return models;
    }

    Future approve(FamilyCardModel familyCard,String comments, int userId, void Function(int) callback, final Database db,final bool byName) async {
      await db.transaction((txn) async {
        //1- Get the latest activity received id not received for this family.
        var activityReceivedLst = await txn.query("activitiesReceived",
                                                  where: ("[key] = ? AND mealUser = " + userId.toString() + " AND mealChecked is null"),
                                                  whereArgs: [familyCard.familyKey],
                                                  limit: 1);
        if (activityReceivedLst.length > 0) {
          var activityReceived = ActivitiesReceivedModel.sqliteFromJson(activityReceivedLst.first);
          var affectedRows = 0;
          var familyCardExists = [];
          if(!byName) {//2- Check the Card HexId is existed.
            familyCardExists = await txn.query('familyCards', where: 'hexId = ?', whereArgs: [familyCard.hexId]);
          }
          else {//3- Check the Card familyKey is existed.
            familyCardExists = await txn.query('familyCards', where: 'familyKey = ?', whereArgs: [familyCard.familyKey]);
          }
          //
          if (familyCardExists.length == 0) {//The family card hasn't been added.
            callback(-5);
            return;
          }
          else {//The family card has been added.
            familyCard = FamilyCardModel.fromJson(familyCardExists.first);
            activityReceived.mealChecked = DateTime.now().toIso8601String();
            activityReceived.comments = comments;
            affectedRows = await txn.update(
                "activitiesReceived", activityReceived.toJson(),
                where: "id= ?", whereArgs: [activityReceived.id]);
            if (affectedRows > 0) { //Success.
              txn.batch().commit();
              callback(1);
            }
            else {
              callback(-1);
            }
          }
        }
      });
    }

    Future<ActivitiesReceivedModel?> getActivityReceived(String familykey, int userId, int permission, final Database db) async {

        //1- Search the activities received by the family key.
        var queryCondition = (permission == Permissions.MealCheck.index ?  ("mealUser = " + userId.toString() + " AND mealChecked is null") : "userid = " + userId.toString());
        var activityReceivedLst = await db.query("activitiesReceived",
                                                 where: "[key] = ? AND (received = 0 OR received is null) AND " + queryCondition,
                                                 whereArgs: [familykey], limit: 1);
        if (activityReceivedLst.length > 0) {
          return ActivitiesReceivedModel.sqliteFromJson(activityReceivedLst.first);
        }
        return null;
    }

    Future<ActivitiesReceivedModel?> getActivityByFamilyKey(String familykey, int userId, int permission, final Database db) async {

      var queryCondition = (permission == Permissions.MealCheck.index ? "mealUser = " + userId.toString() : "userid = " + userId.toString());
      var activityReceivedLst = await db.rawQuery("SELECT * FROM activitiesReceived WHERE [key] = '" + familykey + "' AND "+ queryCondition);
      if (activityReceivedLst.length > 0) {
        return ActivitiesReceivedModel.sqliteFromJson(activityReceivedLst.first);
      }
      return null;
    }

    Future<bool> receive(String familykey, ActivitiesReceivedModel activityReceived, int userId, final Database db) async {
        activityReceived.received = true;
        activityReceived.distibution_date = DateTime.now().toIso8601String();
        //2- Receive the activity received.
        var rowsAffected = await db.update("activitiesReceived", activityReceived.toJson(),
                                            where: "[id] = ? AND (received = 0 OR received is null) AND userid = " + userId.toString(),
                                            whereArgs: [activityReceived.id]);
        if (rowsAffected > 0) {
          //Success.
          return true;
        }
        return false;
    }

    Future<void> removeUnReceivedActivitiesLocally(int userId, int permission, final Database db) async {

      var ars_condition = '';
      if(permission == Permissions.MealCheck.index) {
        ars_condition = 'mealChecked is null AND mealUser = ?';
      }
      else {
        ars_condition = "received = 0 AND userid = ?";
      }
      var ars = await db.query("activitiesReceived",where: ars_condition, whereArgs: [userId]);
      await db.transaction((txn) async {
            for(var i = 0; i < ars.length;i++) {
              var arg = ActivitiesReceivedModel.sqliteFromJson(ars[i]);
              await txn.delete("activityReceivedCards",where: "familyCard_Id = ?", whereArgs: [ arg.card_Id ]);
              await txn.delete("familyCards",where: "id = ?", whereArgs: [ arg.card_Id ]);
            }
            await txn.delete("activitiesReceived",where: ars_condition, whereArgs: [userId]);
            txn.batch().commit();
        });
    }

    void removeRangeCardsLocally(int min,int max,int userId, final Database db) async {
      await db.rawDelete("DELETE FROM familyCards WHERE sn >= $min AND sn <= $max");
    }

    Future<List<ActivitiesReceivedModel>> getAllReceivedModelsLocally(int userid,int permission,final Database db) async {
      List<ActivitiesReceivedModel> result = [];
      try {
        String query ='';
        if(permission == Permissions.MealCheck.index) {
          /*STRFTIME('%d/%m/%Y', Date(distibution_date)) = STRFTIME('%d/%m/%Y', Date('now')) AND*/
          query = "SELECT " + ActivitiesReceivedModel.selectWithoutImg + " FROM activitiesReceived WHERE mealUser =" + userid.toString();
        }
        else {
          /*STRFTIME('%d/%m/%Y', Date(distibution_date)) = STRFTIME('%d/%m/%Y', Date('now')) AND*/
          query = "SELECT " + ActivitiesReceivedModel.selectWithoutImg + " FROM activitiesReceived WHERE userid =" + userid.toString();
        }
        List rows = await db.rawQuery(query);
        result =  rows.map((elem) => ActivitiesReceivedModel.sqliteFromJson(elem)).toList();
      }
      catch (ex) { }
      return result;
    }

    Future<List<ActivitiesReceivedModel>> getUnReceivedModelsLocally(int userid,int permission,final Database db) async {
      List<ActivitiesReceivedModel> result = [];
      try {
        String query ='';
        if(permission == Permissions.MealCheck.index) {
          query = "SELECT * FROM activitiesReceived WHERE mealUser =" + userid.toString() + " AND received = 0";
        }
        else {
          query = "SELECT * FROM activitiesReceived WHERE userid =" + userid.toString() + " AND received = 0";
        }
        List rows = await db.rawQuery(query);
        result =  rows.map((elem) => ActivitiesReceivedModel.sqliteFromJson(elem)).toList();
      }
      catch (ex) { }
      return result;
    }

}