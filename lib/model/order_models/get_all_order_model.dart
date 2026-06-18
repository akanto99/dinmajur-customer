import 'dart:convert';

GetAllOrderModel getAllOrderModelFromJson(String str) => GetAllOrderModel.fromJson(json.decode(str));

String getAllOrderModelToJson(GetAllOrderModel data) => json.encode(data.toJson());

class GetAllOrderModel {
  bool? success;
  String? message;
  Data? data;

  GetAllOrderModel({
    this.success,
    this.message,
    this.data,
  });

  factory GetAllOrderModel.fromJson(Map<String, dynamic> json) => GetAllOrderModel(
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
  Meta? meta;
  List<Datum>? data;

  Data({
    this.meta,
    this.data,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    meta: json["meta"] == null ? null : Meta.fromJson(json["meta"]),
    data: json["data"] == null ? [] : List<Datum>.from(json["data"]!.map((x) => Datum.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "meta": meta?.toJson(),
    "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
  };
}

class Datum {
  String? orderId;
  String? orderTrackingId;
  String? freelancerId;
  String? id;
  String? houseKeeperBookingId;
  String? beautySalonBookingId;
  String? eventCookingBookingId;
  String? servicesBookingId;
  String? categoryType;
  String? type;
  Freelancer? freelancer;
  Customer? customer;
  String? paymentType;
  String? fullAddress;
  dynamic paymentStatus;
  bool? isReview;
  String? status;
  double? total;
  double? subTotalAmount;
  double? totalAmount;
  bool? isApproved;
  int? approvedExtraItemsCount;
  int? extraTotal;
  List<ExtraItem>? extraItems;
  DateTime? createdAt;

  Datum({
    this.orderId,
    this.orderTrackingId,
    this.freelancerId,
    this.id,
    this.houseKeeperBookingId,
    this.beautySalonBookingId,
    this.eventCookingBookingId,
    this.servicesBookingId,
    this.type,
    this.categoryType,
    this.freelancer,
    this.customer,
    this.paymentType,
    this.fullAddress,
    this.paymentStatus,
    this.isReview,
    this.status,
    this.total,
    this.subTotalAmount,
    this.totalAmount,
    this.isApproved,
    this.approvedExtraItemsCount,
    this.extraTotal,
    this.extraItems,
    this.createdAt,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    orderId: json["orderId"],
    orderTrackingId: json["orderTrackingId"],
    freelancerId: json["freelancerId"],
    id: json["_id"],
    houseKeeperBookingId: json["houseKeeperBookingId"],
    beautySalonBookingId: json["beautySalonBookingId"],
    eventCookingBookingId: json["eventCookingBookingId"],
    servicesBookingId: json["servicesBookingId"],
    type: json["type"],
    categoryType: json["categoryType"],
    freelancer: json["freelancer"] == null ? null : Freelancer.fromJson(json["freelancer"]),
    customer: json["customer"] == null ? null : Customer.fromJson(json["customer"]),
    paymentType: json["paymentType"],
    fullAddress: json["fullAddress"],
    paymentStatus: json["paymentStatus"],
    isReview: json["isReview"],
    status: json["status"],
    total: json["total"]?.toDouble(),
    subTotalAmount: json["subTotalAmount"]?.toDouble(),
    totalAmount: json["totalAmount"]?.toDouble(),
    isApproved: json["isApproved"],
    approvedExtraItemsCount: json["approvedExtraItemsCount"],
    extraTotal: json["extraTotal"],
    extraItems: json["extraItems"] == null ? [] : List<ExtraItem>.from(json["extraItems"]!.map((x) => ExtraItem.fromJson(x))),
    createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
  );

  Map<String, dynamic> toJson() => {
    "orderId": orderId,
    "orderTrackingId": orderTrackingId,
    "freelancerId": freelancerId,
    "id": id,
    "houseKeeperBookingId": houseKeeperBookingId,
    "beautySalonBookingId": beautySalonBookingId,
    "eventCookingBookingId": eventCookingBookingId,
    "servicesBookingId": servicesBookingId,
    "type": type,
    "categoryType": categoryType,
    "freelancer": freelancer?.toJson(),
    "customer": customer?.toJson(),
    "paymentType": paymentType,
    "fullAddress": fullAddress,
    "paymentStatus": paymentStatus,
    "isReview": isReview,
    "status": status,
    "total": total,
    "subTotalAmount": subTotalAmount,
    "totalAmount": totalAmount,
    "isApproved": isApproved,
    "approvedExtraItemsCount": approvedExtraItemsCount,
    "extraTotal": extraTotal,
    "extraItems": extraItems == null ? [] : List<dynamic>.from(extraItems!.map((x) => x.toJson())),
    "createdAt": createdAt?.toIso8601String(),
  };
}

class Customer {
  String? id;
  String? phone;
  String? role;
  String? fullName;

  Customer({
    this.id,
    this.phone,
    this.role,
    this.fullName,
  });

  factory Customer.fromJson(Map<String, dynamic> json) => Customer(
    id: json["_id"],
    phone: json["phone"],
    role: json["role"],
    fullName: json["fullName"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "phone": phone,
    "role": role,
    "fullName": fullName,
  };
}

class Freelancer {
  String? id;
  String? phone;
  String? role;
  DateTime? dateOfBirth;
  String? email;
  int? experience;
  String? firstName;
  String? gender;
  String? lastName;
  ProfilePicture? profilePicture;
  List<Skill>? skills;
  double ?averageRating;
  int ?totalReviews;

  Freelancer({
    this.id,
    this.phone,
    this.role,
    this.dateOfBirth,
    this.email,
    this.experience,
    this.firstName,
    this.gender,
    this.lastName,
    this.profilePicture,
    this.skills,
    this.averageRating,
    this.totalReviews,
  });

  factory Freelancer.fromJson(Map<String, dynamic> json) => Freelancer(
    id: json["_id"],
    phone: json["phone"],
    role: json["role"],
    dateOfBirth: json["dateOfBirth"] == null ? null : DateTime.parse(json["dateOfBirth"]),
    email: json["email"],
    experience: json["experience"],
    firstName: json["firstName"],
    gender: json["gender"],
    lastName: json["lastName"],
    profilePicture: json["profilePicture"] == null ? null : ProfilePicture.fromJson(json["profilePicture"]),
    skills: json["skills"] == null ? [] : List<Skill>.from(json["skills"]!.map((x) => Skill.fromJson(x))),
    averageRating: (json['averageRating'] as num?)?.toDouble(),
    totalReviews: json['totalReviews'],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "phone": phone,
    "role": role,
    "dateOfBirth": dateOfBirth?.toIso8601String(),
    "email": email,
    "experience": experience,
    "firstName": firstName,
    "gender": gender,
    "lastName": lastName,
    "profilePicture": profilePicture?.toJson(),
    "skills": skills == null ? [] : List<dynamic>.from(skills!.map((x) => x.toJson())),
    'averageRating':averageRating,
    'totalReviews':totalReviews,
  };
}

class ProfilePicture {
  String? url;
  String? key;

  ProfilePicture({
    this.url,
    this.key,
  });

  factory ProfilePicture.fromJson(Map<String, dynamic> json) => ProfilePicture(
    url: json["url"],
    key: json["key"],
  );

  Map<String, dynamic> toJson() => {
    "url": url,
    "key": key,
  };
}

class Skill {
  String? id;
  String? userId;
  String? category;
  List<String>? items;

  Skill({
    this.id,
    this.userId,
    this.category,
    this.items,
  });

  factory Skill.fromJson(Map<String, dynamic> json) => Skill(
    id: json["_id"],
    userId: json["userId"],
    category: json["category"],
    items: json["items"] == null ? [] : List<String>.from(json["items"]!.map((x) => x)),
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "userId": userId,
    "category": category,
    "items": items == null ? [] : List<dynamic>.from(items!.map((x) => x)),
  };
}

class ExtraItem {
  String? id;
  String? bookingId;
  String? name;
  int? price;
  int? quantity;
  int? total;
  String? status;
  String? paymentStatus;
  DateTime? createdAt;
  String? trackingId;

  ExtraItem({
    this.id,
    this.bookingId,
    this.name,
    this.price,
    this.quantity,
    this.total,
    this.status,
    this.paymentStatus,
    this.createdAt,
    this.trackingId,
  });

  factory ExtraItem.fromJson(Map<String, dynamic> json) => ExtraItem(
    id: json["_id"],
    bookingId: json["bookingId"],
    name: json["name"],
    price: json["price"],
    quantity: json["quantity"],
    total: json["total"],
    status: json["status"],
    paymentStatus: json["paymentStatus"],
    createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
    trackingId: json["trackingId"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "bookingId": bookingId,
    "name": name,
    "price": price,
    "quantity": quantity,
    "total": total,
    "status": status,
    "paymentStatus": paymentStatus,
    "createdAt": createdAt?.toIso8601String(),
    "trackingId": trackingId,
  };
}
class Meta {
  int? total;
  int? page;
  int? limit;
  int? totalPages;
  StatusCount? statusCount;

  Meta({
    this.total,
    this.page,
    this.limit,
    this.totalPages,
    this.statusCount,
  });

  factory Meta.fromJson(Map<String, dynamic> json) => Meta(
    total: json["total"],
    page: json["page"],
    limit: json["limit"],
    totalPages: json["totalPages"],
    statusCount: json["statusCount"] == null ? null : StatusCount.fromJson(json["statusCount"]),  // ← add this
  );

  Map<String, dynamic> toJson() => {
    "total": total,
    "page": page,
    "limit": limit,
    "statusCount": statusCount?.toJson(),
  };
}
class StatusCount {
  int? pending;
  int? running;
  int? completed;
  int? cancelled;

  StatusCount({
    this.pending,
    this.running,
    this.completed,
    this.cancelled,
  });

  factory StatusCount.fromJson(Map<String, dynamic> json) => StatusCount(
    pending: json["PENDING"],
    running: json["RUNNING"],
    completed: json["COMPLETED"],
    cancelled: json["CANCELLED"],
  );

  Map<String, dynamic> toJson() => {
    "PENDING": pending,
    "RUNNING": running,
    "COMPLETED": completed,
    "CANCELLED": cancelled,
  };
}