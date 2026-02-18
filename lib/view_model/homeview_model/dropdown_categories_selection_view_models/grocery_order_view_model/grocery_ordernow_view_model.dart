import 'dart:convert';
import 'package:dinmajur_customer/configs/utils/utils.dart';
import 'package:dinmajur_customer/respository/home_repositories/dropdown_categories_selection_repositories/grocery_ordernow_repository/grocery_payment_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

class GroceryOrdernowViewModel with ChangeNotifier {
  final _myRepo = GroceryPaymentRepository();
  bool _createGroceryPaymentLoading = false;
  bool get createGroceryPaymentLoading => _createGroceryPaymentLoading;

  setGroceryPaymentLoading(bool value) {
    _createGroceryPaymentLoading = value;
    notifyListeners();
  }

  Future<void> groceryPaymentPatchApi(
      BuildContext context,
      dynamic fields,
      Function() onSuccess
      ) async {
    setGroceryPaymentLoading(true);
    try {
      await _myRepo.groceryPaymentPatchApi(fields);
      setGroceryPaymentLoading(false);

      Utils.flushBarSuccessMessage('Payment type updated successfully', context);

      onSuccess();
    } catch (error) {
      setGroceryPaymentLoading(false);
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