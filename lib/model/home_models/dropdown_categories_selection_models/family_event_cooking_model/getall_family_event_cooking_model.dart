import 'dart:convert';

GetAllFamilyEventCookingModel getAllFamilyEventCookingModelFromJson(String str) => GetAllFamilyEventCookingModel.fromJson(json.decode(str));

String getAllFamilyEventCookingModelToJson(GetAllFamilyEventCookingModel data) => json.encode(data.toJson());

class GetAllFamilyEventCookingModel {
  bool? success;
  String? message;
  List<Datum>? data;

  GetAllFamilyEventCookingModel({this.success, this.message, this.data});

  factory GetAllFamilyEventCookingModel.fromJson(Map<String, dynamic> json) =>
      GetAllFamilyEventCookingModel(success: json["success"], message: json["message"], data: json["data"] == null ? [] : List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))));

  Map<String, dynamic> toJson() => {"success": success, "message": message, "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson()))};
}

class Datum {
  String? id;
  String? name;
  int? price;
  String? image;
  String? type;
  DateTime? createdAt;
  DateTime? updatedAt;

  /// For Category → Packages
  List<Datum>? packages;

  /// For Package → Items
  List<Datum>? items;

  /// For Item → Package reference (ID only)
  String? eventCookingPackage;

  int? v;

  Datum({this.id, this.name, this.price, this.image, this.type, this.createdAt, this.updatedAt, this.packages, this.items, this.eventCookingPackage, this.v});

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    id: json["_id"],
    name: json["name"],
    price: json["price"],
    image: json["image"],
    type: json["type"],
    createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
    updatedAt: json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
    packages: json["packages"] == null ? [] : List<Datum>.from(json["packages"].map((x) => Datum.fromJson(x))),
    items: json["items"] == null ? [] : List<Datum>.from(json["items"].map((x) => Datum.fromJson(x))),
    eventCookingPackage: json["eventCookingPackage"],
    v: json["__v"],
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
    "items": items == null ? [] : List<dynamic>.from(items!.map((x) => x.toJson())),
    "eventCookingPackage": eventCookingPackage,
    "__v": v,
  };
}
