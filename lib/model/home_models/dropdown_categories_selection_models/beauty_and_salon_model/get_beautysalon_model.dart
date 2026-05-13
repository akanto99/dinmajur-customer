// To parse this JSON data, do
//
//     final getHomeBeautySalonModel = getHomeBeautySalonModelFromJson(jsonString);

import 'dart:convert';

GetHomeBeautySalonModel getHomeBeautySalonModelFromJson(String str) => GetHomeBeautySalonModel.fromJson(json.decode(str));

String getHomeBeautySalonModelToJson(GetHomeBeautySalonModel data) => json.encode(data.toJson());

class GetHomeBeautySalonModel {
  bool? success;
  String? message;
  Data? data;

  GetHomeBeautySalonModel({
    this.success,
    this.message,
    this.data,
  });

  factory GetHomeBeautySalonModel.fromJson(Map<String, dynamic> json) => GetHomeBeautySalonModel(
    success: json["success"],
    message: json["message"],
    data: json["data"] == null ? null : Data.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "data": data?.toJson(),
  };
}

class Data {
  String? id;
  dynamic userId;
  String? trackingId;
  String? serviceType;
  String? paymentType;
  String? fullName;
  String? fullAddress;
  String? email;
  String? phone;
  String? notes;
  List<dynamic>? images;
  DateTime? date;
  String? time;
  String? discountType;
  double? total;
  double? subTotal;
  double? grandTotal;
  double? vat;
  double? fare;
  double? discountValue;
  String? status;
  String? paymentStatus;
  List<BeautySalonBookingItem>? beautySalonBookingItems;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? v;

  Data({
    this.id,
    this.userId,
    this.trackingId,
    this.serviceType,
    this.paymentType,
    this.fullName,
    this.fullAddress,
    this.email,
    this.phone,
    this.notes,
    this.images,
    this.date,
    this.time,
    this.discountType,
    this.discountValue,
    this.total,
    this.subTotal,
    this.grandTotal,
    this.vat,
    this.fare,
    this.status,
    this.paymentStatus,
    this.beautySalonBookingItems,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    id: json["_id"],
    userId: json["userId"],
    trackingId: json["trackingId"],
    serviceType: json["serviceType"],
    paymentType: json["paymentType"],
    fullName: json["fullName"],
    fullAddress: json["fullAddress"],
    email: json["email"],
    phone: json["phone"],
    notes: json["notes"],
    images: json["images"] == null ? [] : List<dynamic>.from(json["images"]!.map((x) => x)),
    date: json["date"] == null ? null : DateTime.parse(json["date"]),
    time: json["time"],
    discountType: json["discountType"],
    total: (json["total"] as num?)?.toDouble(),
    subTotal: (json["subTotal"] as num?)?.toDouble(),
    grandTotal: (json["grandTotal"] as num?)?.toDouble(),
    vat: (json["vat"] as num?)?.toDouble(),
    fare: (json["fare"] as num?)?.toDouble(),
    discountValue: (json["discountValue"] as num?)?.toDouble(),
    status: json["status"],
    paymentStatus: json["paymentStatus"],
    beautySalonBookingItems: json["beautySalonBookingItems"] == null ? [] : List<BeautySalonBookingItem>.from(json["beautySalonBookingItems"]!.map((x) => BeautySalonBookingItem.fromJson(x))),
    createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
    updatedAt: json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
    v: json["__v"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "userId": userId,
    "trackingId": trackingId,
    "serviceType": serviceType,
    "paymentType": paymentType,
    "fullName": fullName,
    "fullAddress": fullAddress,
    "email": email,
    "phone": phone,
    "notes": notes,
    "images": images == null ? [] : List<dynamic>.from(images!.map((x) => x)),
    "date": date?.toIso8601String(),
    "time": time,
    "discountType": discountType,
    "discountValue": discountValue,
    "total": total,
    "subTotal": subTotal,
    "grandTotal": grandTotal,
    "vat": vat,
    "fare": fare,
    "status": status,
    "paymentStatus": paymentStatus,
    "beautySalonBookingItems": beautySalonBookingItems == null ? [] : List<dynamic>.from(beautySalonBookingItems!.map((x) => x.toJson())),
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
    "__v": v,
  };
}

class BeautySalonBookingItem {
  String? id;
  String? beautySalonBookingId;
  BeautySalonTaskId? beautySalonTaskId;
  List<BeautySalonTaskItemId>? beautySalonTaskItemIds;
  int? quantity;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? v;

  BeautySalonBookingItem({
    this.id,
    this.beautySalonBookingId,
    this.beautySalonTaskId,
    this.beautySalonTaskItemIds,
    this.quantity,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  factory BeautySalonBookingItem.fromJson(Map<String, dynamic> json) => BeautySalonBookingItem(
    id: json["_id"],
    beautySalonBookingId: json["beautySalonBookingId"],
    beautySalonTaskId: json["beautySalonTaskId"] == null ? null : BeautySalonTaskId.fromJson(json["beautySalonTaskId"]),
    beautySalonTaskItemIds: json["beautySalonTaskItemIds"] == null ? [] : List<BeautySalonTaskItemId>.from(json["beautySalonTaskItemIds"]!.map((x) => BeautySalonTaskItemId.fromJson(x))),
    quantity: json["quantity"],
    createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
    updatedAt: json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
    v: json["__v"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "beautySalonBookingId": beautySalonBookingId,
    "beautySalonTaskId": beautySalonTaskId?.toJson(),
    "beautySalonTaskItemIds": beautySalonTaskItemIds == null ? [] : List<dynamic>.from(beautySalonTaskItemIds!.map((x) => x.toJson())),
    "quantity": quantity,
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
    "__v": v,
  };
}

class BeautySalonTaskId {
  String? id;
  String? name;

  BeautySalonTaskId({
    this.id,
    this.name,
  });

  factory BeautySalonTaskId.fromJson(Map<String, dynamic> json) => BeautySalonTaskId(
    id: json["_id"],
    name: json["name"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "name": name,
  };
}

class BeautySalonTaskItemId {
  String? id;
  String? name;
  double? originalPrice;
  double? salePrice;
  String? discountType;
  int? discountValue;

  BeautySalonTaskItemId({
    this.id,
    this.name,
    this.originalPrice,
    this.salePrice,
    this.discountType,
    this.discountValue,
  });

  factory BeautySalonTaskItemId.fromJson(Map<String, dynamic> json) => BeautySalonTaskItemId(
    id: json["_id"],
    name: json["name"],
    originalPrice: (json["originalPrice"] as num?)?.toDouble(),
    salePrice: (json["salePrice"] as num?)?.toDouble(),
    discountType: json["discountType"],
    discountValue: json["discountValue"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "name": name,
    "originalPrice": originalPrice,
    "salePrice": salePrice,
    "discountType": discountType,
    "discountValue": discountValue,
  };
}
