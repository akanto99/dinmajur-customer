// To parse this JSON data, do
//
//     final getSseNotificationCountModel = getSseNotificationCountModelFromJson(jsonString);

import 'dart:convert';

GetSseNotificationCountModel getSseNotificationCountModelFromJson(String str) => GetSseNotificationCountModel.fromJson(json.decode(str));

String getSseNotificationCountModelToJson(GetSseNotificationCountModel data) => json.encode(data.toJson());

class GetSseNotificationCountModel {
  int? total;

  GetSseNotificationCountModel({
    this.total,
  });

  factory GetSseNotificationCountModel.fromJson(Map<String, dynamic> json) => GetSseNotificationCountModel(
    total: json["total"],
  );

  Map<String, dynamic> toJson() => {
    "total": total,
  };
}
