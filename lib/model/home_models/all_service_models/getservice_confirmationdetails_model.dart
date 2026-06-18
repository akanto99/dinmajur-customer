import 'dart:convert';

ServiceConfirmationDetailsModel serviceConfirmationDetailsModelFromJson(String str) => ServiceConfirmationDetailsModel.fromJson(json.decode(str));

class ServiceConfirmationDetailsModel {
  bool? success;
  String? message;
  Data? data;

  ServiceConfirmationDetailsModel({this.success, this.message, this.data});

  factory ServiceConfirmationDetailsModel.fromJson(Map<String, dynamic> json) =>
      ServiceConfirmationDetailsModel(success: json["success"], message: json["message"], data: json["data"] == null ? null : Data.fromJson(json["data"]));
}

class Data {
  String? id;
  String? trackingId;
  String? fullName;
  String? fullAddress;
  String? email;
  String? phone;
  String? notes;
  DateTime? date;
  String? time;
  TimeSlotSnapshot? timeSlotSnapshot;
  double? subTotal;
  double? vat;
  double? fare;
  double? total;
  double? grandTotal;
  String? status;
  Service? serviceSnapshot;
  String? paymentType;
  String? paymentStatus;
  List<BookingItem>? bookingItems;
  num? discountValue;

  String? extraItemsTrackingId;
  String? extraItemsPaymentStatus;
  String? extraItemsStatus;
  num? totalExtraAmount;
  List<ExtraItem>? extraItems;

  Data({
    this.id,
    this.trackingId,
    this.fullName,
    this.fullAddress,
    this.email,
    this.phone,
    this.notes,
    this.date,
    this.time,
    this.timeSlotSnapshot,
    this.subTotal,
    this.vat,
    this.fare,
    this.total,
    this.grandTotal,
    this.status,
    this.serviceSnapshot,
    this.paymentType,
    this.paymentStatus,
    this.bookingItems,
    this.discountValue,

    this.extraItemsTrackingId,
    this.extraItemsPaymentStatus,
    this.extraItemsStatus,
    this.totalExtraAmount,
    this.extraItems,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    id: json["_id"],
    trackingId: json["trackingId"],
    fullName: json["fullName"],
    fullAddress: json["fullAddress"],
    email: json["email"],
    phone: json["phone"],
    notes: json["notes"],
    date: json["date"] == null ? null : DateTime.parse(json["date"]),
    time: json["time"],
    timeSlotSnapshot: json["timeSlotSnapshot"] == null ? null : TimeSlotSnapshot.fromJson(json["timeSlotSnapshot"]),
    subTotal: (json["subTotal"] as num?)?.toDouble(),
    vat: (json["vat"] as num?)?.toDouble(),
    fare: (json["fare"] as num?)?.toDouble(),
    total: (json["total"] as num?)?.toDouble(),
    grandTotal: (json["grandTotal"] as num?)?.toDouble(),
    status: json["status"],
    serviceSnapshot: json["serviceSnapshot"] == null ? null : Service.fromJson(json["serviceSnapshot"]),
    paymentType: json["paymentType"],
    paymentStatus: json["paymentStatus"],
    bookingItems: json["bookingItems"] == null ? [] : List<BookingItem>.from(json["bookingItems"]!.map((x) => BookingItem.fromJson(x))),
    discountValue: json["discountValue"],


    extraItemsTrackingId: json["extraItemsTrackingId"],
    extraItemsPaymentStatus: json["extraItemsPaymentStatus"],
    extraItemsStatus: json["extraItemsStatus"],
    totalExtraAmount: json["totalExtraAmount"],
    extraItems: json["extraItems"] == null ? [] : List<ExtraItem>.from(json["extraItems"]!.map((x) => ExtraItem.fromJson(x))),
  );
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



class BookingItem {
  String? id;
  Task? task;
  int? quantity;
  String? status;

  BookingItem({this.id, this.task, this.quantity, this.status});

  factory BookingItem.fromJson(Map<String, dynamic> json) =>
      BookingItem(id: json["_id"], task: json["task"] == null ? null : Task.fromJson(json["task"]), quantity: json["quantity"], status: json["status"]);
}

class Task {
  String? name;
  Price? price;

  Task({this.name, this.price});

  factory Task.fromJson(Map<String, dynamic> json) => Task(name: json["name"], price: json["price"] == null ? null : Price.fromJson(json["price"]));
}

class Price {
  double? basePrice;
  double? salePrice;

  Price({this.basePrice, this.salePrice});

  factory Price.fromJson(Map<String, dynamic> json) => Price(  basePrice: (json["basePrice"] as num?)?.toDouble(),
    salePrice: (json["salePrice"] as num?)?.toDouble(),);
}

class Service {
  String? id;
  String? name;

  Service({this.id, this.name});

  factory Service.fromJson(Map<String, dynamic> json) => Service(id: json["_id"], name: json["name"]);
}

class TimeSlotSnapshot {
  String? id;
  String? timeLabel;

  TimeSlotSnapshot({this.id, this.timeLabel});

  factory TimeSlotSnapshot.fromJson(Map<String, dynamic> json) => TimeSlotSnapshot(id: json["_id"], timeLabel: json["timeLabel"]);
}
