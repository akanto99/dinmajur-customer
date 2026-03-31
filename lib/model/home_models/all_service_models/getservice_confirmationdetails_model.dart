import 'dart:convert';

ServiceConfirmationDetailsModel serviceConfirmationDetailsModelFromJson(String str) =>
    ServiceConfirmationDetailsModel.fromJson(json.decode(str));

String serviceConfirmationDetailsModelToJson(ServiceConfirmationDetailsModel data) =>
    json.encode(data.toJson());

class ServiceConfirmationDetailsModel {
  bool? success;
  String? message;
  Data? data;

  ServiceConfirmationDetailsModel({
    this.success,
    this.message,
    this.data,
  });

  factory ServiceConfirmationDetailsModel.fromJson(Map<String, dynamic> json) =>
      ServiceConfirmationDetailsModel(
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
  int? discountValue;
  int? total;
  int? subTotal;
  int? grandTotal;
  int? vat;
  int? fare;
  String? status;
  List<ServiceBookingItem>? serviceBookingItems;
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
    this.serviceBookingItems,
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
    images: json["images"] == null
        ? []
        : List<dynamic>.from(json["images"]!.map((x) => x)),
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
    serviceBookingItems: json["serviceBookingItems"] == null
        ? []
        : List<ServiceBookingItem>.from(json["serviceBookingItems"]!
        .map((x) => ServiceBookingItem.fromJson(x))),
    createdAt: json["createdAt"] == null
        ? null
        : DateTime.parse(json["createdAt"]),
    updatedAt: json["updatedAt"] == null
        ? null
        : DateTime.parse(json["updatedAt"]),
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
    "images": images == null
        ? []
        : List<dynamic>.from(images!.map((x) => x)),
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
    "serviceBookingItems": serviceBookingItems == null
        ? []
        : List<dynamic>.from(
        serviceBookingItems!.map((x) => x.toJson())),
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
    "__v": v,
  };
}

class ServiceBookingItem {
  String? id;
  String? serviceBookingId;
  ServiceTaskId? serviceTaskId;
  List<ServiceTaskItemId>? serviceTaskItemIds;
  int? quantity;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? v;

  ServiceBookingItem({
    this.id,
    this.serviceBookingId,
    this.serviceTaskId,
    this.serviceTaskItemIds,
    this.quantity,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  factory ServiceBookingItem.fromJson(Map<String, dynamic> json) =>
      ServiceBookingItem(
        id: json["_id"],
        serviceBookingId: json["serviceBookingId"],
        serviceTaskId: json["serviceTaskId"] == null
            ? null
            : ServiceTaskId.fromJson(json["serviceTaskId"]),
        serviceTaskItemIds: json["serviceTaskItemIds"] == null
            ? []
            : List<ServiceTaskItemId>.from(json["serviceTaskItemIds"]!
            .map((x) => ServiceTaskItemId.fromJson(x))),
        quantity: json["quantity"],
        createdAt: json["createdAt"] == null
            ? null
            : DateTime.parse(json["createdAt"]),
        updatedAt: json["updatedAt"] == null
            ? null
            : DateTime.parse(json["updatedAt"]),
        v: json["__v"],
      );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "serviceBookingId": serviceBookingId,
    "serviceTaskId": serviceTaskId?.toJson(),
    "serviceTaskItemIds": serviceTaskItemIds == null
        ? []
        : List<dynamic>.from(
        serviceTaskItemIds!.map((x) => x.toJson())),
    "quantity": quantity,
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
    "__v": v,
  };
}

class ServiceTaskId {
  String? id;
  String? name;

  ServiceTaskId({
    this.id,
    this.name,
  });

  factory ServiceTaskId.fromJson(Map<String, dynamic> json) =>
      ServiceTaskId(
        id: json["_id"],
        name: json["name"],
      );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "name": name,
  };
}

class ServiceTaskItemId {
  String? id;
  String? name;
  int? originalPrice;
  int? salePrice;
  String? discountType;
  int? discountValue;

  ServiceTaskItemId({
    this.id,
    this.name,
    this.originalPrice,
    this.salePrice,
    this.discountType,
    this.discountValue,
  });

  factory ServiceTaskItemId.fromJson(Map<String, dynamic> json) =>
      ServiceTaskItemId(
        id: json["_id"],
        name: json["name"],
        originalPrice: json["originalPrice"],
        salePrice: json["salePrice"],
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