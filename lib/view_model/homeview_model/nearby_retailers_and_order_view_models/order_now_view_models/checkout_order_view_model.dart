import 'dart:convert';
import 'package:dinmajur_customer/configs/utils/routes/routes_name.dart';
import 'package:dinmajur_customer/configs/utils/utils.dart';
import 'package:dinmajur_customer/respository/home_repositories/nearby_retailers_and_order_repository/order_now_repository/checkout_order_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PostCheckOutOrderViewModel with ChangeNotifier {
  final _myRepo = PostCheckOutOrderRepository();
  bool _checkoutOrderLoading = false;
  bool get checkoutOrderLoading => _checkoutOrderLoading;

  setCheckoutOrderLoading(bool value) {
    _checkoutOrderLoading = value;
    notifyListeners();
  }

  Future<void> checkoutOrderPostApi(BuildContext context, dynamic fields) async {
    setCheckoutOrderLoading(true);
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? AToken = prefs.getString('accessToken');

      if (AToken == null || AToken.isEmpty) {
        Utils.flushBarErrorMessage('Invalid token', context);
        setCheckoutOrderLoading(false);
        return;
      }

      // Make API call
      dynamic value = await _myRepo.checkoutOrderPostApi(fields);

      setCheckoutOrderLoading(false);

      // Print the response

      // Extract orderId from response: data.order._id
      String? orderId;

      if (value is Map<String, dynamic>) {

        final data = value['data'];
        if (data != null && data is Map<String, dynamic>) {

          final order = data['order'];
          if (order != null && order is Map<String, dynamic>) {
            orderId = order['_id']?.toString();
          }
        }
      }


      if (orderId == null || orderId.isEmpty) {
        Utils.flushBarErrorMessage('Order created but ID not found', context);
        return;
      }

      Navigator.pushNamed(
        context,
        RoutesName.trackOrderViewdetailsSocketScreen,
        arguments: {
          'orderId': orderId,
          'fromCheckout': true,
        },
      );

    } catch (error) {
      setCheckoutOrderLoading(false);
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