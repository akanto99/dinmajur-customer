// To parse this JSON data, do
//
//     final getBookedTimeSlotModel = getBookedTimeSlotModelFromJson(jsonString);

import 'dart:convert';

GetBookedTimeSlotModel getBookedTimeSlotModelFromJson(String str) =>
    GetBookedTimeSlotModel.fromJson(json.decode(str));

String getBookedTimeSlotModelToJson(GetBookedTimeSlotModel data) =>
    json.encode(data.toJson());

class GetBookedTimeSlotModel {
  bool? success;
  String? message;
  BookedSlotMeta? meta;
  List<BookedSlotDatum>? data;

  GetBookedTimeSlotModel({
    this.success,
    this.message,
    this.meta,
    this.data,
  });

  factory GetBookedTimeSlotModel.fromJson(Map<String, dynamic> json) =>
      GetBookedTimeSlotModel(
        success: json["success"],
        message: json["message"],
        meta: json["meta"] == null ? null : BookedSlotMeta.fromJson(json["meta"]),
        data: json["data"] == null
            ? []
            : List<BookedSlotDatum>.from(
            json["data"]!.map((x) => BookedSlotDatum.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "meta": meta?.toJson(),
    "data": data == null
        ? []
        : List<dynamic>.from(data!.map((x) => x.toJson())),
  };
}

class BookedSlotDatum {
  String? id;
  String? time;
  bool? isActive;
  int? position;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? v;
  bool? isBooked;

  BookedSlotDatum({
    this.id,
    this.time,
    this.isActive,
    this.position,
    this.createdAt,
    this.updatedAt,
    this.v,
    this.isBooked,
  });

  factory BookedSlotDatum.fromJson(Map<String, dynamic> json) =>
      BookedSlotDatum(
        id: json["_id"],
        time: json["time"],
        isActive: json["isActive"],
        position: json["position"],
        createdAt: json["createdAt"] == null
            ? null
            : DateTime.parse(json["createdAt"]),
        updatedAt: json["updatedAt"] == null
            ? null
            : DateTime.parse(json["updatedAt"]),
        v: json["__v"],
        isBooked: json["isBooked"],
      );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "time": time,
    "isActive": isActive,
    "position": position,
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
    "__v": v,
    "isBooked": isBooked,
  };
}

class BookedSlotMeta {
  int? total;
  int? booked;
  int? available;

  BookedSlotMeta({
    this.total,
    this.booked,
    this.available,
  });

  factory BookedSlotMeta.fromJson(Map<String, dynamic> json) => BookedSlotMeta(
    total: json["total"],
    booked: json["booked"],
    available: json["available"],
  );

  Map<String, dynamic> toJson() => {
    "total": total,
    "booked": booked,
    "available": available,
  };
}