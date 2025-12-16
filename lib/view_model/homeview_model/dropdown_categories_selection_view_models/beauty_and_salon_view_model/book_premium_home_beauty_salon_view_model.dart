import 'dart:convert';
import 'package:dinmajur_customer/configs/utils/routes/routes_name.dart';
import 'package:dinmajur_customer/configs/utils/utils.dart';
import 'package:dinmajur_customer/respository/home_repositories/dropdown_categories_selection_repositories/beauty_and_salon_repository/book_premium_home_beauty_salon_repository.dart';
import 'package:dinmajur_customer/respository/home_repositories/dropdown_categories_selection_repositories/premium_house_keeper_repository/book_premium_house_keeper_repository.dart';
import 'package:dinmajur_customer/respository/home_repositories/post_change_password/post_change_password_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PostBookPremiumHomeBeautySalonViewModel with ChangeNotifier {
  final _myRepo = BookPremiumHomeBeautySalonRepository();
  bool _createBookPremiumHomeBeautySalonLoading = false;
  bool get createBookPremiumHomeBeautySalonLoading => _createBookPremiumHomeBeautySalonLoading;

  setBookPremiumHomeBeautySalonLoading(bool value) {
    _createBookPremiumHomeBeautySalonLoading = value;
    notifyListeners();
  }

  Future<void> bookPremiumHomeBeautySalonPostApi(
      BuildContext context,
      dynamic fields,
      Function(String trackingId) onSuccess // CHANGED: Now receives trackingId
      ) async {
    setBookPremiumHomeBeautySalonLoading(true);
    try {
      // CHANGED: Store the response
      dynamic response = await _myRepo.bookPremiumHomeBeautySalonPostApi(fields);
      setBookPremiumHomeBeautySalonLoading(false);

      Utils.flushBarSuccessMessage('Book Premium Home Beauty and Salon successfully', context);
      await Future.delayed(Duration(milliseconds: 1000));

      if (kDebugMode) print('API Response: ${response.toString()}');

      // CHANGED: Extract trackingId from response and pass it to callback
      String trackingId = '';
      if (response != null && response['data'] != null && response['data']['trackingId'] != null) {
        trackingId = response['data']['trackingId'].toString();
        if (kDebugMode) print('Tracking ID: $trackingId');

        // Call the success callback with trackingId
        onSuccess(trackingId);
      } else {
        if (kDebugMode) print('Warning: trackingId not found in response');
        // Still call success but with empty trackingId
        onSuccess('');
      }

    } catch (error) {
      setBookPremiumHomeBeautySalonLoading(false);
      _handleError(error, context);
      if (kDebugMode) print('Error: $error');
      // Don't call onSuccess on error - dialog will stay open
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