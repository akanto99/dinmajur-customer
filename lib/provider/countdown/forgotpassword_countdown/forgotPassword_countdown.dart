
import 'dart:async';
import 'package:flutter/material.dart';


class ForgotPasswordCountdown extends ChangeNotifier {
  Timer? _timer;
  int _start = 0;
  bool _canResend = false;

  int get start => _start;
  bool get canResend => _canResend;

  void startTimer({int seconds = 120}) {
    _start = seconds;
    _canResend = false;
    _timer?.cancel();

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_start <= 0) {
        timer.cancel();
        _canResend = true;
        notifyListeners(); // ✅ notify after setting canResend = true
      } else {
        _start--;
        notifyListeners(); // ✅ keep this here for regular countdown updates
      }
    });
  }



  void stopTimer() {
    _timer?.cancel();
    _canResend = false;
    notifyListeners();
  }

  String convertToBengaliDigits(String input) {
    const Map<String, String> enToBnDigits = {
      '0': '0', '1': '1', '2': '2', '3': '3', '4': '4',
      '5': '5', '6': '6', '7': '7', '8': '8', '9': '9',
    };
    return input.split('').map((e) => enToBnDigits[e] ?? e).join();
  }

  String get formattedTime {
    int minutes = _start ~/ 60;
    int seconds = _start % 60;
    String time = "${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
    return "${convertToBengaliDigits(time)} second";
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
