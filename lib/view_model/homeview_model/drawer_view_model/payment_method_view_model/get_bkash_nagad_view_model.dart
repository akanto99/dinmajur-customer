import 'package:dinmajur_customer/data/response/api_response.dart';
import 'package:dinmajur_customer/data/response/status.dart';
import 'package:dinmajur_customer/model/home_models/drawer_models/payment_method_model/get_bkash_nagad_model.dart';
import 'package:dinmajur_customer/respository/home_repositories/drawer_repository/payment_method_repository/get_bkash_nagad_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

class GetBkashNagadViewModel with ChangeNotifier {
  final _myRepo = GetBkashNagadRepository();

  // Separate API responses for Bkash and Nagad
  ApiResponse<GetBkashNagadModel> _bkashData = ApiResponse.loading();
  ApiResponse<GetBkashNagadModel> _nagadData = ApiResponse.loading();
  ApiResponse<GetBkashNagadModel> _fetchBkashNagadData = ApiResponse.loading();

  ApiResponse<GetBkashNagadModel> get bkashData => _bkashData;
  ApiResponse<GetBkashNagadModel> get nagadData => _nagadData;
  ApiResponse<GetBkashNagadModel> get bkashNagadData => _fetchBkashNagadData;

  // Getters for easier access
  bool get isBkashLoading => _bkashData.status == Status.LOADING;
  bool get isNagadLoading => _nagadData.status == Status.LOADING;
  bool get isBksahNagadLoading => _fetchBkashNagadData.status == Status.LOADING;

  GetBkashNagadModel? get bkashAccountData => _bkashData.data;
  GetBkashNagadModel? get nagadAccountData => _nagadData.data;
  GetBkashNagadModel? get getBkashNagadModel => _fetchBkashNagadData.data;

  void setBkashDataLoading(ApiResponse<GetBkashNagadModel> response) {
    _bkashData = response;
    notifyListeners();
  }

  void setNagadDataLoading(ApiResponse<GetBkashNagadModel> response) {
    _nagadData = response;
    notifyListeners();
  }

  void setBkashNagadDataLoading(ApiResponse<GetBkashNagadModel> response) {
    _fetchBkashNagadData = response;
    notifyListeners();
  }

  Future<void> fetchBkashDataGetApi() async {
    setBkashDataLoading(ApiResponse.loading());

    _myRepo.getBkashNagadGETAPI("bkash").then((value) {
      if (kDebugMode) print("Bkash Data: $value");
      setBkashDataLoading(ApiResponse.completed(value));
    }).onError((error, stackTrace) {
      if (kDebugMode) {
        print("Bkash Error: $error");
        print(stackTrace);
      }
      setBkashDataLoading(ApiResponse.error(error.toString()));
    });
  }

  Future<void> fetchNagadDataGetApi() async {
    setNagadDataLoading(ApiResponse.loading());

    _myRepo.getBkashNagadGETAPI("nagad").then((value) {
      if (kDebugMode) print("Nagad Data: $value");
      setNagadDataLoading(ApiResponse.completed(value));
    }).onError((error, stackTrace) {
      if (kDebugMode) {
        print("Nagad Error: $error");
        print(stackTrace);
      }
      setNagadDataLoading(ApiResponse.error(error.toString()));
    });
  }

  Future<void> fetchBothPaymentMethodsData() async {
    setBkashNagadDataLoading(ApiResponse.loading());

    try {
      // Call the getAllBkashNagadGETAPI method to get all payment methods
      final value = await _myRepo.getAllBkashNagadGETAPI("");

      if (kDebugMode) print("All Payment Methods Data: $value");
      setBkashNagadDataLoading(ApiResponse.completed(value));
    } catch (error, stackTrace) {
      if (kDebugMode) {
        print("All Payment Methods Error: $error");
        print(stackTrace);
      }
      setBkashNagadDataLoading(ApiResponse.error(error.toString()));
    }
  }

  // Helper methods to get specific payment method data
  List<Datum> get bkashMethods {
    if (_fetchBkashNagadData.data?.data != null) {
      return _fetchBkashNagadData.data!.data!
          .where((method) => method.provider?.toLowerCase() == 'bkash')
          .toList();
    }
    return [];
  }

  List<Datum> get nagadMethods {
    if (_fetchBkashNagadData.data?.data != null) {
      return _fetchBkashNagadData.data!.data!
          .where((method) => method.provider?.toLowerCase() == 'nagad')
          .toList();
    }
    return [];
  }

  bool get hasAnyPaymentMethods {
    return bkashMethods.isNotEmpty || nagadMethods.isNotEmpty;
  }
}