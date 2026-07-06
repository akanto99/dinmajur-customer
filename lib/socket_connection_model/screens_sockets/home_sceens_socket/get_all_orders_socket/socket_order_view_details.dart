import 'package:dinmajur_customer/socket_connection_model/socket_provider_services/socket_manager.dart';
import 'package:flutter/foundation.dart';
import '../../../../model/home_models/socket_home_model/socket_get_all_orders_model/socket_orderdetails_model.dart';

/// Handles emit + listen for "request-order-details" / "get-order-details".
/// Uses SocketManager (singleton) — no SocketProvider dependency.
class OrderDetailsSocketProvider with ChangeNotifier {
  OrderDetailsModel? _orderDetailsModel;
  bool _isLoading = false;
  String? _error;
  String? _currentOrderId;

  OrderDetailsModel? get orderDetailsModel => _orderDetailsModel;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isInitialized => _currentOrderId != null;

  // ══════════════════════════════INITIALIZE — called from TrackOrderScreen and after Checkout═════════════════════════════════════
  Future<void> initializeAndFetch({
    required SocketManager socketManager,
    required String orderId,
    Function(OrderDetailsModel)? onSuccess,
    Function(String)? onError,
  }) async {
    _currentOrderId = orderId;

    if (!socketManager.isConnected) {

      _isLoading = true;
      _error = null;
      notifyListeners();

      // Wait up to 10 seconds for socket to connect (SocketManager handles connecting)
      int waited = 0;
      while (!socketManager.isConnected && waited < 20) {
        await Future.delayed(const Duration(milliseconds: 500));
        waited++;
      }

      if (!socketManager.isConnected) {
        _error = 'Could not connect to server';
        _isLoading = false;
        notifyListeners();
        onError?.call(_error!);
        return;
      }
    }

    await _setupAndFetch(socketManager, orderId, onSuccess: onSuccess, onError: onError);
  }

  // ══════════════════════════════ REFRESH — pull-to-refresh or return from another screen═════════════════════════════════════
  Future<void> refreshOrderDetails({
    required SocketManager socketManager,
    required String orderId,
    Function(OrderDetailsModel)? onSuccess,
    Function(String)? onError,
  }) async {
    _currentOrderId = orderId;

    if (!socketManager.isConnected) {
      int waited = 0;
      while (!socketManager.isConnected && waited < 10) {
        await Future.delayed(const Duration(milliseconds: 500));
        waited++;
      }
    }

    await _setupAndFetch(socketManager, orderId, onSuccess: onSuccess, onError: onError);
  }

  // ═══════════════════════════════RESET — clears stale data before a new fetch════════════════════════════════════
  void reset() {
    _orderDetailsModel = null;
    _isLoading = false;
    _error = null;
    _currentOrderId = null;
    notifyListeners();
  }

  // ══════════════════════════════INTERNAL═════════════════════════════════════
  Future<void> _setupAndFetch(
      SocketManager socketManager,
      String orderId, {
        Function(OrderDetailsModel)? onSuccess,
        Function(String)? onError,
      }) async {
    // Always clear + re-register listeners for a fresh start
    _clearListeners(socketManager);
    await Future.delayed(const Duration(milliseconds: 150));
    _registerListeners(socketManager, onSuccess: onSuccess, onError: onError);

    // Emit request
    _isLoading = true;
    _error = null;
    notifyListeners();

    socketManager.emit('request-order-details', {'orderId': orderId});

    // Timeout — 15 seconds
    Future.delayed(const Duration(seconds: 15), () {
      if (_isLoading) {
        _error = 'Request timed out — no response from server';
        _isLoading = false;
        notifyListeners();
        onError?.call(_error!);
      }
    });
  }

  void _registerListeners(
      SocketManager socketManager, {
        Function(OrderDetailsModel)? onSuccess,
        Function(String)? onError,
      }) {
    // ── Success ──────────────────────────────────────────────────────
    socketManager.on('get-order-details', (data) {
      try {
        if (data == null) throw Exception('Received null data');

        Map<String, dynamic> parsed;
        if (data is Map<String, dynamic>) {
          parsed = data.containsKey('order')
              ? data
              : (data['data'] is Map<String, dynamic> ? data['data'] : data);
        } else {
          throw Exception('Invalid data type: ${data.runtimeType}');
        }

        // Guard: only process if this is for our orderId
        final receivedId =
            parsed['order']?['id']?.toString() ??
                parsed['order']?['_id']?.toString();

        if (receivedId != null &&
            _currentOrderId != null &&
            receivedId != _currentOrderId) {
          return;
        }

        _orderDetailsModel = OrderDetailsModel.fromJson(parsed);
        _isLoading = false;
        _error = null;
        notifyListeners();
        onSuccess?.call(_orderDetailsModel!);

      } catch (e) {
        _error = 'Failed to parse order data';
        _isLoading = false;
        notifyListeners();
        onError?.call(_error!);
      }
    });

    // ── Error ─────────────────────────────────────────────────────────
    socketManager.on('request-order-details-error', (data) {
      _error = (data is Map ? data['message']?.toString() : data?.toString()) ??
          'Failed to fetch order details';
      _isLoading = false;
      notifyListeners();
      onError?.call(_error!);
    });

  }

  void _clearListeners(SocketManager socketManager) {
    socketManager.off('get-order-details');
    socketManager.off('request-order-details-error');
  }

  // ════════════════════════════════CLEANUP═══════════════════════════════════
  void clearAll(SocketManager socketManager) {
    _clearListeners(socketManager);
    _orderDetailsModel = null;
    _isLoading = false;
    _error = null;
    _currentOrderId = null;
    notifyListeners();
  }

  @override
  void dispose() {
    // Listeners are cleared by the screen / VM in their dispose()
    super.dispose();
  }
}