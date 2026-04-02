import 'dart:convert';
import 'package:dinmajur_customer/configs/utils/utils.dart';
import 'package:dinmajur_customer/respository/home_repositories/nearby_retailers_and_order_repository/order_now_repository/freelancer_rating_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

class PatchFreelancerRatingViewModel with ChangeNotifier {
  final _myRepo = PatchFreelancerRatingRepository();
  bool _createFreelancerRatingLoading = false;
  bool get createFreelancerRatingLoading => _createFreelancerRatingLoading;

  setCreateFreelancerRatingLoading(bool value) {
    _createFreelancerRatingLoading = value;
    notifyListeners();
  }

  Future<bool> FreelancerRatingPatchApi(BuildContext context, dynamic fields, {VoidCallback? onSuccess}) async {
    setCreateFreelancerRatingLoading(true);
    try {
      dynamic value = await _myRepo.freelancerRatingPatchApi(fields);
      if (kDebugMode) print(value.toString());

      // ✅ Fire callback BEFORE notifyListeners() to avoid rebuild conflict
      onSuccess?.call();

      // ✅ Update loading state AFTER callback
      setCreateFreelancerRatingLoading(false);
      Utils.flushBarSuccessMessage('Review Submitted Successfully', context);
      return true;
    } catch (error) {
      setCreateFreelancerRatingLoading(false);
      _handleError(error, context);
      return false;
    }
  }

  void _handleError(dynamic error, BuildContext context) {
    String errorMessage = '$error';
    try {
      String errorBody = error.toString();
      int jsonStartIndex = errorBody.indexOf('{');
      if (jsonStartIndex != -1) {
        final decoded = jsonDecode(errorBody.substring(jsonStartIndex));
        errorMessage = decoded['message'] ?? (decoded['errorMessages'] is List && decoded['errorMessages'].isNotEmpty ? decoded['errorMessages'][0]['message'] : errorMessage);
      }
    } catch (_) {
      errorMessage = 'Unexpected error occurred';
    }
    Utils.flushBarErrorMessage(errorMessage, context);
  }
}
