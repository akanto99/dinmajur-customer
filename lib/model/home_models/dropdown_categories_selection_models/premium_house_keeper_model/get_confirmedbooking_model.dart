// To parse this JSON data, do
//
//     final getConfirmedBookingModel = getConfirmedBookingModelFromJson(jsonString);

import 'dart:convert';

GetConfirmedBookingModel getConfirmedBookingModelFromJson(String str) => GetConfirmedBookingModel.fromJson(json.decode(str));

String getConfirmedBookingModelToJson(GetConfirmedBookingModel data) => json.encode(data.toJson());

class GetConfirmedBookingModel {
  bool? success;
  String? message;
  Data? data;

  GetConfirmedBookingModel({
    this.success,
    this.message,
    this.data,
  });

  factory GetConfirmedBookingModel.fromJson(Map<String, dynamic> json) => GetConfirmedBookingModel(
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
  String? userId;
  String? trackingId;
  String? serviceType;
  String? district;
  String? area;
  String? fullName;
  String? fullAddress;
  String? houseSize;
  String? email;
  String? phone;
  String? notes;
  List<dynamic>? images;
  ShiftId? shiftId;
  String? paymentType;
  String? discountType;
  num? discountValue; // Changed from int? to num?
  num? total; // Changed from int? to num?
  num? subTotal; // Changed from int? to num?
  num? grandTotal; // Changed from int? to num?
  num? vat; // Changed from int? to num?
  num? fare; // Changed from int? to num?
  String? status;
  List<HouseKeeperBookingItem>? houseKeeperBookingItems;
  DateTime? createdAt;
  DateTime? updatedAt;

  Data({
    this.id,
    this.userId,
    this.trackingId,
    this.serviceType,
    this.district,
    this.area,
    this.fullName,
    this.fullAddress,
    this.houseSize,
    this.email,
    this.phone,
    this.notes,
    this.images,
    this.shiftId,
    this.paymentType,
    this.discountType,
    this.discountValue,
    this.total,
    this.subTotal,
    this.grandTotal,
    this.vat,
    this.fare,
    this.status,
    this.houseKeeperBookingItems,
    this.createdAt,
    this.updatedAt,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    id: json["_id"],
    userId: json["userId"],
    trackingId: json["trackingId"],
    serviceType: json["serviceType"],
    district: json["district"],
    area: json["area"],
    fullName: json["fullName"],
    fullAddress: json["fullAddress"],
    houseSize: json["houseSize"],
    email: json["email"],
    phone: json["phone"],
    notes: json["notes"],
    images: json["images"] == null ? [] : List<dynamic>.from(json["images"]!.map((x) => x)),
    shiftId: json["shiftId"] == null ? null : ShiftId.fromJson(json["shiftId"]),
    paymentType: json["paymentType"],
    discountType: json["discountType"],
    discountValue: json["discountValue"],
    total: json["total"],
    subTotal: json["subTotal"],
    grandTotal: json["grandTotal"],
    vat: json["vat"],
    fare: json["fare"],
    status: json["status"],
    houseKeeperBookingItems: json["houseKeeperBookingItems"] == null ? [] : List<HouseKeeperBookingItem>.from(json["houseKeeperBookingItems"]!.map((x) => HouseKeeperBookingItem.fromJson(x))),
    createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
    updatedAt: json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "userId": userId,
    "trackingId": trackingId,
    "serviceType": serviceType,
    "district": district,
    "area": area,
    "fullName": fullName,
    "fullAddress": fullAddress,
    "houseSize": houseSize,
    "email": email,
    "phone": phone,
    "notes": notes,
    "images": images == null ? [] : List<dynamic>.from(images!.map((x) => x)),
    "shiftId": shiftId?.toJson(),
    "paymentType": paymentType,
    "discountType": discountType,
    "discountValue": discountValue,
    "total": total,
    "subTotal": subTotal,
    "grandTotal": grandTotal,
    "vat": vat,
    "fare": fare,
    "status": status,
    "houseKeeperBookingItems": houseKeeperBookingItems == null ? [] : List<dynamic>.from(houseKeeperBookingItems!.map((x) => x.toJson())),
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
  };
}

class HouseKeeperBookingItem {
  String? id;
  String? houseKeeperBookingId;
  HouseKeeperTaskId? houseKeeperTaskId;
  List<HouseKeeperTaskItemId>? houseKeeperTaskItemIds;
  int? totalRooms;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? v;

  HouseKeeperBookingItem({
    this.id,
    this.houseKeeperBookingId,
    this.houseKeeperTaskId,
    this.houseKeeperTaskItemIds,
    this.totalRooms,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  factory HouseKeeperBookingItem.fromJson(Map<String, dynamic> json) => HouseKeeperBookingItem(
    id: json["_id"],
    houseKeeperBookingId: json["houseKeeperBookingId"],
    houseKeeperTaskId: json["houseKeeperTaskId"] == null ? null : HouseKeeperTaskId.fromJson(json["houseKeeperTaskId"]),
    houseKeeperTaskItemIds: json["houseKeeperTaskItemIds"] == null ? [] : List<HouseKeeperTaskItemId>.from(json["houseKeeperTaskItemIds"]!.map((x) => HouseKeeperTaskItemId.fromJson(x))),
    totalRooms: json["totalRooms"],
    createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
    updatedAt: json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
    v: json["__v"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "houseKeeperBookingId": houseKeeperBookingId,
    "houseKeeperTaskId": houseKeeperTaskId?.toJson(),
    "houseKeeperTaskItemIds": houseKeeperTaskItemIds == null ? [] : List<dynamic>.from(houseKeeperTaskItemIds!.map((x) => x.toJson())),
    "totalRooms": totalRooms,
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
    "__v": v,
  };
}

class HouseKeeperTaskId {
  String? id;
  String? name;
  bool? hasRoom;

  HouseKeeperTaskId({
    this.id,
    this.name,
    this.hasRoom,
  });

  factory HouseKeeperTaskId.fromJson(Map<String, dynamic> json) => HouseKeeperTaskId(
    id: json["_id"],
    name: json["name"],
    hasRoom: json["hasRoom"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "name": name,
    "hasRoom": hasRoom,
  };
}

class HouseKeeperTaskItemId {
  String? id;
  String? name;
  num? price; // Changed from int? to num?

  HouseKeeperTaskItemId({
    this.id,
    this.name,
    this.price,
  });

  factory HouseKeeperTaskItemId.fromJson(Map<String, dynamic> json) => HouseKeeperTaskItemId(
    id: json["_id"],
    name: json["name"],
    price: json["price"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "name": name,
    "price": price,
  };
}

class ShiftId {
  String? id;
  String? type;
  String? startTime;
  String? endTime;

  ShiftId({
    this.id,
    this.type,
    this.startTime,
    this.endTime,
  });

  factory ShiftId.fromJson(Map<String, dynamic> json) => ShiftId(
    id: json["_id"],
    type: json["type"],
    startTime: json["startTime"],
    endTime: json["endTime"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "type": type,
    "startTime": startTime,
    "endTime": endTime,
  };
}