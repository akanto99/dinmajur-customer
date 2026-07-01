// notification_view_model.dart
import 'package:dinmajur_customer/configs/services/sse_notification_services/notificationscreen_with_sse/get_ssc_nofication_model.dart';
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


    _notificationSubscription = notificationStream.listen(
          (notificationData) {
        _handleNewNotification(notificationData);
      },
      onError: (error) {
      },
      onDone: () {
      },
      cancelOnError: false,
    );

  }

  // Handle new notification
  void _handleNewNotification(Map<String, dynamic> data) {

    try {
      // Parse to model (data already has ssePayload wrapper)
      final notification = GetSseNotificationModel.fromJson(data);

      // Validate that we have the payload
      if (notification.ssePayload == null) {
        return;
      }

      // Add to notifications list at the beginning
      _notifications.insert(0, notification);
      notifyListeners();

      // Log notification details
    } catch (e, stackTrace) {
    }
  }

  // Mark notification as read by index
  void markAsRead(int index) {
    if (index < 0 || index >= _notifications.length) {
      return;
    }

    final notification = _notifications[index];

    if (notification.ssePayload?.read != true) {
      notification.ssePayload?.read = true;
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

    notifyListeners();
  }

  // Clear all notifications
  void clearAllNotifications() {
    final count = _notifications.length;
    _notifications.clear();
    notifyListeners();
  }

  // Delete a single notification
  void deleteNotification(int index) {
    if (index < 0 || index >= _notifications.length) {
      return;
    }

    _notifications.removeAt(index);
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
    }
  }

  // Get notification by ID
  GetSseNotificationModel? getNotificationById(String id) {
    try {
      return _notifications.firstWhere(
            (notification) => notification.ssePayload?.id == id,
      );
    } catch (e) {
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
    super.dispose();
  }
}