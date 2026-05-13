
import 'dart:convert';
import 'package:dinmajur_customer/configs/utils/utils.dart';
import 'package:dinmajur_customer/respository/home_repositories/dropdown_categories_selection_repositories/beauty_and_salon_repository/book_premium_home_beauty_salon_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

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
      Function(String? trackingId) onSuccess,
      ) async {
    setBookPremiumHomeBeautySalonLoading(true);   // loading শুরু

    try {
      dynamic response = await _myRepo.bookPremiumHomeBeautySalonPostApi(fields);

      String? trackingId;
      if (response != null && response['data'] != null) {
        trackingId = response['data']['trackingId']?.toString();

        if (kDebugMode) print('Tracking ID: $trackingId');

        // ✅ এখানে loading false করবো না
        onSuccess(trackingId);
      } else {
        setBookPremiumHomeBeautySalonLoading(false);
        onSuccess(null);
      }
    } catch (error) {
      setBookPremiumHomeBeautySalonLoading(false);
      _handleError(error, context);
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