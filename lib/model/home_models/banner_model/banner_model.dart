import 'dart:convert';

BannerModel bannerModelFromJson(String str) => BannerModel.fromJson(json.decode(str));
String bannerModelToJson(BannerModel data) => json.encode(data.toJson());

class BannerModel {
  bool? success;
  String? message;
  dynamic meta;
  Data? data;

  BannerModel({this.success, this.message, this.meta, this.data});

  factory BannerModel.fromJson(Map<String, dynamic> json) =>
      BannerModel(success: json["success"], message: json["message"], meta: json["meta"], data: json["data"] == null ? null : Data.fromJson(json["data"]));

  Map<String, dynamic> toJson() => {"success": success, "message": message, "meta": meta, "data": data?.toJson()};
}

class Data {
  String? id;
  String? type;
  String? placement;
  BannerImage? image;
  bool? isActive;
  List<BannerItem>? items;
  BannerVideo? video;

  Data({this.id, this.type, this.placement, this.image, this.isActive, this.items, this.video});

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    id: json["_id"],
    type: json["type"],
    placement: json["placement"],
    image: json["image"] == null ? null : BannerImage.fromJson(json["image"]),
    isActive: json["isActive"],
    items: json["items"] == null ? [] : List<BannerItem>.from(json["items"].map((x) => BannerItem.fromJson(x))),
    video: json["video"] == null ? null : BannerVideo.fromJson(json["video"]),
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "type": type,
    "placement": placement,
    "image": image?.toJson(),
    "isActive": isActive,
    "items": items == null ? [] : List<dynamic>.from(items!.map((x) => x.toJson())),
    "video": video?.toJson(),
  };
}

// ── Video banner — no tap-to-navigate target on the backend model
// (unlike image/items, which carry a linked service/task), just a plain
// looping video.
class BannerVideo {
  String? url;
  String? altText;

  BannerVideo({this.url, this.altText});

  factory BannerVideo.fromJson(Map<String, dynamic> json) => BannerVideo(url: json["url"], altText: json["altText"]);

  Map<String, dynamic> toJson() => {"url": url, "altText": altText};
}

class BannerImage {
  String? type;
  String? url;
  Service? service;

  BannerImage({this.type, this.url, this.service});

  factory BannerImage.fromJson(Map<String, dynamic> json) => BannerImage(type: json["type"], url: json["url"], service: json["service"] == null ? null : Service.fromJson(json["service"]));

  Map<String, dynamic> toJson() => {"type": type, "url": url, "service": service?.toJson()};
}

// ── New typed class for carousel items ──────────────────────────────
class BannerItem {
  String? type;
  String? url;
  Service? service;
  int? position;
  bool? isActive;

  BannerItem({this.type, this.url, this.service, this.position, this.isActive});

  factory BannerItem.fromJson(Map<String, dynamic> json) =>
      BannerItem(type: json["type"], url: json["url"], service: json["service"] == null ? null : Service.fromJson(json["service"]), position: json["position"], isActive: json["isActive"]);

  Map<String, dynamic> toJson() => {"type": type, "url": url, "service": service?.toJson(), "position": position, "isActive": isActive};
}

class Service {
  String? id;
  String? name;
  String? slug;
  String? description;

  Service({this.id, this.name, this.slug, this.description});

  factory Service.fromJson(Map<String, dynamic> json) => Service(id: json["_id"], name: json["name"], slug: json["slug"], description: json["description"]);

  Map<String, dynamic> toJson() => {"_id": id, "name": name, "slug": slug, "description": description};
}
