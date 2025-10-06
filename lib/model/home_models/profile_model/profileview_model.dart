// To parse this JSON data, do
//
//     final profileViewModel = profileViewModelFromJson(jsonString);

import 'dart:convert';

ProfileViewModel profileViewModelFromJson(String str) => ProfileViewModel.fromJson(json.decode(str));

String profileViewModelToJson(ProfileViewModel data) => json.encode(data.toJson());

class ProfileViewModel {
  bool? success;
  String? message;
  Data? data;

  ProfileViewModel({
    this.success,
    this.message,
    this.data,
  });

  factory ProfileViewModel.fromJson(Map<String, dynamic> json) => ProfileViewModel(
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
  User? user;
  Addresses? addresses;

  Data({
    this.user,
    this.addresses,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    user: json["user"] == null ? null : User.fromJson(json["user"]),
    addresses: json["addresses"] == null ? null : Addresses.fromJson(json["addresses"]),
  );

  Map<String, dynamic> toJson() => {
    "user": user?.toJson(),
    "addresses": addresses?.toJson(),
  };
}

class Addresses {
  String? id;
  String? userId;
  String? type;
  String? fullAddress;
  GeoLocation? geoLocation;
  bool? addressesDefault;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? v;

  Addresses({
    this.id,
    this.userId,
    this.type,
    this.fullAddress,
    this.geoLocation,
    this.addressesDefault,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  factory Addresses.fromJson(Map<String, dynamic> json) => Addresses(
    id: json["_id"],
    userId: json["userId"],
    type: json["type"],
    fullAddress: json["fullAddress"],
    geoLocation: json["geoLocation"] == null ? null : GeoLocation.fromJson(json["geoLocation"]),
    addressesDefault: json["default"],
    createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
    updatedAt: json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
    v: json["__v"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "userId": userId,
    "type": type,
    "fullAddress": fullAddress,
    "geoLocation": geoLocation?.toJson(),
    "default": addressesDefault,
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
    "__v": v,
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

class User {
  String? id;
  String? firstName;
  String? lastName;
  String? phone;
  ProfilePicture? profilePicture;
  String? role;

  User({
    this.id,
    this.firstName,
    this.lastName,
    this.phone,
    this.profilePicture,
    this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json["_id"],
    firstName: json["firstName"],
    lastName: json["lastName"],
    phone: json["phone"],
    profilePicture: json["profilePicture"] == null ? null : ProfilePicture.fromJson(json["profilePicture"]),
    role: json["role"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "firstName": firstName,
    "lastName": lastName,
    "phone": phone,
    "profilePicture": profilePicture?.toJson(),
    "role": role,
  };
}

class ProfilePicture {
  String? url;
  String? key;
  String? altText;

  ProfilePicture({
    this.url,
    this.key,
    this.altText,
  });

  factory ProfilePicture.fromJson(Map<String, dynamic> json) => ProfilePicture(
    url: json["url"],
    key: json["key"],
    altText: json["altText"],
  );

  Map<String, dynamic> toJson() => {
    "url": url,
    "key": key,
    "altText": altText,
  };
}
