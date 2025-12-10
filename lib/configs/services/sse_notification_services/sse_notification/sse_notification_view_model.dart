// notification_view_model.dart
import 'package:dinmajur_customer/configs/services/sse_notification_services/sse_notification/get_ssc_nofication_model.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';

class NotificationViewModel extends ChangeNotifier {
  // List of notifications (using proper model)
  List<GetSseNotificationModel> _notifications = [];

  // Stream subscription
  StreamSubscription<Map<String, dynamic>>? _notificationSubscription;

  // Loading state
  bool _isLoading = false;

  // Getters
  List<GetSseNotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;
  bool get hasNotifications => _notifications.isNotEmpty;
  int get notificationCount => _notifications.length;

  // Get unread count from notification list (if needed separately)
  int get unreadCount => _notifications
      .where((n) => n.ssePayload?.read != true)
      .length;

  // Initialize notification listener (for full notification objects)
  void initializeNotificationListener(Stream<Map<String, dynamic>> notificationStream) {
    _notificationSubscription?.cancel();

    debugPrint('🎯 NotificationViewModel: Initializing notification listener...');

    _notificationSubscription = notificationStream.listen(
          (notificationData) {
        _handleNewNotification(notificationData);
      },
      onError: (error) {
        debugPrint('❌ Error in notification stream: $error');
      },
      onDone: () {
        debugPrint('⚠️ Notification stream closed');
      },
      cancelOnError: false,
    );

    debugPrint('✅ Notification listener initialized');
  }

  // Handle new notification
  void _handleNewNotification(Map<String, dynamic> data) {
    debugPrint('═══════════════════════════════════════════════════════');
    debugPrint('🆕 NEW NOTIFICATION RECEIVED');
    debugPrint('═══════════════════════════════════════════════════════');

    try {
      // Parse to model (data already has ssePayload wrapper)
      final notification = GetSseNotificationModel.fromJson(data);

      // Validate that we have the payload
      if (notification.ssePayload == null) {
        debugPrint('⚠️ Notification has no ssePayload, ignoring');
        return;
      }

      // Add to notifications list at the beginning
      _notifications.insert(0, notification);
      notifyListeners();

      // Log notification details
      debugPrint('✅ Notification added:');
      debugPrint('   Type: ${notification.ssePayload?.type}');
      debugPrint('   Message: ${notification.ssePayload?.message}');
      debugPrint('   Priority: ${notification.ssePayload?.priority}');
      debugPrint('   Order ID: ${notification.ssePayload?.data?.orderId}');
      debugPrint('   Action URL: ${notification.ssePayload?.actionUrl}');
      debugPrint('   Read: ${notification.ssePayload?.read}');
      debugPrint('───────────────────────────────────────────────────────');
      debugPrint('📈 Total Notifications: ${_notifications.length}');
      debugPrint('🔴 Unread Count: $unreadCount');
      debugPrint('═══════════════════════════════════════════════════════');
    } catch (e, stackTrace) {
      debugPrint('❌ Error parsing notification: $e');
      debugPrint('❌ Stack trace: $stackTrace');
      debugPrint('❌ Raw data: $data');
    }
  }

  // Mark notification as read by index
  void markAsRead(int index) {
    if (index < 0 || index >= _notifications.length) {
      debugPrint('⚠️ Invalid notification index: $index');
      return;
    }

    final notification = _notifications[index];

    if (notification.ssePayload?.read != true) {
      notification.ssePayload?.read = true;
      debugPrint('✅ Notification marked as read at index $index');
      notifyListeners();
    }
  }

  // Mark notification as read by ID
  void markAsReadById(String notificationId) {
    final index = _notifications.indexWhere(
          (notification) => notification.ssePayload?.id == notificationId,
    );

    if (index != -1) {
      markAsRead(index);
    } else {
      debugPrint('⚠️ Notification not found with ID: $notificationId');
    }
  }

  // Mark all as read
  void markAllAsRead() {
    int markedCount = 0;

    for (var notification in _notifications) {
      if (notification.ssePayload?.read != true) {
        notification.ssePayload?.read = true;
        markedCount++;
      }
    }

    debugPrint('✅ Marked $markedCount notifications as read');
    notifyListeners();
  }

  // Clear all notifications
  void clearAllNotifications() {
    final count = _notifications.length;
    _notifications.clear();
    debugPrint('✅ Cleared $count notifications');
    notifyListeners();
  }

  // Delete a single notification
  void deleteNotification(int index) {
    if (index < 0 || index >= _notifications.length) {
      debugPrint('⚠️ Invalid notification index: $index');
      return;
    }

    _notifications.removeAt(index);
    debugPrint('✅ Notification deleted at index $index');
    notifyListeners();
  }

  // Delete notification by ID
  void deleteNotificationById(String notificationId) {
    final index = _notifications.indexWhere(
          (notification) => notification.ssePayload?.id == notificationId,
    );

    if (index != -1) {
      deleteNotification(index);
    } else {
      debugPrint('⚠️ Notification not found with ID: $notificationId');
    }
  }

  // Get notification by ID
  GetSseNotificationModel? getNotificationById(String id) {
    try {
      return _notifications.firstWhere(
            (notification) => notification.ssePayload?.id == id,
      );
    } catch (e) {
      debugPrint('⚠️ Notification not found with ID: $id');
      return null;
    }
  }

  // Get notifications by type
  List<GetSseNotificationModel> getNotificationsByType(String type) {
    return _notifications
        .where((notification) => notification.ssePayload?.type == type)
        .toList();
  }

  // Get unread notifications
  List<GetSseNotificationModel> getUnreadNotifications() {
    return _notifications
        .where((notification) => notification.ssePayload?.read != true)
        .toList();
  }

  // Get read notifications
  List<GetSseNotificationModel> getReadNotifications() {
    return _notifications
        .where((notification) => notification.ssePayload?.read == true)
        .toList();
  }

  // Get notifications by priority
  List<GetSseNotificationModel> getNotificationsByPriority(String priority) {
    return _notifications
        .where((notification) => notification.ssePayload?.priority == priority)
        .toList();
  }

  // Get high priority unread notifications
  List<GetSseNotificationModel> getHighPriorityUnread() {
    return _notifications
        .where((notification) =>
    notification.ssePayload?.priority == 'high' &&
        notification.ssePayload?.read != true)
        .toList();
  }

  // Get notification count by type
  int getNotificationCountByType(String type) {
    return _notifications
        .where((notification) => notification.ssePayload?.type == type)
        .length;
  }

  // Set loading state
  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Refresh notifications (if you want to fetch from API)
  Future<void> refreshNotifications() async {
    setLoading(true);
    // TODO: Implement API call to fetch notifications
    await Future.delayed(Duration(seconds: 1)); // Simulated delay
    setLoading(false);
  }

  @override
  void dispose() {
    _notificationSubscription?.cancel();
    debugPrint('🔴 NotificationViewModel disposed');
    super.dispose();
  }
}