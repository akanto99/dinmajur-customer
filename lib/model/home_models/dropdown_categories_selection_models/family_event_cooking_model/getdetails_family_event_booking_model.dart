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

  factory GetDetailesFamilyEventBookingModel.fromJson(Map<String, dynamic> json) =>
      GetDetailesFamilyEventBookingModel(
        success: json["success"],
        message: json["message"],
        meta: json["meta"],
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "meta": meta,
    "data": data?.toJson(),
  };
}

class Data {
  String? id;
  String? customerId;
  String? trackingId;
  String? paymentType;
  String? fullName;
  String? fullAddress;
  String? email;
  String? phone;
  String? slot;
  DateTime? date;
  String? discountType;
  num? discountValue;
  num? total;
  num? subTotal;
  num? grandTotal;
  num? vat;
  num? transportFee;
  String? status;
  String? paymentStatus;
  dynamic eventCookingCategory; // Can be String (ID) or EventCookingCategory object
  List<BookingItem>? items;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? v;

  Data({
    this.id,
    this.customerId,
    this.trackingId,
    this.paymentType,
    this.fullName,
    this.fullAddress,
    this.email,
    this.phone,
    this.slot,
    this.date,
    this.discountType,
    this.discountValue,
    this.total,
    this.subTotal,
    this.grandTotal,
    this.vat,
    this.transportFee,
    this.status,
    this.paymentStatus,
    this.eventCookingCategory,
    this.items,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  // Helper to get category name safely
  String? get categoryName {
    if (eventCookingCategory == null) return null;
    if (eventCookingCategory is String) return null; // Just an ID, no name available
    if (eventCookingCategory is Map || eventCookingCategory is EventCookingCategory) {
      try {
        return eventCookingCategory is EventCookingCategory
            ? eventCookingCategory.name
            : eventCookingCategory['name'];
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  // Helper to get category ID safely
  String? get categoryId {
    if (eventCookingCategory == null) return null;
    if (eventCookingCategory is String) return eventCookingCategory;
    if (eventCookingCategory is Map) return eventCookingCategory['_id'];
    if (eventCookingCategory is EventCookingCategory) return eventCookingCategory.id;
    return null;
  }

  factory Data.fromJson(Map<String, dynamic> json) {
    // Handle eventCookingCategory - can be String or Object
    dynamic parsedCategory;
    if (json["eventCookingCategory"] != null) {
      if (json["eventCookingCategory"] is String) {
        // It's just an ID string
        parsedCategory = json["eventCookingCategory"];
      } else if (json["eventCookingCategory"] is Map<String, dynamic>) {
        // It's a full object
        parsedCategory = EventCookingCategory.fromJson(json["eventCookingCategory"]);
      }
    }

    return Data(
      id: json["_id"],
      customerId: json["customerId"],
      trackingId: json["trackingId"],
      paymentType: json["paymentType"],
      fullName: json["fullName"],
      fullAddress: json["fullAddress"],
      email: json["email"],
      phone: json["phone"],
      slot: json["slot"],
      date: json["date"] == null ? null : DateTime.parse(json["date"]),
      discountType: json["discountType"],
      discountValue: json["discountValue"],
      total: json["total"],
      subTotal: json["subTotal"],
      grandTotal: json["grandTotal"],
      vat: json["vat"],
      transportFee: json["transport_fee"],
      status: json["status"],
      paymentStatus: json["paymentStatus"],
      eventCookingCategory: parsedCategory,
      items: json["items"] == null
          ? []
          : List<BookingItem>.from(
          json["items"].map((x) => BookingItem.fromJson(x))),
      createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
      updatedAt: json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
      v: json["__v"],
    );
  }

  Map<String, dynamic> toJson() {
    dynamic categoryJson;
    if (eventCookingCategory != null) {
      if (eventCookingCategory is String) {
        categoryJson = eventCookingCategory;
      } else if (eventCookingCategory is EventCookingCategory) {
        categoryJson = eventCookingCategory.toJson();
      }
    }

    return {
      "_id": id,
      "customerId": customerId,
      "trackingId": trackingId,
      "paymentType": paymentType,
      "fullName": fullName,
      "fullAddress": fullAddress,
      "email": email,
      "phone": phone,
      "slot": slot,
      "date": date?.toIso8601String(),
      "discountType": discountType,
      "discountValue": discountValue,
      "total": total,
      "subTotal": subTotal,
      "grandTotal": grandTotal,
      "vat": vat,
      "transport_fee": transportFee,
      "status": status,
      "paymentStatus": paymentStatus,
      "eventCookingCategory": categoryJson,
      "items": items?.map((x) => x.toJson()).toList() ?? [],
      "createdAt": createdAt?.toIso8601String(),
      "updatedAt": updatedAt?.toIso8601String(),
      "__v": v,
    };
  }
}

class EventCookingCategory {
  String? id;
  String? name;
  dynamic image;
  String? type;
  int? position;

  EventCookingCategory({
    this.id,
    this.name,
    this.image,
    this.type,
    this.position,
  });

  factory EventCookingCategory.fromJson(Map<String, dynamic> json) =>
      EventCookingCategory(
        id: json["_id"],
        name: json["name"],
        image: json["image"],
        type: json["type"],
        position: json["position"],
      );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "name": name,
    "image": image,
    "type": type,
    "position": position,
  };
}

class BookingItem {
  String? id;
  String? eventCookingBooking;
  Package? package;
  Price? price; // For REGULAR bookings
  List<ItemWrapper>? items; // For MANUAL bookings (array of items)
  DateTime? createdAt;
  DateTime? updatedAt;
  int? v;

  BookingItem({
    this.id,
    this.eventCookingBooking,
    this.package,
    this.price,
    this.items,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  // Helper to determine if this is a manual booking
  bool get isManual => items != null && items!.isNotEmpty;

  // Helper to get all item details (works for both regular and manual)
  List<String> get itemNames {
    if (isManual) {
      return items?.map((e) => e.item?.name ?? '').where((n) => n.isNotEmpty).toList() ?? [];
    }
    return package?.name != null ? [package!.name!] : [];
  }

  // Helper to get the price details for regular bookings
  Price? get regularPrice => price;

  // Helper to get all prices for manual bookings
  List<Price> get manualPrices {
    if (isManual) {
      return items?.map((e) => e.price).where((p) => p != null).cast<Price>().toList() ?? [];
    }
    return [];
  }

  factory BookingItem.fromJson(Map<String, dynamic> json) => BookingItem(
    id: json["_id"],
    eventCookingBooking: json["eventCookingBooking"],
    package: json["package"] == null ? null : Package.fromJson(json["package"]),
    price: json["price"] == null ? null : Price.fromJson(json["price"]),
    items: json["items"] == null
        ? null
        : List<ItemWrapper>.from(
        json["items"].map((x) => ItemWrapper.fromJson(x))),
    createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
    updatedAt: json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
    v: json["__v"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "eventCookingBooking": eventCookingBooking,
    "package": package?.toJson(),
    "price": price?.toJson(),
    "items": items?.map((x) => x.toJson()).toList(),
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
  GuestRange? guestRange;
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
    guestRange: json["guestRange"] == null
        ? null
        : GuestRange.fromJson(json["guestRange"]),
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
    "guestRange": guestRange?.toJson(),
    "originalPrice": originalPrice,
    "salePrice": salePrice,
    "discountType": discountType,
    "discountValue": discountValue,
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
    "__v": v,
  };
}

class GuestRange {
  String? label;

  GuestRange({this.label});

  factory GuestRange.fromJson(Map<String, dynamic> json) => GuestRange(
    label: json["label"],
  );

  Map<String, dynamic> toJson() => {
    "label": label,
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