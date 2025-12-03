// To parse this JSON data:
//
//     final getAllPermiumHouseKeeperTask = getAllPermiumHouseKeeperTaskFromJson(jsonString);

import 'dart:convert';

GetAllPermiumHouseKeeperTaskModel getAllPermiumHouseKeeperTaskModelFromJson(String str) =>
    GetAllPermiumHouseKeeperTaskModel.fromJson(json.decode(str));

String getAllPermiumHouseKeeperTaskModelToJson(GetAllPermiumHouseKeeperTaskModel data) =>
    json.encode(data.toJson());

class GetAllPermiumHouseKeeperTaskModel {
  bool? success;
  String? message;
  List<Datum>? data;

  GetAllPermiumHouseKeeperTaskModel({
    this.success,
    this.message,
    this.data,
  });

  factory GetAllPermiumHouseKeeperTaskModel.fromJson(Map<String, dynamic> json) =>
      GetAllPermiumHouseKeeperTaskModel(
        success: json["success"],
        message: json["message"],
        data: json["data"] == null
            ? []
            : List<Datum>.from(
          json["data"]!.map((x) => Datum.fromJson(x)),
        ),
      );

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "data": data == null
        ? []
        : List<dynamic>.from(data!.map((x) => x.toJson())),
  };
}

class Datum {
  String? id;
  String? name;
  String? slug;
  bool? hasRoom;
  List<HouseKeeperTaskItem>? houseKeeperTaskItems;
  int? position;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? v;

  String? discountType;
  int? discountValue;

  ImageModel? image;
  ImageModel? icon;

  Datum({
    this.id,
    this.name,
    this.slug,
    this.hasRoom,
    this.houseKeeperTaskItems,
    this.position,
    this.createdAt,
    this.updatedAt,
    this.v,
    this.discountType,
    this.discountValue,
    this.image,
    this.icon,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    id: json["_id"],
    name: json["name"],
    slug: json["slug"],
    hasRoom: json["hasRoom"],
    houseKeeperTaskItems: json["houseKeeperTaskItems"] == null
        ? []
        : List<HouseKeeperTaskItem>.from(
      json["houseKeeperTaskItems"]!
          .map((x) => HouseKeeperTaskItem.fromJson(x)),
    ),
    position: json["position"],
    createdAt: json["createdAt"] == null
        ? null
        : DateTime.parse(json["createdAt"]),
    updatedAt: json["updatedAt"] == null
        ? null
        : DateTime.parse(json["updatedAt"]),
    v: json["__v"],
    discountType: json["discountType"],
    discountValue: json["discountValue"],
    image: json["image"] == null
        ? null
        : ImageModel.fromJson(json["image"]),
    icon:
    json["icon"] == null ? null : ImageModel.fromJson(json["icon"]),
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "name": name,
    "slug": slug,
    "hasRoom": hasRoom,
    "houseKeeperTaskItems": houseKeeperTaskItems == null
        ? []
        : List<dynamic>.from(
        houseKeeperTaskItems!.map((x) => x.toJson())),
    "position": position,
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
    "__v": v,
    "discountType": discountType,
    "discountValue": discountValue,
    "image": image?.toJson(),
    "icon": icon?.toJson(),
  };
}

class HouseKeeperTaskItem {
  String? id;
  String? name;
  int? price;
  String? houseKeeperTaskId;
  int? v;
  DateTime? createdAt;
  DateTime? updatedAt;

  HouseKeeperTaskItem({
    this.id,
    this.name,
    this.price,
    this.houseKeeperTaskId,
    this.v,
    this.createdAt,
    this.updatedAt,
  });

  factory HouseKeeperTaskItem.fromJson(Map<String, dynamic> json) =>
      HouseKeeperTaskItem(
        id: json["_id"],
        name: json["name"],
        price: json["price"],
        houseKeeperTaskId: json["houseKeeperTaskId"],
        v: json["__v"],
        createdAt: json["createdAt"] == null
            ? null
            : DateTime.parse(json["createdAt"]),
        updatedAt: json["updatedAt"] == null
            ? null
            : DateTime.parse(json["updatedAt"]),
      );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "name": name,
    "price": price,
    "houseKeeperTaskId": houseKeeperTaskId,
    "__v": v,
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
  };
}

class ImageModel {
  String? url;
  String? key;
  String? altText;

  ImageModel({
    this.url,
    this.key,
    this.altText,
  });

  factory ImageModel.fromJson(Map<String, dynamic> json) => ImageModel(
    url: json["url"],
    key: json["key"],
    altText: json["altText"],
  );

  Map<String, dynamic> toJson() => {
    "url": url,
    "key": key,
    "altText": altText,
  };
}
