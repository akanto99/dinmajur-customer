/// For Web View SSL Implementation using payment url
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

  /// Updated to return both paymentUrl and trackingId
  Future<void> bookFamilyEventCookingPostApi(
      BuildContext context,
      dynamic fields,
      Function(String? paymentUrl, String? trackingId) onSuccess
      ) async {
    setBookFamilyEventCookingLoading(true);
    try {
      dynamic response = await _myRepo.bookFamilyEventCookingPostApi(fields);
      setBookFamilyEventCookingLoading(false);

      Utils.flushBarSuccessMessage('Book Family Event Cooking successfully', context);
      // await Future.delayed(Duration(milliseconds: 1000));

      if (kDebugMode) print('API Response: ${response.toString()}');

      // Extract trackingId and paymentUrl from response
      String? trackingId;
      String? paymentUrl;

      if (response != null && response['data'] != null) {
        trackingId = response['data']['trackingId']?.toString();
        paymentUrl = response['data']['GatewayPageURL']?.toString();

        if (kDebugMode) {
          print('Tracking ID: $trackingId');
          print('Payment URL: $paymentUrl');
        }

        // Call the success callback with both values
        onSuccess(paymentUrl, trackingId);
      } else {
        if (kDebugMode) print('Warning: Response data not found');
        onSuccess(null, null);
      }

    } catch (error) {
      setBookFamilyEventCookingLoading(false);
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

///For Ssl Integration using store id and Password
// import 'dart:convert';
// import 'package:dinmajur_customer/configs/utils/utils.dart';
// import 'package:dinmajur_customer/respository/home_repositories/dropdown_categories_selection_repositories/family_event_cooking_repository/bookfamily_event_cooking_repository.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/foundation.dart';
//
// class PostBookFamilyEventCookingViewModel with ChangeNotifier {
//   final _myRepo = BookFamilyEventCookingRepository();
//   bool _createBookFamilyEventCookingLoading = false;
//   bool get createBookFamilyEventCookingLoading => _createBookFamilyEventCookingLoading;
//
//   setBookFamilyEventCookingLoading(bool value) {
//     _createBookFamilyEventCookingLoading = value;
//     notifyListeners();
//   }
//
//   Future<void> bookFamilyEventCookingPostApi(
//       BuildContext context,
//       dynamic fields,
//       Function(String? trackingId) onSuccess // CHANGED: Now receives both paymentUrl and trackingId
//       ) async {
//     setBookFamilyEventCookingLoading(true);
//     try {
//       // Store the response
//       dynamic response = await _myRepo.bookFamilyEventCookingPostApi(fields);
//       setBookFamilyEventCookingLoading(false);
//       if (kDebugMode) print('API Response: ${response.toString()}');
//       String? trackingId;
//
//
//       if (response != null && response['data'] != null) {
//         trackingId = response['data']['trackingId']?.toString();
//
//         if (kDebugMode) {
//           print('Tracking ID: $trackingId');
//         }
//
//         // Call the success callback with both paymentUrl and trackingId
//         onSuccess(trackingId);
//       } else {
//         if (kDebugMode) print('Warning: trackingId not found in response');
//         // Still call success but with null values
//         onSuccess(null);
//       }
//
//     } catch (error) {
//       setBookFamilyEventCookingLoading(false);
//       _handleError(error, context);
//       if (kDebugMode) print('Error: $error');
//       // Don't call onSuccess on error - dialog will stay open
//     }
//   }
//
//   void _handleError(dynamic error, BuildContext context) {
//     String errorMessage = '$error';
//     try {
//       String errorBody = error.toString();
//       int jsonStartIndex = errorBody.indexOf('{');
//       if (jsonStartIndex != -1) {
//         final decoded = jsonDecode(errorBody.substring(jsonStartIndex));
//         errorMessage = decoded['message'] ??
//             (decoded['errorMessages'] is List && decoded['errorMessages'].isNotEmpty
//                 ? decoded['errorMessages'][0]['message']
//                 : errorMessage);
//       }
//     } catch (_) {
//       errorMessage = 'Unexpected error occurred';
//     }
//     Utils.flushBarErrorMessage(errorMessage, context);
//   }
// }