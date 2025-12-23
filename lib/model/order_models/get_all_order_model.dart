// To parse this JSON data, do
//
//     final getAllOrderModel = getAllOrderModelFromJson(jsonString);

import 'dart:convert';

GetAllOrderModel getAllOrderModelFromJson(String str) => GetAllOrderModel.fromJson(json.decode(str));

String getAllOrderModelToJson(GetAllOrderModel data) => json.encode(data.toJson());

class GetAllOrderModel {
  bool? success;
  String? message;
  Data? data;

  GetAllOrderModel({
    this.success,
    this.message,
    this.data,
  });

  factory GetAllOrderModel.fromJson(Map<String, dynamic> json) => GetAllOrderModel(
    success: json["success"],
    message: json["message"],
    data: json["data"] == null ? null : Data.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "data": data?.toJson(),
  };
}

class Data {
  int? total;
  List<Datum>? data;

  Data({
    this.total,
    this.data,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    total: json["total"],
    data: json["data"] == null ? [] : List<Datum>.from(json["data"]!.map((x) => Datum.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "total": total,
    "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
  };
}

class Datum {
  String? orderId;
  String? houseKeeperBookingId;
  String? beautySalonBookingId;
  String? type;
  String? status;
  double? total; // ✅ Changed from int? to double?
  DateTime? createdAt;

  Datum({
    this.orderId,
    this.houseKeeperBookingId,
    this.beautySalonBookingId,
    this.type,
    this.status,
    this.total,
    this.createdAt,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    orderId: json["orderId"],
    houseKeeperBookingId: json["houseKeeperBookingId"],
    beautySalonBookingId: json["beautySalonBookingId"],
    type: json["type"],
    status: json["status"],
    // ✅ Handle both int and double values safely
    total: json["total"] != null
        ? (json["total"] is int
        ? (json["total"] as int).toDouble()
        : json["total"] as double)
        : null,
    createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
  );

  Map<String, dynamic> toJson() => {
    "orderId": orderId,
    "houseKeeperBookingId": houseKeeperBookingId,
    "beautySalonBookingId": beautySalonBookingId,
    "type": type,
    "status": status,
    "total": total,
    "createdAt": createdAt?.toIso8601String(),
  };

  // ✅ Helper method to get formatted total with 2 decimal places
  String get formattedTotal => total != null ? total!.toStringAsFixed(2) : '0.00';

  // ✅ Helper method to get total as integer (for backward compatibility)
  int get totalAsInt => total?.toInt() ?? 0;
}