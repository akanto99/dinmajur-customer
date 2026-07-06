import 'package:flutter/foundation.dart';
import 'dart:async';

class NotificationCountViewModel extends ChangeNotifier {
  int _notificationCount = 0;
  StreamSubscription<int>? _countSubscription;
  StreamSubscription<int>? _incrementSubscription; // ✅ NEW
  bool _isInitialized = false;

  // Getters
  int get notificationCount => _notificationCount;
  bool get hasNotifications => _notificationCount > 0;
  bool get isInitialized => _isInitialized;

  // ✅ Initialize listener for both notificationCount and notificationIncrement
  void initializeCountListener(
      Stream<int> countStream,
      Stream<int> incrementStream, // ✅ NEW parameter
      ) {
    // Prevent multiple initializations
    if (_isInitialized) {
      return;
    }

    _countSubscription?.cancel();
    _incrementSubscription?.cancel();

    // debugPrint('🎯 NotificationCountViewModel: Initializing listeners...');

    // Listen to full count updates (from init and notificationCount events)
    _countSubscription = countStream.listen(
          (count) {
        // debugPrint('═══════════════════════════════════════════');
        // debugPrint('📊 FULL COUNT RECEIVED: $count');
        // debugPrint('📊 Previous count: $_notificationCount');
        // debugPrint('═══════════════════════════════════════════');

        _notificationCount = count;
        notifyListeners();

        // debugPrint('✅ Badge count updated to: $count');
        // debugPrint('✅ Listeners notified');
      },
      onError: (error) {
      },
      onDone: () {
      },
      cancelOnError: false,
    );

    // ✅ NEW: Listen to increment updates
    _incrementSubscription = incrementStream.listen(
          (increment) {

        _notificationCount += increment;
        notifyListeners();

      },
      onError: (error) {
      },
      onDone: () {
      },
      cancelOnError: false,
    );

    _isInitialized = true;
  }

  // Set initial count from stream controller's last value
  void setInitialCount(int count) {
    _notificationCount = count;
    notifyListeners();
    // debugPrint('🎯 Initial count set to: $count');
  }



  @override
  void dispose() {
    _countSubscription?.cancel();
    _incrementSubscription?.cancel();
    super.dispose();
  }
}