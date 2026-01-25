

import 'dart:convert';
import 'package:dinmajur_customer/configs/services/ssl_payment_service/ssl_failed_mvvm/ssl_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class PostSslPaymentFailedViewModel with ChangeNotifier {
  final _myRepo = SslPaymentFailedRepository();
  bool _sslPaymentFailedLoading = false;
  bool get sslPaymentFailedLoading => _sslPaymentFailedLoading;

  setSslPaymentFailedLoading(bool value) {
    _sslPaymentFailedLoading = value;
    notifyListeners();
  }

  Future<void> sslPaymentFailedPostApi(
      BuildContext context,
      dynamic fields,
      Function() onSuccess,
      ) async {
    setSslPaymentFailedLoading(true);
    try {
      if (kDebugMode) {
        print("📤 Posting SSL Failed Payment Data:");
        print(jsonEncode(fields));
      }

      dynamic response = await _myRepo.sslPaymentFailedAPI(fields);

      setSslPaymentFailedLoading(false);

      if (kDebugMode) {
        print("✅ SSL Failed API Response:");
        print(response);
      }

      // ✅ Call onSuccess callback after successful API call
      onSuccess();

    } catch (error) {
      setSslPaymentFailedLoading(false);
      if (kDebugMode) print('❌ SSL Failed API Error: $error');

      // ✅ Still call onSuccess to navigate to failed screen even if API fails
      onSuccess();
    }
  }
}