
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
  static bool _isProcessing = false;
  Future<SSLPaymentResult> initiatePayment({
    required String trackingId,
    required double totalAmount,
    String? productCategory,
    bool useTestMode = false,
    String? customerName,
    String? customerPhone,
    String? customerEmail,
    String? customerAddress,
  }) async {

    if (_isProcessing) {
      return SSLPaymentResult(
        success: false,
        status: 'CANCELLED',
        errorMessage: 'Payment already in progress',
      );
    }
    _isProcessing = true;

    try {
      // Validate
      if (trackingId.isEmpty) {
        return SSLPaymentResult(success: false, status: 'ERROR', errorMessage: 'Tracking ID cannot be empty');
      }

      if (totalAmount <= 0) {
        return SSLPaymentResult(success: false, status: 'ERROR', errorMessage: 'Total amount must be greater than 0');
      }

      final storeId = dotenv.env['SSL_STORE_ID'];
      final storePassword = dotenv.env['SSL_STORE_PASSWORD'];
      final storeIpnUrl = dotenv.env['SSL_STORE_IPN_URL'];

      if (storeId == null || storePassword == null) {
        return SSLPaymentResult(success: false, status: 'ERROR', errorMessage: 'SSL Commerz credentials not configured');
      }

      // Use provided customer info or defaults
      final name = customerName?.isNotEmpty == true ? customerName! : "";
      final phone = customerPhone?.isNotEmpty == true ? customerPhone! : "";
      final email = customerEmail?.isNotEmpty == true ? customerEmail! : "";
      final address = customerAddress?.isNotEmpty == true ? customerAddress! : "";

      Sslcommerz sslcommerz =
          Sslcommerz(
                initializer: SSLCommerzInitialization(
                  ipn_url: storeIpnUrl,
                  store_id: storeId,
                  store_passwd: storePassword,
                  total_amount: totalAmount,
                  tran_id: trackingId,
                  currency: SSLCurrencyType.BDT,
                  product_category: productCategory ?? "",
                  sdkType: SSLCSdkType.LIVE,
                  // sdkType:SSLCSdkType.TESTBOX,
                ),
              )
              .addCustomerInfoInitializer(
                customerInfoInitializer: SSLCCustomerInfoInitializer(
                  customerName: name,
                  customerEmail: email,
                  customerAddress1: address,
                  customerCountry: "Bangladesh",
                  customerPhone: phone,
                  customerState: 'BD',
                  customerCity: '',
                  customerPostCode: '',
                ),
              )
              .addProductInitializer(
                sslcProductInitializer: SSLCProductInitializer(
                  productName: productCategory ?? "",
                  productCategory: productCategory ?? "",
                  general: General(general: productCategory ?? "", productProfile: "general"),
                ),
              );


      var result = await sslcommerz.payNow();

      if (result is PlatformException) {
        return SSLPaymentResult(success: false, status: 'FAILED', errorMessage: result.toString());
      }

      String? status = result.status?.toString().toUpperCase();
      String? amount = result.amount?.toString();
      String? cardType = result.cardType?.toString();
      String? tranId = result.tranId?.toString();
      String? valId = result.valId?.toString();
      String? riskTitle = result.riskTitle?.toString();

      // User cancelled
      if (status == 'CANCELLED' || status == 'CANCELED') {
        return SSLPaymentResult(success: false, status: 'CANCELLED', errorMessage: 'Payment was cancelled by user');
      }

      // SDK failed to initialize (no transaction data)
      if (status == 'FAILED' && tranId == null && valId == null && amount == null) {
        return SSLPaymentResult(success: false, status: 'FAILED', errorMessage: 'Payment gateway failed to open. Please check your internet connection and credentials.');
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

      return SSLPaymentResult(success: isSuccess, status: status ?? 'UNKNOWN', amount: amount, cardType: cardType, transactionId: tranId, validationId: valId);
    } catch (e, stackTrace) {
      return SSLPaymentResult(success: false, status: 'ERROR', errorMessage: 'Payment failed: ${e.toString()}');
    }finally {
      _isProcessing = false; // ← ALWAYS unlocks after SSL returns (success/cancel/fail/error)
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

  SSLPaymentResult({required this.success, required this.status, this.amount, this.cardType, this.transactionId, this.validationId, this.errorMessage});

  @override
  String toString() {
    return 'SSLPaymentResult(success: $success, status: $status, amount: $amount, '
        'cardType: $cardType, transactionId: $transactionId, validationId: $validationId, '
        'errorMessage: $errorMessage)';
  }
}
