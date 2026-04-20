import 'dart:convert';

GetBookedTimeSlotModel getBookedTimeSlotModelFromJson(String str) =>
    GetBookedTimeSlotModel.fromJson(json.decode(str));

String getBookedTimeSlotModelToJson(GetBookedTimeSlotModel data) =>
    json.encode(data.toJson());

class GetBookedTimeSlotModel {
  bool? success;
  String? message;
  Meta? meta;
  List<BookedSlotDatum>? data;

  GetBookedTimeSlotModel({this.success, this.message, this.meta, this.data});

  factory GetBookedTimeSlotModel.fromJson(Map<String, dynamic> json) =>
      GetBookedTimeSlotModel(
        success: json["success"],
        message: json["message"],
        meta: json["meta"] == null ? null : Meta.fromJson(json["meta"]),
        data: json["data"] == null
            ? []
            : List<BookedSlotDatum>.from(
            json["data"]!.map((x) => BookedSlotDatum.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "meta": meta?.toJson(),
    "data": data == null
        ? []
        : List<dynamic>.from(data!.map((x) => x.toJson())),
  };
}

class Meta {
  int? total;

  Meta({this.total});

  factory Meta.fromJson(Map<String, dynamic> json) => Meta(total: json["total"]);

  Map<String, dynamic> toJson() => {"total": total};
}

class BookedSlotDatum {
  String? id;
  String? time;
  bool? isActive;
  int? position;
  bool? isBooked;


  BookedSlotDatum({
    this.id,
    this.time,
    this.isActive,
    this.position,
    this.isBooked

  });

  /// Convenience getter — reads isBooked from the nested availability object
  bool get isBookedSlot => isBooked ?? false;

  factory BookedSlotDatum.fromJson(Map<String, dynamic> json) =>
      BookedSlotDatum(
        id: json["_id"],
        time: json["time"],
        isActive: json["isActive"],
        position: json["position"],
          isBooked: json["isBooked"],
      );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "time": time,
    "isActive": isActive,
    "position": position,
    "isBooked": isBooked,

  };
}
//
// class Availability {
//   String? date;
//   bool? isBooked;
//
//   Availability({this.date, this.isBooked});
//
//   factory Availability.fromJson(Map<String, dynamic> json) => Availability(
//     date: json["date"],
//     isBooked: json["isBooked"],
//   );
//
//   Map<String, dynamic> toJson() => {
//     "date": date,
//     "isBooked": isBooked,
//   };
// }