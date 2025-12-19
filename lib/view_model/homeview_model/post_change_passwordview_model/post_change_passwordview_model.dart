import 'dart:convert';
import 'package:dinmajur_customer/configs/utils/routes/routes_name.dart';
import 'package:dinmajur_customer/configs/utils/utils.dart';
import 'package:dinmajur_customer/respository/home_repositories/post_change_password/post_change_password_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PostChangePasswordViewModel with ChangeNotifier {
  final _myRepo = PostChangePasswordRepository();
  bool _createPostChangePasswordLoading = false;
  bool get createPostChangePasswordLoading => _createPostChangePasswordLoading;

  setCreatePostChangePasswordLoading(bool value) {
    _createPostChangePasswordLoading = value;
    notifyListeners();
  }

  Future<void> changePasswordPostApi(BuildContext context, dynamic fields,) async {
    setCreatePostChangePasswordLoading(true);
    try {
      // SharedPreferences prefs = await SharedPreferences.getInstance();
      // String? AToken = prefs.getString('accessToken');
      // if (AToken == null || AToken.isEmpty) {
      //   Utils.flushBarErrorMessage('Invalid token', context);
      //   setCreatePostChangePasswordLoading(false);
      //   return;
      // }
      dynamic value = await _myRepo.changePasswordPostApi(fields);
      setCreatePostChangePasswordLoading(false);
      Utils.flushBarSuccessMessage('Password has been successfully changed', context);
      await Future.delayed(Duration(milliseconds: 1000));
      Navigator.pushNamed(context, RoutesName.navigationBar);
      if (kDebugMode) print(value.toString());
    } catch (error) {
      setCreatePostChangePasswordLoading(false);
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