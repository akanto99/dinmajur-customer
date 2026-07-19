import 'dart:convert';

HomeSectionsModel homeSectionsModelFromJson(String str) =>
    HomeSectionsModel.fromJson(json.decode(str));

class HomeSectionsModel {
  bool? success;
  String? message;
  List<HomeSectionItem>? data;

  HomeSectionsModel({this.success, this.message, this.data});

  factory HomeSectionsModel.fromJson(Map<String, dynamic> json) {
    final rawData = json["data"];
    List<HomeSectionItem> items = [];
    if (rawData is List) {
      items = rawData.map((x) => HomeSectionItem.fromJson(x)).toList();
    }
    return HomeSectionsModel(
      success: json["success"],
      message: json["message"],
      data: items,
    );
  }
}

/// One row in the home page's admin-controlled order — either a fixed
/// page block (`type == 'FIXED'`, identified by `key`) or a specific
/// banner/featured-services CMS document (`type == 'CMS'`, identified by
/// `cmsId`). Mirrors HomeSection on the backend (admin.service.ts).
class HomeSectionItem {
  String? id;
  String? type;
  String? key;
  String? cmsId;
  String? placement;
  String? label;
  String? thumbnail;
  int? order;
  bool? isActive;

  HomeSectionItem({
    this.id,
    this.type,
    this.key,
    this.cmsId,
    this.placement,
    this.label,
    this.thumbnail,
    this.order,
    this.isActive,
  });

  factory HomeSectionItem.fromJson(Map<String, dynamic> json) =>
      HomeSectionItem(
        id: json["_id"],
        type: json["type"],
        key: json["key"],
        cmsId: json["cmsId"],
        placement: json["placement"],
        label: json["label"],
        thumbnail: json["thumbnail"],
        order: json["order"] is int ? json["order"] : int.tryParse(json["order"]?.toString() ?? ''),
        isActive: json["isActive"],
      );

  bool get isFixedServices => type == 'FIXED' && key == 'SERVICES';
  bool get isFeaturedServices => type == 'CMS' && placement == 'featured_services';
  bool get isBanner => type == 'CMS' && placement != 'featured_services';
}
