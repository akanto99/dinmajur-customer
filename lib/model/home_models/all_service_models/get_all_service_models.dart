// To parse this JSON data, do
//
//     final getAllServicesModel = getAllServicesModelFromJson(jsonString);

import 'dart:convert';

GetAllServicesModel getAllServicesModelFromJson(String str) => GetAllServicesModel.fromJson(json.decode(str));

String getAllServicesModelToJson(GetAllServicesModel data) => json.encode(data.toJson());

class GetAllServicesModel {
  bool? success;
  String? message;
  Meta? meta;
  List<Datum>? data;

  GetAllServicesModel({this.success, this.message, this.meta, this.data});

  factory GetAllServicesModel.fromJson(Map<String, dynamic> json) => GetAllServicesModel(
    success: json["success"],
    message: json["message"],
    meta: json["meta"] == null ? null : Meta.fromJson(json["meta"]),
    data: json["data"] == null ? [] : List<Datum>.from(json["data"]!.map((x) => Datum.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {"success": success, "message": message, "meta": meta?.toJson(), "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson()))};
}

class Datum {
  String? id;
  String? name;
  String? description;
  String? slug;
  Image? image;
  List<Category>? categories;
  bool? isPartner;


  Datum({this.id,
    this.name,
    this.description,
    this.slug, this.image,this.categories,this.isPartner});

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    id: json["_id"],
    name: json["name"],
    description: json["description"],
    slug: json["slug"],
    image: json["image"] == null ? null : Image.fromJson(json["image"]),
    categories: json["categories"] == null ? [] : List<Category>.from(json["categories"]!.map((x) => Category.fromJson(x))),
    isPartner: json["isPartner"],

  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "name": name,
    "description": description,
    "slug": slug,
    "image": image?.toJson(),
    "categories": categories == null ? [] : List<dynamic>.from(categories!.map((x) => x.toJson())),
    "isPartner": isPartner,
  };
}

class Category {
  String? id;
  String? name;


  Category({this.id, this.name});

  factory Category.fromJson(Map<String, dynamic> json) => Category(
    id: json["_id"],
    name: json["name"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "name": name,
  };
}

class Image {
  String? id;
  String? key;
  String? altText;
  String? url;

  Image({this.id, this.key, this.altText, this.url});

  factory Image.fromJson(Map<String, dynamic> json) => Image(id: json["_id"], key: json["key"], altText: json["altText"], url: json["url"]);

  Map<String, dynamic> toJson() => {"_id": id, "key": key, "altText": altText, "url": url};
}



class Meta {
  int? totalServices;

  Meta({this.totalServices});

  factory Meta.fromJson(Map<String, dynamic> json) => Meta(totalServices: json["totalServices"]);

  Map<String, dynamic> toJson() => {"totalServices": totalServices};
}
