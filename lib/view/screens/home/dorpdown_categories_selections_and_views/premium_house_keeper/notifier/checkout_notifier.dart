
///For Ssl Integration using store id and Password
import 'dart:io';

import 'package:dinmajur_customer/configs/services/ssl_payment_service/ssl_payment.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CheckoutViewModel extends ChangeNotifier {
  String? _selectedHouseSize;
  String? _selectedPaymentMethod;
  bool _isProcessing = false;

  String? get selectedHouseSize => _selectedHouseSize;
  String? get selectedPaymentMethod => _selectedPaymentMethod;
  bool get isProcessing => _isProcessing;
  final SSLCommerzPaymentService _paymentService = SSLCommerzPaymentService();

  // Payment methods data
  final List<Map<String, dynamic>> paymentMethods = [
    {
      'method': 'online',
      'title': 'Online Payment',
      'icon': 'wallet',
      'color': 0xFFEE4237
    },
    {
      'method': 'cash',
      'title': 'Hand Cash',
      'icon': 'sackDollar',
      'color': 0xFF45A986
    },
  ];

  void setHouseSize(String size) {
    _selectedHouseSize = size;
    notifyListeners();
  }

  void setPaymentMethod(String method) {
    _selectedPaymentMethod = method;
    notifyListeners();
  }

  void setProcessing(bool value) {
    _isProcessing = value;
    notifyListeners();
  }

  // Calculate total price - FIXED: Added explicit type casting
  double calculateTotal({
    required Map<String, int> serviceQuantities,
    required Map<String, Set<String>> selectedTaskItems,
    required List<dynamic> services,
  }) {
    double total = 0;

    for (var service in services) {
      int qty = serviceQuantities[service.id ?? ''] ?? 0;
      if (qty > 0 && service.houseKeeperTaskItems?.isNotEmpty == true) {
        // FIX: Properly handle dynamic list casting
        Set<String> selectedItems = selectedTaskItems[service.id ?? '']?.cast<String>() ??
            (service.houseKeeperTaskItems as List<dynamic>)
                .map((item) => (item.id ?? '') as String)
                .toSet();

        double price = 0;
        for (var item in service.houseKeeperTaskItems!) {
          if (selectedItems.contains(item.id ?? '')) {
            price += item.price?.toDouble() ?? 0;
          }
        }

        if (service.discountType != null &&
            service.discountValue != null &&
            price > 0) {
          if (service.discountType == 'PERCENTAGE') {
            price = price - (price * service.discountValue! / 100);
          } else if (service.discountType == 'FLAT') {
            price = price - service.discountValue!.toDouble();
          }
        }

        total += price * qty;
      }
    }
    return total;
  }

  // Calculate saved amount - FIXED: Added explicit type casting
  double calculateSaved({
    required Map<String, int> serviceQuantities,
    required Map<String, Set<String>> selectedTaskItems,
    required List<dynamic> services,
  }) {
    double saved = 0;

    for (var service in services) {
      int qty = serviceQuantities[service.id ?? ''] ?? 0;
      if (qty > 0 &&
          service.houseKeeperTaskItems?.isNotEmpty == true &&
          service.discountValue != null) {
        // FIX: Properly handle dynamic list casting
        Set<String> selectedItems = selectedTaskItems[service.id ?? '']?.cast<String>() ??
            (service.houseKeeperTaskItems as List<dynamic>)
                .map((item) => (item.id ?? '') as String)
                .toSet();

        double originalPrice = 0;
        for (var item in service.houseKeeperTaskItems!) {
          if (selectedItems.contains(item.id ?? '')) {
            originalPrice += item.price?.toDouble() ?? 0;
          }
        }

        double discount = 0;
        if (service.discountType == 'PERCENTAGE') {
          discount = originalPrice * service.discountValue! / 100;
        } else if (service.discountType == 'FLAT') {
          discount = service.discountValue!.toDouble();
        }

        saved += discount * qty;
      }
    }
    return saved;
  }

  // Get total items count
  int getTotalItems(Map<String, int> serviceQuantities) {
    return serviceQuantities.entries.where((entry) => entry.value > 0).length;
  }

  // Validate form fields
  String? validateCheckoutForm({
    required String phone,
    required String address,
    // required String? houseSize,
    required String? paymentMethod,
  }) {
    if (phone.isEmpty) {
      return "Phone number is required";
    }
    if (address.isEmpty) {
      return "Service address is required";
    }
    // if (houseSize == null) {
    //   return "Please select house size";
    // }
    if (paymentMethod == null) {
      return "Please select a payment method";
    }
    return null;
  }

  // Get payment method data for API
  // Map<String, dynamic> getPaymentMethodData(String? method) {
  //   switch (method) {
  //     case 'online':
  //       return {"type": "WALLET", "provider": "online"};
  //     case 'cash':
  //       return {"type": "OTHER", "provider": "cash_on_delivery"};
  //     default:
  //       return {"type": "OTHER", "provider": "cash_on_delivery"};
  //   }
  // }
  // Get payment method data for API
  String getPaymentMethodData(String? method) {
    switch (method) {
      case 'online':
        return "ONLINE";
      case 'cash':
        return "CASH_ON_DELIVERY";
      default:
        return "OTHERS";
    }
  }

  // Prepare tasks data for booking - FIXED: Added explicit type casting
  List<Map<String, dynamic>> prepareTasksData({
    required Map<String, int> serviceQuantities,
    required Map<String, Set<String>> selectedTaskItems,
    required List<dynamic> services,
  }) {
    List<Map<String, dynamic>> tasks = [];

    for (var service in services) {
      int qty = serviceQuantities[service.id ?? ''] ?? 0;
      if (qty > 0) {
        // FIX: Properly handle dynamic list casting
        Set<String> selectedItems = selectedTaskItems[service.id ?? '']?.cast<String>() ??
            (service.houseKeeperTaskItems != null
                ? (service.houseKeeperTaskItems as List<dynamic>)
                .map((item) => (item.id ?? '') as String)
                .toSet()
                : <String>{});

        if (selectedItems.isNotEmpty) {
          tasks.add({
            "houseKeeperTaskId": service.id,
            "totalRooms": qty,
            "houseKeeperTaskItemIds": selectedItems.toList()
          });
        }
      }
    }

    return tasks;
  }

  // Get shift ID from selected time
  String? getShiftId({
    required String selectedTime,
    required List<dynamic> shiftTimes,
  }) {
    for (var shift in shiftTimes) {
      String displayText =
          '${shift.type ?? ''} (${shift.startTime ?? ''}-${shift.endTime ?? ''})';
      if (displayText == selectedTime) {
        return shift.shiftId;
      }
    }
    return null;
  }

  // Prepare complete booking data
  Future<Map<String, dynamic>> prepareBookingData({
    required String fullName,
    required String phone,
    required String address,
    Map<String, dynamic>? customerLocation,
    required String? houseSize,
    required String? specialRequest,
    required String selectedFrequency,
    required String selectedDate,
    required String? shiftId,
    required List<Map<String, dynamic>> tasks,
    required String? paymentMethod,
  }) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');

    // Map<String, dynamic> paymentData = getPaymentMethodData(paymentMethod);
    String paymentData = getPaymentMethodData(paymentMethod);

    return {
      "userId": userId.toString(),
      "district": "Chittagong",
      "date": selectedDate,
      "area": "N/A",
      "planType": selectedFrequency.toUpperCase(),
      "fullName": fullName.trim(),
      "phone": phone.trim(),
      "fullAddress": address.trim(),
      if (customerLocation != null) 'location': customerLocation,
      "houseSize": houseSize,
      "notes": specialRequest?.trim().isEmpty == true ? null : specialRequest?.trim(),
      "tasks": tasks,
      "couponCode": null,
      "shiftId": shiftId,

      "paymentType": paymentData,
      "source": Platform.isAndroid ? "android" : "ios",
    };
  }

  // // Initiate SSL Commerz payment
  // Future<SSLPaymentResult> initiateSSLCommerzPayment({
  //   required String trackingId,
  //   required double totalAmount,
  // }) async {
  //   try {
  //     Sslcommerz sslcommerz = Sslcommerz(
  //       initializer: SSLCommerzInitialization(
  //         multi_card_name: "visa,master,amex,bkash,nagad,rocket,upay",
  //         currency: SSLCurrencyType.BDT,
  //         product_category: "Service",
  //         sdkType: SSLCSdkType.TESTBOX,
  //         store_id: dotenv.env['SSL_STORE_ID']!,
  //         store_passwd: dotenv.env['SSL_STORE_PASSWORD']!,
  //         total_amount: totalAmount,
  //         tran_id: trackingId,
  //       ),
  //     );
  //
  //     var result = await sslcommerz.payNow();
  //
  //     if (result is PlatformException) {
  //       return SSLPaymentResult(
  //         success: false,
  //         status: 'FAILED',
  //         errorMessage: result.toString(),
  //       );
  //     } else {
  //       // Extract payment details
  //       String? status = result.status;
  //       String? amount = result.amount;
  //       String? cardType = result.cardType;
  //
  //       print("✅ Payment Response Received!");
  //       print("Status: $status");
  //       print("Amount: $amount");
  //       print("Card Type: $cardType");
  //
  //       return SSLPaymentResult(
  //         success: status == 'VALID' || status == 'VALIDATED',
  //         status: status ?? 'UNKNOWN',
  //         amount: amount,
  //         cardType: cardType,
  //         transactionId: result.tranId,
  //         validationId: result.valId,
  //       );
  //     }
  //   } catch (e) {
  //     print("💥 SSL Commerz Error: $e");
  //     return SSLPaymentResult(
  //       success: false,
  //       status: 'ERROR',
  //       errorMessage: e.toString(),
  //     );
  //   }
  // }
  /// Initiate payment using centralized service
  // Future<SSLPaymentResult> initiatePayment({
  //   required String trackingId,
  //   required double totalAmount,
  // }) async {
  //   return await _paymentService.initiatePayment(
  //     trackingId: trackingId,
  //     totalAmount: totalAmount,
  //     productCategory: "House Keeping Service",
  //   );
  // }
  /// Initiate payment using centralized service
  Future<SSLPaymentResult> initiatePayment({
    required String trackingId,
    required double totalAmount,
    String? customerName,
    String? customerPhone,
    String? customerEmail,
    String? customerAddress,
  }) async {
    // print("Tracking ID: $trackingId");
    // print("Total Amount: $totalAmount");
    // print("Customer: $customerName");
    // print("Phone: $customerPhone");

    try {
      final result = await _paymentService.initiatePayment(
        trackingId: trackingId,
        totalAmount: totalAmount,
        productCategory: "House Keeping Service",
        customerName: customerName,
        customerPhone: customerPhone,
        customerEmail: customerEmail,
        customerAddress: customerAddress,
      );

      // print(result.toString());

      return result;
    } catch (e, stackTrace) {

      return SSLPaymentResult(
        success: false,
        status: 'ERROR',
        errorMessage: 'Failed to initiate payment: ${e.toString()}',
      );
    }
  }
  void reset() {
    _selectedHouseSize = null;
    _selectedPaymentMethod = null;
    _isProcessing = false;
    notifyListeners();
  }
}
