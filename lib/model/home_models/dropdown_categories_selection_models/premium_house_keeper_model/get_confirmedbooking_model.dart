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
  String? freelancerId;
  String? userId;
  String? trackingId;
  String? serviceType;
  String? district;
  String? area;
  String? fullName;
  DateTime? date;
  String? fullAddress;
  String? houseSize;
  String? email;
  String? phone;
  String? notes;
  List<dynamic>? images;
  ShiftId? shiftId;
  String? paymentType;
  String? discountType;
  num? discountValue;
  num? total;
  num? subTotal;
  num? grandTotal;
  num? vat;
  num? fare;
  String? status;
  String? paymentStatus;
  List<HouseKeeperBookingItem>? houseKeeperBookingItems;

  String? extraItemsTrackingId;
  String? extraItemsPaymentStatus;
  String? extraItemsStatus;
  List<ExtraItem>? extraItems;
  num?totalExtraAmount;

  DateTime? createdAt;
  DateTime? updatedAt;

  Data({
    this.id,
    this.freelancerId,
    this.userId,
    this.trackingId,
    this.serviceType,
    this.district,
    this.area,
    this.fullName,
    this.date,
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
    this.paymentStatus,
    this.houseKeeperBookingItems,

    this.extraItemsTrackingId,
    this.extraItemsPaymentStatus,
    this.extraItemsStatus,
    this.extraItems,
    this.totalExtraAmount,

    this.createdAt,
    this.updatedAt,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    id: json["_id"],
    freelancerId: json["freelancerId"],
    userId: json["userId"],
    trackingId: json["trackingId"],
    serviceType: json["serviceType"],
    district: json["district"],
    area: json["area"],
    fullName: json["fullName"],
    date: json["date"] == null ? null : DateTime.parse(json["date"]),
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
    paymentStatus: json["paymentStatus"],
    houseKeeperBookingItems: json["houseKeeperBookingItems"] == null ? [] : List<HouseKeeperBookingItem>.from(json["houseKeeperBookingItems"]!.map((x) => HouseKeeperBookingItem.fromJson(x))),

    extraItemsTrackingId: json["extraItemsTrackingId"],
    extraItemsPaymentStatus: json["extraItemsPaymentStatus"],
    extraItemsStatus: json["extraItemsStatus"],
    extraItems: json["extraItems"] == null ? [] : List<ExtraItem>.from(json["extraItems"]!.map((x) => ExtraItem.fromJson(x))),
    totalExtraAmount: json["totalExtraAmount"],

    createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
    updatedAt: json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "freelancerId": freelancerId,
    "userId": userId,
    "trackingId": trackingId,
    "serviceType": serviceType,
    "district": district,
    "area": area,
    "fullName": fullName,
    "date": date?.toIso8601String(),
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
    "paymentStatus": paymentStatus,
    "houseKeeperBookingItems": houseKeeperBookingItems == null ? [] : List<dynamic>.from(houseKeeperBookingItems!.map((x) => x.toJson())),

    "extraItemsTrackingId": extraItemsTrackingId,
    "extraItemsPaymentStatus": extraItemsPaymentStatus,
    "extraItemsStatus": extraItemsStatus,
    "extraItems": extraItems == null ? [] : List<dynamic>.from(extraItems!.map((x) => x.toJson())),
    "totalExtraAmount": totalExtraAmount,

    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
  };
}

class ExtraItem {
  String? id;
  String? name;
  int? price;
  int? quantity;
  int? total;
  String? status;
  DateTime? createdAt;

  ExtraItem({
    this.id,
    this.name,
    this.price,
    this.quantity,
    this.total,
    this.status,
    this.createdAt,
  });

  factory ExtraItem.fromJson(Map<String, dynamic> json) => ExtraItem(
    id: json["_id"],
    name: json["name"],
    price: json["price"],
    quantity: json["quantity"],
    total: json["total"],
    status: json["status"],
    createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "name": name,
    "price": price,
    "quantity": quantity,
    "total": total,
    "status": status,
    "createdAt": createdAt?.toIso8601String(),
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