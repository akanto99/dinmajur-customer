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
  String? id;
  String? type;
  String? startTime;
  String? endTime;
  int? price;
  List<Task>? tasks;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? v;

  Datum({
    this.id,
    this.type,
    this.startTime,
    this.endTime,
    this.price,
    this.tasks,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    id: json["_id"],
    type: json["type"],
    startTime: json["startTime"],
    endTime: json["endTime"],
    price: json["price"],
    tasks: json["tasks"] == null ? [] : List<Task>.from(json["tasks"]!.map((x) => Task.fromJson(x))),
    createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
    updatedAt: json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
    v: json["__v"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "type": type,
    "startTime": startTime,
    "endTime": endTime,
    "price": price,
    "tasks": tasks == null ? [] : List<dynamic>.from(tasks!.map((x) => x.toJson())),
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
    "__v": v,
  };
}

class Task {
  String? name;
  List<String>? items;

  Task({
    this.name,
    this.items,
  });

  factory Task.fromJson(Map<String, dynamic> json) => Task(
    name: json["name"],
    items: json["items"] == null ? [] : List<String>.from(json["items"]!.map((x) => x)),
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "items": items == null ? [] : List<dynamic>.from(items!.map((x) => x)),
  };
}
