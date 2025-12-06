import 'dart:convert';
import 'package:dinmajur_customer/configs/utils/routes/routes_name.dart';
import 'package:dinmajur_customer/configs/utils/utils.dart';
import 'package:dinmajur_customer/respository/home_repositories/dropdown_categories_selection_repositories/premium_house_keeper_repository/book_premium_house_keeper_repository.dart';
import 'package:dinmajur_customer/respository/home_repositories/post_change_password/post_change_password_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PostBookPremiumHouseKeeperViewModel with ChangeNotifier {
  final _myRepo = BookPremiumHouseKeeperRepository();
  bool _createBookPremiumHouseKeeperLoading = false;
  bool get createBookPremiumHouseKeeperLoading => _createBookPremiumHouseKeeperLoading;

  setBookPremiumHouseKeeperLoading(bool value) {
    _createBookPremiumHouseKeeperLoading = value;
    notifyListeners();
  }

  Future<void> bookPremiumHouseKeeperLoadingPostApi(BuildContext context, dynamic fields,) async {
    setBookPremiumHouseKeeperLoading(true);
    try {
      dynamic value = await _myRepo.bookPremiumHouseKeeperPostApi(fields);
      setBookPremiumHouseKeeperLoading(false);
      Utils.flushBarSuccessMessage('Book Premium house keeper successfully changed', context);
      await Future.delayed(Duration(milliseconds: 1000));

      if (kDebugMode) print(value.toString());
    } catch (error) {
      setBookPremiumHouseKeeperLoading(false);
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