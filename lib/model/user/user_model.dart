import 'dart:convert';

UserModel userModelFromJson(String str) => UserModel.fromJson(json.decode(str));

String userModelToJson(UserModel data) => json.encode(data.toJson());

class UserModel {
  bool? success;
  String? message;
  Data? data;

  UserModel({this.success, this.message, this.data});

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(success: json["success"], message: json["message"], data: json["data"] == null ? null : Data.fromJson(json["data"]));

  Map<String, dynamic> toJson() => {"success": success, "message": message, "data": data?.toJson()};
}

class Data {
  User? user;
  String? accessToken;
  String? refreshToken;

  Data({this.user, this.accessToken, this.refreshToken});

  factory Data.fromJson(Map<String, dynamic> json) => Data(user: json["user"] == null ? null : User.fromJson(json["user"]), accessToken: json["accessToken"], refreshToken: json["refreshToken"]);

  Map<String, dynamic> toJson() => {"user": user?.toJson(), "accessToken": accessToken, "refreshToken": refreshToken};
}

class User {
  String? id;
  String? userId;
  String? phone;
  String? role;
  String? userStatus;
  String? fullName;
  ProfilePicture? profilePicture;

  User({this.id, this.userId, this.phone, this.role, this.userStatus, this.fullName, this.profilePicture});

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json["_id"],
    userId: json["id"],
    phone: json["phone"],
    role: json["role"],
    userStatus: json["userStatus"],
    fullName: json["fullName"],
    profilePicture: json["profilePicture"] == null ? null : ProfilePicture.fromJson(json["profilePicture"]),
  );

  Map<String, dynamic> toJson() => {"_id": id, "id": userId, "phone": phone, "role": role, "userStatus": userStatus, "fullName": fullName, "profilePicture": profilePicture?.toJson()};
}

class ProfilePicture {
  String? url;
  String? altText;
  String? key;

  ProfilePicture({this.url, this.altText, this.key});

  factory ProfilePicture.fromJson(Map<String, dynamic> json) => ProfilePicture(url: json["url"], altText: json["altText"], key: json["key"]);

  Map<String, dynamic> toJson() => {"url": url, "altText": altText, "key": key};
}
