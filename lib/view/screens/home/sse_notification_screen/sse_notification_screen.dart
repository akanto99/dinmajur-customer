// notifications_list_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dinmajur_customer/configs/services/sse_notification_services/sse_notification_service.dart';
import 'package:dinmajur_customer/configs/services/sse_notification_services/sse_notification/sse_notification_view_model.dart';

class NotificationsListScreenOld extends StatefulWidget {
  const NotificationsListScreenOld({Key? key}) : super(key: key);

  @override
  State<NotificationsListScreenOld> createState() => _NotificationsListScreenOldState();
}

class _NotificationsListScreenOldState extends State<NotificationsListScreenOld> {
  bool _listenerInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // ✅ Initialize notification listener ONLY in notifications list screen
    if (!_listenerInitialized) {
      _initializeNotificationListener();
      _listenerInitialized = true;
    }
  }

  void _initializeNotificationListener() {
    try {
      final sseService = Provider.of<SSENotificationService>(context, listen: false);
      final notificationViewModel = Provider.of<NotificationViewModel>(context, listen: false);

      // Connect notification stream to view model
      notificationViewModel.initializeNotificationListener(
        sseService.notificationStream,
      );

      debugPrint('✅ NotificationsListScreen: Notification listener initialized');
    } catch (e) {
      debugPrint('❌ NotificationsListScreen: Error initializing listener: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications'),
        actions: [
          Consumer<NotificationViewModel>(
            builder: (context, viewModel, _) {
              if (viewModel.hasNotifications) {
                return TextButton(
                  onPressed: () {
                    viewModel.markAllAsRead();
                  },
                  child: Text('Mark All Read'),
                );
              }
              return SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Consumer<NotificationViewModel>(
        builder: (context, viewModel, _) {
          if (viewModel.isLoading) {
            return Center(child: CircularProgressIndicator());
          }

          if (!viewModel.hasNotifications) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_off, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No notifications yet'),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: viewModel.refreshNotifications,
            child: ListView.builder(
              itemCount: viewModel.notifications.length,
              itemBuilder: (context, index) {
                final notification = viewModel.notifications[index];
                final payload = notification.ssePayload;

                if (payload == null) return SizedBox.shrink();

                final isUnread = payload.read != true;

                return Dismissible(
                  key: Key(payload.id ?? index.toString()),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: EdgeInsets.only(right: 20),
                    color: Colors.red,
                    child: Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (_) {
                    viewModel.deleteNotification(index);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Notification deleted')),
                    );
                  },
                  child: Card(
                    margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    color: isUnread ? Colors.blue.shade50 : Colors.white,
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: _getPriorityColor(payload.priority),
                        child: Icon(
                          _getNotificationIcon(payload.type),
                          color: Colors.white,
                        ),
                      ),
                      title: Text(
                        payload.message ?? 'No message',
                        style: TextStyle(
                          fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (payload.data?.orderId != null)
                            Text('Order: ${payload.data!.orderId}'),
                          Text(
                            _formatDateTime(payload.createdAt),
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                      trailing: isUnread
                          ? Icon(Icons.circle, color: Colors.blue, size: 12)
                          : null,
                      onTap: () {
                        if (isUnread) {
                          viewModel.markAsRead(index);
                        }

                        // TODO: Navigate based on actionUrl or notification type
                        if (payload.actionUrl != null) {
                          debugPrint('Navigate to: ${payload.actionUrl}');
                        }
                      },
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Color _getPriorityColor(String? priority) {
    switch (priority?.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.blue;
    }
  }

  IconData _getNotificationIcon(String? type) {
    switch (type?.toLowerCase()) {
      case 'order':
        return Icons.shopping_bag;
      case 'delivery':
        return Icons.local_shipping;
      case 'payment':
        return Icons.payment;
      default:
        return Icons.notifications;
    }
  }

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return '';

    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }
}