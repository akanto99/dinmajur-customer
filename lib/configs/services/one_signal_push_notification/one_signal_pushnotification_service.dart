import 'package:dinmajur_customer/configs/services/navigator_services/navigator_services_refreshToken.dart';
import 'package:dinmajur_customer/configs/services/navigator_services/pending_navigator_service.dart';
import 'package:dinmajur_customer/configs/utils/routes/routes_name.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer' as developer;

/// OneSignal Notification Service
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
      // OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
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
      final notification = event.notification;

      final title = notification.title;
      final body = notification.body;
      final data = notification.additionalData;

      developer.log("--------------------------- Title: $title");
      developer.log("---------------------------Body: $body");
      developer.log("--------------------------- Data: $data");

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
    final raw = notification.additionalData ?? {};

    developer.log('Notification clicked with raw data: $raw', name: 'OneSignal');

    final Map<String, dynamic> inner = (raw['data'] is Map) ? Map<String, dynamic>.from(raw['data'] as Map) : {};

    final String? bookingType = (inner['bookingType'] ?? raw['bookingType'])?.toString();
    final String? trackingId = (inner['trackingId'] ?? raw['trackingId'])?.toString();
    final String? orderId = (inner['orderId'] ?? raw['orderId'])?.toString();
    final String? bookingStatus = (inner['bookingStatus'] ?? inner['status'] ?? raw['status'])?.toString().toUpperCase();

    developer.log('Resolved → bookingType: $bookingType | trackingId: $trackingId | orderId: $orderId | status: $bookingStatus', name: 'OneSignal');

    if (bookingType == null || bookingType.isEmpty) {
      developer.log('Missing bookingType, cannot route', name: 'OneSignal');
      return;
    }

    // Resolve route + arguments from bookingType
    String? targetRoute;
    Map<String, dynamic>? targetArgs;

    switch (bookingType) {
      case 'ORDER':
        if (orderId == null || orderId.isEmpty) return;
        if (bookingStatus == 'PENDING' || bookingStatus == 'RUNNING') {
          targetRoute = RoutesName.trackOrderViewdetailsSocketScreen;
          targetArgs = {'orderId': orderId};
        } else {
          targetRoute = RoutesName.completeOrdersDetailsScreen;
          targetArgs = {'orderId': orderId};
        }
        break;
      case 'HOUSEKEEPER':
      case 'BEAUTY_SALON':
      case 'EVENT_COOKING':
      case 'SERVICES':
        int tabIndex = 0; // default to pending
        if (bookingStatus == 'PENDING') {
          tabIndex = 0;
        } else if (bookingStatus == 'RUNNING') {
          tabIndex = 1;
        } else if (bookingStatus == 'COMPLETED' || bookingStatus == 'COMPLETE') {
          tabIndex = 2;
        }
        targetRoute = RoutesName.navigationBar;
        targetArgs = {'initialIndex': 2, 'orderTabIndex': tabIndex};

      case 'SYSTEM':
      case 'PROMOTION':
        targetRoute = RoutesName.navigationBar;
        targetArgs = {'initialIndex': 0, 'orderTabIndex': 0};
        break;
    }

    final navigator = NavigationService.navigatorKey.currentState;

    if (navigator == null) {
      developer.log('Navigator not ready, saving pending route: $targetRoute', name: 'OneSignal');
      PendingNavigationService().setPending(targetRoute!, targetArgs ?? {});
      return;
    }
    navigator.pushNamed(targetRoute!, arguments: targetArgs);
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
