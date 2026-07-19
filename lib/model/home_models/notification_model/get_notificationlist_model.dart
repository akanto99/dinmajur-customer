import 'dart:convert';

NotificationListModel notificationListModelFromJson(String str) => NotificationListModel.fromJson(json.decode(str));

String notificationListModelToJson(NotificationListModel data) => json.encode(data.toJson());

class NotificationListModel {
  bool? success;
  String? message;
  Meta? meta;
  List<Datum>? data;

  NotificationListModel({
    this.success,
    this.message,
    this.meta,
    this.data,
  });

  factory NotificationListModel.fromJson(Map<String, dynamic> json) => NotificationListModel(
    success: json["success"],
    message: json["message"],
    meta: json["meta"] == null ? null : Meta.fromJson(json["meta"]),
    data: json["data"] == null ? [] : List<Datum>.from(json["data"]!.map((x) => Datum.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "meta": meta?.toJson(),
    "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
  };
}

class Datum {
  String? id;
  String? title;
  String? badge;
  String? type;
  bool? read;
  bool? isNew;
  String? message;
  String? priority;
  Data? data;
  DateTime? createdAt;
  DateTime? updatedAt;

  Datum({
    this.id,
    this.title,
    this.badge,
    this.type,
    this.read,
    this.isNew,
    this.message,
    this.priority,
    this.data,
    this.createdAt,
    this.updatedAt,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    id: json["_id"],
    title: json["title"],
    badge: json["badge"],
    type: json["type"],
    read: json["read"],
    isNew: json["isNew"],
    message: json["message"],
    priority: json["priority"],
    data: json["data"] == null ? null : Data.fromJson(json["data"]),
    createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
    updatedAt: json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "title": title,
    "badge": badge,
    "type": type,
    "read": read,
    "isNew": isNew,
    "message": message,
    "priority": priority,
    "data": data?.toJson(),
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
  };
}

class Data {
  String? trackingId;
  String? status;

  Data({
    this.trackingId,
    this.status,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    trackingId: json["trackingId"],
    status: json["status"],
  );

  Map<String, dynamic> toJson() => {
    "trackingId": trackingId,
    "status": status,
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
