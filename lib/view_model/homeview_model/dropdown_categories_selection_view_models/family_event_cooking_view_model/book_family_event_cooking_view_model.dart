
import 'dart:convert';
import 'package:dinmajur_customer/configs/utils/utils.dart';
import 'package:dinmajur_customer/respository/home_repositories/dropdown_categories_selection_repositories/family_event_cooking_repository/bookfamily_event_cooking_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

class PostBookFamilyEventCookingViewModel with ChangeNotifier {
  final _myRepo = BookFamilyEventCookingRepository();
  bool _createBookFamilyEventCookingLoading = false;
  bool get createBookFamilyEventCookingLoading => _createBookFamilyEventCookingLoading;

  setBookFamilyEventCookingLoading(bool value) {
    _createBookFamilyEventCookingLoading = value;
    notifyListeners();
  }

  Future<void> bookFamilyEventCookingPostApi(
      BuildContext context,
      dynamic fields,
      Function(String? trackingId) onSuccess) async {

    setBookFamilyEventCookingLoading(true);

    try {
      dynamic response = await _myRepo.bookFamilyEventCookingPostApi(fields);

      String? trackingId;

      if (response != null && response['data'] != null) {
        trackingId = response['data']['trackingId']?.toString();

        onSuccess(trackingId);
      } else {
        setBookFamilyEventCookingLoading(false);
        onSuccess(null);
      }
    } catch (error) {
      setBookFamilyEventCookingLoading(false);
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