import 'dart:convert';

OrderDetailsModel orderDetailsModelFromJson(String str) => OrderDetailsModel.fromJson(json.decode(str));

String orderDetailsModelToJson(OrderDetailsModel data) => json.encode(data.toJson());

class OrderDetailsModel {
  Order? order;
  Retailer? retailer;
  Customer? customer;
  Freelancer? freelancer;
  Delivery? delivery;
  Payment? payment;

  OrderDetailsModel({
    this.order,
    this.retailer,
    this.customer,
    this.freelancer,
    this.delivery,
    this.payment,
  });

  factory OrderDetailsModel.fromJson(Map<String, dynamic> json) => OrderDetailsModel(
    order: json["order"] == null ? null : Order.fromJson(json["order"]),
    retailer: json["retailer"] == null ? null : Retailer.fromJson(json["retailer"]),
    customer: json["customer"] == null ? null : Customer.fromJson(json["customer"]),
    freelancer: json["freelancer"] == null ? null : Freelancer.fromJson(json["freelancer"]),
    delivery: json["delivery"] == null ? null : Delivery.fromJson(json["delivery"]),
    payment: json["payment"] == null ? null : Payment.fromJson(json["payment"]),

  );

  Map<String, dynamic> toJson() => {
    "order": order?.toJson(),
    "retailer": retailer?.toJson(),
    "customer": customer?.toJson(),
    "freelancer": freelancer?.toJson(),
    "delivery": delivery?.toJson(),
    "payment": payment?.toJson(),
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
    String? trackingId;
  String? orderId;
  Destination? pickup;
  String? pickupFullAddress;
  Destination? destination;
  String? destinationFullAddress;
  int? fare;
  String? status;
  String? duration;
  String? distance;
  DateTime? createdAt;
  DateTime? updatedAt;

  Delivery({
    this.id,
    this.customerId,
    this.retailerId,
        this.trackingId,
    this.orderId,
    this.pickup,
    this.pickupFullAddress,
    this.destination,
    this.destinationFullAddress,
    this.fare,
    this.status,
    this.duration,
    this.distance,
    this.createdAt,
    this.updatedAt,
  });

  factory Delivery.fromJson(Map<String, dynamic> json) {
    // ✅ Helper function for safe date parsing
    DateTime? parseDateTime(dynamic value) {
      if (value == null) return null;
      try {
        if (value is String) {
          return DateTime.parse(value);
        }
        return null;
      } catch (e) {
        print('⚠️ Delivery date parse error: $value - $e');
        return null;
      }
    }

    return Delivery(
      id: json["_id"],
      customerId: json["customerId"],
      retailerId: json["retailerId"],
          trackingId: json["trackingId"],
      orderId: json["orderId"],
      pickup: json["pickup"] == null ? null : Destination.fromJson(json["pickup"]),
      pickupFullAddress: json["pickupFullAddress"],
      destination: json["destination"] == null ? null : Destination.fromJson(json["destination"]),
      destinationFullAddress: json["destinationFullAddress"],
      fare: json["fare"],
      status: json["status"],
      duration: json["duration"],
      distance: json["distance"],
      createdAt: parseDateTime(json["createdAt"]),
      updatedAt: parseDateTime(json["updatedAt"]),
    );
  }

  Map<String, dynamic> toJson() => {
    "_id": id,
    "customerId": customerId,
    "retailerId": retailerId,
        "trackingId": trackingId,
    "orderId": orderId,
    "pickup": pickup?.toJson(),
    "pickupFullAddress": pickupFullAddress,
    "destination": destination?.toJson(),
    "destinationFullAddress": destinationFullAddress,
    "fare": fare,
    "status": status,
    "duration": duration,
    "distance": distance,
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
  };
}

class Destination {
  double? lat;
  double? lng;

  Destination({
    this.lat,
    this.lng,
  });

  factory Destination.fromJson(Map<String, dynamic> json) => Destination(
    lat: json["lat"]?.toDouble(),
    lng: json["lng"]?.toDouble(),
  );

  Map<String, dynamic> toJson() => {
    "lat": lat,
    "lng": lng,
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
  dynamic deliveryCharge;
  int? budget;
  String? estimatedDeliveryTime;
    int? freelancerEarning;
  int? customerPlatformFee;
  List<Item>? items;
  String? status;
  int? vat;
  int? subTotalAmount;
  int? totalAmount;
  String? customerNote;
  DateTime? createdAt;
  DateTime? updatedAt;

  Order({
    this.id,
    this.customerId,
    this.retailerId,
    this.paymentMethodId,
    this.deliveryCharge,
    this.budget,
    this.estimatedDeliveryTime,
        this.freelancerEarning,
    this.customerPlatformFee,
    this.items,
    this.status,
    this.vat,
    this.subTotalAmount,
    this.totalAmount,
    this.customerNote,
    this.createdAt,
    this.updatedAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    // ✅ Helper function for safe date parsing
    DateTime? parseDateTime(dynamic value) {
      if (value == null) return null;
      try {
        if (value is String) {
          return DateTime.parse(value);
        }
        return null;
      } catch (e) {
        print('⚠️ Order date parse error: $value - $e');
        return null;
      }
    }

    return Order(
      id: json["_id"],
      customerId: json["customerId"],
      retailerId: json["retailerId"],
      paymentMethodId: json["paymentMethodId"],
      deliveryCharge: json["deliveryCharge"],
      budget: json["budget"],
      estimatedDeliveryTime: json["estimatedDeliveryTime"]?.toString(),
          freelancerEarning: json["freelancerEarning"],
      customerPlatformFee: json["customerPlatformFee"],
      items: json["items"] == null ? [] : List<Item>.from(json["items"]!.map((x) => Item.fromJson(x))),
      status: json["status"],
      vat: json["vat"],
      subTotalAmount: json["subTotalAmount"],
      totalAmount: json["totalAmount"],
      customerNote: json["customerNote"],
      createdAt: parseDateTime(json["createdAt"]),
      updatedAt: parseDateTime(json["updatedAt"]),
    );
  }

  Map<String, dynamic> toJson() => {
    "_id": id,
    "customerId": customerId,
    "retailerId": retailerId,
    "paymentMethodId": paymentMethodId,
    "deliveryCharge": deliveryCharge,
    "budget": budget,
    "estimatedDeliveryTime": estimatedDeliveryTime,
        "freelancerEarning": freelancerEarning,
    "customerPlatformFee": customerPlatformFee,
    "items": items == null ? [] : List<dynamic>.from(items!.map((x) => x.toJson())),
    "status": status,
    "vat": vat,
    "subTotalAmount": subTotalAmount,
    "totalAmount": totalAmount,
    "customerNote": customerNote,
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
  };
}

class Item {
  String? id;
  String? name;
  double? quantity; // ✅ Changed from int? to double? (from logs: quantity: 1.5, 0.5)
  String? unit;
  int? unitPrice;
  int? totalPrice;
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

  factory Item.fromJson(Map<String, dynamic> json) {
    // ✅ Helper function for safe date parsing
    DateTime? parseDateTime(dynamic value) {
      if (value == null) return null;
      try {
        if (value is String) {
          return DateTime.parse(value);
        }
        return null;
      } catch (e) {
        print('⚠️ Item date parse error: $value - $e');
        return null;
      }
    }

    return Item(
      id: json["_id"],
      name: json["name"],
      quantity: json["quantity"]?.toDouble(), // ✅ Safe conversion to double
      unit: json["unit"],
      unitPrice: json["unitPrice"],
      totalPrice: json["totalPrice"],
      status: json["status"],
      createdAt: parseDateTime(json["createdAt"]),
      updatedAt: parseDateTime(json["updatedAt"]),
      comment: json["comment"],
    );
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
class Payment {
  String? id;
  int? amount;
  String? paymentType;
  String? status;

  Payment({
    this.id,
    this.amount,
    this.paymentType,
    this.status,
  });

  factory Payment.fromJson(Map<String, dynamic> json) => Payment(
    id: json["_id"],
    amount: json["amount"],
    paymentType: json["paymentType"],
    status: json["status"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "amount": amount,
    "paymentType": paymentType,
    "status": status,
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