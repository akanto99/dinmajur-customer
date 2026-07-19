import 'dart:convert';

GetAllPermiumHomeBeautySalonModel getAllPermiumHomeBeautySalonModelFromJson(String str) => GetAllPermiumHomeBeautySalonModel.fromJson(json.decode(str));

String getAllPermiumHomeBeautySalonModelToJson(GetAllPermiumHomeBeautySalonModel data) => json.encode(data.toJson());

class GetAllPermiumHomeBeautySalonModel {
  bool? success;
  String? message;
  Meta? meta;
  List<Datum>? data;

  GetAllPermiumHomeBeautySalonModel({
    this.success,
    this.message,
    this.meta,
    this.data,
  });

  factory GetAllPermiumHomeBeautySalonModel.fromJson(Map<String, dynamic> json) => GetAllPermiumHomeBeautySalonModel(
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
  String? slug;
  int? position;
  Image? image;
  dynamic banner;
    bool? viewInPopup;
  List<Item>? items;

  Datum({
    this.id,
    this.name,
    this.slug,
    this.position,
    this.image,
    this.banner,
       this.viewInPopup,
    this.items,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    id: json["_id"],
    name: json["name"],
    slug: json["slug"],
    position: json["position"],
    image: json["image"] == null ? null : Image.fromJson(json["image"]),
    banner: json["banner"],
        viewInPopup: json["viewInPopup"],
    items: json["items"] == null ? [] : List<Item>.from(json["items"]!.map((x) => Item.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "name": name,
    "slug": slug,
    "position": position,
    "image": image?.toJson(),
    "banner": banner,
      "viewInPopup": viewInPopup,
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
  num? originalPrice;  // Changed from int? to num?
  num? salePrice;      // Changed from int? to num?
  DiscountType? discountType;
  num? discountValue;  // Changed from int? to num?
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