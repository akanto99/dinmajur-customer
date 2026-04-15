// To parse this JSON data, do
//
//     final freelancerReviewModel = freelancerReviewModelFromJson(jsonString);

import 'dart:convert';

FreelancerReviewModel freelancerReviewModelFromJson(String str) => FreelancerReviewModel.fromJson(json.decode(str));

String freelancerReviewModelToJson(FreelancerReviewModel data) => json.encode(data.toJson());

class FreelancerReviewModel {
  bool? success;
  String? message;
  dynamic meta;
  Data? data;

  FreelancerReviewModel({this.success, this.message, this.meta, this.data});

  factory FreelancerReviewModel.fromJson(Map<String, dynamic> json) =>
      FreelancerReviewModel(success: json["success"], message: json["message"], meta: json["meta"], data: json["data"] == null ? null : Data.fromJson(json["data"]));

  Map<String, dynamic> toJson() => {"success": success, "message": message, "meta": meta, "data": data?.toJson()};
}

class Data {
  Freelancer? freelancer;
  Stats? stats;
  ReviewsSummery? reviewsSummery;
  List<Review>? reviews;

  Data({this.freelancer, this.stats, this.reviewsSummery, this.reviews});

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    freelancer: json["freelancer"] == null ? null : Freelancer.fromJson(json["freelancer"]),
    stats: json["stats"] == null ? null : Stats.fromJson(json["stats"]),
    reviewsSummery: json["reviewsSummery"] == null ? null : ReviewsSummery.fromJson(json["reviewsSummery"]),
    reviews: json["reviews"] == null ? [] : List<Review>.from(json["reviews"]!.map((x) => Review.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "freelancer": freelancer?.toJson(),
    "stats": stats?.toJson(),
    "reviewsSummery": reviewsSummery?.toJson(),
    "reviews": reviews == null ? [] : List<dynamic>.from(reviews!.map((x) => x.toJson())),
  };
}

class Freelancer {
  List<Skill>? skills;
  String? firstName;
  String? lastName;
  String? fullAddress;
  FreelancerProfilePicture? profilePicture;
  String? phone;
  int? experience;

  Freelancer({this.skills, this.firstName, this.lastName, this.fullAddress, this.profilePicture, this.phone, this.experience});

  factory Freelancer.fromJson(Map<String, dynamic> json) => Freelancer(
    skills: json["skills"] == null ? [] : List<Skill>.from(json["skills"]!.map((x) => Skill.fromJson(x))),
    firstName: json["firstName"],
    lastName: json["lastName"],
    fullAddress: json["fullAddress"],
    profilePicture: json["profilePicture"] == null ? null : FreelancerProfilePicture.fromJson(json["profilePicture"]),
    phone: json["phone"],
    experience: json["experience"],
  );

  Map<String, dynamic> toJson() => {
    "skills": skills == null ? [] : List<dynamic>.from(skills!.map((x) => x.toJson())),
    "firstName": firstName,
    "lastName": lastName,
    "fullAddress": fullAddress,
    "profilePicture": profilePicture?.toJson(),
    "phone": phone,
    "experience": experience,
  };
}

class FreelancerProfilePicture {
  String? url;
  String? key;

  FreelancerProfilePicture({this.url, this.key});

  factory FreelancerProfilePicture.fromJson(Map<String, dynamic> json) => FreelancerProfilePicture(url: json["url"], key: json["key"]);

  Map<String, dynamic> toJson() => {"url": url, "key": key};
}

class Skill {
  String? id;
  String? category;
  String? userId;
  List<String>? items;

  Skill({this.id, this.category, this.userId, this.items});

  factory Skill.fromJson(Map<String, dynamic> json) =>
      Skill(id: json["_id"], category: json["category"], userId: json["userId"], items: json["items"] == null ? [] : List<String>.from(json["items"]!.map((x) => x)));

  Map<String, dynamic> toJson() => {"_id": id, "category": category, "userId": userId, "items": items == null ? [] : List<dynamic>.from(items!.map((x) => x))};
}

class Review {
  String? id;
  Reviewer? reviewer;
  int? rating;
  String? review;

  Review({this.id, this.reviewer, this.rating, this.review});

  factory Review.fromJson(Map<String, dynamic> json) =>
      Review(id: json["_id"], reviewer: json["reviewer"] == null ? null : Reviewer.fromJson(json["reviewer"]), rating: json["rating"], review: json["review"]);

  Map<String, dynamic> toJson() => {"_id": id, "reviewer": reviewer?.toJson(), "rating": rating, "review": review};
}

class Reviewer {
  String? id;
  String? phone;
  String? fullName;
  ReviewerProfilePicture? profilePicture;
  String? reviewerId;

  Reviewer({this.id, this.phone, this.fullName, this.profilePicture, this.reviewerId});

  factory Reviewer.fromJson(Map<String, dynamic> json) => Reviewer(
    id: json["_id"],
    phone: json["phone"],
    fullName: json["fullName"],
    profilePicture: json["profilePicture"] == null ? null : ReviewerProfilePicture.fromJson(json["profilePicture"]),
    reviewerId: json["id"],
  );

  Map<String, dynamic> toJson() => {"_id": id, "phone": phone, "fullName": fullName, "profilePicture": profilePicture?.toJson(), "id": reviewerId};
}

class ReviewerProfilePicture {
  String? url;
  String? altText;
  String? key;

  ReviewerProfilePicture({this.url, this.altText, this.key});

  factory ReviewerProfilePicture.fromJson(Map<String, dynamic> json) => ReviewerProfilePicture(url: json["url"], altText: json["altText"], key: json["key"]);

  Map<String, dynamic> toJson() => {"url": url, "altText": altText, "key": key};
}

class ReviewsSummery {
  int? totalReviews;
  double? avgRating;
  Map<String, int>? ratingBreakdown;

  ReviewsSummery({this.totalReviews, this.avgRating, this.ratingBreakdown});

  factory ReviewsSummery.fromJson(Map<String, dynamic> json) =>
      ReviewsSummery(totalReviews: json["totalReviews"], avgRating: json["avgRating"]?.toDouble(), ratingBreakdown: Map.from(json["ratingBreakdown"]!).map((k, v) => MapEntry<String, int>(k, v)));

  Map<String, dynamic> toJson() => {"totalReviews": totalReviews, "avgRating": avgRating, "ratingBreakdown": Map.from(ratingBreakdown!).map((k, v) => MapEntry<String, dynamic>(k, v))};
}

class Stats {
  int? totalOrders;
  int? runningOrders;
  int? pendingOrders;
  int? completedOrders;
  int? cancelledOrders;
  double? pendingCompletionRate;

  Stats({this.totalOrders, this.runningOrders, this.pendingOrders, this.completedOrders, this.cancelledOrders, this.pendingCompletionRate});

  factory Stats.fromJson(Map<String, dynamic> json) => Stats(
    totalOrders: json["totalOrders"],
    runningOrders: json["runningOrders"],
    pendingOrders: json["pendingOrders"],
    completedOrders: json["completedOrders"],
    cancelledOrders: json["cancelledOrders"],
    pendingCompletionRate: json["pendingCompletionRate"]?.toDouble(),
  );

  Map<String, dynamic> toJson() => {
    "totalOrders": totalOrders,
    "runningOrders": runningOrders,
    "pendingOrders": pendingOrders,
    "completedOrders": completedOrders,
    "cancelledOrders": cancelledOrders,
    "pendingCompletionRate": pendingCompletionRate,
  };
}
