// To parse this JSON data, do
//
//     final notificationListModel = notificationListModelFromJson(jsonString);

import 'dart:convert';

NotificationListModel notificationListModelFromJson(String str) => NotificationListModel.fromJson(json.decode(str));

String notificationListModelToJson(NotificationListModel data) => json.encode(data.toJson());

class NotificationListModel {
  bool? success;
  String? message;
  NotificationListModelData? data;

  NotificationListModel({
    this.success,
    this.message,
    this.data,
  });

  factory NotificationListModel.fromJson(Map<String, dynamic> json) => NotificationListModel(
    success: json["success"],
    message: json["message"],
    data: json["data"] == null ? null : NotificationListModelData.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "data": data?.toJson(),
  };
}

class NotificationListModelData {
  List<Datum>? data;
  Meta? meta;

  NotificationListModelData({
    this.data,
    this.meta,
  });

  factory NotificationListModelData.fromJson(Map<String, dynamic> json) => NotificationListModelData(
    data: json["data"] == null ? [] : List<Datum>.from(json["data"]!.map((x) => Datum.fromJson(x))),
    meta: json["meta"] == null ? null : Meta.fromJson(json["meta"]),
  );

  Map<String, dynamic> toJson() => {
    "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
    "meta": meta?.toJson(),
  };
}

class Datum {
  String? id;
  String? user;
  String? source;
  String? type;
  String? message;
  DatumData? data;
  bool? read;
  bool? delivered;
  String? priority;
  DateTime? createdAt;
  DateTime? updatedAt;

  Datum({
    this.id,
    this.user,
    this.source,
    this.type,
    this.message,
    this.data,
    this.read,
    this.delivered,
    this.priority,
    this.createdAt,
    this.updatedAt,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    id: json["_id"],
    user: json["user"],
    source: json["source"],
    type: json["type"],
    message: json["message"],
    data: json["data"] == null ? null : DatumData.fromJson(json["data"]),
    read: json["read"],
    delivered: json["delivered"],
    priority: json["priority"],
    createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
    updatedAt: json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "user": user,
    "source": source,
    "type": type,
    "message": message,
    "data": data?.toJson(),
    "read": read,
    "delivered": delivered,
    "priority": priority,
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
  };
}

class DatumData {
  String? title;
  Params? params;
  String? status;

  DatumData({
    this.title,
    this.params,
    this.status,
  });

  factory DatumData.fromJson(Map<String, dynamic> json) => DatumData(
    title: json["title"],
    params: json["params"] == null ? null : Params.fromJson(json["params"]),
    status: json["status"],
  );

  Map<String, dynamic> toJson() => {
    "title": title,
    "params": params?.toJson(),
    "status": status,
  };
}

class Params {
  String? beautySalonBookingId;
  String? houseKeeperBookingId;
  String? orderId;
  String? deliveryId;

  Params({
    this.beautySalonBookingId,
    this.houseKeeperBookingId,
    this.orderId,
    this.deliveryId,
  });

  factory Params.fromJson(Map<String, dynamic> json) => Params(
    beautySalonBookingId: json["beautySalonBookingId"],
    houseKeeperBookingId: json["houseKeeperBookingId"],
    orderId: json["orderId"],
    deliveryId: json["deliveryId"],
  );

  Map<String, dynamic> toJson() => {
    "beautySalonBookingId": beautySalonBookingId,
    "houseKeeperBookingId": houseKeeperBookingId,
    "orderId": orderId,
    "deliveryId": deliveryId,
  };
}

class Meta {
  int? page;
  int? limit;
  int? total;
  int? totalPages;
  bool? hasNext;
  bool? hasPrev;
  int? unreadCount;

  Meta({
    this.page,
    this.limit,
    this.total,
    this.totalPages,
    this.hasNext,
    this.hasPrev,
    this.unreadCount,
  });

  factory Meta.fromJson(Map<String, dynamic> json) => Meta(
    page: json["page"],
    limit: json["limit"],
    total: json["total"],
    totalPages: json["totalPages"],
    hasNext: json["hasNext"],
    hasPrev: json["hasPrev"],
    unreadCount: json["unreadCount"],
  );

  Map<String, dynamic> toJson() => {
    "page": page,
    "limit": limit,
    "total": total,
    "totalPages": totalPages,
    "hasNext": hasNext,
    "hasPrev": hasPrev,
    "unreadCount": unreadCount,
  };
}
