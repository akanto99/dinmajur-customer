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
  String? id;
  String? name;
  String? image;
  String? type;
  int? position;
  DateTime? createdAt;
  DateTime? updatedAt;
  List<Datum>? packages;
  List<Price>? prices;
  List<Datum>? items;
  String? description;

  Datum({
    this.id,
    this.name,
    this.image,
    this.type,
    this.position,
    this.createdAt,
    this.updatedAt,
    this.packages,
    this.prices,
    this.items,
    this.description,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    id: json["_id"],
    name: json["name"],
    image: json["image"],
    type: json["type"],
    position: json["position"],
    createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
    updatedAt: json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
    packages: json["packages"] == null ? [] : List<Datum>.from(json["packages"]!.map((x) => Datum.fromJson(x))),
    prices: json["prices"] == null ? [] : List<Price>.from(json["prices"]!.map((x) => Price.fromJson(x))),
    items: json["items"] == null ? [] : List<Datum>.from(json["items"]!.map((x) => Datum.fromJson(x))),
    description: json["description"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "name": name,
    "image": image,
    "type": type,
    "position": position,
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
    "packages": packages == null ? [] : List<dynamic>.from(packages!.map((x) => x.toJson())),
    "prices": prices == null ? [] : List<dynamic>.from(prices!.map((x) => x.toJson())),
    "items": items == null ? [] : List<dynamic>.from(items!.map((x) => x.toJson())),
    "description": description,
  };
}

class Price {
  String? id;
  int? originalPrice;
  DiscountType? discountType;
  int? discountValue;
  double? salePrice;
  GuestRange? guestRange;

  Price({
    this.id,
    this.originalPrice,
    this.discountType,
    this.discountValue,
    this.salePrice,
    this.guestRange,
  });

  factory Price.fromJson(Map<String, dynamic> json) => Price(
    id: json["_id"],
    originalPrice: json["originalPrice"],
    discountType: discountTypeValues.map[json["discountType"]]!,
    discountValue: json["discountValue"],
    salePrice: json["salePrice"]?.toDouble(),
    guestRange: json["guestRange"] == null ? null : GuestRange.fromJson(json["guestRange"]),
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "originalPrice": originalPrice,
    "discountType": discountTypeValues.reverse[discountType],
    "discountValue": discountValue,
    "salePrice": salePrice,
    "guestRange": guestRange?.toJson(),
  };
}

enum DiscountType {
  NONE,
  PERCENTAGE
}

final discountTypeValues = EnumValues({
  "NONE": DiscountType.NONE,
  "PERCENTAGE": DiscountType.PERCENTAGE
});

class GuestRange {
  Id? id;
  Label? label;

  GuestRange({
    this.id,
    this.label,
  });

  factory GuestRange.fromJson(Map<String, dynamic> json) => GuestRange(
    id: idValues.map[json["id"]]!,
    label: labelValues.map[json["label"]]!,
  );

  Map<String, dynamic> toJson() => {
    "id": idValues.reverse[id],
    "label": labelValues.reverse[label],
  };
}

enum Id {
  THE_695_A3_E3_DC71508_DE1_D55_CBD8,
  THE_695_A3_E3_DC71508_DE1_D55_CBD9,
  THE_695_A3_E3_DC71508_DE1_D55_CBDA
}

final idValues = EnumValues({
  "695a3e3dc71508de1d55cbd8": Id.THE_695_A3_E3_DC71508_DE1_D55_CBD8,
  "695a3e3dc71508de1d55cbd9": Id.THE_695_A3_E3_DC71508_DE1_D55_CBD9,
  "695a3e3dc71508de1d55cbda": Id.THE_695_A3_E3_DC71508_DE1_D55_CBDA
});

enum Label {
  THE_2530,
  THE_3035,
  THE_4050
}

final labelValues = EnumValues({
  "25–30": Label.THE_2530,
  "30–35": Label.THE_3035,
  "40–50": Label.THE_4050
});

class Meta {
  int? total;
  TransportFee? transportFee;

  Meta({
    this.total,
    this.transportFee,
  });

  factory Meta.fromJson(Map<String, dynamic> json) => Meta(
    total: json["total"],
    transportFee: json["transportFee"] == null ? null : TransportFee.fromJson(json["transportFee"]),
  );

  Map<String, dynamic> toJson() => {
    "total": total,
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
