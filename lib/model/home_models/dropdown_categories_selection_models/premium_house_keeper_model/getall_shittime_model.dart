// To parse this JSON data, do
//
//     final getAllShiftTimeModel = getAllShiftTimeModelFromJson(jsonString);

import 'dart:convert';

GetAllShiftTimeModel getAllShiftTimeModelFromJson(String str) => GetAllShiftTimeModel.fromJson(json.decode(str));

String getAllShiftTimeModelToJson(GetAllShiftTimeModel data) => json.encode(data.toJson());

class GetAllShiftTimeModel {
  bool? success;
  String? message;
  List<Datum>? data;

  GetAllShiftTimeModel({
    this.success,
    this.message,
    this.data,
  });

  factory GetAllShiftTimeModel.fromJson(Map<String, dynamic> json) => GetAllShiftTimeModel(
    success: json["success"],
    message: json["message"],
    data: json["data"] == null ? [] : List<Datum>.from(json["data"]!.map((x) => Datum.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
  };
}

class Datum {
  String? shiftId;
  String? type;
  String? startTime;
  String? endTime;
  bool? isBooked;

  Datum({
    this.shiftId,
    this.type,
    this.startTime,
    this.endTime,
    this.isBooked,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    shiftId: json["shiftId"],
    type: json["type"],
    startTime: json["startTime"],
    endTime: json["endTime"],
    isBooked: json["isBooked"],
  );

  Map<String, dynamic> toJson() => {
    "shiftId": shiftId,
    "type": type,
    "startTime": startTime,
    "endTime": endTime,
    "isBooked": isBooked,
  };
}
