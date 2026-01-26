/// For Web View SSl Implementation using payment url
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

  /// Updated to return both paymentUrl and trackingId
  Future<void> bookPremiumHouseKeeperPostApi(
      BuildContext context,
      dynamic fields,
      Function(String? paymentUrl, String? trackingId) onSuccess
      ) async {
    setBookPremiumHouseKeeperLoading(true);
    try {
      dynamic response = await _myRepo.bookPremiumHouseKeeperPostApi(fields);
      setBookPremiumHouseKeeperLoading(false);

      Utils.flushBarSuccessMessage('Book Premium house keeper successfully', context);
      await Future.delayed(Duration(milliseconds: 1000));

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


///For Ssl Integration using store id and Password
// import 'dart:convert';
// import 'package:dinmajur_customer/configs/utils/utils.dart';
// import 'package:dinmajur_customer/respository/home_repositories/dropdown_categories_selection_repositories/premium_house_keeper_repository/book_premium_house_keeper_repository.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/foundation.dart';
//
// class PostBookPremiumHouseKeeperViewModel with ChangeNotifier {
//   final _myRepo = BookPremiumHouseKeeperRepository();
//   bool _createBookPremiumHouseKeeperLoading = false;
//   bool get createBookPremiumHouseKeeperLoading => _createBookPremiumHouseKeeperLoading;
//
//   setBookPremiumHouseKeeperLoading(bool value) {
//     _createBookPremiumHouseKeeperLoading = value;
//     notifyListeners();
//   }
//
//   // ✅ UPDATED: Only returns trackingId
//   Future<void> bookPremiumHouseKeeperPostApi(
//       BuildContext context,
//       dynamic fields,
//       Function(String? trackingId) onSuccess // ✅ Simplified callback
//       ) async {
//     setBookPremiumHouseKeeperLoading(true);
//     try {
//       // Get the API response
//       dynamic response = await _myRepo.bookPremiumHouseKeeperPostApi(fields);
//       setBookPremiumHouseKeeperLoading(false);
//
//       Utils.flushBarSuccessMessage('Booking created successfully', context);
//       await Future.delayed(Duration(milliseconds: 1000));
//
//       if (kDebugMode) print('API Response: ${response.toString()}');
//
//       // Extract tracking ID from response
//       String? trackingId;
//
//       if (response != null && response['data'] != null) {
//         if (response['data']['trackingId'] != null) {
//           trackingId = response['data']['trackingId'].toString();
//           if (kDebugMode) print('Tracking ID: $trackingId');
//         }
//
//         // Call the success callback with trackingId only
//         onSuccess(trackingId);
//       } else {
//         if (kDebugMode) print('Warning: No data found in response');
//         onSuccess(null);
//       }
//
//     } catch (error) {
//       setBookPremiumHouseKeeperLoading(false);
//       _handleError(error, context);
//       if (kDebugMode) print('Error: $error');
//       // Don't call onSuccess on error
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