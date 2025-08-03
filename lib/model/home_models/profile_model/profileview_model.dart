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
  List<Address>? addresses;
  List<Service>? skills;
  List<Service>? services;
  List<Portfolio>? portfolios;
  List<dynamic>? contacts;

  Data({
    this.user,
    this.addresses,
    this.skills,
    this.services,
    this.portfolios,
    this.contacts,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    user: json["user"] == null ? null : User.fromJson(json["user"]),
    addresses: json["addresses"] == null ? [] : List<Address>.from(json["addresses"]!.map((x) => Address.fromJson(x))),
    skills: json["skills"] == null ? [] : List<Service>.from(json["skills"]!.map((x) => Service.fromJson(x))),
    services: json["services"] == null ? [] : List<Service>.from(json["services"]!.map((x) => Service.fromJson(x))),
    portfolios: json["portfolios"] == null ? [] : List<Portfolio>.from(json["portfolios"]!.map((x) => Portfolio.fromJson(x))),
    contacts: json["contacts"] == null ? [] : List<dynamic>.from(json["contacts"]!.map((x) => x)),
  );

  Map<String, dynamic> toJson() => {
    "user": user?.toJson(),
    "addresses": addresses == null ? [] : List<dynamic>.from(addresses!.map((x) => x.toJson())),
    "skills": skills == null ? [] : List<dynamic>.from(skills!.map((x) => x.toJson())),
    "services": services == null ? [] : List<dynamic>.from(services!.map((x) => x.toJson())),
    "portfolios": portfolios == null ? [] : List<dynamic>.from(portfolios!.map((x) => x.toJson())),
    "contacts": contacts == null ? [] : List<dynamic>.from(contacts!.map((x) => x)),
  };
}

class Address {
  String? id;
  String? userId;
  String? type;
  String? thana;
  String? district;
  String? division;
  String? fullAddress;
  String? country;
  GeoLocation? geoLocation;
  bool? isDeleted;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? v;

  Address({
    this.id,
    this.userId,
    this.type,
    this.thana,
    this.district,
    this.division,
    this.fullAddress,
    this.country,
    this.geoLocation,
    this.isDeleted,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  factory Address.fromJson(Map<String, dynamic> json) => Address(
    id: json["_id"],
    userId: json["userId"],
    type: json["type"],
    thana: json["thana"],
    district: json["district"],
    division: json["division"],
    fullAddress: json["fullAddress"],
    country: json["country"],
    geoLocation: json["geoLocation"] == null ? null : GeoLocation.fromJson(json["geoLocation"]),
    isDeleted: json["isDeleted"],
    createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
    updatedAt: json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
    v: json["__v"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "userId": userId,
    "type": type,
    "thana": thana,
    "district": district,
    "division": division,
    "fullAddress": fullAddress,
    "country": country,
    "geoLocation": geoLocation?.toJson(),
    "isDeleted": isDeleted,
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
    "__v": v,
  };
}

class GeoLocation {
  String? type;
  List<double>? coordinates;
  DateTime? timestamp;

  GeoLocation({
    this.type,
    this.coordinates,
    this.timestamp,
  });

  factory GeoLocation.fromJson(Map<String, dynamic> json) => GeoLocation(
    type: json["type"],
    coordinates: json["coordinates"] == null ? [] : List<double>.from(json["coordinates"]!.map((x) => x?.toDouble())),
    timestamp: json["timestamp"] == null ? null : DateTime.parse(json["timestamp"]),
  );

  Map<String, dynamic> toJson() => {
    "type": type,
    "coordinates": coordinates == null ? [] : List<dynamic>.from(coordinates!.map((x) => x)),
    "timestamp": timestamp?.toIso8601String(),
  };
}

class Portfolio {
  ProfilePicture? thumbnail;
  String? id;
  String? userId;
  String? title;
  dynamic description;
  List<dynamic>? images;
  bool? isDeleted;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? v;

  Portfolio({
    this.thumbnail,
    this.id,
    this.userId,
    this.title,
    this.description,
    this.images,
    this.isDeleted,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  factory Portfolio.fromJson(Map<String, dynamic> json) => Portfolio(
    thumbnail: json["thumbnail"] == null ? null : ProfilePicture.fromJson(json["thumbnail"]),
    id: json["_id"],
    userId: json["userId"],
    title: json["title"],
    description: json["description"],
    images: json["images"] == null ? [] : List<dynamic>.from(json["images"]!.map((x) => x)),
    isDeleted: json["isDeleted"],
    createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
    updatedAt: json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
    v: json["__v"],
  );

  Map<String, dynamic> toJson() => {
    "thumbnail": thumbnail?.toJson(),
    "_id": id,
    "userId": userId,
    "title": title,
    "description": description,
    "images": images == null ? [] : List<dynamic>.from(images!.map((x) => x)),
    "isDeleted": isDeleted,
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
    "__v": v,
  };
}

class ProfilePicture {
  String? url;
  String? altText;

  ProfilePicture({
    this.url,
    this.altText,
  });

  factory ProfilePicture.fromJson(Map<String, dynamic> json) => ProfilePicture(
    url: json["url"],
    altText: json["altText"],
  );

  Map<String, dynamic> toJson() => {
    "url": url,
    "altText": altText,
  };
}

class Service {
  String? id;
  String? userId;
  String? category;
  List<String>? items;
  bool? isDeleted;
  int? v;
  DateTime? createdAt;
  DateTime? updatedAt;

  Service({
    this.id,
    this.userId,
    this.category,
    this.items,
    this.isDeleted,
    this.v,
    this.createdAt,
    this.updatedAt,
  });

  factory Service.fromJson(Map<String, dynamic> json) => Service(
    id: json["_id"],
    userId: json["userId"],
    category: json["category"],
    items: json["items"] == null ? [] : List<String>.from(json["items"]!.map((x) => x)),
    isDeleted: json["isDeleted"],
    v: json["__v"],
    createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
    updatedAt: json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "userId": userId,
    "category": category,
    "items": items == null ? [] : List<dynamic>.from(items!.map((x) => x)),
    "isDeleted": isDeleted,
    "__v": v,
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
  };
}

class User {
  String? id;
  String? phone;
  bool? isEmailVerified;
  bool? isPhoneVerified;
  String? role;
  String? userStatus;
  bool? isRegistered;
  bool? isDeleted;
  bool? checkedJoinUs;
  bool? checkedSelectServices;
  bool? checkedSelectArea;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? v;
  DateTime? dateOfBirth;
  String? email;
  int? experience;
  String? firstName;
  String? gender;
  String? lastName;
  ProfilePicture? profilePicture;
  int? salary;
  String? salaryType;
  bool? isDeliveryPerson;
  String? bio;
  String? userId;

  User({
    this.id,
    this.phone,
    this.isEmailVerified,
    this.isPhoneVerified,
    this.role,
    this.userStatus,
    this.isRegistered,
    this.isDeleted,
    this.checkedJoinUs,
    this.checkedSelectServices,
    this.checkedSelectArea,
    this.createdAt,
    this.updatedAt,
    this.v,
    this.dateOfBirth,
    this.email,
    this.experience,
    this.firstName,
    this.gender,
    this.lastName,
    this.profilePicture,
    this.salary,
    this.salaryType,
    this.isDeliveryPerson,
    this.bio,
    this.userId,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json["_id"],
    phone: json["phone"],
    isEmailVerified: json["isEmailVerified"],
    isPhoneVerified: json["isPhoneVerified"],
    role: json["role"],
    userStatus: json["userStatus"],
    isRegistered: json["isRegistered"],
    isDeleted: json["isDeleted"],
    checkedJoinUs: json["checkedJoinUs"],
    checkedSelectServices: json["checkedSelectServices"],
    checkedSelectArea: json["checkedSelectArea"],
    createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
    updatedAt: json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
    v: json["__v"],
    dateOfBirth: json["dateOfBirth"] == null ? null : DateTime.parse(json["dateOfBirth"]),
    email: json["email"],
    experience: json["experience"],
    firstName: json["firstName"],
    gender: json["gender"],
    lastName: json["lastName"],
    profilePicture: json["profilePicture"] == null ? null : ProfilePicture.fromJson(json["profilePicture"]),
    salary: json["salary"],
    salaryType: json["salaryType"],
    isDeliveryPerson: json["isDeliveryPerson"],
    bio: json["bio"],
    userId: json["id"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "phone": phone,
    "isEmailVerified": isEmailVerified,
    "isPhoneVerified": isPhoneVerified,
    "role": role,
    "userStatus": userStatus,
    "isRegistered": isRegistered,
    "isDeleted": isDeleted,
    "checkedJoinUs": checkedJoinUs,
    "checkedSelectServices": checkedSelectServices,
    "checkedSelectArea": checkedSelectArea,
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
    "__v": v,
    "dateOfBirth": dateOfBirth?.toIso8601String(),
    "email": email,
    "experience": experience,
    "firstName": firstName,
    "gender": gender,
    "lastName": lastName,
    "profilePicture": profilePicture?.toJson(),
    "salary": salary,
    "salaryType": salaryType,
    "isDeliveryPerson": isDeliveryPerson,
    "bio": bio,
    "id": userId,
  };
}