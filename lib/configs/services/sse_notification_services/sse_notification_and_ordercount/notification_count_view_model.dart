// // notification_count_view_model.dart
// import 'package:flutter/foundation.dart';
// import 'dart:async';
//
// class NotificationCountViewModel extends ChangeNotifier {
//   int _notificationCount = 0;
//   StreamSubscription<int>? _countSubscription;
//
//   // Getters
//   int get notificationCount => _notificationCount;
//   bool get hasNotifications => _notificationCount > 0;
//
//   // Initialize listener for notificationCount event only
//   void initializeCountListener(Stream<int> countStream) {
//     _countSubscription?.cancel();
//
//     debugPrint('🎯 NotificationCountViewModel: Initializing count listener...');
//
//     _countSubscription = countStream.listen(
//           (count) {
//         debugPrint('═══════════════════════════════════════════');
//         debugPrint('📊 COUNT RECEIVED: $count');
//         debugPrint('📊 Previous count: $_notificationCount');
//         debugPrint('═══════════════════════════════════════════');
//
//         _notificationCount = count;
//         notifyListeners();
//
//         debugPrint('✅ Badge count updated to: $count');
//         debugPrint('✅ Listeners notified');
//       },
//       onError: (error) {
//         debugPrint('❌ Error in count stream: $error');
//       },
//       onDone: () {
//         debugPrint('⚠️ Count stream closed');
//       },
//       cancelOnError: false,
//     );
//
//     debugPrint('✅ notificationCount listener initialized');
//   }
//
//   // Manually update count (if needed)
//   void updateCount(int count) {
//     _notificationCount = count;
//     notifyListeners();
//     debugPrint('📊 Count manually updated to: $count');
//   }
//
//   // Reset count
//   void resetCount() {
//     _notificationCount = 0;
//     notifyListeners();
//     debugPrint('🔄 Count reset to 0');
//   }
//
//   // Increment count (for local testing)
//   void incrementCount() {
//     _notificationCount++;
//     notifyListeners();
//     debugPrint('➕ Count incremented to: $_notificationCount');
//   }
//
//   // Decrement count (for local testing)
//   void decrementCount() {
//     if (_notificationCount > 0) {
//       _notificationCount--;
//       notifyListeners();
//       debugPrint('➖ Count decremented to: $_notificationCount');
//     }
//   }
//
//   @override
//   void dispose() {
//     _countSubscription?.cancel();
//     debugPrint('🔴 NotificationCountViewModel disposed');
//     super.dispose();
//   }
// }
// notification_count_view_model.dart
// import 'package:flutter/foundation.dart';
// import 'dart:async';
//
// class NotificationCountViewModel extends ChangeNotifier {
//   int _notificationCount = 0;
//   StreamSubscription<int>? _countSubscription;
//   bool _isInitialized = false;
//
//   // Getters
//   int get notificationCount => _notificationCount;
//   bool get hasNotifications => _notificationCount > 0;
//   bool get isInitialized => _isInitialized;
//
//   // ✅ Initialize listener for notificationCount event only
//   void initializeCountListener(Stream<int> countStream) {
//     // Prevent multiple initializations
//     if (_isInitialized) {
//       debugPrint('⚠️ NotificationCountViewModel: Already initialized, skipping...');
//       return;
//     }
//
//     _countSubscription?.cancel();
//
//     debugPrint('🎯 NotificationCountViewModel: Initializing count listener...');
//
//     _countSubscription = countStream.listen(
//       (count) {
//         debugPrint('═══════════════════════════════════════════');
//         debugPrint('📊 COUNT RECEIVED: $count');
//         debugPrint('📊 Previous count: $_notificationCount');
//         debugPrint('═══════════════════════════════════════════');
//
//         _notificationCount = count;
//         notifyListeners();
//
//         debugPrint('✅ Badge count updated to: $count');
//         debugPrint('✅ Listeners notified');
//       },
//       onError: (error) {
//         debugPrint('❌ Error in count stream: $error');
//       },
//       onDone: () {
//         debugPrint('⚠️ Count stream closed');
//         _isInitialized = false;
//       },
//       cancelOnError: false,
//     );
//
//     _isInitialized = true;
//     debugPrint('✅ notificationCount listener initialized');
//   }
//
//   // ✅ NEW: Get initial count from stream controller's last value
//   void setInitialCount(int count) {
//     _notificationCount = count;
//     notifyListeners();
//     debugPrint('🎯 Initial count set to: $count');
//   }
//
//   @override
//   void dispose() {
//     _countSubscription?.cancel();
//     debugPrint('🔴 NotificationCountViewModel disposed');
//     super.dispose();
//   }
// }
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
      debugPrint('⚠️ NotificationCountViewModel: Already initialized, skipping...');
      return;
    }

    _countSubscription?.cancel();
    _incrementSubscription?.cancel();

    debugPrint('🎯 NotificationCountViewModel: Initializing listeners...');

    // Listen to full count updates (from init and notificationCount events)
    _countSubscription = countStream.listen(
          (count) {
        debugPrint('═══════════════════════════════════════════');
        debugPrint('📊 FULL COUNT RECEIVED: $count');
        debugPrint('📊 Previous count: $_notificationCount');
        debugPrint('═══════════════════════════════════════════');

        _notificationCount = count;
        notifyListeners();

        debugPrint('✅ Badge count updated to: $count');
        debugPrint('✅ Listeners notified');
      },
      onError: (error) {
        debugPrint('❌ Error in count stream: $error');
      },
      onDone: () {
        debugPrint('⚠️ Count stream closed');
      },
      cancelOnError: false,
    );

    // ✅ NEW: Listen to increment updates
    _incrementSubscription = incrementStream.listen(
          (increment) {
        debugPrint('═══════════════════════════════════════════');
        debugPrint('➕ INCREMENT RECEIVED: $increment');
        debugPrint('📊 Current count before increment: $_notificationCount');
        debugPrint('═══════════════════════════════════════════');

        _notificationCount += increment;
        notifyListeners();

        debugPrint('✅ Badge count incremented to: $_notificationCount');
        debugPrint('✅ Listeners notified');
      },
      onError: (error) {
        debugPrint('❌ Error in increment stream: $error');
      },
      onDone: () {
        debugPrint('⚠️ Increment stream closed');
      },
      cancelOnError: false,
    );

    _isInitialized = true;
    debugPrint('✅ Both notificationCount and increment listeners initialized');
  }

  // Set initial count from stream controller's last value
  void setInitialCount(int count) {
    _notificationCount = count;
    notifyListeners();
    debugPrint('🎯 Initial count set to: $count');
  }



  @override
  void dispose() {
    _countSubscription?.cancel();
    _incrementSubscription?.cancel();
    debugPrint('🔴 NotificationCountViewModel disposed');
    super.dispose();
  }
}