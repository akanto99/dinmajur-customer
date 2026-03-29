import 'dart:convert';
import 'package:dinmajur_customer/configs/utils/utils.dart';
import 'package:dinmajur_customer/respository/home_repositories/all_service_repositories/book_service_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

class BookServiceViewModel with ChangeNotifier {
  final _myRepo = BookServiceRepository();
  bool _createBookServiceLoading = false;
  bool get createBookServiceLoading => _createBookServiceLoading;

  setBookServiceLoading(bool value) {
    _createBookServiceLoading = value;
    notifyListeners();
  }

  Future<void> bookServicePostApi(
      BuildContext context,
      dynamic fields,
      Function(String? trackingId) onSuccess
      ) async {
    setBookServiceLoading(true);
    try {
      dynamic response = await _myRepo.bookServicePostApi(fields);
      setBookServiceLoading(false);

      if (kDebugMode) print('API Response: ${response.toString()}');

      String? trackingId;


      if (response != null && response['data'] != null) {
        trackingId = response['data']['trackingId']?.toString();

        if (kDebugMode) {
          print('Tracking ID: $trackingId');
        }

        onSuccess(trackingId);
      } else {
        if (kDebugMode) print('Warning: trackingId not found in response');
        onSuccess(null);
      }

    } catch (error) {
      setBookServiceLoading(false);
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