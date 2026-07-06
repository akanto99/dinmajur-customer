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
