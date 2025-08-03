import 'dart:convert';

UserModel userModelFromJson(String str) => UserModel.fromJson(json.decode(str));

String userModelToJson(UserModel data) => json.encode(data.toJson());

class UserModel {
  bool? success;
  String? message;
  Data? data;

  UserModel({
    this.success,
    this.message,
    this.data,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
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
  String? accessToken;
  String? refreshToken;
  User? user;

  Data({
    this.accessToken,
    this.refreshToken,
    this.user,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    accessToken: json["accessToken"],
    refreshToken: json["refreshToken"],
    user: json["user"] == null ? null : User.fromJson(json["user"]),
  );

  Map<String, dynamic> toJson() => {
    "accessToken": accessToken,
    "refreshToken": refreshToken,
    "user": user?.toJson(),
  };
}

class User {
  String? id;
  String? userId;
  String? phone;
  String? role;
  String? userStatus;
  bool? isRegistered;
  bool? isPhoneVerified;
  String? firstName;
  String? lastName;
  ProfilePicture? profilePicture; // ✅ Changed from String to ProfilePicture
  bool? isDeliveryPerson; // ✅ Added missing field
  bool? checkedJoinUs;
  bool? checkedSelectServices;
  bool? checkedSelectArea;

  User({
    this.id,
    this.userId,
    this.phone,
    this.role,
    this.userStatus,
    this.isRegistered,
    this.isPhoneVerified,
    this.firstName,
    this.lastName,
    this.profilePicture,
    this.isDeliveryPerson,
    this.checkedJoinUs,
    this.checkedSelectServices,
    this.checkedSelectArea,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json["_id"],
    userId: json["id"],
    phone: json["phone"],
    role: json["role"],
    userStatus: json["userStatus"],
    isRegistered: json["isRegistered"],
    isPhoneVerified: json["isPhoneVerified"],
    firstName: json["firstName"],
    lastName: json["lastName"],
    profilePicture: json["profilePicture"] == null
        ? null
        : ProfilePicture.fromJson(json["profilePicture"]), // ✅ Fixed parsing
    isDeliveryPerson: json["isDeliveryPerson"], // ✅ Added missing field
    checkedJoinUs: json["checkedJoinUs"],
    checkedSelectServices: json["checkedSelectServices"],
    checkedSelectArea: json["checkedSelectArea"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "id": userId,
    "phone": phone,
    "role": role,
    "userStatus": userStatus,
    "isRegistered": isRegistered,
    "isPhoneVerified": isPhoneVerified,
    "firstName": firstName,
    "lastName": lastName,
    "profilePicture": profilePicture?.toJson(), // ✅ Fixed serialization
    "isDeliveryPerson": isDeliveryPerson, // ✅ Added missing field
    "checkedJoinUs": checkedJoinUs,
    "checkedSelectServices": checkedSelectServices,
    "checkedSelectArea": checkedSelectArea,
  };
}

// ✅ New ProfilePicture class
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