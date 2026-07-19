import 'dart:convert';

GetAllNearbyServiceStoresModel getAllNearbyServiceStoresModelFromJson(String str) => GetAllNearbyServiceStoresModel.fromJson(json.decode(str));

String getAllNearbyServiceStoresModelToJson(GetAllNearbyServiceStoresModel data) => json.encode(data.toJson());

class GetAllNearbyServiceStoresModel {
  bool? success;
  String? message;
  dynamic meta;
  List<Datum>? data;

  GetAllNearbyServiceStoresModel({
    this.success,
    this.message,
    this.meta,
    this.data,
  });

  factory GetAllNearbyServiceStoresModel.fromJson(Map<String, dynamic> json) => GetAllNearbyServiceStoresModel(
    success: json["success"],
    message: json["message"],
    meta: json["meta"],
    data: json["data"] == null ? [] : List<Datum>.from(json["data"]!.map((x) => Datum.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "meta": meta,
    "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
  };
}

class Datum {
  String? id;
  String? userId;
  String? businessName;
  String? businessOpeningTime;
  String? businessClosingTime;
  Logo? logo;
  GeoLocation? geoLocation;
  String? businessType;
  int? platformFee;
  Distance? distance;
  Distance? duration;
  String? fullAddress;
  bool? isAvailable;

  Datum({
    this.id,
    this.userId,
    this.businessName,
    this.businessOpeningTime,
    this.businessClosingTime,
    this.logo,
    this.geoLocation,
    this.businessType,
    this.platformFee,
    this.distance,
    this.duration,
    this.fullAddress,
    this.isAvailable,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    id: json["_id"],
    userId: json["userId"],
    businessName: json["businessName"],
    businessOpeningTime: json["businessOpeningTime"],
    businessClosingTime: json["businessClosingTime"],
    logo: json["logo"] == null ? null : Logo.fromJson(json["logo"]),
    geoLocation: json["geoLocation"] == null ? null : GeoLocation.fromJson(json["geoLocation"]),
    businessType: json["businessType"],
    platformFee: json["platformFee"],
    distance: json["distance"] == null ? null : Distance.fromJson(json["distance"]),
    duration: json["duration"] == null ? null : Distance.fromJson(json["duration"]),
    fullAddress: json["fullAddress"],
    isAvailable: json["isAvailable"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "userId": userId,
    "businessName": businessName,
    "businessOpeningTime": businessOpeningTime,
    "businessClosingTime": businessClosingTime,
    "logo": logo?.toJson(),
    "geoLocation": geoLocation?.toJson(),
    "businessType": businessType,
    "platformFee": platformFee,
    "distance": distance?.toJson(),
    "duration": duration?.toJson(),
    "fullAddress": fullAddress,
    "isAvailable": isAvailable,
  };
}

class Distance {
  String? text;
  int? value;

  Distance({
    this.text,
    this.value,
  });

  factory Distance.fromJson(Map<String, dynamic> json) => Distance(
    text: json["text"],
    value: json["value"],
  );

  Map<String, dynamic> toJson() => {
    "text": text,
    "value": value,
  };
}

class GeoLocation {
  String? type;
  List<double>? coordinates;

  GeoLocation({
    this.type,
    this.coordinates,
  });

  factory GeoLocation.fromJson(Map<String, dynamic> json) => GeoLocation(
    type: json["type"],
    coordinates: json["coordinates"] == null ? [] : List<double>.from(json["coordinates"]!.map((x) => x?.toDouble())),
  );

  Map<String, dynamic> toJson() => {
    "type": type,
    "coordinates": coordinates == null ? [] : List<dynamic>.from(coordinates!.map((x) => x)),
  };
}

class Logo {
  String? url;
  String? key;

  Logo({
    this.url,
    this.key,
  });

  factory Logo.fromJson(Map<String, dynamic> json) => Logo(
    url: json["url"],
    key: json["key"],
  );

  Map<String, dynamic> toJson() => {
    "url": url,
    "key": key,
  };
}
