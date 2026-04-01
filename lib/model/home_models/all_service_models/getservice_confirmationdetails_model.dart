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
  int? subTotal;
  int? vat;
  int? fare;
  int? total;
  int? grandTotal;
  String? status;
  Service? serviceSnapshot;
  String? paymentType;
  List<BookingItem>? bookingItems;
  num? discountValue;

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
    this.bookingItems,
    this.discountValue,
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
    subTotal: json["subTotal"],
    vat: json["vat"],
    fare: json["fare"],
    total: json["total"],
    grandTotal: json["grandTotal"],
    status: json["status"],
    serviceSnapshot: json["serviceSnapshot"] == null ? null : Service.fromJson(json["serviceSnapshot"]),
    paymentType: json["paymentType"],
    bookingItems: json["bookingItems"] == null ? [] : List<BookingItem>.from(json["bookingItems"]!.map((x) => BookingItem.fromJson(x))),
    discountValue: json["discountValue"],
  );
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
  int? basePrice;
  int? salePrice;

  Price({this.basePrice, this.salePrice});

  factory Price.fromJson(Map<String, dynamic> json) => Price(basePrice: json["basePrice"], salePrice: json["salePrice"]);
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
