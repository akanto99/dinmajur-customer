// To parse this JSON data, do
//
//     final getAllOrderModel = getAllOrderModelFromJson(jsonString);

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
  int? total;
  List<Datum>? data;

  Data({
    this.total,
    this.data,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    total: json["total"],
    data: json["data"] == null ? [] : List<Datum>.from(json["data"]!.map((x) => Datum.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "total": total,
    "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
  };
}

class Datum {
  Order? order;
  Retailer? retailer;
  Customer? customer;
  Freelancer? freelancer;
  Delivery? delivery;

  Datum({
    this.order,
    this.retailer,
    this.customer,
    this.freelancer,
    this.delivery,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    order: json["order"] == null ? null : Order.fromJson(json["order"]),
    retailer: json["retailer"] == null ? null : Retailer.fromJson(json["retailer"]),
    customer: json["customer"] == null ? null : Customer.fromJson(json["customer"]),
    freelancer: json["freelancer"] == null ? null : Freelancer.fromJson(json["freelancer"]),
    delivery: json["delivery"] == null ? null : Delivery.fromJson(json["delivery"]),
  );

  Map<String, dynamic> toJson() => {
    "order": order?.toJson(),
    "retailer": retailer?.toJson(),
    "customer": customer?.toJson(),
    "freelancer": freelancer?.toJson(),
    "delivery": delivery?.toJson(),
  };
}

class Customer {
  String? id;
  String? fullName;
  String? phone;

  Customer({
    this.id,
    this.fullName,
    this.phone,
  });

  factory Customer.fromJson(Map<String, dynamic> json) => Customer(
    id: json["_id"],
    fullName: json["fullName"],
    phone: json["phone"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "fullName": fullName,
    "phone": phone,
  };
}

class Delivery {
  Destination? pickup;
  String? pickupFullAddress;
  Destination? destination;
  String? destinationFullAddress;
  String? status;
  int? fare;
  String? duration;
  String? distance;

  Delivery({
    this.pickup,
    this.pickupFullAddress,
    this.destination,
    this.destinationFullAddress,
    this.status,
    this.fare,
    this.duration,
    this.distance,
  });

  factory Delivery.fromJson(Map<String, dynamic> json) => Delivery(
    pickup: json["pickup"] == null ? null : Destination.fromJson(json["pickup"]),
    pickupFullAddress: json["pickupFullAddress"],
    destination: json["destination"] == null ? null : Destination.fromJson(json["destination"]),
    destinationFullAddress: json["destinationFullAddress"],
    status: json["status"],
    fare: json["fare"],
    duration: json["duration"],
    distance: json["distance"],
  );

  Map<String, dynamic> toJson() => {
    "pickup": pickup?.toJson(),
    "pickupFullAddress": pickupFullAddress,
    "destination": destination?.toJson(),
    "destinationFullAddress": destinationFullAddress,
    "status": status,
    "fare": fare,
    "duration": duration,
    "distance": distance,
  };
}

class Destination {
  String? type;
  List<double>? coordinates;

  Destination({
    this.type,
    this.coordinates,
  });

  factory Destination.fromJson(Map<String, dynamic> json) => Destination(
    type: json["type"],
    coordinates: json["coordinates"] == null ? [] : List<double>.from(json["coordinates"]!.map((x) => x?.toDouble())),
  );

  Map<String, dynamic> toJson() => {
    "type": type,
    "coordinates": coordinates == null ? [] : List<dynamic>.from(coordinates!.map((x) => x)),
  };
}

class Freelancer {
  String? firstName;
  String? lastName;
  String? id;
  String? phone;

  Freelancer({
    this.firstName,
    this.lastName,
    this.id,
    this.phone,
  });

  factory Freelancer.fromJson(Map<String, dynamic> json) => Freelancer(
    firstName: json["firstName"],
    lastName: json["lastName"],
    id: json["_id"],
    phone: json["phone"],
  );

  Map<String, dynamic> toJson() => {
    "firstName": firstName,
    "lastName": lastName,
    "_id": id,
    "phone": phone,
  };
}

class Order {
  String? id;
  int? budget;
  String? status;
  String? estimatedDeliveryTime;
  DateTime? createdAt;
  DateTime? updatedAt;

  Order({
    this.id,
    this.budget,
    this.status,
    this.estimatedDeliveryTime,
    this.createdAt,
    this.updatedAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) => Order(
    id: json["_id"],
    budget: json["budget"],
    status: json["status"],
    estimatedDeliveryTime: json["estimatedDeliveryTime"],
    createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
    updatedAt: json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "budget": budget,
    "status": status,
    "estimatedDeliveryTime": estimatedDeliveryTime,
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
  };
}

class Retailer {
  String? id;
  String? businessName;
  String? businessType;
  Logo? logo;

  Retailer({
    this.id,
    this.businessName,
    this.businessType,
    this.logo,
  });

  factory Retailer.fromJson(Map<String, dynamic> json) => Retailer(
    id: json["_id"],
    businessName: json["businessName"],
    businessType: json["businessType"],
    logo: json["logo"] == null ? null : Logo.fromJson(json["logo"]),
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "businessName": businessName,
    "businessType": businessType,
    "logo": logo?.toJson(),
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
