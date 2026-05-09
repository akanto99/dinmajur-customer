import 'dart:convert';
import 'package:dinmajur_customer/configs/utils/utils.dart';
import 'package:dinmajur_customer/respository/home_repositories/drawer_repository/support_repository/support_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

class PostSupportViewModel with ChangeNotifier {
  final _myRepo = SupportRepository();
  bool _createSupportLoading = false;
  bool get createSupportLoading => _createSupportLoading;

  setCreateSupportLoading(bool value) {
    _createSupportLoading = value;
    notifyListeners();
  }

  Future<void> supportPostAPI(BuildContext context, dynamic fields,) async {
    setCreateSupportLoading(true);
    try {
      dynamic value = await _myRepo.supportPostApi(fields);
      setCreateSupportLoading(false);
      Utils.flushBarSuccessMessage('Support message sent successfully!', context);
    } catch (error) {
      setCreateSupportLoading(false);
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