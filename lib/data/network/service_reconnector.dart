import 'dart:async';
import 'package:dinmajur_customer/configs/services/sse_notification_services/sse_notification_and_ordercount/notification_count_view_model.dart';
import 'package:dinmajur_customer/configs/services/sse_notification_services/sse_notification_and_ordercount/running_ordercount_view_model.dart';
import 'package:dinmajur_customer/configs/services/sse_notification_services/sse_notification_service.dart';
import 'package:dinmajur_customer/socket_connection_model/socket_provider_services/socket_manager.dart';

class ServiceReconnector {
  static final ServiceReconnector _instance = ServiceReconnector._internal();
  factory ServiceReconnector() => _instance;
  ServiceReconnector._internal();

  SocketManager? _socketManager;
  SSENotificationService? _sseService;
  NotificationCountViewModel? _notifVM;
  RunningOrderCountViewModel? _orderVM;

  bool get _isInitialized =>
      _socketManager != null &&
          _sseService != null &&
          _notifVM != null &&
          _orderVM != null;

  void init({
    required SocketManager socketManager,
    required SSENotificationService sseService,
    required NotificationCountViewModel notifVM,
    required RunningOrderCountViewModel orderVM,
  }) {
    _socketManager = socketManager;
    _sseService = sseService;
    _notifVM = notifVM;
    _orderVM = orderVM;
  }

  Future<void> reconnectAll(String newAccessToken) async {
    if (!_isInitialized) {
      return;
    }
    await Future.wait([
      _reconnectSocket(newAccessToken),
      _reconnectSSE(),
    ]);
  }

  Future<void> _reconnectSocket(String newAccessToken) async {
    try {
      final socket = _socketManager!;
      if (socket.isConnected) {
        socket.disconnect();
        await Future.delayed(const Duration(milliseconds: 300));
      }
      await socket.connect(newAccessToken);
    } catch (e) {
    }
  }

  Future<void> _reconnectSSE() async {
    try {
      final sseService = _sseService!;
      final notifVM = _notifVM!;
      final orderVM = _orderVM!;

      await sseService.stopListening();
      await Future.delayed(const Duration(milliseconds: 300));
      await sseService.startListening();
      await Future.delayed(const Duration(milliseconds: 300));

      if (!notifVM.isInitialized) {
        notifVM.initializeCountListener(
          sseService.notificationCountStream,
          sseService.notificationIncrementStream,
        );
      }
      notifVM.setInitialCount(sseService.currentCount);

      if (!orderVM.isInitialized) {
        orderVM.initializeCountListener(sseService.runningOrderCountStream);
      }
      orderVM.setInitialCount(sseService.currentRunningOrderCount);

    } catch (e) {
    }
  }
}