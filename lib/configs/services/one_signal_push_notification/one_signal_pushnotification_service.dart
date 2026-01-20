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
      developer.log(
        'Notification received in foreground: ${event.notification.title}',
        name: 'OneSignal',
      );

      // You can modify the notification here or prevent it from showing
      // event.preventDefault(); // Prevents the notification from displaying

      // Display the notification
      event.notification.display();
    });

    // Notification clicked/opened
    OneSignal.Notifications.addClickListener((event) {
      developer.log(
        'Notification clicked: ${event.notification.title}',
        name: 'OneSignal',
      );

      // Handle notification click
      _handleNotificationClick(event);
    });

    // Permission observer
    OneSignal.Notifications.addPermissionObserver((state) {
      developer.log(
        'Notification permission state changed: $state',
        name: 'OneSignal',
      );
    });
  }

  /// Handle notification click events
  void _handleNotificationClick(OSNotificationClickEvent event) {
    final notification = event.notification;

    // Get additional data from notification
    final additionalData = notification.additionalData;

    developer.log(
      'Notification Data: ${additionalData.toString()}',
      name: 'OneSignal',
    );

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

  /// Set user tags (for segmentation)
  Future<void> setUserTags(Map<String, dynamic> tags) async {
    if (!_isInitialized) {
      throw Exception('OneSignal not initialized. Call initialize() first.');
    }

    try {
      await OneSignal.User.addTags(tags);
      developer.log('User tags set: $tags', name: 'OneSignal');
    } catch (e) {
      developer.log('Error setting user tags: $e', name: 'OneSignal', error: e);
      rethrow;
    }
  }

  /// Remove user tags
  Future<void> removeUserTags(List<String> tagKeys) async {
    if (!_isInitialized) {
      throw Exception('OneSignal not initialized. Call initialize() first.');
    }

    try {
      await OneSignal.User.removeTags(tagKeys);
      developer.log('User tags removed: $tagKeys', name: 'OneSignal');
    } catch (e) {
      developer.log('Error removing user tags: $e', name: 'OneSignal', error: e);
      rethrow;
    }
  }

  /// Set user email (for email notifications)
  Future<void> setUserEmail(String email) async {
    if (!_isInitialized) {
      throw Exception('OneSignal not initialized. Call initialize() first.');
    }

    try {
      await OneSignal.User.addEmail(email);
      developer.log('User email set: $email', name: 'OneSignal');
    } catch (e) {
      developer.log('Error setting user email: $e', name: 'OneSignal', error: e);
      rethrow;
    }
  }

  /// Set user phone number (for SMS notifications)
  Future<void> setUserPhoneNumber(String phoneNumber) async {
    if (!_isInitialized) {
      throw Exception('OneSignal not initialized. Call initialize() first.');
    }

    try {
      await OneSignal.User.addSms(phoneNumber);
      developer.log('User phone number set: $phoneNumber', name: 'OneSignal');
    } catch (e) {
      developer.log('Error setting user phone number: $e', name: 'OneSignal', error: e);
      rethrow;
    }
  }

  /// Get current notification permission status
  Future<bool> getNotificationPermission() async {
    if (!_isInitialized) {
      throw Exception('OneSignal not initialized. Call initialize() first.');
    }

    try {
      final permission = await OneSignal.Notifications.permission;
      developer.log('Notification permission: $permission', name: 'OneSignal');
      return permission;
    } catch (e) {
      developer.log('Error getting notification permission: $e', name: 'OneSignal', error: e);
      return false;
    }
  }

  /// Request notification permission
  Future<bool> requestNotificationPermission() async {
    if (!_isInitialized) {
      throw Exception('OneSignal not initialized. Call initialize() first.');
    }

    try {
      final granted = await OneSignal.Notifications.requestPermission(true);
      developer.log('Notification permission granted: $granted', name: 'OneSignal');
      return granted;
    } catch (e) {
      developer.log('Error requesting notification permission: $e', name: 'OneSignal', error: e);
      return false;
    }
  }

  /// Get OneSignal device ID
  String? getDeviceId() {
    if (!_isInitialized) {
      throw Exception('OneSignal not initialized. Call initialize() first.');
    }

    try {
      final deviceId = OneSignal.User.pushSubscription.id;
      developer.log('OneSignal Device ID: $deviceId', name: 'OneSignal');
      return deviceId;
    } catch (e) {
      developer.log('Error getting device ID: $e', name: 'OneSignal', error: e);
      return null;
    }
  }

  /// Get current user ID
  String? getCurrentUserId() {
    return _currentUserId;
  }

  /// Check if OneSignal is initialized
  bool get isInitialized => _isInitialized;

  /// Clear notification badges (iOS)
  Future<void> clearBadges() async {
    try {
      await OneSignal.Notifications.clearAll();
      developer.log('Notification badges cleared', name: 'OneSignal');
    } catch (e) {
      developer.log('Error clearing badges: $e', name: 'OneSignal', error: e);
    }
  }

  /// Send outcome (for tracking conversions)
  Future<void> sendOutcome(String outcomeName, {double? value}) async {
    if (!_isInitialized) {
      throw Exception('OneSignal not initialized. Call initialize() first.');
    }

    try {
      if (value != null) {
        await OneSignal.Session.addOutcomeWithValue(outcomeName, value);
      } else {
        await OneSignal.Session.addOutcome(outcomeName);
      }
      developer.log('Outcome sent: $outcomeName${value != null ? " = $value" : ""}', name: 'OneSignal');
    } catch (e) {
      developer.log('Error sending outcome: $e', name: 'OneSignal', error: e);
      rethrow;
    }
  }

  /// Opt in/out of push notifications
  Future<void> setSubscription(bool subscribe) async {
    if (!_isInitialized) {
      throw Exception('OneSignal not initialized. Call initialize() first.');
    }

    try {
      await OneSignal.User.pushSubscription.optIn();
      developer.log('Push subscription: ${subscribe ? "opted in" : "opted out"}', name: 'OneSignal');
    } catch (e) {
      developer.log('Error setting subscription: $e', name: 'OneSignal', error: e);
      rethrow;
    }
  }
}