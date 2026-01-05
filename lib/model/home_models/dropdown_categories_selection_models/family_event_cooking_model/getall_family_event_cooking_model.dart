// To parse this JSON data, do
//
//     final getAllFamilyEventCookingModel = getAllFamilyEventCookingModelFromJson(jsonString);

import 'dart:convert';

GetAllFamilyEventCookingModel getAllFamilyEventCookingModelFromJson(String str) => GetAllFamilyEventCookingModel.fromJson(json.decode(str));

String getAllFamilyEventCookingModelToJson(GetAllFamilyEventCookingModel data) => json.encode(data.toJson());

class GetAllFamilyEventCookingModel {
  bool? success;
  String? message;
  List<Datum>? data;

  GetAllFamilyEventCookingModel({
    this.success,
    this.message,
    this.data,
  });

  factory GetAllFamilyEventCookingModel.fromJson(Map<String, dynamic> json) => GetAllFamilyEventCookingModel(
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

class Package {
  String? id;
  String? name;
  List<Price>? prices;
  String? image;
  DateTime? createdAt;
  DateTime? updatedAt;
  List<Datum>? items;

  Package({
    this.id,
    this.name,
    this.prices,
    this.image,
    this.createdAt,
    this.updatedAt,
    this.items,
  });

  factory Package.fromJson(Map<String, dynamic> json) => Package(
    id: json["_id"],
    name: json["name"],
    prices: json["prices"] == null ? [] : List<Price>.from(json["prices"]!.map((x) => Price.fromJson(x))),
    image: json["image"],
    createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
    updatedAt: json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
    items: json["items"] == null ? [] : List<Datum>.from(json["items"]!.map((x) => Datum.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "name": name,
    "prices": prices == null ? [] : List<dynamic>.from(prices!.map((x) => x.toJson())),
    "image": image,
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
    "items": items == null ? [] : List<dynamic>.from(items!.map((x) => x.toJson())),
  };
}

class Datum {
  String? id;
  String? name;
  int? price;
  String? image;
  String? type;
  DateTime? createdAt;
  DateTime? updatedAt;
  List<Package>? packages;

  Datum({
    this.id,
    this.name,
    this.price,
    this.image,
    this.type,
    this.createdAt,
    this.updatedAt,
    this.packages,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    id: json["_id"],
    name: json["name"],
    price: json["price"],
    image: json["image"],
    type: json["type"],
    createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
    updatedAt: json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
    packages: json["packages"] == null ? [] : List<Package>.from(json["packages"]!.map((x) => Package.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "name": name,
    "price": price,
    "image": image,
    "type": type,
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
    "packages": packages == null ? [] : List<dynamic>.from(packages!.map((x) => x.toJson())),
  };
}

class Price {
  int? price;
  String? id;
  GuestRange? guestRange;

  Price({
    this.price,
    this.id,
    this.guestRange,
  });

  factory Price.fromJson(Map<String, dynamic> json) => Price(
    price: json["price"],
    id: json["_id"],
    guestRange: guestRangeValues.map[json["guestRange"]]!,
  );

  Map<String, dynamic> toJson() => {
    "price": price,
    "_id": id,
    "guestRange": guestRangeValues.reverse[guestRange],
  };
}

enum GuestRange {
  THE_2530,
  THE_3035,
  THE_4050
}

final guestRangeValues = EnumValues({
  "25–30": GuestRange.THE_2530,
  "30–35": GuestRange.THE_3035,
  "40–50": GuestRange.THE_4050
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
