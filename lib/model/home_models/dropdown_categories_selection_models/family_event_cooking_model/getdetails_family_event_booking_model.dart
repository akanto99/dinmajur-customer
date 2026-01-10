import 'dart:convert';

GetDetailesFamilyEventBookingModel getDetailesFamilyEventBookingModelFromJson(String str) => GetDetailesFamilyEventBookingModel.fromJson(json.decode(str));

String getDetailesFamilyEventBookingModelToJson(GetDetailesFamilyEventBookingModel data) => json.encode(data.toJson());

class GetDetailesFamilyEventBookingModel {
  bool? success;
  String? message;
  Data? data;

  GetDetailesFamilyEventBookingModel({this.success, this.message, this.data});

  factory GetDetailesFamilyEventBookingModel.fromJson(Map<String, dynamic> json) =>
      GetDetailesFamilyEventBookingModel(success: json["success"], message: json["message"], data: json["data"] == null ? null : Data.fromJson(json["data"]));

  Map<String, dynamic> toJson() => {"success": success, "message": message, "data": data?.toJson()};
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
  int? discountValue;
  int? total;
  int? subTotal;
  int? grandTotal;
  int? vat;
  int? fare;
  String? status;
  List<FamilyEventBookingItem>? familyEventBookingItems;
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
    this.familyEventBookingItems,
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
    images: json["images"] == null ? [] : List<dynamic>.from(json["images"]),
    date: json["date"] == null ? null : DateTime.parse(json["date"]),
    time: json["time"],
    discountType: json["discountType"],
    discountValue: json["discountValue"],
    total: json["total"],
    subTotal: json["subTotal"],
    grandTotal: json["grandTotal"],
    vat: json["vat"],
    fare: json["fare"],
    status: json["status"],
    familyEventBookingItems: json["familyEventBookingItems"] == null ? [] : List<FamilyEventBookingItem>.from(json["familyEventBookingItems"].map((x) => FamilyEventBookingItem.fromJson(x))),
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
    "images": images ?? [],
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
    "familyEventBookingItems": familyEventBookingItems?.map((x) => x.toJson()).toList() ?? [],
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
    "__v": v,
  };
}

class FamilyEventBookingItem {
  String? id;
  String? bookingId;
  EventTaskId? eventTaskId;
  List<EventTaskItemId>? eventTaskItemIds;
  int? quantity;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? v;

  FamilyEventBookingItem({this.id, this.bookingId, this.eventTaskId, this.eventTaskItemIds, this.quantity, this.createdAt, this.updatedAt, this.v});

  factory FamilyEventBookingItem.fromJson(Map<String, dynamic> json) => FamilyEventBookingItem(
    id: json["_id"],
    bookingId: json["bookingId"],
    eventTaskId: json["eventTaskId"] == null ? null : EventTaskId.fromJson(json["eventTaskId"]),
    eventTaskItemIds: json["eventTaskItemIds"] == null ? [] : List<EventTaskItemId>.from(json["eventTaskItemIds"].map((x) => EventTaskItemId.fromJson(x))),
    quantity: json["quantity"],
    createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
    updatedAt: json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
    v: json["__v"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "bookingId": bookingId,
    "eventTaskId": eventTaskId?.toJson(),
    "eventTaskItemIds": eventTaskItemIds?.map((x) => x.toJson()).toList() ?? [],
    "quantity": quantity,
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
    "__v": v,
  };
}

class EventTaskId {
  String? id;
  String? name;

  EventTaskId({this.id, this.name});

  factory EventTaskId.fromJson(Map<String, dynamic> json) => EventTaskId(id: json["_id"], name: json["name"]);

  Map<String, dynamic> toJson() => {"_id": id, "name": name};
}

class EventTaskItemId {
  String? id;
  String? name;
  int? originalPrice;
  int? salePrice;
  String? discountType;
  int? discountValue;

  EventTaskItemId({this.id, this.name, this.originalPrice, this.salePrice, this.discountType, this.discountValue});

  factory EventTaskItemId.fromJson(Map<String, dynamic> json) => EventTaskItemId(
    id: json["_id"],
    name: json["name"],
    originalPrice: json["originalPrice"],
    salePrice: json["salePrice"],
    discountType: json["discountType"],
    discountValue: json["discountValue"],
  );

  Map<String, dynamic> toJson() => {"_id": id, "name": name, "originalPrice": originalPrice, "salePrice": salePrice, "discountType": discountType, "discountValue": discountValue};
}
