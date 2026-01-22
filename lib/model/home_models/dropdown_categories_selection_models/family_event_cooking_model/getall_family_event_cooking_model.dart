// To parse this JSON data, do
//
//     final getAllFamilyEventCookingModel = getAllFamilyEventCookingModelFromJson(jsonString);

import 'dart:convert';

GetAllFamilyEventCookingModel getAllFamilyEventCookingModelFromJson(String str) => GetAllFamilyEventCookingModel.fromJson(json.decode(str));

String getAllFamilyEventCookingModelToJson(GetAllFamilyEventCookingModel data) => json.encode(data.toJson());

class GetAllFamilyEventCookingModel {
  bool? success;
  String? message;
  Meta? meta;
  List<Datum>? data;

  GetAllFamilyEventCookingModel({
    this.success,
    this.message,
    this.meta,
    this.data,
  });

  factory GetAllFamilyEventCookingModel.fromJson(Map<String, dynamic> json) => GetAllFamilyEventCookingModel(
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
  List<Package>? packages;
  String? id;
  String? name;
  String? type;
  int? position;
  Image? image;

  Datum({
    this.packages,
    this.id,
    this.name,
    this.type,
    this.position,
    this.image,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    packages: json["packages"] == null ? [] : List<Package>.from(json["packages"]!.map((x) => Package.fromJson(x))),
    id: json["_id"],
    name: json["name"],
    type: json["type"],
    position: json["position"],
    image: json["image"] == null ? null : Image.fromJson(json["image"]),
  );

  Map<String, dynamic> toJson() => {
    "packages": packages == null ? [] : List<dynamic>.from(packages!.map((x) => x.toJson())),
    "_id": id,
    "name": name,
    "type": type,
    "position": position,
    "image": image?.toJson(),
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

class Package {
  String? id;
  String? name;
  int? position;
  List<Price>? prices;
  List<Item>? items;
  Image? image;

  Package({
    this.id,
    this.name,
    this.position,
    this.prices,
    this.items,
    this.image,
  });

  factory Package.fromJson(Map<String, dynamic> json) => Package(
    id: json["_id"],
    name: json["name"],
    position: json["position"],
    prices: json["prices"] == null ? [] : List<Price>.from(json["prices"]!.map((x) => Price.fromJson(x))),
    items: json["items"] == null ? [] : List<Item>.from(json["items"]!.map((x) => Item.fromJson(x))),
    image: json["image"] == null ? null : Image.fromJson(json["image"]),

  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "name": name,
    "position": position,
    "prices": prices == null ? [] : List<dynamic>.from(prices!.map((x) => x.toJson())),
    "items": items == null ? [] : List<dynamic>.from(items!.map((x) => x.toJson())),
    "image": image?.toJson(),

  };
}

class Item {
  String? id;
  String? eventCookingPackage;
  String? name;
  String? description;
  dynamic image;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? v;
  List<Price>? prices;

  Item({
    this.id,
    this.eventCookingPackage,
    this.name,
    this.description,
    this.image,
    this.createdAt,
    this.updatedAt,
    this.v,
    this.prices,
  });

  factory Item.fromJson(Map<String, dynamic> json) => Item(
    id: json["_id"],
    eventCookingPackage: json["eventCookingPackage"],
    name: json["name"],
    description: json["description"],
    image: json["image"],
    createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
    updatedAt: json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
    v: json["__v"],
    prices: json["prices"] == null ? [] : List<Price>.from(json["prices"]!.map((x) => Price.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "eventCookingPackage": eventCookingPackage,
    "name": name,
    "description": description,
    "image": image,
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
    "__v": v,
    "prices": prices == null ? [] : List<dynamic>.from(prices!.map((x) => x.toJson())),
  };
}

class Price {
  String? id;
  String? referenceType;
  String? referenceId;
  GuestRange? guestRange;
  int? originalPrice;
  double? salePrice;
  DiscountType? discountType;
  int? discountValue;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? v;

  Price({
    this.id,
    this.referenceType,
    this.referenceId,
    this.guestRange,
    this.originalPrice,
    this.salePrice,
    this.discountType,
    this.discountValue,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  factory Price.fromJson(Map<String, dynamic> json) => Price(
    id: json["_id"],
    referenceType:json["referenceType"],
    referenceId: json["referenceId"],
    guestRange: json["guestRange"] == null ? null : GuestRange.fromJson(json["guestRange"]),
    originalPrice: json["originalPrice"],
    salePrice: json["salePrice"]?.toDouble(),
    discountType: discountTypeValues.map[json["discountType"]]!,
    discountValue: json["discountValue"],
    createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
    updatedAt: json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
    v: json["__v"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "referenceType": referenceType,
    "referenceId": referenceId,
    "guestRange": guestRange?.toJson(),
    "originalPrice": originalPrice,
    "salePrice": salePrice,
    "discountType": discountTypeValues.reverse[discountType],
    "discountValue": discountValue,
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
    "__v": v,
  };
}

enum DiscountType {
  NONE,
  PERCENTAGE,
  FLAT
}

final discountTypeValues = EnumValues({
  "NONE": DiscountType.NONE,
  "PERCENTAGE": DiscountType.PERCENTAGE,
  "FLAT": DiscountType.FLAT
});

class GuestRange {
  String? id;
  String? label;
  bool? isActive;
  int? v;
  DateTime? createdAt;
  DateTime? updatedAt;

  GuestRange({
    this.id,
    this.label,
    this.isActive,
    this.v,
    this.createdAt,
    this.updatedAt,
  });

  factory GuestRange.fromJson(Map<String, dynamic> json) => GuestRange(
    id: json["_id"],
    label: json["label"],
    isActive: json["isActive"],
    v: json["__v"],
    createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
    updatedAt: json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "label":label,
    "isActive": isActive,
    "__v": v,
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
  };
}


class Meta {
  TransportFee? transportFee;

  Meta({
    this.transportFee,
  });

  factory Meta.fromJson(Map<String, dynamic> json) => Meta(
    transportFee: json["transportFee"] == null ? null : TransportFee.fromJson(json["transportFee"]),
  );

  Map<String, dynamic> toJson() => {
    "transportFee": transportFee?.toJson(),
  };
}

class TransportFee {
  String? name;
  String? description;
  int? value;

  TransportFee({
    this.name,
    this.description,
    this.value,
  });

  factory TransportFee.fromJson(Map<String, dynamic> json) => TransportFee(
    name: json["name"],
    description: json["description"],
    value: json["value"],
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "description": description,
    "value": value,
  };
}

class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}
