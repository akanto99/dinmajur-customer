import 'dart:convert';

FeaturedServicesModel featuredServicesModelFromJson(String str) =>
    FeaturedServicesModel.fromJson(json.decode(str));

class FeaturedServicesModel {
  bool? success;
  String? message;
  FeaturedServicesData? data;

  FeaturedServicesModel({this.success, this.message, this.data});

  // API response shape: { success, message, data: [...sections], meta: {...} }
  factory FeaturedServicesModel.fromJson(Map<String, dynamic> json) {
    final rawData = json["data"];
    List<FeaturedSection> sections = [];
    if (rawData is List) {
      sections = rawData.map((x) => FeaturedSection.fromJson(x)).toList();
    }
    final meta = json["meta"] == null ? null : FeaturedServicesMeta.fromJson(json["meta"]);
    return FeaturedServicesModel(
      success: json["success"],
      message: json["message"],
      data: FeaturedServicesData(meta: meta, data: sections),
    );
  }
}

class FeaturedServicesData {
  FeaturedServicesMeta? meta;
  List<FeaturedSection>? data;

  FeaturedServicesData({this.meta, this.data});
}

class FeaturedServicesMeta {
  int? page;
  int? limit;
  int? total;

  FeaturedServicesMeta({this.page, this.limit, this.total});

  factory FeaturedServicesMeta.fromJson(Map<String, dynamic> json) =>
      FeaturedServicesMeta(
        page: int.tryParse(json["page"]?.toString() ?? '') ?? json["page"],
        limit: int.tryParse(json["limit"]?.toString() ?? '') ?? json["limit"],
        total: json["total"] is int ? json["total"] : int.tryParse(json["total"]?.toString() ?? ''),
      );
}

class FeaturedSection {
  String? id;
  String? title;
  String? subtitle;
  String? type;
  String? placement;
  String? homePosition;
  bool? isActive;
  List<FeaturedItem>? items;

  FeaturedSection({this.id, this.title, this.subtitle, this.type, this.placement, this.homePosition, this.isActive, this.items});

  factory FeaturedSection.fromJson(Map<String, dynamic> json) => FeaturedSection(
        id: json["_id"],
        title: json["title"],
        subtitle: json["subtitle"],
        type: json["type"],
        placement: json["placement"],
        homePosition: json["homePosition"],
        isActive: json["isActive"],
        items: json["items"] == null
            ? []
            : List<FeaturedItem>.from(json["items"].map((x) => FeaturedItem.fromJson(x))),
      );
}

class FeaturedItem {
  String? id;
  String? url;
  String? altText;
  FeaturedServiceRef? service;
  FeaturedTaskRef? task;
  int? position;
  bool? isActive;

  FeaturedItem({this.id, this.url, this.altText, this.service, this.task, this.position, this.isActive});

  factory FeaturedItem.fromJson(Map<String, dynamic> json) => FeaturedItem(
        id: json["_id"],
        url: json["url"],
        altText: json["altText"],
        service: json["service"] == null ? null : FeaturedServiceRef.fromJson(json["service"]),
        task: json["task"] == null ? null : FeaturedTaskRef.fromJson(json["task"]),
        position: json["position"],
        isActive: json["isActive"],
      );

  String get displayName {
    if (altText != null && altText!.isNotEmpty) return altText!;
    if (task?.name != null) return task!.name!;
    if (service?.name != null) return service!.name!;
    return '';
  }

  String? get displayImageUrl => url;

  String? get serviceSlug => task?.service?.slug ?? service?.slug;
  String? get serviceId => task?.service?.id ?? service?.id;
  String? get serviceName => task?.service?.name ?? service?.name;
}

class FeaturedTaskRef {
  String? id;
  String? name;
  FeaturedServiceRef? service;
  FeaturedTaskPrice? price;

  FeaturedTaskRef({this.id, this.name, this.service, this.price});

  factory FeaturedTaskRef.fromJson(Map<String, dynamic> json) => FeaturedTaskRef(
        id: json["_id"],
        name: json["name"],
        service: json["service"] == null ? null : FeaturedServiceRef.fromJson(json["service"]),
        price: json["price"] == null ? null : FeaturedTaskPrice.fromJson(json["price"]),
      );
}

class FeaturedTaskPrice {
  double? salePrice;
  double? basePrice;

  FeaturedTaskPrice({this.salePrice, this.basePrice});

  factory FeaturedTaskPrice.fromJson(Map<String, dynamic> json) => FeaturedTaskPrice(
        salePrice: (json["salePrice"] as num?)?.toDouble(),
        basePrice: (json["basePrice"] as num?)?.toDouble(),
      );
}

class FeaturedServiceRef {
  String? id;
  String? slug;
  String? name;
  String? description;

  FeaturedServiceRef({this.id, this.slug, this.name, this.description});

  factory FeaturedServiceRef.fromJson(Map<String, dynamic> json) => FeaturedServiceRef(
        id: json["_id"],
        slug: json["slug"],
        name: json["name"],
        description: json["description"],
      );
}
