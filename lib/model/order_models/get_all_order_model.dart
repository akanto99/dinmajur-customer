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
  Meta? meta;
  List<Datum>? data;

  Data({
    this.meta,
    this.data,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    meta: json["meta"] == null ? null : Meta.fromJson(json["meta"]),
    data: json["data"] == null ? [] : List<Datum>.from(json["data"]!.map((x) => Datum.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "meta": meta?.toJson(),
    "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
  };
}

class Datum {
  String? orderId;
  String? houseKeeperBookingId;
  String? beautySalonBookingId;
  String? type;
  String? status;
  double? total;
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
    total: json["total"]?.toDouble(),
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
}

class Meta {
  int? total;
  int? page;
  int? limit;
  int? totalPages;

  Meta({
    this.total,
    this.page,
    this.limit,
    this.totalPages,
  });

  factory Meta.fromJson(Map<String, dynamic> json) => Meta(
    total: json["total"],
    page: json["page"],
    limit: json["limit"],
    totalPages: json["totalPages"],
  );

  Map<String, dynamic> toJson() => {
    "total": total,
    "page": page,
    "limit": limit,
    "totalPages": totalPages,
  };
}
