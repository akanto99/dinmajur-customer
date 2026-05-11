// To parse this JSON data, do
//
//     final getOrderDetailsModel = getOrderDetailsModelFromJson(jsonString);

import 'dart:convert';
import 'package:flutter/foundation.dart';

GetOrderDetailsModel getOrderDetailsModelFromJson(String str) => GetOrderDetailsModel.fromJson(json.decode(str));

String getOrderDetailsModelToJson(GetOrderDetailsModel data) => json.encode(data.toJson());

class GetOrderDetailsModel {
  bool? success;
  String? message;
  Data? data;

  GetOrderDetailsModel({
    this.success,
    this.message,
    this.data,
  });

  factory GetOrderDetailsModel.fromJson(Map<String, dynamic> json) => GetOrderDetailsModel(
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
  Order? order;
  Retailer? retailer;
  Customer? customer;
  Freelancer? freelancer;
  Delivery? delivery;
  PaymentMethod? paymentMethod;

  Data({
    this.order,
    this.retailer,
    this.customer,
    this.freelancer,
    this.delivery,
    this.paymentMethod,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    order: json["order"] == null ? null : Order.fromJson(json["order"]),
    retailer: json["retailer"] == null ? null : Retailer.fromJson(json["retailer"]),
    customer: json["customer"] == null ? null : Customer.fromJson(json["customer"]),
    freelancer: json["freelancer"] == null ? null : Freelancer.fromJson(json["freelancer"]),
    delivery: json["delivery"] == null ? null : Delivery.fromJson(json["delivery"]),
    paymentMethod: json["paymentMethod"] == null ? null : PaymentMethod.fromJson(json["paymentMethod"]),
  );

  Map<String, dynamic> toJson() => {
    "order": order?.toJson(),
    "retailer": retailer?.toJson(),
    "customer": customer?.toJson(),
    "freelancer": freelancer?.toJson(),
    "delivery": delivery?.toJson(),
    "paymentMethod": paymentMethod?.toJson(),
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
  String? id;
  String? customerId;
  String? retailerId;
  String? orderId;
  Destination? pickup;
  String? pickupFullAddress;
  Destination? destination;
  String? destinationFullAddress;
  String? status;
  String? duration;
  String? distance;
  DateTime? createdAt;
  DateTime? updatedAt;
  DateTime? acceptedAt;
  DateTime? pickedUpAt;
  DateTime? deliveredAt;

  Delivery({
    this.id,
    this.customerId,
    this.retailerId,
    this.orderId,
    this.pickup,
    this.pickupFullAddress,
    this.destination,
    this.destinationFullAddress,
    this.status,
    this.duration,
    this.distance,
    this.createdAt,
    this.updatedAt,
    this.acceptedAt,
    this.pickedUpAt,
    this.deliveredAt,
  });

  factory Delivery.fromJson(Map<String, dynamic> json) => Delivery(
    id: json["_id"],
    customerId: json["customerId"],
    retailerId: json["retailerId"],
    orderId: json["orderId"],
    pickup: json["pickup"] == null ? null : Destination.fromJson(json["pickup"]),
    pickupFullAddress: json["pickupFullAddress"],
    destination: json["destination"] == null ? null : Destination.fromJson(json["destination"]),
    destinationFullAddress: json["destinationFullAddress"],
    status: json["status"],
    duration: json["duration"],
    distance: json["distance"],
    // ✅ Safe date parsing
    createdAt: _parseDate(json["createdAt"]),
    updatedAt: _parseDate(json["updatedAt"]),
    acceptedAt: _parseDate(json["acceptedAt"]),
    pickedUpAt: _parseDate(json["pickedUpAt"]),
    deliveredAt: _parseDate(json["deliveredAt"]),
  );

  // ✅ Helper method for safe date parsing
  static DateTime? _parseDate(dynamic dateValue) {
    if (dateValue == null) return null;

    try {
      if (dateValue is String && dateValue.isNotEmpty) {
        return DateTime.parse(dateValue);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Map<String, dynamic> toJson() => {
    "_id": id,
    "customerId": customerId,
    "retailerId": retailerId,
    "orderId": orderId,
    "pickup": pickup?.toJson(),
    "pickupFullAddress": pickupFullAddress,
    "destination": destination?.toJson(),
    "destinationFullAddress": destinationFullAddress,
    "status": status,
    "duration": duration,
    "distance": distance,
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
    "acceptedAt": acceptedAt?.toIso8601String(),
    "pickedUpAt": pickedUpAt?.toIso8601String(),
    "deliveredAt": deliveredAt?.toIso8601String(),
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
  String? id;
  String? firstName;
  String? lastName;
  String? phone;
  ProfilePicture? profilePicture;
  double? rating;
  DateTime? acceptedAt;
  int? totalOrders;

  Freelancer({
    this.id,
    this.firstName,
    this.lastName,
    this.phone,
    this.profilePicture,
    this.rating,
    this.acceptedAt,
    this.totalOrders,
  });

  factory Freelancer.fromJson(Map<String, dynamic> json) {
    // Helper function for safe date parsing
    DateTime? parseDateTime(dynamic value) {
      if (value == null) return null;
      try {
        if (value is String) {
          return DateTime.parse(value);
        }
        return null;
      } catch (e) {
        print('⚠️ Freelancer date parse error: $value - $e');
        return null;
      }
    }

    return Freelancer(
      id: json["_id"],
      firstName: json["firstName"],
      lastName: json["lastName"],
      phone: json["phone"],
      profilePicture: json["profilePicture"] != null
          ? ProfilePicture.fromJson(json["profilePicture"])
          : null,
      rating: json["rating"]?.toDouble(),
      acceptedAt: parseDateTime(json["acceptedAt"]),
      totalOrders: json["totalOrders"],
    );
  }

  Map<String, dynamic> toJson() => {
    "_id": id,
    "firstName": firstName,
    "lastName": lastName,
    "phone": phone,
    "profilePicture": profilePicture?.toJson(),
    "rating": rating,
    "acceptedAt": acceptedAt?.toIso8601String(),
    "totalOrders": totalOrders,
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

class Order {
  String? id;
  String? customerId;
  String? retailerId;
  String? paymentMethodId;
  num? budget;
  String? estimatedDeliveryTime;
  List<Item>? items;
  String? status;
  num? vat;
  num? subTotalAmount;
  num? totalAmount;
  num? freelancerEarning;
  num? customerPlatformFee;
  String? customerNote;
  DateTime? createdAt;
  DateTime? updatedAt;
  num? deliveryCharge;
  num? ontimeBonus;
  num? basePay;
  num? customerTip;

  Order({
    this.id,
    this.customerId,
    this.retailerId,
    this.paymentMethodId,
    this.budget,
    this.estimatedDeliveryTime,
    this.items,
    this.status,
    this.vat,
    this.subTotalAmount,
    this.totalAmount,
    this.freelancerEarning,
    this.customerPlatformFee,
    this.customerNote,
    this.createdAt,
    this.updatedAt,
    this.deliveryCharge,
    this.ontimeBonus,
    this.basePay,
    this.customerTip,
  });

  factory Order.fromJson(Map<String, dynamic> json) => Order(
    id: json["_id"],
    customerId: json["customerId"],
    retailerId: json["retailerId"],
    paymentMethodId: json["paymentMethodId"],
    budget: json["budget"],
    estimatedDeliveryTime: json["estimatedDeliveryTime"],
    items: json["items"] == null ? [] : List<Item>.from(json["items"]!.map((x) => Item.fromJson(x))),
    status: json["status"],
    vat: json["vat"],
    subTotalAmount: json["subTotalAmount"],
    totalAmount: json["totalAmount"],
    freelancerEarning: json["freelancerEarning"],
    customerPlatformFee: json["customerPlatformFee"],
    customerNote: json["customerNote"],
    // ✅ Safe date parsing
    createdAt: _parseDate(json["createdAt"]),
    updatedAt: _parseDate(json["updatedAt"]),
    deliveryCharge: json["deliveryCharge"],
    ontimeBonus: json["ontimeBonus"],
    basePay: json["basePay"],
    customerTip: json["customerTip"],
  );

  // ✅ Helper method for safe date parsing
  static DateTime? _parseDate(dynamic dateValue) {
    if (dateValue == null) return null;

    try {
      if (dateValue is String && dateValue.isNotEmpty) {
        return DateTime.parse(dateValue);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Map<String, dynamic> toJson() => {
    "_id": id,
    "customerId": customerId,
    "retailerId": retailerId,
    "paymentMethodId": paymentMethodId,
    "budget": budget,
    "estimatedDeliveryTime": estimatedDeliveryTime,
    "items": items == null ? [] : List<dynamic>.from(items!.map((x) => x.toJson())),
    "status": status,
    "vat": vat,
    "subTotalAmount": subTotalAmount,
    "totalAmount": totalAmount,
    "freelancerEarning": freelancerEarning,
    "customerPlatformFee": customerPlatformFee,
    "customerNote": customerNote,
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
    "deliveryCharge": deliveryCharge,
    "ontimeBonus": ontimeBonus,
    "basePay": basePay,
    "customerTip": customerTip,
  };
}

class Item {
  String? id;
  String? name;
  double? quantity;
  String? unit;
  num? unitPrice;
  num? totalPrice;
  String? status;
  DateTime? createdAt;
  DateTime? updatedAt;
    String? comment;

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
        this.comment,
  });

  factory Item.fromJson(Map<String, dynamic> json) => Item(
    id: json["_id"],
    name: json["name"],
    quantity: json["quantity"]?.toDouble(),
    unit: json["unit"],
    unitPrice: json["unitPrice"],
    totalPrice: json["totalPrice"],
    status: json["status"],
    // ✅ Safe date parsing
    createdAt: _parseDate(json["createdAt"]),
    updatedAt: _parseDate(json["updatedAt"]),
          comment: json["comment"],
  );

  // ✅ Helper method for safe date parsing
  static DateTime? _parseDate(dynamic dateValue) {
    if (dateValue == null) return null;

    try {
      if (dateValue is String && dateValue.isNotEmpty) {
        return DateTime.parse(dateValue);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

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
        "comment": comment,
  };
}
class PaymentMethod {
  String? id;
  String? type;
  String? provider;

  PaymentMethod({
    this.id,
    this.type,
    this.provider,
  });

  factory PaymentMethod.fromJson(Map<String, dynamic> json) => PaymentMethod(
    id: json["_id"],
    type: json["type"],
    provider: json["provider"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "type": type,
    "provider": provider,
  };
}

class Retailer {
  String? id;
  String? userId;
  String? businessType;
  String? businessName;
  String? businessOpeningTime;
  String? businessClosingTime;
  Logo? logo;
  Destination? geoLocation;
  String? fullAddress;

  Retailer({
    this.id,
    this.userId,
    this.businessType,
    this.businessName,
    this.businessOpeningTime,
    this.businessClosingTime,
    this.logo,
    this.geoLocation,
    this.fullAddress,
  });

  factory Retailer.fromJson(Map<String, dynamic> json) => Retailer(
    id: json["_id"],
    userId: json["userId"],
    businessType: json["businessType"],
    businessName: json["businessName"],
    businessOpeningTime: json["businessOpeningTime"],
    businessClosingTime: json["businessClosingTime"],
    logo: json["logo"] == null ? null : Logo.fromJson(json["logo"]),
    geoLocation: json["geoLocation"] == null ? null : Destination.fromJson(json["geoLocation"]),
    fullAddress: json["fullAddress"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "userId": userId,
    "businessType": businessType,
    "businessName": businessName,
    "businessOpeningTime": businessOpeningTime,
    "businessClosingTime": businessClosingTime,
    "logo": logo?.toJson(),
    "geoLocation": geoLocation?.toJson(),
    "fullAddress": fullAddress,
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