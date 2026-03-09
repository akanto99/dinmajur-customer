/// For Web View SSL Implementation using payment url
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
//
// class CheckoutBeautySalonViewModel extends ChangeNotifier {
//   String? _selectedServiceTime;
//   String? _selectedPaymentMethod;
//   DateTime? _selectedDate;
//   bool _isProcessing = false;
//
//   String? get selectedServiceTime => _selectedServiceTime;
//   String? get selectedPaymentMethod => _selectedPaymentMethod;
//   DateTime? get selectedDate => _selectedDate;
//   bool get isProcessing => _isProcessing;
//
//   // Payment methods data
//   final List<Map<String, dynamic>> paymentMethods = [
//     {
//       'method': 'online',
//       'title': 'Online Payment',
//       'icon': 'wallet',
//       'color': 0xFFEE4237
//     },
//     {
//       'method': 'cash',
//       'title': 'Hand Cash',
//       'icon': 'sackDollar',
//       'color': 0xFF45A986
//     },
//   ];
//
//   void setServiceTime(String time) {
//     _selectedServiceTime = time;
//     notifyListeners();
//   }
//
//   void setPaymentMethod(String method) {
//     _selectedPaymentMethod = method;
//     notifyListeners();
//   }
//
//   void setSelectedDate(DateTime date) {
//     _selectedDate = date;
//     notifyListeners();
//   }
//
//   void setProcessing(bool value) {
//     _isProcessing = value;
//     notifyListeners();
//   }
//
//   // Calculate total price
//   double calculateTotal({
//     required Map<String, int> serviceQuantities,
//     required List<dynamic> categories,
//   }) {
//     double total = 0;
//
//     for (var category in categories) {
//       if (category.items != null) {
//         for (var service in category.items!) {
//           int qty = serviceQuantities[service.id ?? ''] ?? 0;
//           if (qty > 0) {
//             double price = service.salePrice?.toDouble() ??
//                 service.originalPrice?.toDouble() ?? 0;
//             total += price * qty;
//           }
//         }
//       }
//     }
//     return total;
//   }
//
//   // Calculate saved amount
//   double calculateSaved({
//     required Map<String, int> serviceQuantities,
//     required List<dynamic> categories,
//   }) {
//     double saved = 0;
//
//     for (var category in categories) {
//       if (category.items != null) {
//         for (var service in category.items!) {
//           int qty = serviceQuantities[service.id ?? ''] ?? 0;
//           if (qty > 0 && service.discountValue != null) {
//             double originalPrice = service.originalPrice?.toDouble() ?? 0;
//             double salePrice = service.salePrice?.toDouble() ?? originalPrice;
//             double discount = originalPrice - salePrice;
//             saved += discount * qty;
//           }
//         }
//       }
//     }
//     return saved;
//   }
//
//   // Get total items count
//   int getTotalItems(Map<String, int> serviceQuantities) {
//     return serviceQuantities.entries.where((entry) => entry.value > 0).length;
//   }
//
//   // Validation for cart dialog (date & time only)
//   String? validateCartForm({
//     required DateTime? selectedDate,
//     required String? serviceTime,
//   }) {
//     if (selectedDate == null) {
//       return "Please select a date";
//     }
//     if (serviceTime == null || serviceTime.isEmpty) {
//       return "Please select a service time";
//     }
//     return null;
//   }
//
//   // Validation for checkout screen (name, phone, address, payment)
//   String? validateCheckoutDetails({
//     required String fullName,
//     required String phone,
//     required String address,
//     required String? paymentMethod,
//   }) {
//     if (fullName.trim().isEmpty) {
//       return "Please enter your full name";
//     }
//     if (phone.trim().isEmpty) {
//       return "Please enter your phone number";
//     }
//     if (address.trim().isEmpty) {
//       return "Please enter your address";
//     }
//     if (paymentMethod == null || paymentMethod.isEmpty) {
//       return "Please select a payment method";
//     }
//     return null;
//   }
//
//   // Get payment method data for API
//   String getPaymentMethodData(String? method) {
//     switch (method) {
//       case 'online':
//         return "ONLINE";
//       case 'cash':
//         return "CASH_ON_DELIVERY";
//       default:
//         return "OTHERS";
//     }
//   }
//
//   // Prepare tasks data for booking
//   List<Map<String, dynamic>> prepareTasksData({
//     required Map<String, int> serviceQuantities,
//     required List<dynamic> categories,
//   }) {
//     List<Map<String, dynamic>> tasks = [];
//
//     for (var category in categories) {
//       if (category.items != null) {
//         for (var service in category.items!) {
//           int qty = serviceQuantities[service.id ?? ''] ?? 0;
//           if (qty > 0) {
//             tasks.add({
//               'beautySalonTaskId': category.id,
//               'quantity': qty,
//               'subTasks': [
//                 {
//                   'beautySalonTaskItemId': service.id,
//                 },
//               ],
//             });
//           }
//         }
//       }
//     }
//
//     return tasks;
//   }
//
//   // Prepare complete booking data
//   Map<String, dynamic> prepareBookingData({
//     required String userId,
//     required String fullName,
//     required String phone,
//     required String address,
//     required String? specialRequest,
//     required DateTime selectedDate,
//     required String serviceTime,
//     required List<Map<String, dynamic>> tasks,
//     required String? paymentMethod,
//     required String source,
//   }) {
//     String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);
//     String paymentData = getPaymentMethodData(paymentMethod);
//
//     return {
//       'userId': userId,
//       'fullName': fullName.trim(),
//       'time': serviceTime,
//       'phone': phone.trim(),
//       'fullAddress': address.trim(),
//       'notes': specialRequest?.trim().isEmpty == true
//           ? null
//           : specialRequest?.trim(),
//       'date': formattedDate,
//       'tasks': tasks,
//       "paymentType": paymentData,
//       "source": source,
//     };
//   }
//
//   void reset() {
//     _selectedServiceTime = null;
//     _selectedPaymentMethod = null;
//     _selectedDate = null;
//     _isProcessing = false;
//     notifyListeners();
//   }
// }


///For Ssl Integration using store id and Password
import 'package:dinmajur_customer/configs/services/ssl_payment_service/ssl_payment.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_sslcommerz/model/SSLCSdkType.dart';
import 'package:flutter_sslcommerz/model/SSLCommerzInitialization.dart';
import 'package:flutter_sslcommerz/model/SSLCurrencyType.dart';
import 'package:flutter_sslcommerz/sslcommerz.dart';
import 'package:intl/intl.dart';

class CheckoutBeautySalonViewModel extends ChangeNotifier {
  String? _selectedServiceTime;
  String? _selectedPaymentMethod;
  DateTime? _selectedDate;
  bool _isProcessing = false;

  String? get selectedServiceTime => _selectedServiceTime;
  String? get selectedPaymentMethod => _selectedPaymentMethod;
  DateTime? get selectedDate => _selectedDate;
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

  void setServiceTime(String time) {
    _selectedServiceTime = time;
    notifyListeners();
  }

  void setPaymentMethod(String method) {
    _selectedPaymentMethod = method;
    notifyListeners();
  }

  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  void setProcessing(bool value) {
    _isProcessing = value;
    notifyListeners();
  }

  // Calculate total price
  double calculateTotal({
    required Map<String, int> serviceQuantities,
    required List<dynamic> categories,
  }) {
    double total = 0;

    for (var category in categories) {
      if (category.items != null) {
        for (var service in category.items!) {
          int qty = serviceQuantities[service.id ?? ''] ?? 0;
          if (qty > 0) {
            double price = service.salePrice?.toDouble() ??
                service.originalPrice?.toDouble() ?? 0;
            total += price * qty;
          }
        }
      }
    }
    return total;
  }

  // Calculate saved amount
  double calculateSaved({
    required Map<String, int> serviceQuantities,
    required List<dynamic> categories,
  }) {
    double saved = 0;

    for (var category in categories) {
      if (category.items != null) {
        for (var service in category.items!) {
          int qty = serviceQuantities[service.id ?? ''] ?? 0;
          if (qty > 0 && service.discountValue != null) {
            double originalPrice = service.originalPrice?.toDouble() ?? 0;
            double salePrice = service.salePrice?.toDouble() ?? originalPrice;
            double discount = originalPrice - salePrice;
            saved += discount * qty;
          }
        }
      }
    }
    return saved;
  }

  // Get total items count
  int getTotalItems(Map<String, int> serviceQuantities) {
    return serviceQuantities.entries.where((entry) => entry.value > 0).length;
  }

  // In checkout_notifier.dart

// Validation for cart dialog (date & time only)
  String? validateCartForm({
    required DateTime? selectedDate,
    required String? serviceTime,
  }) {
    if (selectedDate == null) {
      return "Please select a date";
    }
    if (serviceTime == null || serviceTime.isEmpty) {
      return "Please select a service time";
    }
    return null;
  }

// Validation for checkout screen (name, phone, address, payment)
  String? validateCheckoutDetails({
    required String fullName,
    required String phone,
    required String address,
    required String? paymentMethod,
  }) {
    if (fullName.trim().isEmpty) {
      return "Please enter your full name";
    }
    if (phone.trim().isEmpty) {
      return "Please enter your phone number";
    }
    if (address.trim().isEmpty) {
      return "Please enter your address";
    }
    if (paymentMethod == null || paymentMethod.isEmpty) {
      return "Please select a payment method";
    }
    return null;
  }
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

  // Prepare tasks data for booking
  List<Map<String, dynamic>> prepareTasksData({
    required Map<String, int> serviceQuantities,
    required List<dynamic> categories,
  }) {
    List<Map<String, dynamic>> tasks = [];

    for (var category in categories) {
      if (category.items != null) {
        for (var service in category.items!) {
          int qty = serviceQuantities[service.id ?? ''] ?? 0;
          if (qty > 0) {
            tasks.add({
              'beautySalonTaskId': category.id,
              'quantity': qty,
              'subTasks': [
                {
                  'beautySalonTaskItemId': service.id,
                },
              ],
            });
          }
        }
      }
    }

    return tasks;
  }

  // Prepare complete booking data
  Map<String, dynamic> prepareBookingData({
    required String userId,
    required String fullName,
    required String phone,
    required String address,
    required String? specialRequest,
    required DateTime selectedDate,
    required String serviceTime,
    required String timeSlot,
    required List<Map<String, dynamic>> tasks,
    required String? paymentMethod,
    Map<String, dynamic>? customerLocation,
  }) {
    String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);
    // Map<String, dynamic> paymentData = getPaymentMethodData(paymentMethod);
     String paymentData = getPaymentMethodData(paymentMethod);

    return {
      'userId': userId,
      'fullName': fullName.trim(),
      'time': serviceTime,
      'timeSlot':timeSlot,
      'phone': phone.trim(),
      if (customerLocation != null) 'location': customerLocation,
      'fullAddress': address.trim(),
      'notes': specialRequest?.trim().isEmpty == true
          ? null
          : specialRequest?.trim(),
      'date': formattedDate,
      'tasks': tasks,
         "paymentType": paymentData,
    };
  }
  Future<SSLPaymentResult> initiatePayment({
    required String trackingId,
    required double totalAmount,
    String? customerName,
    String? customerPhone,
    String? customerEmail,
    String? customerAddress,
  }) async {
    print("═══════════════════════════════════════════");
    print("🚀 CheckoutViewModel: Initiating Payment");
    print("Tracking ID: $trackingId");
    print("Total Amount: $totalAmount");
    print("Customer: $customerName");
    print("Phone: $customerPhone");
    print("═══════════════════════════════════════════");

    try {
      final result = await _paymentService.initiatePayment(
        trackingId: trackingId,
        totalAmount: totalAmount,
        productCategory: "Beauty & Salon Service",
        customerName: customerName,
        customerPhone: customerPhone,
        customerEmail: customerEmail,
        customerAddress: customerAddress,
      );

      print("═══════════════════════════════════════════");
      print("📥 Payment Service Result:");
      print(result.toString());
      print("═══════════════════════════════════════════");

      return result;
    } catch (e, stackTrace) {
      print("💥 Payment Initiation Error in ViewModel: $e");
      print("Stack Trace: $stackTrace");

      return SSLPaymentResult(
        success: false,
        status: 'ERROR',
        errorMessage: 'Failed to initiate payment: ${e.toString()}',
      );
    }
  }

void reset() {
    _selectedServiceTime = null;
    _selectedPaymentMethod = null;
    _selectedDate = null;
    _isProcessing = false;
    notifyListeners();
  }
}
