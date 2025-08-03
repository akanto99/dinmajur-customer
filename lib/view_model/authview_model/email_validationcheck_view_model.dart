import 'dart:convert';
import 'package:dinmajur_customer/configs/utils/utils.dart';
import 'package:dinmajur_customer/respository/auth_repository/email_validationcheck_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';


class EmailValidationCheckViewModel with ChangeNotifier {
  final _myRepo = EmailValidationCheckRepository();

  ///Email Validation
  bool _emailCheckLoading = false;
  bool get emailCheckLoading => _emailCheckLoading;
  setEmailCheckLoading(bool value) {
    _emailCheckLoading = value;
    notifyListeners();
  }

  Future<bool> emailValidationCheck(dynamic data, BuildContext context) async {
    setEmailCheckLoading(true);
    try {
      dynamic value = await _myRepo.emailValidationCheck(data);
      setEmailCheckLoading(false);
      if (value['success'] == true) {
        // Utils.flushBarSuccessMessage('ইমেইল আইডি ব্যবহারযোগ্য।', context);
        print(value['message']);
        if (kDebugMode) print(value.toString());
        return true;
      } else {
        Utils.flushBarErrorMessage(value['message'] ?? 'ইমেইল ইতোমধ্যে ব্যবহৃত হয়েছে', context);
        return false;
      }
    } catch (error) {
      setEmailCheckLoading(false);
      // Utils.flushBarErrorMessage('$error', context);
      _handleError(error, context);
      if (kDebugMode) print('Error: $error');
      return false;
    }
  }


  ///Handle Errors
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
