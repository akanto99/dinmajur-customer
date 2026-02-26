// import 'package:flutter/services.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:flutter_sslcommerz/model/SSLCSdkType.dart';
// import 'package:flutter_sslcommerz/model/SSLCommerzInitialization.dart';
// import 'package:flutter_sslcommerz/model/SSLCurrencyType.dart';
// import 'package:flutter_sslcommerz/sslcommerz.dart';
//
// /// Centralized SSL Commerz Payment Service
// /// Handles all SSL Commerz payment operations across the app
// class SSLCommerzPaymentService {
//   // Singleton pattern to ensure single instance
//   static final SSLCommerzPaymentService _instance = SSLCommerzPaymentService._internal();
//
//   factory SSLCommerzPaymentService() {
//     return _instance;
//   }
//
//   SSLCommerzPaymentService._internal();
//
//   /// Initiates SSL Commerz payment
//   ///
//   /// [trackingId] - Unique transaction ID from your booking
//   /// [totalAmount] - Total amount to be paid
//   /// [productCategory] - Category of product/service (default: "Service")
//   /// [useTestMode] - Whether to use test environment (default: true)
//   Future<SSLPaymentResult> initiatePayment({
//     required String trackingId,
//     required double totalAmount,
//     String productCategory = "Service",
//     bool useTestMode = true,
//   }) async {
//     try {
//       // Validate inputs
//       if (trackingId.isEmpty) {
//         return SSLPaymentResult(
//           success: false,
//           status: 'ERROR',
//           errorMessage: 'Tracking ID cannot be empty',
//         );
//       }
//
//       if (totalAmount <= 0) {
//         return SSLPaymentResult(
//           success: false,
//           status: 'ERROR',
//           errorMessage: 'Total amount must be greater than 0',
//         );
//       }
//
//       // Get SSL Commerz credentials from environment
//       final storeId = dotenv.env['SSL_STORE_ID'];
//       final storePassword = dotenv.env['SSL_STORE_PASSWORD'];
//
//       if (storeId == null || storePassword == null) {
//         return SSLPaymentResult(
//           success: false,
//           status: 'ERROR',
//           errorMessage: 'SSL Commerz credentials not configured',
//         );
//       }
//
//       // Initialize SSL Commerz
//       Sslcommerz sslcommerz = Sslcommerz(
//         initializer: SSLCommerzInitialization(
//           multi_card_name: "visa,master,amex,bkash,nagad,rocket,upay,tap,okwallet,"
//               "dbbl_visa,dbbl_master,city_visa,city_master,city_amex,"
//               "ebl_visa,ebl_master,sbl_visa,sbl_master,brac_visa,brac_master,"
//               "ibbl,mtbl,city,ebl,sbl,brac,dbbl,dutchbangla,ab,scb,ucb,"
//               "premier,nrb,trust,bankasia,midland,union,pubali,sibl,exim,"
//               "southeast,islamibank,al_arafah,social,ific,shahjalal,"
//               "firstsecurity,onebank,qcash,fastcash",
//           currency: SSLCurrencyType.BDT,
//           product_category: productCategory,
//           sdkType: useTestMode ? SSLCSdkType.TESTBOX : SSLCSdkType.LIVE,
//           store_id: storeId,
//           store_passwd: storePassword,
//           total_amount: totalAmount,
//           tran_id: trackingId,
//         ),
//       );
//
//       print("🔄 Initiating SSL Commerz Payment...");
//       print("Tracking ID: $trackingId");
//       print("Amount: $totalAmount BDT");
//
//       // Execute payment
//       var result = await sslcommerz.payNow();
//
//       // Handle platform exception
//       if (result is PlatformException) {
//         print("❌ Payment Failed - Platform Exception");
//         return SSLPaymentResult(
//           success: false,
//           status: 'FAILED',
//           errorMessage: result.toString(),
//         );
//       }
//
//       // Extract payment details
//       String? status = result.status;
//       String? amount = result.amount;
//       String? cardType = result.cardType;
//       String? tranId = result.tranId;
//       String? valId = result.valId;
//
//       print("✅ Payment Response Received!");
//       print("Status: $status");
//       print("Amount: $amount");
//       print("Card Type: $cardType");
//       print("Transaction ID: $tranId");
//       print("Validation ID: $valId");
//
//       // Determine success based on status
//       bool isSuccess = status == 'VALID' || status == 'VALIDATED';
//
//       return SSLPaymentResult(
//         success: isSuccess,
//         status: status ?? 'UNKNOWN',
//         amount: amount,
//         cardType: cardType,
//         transactionId: tranId,
//         validationId: valId,
//       );
//     } catch (e) {
//       print("💥 SSL Commerz Error: $e");
//       return SSLPaymentResult(
//         success: false,
//         status: 'ERROR',
//         errorMessage: e.toString(),
//       );
//     }
//   }
//
//   /// Validates payment result
//   bool isPaymentSuccessful(SSLPaymentResult result) {
//     return result.success &&
//         (result.status == 'VALID' || result.status == 'VALIDATED');
//   }
//
//   /// Checks if payment was cancelled by user
//   bool isPaymentCancelled(SSLPaymentResult result) {
//     return result.status == 'CANCELLED' || result.status == 'CANCELED';
//   }
//
//   /// Checks if payment failed
//   bool isPaymentFailed(SSLPaymentResult result) {
//     return result.status == 'FAILED' || result.status == 'ERROR';
//   }
// }
//
// /// Payment result model
// class SSLPaymentResult {
//   final bool success;
//   final String status;
//   final String? amount;
//   final String? cardType;
//   final String? transactionId;
//   final String? validationId;
//   final String? errorMessage;
//
//   SSLPaymentResult({
//     required this.success,
//     required this.status,
//     this.amount,
//     this.cardType,
//     this.transactionId,
//     this.validationId,
//     this.errorMessage,
//   });
//
//   @override
//   String toString() {
//     return 'SSLPaymentResult(success: $success, status: $status, amount: $amount, '
//         'cardType: $cardType, transactionId: $transactionId, validationId: $validationId, '
//         'errorMessage: $errorMessage)';
//   }
// }

import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_sslcommerz/model/SSLCSdkType.dart';
import 'package:flutter_sslcommerz/model/SSLCommerzInitialization.dart';
import 'package:flutter_sslcommerz/model/SSLCurrencyType.dart';
import 'package:flutter_sslcommerz/model/SSLCCustomerInfoInitializer.dart';
import 'package:flutter_sslcommerz/model/sslproductinitilizer/General.dart';
import 'package:flutter_sslcommerz/model/sslproductinitilizer/SSLCProductInitializer.dart';
import 'package:flutter_sslcommerz/sslcommerz.dart';

class SSLCommerzPaymentService {
  static final SSLCommerzPaymentService _instance = SSLCommerzPaymentService._internal();
  factory SSLCommerzPaymentService() => _instance;
  SSLCommerzPaymentService._internal();

  Future<SSLPaymentResult> initiatePayment({
    required String trackingId,
    required double totalAmount,
    String ? productCategory,
    bool useTestMode = false,
    String? customerName,
    String? customerPhone,
    String? customerEmail,
    String? customerAddress,
  }) async {
    try {
      // Validate
      if (trackingId.isEmpty) {
        return SSLPaymentResult(
          success: false,
          status: 'ERROR',
          errorMessage: 'Tracking ID cannot be empty',
        );
      }

      if (totalAmount <= 0) {
        return SSLPaymentResult(
          success: false,
          status: 'ERROR',
          errorMessage: 'Total amount must be greater than 0',
        );
      }

      final storeId = dotenv.env['SSL_STORE_ID'];
      final storePassword = dotenv.env['SSL_STORE_PASSWORD'];
      final storeIpnUrl = dotenv.env['SSL_STORE_IPN_URL'];

      if (storeId == null || storePassword == null) {
        return SSLPaymentResult(
          success: false,
          status: 'ERROR',
          errorMessage: 'SSL Commerz credentials not configured',
        );
      }

      // Use provided customer info or defaults
      final name = customerName?.isNotEmpty == true ? customerName! : "";
      final phone = customerPhone?.isNotEmpty == true ? customerPhone! : "";
      final email = customerEmail?.isNotEmpty == true ? customerEmail! : "";
      final address = customerAddress?.isNotEmpty == true ? customerAddress! : "";

      print("═══════════════════════════════════════════");
      print("🔄 Initiating SSL Commerz Payment");
      print("Store ID: $storeId");
      print("Tracking ID: $trackingId");
      print("Amount: $totalAmount BDT");
      print("Customer: $name");
      print("Phone: $phone");
      print("Mode: ${useTestMode ? 'TESTBOX' : 'LIVE'}");
      print("═══════════════════════════════════════════");

      // Initialize SSL Commerz with ALL required fields
      Sslcommerz sslcommerz = Sslcommerz(
        initializer: SSLCommerzInitialization(
          ipn_url: storeIpnUrl,
          store_id: storeId,
          store_passwd: storePassword,
          total_amount: totalAmount,
          tran_id: trackingId,
          currency: SSLCurrencyType.BDT,
          product_category: productCategory ?? "",
          // sdkType:SSLCSdkType.TESTBOX,
          sdkType:SSLCSdkType.LIVE,
          // sdkType:useTestMode ?SSLCSdkType.TESTBOX: SSLCSdkType.LIVE,
          //   multi_card_name: "visa,master,amex,bkash,nagad,rocket,upay,tap,okwallet,"
          //     "dbbl_visa,dbbl_master,city_visa,city_master,city_amex,"
          //     "ebl_visa,ebl_master,sbl_visa,sbl_master,brac_visa,brac_master,"
          //     "ibbl,mtbl,city,ebl,sbl,brac,dbbl,dutchbangla,ab,scb,ucb,"
          //     "premier,nrb,trust,bankasia,midland,union,pubali,sibl,exim,"
          //     "southeast,islamibank,al_arafah,social,ific,shahjalal,"
          //     "firstsecurity,onebank,qcash,fastcash",
        )
      )
          .addCustomerInfoInitializer(customerInfoInitializer: SSLCCustomerInfoInitializer(
        customerName: name,
        customerEmail: email,
        customerAddress1: address,
        customerCountry: "Bangladesh",
        customerPhone: phone, customerState: 'BD',
        customerCity: '',
        customerPostCode: '',
      )
      ).addProductInitializer( sslcProductInitializer: SSLCProductInitializer(
        productName: productCategory?? "",
        productCategory: productCategory?? "",  general: General(
        general: productCategory??"",
        productProfile: "general",
      ),

      )
      );

      print("✅ SSL Commerz configured - launching payment...");

      var result = await sslcommerz.payNow();

      print("═══════════════════════════════════════════");
      print("📦 Payment Result Received");
      print("Type: ${result.runtimeType}");
      print("═══════════════════════════════════════════");

      if (result is PlatformException) {
        print("❌ Platform Exception: ${result}");
        return SSLPaymentResult(
          success: false,
          status: 'FAILED',
          errorMessage: result.toString(),
        );
      }

      String? status = result.status?.toString().toUpperCase();
      String? amount = result.amount?.toString();
      String? cardType = result.cardType?.toString();
      String? tranId = result.tranId?.toString();
      String? valId = result.valId?.toString();
      String? riskTitle = result.riskTitle?.toString();

      print("═══════════════════════════════════════════");
      print("✅ Payment Response:");
      print("Status: $status");
      print("Amount: $amount");
      print("Card Type: $cardType");
      print("Transaction ID: $tranId");
      print("Validation ID: $valId");
      print("Risk Title: $riskTitle");
      print("═══════════════════════════════════════════");

      // User cancelled
      if (status == 'CANCELLED' || status == 'CANCELED') {
        return SSLPaymentResult(
          success: false,
          status: 'CANCELLED',
          errorMessage: 'Payment was cancelled by user',
        );
      }

      // SDK failed to initialize (no transaction data)
      if (status == 'FAILED' && tranId == null && valId == null && amount == null) {
        print("❌ CRITICAL: Payment gateway failed to initialize");
        return SSLPaymentResult(
          success: false,
          status: 'FAILED',
          errorMessage: 'Payment gateway failed to open. Please check your internet connection and SSL Commerz credentials.',
        );
      }

      bool isSuccess = status == 'VALID' || status == 'VALIDATED' || status == 'SUCCESS';

      if (!isSuccess && status == 'FAILED') {
        return SSLPaymentResult(
          success: false,
          status: 'FAILED',
          errorMessage: riskTitle ?? 'Payment transaction failed',
          amount: amount,
          cardType: cardType,
          transactionId: tranId,
          validationId: valId,
        );
      }

      return SSLPaymentResult(
        success: isSuccess,
        status: status ?? 'UNKNOWN',
        amount: amount,
        cardType: cardType,
        transactionId: tranId,
        validationId: valId,
      );

    } catch (e, stackTrace) {
      print("💥 SSL Commerz Error: $e");
      print("Stack: $stackTrace");
      return SSLPaymentResult(
        success: false,
        status: 'ERROR',
        errorMessage: 'Payment failed: ${e.toString()}',
      );
    }
  }
}

class SSLPaymentResult {
  final bool success;
  final String status;
  final String? amount;
  final String? cardType;
  final String? transactionId;
  final String? validationId;
  final String? errorMessage;

  SSLPaymentResult({
    required this.success,
    required this.status,
    this.amount,
    this.cardType,
    this.transactionId,
    this.validationId,
    this.errorMessage,
  });

  @override
  String toString() {
    return 'SSLPaymentResult(success: $success, status: $status, amount: $amount, '
        'cardType: $cardType, transactionId: $transactionId, validationId: $validationId, '
        'errorMessage: $errorMessage)';
  }
}