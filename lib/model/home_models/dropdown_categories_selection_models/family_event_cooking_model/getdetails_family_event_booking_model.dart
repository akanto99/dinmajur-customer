import 'dart:convert';

GetDetailesFamilyEventBookingModel getDetailesFamilyEventBookingModelFromJson(String str) =>
    GetDetailesFamilyEventBookingModel.fromJson(json.decode(str));

String getDetailesFamilyEventBookingModelToJson(GetDetailesFamilyEventBookingModel data) =>
    json.encode(data.toJson());

class GetDetailesFamilyEventBookingModel {
  bool? success;
  String? message;
  dynamic meta;
  Data? data;

  GetDetailesFamilyEventBookingModel({
    this.success,
    this.message,
    this.meta,
    this.data
  });

  factory GetDetailesFamilyEventBookingModel.fromJson(Map<String, dynamic> json) {
    // Handle both structures:
    // REGULAR: { success, message, meta, data: { _id, trackingId, ... } }
    // MANUAL: { success, message, meta, data: { success, message, data: { _id, trackingId, ... } } }

    Data? parsedData;
    if (json["data"] != null) {
      // Check if data contains nested 'data' field (MANUAL structure)
      if (json["data"]["data"] != null) {
        parsedData = Data.fromJson(json["data"]["data"]);
      } else {
        // Direct data field (REGULAR structure)
        parsedData = Data.fromJson(json["data"]);
      }
    }

    return GetDetailesFamilyEventBookingModel(
      success: json["success"],
      message: json["message"],
      meta: json["meta"],
      data: parsedData,
    );
  }

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "meta": meta,
    "data": data?.toJson(),
  };
}

class Data {
  String? id;
  String? trackingId;
  String? paymentType;
  String? fullName;
  String? fullAddress;
  String? email;
  String? phone;
  DateTime? date;
  String? discountType;
  num? discountValue;
  num? total;
  num? subTotal;
  num? grandTotal;
  num? vat;
  num? transportFee;
  String? status;
  String? eventCookingCategory;
  List<EventCookingItem>? items;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? v;

  Data({
    this.id,
    this.trackingId,
    this.paymentType,
    this.fullName,
    this.fullAddress,
    this.email,
    this.phone,
    this.date,
    this.discountType,
    this.discountValue,
    this.total,
    this.subTotal,
    this.grandTotal,
    this.vat,
    this.transportFee,
    this.status,
    this.eventCookingCategory,
    this.items,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    id: json["_id"],
    trackingId: json["trackingId"],
    paymentType: json["paymentType"],
    fullName: json["fullName"],
    fullAddress: json["fullAddress"],
    email: json["email"],
    phone: json["phone"],
    date: json["date"] == null ? null : DateTime.parse(json["date"]),
    discountType: json["discountType"],
    discountValue: json["discountValue"],
    total: json["total"],
    subTotal: json["subTotal"],
    grandTotal: json["grandTotal"],
    vat: json["vat"],
    transportFee: json["transport_fee"],
    status: json["status"],
    eventCookingCategory: json["eventCookingCategory"],
    items: json["items"] == null
        ? []
        : List<EventCookingItem>.from(
        json["items"].map((x) => EventCookingItem.fromJson(x))),
    createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
    updatedAt: json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
    v: json["__v"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "trackingId": trackingId,
    "paymentType": paymentType,
    "fullName": fullName,
    "fullAddress": fullAddress,
    "email": email,
    "phone": phone,
    "date": date?.toIso8601String(),
    "discountType": discountType,
    "discountValue": discountValue,
    "total": total,
    "subTotal": subTotal,
    "grandTotal": grandTotal,
    "vat": vat,
    "transport_fee": transportFee,
    "status": status,
    "eventCookingCategory": eventCookingCategory,
    "items": items?.map((x) => x.toJson()).toList() ?? [],
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
    "__v": v,
  };
}

class EventCookingItem {
  String? id;
  String? eventCookingBooking;
  Package? package;
  Price? price; // For REGULAR bookings
  ItemWrapper? item; // For MANUAL bookings
  DateTime? createdAt;
  DateTime? updatedAt;
  int? v;

  EventCookingItem({
    this.id,
    this.eventCookingBooking,
    this.package,
    this.price,
    this.item,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  // Helper to determine if this is a manual booking
  bool get isManual => item != null;

  // Helper to get the item name (works for both regular and manual)
  String? get itemName {
    if (isManual) {
      return item?.item?.name;
    }
    return package?.name;
  }

  // Helper to get the price details (works for both regular and manual)
  Price? get priceDetails {
    if (isManual) {
      return item?.price;
    }
    return price;
  }

  factory EventCookingItem.fromJson(Map<String, dynamic> json) => EventCookingItem(
    id: json["_id"],
    eventCookingBooking: json["eventCookingBooking"],
    package: json["package"] == null ? null : Package.fromJson(json["package"]),
    price: json["price"] == null ? null : Price.fromJson(json["price"]),
    item: json["item"] == null ? null : ItemWrapper.fromJson(json["item"]),
    createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
    updatedAt: json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
    v: json["__v"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "eventCookingBooking": eventCookingBooking,
    "package": package?.toJson(),
    "price": price?.toJson(),
    "item": item?.toJson(),
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
    "__v": v,
  };
}

class Package {
  String? id;
  String? eventCookingCategory;
  String? name;
  dynamic image;
  int? position;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? v;

  Package({
    this.id,
    this.eventCookingCategory,
    this.name,
    this.image,
    this.position,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  factory Package.fromJson(Map<String, dynamic> json) => Package(
    id: json["_id"] ?? json["id"],
    eventCookingCategory: json["eventCookingCategory"],
    name: json["name"],
    image: json["image"],
    position: json["position"],
    createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
    updatedAt: json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
    v: json["__v"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "eventCookingCategory": eventCookingCategory,
    "name": name,
    "image": image,
    "position": position,
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
    "__v": v,
  };
}

class Price {
  String? id;
  String? referenceType;
  String? referenceId;
  String? guestRange;
  num? originalPrice;
  num? salePrice;
  String? discountType;
  num? discountValue;
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
    referenceType: json["referenceType"],
    referenceId: json["referenceId"],
    guestRange: json["guestRange"],
    originalPrice: json["originalPrice"],
    salePrice: json["salePrice"],
    discountType: json["discountType"],
    discountValue: json["discountValue"],
    createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
    updatedAt: json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
    v: json["__v"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "referenceType": referenceType,
    "referenceId": referenceId,
    "guestRange": guestRange,
    "originalPrice": originalPrice,
    "salePrice": salePrice,
    "discountType": discountType,
    "discountValue": discountValue,
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
    "__v": v,
  };
}

// For MANUAL bookings - nested item structure
class ItemWrapper {
  ItemDetails? item;
  Price? price;

  ItemWrapper({this.item, this.price});

  factory ItemWrapper.fromJson(Map<String, dynamic> json) => ItemWrapper(
    item: json["item"] == null ? null : ItemDetails.fromJson(json["item"]),
    price: json["price"] == null ? null : Price.fromJson(json["price"]),
  );

  Map<String, dynamic> toJson() => {
    "item": item?.toJson(),
    "price": price?.toJson(),
  };
}

class ItemDetails {
  String? id;
  String? eventCookingPackage;
  String? name;
  String? description;
  dynamic image;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? v;

  ItemDetails({
    this.id,
    this.eventCookingPackage,
    this.name,
    this.description,
    this.image,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  factory ItemDetails.fromJson(Map<String, dynamic> json) => ItemDetails(
    id: json["_id"],
    eventCookingPackage: json["eventCookingPackage"],
    name: json["name"],
    description: json["description"],
    image: json["image"],
    createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
    updatedAt: json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
    v: json["__v"],
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
  };
}