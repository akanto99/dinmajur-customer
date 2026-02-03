import 'package:flutter/foundation.dart';
import '../../../../model/home_models/socket_home_model/socket_get_all_orders_model/socket_orderdetails_model.dart';
import '../../../socket_provider_services/socket_provider.dart';

class OrderDetailsSocketProvider with ChangeNotifier {
  // State
  OrderDetailsModel? _orderDetailsModel;
  bool _isLoading = false;
  String? _error;

  // Socket reference
  SocketProvider? _socketProvider;
  bool _isListenerSetup = false;
  String? _currentOrderId;

  // Getters
  OrderDetailsModel? get orderDetailsModel => _orderDetailsModel;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Initialize and fetch order details
  Future<void> initializeAndFetch({
    required SocketProvider socketProvider,
    required String orderId,
    Function(OrderDetailsModel)? onSuccess,
    Function(String)? onError,
  }) async {
    try {
      _socketProvider = socketProvider;
      _currentOrderId = orderId;

      // ✅ Ensure socket is connected before proceeding
      await _ensureSocketConnection();

      // Setup listeners once
      if (!_isListenerSetup) {
        print('🔧 [FRONTEND] Setting up listeners...');
        _setupListeners(onSuccess);
        _isListenerSetup = true;
        await Future.delayed(Duration(milliseconds: 200));
        print('✅ [FRONTEND] Listeners setup complete');
      } else {
        print('ℹ️ [FRONTEND] Listeners already setup, skipping');
      }

      // Fetch data
      print('📤 [FRONTEND] Calling _fetchOrderDetails...');
      await _fetchOrderDetails(orderId);
    } catch (e) {
      print('❌ [FRONTEND] initializeAndFetch error: $e');
      _error = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      onError?.call(_error!);
    }
  }

  /// Refresh order details
  Future<void> refreshOrderDetails({
    required SocketProvider socketProvider,
    required String orderId,
    Function(OrderDetailsModel)? onSuccess,
    Function(String)? onError,
  }) async {
    try {
      print('🔄 [FRONTEND] refreshOrderDetails called for orderId: $orderId');
      _socketProvider = socketProvider;
      _currentOrderId = orderId;

      // ✅ Ensure socket is connected before proceeding
      await _ensureSocketConnection();

      // Clear and reset listeners
      print('🧹 [FRONTEND] Clearing old listeners...');
      _clearListeners();
      await Future.delayed(Duration(milliseconds: 200));

      print('🔧 [FRONTEND] Setting up fresh listeners...');
      _setupListeners(onSuccess);
      _isListenerSetup = true;
      await Future.delayed(Duration(milliseconds: 200));
      print('✅ [FRONTEND] Fresh listeners setup complete');

      // Fetch data
      print('📤 [FRONTEND] Calling _fetchOrderDetails for refresh...');
      await _fetchOrderDetails(orderId);
    } catch (e) {
      print('❌ [FRONTEND] refreshOrderDetails error: $e');
      _error = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      onError?.call(_error!);
    }
  }

  /// ✅ NEW: Ensure socket is connected before any operation
  Future<void> _ensureSocketConnection() async {
    if (_socketProvider == null) {
      throw Exception('Socket provider is not initialized');
    }

    // If socket is already connected, return immediately
    if (_socketProvider!.isConnected) {
      print('✅ [FRONTEND] Socket already connected');
      print('🔌 [FRONTEND] Socket ID: ${_socketProvider!.socketService.socket?.id}');
      return;
    }

    // If socket is disconnected, attempt to reconnect
    print('⏳ [FRONTEND] Socket not connected, attempting reconnection...');
    _isLoading = true;
    notifyListeners();

    try {
      // Attempt auto-reconnect with retry logic
      await _socketProvider!.autoReconnect(maxRetries: 5, delay: Duration(seconds: 2));

      // Verify connection was successful
      if (!_socketProvider!.isConnected) {
        throw Exception('Failed to establish socket connection after retries');
      }

      print('✅ [FRONTEND] Socket reconnected successfully');
      print('🔌 [FRONTEND] Socket ID: ${_socketProvider!.socketService.socket?.id}');

      // Small delay to ensure connection is stable
      await Future.delayed(Duration(milliseconds: 500));

    } catch (e) {
      print('❌ [FRONTEND] Socket reconnection failed: $e');
      throw Exception('Could not connect to server: $e');
    }
  }

  /// Fetch order details by emitting socket event
  Future<void> _fetchOrderDetails(String orderId) async {
    print('📦 [FRONTEND] _fetchOrderDetails called with orderId: $orderId');

    if (orderId.trim().isEmpty || orderId == 'N/A') {
      print('❌ [FRONTEND] Invalid order ID: "$orderId"');
      throw Exception('Invalid order ID');
    }

    if (_socketProvider?.socketService.socket == null) {
      print('❌ [FRONTEND] Socket is null, cannot emit');
      throw Exception('Socket not available');
    }

    if (!_socketProvider!.isConnected) {
      print('❌ [FRONTEND] Socket not connected, cannot emit');
      throw Exception('Socket not connected');
    }

    print('✅ [FRONTEND] Socket available, preparing to emit');
    print('🔌 [FRONTEND] Socket connected: ${_socketProvider!.isConnected}');
    print('🔌 [FRONTEND] Socket ID: ${_socketProvider!.socketService.socket?.id}');

    _isLoading = true;
    _error = null;
    notifyListeners();

    print('📤 [FRONTEND] Emitting "request-order-details" event...');
    print('📤 [FRONTEND] Event data: {"orderId": "$orderId"}');

    // Emit request
    try {
      _socketProvider!.socketService.socket!.emit('request-order-details', {
        'orderId': orderId,
      });
      print('✅ [FRONTEND] Event emitted successfully');
      print('⏳ [FRONTEND] Waiting for backend response on "get-order-details" or "request-order-details-error"...');
    } catch (e) {
      print('❌ [FRONTEND] Error emitting event: $e');
      throw Exception('Failed to emit event: $e');
    }

    // Timeout handler
    Future.delayed(Duration(seconds: 15), () {
      if (_isLoading) {
        print('⏱️ [FRONTEND] Request timeout - no response received after 15 seconds');
        print('❌ [BACKEND] Backend did not respond to "request-order-details" event');
        _error = 'Request timeout - Backend not responding';
        _isLoading = false;
        notifyListeners();
      }
    });
  }

  /// Setup socket listeners
  void _setupListeners(Function(OrderDetailsModel)? onSuccess) {
    final socket = _socketProvider?.socketService.socket;
    if (socket == null) {
      print('⚠️ [FRONTEND] Cannot setup listeners: socket is null');
      return;
    }

    print('🔧 [FRONTEND] Setting up socket listeners...');

    // Clear existing listeners
    socket.off('get-order-details');
    socket.off('request-order-details-error');
    print('🧹 [FRONTEND] Cleared existing listeners');

    // Listen for success
    print('👂 [FRONTEND] Registering listener for "get-order-details"...');
    socket.on('get-order-details', (data) {
      print('═══════════════════════════════════════════════════════════');
      print('✅ [BACKEND] Response received on "get-order-details" event');
      print('📥 [BACKEND] Raw data: $data');
      print('═══════════════════════════════════════════════════════════');

      try {
        if (data == null) {
          print('❌ [BACKEND] Data is null');
          throw Exception('Received null data');
        }

        // Parse response
        Map<String, dynamic> responseData;
        if (data is Map<String, dynamic>) {
          if (data.containsKey('order')) {
            print('✅ [BACKEND] Data has "order" key - using direct structure');
            responseData = data;
          } else if (data.containsKey('data')) {
            print('✅ [BACKEND] Data has "data" key - using wrapped structure');
            responseData = data['data'];
          } else {
            print('❌ [BACKEND] Invalid structure - no "order" or "data" key');
            print('📋 [BACKEND] Available keys: ${data.keys.toList()}');
            throw Exception('Invalid response structure');
          }
        } else {
          print('❌ [BACKEND] Data is not Map<String, dynamic>');
          throw Exception('Invalid data format');
        }

        print('🔄 [FRONTEND] Parsing response data...');
        _orderDetailsModel = OrderDetailsModel.fromJson(responseData);
        print('✅ [FRONTEND] Data parsed successfully----------------------------');


        _isLoading = false;
        _error = null;
        notifyListeners();

        // Call success callback
        if (onSuccess != null && _orderDetailsModel != null) {
          onSuccess(_orderDetailsModel!);
        }

        print('✅ [FRONTEND] UI notified - data ready to display');
      } catch (e) {
        print('═══════════════════════════════════════════════════════════');
        print('❌ [FRONTEND] Parse error: $e');
        print('═══════════════════════════════════════════════════════════');
        _error = 'Failed to parse data: $e';
        _isLoading = false;
        notifyListeners();
      }
    });

    // Listen for errors
    print('👂 [FRONTEND] Registering listener for "request-order-details-error"...');
    socket.on('request-order-details-error', (data) {
      print('═══════════════════════════════════════════════════════════');
      print('❌ [BACKEND] Error received on "request-order-details-error" event');
      print('📥 [BACKEND] Error data type: ${data.runtimeType}');
      print('📥 [BACKEND] Raw error data: $data');
      print('═══════════════════════════════════════════════════════════');

      String errorMessage = 'Failed to fetch order details';

      if (data is String) {
        print('❌ [BACKEND] Error is String: $data');
        errorMessage = data;
      } else if (data is Map<String, dynamic>) {
        print('❌ [BACKEND] Error is Map');
        errorMessage = data['message']?.toString() ??
            data['error']?.toString() ??
            errorMessage;
        print('❌ [BACKEND] Extracted error message: $errorMessage');
      }

      _error = errorMessage;
      _isLoading = false;
      notifyListeners();
      print('❌ [FRONTEND] Error state updated and UI notified');
    });

    print('✅ [FRONTEND] All listeners registered successfully');
  }

  /// Clear socket listeners
  void _clearListeners() {
    final socket = _socketProvider?.socketService.socket;
    if (socket != null) {
      print('🧹 [FRONTEND] Clearing socket listeners...');
      socket.off('get-order-details');
      socket.off('request-order-details-error');
      print('✅ [FRONTEND] Socket listeners cleared');
    } else {
      print('⚠️ [FRONTEND] Cannot clear listeners: socket is null');
    }
    _isListenerSetup = false;
  }

  /// ✅ NEW: Retry fetching order details (useful after reconnection)
  Future<void> retryFetch() async {
    if (_currentOrderId == null) {
      print('⚠️ [FRONTEND] Cannot retry: No order ID stored');
      return;
    }

    if (_socketProvider == null) {
      print('⚠️ [FRONTEND] Cannot retry: Socket provider not initialized');
      return;
    }

    print('🔄 [FRONTEND] Retrying order details fetch...');

    try {
      await _ensureSocketConnection();
      await _fetchOrderDetails(_currentOrderId!);
    } catch (e) {
      print('❌ [FRONTEND] Retry failed: $e');
      _error = 'Retry failed: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Clear all data
  void clearData() {
    _orderDetailsModel = null;
    _isLoading = false;
    _error = null;
    notifyListeners();
  }

  /// Reset provider
  void reset() {
    _clearListeners();
    clearData();
    _socketProvider = null;
    _isListenerSetup = false;
    _currentOrderId = null;
  }

  @override
  void dispose() {
    _clearListeners();
    _socketProvider = null;
    _currentOrderId = null;
    super.dispose();
  }
}