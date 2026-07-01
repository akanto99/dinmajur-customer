import 'package:flutter/cupertino.dart';
import 'package:pinput/pinput.dart';
import 'package:smart_auth/smart_auth.dart';

class SmsRetrieverImpl implements SmsRetriever {
  SmsRetrieverImpl(this.smartAuth, {this.onSmsReceived}) {
    _startListening();
  }

  final SmartAuth smartAuth;
  final Function(String?)? onSmsReceived;

  // ✅ Start listening immediately when initialized
  void _startListening() {
    getSmsCode();
  }

  @override
  Future<void> dispose() {
    return smartAuth.removeUserConsentApiListener();
  }

  @override
  Future<String?> getSmsCode() async {
    try {
      final res = await smartAuth.getSmsWithUserConsentApi();
      if (res.hasData) {
        final code = res.data?.code;
        if (code != null) {

          // ✅ Trigger callback to update UI
          onSmsReceived?.call(code);

          return code;
        }
      }
    } catch (e) {
    }
    return null;
  }

  @override
  bool get listenForMultipleSms => false;
}