import 'dart:convert';

GetTimeSlotModel getTimeSlotModelFromJson(String str) =>
    GetTimeSlotModel.fromJson(json.decode(str));

String getTimeSlotModelToJson(GetTimeSlotModel data) =>
    json.encode(data.toJson());

class GetTimeSlotModel {
  bool? success;
  String? message;
  List<ServiceSlotData>? data;

  GetTimeSlotModel({this.success, this.message, this.data});

  factory GetTimeSlotModel.fromJson(Map<String, dynamic> json) =>
      GetTimeSlotModel(
        success: json["success"],
        message: json["message"],
        data: json["data"] == null
            ? []
            : List<ServiceSlotData>.from(
            json["data"].map((x) => ServiceSlotData.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "data": data == null
        ? []
        : List<dynamic>.from(data!.map((x) => x.toJson())),
  };

  // ✅ Convenience getter — cart only needs the flat list of TimeSlots
  List<TimeSlot> get timeSlots =>
      data?.isNotEmpty == true ? data!.first.timeSlots ?? [] : [];
}

class ServiceSlotData {
  SlotService? service;
  List<TimeSlot>? timeSlots;

  ServiceSlotData({this.service, this.timeSlots});

  factory ServiceSlotData.fromJson(Map<String, dynamic> json) =>
      ServiceSlotData(
        service: json["service"] == null
            ? null
            : SlotService.fromJson(json["service"]),
        timeSlots: json["timeSlots"] == null
            ? []
            : List<TimeSlot>.from(
            json["timeSlots"].map((x) => TimeSlot.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
    "service": service?.toJson(),
    "timeSlots": timeSlots == null
        ? []
        : List<dynamic>.from(timeSlots!.map((x) => x.toJson())),
  };
}

class SlotService {
  String? id;
  String? name;
  String? slug;

  SlotService({this.id, this.name, this.slug});

  factory SlotService.fromJson(Map<String, dynamic> json) => SlotService(
    id: json["_id"],
    name: json["name"],
    slug: json["slug"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "name": name,
    "slug": slug,
  };
}

class TimeSlot {
  String? id;
  String? timeLabel;
  int? startMinutes;
  int? endMinutes;
  bool? isActive;
  int? position;
  Availability? availability;

  TimeSlot({
    this.id,
    this.timeLabel,
    this.startMinutes,
    this.endMinutes,
    this.isActive,
    this.position,
    this.availability,
  });

  factory TimeSlot.fromJson(Map<String, dynamic> json) => TimeSlot(
    id: json["_id"],
    timeLabel: json["timeLabel"],
    startMinutes: json["startMinutes"],
    endMinutes: json["endMinutes"],
    isActive: json["isActive"],
    position: json["position"],
    availability: json["availability"] == null
        ? null
        : Availability.fromJson(json["availability"]),
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "timeLabel": timeLabel,
    "startMinutes": startMinutes,
    "endMinutes": endMinutes,
    "isActive": isActive,
    "position": position,
    "availability": availability?.toJson(),
  };
}

class Availability {
  String? date;
  bool? isBooked;

  Availability({this.date, this.isBooked});

  factory Availability.fromJson(Map<String, dynamic> json) => Availability(
    date: json["date"],
    isBooked: json["isBooked"],
  );

  Map<String, dynamic> toJson() => {
    "date": date,
    "isBooked": isBooked,
  };
}