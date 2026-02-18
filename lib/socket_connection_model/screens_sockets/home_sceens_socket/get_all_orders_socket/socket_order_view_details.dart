import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../../model/home_models/socket_home_model/socket_get_all_orders_model/socket_orderdetails_model.dart';
import '../../../socket_provider_services/socket_provider.dart';

class OrderDetailsSocketProvider with ChangeNotifier {
  // ── State ─────────────────────────────────────────────────────────────────────
  OrderDetailsModel? _orderDetailsModel;
  bool _isLoading = false;
  String? _error;

  // ── Socket ────────────────────────────────────────────────────────────────────
  SocketProvider? _socketProvider;
  bool _isListenerSetup = false;
  String? _currentOrderId;
  dynamic _listenerSocketId;

  // ── Debounce: prevent double-emit when two observers fire simultaneously ───────
  Timer? _refreshDebounce;
  bool _isRefreshing = false;

  // ── Timeout timer ─────────────────────────────────────────────────────────────
  Timer? _timeoutTimer;

  // ── Getters ───────────────────────────────────────────────────────────────────
  OrderDetailsModel? get orderDetailsModel => _orderDetailsModel;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // ─────────────────────────────────────────────────────────────────────────────
  // PUBLIC: Initialize — fresh screen entry, always clears old data first
  // ─────────────────────────────────────────────────────────────────────────────
  Future<void> initializeAndFetch({
    required SocketProvider socketProvider,
    required String orderId,
    Function(OrderDetailsModel)? onSuccess,
    Function(String)? onError,
  }) async {
    print('🚀 [PROVIDER] initializeAndFetch → orderId: $orderId');

    // Cancel any pending debounce / timeout
    _refreshDebounce?.cancel();
    _timeoutTimer?.cancel();
    _isRefreshing = false;

    // Full reset — clears old data so previous order never bleeds through
    _resetState();

    _socketProvider = socketProvider;
    _currentOrderId = orderId;

    try {
      await _ensureSocketConnection();
      _rebuildListeners(onSuccess);
      // Show loader for first load (no data yet)
      await _emitRequest(orderId, showLoader: true);
    } catch (e) {
      print('❌ [PROVIDER] initializeAndFetch error: $e');
      _error = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      onError?.call(_error!);
    }
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // PUBLIC: Refresh — background update, NEVER wipes existing data or shows loader
  // Debounced: if called twice within 800ms, only fires once
  // ─────────────────────────────────────────────────────────────────────────────
  Future<void> refreshOrderDetails({
    required SocketProvider socketProvider,
    required String orderId,
    Function(OrderDetailsModel)? onSuccess,
    Function(String)? onError,
  }) async {
    // ✅ Debounce: ignore if a refresh is already queued or in-flight
    if (_isRefreshing) {
      print('⏭️ [PROVIDER] Refresh already in progress — skipping duplicate');
      return;
    }

    _refreshDebounce?.cancel();
    _refreshDebounce = Timer(const Duration(milliseconds: 600), () async {
      print('🔄 [PROVIDER] refreshOrderDetails → orderId: $orderId');

      _isRefreshing = true;
      _socketProvider = socketProvider;
      _currentOrderId = orderId;

      // ✅ Keep existing data visible — only clear the error
      _error = null;

      try {
        await _ensureSocketConnection();
        _rebuildListeners(onSuccess);
        // ✅ showLoader: false → no isLoading=true → no blink
        await _emitRequest(orderId, showLoader: false);
      } catch (e) {
        print('❌ [PROVIDER] refreshOrderDetails error: $e');
        // Don't wipe data on refresh failure — just show error silently
        _error = e.toString().replaceAll('Exception: ', '');
        notifyListeners();
        onError?.call(_error!);
      } finally {
        _isRefreshing = false;
      }
    });
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // PRIVATE: Ensure socket connected
  // ─────────────────────────────────────────────────────────────────────────────
  Future<void> _ensureSocketConnection() async {
    if (_socketProvider == null) throw Exception('Socket provider not initialized');

    if (_socketProvider!.isConnected) {
      print('✅ [PROVIDER] Socket already connected');
      return;
    }

    print('⏳ [PROVIDER] Socket disconnected — auto-reconnecting...');
    // Only show loader on first fetch (caller controls this via showLoader param)
    await _socketProvider!.autoReconnect(delay: const Duration(seconds: 2));

    if (!_socketProvider!.isConnected) {
      throw Exception('Failed to establish socket connection after retries');
    }

    print('✅ [PROVIDER] Socket reconnected');
    await Future.delayed(const Duration(milliseconds: 300));
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // PRIVATE: Rebuild listeners only if socket changed
  // ─────────────────────────────────────────────────────────────────────────────
  void _rebuildListeners(Function(OrderDetailsModel)? onSuccess) {
    final socket = _socketProvider?.socketService.socket;

    if (socket == null) {
      print('⚠️ [PROVIDER] Cannot setup listeners: socket is null');
      _isListenerSetup = false;
      _listenerSocketId = null;
      return;
    }

    final currentSocketId = socket.id ?? socket.hashCode;

    // Listeners already on THIS socket — nothing to do
    if (_isListenerSetup && _listenerSocketId == currentSocketId) {
      print('ℹ️ [PROVIDER] Listeners already on current socket ($currentSocketId)');
      return;
    }

    // Clear stale listeners (may be on a dead socket — that's a no-op)
    _clearListeners();

    print('🔧 [PROVIDER] Registering listeners on socket $currentSocketId');

    // ── Success ───────────────────────────────────────────────────────────────
    socket.on('get-order-details', (data) {
      print('✅ [PROVIDER] "get-order-details" received');

      // Cancel timeout — we got a response
      _timeoutTimer?.cancel();

      try {
        if (data == null) throw Exception('Received null data');

        Map<String, dynamic> responseData;
        if (data is Map<String, dynamic>) {
          if (data.containsKey('order')) {
            responseData = data;
          } else if (data.containsKey('data') && data['data'] is Map<String, dynamic>) {
            responseData = data['data'] as Map<String, dynamic>;
          } else {
            throw Exception('Invalid response structure. Keys: ${data.keys.toList()}');
          }
        } else {
          throw Exception('Data is not a Map: ${data.runtimeType}');
        }

        // ✅ Update data in-place — no wipe, no blink
        _orderDetailsModel = OrderDetailsModel.fromJson(responseData);
        _isLoading = false;
        _error = null;
        _isRefreshing = false;
        notifyListeners();

        print('✅ [PROVIDER] Parsed & UI notified (no blink)');

        if (onSuccess != null && _orderDetailsModel != null) {
          onSuccess(_orderDetailsModel!);
        }
      } catch (e) {
        print('❌ [PROVIDER] Parse error: $e');
        _error = 'Failed to parse data: $e';
        _isLoading = false;
        _isRefreshing = false;
        notifyListeners();
      }
    });

    // ── Error ─────────────────────────────────────────────────────────────────
    socket.on('request-order-details-error', (data) {
      print('❌ [PROVIDER] "request-order-details-error": $data');
      _timeoutTimer?.cancel();

      String msg = 'Failed to fetch order details';
      if (data is String) {
        msg = data;
      } else if (data is Map<String, dynamic>) {
        msg = data['message']?.toString() ?? data['error']?.toString() ?? msg;
      }

      _error = msg;
      _isLoading = false;
      _isRefreshing = false;
      notifyListeners();
    });

    _isListenerSetup = true;
    _listenerSocketId = currentSocketId;
    print('✅ [PROVIDER] Listeners registered on socket $currentSocketId');
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // PRIVATE: Emit request
  // showLoader = true  → sets _isLoading (first load, no data yet)
  // showLoader = false → silent refresh, keeps existing data visible
  // ─────────────────────────────────────────────────────────────────────────────
  Future<void> _emitRequest(String orderId, {required bool showLoader}) async {
    if (orderId.trim().isEmpty || orderId == 'N/A') {
      throw Exception('Invalid order ID: "$orderId"');
    }

    final socket = _socketProvider?.socketService.socket;
    if (socket == null) throw Exception('Socket is null');
    if (!_socketProvider!.isConnected) throw Exception('Socket not connected');

    // Only trigger loading spinner when there is no data to show
    if (showLoader) {
      _isLoading = true;
      _error = null;
      notifyListeners();
    }

    print('📤 [PROVIDER] Emitting "request-order-details" → orderId: $orderId (showLoader: $showLoader)');
    socket.emit('request-order-details', {'orderId': orderId});
    print('✅ [PROVIDER] Emitted successfully');

    // ✅ Timeout — only meaningful for first load
    _timeoutTimer?.cancel();
    _timeoutTimer = Timer(const Duration(seconds: 15), () {
      if (_isLoading || _isRefreshing) {
        print('⏱️ [PROVIDER] Timeout — no response after 15s');
        _error = _orderDetailsModel == null
            ? 'Request timed out. Please pull down to retry.'
            : null; // Don't show error if we already have data
        _isLoading = false;
        _isRefreshing = false;
        if (_error != null) notifyListeners();
      }
    });
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // PRIVATE: Clear listeners
  // ─────────────────────────────────────────────────────────────────────────────
  void _clearListeners() {
    final socket = _socketProvider?.socketService.socket;
    if (socket != null) {
      socket.off('get-order-details');
      socket.off('request-order-details-error');
      print('🧹 [PROVIDER] Cleared socket listeners');
    }
    _isListenerSetup = false;
    _listenerSocketId = null;
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // PRIVATE: Reset all state (first load only)
  // ─────────────────────────────────────────────────────────────────────────────
  void _resetState() {
    _clearListeners();
    _timeoutTimer?.cancel();
    _refreshDebounce?.cancel();
    _orderDetailsModel = null;
    _isLoading = false;
    _isRefreshing = false;
    _error = null;
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // PUBLIC: Retry button
  // ─────────────────────────────────────────────────────────────────────────────
  Future<void> retryFetch({Function(OrderDetailsModel)? onSuccess}) async {
    if (_currentOrderId == null || _socketProvider == null) return;

    print('🔄 [PROVIDER] retryFetch → $_currentOrderId');
    _isRefreshing = false; // Allow immediate retry

    try {
      await _ensureSocketConnection();
      _rebuildListeners(onSuccess);
      await _emitRequest(_currentOrderId!, showLoader: _orderDetailsModel == null);
    } catch (e) {
      print('❌ [PROVIDER] Retry failed: $e');
      _error = 'Retry failed: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // PUBLIC: Full reset (called on VM dispose)
  // ─────────────────────────────────────────────────────────────────────────────
  void reset() {
    _refreshDebounce?.cancel();
    _timeoutTimer?.cancel();
    _clearListeners();
    _orderDetailsModel = null;
    _isLoading = false;
    _isRefreshing = false;
    _error = null;
    _socketProvider = null;
    _currentOrderId = null;
    _listenerSocketId = null;
  }

  @override
  void dispose() {
    _refreshDebounce?.cancel();
    _timeoutTimer?.cancel();
    _clearListeners();
    super.dispose();
  }
}