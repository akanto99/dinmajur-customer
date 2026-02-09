import 'dart:convert';

GetAllHouseKeeperCategoryModel getAllHouseKeeperCategoryModelFromJson(String str) => GetAllHouseKeeperCategoryModel.fromJson(json.decode(str));

String getAllHouseKeeperCategoryModelToJson(GetAllHouseKeeperCategoryModel data) => json.encode(data.toJson());

class GetAllHouseKeeperCategoryModel {
  bool? success;
  String? message;
  dynamic meta;
  List<Datum>? data;

  GetAllHouseKeeperCategoryModel({
    this.success,
    this.message,
    this.meta,
    this.data,
  });

  factory GetAllHouseKeeperCategoryModel.fromJson(Map<String, dynamic> json) => GetAllHouseKeeperCategoryModel(
    success: json["success"],
    message: json["message"],
    meta: json["meta"],
    data: json["data"] == null ? [] : List<Datum>.from(json["data"]!.map((x) => Datum.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "meta": meta,
    "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
  };
}

class Datum {
  dynamic image;
  Icon? icon;
  String? id;
  String? name;
  String? description;
  String? slug;
  int? position;
  int? v;
  DateTime? createdAt;
  DateTime? updatedAt;

  Datum({
    this.image,
    this.icon,
    this.id,
    this.name,
    this.description,
    this.slug,
    this.position,
    this.v,
    this.createdAt,
    this.updatedAt,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    image: json["image"],
    icon: json["icon"] == null ? null : Icon.fromJson(json["icon"]),
    id: json["_id"],
    name: json["name"],
    description: json["description"],
    slug: json["slug"],
    position: json["position"],
    v: json["__v"],
    createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
    updatedAt: json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
  );

  Map<String, dynamic> toJson() => {
    "image": image,
    "icon": icon?.toJson(),
    "_id": id,
    "name": name,
    "description": description,
    "slug": slug,
    "position": position,
    "__v": v,
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
  };
}

class Icon {
  String? url;
  String? key;
  String? altText;

  Icon({
    this.url,
    this.key,
    this.altText,
  });

  factory Icon.fromJson(Map<String, dynamic> json) => Icon(
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
