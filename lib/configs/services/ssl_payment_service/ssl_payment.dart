import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_sslcommerz/model/SSLCSdkType.dart';
import 'package:flutter_sslcommerz/model/SSLCommerzInitialization.dart';
import 'package:flutter_sslcommerz/model/SSLCurrencyType.dart';
import 'package:flutter_sslcommerz/sslcommerz.dart';

/// Centralized SSL Commerz Payment Service
/// Handles all SSL Commerz payment operations across the app
class SSLCommerzPaymentService {
  // Singleton pattern to ensure single instance
  static final SSLCommerzPaymentService _instance = SSLCommerzPaymentService._internal();

  factory SSLCommerzPaymentService() {
    return _instance;
  }

  SSLCommerzPaymentService._internal();

  /// Initiates SSL Commerz payment
  ///
  /// [trackingId] - Unique transaction ID from your booking
  /// [totalAmount] - Total amount to be paid
  /// [productCategory] - Category of product/service (default: "Service")
  /// [useTestMode] - Whether to use test environment (default: true)
  Future<SSLPaymentResult> initiatePayment({
    required String trackingId,
    required double totalAmount,
    String productCategory = "Service",
    bool useTestMode = true,
  }) async {
    try {
      // Validate inputs
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

      // Get SSL Commerz credentials from environment
      final storeId = dotenv.env['SSL_STORE_ID'];
      final storePassword = dotenv.env['SSL_STORE_PASSWORD'];

      if (storeId == null || storePassword == null) {
        return SSLPaymentResult(
          success: false,
          status: 'ERROR',
          errorMessage: 'SSL Commerz credentials not configured',
        );
      }

      // Initialize SSL Commerz
      Sslcommerz sslcommerz = Sslcommerz(
        initializer: SSLCommerzInitialization(
          multi_card_name: "visa,master,amex,bkash,nagad,rocket,upay",
          currency: SSLCurrencyType.BDT,
          product_category: productCategory,
          sdkType: useTestMode ? SSLCSdkType.TESTBOX : SSLCSdkType.LIVE,
          store_id: storeId,
          store_passwd: storePassword,
          total_amount: totalAmount,
          tran_id: trackingId,
        ),
      );

      print("🔄 Initiating SSL Commerz Payment...");
      print("Tracking ID: $trackingId");
      print("Amount: $totalAmount BDT");

      // Execute payment
      var result = await sslcommerz.payNow();

      // Handle platform exception
      if (result is PlatformException) {
        print("❌ Payment Failed - Platform Exception");
        return SSLPaymentResult(
          success: false,
          status: 'FAILED',
          errorMessage: result.toString(),
        );
      }

      // Extract payment details
      String? status = result.status;
      String? amount = result.amount;
      String? cardType = result.cardType;
      String? tranId = result.tranId;
      String? valId = result.valId;

      print("✅ Payment Response Received!");
      print("Status: $status");
      print("Amount: $amount");
      print("Card Type: $cardType");
      print("Transaction ID: $tranId");
      print("Validation ID: $valId");

      // Determine success based on status
      bool isSuccess = status == 'VALID' || status == 'VALIDATED';

      return SSLPaymentResult(
        success: isSuccess,
        status: status ?? 'UNKNOWN',
        amount: amount,
        cardType: cardType,
        transactionId: tranId,
        validationId: valId,
      );
    } catch (e) {
      print("💥 SSL Commerz Error: $e");
      return SSLPaymentResult(
        success: false,
        status: 'ERROR',
        errorMessage: e.toString(),
      );
    }
  }

  /// Validates payment result
  bool isPaymentSuccessful(SSLPaymentResult result) {
    return result.success &&
        (result.status == 'VALID' || result.status == 'VALIDATED');
  }

  /// Checks if payment was cancelled by user
  bool isPaymentCancelled(SSLPaymentResult result) {
    return result.status == 'CANCELLED' || result.status == 'CANCELED';
  }

  /// Checks if payment failed
  bool isPaymentFailed(SSLPaymentResult result) {
    return result.status == 'FAILED' || result.status == 'ERROR';
  }
}

/// Payment result model
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