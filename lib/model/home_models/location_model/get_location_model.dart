// File: lib/model/home_models/location_model/get_location_model.dart

class GetLocationListDataModel {
  bool success;
  String message;
  List<Datum> data;

  GetLocationListDataModel({required this.success, required this.message, required this.data});

  // Factory constructor to create an instance from JSON
  factory GetLocationListDataModel.fromJson(Map<String, dynamic> json) {
    return GetLocationListDataModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? (json['data'] as List).map((item) => Datum.fromJson(item)).toList() : [],
    );
  }

  // Method to convert instance to JSON
  Map<String, dynamic> toJson() {
    return {'success': success, 'message': message, 'data': data.map((item) => item.toJson()).toList()};
  }
}

class Datum {
  String id;
  String userId;
  String type;
  String fullAddress;
  GeoLocation geoLocation;
  DateTime createdAt;
  DateTime updatedAt;
  int v;

  Datum({required this.id, required this.userId, required this.type, required this.fullAddress, required this.geoLocation, required this.createdAt, required this.updatedAt, required this.v});

  // Factory constructor to create an instance from JSON
  factory Datum.fromJson(Map<String, dynamic> json) {
    return Datum(
      id: json['_id'] ?? '',
      userId: json['userId'] ?? '',
      type: json['type'] ?? '',
      fullAddress: json['fullAddress'] ?? '',
      geoLocation: json['geoLocation'] != null ? GeoLocation.fromJson(json['geoLocation']) : GeoLocation(type: 'Point', coordinates: [0.0, 0.0]),
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : DateTime.now(),
      v: json['__v'] ?? 0,
    );
  }

  // Method to convert instance to JSON
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'userId': userId,
      'type': type,
      'fullAddress': fullAddress,
      'geoLocation': geoLocation.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      '__v': v,
    };
  }
}

class GeoLocation {
  String type;
  List<double> coordinates;

  GeoLocation({required this.type, required this.coordinates});

  // Factory constructor to create an instance from JSON
  factory GeoLocation.fromJson(Map<String, dynamic> json) {
    return GeoLocation(type: json['type'] ?? 'Point', coordinates: json['coordinates'] != null ? (json['coordinates'] as List).map((e) => (e as num).toDouble()).toList() : [0.0, 0.0]);
  }

  // Method to convert instance to JSON
  Map<String, dynamic> toJson() {
    return {'type': type, 'coordinates': coordinates};
  }
}
