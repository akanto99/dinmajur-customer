import 'package:dinmajur_customer/data/network/NetworkApiService.dart';
import 'package:dinmajur_customer/data/response/api_response.dart';
import 'package:dinmajur_customer/model/home_models/dropdown_categories_selection_models/premium_house_keeper_model/check_coverage_model.dart';
import 'package:dinmajur_customer/respository/home_repositories/dropdown_categories_selection_repositories/premium_house_keeper_repository/check_coverage_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

// class CheckCoverageViewModel with ChangeNotifier {
//   final _myRepo = CheckCoverageRepository();
//
//   ApiResponse<CheckCoverageModel> checkCoverageData = ApiResponse.loading();
//
//   setCheckCoverageData(ApiResponse<CheckCoverageModel> response){
//     checkCoverageData = response;
//     notifyListeners();
//   }
//
//   Future<void> fetchCheckCoverageDataApi() async {
//     setCheckCoverageData(ApiResponse.loading());
//
//     try {
//       final value = await _myRepo.fetchCheckCoverageData();
//       print('✅ API Response: $value');
//       print('✅ Inside Service Area: ${value.data?.insideServiceArea}');
//       setCheckCoverageData(ApiResponse.completed(value));
//     } catch (error, stackTrace) {
//       if (kDebugMode) {
//         print('❌ Error: $error');
//         print('❌ StackTrace: $stackTrace');
//       }
//       setCheckCoverageData(ApiResponse.error(error.toString()));
//     }
//   }
// }
class CheckCoverageViewModel with ChangeNotifier {
  final _myRepo = CheckCoverageRepository();

  ApiResponse<CheckCoverageModel> checkCoverageData = ApiResponse.loading();

  setCheckCoverageData(ApiResponse<CheckCoverageModel> response) {
    checkCoverageData = response;
    notifyListeners();
  }

  Future<void> fetchCheckCoverageDataApi() async {
    setCheckCoverageData(ApiResponse.loading());

    try {
      final value = await _myRepo.fetchCheckCoverageData();
      print('✅ API Response: $value');
      print('✅ Inside Service Area: ${value.data?.insideServiceArea}');
      setCheckCoverageData(ApiResponse.completed(value));
    } catch (error, stackTrace) {
      if (kDebugMode) {
        print('❌ Error: $error');
        print('❌ StackTrace: $stackTrace');
      }

      // ✅ Set error state immediately - don't retry in ViewModel
      setCheckCoverageData(ApiResponse.error(error.toString()));

      // // ✅ Clear retry attempts on error
      // NetworkApiService.clearRetryAttempts();
    }
  }



}