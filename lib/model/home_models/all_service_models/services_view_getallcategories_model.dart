import 'dart:convert';

ServicesViewGetAllCategoryModel servicesViewGetAllCategoryModelFromJson(String str) =>
    ServicesViewGetAllCategoryModel.fromJson(json.decode(str));

String servicesViewGetAllCategoryModelToJson(ServicesViewGetAllCategoryModel data) =>
    json.encode(data.toJson());

class ServicesViewGetAllCategoryModel {
  bool? success;
  String? message;
  dynamic meta;
  Data? data;

  ServicesViewGetAllCategoryModel({
    this.success,
    this.message,
    this.meta,
    this.data,
  });

  factory ServicesViewGetAllCategoryModel.fromJson(Map<String, dynamic> json) =>
      ServicesViewGetAllCategoryModel(
        success: json["success"],
        message: json["message"],
        meta: json["meta"],
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "meta": meta,
    "data": data?.toJson(),
  };
}

// ─────────────────────────────────────────────

class Data {
  String? serviceId;
  String? serviceName;
  String? serviceDescription;
  int? totalCategories;
  int? minimumOrderAmount;
  double? transportFee;
  List<Category>? categories;

  Data({
    this.serviceId,
    this.serviceName,
    this.serviceDescription,
    this.transportFee,
    this.minimumOrderAmount,
    this.totalCategories,
    this.categories,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    serviceId: json["serviceId"],
    serviceName: json["serviceName"],
    serviceDescription: json["serviceDescription"],
    transportFee: (json["transportFee"] as num?)?.toDouble(),
    minimumOrderAmount: json["minimumOrderAmount"] ,
    totalCategories: json["totalCategories"],
    categories: json["categories"] == null
        ? []
        : List<Category>.from(
        json["categories"].map((x) => Category.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "serviceId": serviceId,
    "serviceName": serviceName,
    "serviceDescription": serviceDescription,
    "transportFee": transportFee,
    "minimumOrderAmount": minimumOrderAmount,
    "totalCategories": totalCategories,
    "categories": categories == null
        ? []
        : List<dynamic>.from(categories!.map((x) => x.toJson())),
  };
}

// ─────────────────────────────────────────────

class Category {
  String? id;
  String? name;
  String? slug;
  ImageModel? image;
  int? position;
  List<Task>? tasks;
  int? totalTasks;

  Category({
    this.id,
    this.name,
    this.slug,
    this.image,
    this.position,
    this.tasks,
    this.totalTasks,
  });

  factory Category.fromJson(Map<String, dynamic> json) => Category(
    id: json["_id"],
    name: json["name"],
    slug: json["slug"],
    image: json["image"] == null
        ? null
        : json["image"] is String
        ? ImageModel(id: json["image"]) // handles string case
        : ImageModel.fromJson(json["image"]),
    position: json["position"],
    tasks: json["tasks"] == null
        ? []
        : List<Task>.from(json["tasks"].map((x) => Task.fromJson(x))),
    totalTasks: json["totalTasks"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "name": name,
    "slug": slug,
    "image": image?.toJson(),
    "position": position,
    "tasks": tasks == null
        ? []
        : List<dynamic>.from(tasks!.map((x) => x.toJson())),
    "totalTasks": totalTasks,
  };
}

// ─────────────────────────────────────────────

class Task {
  String? id;
  String? name;
  int? position;
  Price? price;
  List<ImageModel>? images;
  int? durationInMin;
  String? description;
  String? overview;
  String? steps;
  String? products;
  String? benefits;
  String? instructions;
  String? details;
  DateTime? createdAt;
  DateTime? updatedAt;
  List<Faq>? faqs;

  Task({
    this.id,
    this.name,
    this.position,
    this.price,
    this.images,
    this.durationInMin,
    this.description,
    this.overview,
    this.steps,
    this.products,
    this.benefits,
    this.instructions,
    this.details,
    this.createdAt,
    this.updatedAt,
    this.faqs,
  });

  factory Task.fromJson(Map<String, dynamic> json) => Task(
    id: json["_id"],
    name: json["name"],
    position: json["position"],
    price: json["price"] == null ? null : Price.fromJson(json["price"]),
    images: json["images"] == null
        ? []
        : List<ImageModel>.from(
        json["images"].map((x) => ImageModel.fromJson(x))),
    durationInMin: json["durationInMin"],
    description: json["description"] is String ? json["description"] : null,
    overview: json["overview"] is String ? json["overview"] : null,
    steps: json["steps"] is String ? json["steps"] : null,
    products: json["products"] is String ? json["products"] : null,
    benefits: json["benefits"] is String ? json["benefits"] : null,
    instructions: json["instructions"] is String ? json["instructions"] : null,
    details: json["details"] is String ? json["details"] : null,
    createdAt: json["createdAt"] == null
        ? null
        : DateTime.tryParse(json["createdAt"]),
    updatedAt: json["updatedAt"] == null
        ? null
        : DateTime.tryParse(json["updatedAt"]),
    faqs: json["faqs"] == null
        ? []
        : List<Faq>.from(json["faqs"].map((x) => Faq.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "name": name,
    "position": position,
    "price": price?.toJson(),
    "images": images == null
        ? []
        : List<dynamic>.from(images!.map((x) => x.toJson())),
    "durationInMin": durationInMin,
    "description": description,
    "overview": overview,
    "steps": steps,
    "products": products,
    "benefits": benefits,
    "instructions": instructions,
    "details": details,
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
    "faqs": faqs == null
        ? []
        : List<dynamic>.from(faqs!.map((x) => x.toJson())),
  };
}

// ─────────────────────────────────────────────

class Faq {
  String? id;
  String? question;
  String? answer;

  Faq({this.id, this.question, this.answer});

  factory Faq.fromJson(Map<String, dynamic> json) => Faq(
    id: json["_id"],
    question: json["question"],
    answer: json["answer"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "question": question,
    "answer": answer,
  };
}

// ─────────────────────────────────────────────

class ImageModel {
  String? id;
  String? key;
  String? altText;
  String? url;

  ImageModel({this.id, this.key, this.altText, this.url});

  factory ImageModel.fromJson(Map<String, dynamic> json) => ImageModel(
    id: json["_id"],
    key: json["key"],
    altText: json["altText"],
    url: json["url"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "key": key,
    "altText": altText,
    "url": url,
  };
}

// ─────────────────────────────────────────────

class Price {
  double? basePrice;
  double? salePrice;
  DiscountType? discountType;
  double? discountValue;

  Price({
    this.basePrice,
    this.salePrice,
    this.discountType,
    this.discountValue,
  });

  factory Price.fromJson(Map<String, dynamic> json) => Price(
    basePrice: (json["basePrice"] as num?)?.toDouble(),
    salePrice: (json["salePrice"] as num?)?.toDouble(),
    discountType:
    discountTypeValues.map[json["discountType"]] ??
        DiscountType.NONE,
    discountValue: (json["discountValue"] as num?)?.toDouble(),
  );

  Map<String, dynamic> toJson() => {
    "basePrice": basePrice,
    "salePrice": salePrice,
    "discountType": discountTypeValues.reverse[discountType],
    "discountValue": discountValue,
  };
}

// ─────────────────────────────────────────────

enum DiscountType { FLAT, NONE, PERCENTAGE }

final discountTypeValues = EnumValues({
  "FLAT": DiscountType.FLAT,
  "NONE": DiscountType.NONE,
  "PERCENTAGE": DiscountType.PERCENTAGE,
});

class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}