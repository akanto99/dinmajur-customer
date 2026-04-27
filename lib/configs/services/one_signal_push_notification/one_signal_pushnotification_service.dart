import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer' as developer;

/// OneSignal Notification Service
/// Handles all OneSignal notification configuration and management
class OneSignalNotificationService {
  static final OneSignalNotificationService _instance = OneSignalNotificationService._internal();
  factory OneSignalNotificationService() => _instance;
  OneSignalNotificationService._internal();

  bool _isInitialized = false;
  String? _currentUserId;

  /// Initialize OneSignal with configuration
  Future<void> initialize() async {
    if (_isInitialized) {
      developer.log('OneSignal already initialized', name: 'OneSignal');
      return;
    }

    try {
      // Set log level for debugging
      OneSignal.Debug.setLogLevel(OSLogLevel.verbose);

      // Get OneSignal App ID from .env
      final oneSignalAppId = dotenv.env['ONESIGNAL_APP_ID'];
      if (oneSignalAppId == null || oneSignalAppId.isEmpty) {
        throw Exception('ONESIGNAL_APP_ID not found in .env file');
      }

      // Initialize OneSignal
      OneSignal.initialize(oneSignalAppId);

      // Request notification permission (false = don't fallback to settings)
      await OneSignal.Notifications.requestPermission(true);

      // Set up notification handlers
      _setupNotificationHandlers();

      _isInitialized = true;
      developer.log('OneSignal initialized successfully', name: 'OneSignal');
    } catch (e) {
      developer.log('Error initializing OneSignal: $e', name: 'OneSignal', error: e);
      rethrow;
    }
  }

  /// Set up notification event handlers
  void _setupNotificationHandlers() {
    // Notification received (foreground)
    OneSignal.Notifications.addForegroundWillDisplayListener((event) {
      developer.log('Notification received in foreground: ${event.notification.title}', name: 'OneSignal');
      print("----------------------This is Foreground--------------");
      // You can modify the notification here or prevent it from showing
      // event.preventDefault(); // Prevents the notification from displaying

      // Display the notification
      event.notification.display();
    });

    // Notification clicked/opened
    OneSignal.Notifications.addClickListener((event) {
      developer.log('Notification clicked: ${event.notification.title}', name: 'OneSignal');

      // Handle notification click
      _handleNotificationClick(event);
    });

    // Permission observer
    OneSignal.Notifications.addPermissionObserver((state) {
      developer.log('Notification permission state changed: $state', name: 'OneSignal');
    });
  }

  /// Handle notification click events
  void _handleNotificationClick(OSNotificationClickEvent event) {
    final notification = event.notification;

    // Get additional data from notification
    final additionalData = notification.additionalData;

    developer.log('Notification Data: ${additionalData.toString()}', name: 'OneSignal');

    // TODO: Navigate to specific screen based on notification data
    // Example:
    // if (additionalData?['type'] == 'order') {
    //   NavigationService.navigatorKey.currentState?.pushNamed(
    //     RoutesName.orderDetails,
    //     arguments: additionalData?['orderId'],
    //   );
    // }
  }

  /// Login user to OneSignal (for targeted notifications)
  Future<void> loginUser(String userId) async {
    if (!_isInitialized) {
      developer.log('OneSignal not initialized, initializing now...', name: 'OneSignal');
      await initialize();
    }

    try {
      await OneSignal.login(userId);
      _currentUserId = userId;

      // Save to SharedPreferences for persistence
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('onesignal_user_id', userId);

      developer.log('✅ User logged in to OneSignal: $userId', name: 'OneSignal');
    } catch (e) {
      developer.log('❌ Error logging in user: $e', name: 'OneSignal', error: e);
      rethrow;
    }
  }

  /// Logout user from OneSignal
  Future<void> logoutUser() async {
    if (!_isInitialized) {
      throw Exception('OneSignal not initialized. Call initialize() first.');
    }

    try {
      await OneSignal.logout();
      _currentUserId = null;

      // Remove from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('onesignal_user_id');

      developer.log('User logged out from OneSignal', name: 'OneSignal');
    } catch (e) {
      developer.log('Error logging out user: $e', name: 'OneSignal', error: e);
      rethrow;
    }
  }

  /// Auto-login if user was previously logged in
  Future<void> autoLogin() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId'); // Your app's user ID

      if (userId != null && userId.isNotEmpty) {
        await loginUser(userId);
      }
    } catch (e) {
      developer.log('Error in auto-login: $e', name: 'OneSignal', error: e);
    }
  }

  /// Get current user ID
  String? getCurrentUserId() {
    return _currentUserId;
  }
}
