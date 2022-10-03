import 'dart:convert';
import 'dart:io';
import 'package:care_app/Enums/FamilyCardStatuses.dart';
import 'package:care_app/Models/ActivitiesReceivedCardModel.dart';
import 'package:care_app/Models/FamilyCardModel.dart';
import 'package:care_app/Utilities/ApiResponse.dart';
import 'package:care_app/Utilities/Settings.dart';
import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart';
import 'package:tuple/tuple.dart';

class FamilyCardProvider {

  String _postFamilyCardUrl = '/api/postFamilyCards';
  String _readfamilyCardsUrl = '/api/FamilyCards';

  //********* Family cards ***********

  Future<Tuple2<List<FamilyCardModel>,int>> familyCards(int userId, String token) async {
    var statusCode=  200;
    List<FamilyCardModel> familyCardModels = [];
    try {
      final headers = {
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.authorizationHeader: 'Bearer ' + token,
        'userId': userId.toString()
      };
      var url = Uri.http(Settings.apiDomain, _readfamilyCardsUrl);
      http.Response response = await http.post(url, headers: headers);
      if (response.statusCode == 200) {
        var dataList = jsonDecode(response.body) as List;
        familyCardModels = dataList.map((elem) {
          return FamilyCardModel.fromJson(elem)
            ..addBy = userId;
        }).toList();
      }
      statusCode = response.statusCode;
    }
    catch (ex) {}
    return new Tuple2(familyCardModels,statusCode);
  }

  Future saveFamilyCardModelsLocally(List<FamilyCardModel> existedModels,
      FamilyCardModel familyCardModel,void Function(int rowsAffected) callBack,final Database db) async {
    var rowsAffected = 0;
    try {
      if(existedModels.any((element) => element.id == familyCardModel.id)) {
        rowsAffected = 1;
      }
      else {
        await db.transaction((txn) async {
            rowsAffected =
            await txn.insert('familyCards', familyCardModel.toJson());
            familyCardModel.activityReceivedCards?.forEach((element) async {
              List rows = await txn.rawQuery(
                  'SELECT * FROM activityReceivedCards WHERE activityReceived_Id= ' +
                      element.activityReceived_Id.toString());
              if (rows.length == 0) {
                rowsAffected +=
                await txn.insert("activityReceivedCards", element.toJson());
              }
              txn.batch();
            });
            callBack(rowsAffected);
        });
      }
    }
    catch (ex) { }
  }

  Future<List<FamilyCardModel>> getFamilyCardModelsByIds(String ids,final Database db) async {
    List<FamilyCardModel> existedModels = [];
    try {
      List rows = await db.rawQuery('SELECT * FROM familyCards WHERE id IN (' + ids + ')');
      existedModels  = rows.map((e) => FamilyCardModel.fromJson(e)).toList();
    }
    catch(ex) { }
    return existedModels;
  }

  Future<List<FamilyCardModel>> getFamilyCardModelsByHexId(String hexId,final Database db) async {
    List<FamilyCardModel> existedModels = [];
    try {
      List rows = await db.rawQuery("SELECT * FROM familyCards WHERE hexId IN ('$hexId')");
      existedModels  = rows.map((e) => FamilyCardModel.fromJson(e)).toList();
    }
    catch(ex) { }
    return existedModels;
  }

  Future<List<FamilyCardModel>> getFamilyCardModelsLocally(int userid,int permission,final Database db) async {
    List<FamilyCardModel> models = [];
    try {
      List rows = await db.rawQuery("SELECT * FROM familyCards WHERE status=" + FamilyCardStatuses.New.index.toString() +
                                    " AND addBy = $userid");
      List nestedRows = await db.rawQuery("SELECT * FROM familyCards fc inner join activityReceivedCards arc "
                                          " on fc.id = arc.familyCard_Id WHERE " +
                                          " fc.status =" + FamilyCardStatuses.New.index.toString() +
                                          " AND fc.addBy = $userid");
      var receivedModels = nestedRows.map((e) => ActivitiesReceivedCardModel.fromJson(e)).toList();
      for (var i = 0; i < rows.length; i++) {
        var elemItem = Map.of(rows[i]);
        elemItem['status'] = FamilyCardStatuses.Active.index;
        //Family card items.
        var familyCard = FamilyCardModel.fromJson(elemItem.map((key, value) =>
                                                  MapEntry(key as String, value as dynamic)));
        //Activities received card items.
        receivedModels.map((elem) {
           if(elem.familyCard_Id == familyCard.id) { familyCard.activityReceivedCards?.add(elem); }
           return elem;
        }).toList();
        //Add family card model.
        models.add(familyCard);
      }
    }
    catch (ex) { }
    return models;
  }

  Future<int> getLastSNLocally(int userid,int permission,final Database db) async {
    try {
      List rows = await db.rawQuery("SELECT IFNULL(Max(SN),0) AS LastSN FROM familyCards WHERE addBy = $userid");
      return (rows.first['LastSN'] as int);
    }
    catch(ex) {  }
    return 0;
  }

  Future<Tuple2<ApiResponse,int>> postFamilyCardModels(List<FamilyCardModel> familyCards,int permission,
      String token) async {
    var statusCode=  200;
    var apiResponse = new ApiResponse();
    try {
      final headers = {
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.authorizationHeader: 'Bearer ' + token
      };
      var url = Uri.http(Settings.apiDomain, _postFamilyCardUrl);
      //Get [ activityReceivedCards ].
      List<ActivitiesReceivedCardModel> receivedCards = [];
      for (var fc in familyCards) {
        for(var arc in fc.activityReceivedCards!){
          receivedCards.add(arc);
        }
      }
      http.Response response = await http.post(url, headers: headers,
                                                    body: jsonEncode({ 'familyCards': familyCards,'activityReceivedCards': receivedCards}),
                                                    encoding: Encoding.getByName('utf-8'));
      if (response.statusCode == 200) {
        var responseMap = jsonDecode(response.body) as Map<String, dynamic>;
        apiResponse = ApiResponse.fromJson(responseMap);
      }
      statusCode = response.statusCode;
      return new Tuple2(apiResponse,statusCode);
    }
    catch (ex) {}
    return new Tuple2(apiResponse,statusCode);
  }

  Future<int> activateFamilyCardLocally(FamilyCardModel familyCardModel,int permission,final Database db) async {
    var rowsAffected = 0;
    try {
      familyCardModel.status = FamilyCardStatuses.Active.index;
      rowsAffected = await db.update('familyCards', familyCardModel.toJson(),where: "id= ?",whereArgs: [familyCardModel.id]);
    }
    catch (ex) { }
    return rowsAffected;
  }

  Future<int> addFamilyCardLocally(FamilyCardModel familyCardModel,int permission,final Database db) async {
    var rowsAffected = 0;
    try {
      familyCardModel.status = FamilyCardStatuses.New.index;
      rowsAffected = await db.insert('familyCards', familyCardModel.toJson());
    }
    catch (ex) { }
    return rowsAffected;
  }

  Future<int> removeFamilyCardLocally(int userId,int SN, final Database db) async {
    var rowsAffected = 0;
    try {
      rowsAffected = await db.delete('familyCards', where: "sn = ? AND addBy = ?",whereArgs: [SN,userId]);
    }
    catch (ex) { }
    return rowsAffected;
  }

}