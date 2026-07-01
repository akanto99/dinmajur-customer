import 'package:flutter/foundation.dart';
import 'dart:async';

class RunningOrderCountViewModel extends ChangeNotifier {
  int _runningOrderCount = 0;
  StreamSubscription<int>? _countSubscription;
  bool _isInitialized = false;

  // Getters
  int get runningOrderCount => _runningOrderCount;
  bool get hasRunningOrders => _runningOrderCount > 0;
  bool get isInitialized => _isInitialized;

  // Initialize listener for runningOrderCount event
  void initializeCountListener(Stream<int> countStream) {
    if (_isInitialized) {
      return;
    }

    _countSubscription?.cancel();

    // debugPrint('🎯 RunningOrderCountViewModel: Initializing count listener...');

    _countSubscription = countStream.listen(
          (count) {
        // debugPrint('═══════════════════════════════════════════');
        // debugPrint('📦 RUNNING ORDER COUNT RECEIVED: $count');
        // debugPrint('📦 Previous count: $_runningOrderCount');
        // debugPrint('═══════════════════════════════════════════');

        _runningOrderCount = count;
        notifyListeners();
        //
        // debugPrint('✅ Running order badge count updated to: $count');
        // debugPrint('✅ Listeners notified');
      },
      onError: (error) {
      },
      onDone: () {
        _isInitialized = false;
      },
      cancelOnError: false,
    );

    _isInitialized = true;
    // debugPrint('✅ runningOrderCount listener initialized');
  }

  // Set initial count from stream controller's last value
  void setInitialCount(int count) {
    _runningOrderCount = count;
    notifyListeners();
    // debugPrint('🎯 Initial running order count set to: $count');
  }

  @override
  void dispose() {
    _countSubscription?.cancel();
    super.dispose();
  }
}