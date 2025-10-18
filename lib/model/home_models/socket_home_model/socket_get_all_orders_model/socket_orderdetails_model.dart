import 'dart:convert';

OrderDetailsModel orderDetailsModelFromJson(String str) => OrderDetailsModel.fromJson(json.decode(str));

String orderDetailsModelToJson(OrderDetailsModel data) => json.encode(data.toJson());

class OrderDetailsModel {
  Order? order;
  Retailer? retailer;
  Freelancer? freelancer;
  Delivery? delivery;
  Customer? customer;

  OrderDetailsModel({
    this.order,
    this.retailer,
    this.freelancer,
    this.delivery,
    this.customer,
  });

  factory OrderDetailsModel.fromJson(Map<String, dynamic> json) => OrderDetailsModel(
    order: json["order"] == null ? null : Order.fromJson(json["order"]),
    retailer: json["retailer"] == null ? null : Retailer.fromJson(json["retailer"]),
    freelancer: json["freelancer"] == null ? null : Freelancer.fromJson(json["freelancer"]),
    delivery: json["delivery"] == null ? null : Delivery.fromJson(json["delivery"]),
    customer: json["customer"] == null ? null : Customer.fromJson(json["customer"]),
  );

  Map<String, dynamic> toJson() => {
    "order": order?.toJson(),
    "retailer": retailer?.toJson(),
    "freelancer": freelancer?.toJson(),
    "delivery": delivery?.toJson(),
    "customer": customer?.toJson(),
  };
}
class Delivery {
  String? id;
  String? status;
  Destination? destination;
  int? fare;
  String? duration;
  String? distance;

  Delivery({
    this.id,
    this.status,
    this.destination,
    this.fare,
    this.duration,
    this.distance,
  });

  factory Delivery.fromJson(Map<String, dynamic> json) => Delivery(
    id: json["_id"],
    status: json["status"],
    destination: json["destination"] == null ? null : Destination.fromJson(json["destination"]),
    fare: json["fare"],
    duration: json["duration"],
    distance: json["distance"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "status": status,
    "destination": destination?.toJson(),
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
  String? id;
  String? firstName;
  String? lastName;
  String? phone;

  Freelancer({
    this.id,
    this.firstName,
    this.lastName,
    this.phone,
  });

  factory Freelancer.fromJson(Map<String, dynamic> json) => Freelancer(
    id: json["_id"],
    firstName: json["firstName"],
    lastName: json["lastName"],
    phone: json["phone"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "firstName": firstName,
    "lastName": lastName,
    "phone": phone,
  };
}

class Order {
  String? id;
  String? status;
  int? budget;
  String? estimatedDeliveryTime;
  int? subTotalAmount;
  int? totalAmount;
  DateTime? createdAt;
  DateTime? updatedAt;
  List<Item>? items;

  Order({
    this.id,
    this.status,
    this.budget,
    this.estimatedDeliveryTime,
    this.subTotalAmount,
    this.totalAmount,
    this.createdAt,
    this.updatedAt,
    this.items,
  });

  factory Order.fromJson(Map<String, dynamic> json) => Order(
    id: json["_id"],
    status: json["status"],
    budget: json["budget"],
    estimatedDeliveryTime: json["estimatedDeliveryTime"],
    subTotalAmount: json["subTotalAmount"],
    totalAmount: json["totalAmount"],
    createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
    updatedAt: json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
    items: json["items"] == null ? [] : List<Item>.from(json["items"]!.map((x) => Item.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "status": status,
    "budget": budget,
    "estimatedDeliveryTime": estimatedDeliveryTime,
    "subTotalAmount": subTotalAmount,
    "totalAmount": totalAmount,
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
    "items": items == null ? [] : List<dynamic>.from(items!.map((x) => x.toJson())),
  };
}

class Item {
  String? id;
  String? name;
  double? quantity;
  String? unit;
  int? unitPrice;
  int? totalPrice;
  String? status;
  DateTime? createdAt;
  DateTime? updatedAt;

  Item({
    this.id,
    this.name,
    this.quantity,
    this.unit,
    this.unitPrice,
    this.totalPrice,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory Item.fromJson(Map<String, dynamic> json) => Item(
    id: json["_id"],
    name: json["name"],
    quantity: json["quantity"]?.toDouble(),
    unit: json["unit"],
    unitPrice: json["unitPrice"],
    totalPrice: json["totalPrice"],
    status: json["status"],
    createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
    updatedAt: json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "name": name,
    "quantity": quantity,
    "unit": unit,
    "unitPrice": unitPrice,
    "totalPrice": totalPrice,
    "status": status,
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
class Customer {
  String? id;
  String? phone;
  String? firstName;
  String? lastName;

  Customer({
    this.id,
    this.phone,
    this.firstName,
    this.lastName,
  });

  factory Customer.fromJson(Map<String, dynamic> json) => Customer(
    id: json["_id"],
    phone: json["phone"],
    firstName: json["firstName"],
    lastName: json["lastName"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "phone": phone,
    "firstName": firstName,
    "lastName": lastName,
  };
}
class Logo {
  String? url;

  Logo({
    this.url,
  });

  factory Logo.fromJson(Map<String, dynamic> json) => Logo(
    url: json["url"],
  );

  Map<String, dynamic> toJson() => {
    "url": url,
  };
}
