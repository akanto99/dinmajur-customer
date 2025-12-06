// To parse this JSON data, do
//
//     final checkCoverageModel = checkCoverageModelFromJson(jsonString);

import 'dart:convert';

CheckCoverageModel checkCoverageModelFromJson(String str) => CheckCoverageModel.fromJson(json.decode(str));

String checkCoverageModelToJson(CheckCoverageModel data) => json.encode(data.toJson());

class CheckCoverageModel {
  bool? success;
  String? message;
  Data? data;

  CheckCoverageModel({
    this.success,
    this.message,
    this.data,
  });

  factory CheckCoverageModel.fromJson(Map<String, dynamic> json) => CheckCoverageModel(
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
  bool? insideServiceArea;

  Data({
    this.insideServiceArea,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    insideServiceArea: json["insideServiceArea"],
  );

  Map<String, dynamic> toJson() => {
    "insideServiceArea": insideServiceArea,
  };
}
