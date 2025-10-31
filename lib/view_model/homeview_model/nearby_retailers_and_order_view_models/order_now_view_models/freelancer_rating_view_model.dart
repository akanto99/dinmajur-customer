import 'dart:convert';
import 'package:dinmajur_customer/configs/utils/routes/routes_name.dart';
import 'package:dinmajur_customer/configs/utils/utils.dart';
import 'package:dinmajur_customer/respository/home_repositories/nearby_retailers_and_order_repository/order_now_repository/freelancer_rating_repository.dart';
import 'package:dinmajur_customer/respository/home_repositories/post_change_password/post_change_password_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PatchFreelancerRatingViewModel with ChangeNotifier {
  final _myRepo = PatchFreelancerRatingRepository();
  bool _createFreelancerRatingLoading = false;
  bool get createFreelancerRatingLoading => _createFreelancerRatingLoading;

  setCreateFreelancerRatingLoading(bool value) {
    _createFreelancerRatingLoading = value;
    notifyListeners();
  }

  Future<void> FreelancerRatingPatchApi(BuildContext context, String freelancerID, dynamic fields,) async {
    setCreateFreelancerRatingLoading(true);
    try {
      dynamic value = await _myRepo.freelancerRatingPatchApi(freelancerID,fields);
      setCreateFreelancerRatingLoading(false);
      Utils.flushBarSuccessMessage('Send Rating Successfully', context);
      await Future.delayed(Duration(milliseconds: 1000));
      // Navigator.pushNamed(context, RoutesName.navigationBar);
      if (kDebugMode) print(value.toString());
    } catch (error) {
      setCreateFreelancerRatingLoading(false);
      _handleError(error, context);
      if (kDebugMode) print('Error: $error');
    }
  }




  void _handleError(dynamic error, BuildContext context) {
    String errorMessage = '$error';
    try {
      String errorBody = error.toString();
      int jsonStartIndex = errorBody.indexOf('{');
      if (jsonStartIndex != -1) {
        final decoded = jsonDecode(errorBody.substring(jsonStartIndex));
        errorMessage = decoded['message'] ??
            (decoded['errorMessages'] is List && decoded['errorMessages'].isNotEmpty
                ? decoded['errorMessages'][0]['message']
                : errorMessage);
      }
    } catch (_) {
      errorMessage = 'Unexpected error occurred';
    }
    Utils.flushBarErrorMessage(errorMessage, context);
  }
}