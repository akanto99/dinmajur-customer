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
  String? type;
  String? message;
  DatumData? data;
  bool? read;
  bool? delivered;
  dynamic deliveredAt;
  String? actionUrl;
  String? priority;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? v;

  Datum({
    this.id,
    this.type,
    this.message,
    this.data,
    this.read,
    this.delivered,
    this.deliveredAt,
    this.actionUrl,
    this.priority,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    id: json["_id"],
    type: json["type"],
    message: json["message"],
    data: json["data"] == null ? null : DatumData.fromJson(json["data"]),
    read: json["read"],
    delivered: json["delivered"],
    deliveredAt: json["deliveredAt"],
    actionUrl: json["actionUrl"],
    priority: json["priority"],
    createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
    updatedAt: json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
    v: json["__v"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "type": type,
    "message": message,
    "data": data?.toJson(),
    "read": read,
    "delivered": delivered,
    "deliveredAt": deliveredAt,
    "actionUrl": actionUrl,
    "priority": priority,
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
    "__v": v,
  };
}

class DatumData {
  String? orderId;
  String? customerId;
  String? retailerId;
  String? deliveryId;

  DatumData({
    this.orderId,
    this.customerId,
    this.retailerId,
    this.deliveryId,
  });

  factory DatumData.fromJson(Map<String, dynamic> json) => DatumData(
    orderId: json["orderId"],
    customerId: json["customerId"],
    retailerId: json["retailerId"],
    deliveryId: json["deliveryId"],
  );

  Map<String, dynamic> toJson() => {
    "orderId": orderId,
    "customerId": customerId,
    "retailerId": retailerId,
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
