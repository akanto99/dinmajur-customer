import 'dart:convert';

GetSseNotificationModel getSseNotificationModelFromJson(String str) => GetSseNotificationModel.fromJson(json.decode(str));

String getSseNotificationModelToJson(GetSseNotificationModel data) => json.encode(data.toJson());

class GetSseNotificationModel {
  SsePayload? ssePayload;

  GetSseNotificationModel({
    this.ssePayload,
  });

  factory GetSseNotificationModel.fromJson(Map<String, dynamic> json) => GetSseNotificationModel(
    ssePayload: json["ssePayload"] == null ? null : SsePayload.fromJson(json["ssePayload"]),
  );

  Map<String, dynamic> toJson() => {
    "ssePayload": ssePayload?.toJson(),
  };
}

class SsePayload {
  String? type;
  String? message;
  Data? data;
  bool? read;
  bool? delivered;
  dynamic deliveredAt;
  String? actionUrl;
  String? priority;
  String? id;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? v;

  SsePayload({
    this.type,
    this.message,
    this.data,
    this.read,
    this.delivered,
    this.deliveredAt,
    this.actionUrl,
    this.priority,
    this.id,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  factory SsePayload.fromJson(Map<String, dynamic> json) => SsePayload(
    type: json["type"],
    message: json["message"],
    data: json["data"] == null ? null : Data.fromJson(json["data"]),
    read: json["read"],
    delivered: json["delivered"],
    deliveredAt: json["deliveredAt"],
    actionUrl: json["actionUrl"],
    priority: json["priority"],
    id: json["_id"],
    createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
    updatedAt: json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
    v: json["__v"],
  );

  Map<String, dynamic> toJson() => {
    "type": type,
    "message": message,
    "data": data?.toJson(),
    "read": read,
    "delivered": delivered,
    "deliveredAt": deliveredAt,
    "actionUrl": actionUrl,
    "priority": priority,
    "_id": id,
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
    "__v": v,
  };
}

class Data {
  String? orderId;
  String? customerId;
  String? retailerId;
  String? deliveryId;

  Data({
    this.orderId,
    this.customerId,
    this.retailerId,
    this.deliveryId,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
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
