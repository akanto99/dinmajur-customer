
import 'dart:convert';
import 'package:dinmajur_customer/configs/utils/utils.dart';
import 'package:dinmajur_customer/respository/home_repositories/dropdown_categories_selection_repositories/premium_house_keeper_repository/book_premium_house_keeper_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

class PostBookPremiumHouseKeeperViewModel with ChangeNotifier {
  final _myRepo = BookPremiumHouseKeeperRepository();
  bool _createBookPremiumHouseKeeperLoading = false;
  bool get createBookPremiumHouseKeeperLoading => _createBookPremiumHouseKeeperLoading;

  setBookPremiumHouseKeeperLoading(bool value) {
    _createBookPremiumHouseKeeperLoading = value;
    notifyListeners();
  }

  Future<void> bookPremiumHouseKeeperPostApi(
      BuildContext context,
      dynamic fields,
      Function(String? trackingId) onSuccess) async {

    setBookPremiumHouseKeeperLoading(true);

    try {
      dynamic response = await _myRepo.bookPremiumHouseKeeperPostApi(fields);

      String? trackingId;

      if (response != null && response['data'] != null) {
        trackingId = response['data']['trackingId']?.toString();

        onSuccess(trackingId);
      } else {
        setBookPremiumHouseKeeperLoading(false);
        onSuccess(null);
      }
    } catch (error) {
      setBookPremiumHouseKeeperLoading(false);
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