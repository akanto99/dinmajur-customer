import 'dart:convert';

GetBkashNagadModel getBkashNagadModelFromJson(String str) => GetBkashNagadModel.fromJson(json.decode(str));

String getBkashNagadModelToJson(GetBkashNagadModel data) => json.encode(data.toJson());

class GetBkashNagadModel {
  bool? success;
  String? message;
  List<Datum>? data;

  GetBkashNagadModel({
    this.success,
    this.message,
    this.data,
  });

  factory GetBkashNagadModel.fromJson(Map<String, dynamic> json) => GetBkashNagadModel(
    success: json["success"],
    message: json["message"],
    data: json["data"] == null ? [] : List<Datum>.from(json["data"]!.map((x) => Datum.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
  };
}

class Datum {
  String? id;
  String? userId;
  String? type;
  String? provider;
  String? accountNumber;
  dynamic last4;
  dynamic expiryMonth;
  dynamic expiryYear;
  dynamic token;
  bool? isDefault;
  DateTime? addedAt;
  int? v;

  Datum({
    this.id,
    this.userId,
    this.type,
    this.provider,
    this.accountNumber,
    this.last4,
    this.expiryMonth,
    this.expiryYear,
    this.token,
    this.isDefault,
    this.addedAt,
    this.v,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    id: json["_id"],
    userId: json["userId"],
    type: json["type"],
    provider: json["provider"],
    accountNumber: json["accountNumber"],
    last4: json["last4"],
    expiryMonth: json["expiryMonth"],
    expiryYear: json["expiryYear"],
    token: json["token"],
    isDefault: json["isDefault"],
    addedAt: json["addedAt"] == null ? null : DateTime.parse(json["addedAt"]),
    v: json["__v"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "userId": userId,
    "type": type,
    "provider": provider,
    "accountNumber": accountNumber,
    "last4": last4,
    "expiryMonth": expiryMonth,
    "expiryYear": expiryYear,
    "token": token,
    "isDefault": isDefault,
    "addedAt": addedAt?.toIso8601String(),
    "__v": v,
  };
}
