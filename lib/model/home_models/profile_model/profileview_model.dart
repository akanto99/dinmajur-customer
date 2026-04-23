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
  Orders? orders;

  Data({
    this.user,
    this.addresses,
    this.orders,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    user: json["user"] == null ? null : User.fromJson(json["user"]),
    addresses: json["addresses"] == null ? null : Addresses.fromJson(json["addresses"]),
    orders: json["orders"] == null ? null : Orders.fromJson(json["orders"]),
  );

  Map<String, dynamic> toJson() => {
    "user": user?.toJson(),
    "addresses": addresses?.toJson(),
    "orders": orders?.toJson(),
  };
}

class Addresses {
  String? id;
  String? userId;
  String? type;
  String? fullAddress;
  String? city;
  String? country;
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
    this.city,
    this.country,
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
    city: json["city"],
    country: json["country"],
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
    "city": city,
    "country": country,
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

class Orders {
  double? totalSpend;
  int? totalOrders;
  int? totalReviews;
  RecentOrder? recentOrder;

  Orders({
    this.totalSpend,
    this.totalOrders,
    this.totalReviews,
    this.recentOrder,
  });

  factory Orders.fromJson(Map<String, dynamic> json) => Orders(
    totalSpend: json["totalSpend"] == null ? null : (json["totalSpend"] as num).toDouble(),
    totalOrders: json["totalOrders"],
    totalReviews: json["totalReviews"],
    recentOrder: json["recentOrder"] == null ? null : RecentOrder.fromJson(json["recentOrder"]),
  );

  Map<String, dynamic> toJson() => {
    "totalSpend": totalSpend,
    "totalOrders": totalOrders,
    "totalReviews": totalReviews,
    "recentOrder": recentOrder?.toJson(),
  };
}

class RecentOrder {
  String? id;
  int? total;
  String? status;

  RecentOrder({
    this.id,
    this.total,
    this.status,
  });

  factory RecentOrder.fromJson(Map<String, dynamic> json) => RecentOrder(
    id: json["_id"],
    total: json["total"],
    status: json["status"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "total": total,
    "status": status,
  };
}

class User {
  String? id;
  String? fullName;
  String? phone;
  ProfilePicture? profilePicture;
  String? role;
  DateTime? createdAt;

  User({
    this.id,
    this.fullName,
    this.phone,
    this.profilePicture,
    this.role,
    this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json["_id"],
    fullName: json["fullName"],
    phone: json["phone"],
    profilePicture: json["profilePicture"] == null ? null : ProfilePicture.fromJson(json["profilePicture"]),
    role: json["role"],
    createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "fullName": fullName,
    "phone": phone,
    "profilePicture": profilePicture?.toJson(),
    "role": role,
    "createdAt": createdAt?.toIso8601String(),
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
