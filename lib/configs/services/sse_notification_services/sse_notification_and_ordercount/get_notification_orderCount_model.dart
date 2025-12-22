// import 'dart:convert';
//
// GetSseNotificationCountModel getSseNotificationCountModelFromJson(String str) => GetSseNotificationCountModel.fromJson(json.decode(str));
//
// String getSseNotificationCountModelToJson(GetSseNotificationCountModel data) => json.encode(data.toJson());
//
// class GetSseNotificationCountModel {
//   int? total;
//
//   GetSseNotificationCountModel({
//     this.total,
//   });
//
//   factory GetSseNotificationCountModel.fromJson(Map<String, dynamic> json) => GetSseNotificationCountModel(
//     total: json["total"],
//   );
//
//   Map<String, dynamic> toJson() => {
//     "total": total,
//   };
// }
// To parse this JSON data, do
//
//     final getSseNotificationAndOrderCountModel = getSseNotificationAndOrderCountModelFromJson(jsonString);

import 'dart:convert';

GetSseNotificationAndOrderCountModel getSseNotificationAndOrderCountModelFromJson(String str) => GetSseNotificationAndOrderCountModel.fromJson(json.decode(str));

String getSseNotificationAndOrderCountModelToJson(GetSseNotificationAndOrderCountModel data) => json.encode(data.toJson());

class GetSseNotificationAndOrderCountModel {
  int? notificationCount;
  int? runningOrderCount;

  GetSseNotificationAndOrderCountModel({
    this.notificationCount,
    this.runningOrderCount,
  });

  factory GetSseNotificationAndOrderCountModel.fromJson(Map<String, dynamic> json) => GetSseNotificationAndOrderCountModel(
    notificationCount: json["notificationCount"],
    runningOrderCount: json["runningOrderCount"],
  );

  Map<String, dynamic> toJson() => {
    "notificationCount": notificationCount,
    "runningOrderCount": runningOrderCount,
  };
}
