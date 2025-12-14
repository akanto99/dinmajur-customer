// To parse this JSON data, do
//
//     final getAllPermiumHomeBeautySalonModel = getAllPermiumHomeBeautySalonModelFromJson(jsonString);

import 'dart:convert';

GetAllPermiumHomeBeautySalonModel getAllPermiumHomeBeautySalonModelFromJson(String str) => GetAllPermiumHomeBeautySalonModel.fromJson(json.decode(str));

String getAllPermiumHomeBeautySalonModelToJson(GetAllPermiumHomeBeautySalonModel data) => json.encode(data.toJson());

class GetAllPermiumHomeBeautySalonModel {
  bool? success;
  String? message;
  List<Datum>? data;

  GetAllPermiumHomeBeautySalonModel({
    this.success,
    this.message,
    this.data,
  });

  factory GetAllPermiumHomeBeautySalonModel.fromJson(Map<String, dynamic> json) => GetAllPermiumHomeBeautySalonModel(
    success: json["success"],
    message: json["message"],
    data: json["data"] == null ? [] : List<Datum>.from(json["data"]!.map((x) => Datum.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
  };
}

class Datum {
  String? id;
  String? name;
  String? slug;
  int? position;
  Image? image;
  dynamic banner;
  List<Item>? items;

  Datum({
    this.id,
    this.name,
    this.slug,
    this.position,
    this.image,
    this.banner,
    this.items,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    id: json["_id"],
    name: json["name"],
    slug: json["slug"],
    position: json["position"],
    image: json["image"] == null ? null : Image.fromJson(json["image"]),
    banner: json["banner"],
    items: json["items"] == null ? [] : List<Item>.from(json["items"]!.map((x) => Item.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "name": name,
    "slug": slug,
    "position": position,
    "image": image?.toJson(),
    "banner": banner,
    "items": items == null ? [] : List<dynamic>.from(items!.map((x) => x.toJson())),
  };
}

class Image {
  String? url;
  String? key;
  String? altText;

  Image({
    this.url,
    this.key,
    this.altText,
  });

  factory Image.fromJson(Map<String, dynamic> json) => Image(
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

class Item {
  String? id;
  String? name;
  int? originalPrice;
  int? salePrice;
  DiscountType? discountType;
  int? discountValue;
  String? details;
  Image? image;
  List<dynamic>? faqs;

  Item({
    this.id,
    this.name,
    this.originalPrice,
    this.salePrice,
    this.discountType,
    this.discountValue,
    this.details,
    this.image,
    this.faqs,
  });

  factory Item.fromJson(Map<String, dynamic> json) => Item(
    id: json["_id"],
    name: json["name"],
    originalPrice: json["originalPrice"],
    salePrice: json["salePrice"],
    // Handle null or unknown discount types safely
    discountType: json["discountType"] != null
        ? discountTypeValues.map[json["discountType"]]
        : null,
    discountValue: json["discountValue"],
    details: json["details"],
    image: json["image"] == null ? null : Image.fromJson(json["image"]),
    faqs: json["faqs"] == null ? [] : List<dynamic>.from(json["faqs"]!.map((x) => x)),
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "name": name,
    "originalPrice": originalPrice,
    "salePrice": salePrice,
    "discountType": discountType != null ? discountTypeValues.reverse[discountType] : null,
    "discountValue": discountValue,
    "details": details,
    "image": image?.toJson(),
    "faqs": faqs == null ? [] : List<dynamic>.from(faqs!.map((x) => x)),
  };
}

enum DiscountType {
  PERCENTAGE,
  FLAT
}

final discountTypeValues = EnumValues({
  "PERCENTAGE": DiscountType.PERCENTAGE,
  "FLAT": DiscountType.FLAT
});

class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}