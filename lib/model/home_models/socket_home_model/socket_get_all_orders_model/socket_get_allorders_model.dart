import 'dart:convert';

GetAllOrdersUpdatedModel getAllOrdersUpdatedModelFromJson(String str) => GetAllOrdersUpdatedModel.fromJson(json.decode(str));

String getAllOrdersUpdatedModelToJson(GetAllOrdersUpdatedModel data) => json.encode(data.toJson());

class GetAllOrdersUpdatedModel {
  List<Datum>? data;

  GetAllOrdersUpdatedModel({
    this.data,
  });

  factory GetAllOrdersUpdatedModel.fromJson(Map<String, dynamic> json) => GetAllOrdersUpdatedModel(
    data: json["data"] == null ? [] : List<Datum>.from(json["data"]!.map((x) => Datum.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
  };
}

class Datum {
  Order? order;
  Retailer? retailer;
  Freelancer? freelancer;
  Delivery? delivery;

  Datum({
    this.order,
    this.retailer,
    this.freelancer,
    this.delivery,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    order: json["order"] == null ? null : Order.fromJson(json["order"]),
    retailer: json["retailer"] == null ? null : Retailer.fromJson(json["retailer"]),
    freelancer: json["freelancer"] == null ? null : Freelancer.fromJson(json["freelancer"]),
    delivery: json["delivery"] == null ? null : Delivery.fromJson(json["delivery"]),
  );

  Map<String, dynamic> toJson() => {
    "order": order?.toJson(),
    "retailer": retailer?.toJson(),
    "freelancer": freelancer?.toJson(),
    "delivery": delivery?.toJson(),
  };
}

class Delivery {
  Destination? destination;
  String? status;
  int? fare;
  String? duration;
  String? distance;

  Delivery({
    this.destination,
    this.status,
    this.fare,
    this.duration,
    this.distance,
  });

  factory Delivery.fromJson(Map<String, dynamic> json) => Delivery(
    destination: json["destination"] == null ? null : Destination.fromJson(json["destination"]),
    status: json["status"],
    fare: json["fare"],
    duration: json["duration"],
    distance: json["distance"],
  );

  Map<String, dynamic> toJson() => {
    "destination": destination?.toJson(),
    "status": status,
    "fare": fare,
    "duration": duration,
    "distance": distance,
  };
}

class Destination {
  String? type;
  List<double>? coordinates;
  String? fullAddress;

  Destination({
    this.type,
    this.coordinates,
    this.fullAddress,
  });

  factory Destination.fromJson(Map<String, dynamic> json) => Destination(
    type: json["type"],
    coordinates: json["coordinates"] == null ? [] : List<double>.from(json["coordinates"]!.map((x) => x?.toDouble())),
    fullAddress: json["fullAddress"],
  );

  Map<String, dynamic> toJson() => {
    "type": type,
    "coordinates": coordinates == null ? [] : List<dynamic>.from(coordinates!.map((x) => x)),
    "fullAddress": fullAddress,
  };
}

class Freelancer {
  String? firstName;
  String? lastName;
  String? id;

  Freelancer({
    this.firstName,
    this.lastName,
    this.id,
  });

  factory Freelancer.fromJson(Map<String, dynamic> json) => Freelancer(
    firstName: json["firstName"],
    lastName: json["lastName"],
    id: json["_id"],
  );

  Map<String, dynamic> toJson() => {
    "firstName": firstName,
    "lastName": lastName,
    "_id": id,
  };
}

class Order {
  String? id;
  int? budget;
  String? estimatedDeliveryTime;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? status;

  Order({
    this.id,
    this.budget,
    this.estimatedDeliveryTime,
    this.createdAt,
    this.updatedAt,
    this.status,
  });

  factory Order.fromJson(Map<String, dynamic> json) => Order(
    id: json["_id"],
    budget: json["budget"],
    estimatedDeliveryTime: json["estimatedDeliveryTime"],
    createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
    updatedAt: json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
    status: json["status"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "budget": budget,
    "estimatedDeliveryTime": estimatedDeliveryTime,
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
    "status": status,
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
