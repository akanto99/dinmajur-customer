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

  // ✅ Track which orderId this provider is currently serving
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
      print('📱 [FRONTEND] initializeAndFetch called for orderId: $orderId');
      _socketProvider = socketProvider;
      _currentOrderId = orderId; // ✅ Store the current orderId

      // Wait for socket connection
      if (!_socketProvider!.isConnected) {
        print('⏳ [FRONTEND] Socket not connected, waiting...');
        _isLoading = true;
        notifyListeners();

        int attempts = 0;
        while (!_socketProvider!.isConnected && attempts < 20) {
          await Future.delayed(Duration(milliseconds: 500));
          attempts++;
          print('⏳ [FRONTEND] Connection attempt $attempts/20');
        }

        if (!_socketProvider!.isConnected) {
          print('❌ [FRONTEND] Socket connection timeout after 20 attempts');
          throw Exception('Could not connect to server');
        }
      }

      print('✅ [FRONTEND] Socket is connected');
      print('🔌 [FRONTEND] Socket ID: ${_socketProvider!.socketService.socket?.id}');

      // Setup listeners once
      if (!_isListenerSetup) {
        print('🔧 [FRONTEND] Setting up listeners...');
        _setupListeners(onSuccess: onSuccess);
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
      _currentOrderId = orderId; // ✅ Keep currentOrderId in sync

      if (!_socketProvider!.isConnected) {
        print('❌ [FRONTEND] Socket not connected during refresh');
        throw Exception('Socket not connected');
      }

      print('✅ [FRONTEND] Socket connected for refresh');
      print('🔌 [FRONTEND] Socket ID: ${_socketProvider!.socketService.socket?.id}');

      // Clear and reset listeners
      print('🧹 [FRONTEND] Clearing old listeners...');
      _clearListeners();
      await Future.delayed(Duration(milliseconds: 200));

      print('🔧 [FRONTEND] Setting up fresh listeners...');
      _setupListeners(onSuccess: onSuccess);
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

    print('✅ [FRONTEND] Socket available, preparing to emit');
    print('🔌 [FRONTEND] Socket connected: ${_socketProvider!.isConnected}');
    print('🔌 [FRONTEND] Socket ID: ${_socketProvider!.socketService.socket?.id}');

    _isLoading = true;
    _error = null;
    notifyListeners();

    print('📤 [FRONTEND] Emitting "request-order-details" event...');
    print('📤 [FRONTEND] Event data: {"orderId": "$orderId"}');

    try {
      _socketProvider!.socketService.socket!.emit('request-order-details', {
        'orderId': orderId,
      });
      print('✅ [FRONTEND] Event emitted successfully');
      print('⏳ [FRONTEND] Waiting for backend response...');
    } catch (e) {
      print('❌ [FRONTEND] Error emitting event: $e');
      throw Exception('Failed to emit event: $e');
    }

    // Timeout handler
    Future.delayed(Duration(seconds: 15), () {
      if (_isLoading) {
        print('⏱️ [FRONTEND] Request timeout - no response received after 15 seconds');
        _error = 'Request timeout - Backend not responding';
        _isLoading = false;
        notifyListeners();
      }
    });
  }

  /// Setup socket listeners
  void _setupListeners({Function(OrderDetailsModel)? onSuccess}) {
    final socket = _socketProvider?.socketService.socket;
    if (socket == null) {
      print('⚠️ [FRONTEND] Cannot setup listeners: socket is null');
      return;
    }

    print('🔧 [FRONTEND] Setting up socket listeners...');

    // Clear existing listeners first
    socket.off('get-order-details');
    socket.off('request-order-details-error');
    print('🧹 [FRONTEND] Cleared existing listeners');

    // ── Success listener ──────────────────────────────────────────────────────
    print('👂 [FRONTEND] Registering listener for "get-order-details"...');
    socket.on('get-order-details', (data) {
      print('═══════════════════════════════════════════════════════════');
      print('✅ [BACKEND] Response received on "get-order-details" event');
      print('📥 [BACKEND] Data type: ${data.runtimeType}');
      print('═══════════════════════════════════════════════════════════');

      try {
        if (data == null) {
          print('❌ [BACKEND] Data is null');
          throw Exception('Received null data');
        }

        // Parse response structure
        Map<String, dynamic> responseData;
        if (data is Map<String, dynamic>) {
          if (data.containsKey('order')) {
            responseData = data;
          } else if (data.containsKey('data') && data['data'] is Map<String, dynamic>) {
            responseData = data['data'] as Map<String, dynamic>;
          } else {
            print('❌ [BACKEND] Invalid structure. Keys: ${data.keys.toList()}');
            throw Exception('Invalid response structure');
          }
        } else {
          throw Exception('Invalid data format: ${data.runtimeType}');
        }

        // ✅ KEY FIX: Only process if this response belongs to OUR orderId
        final receivedOrderId =
            responseData['order']?['id']?.toString() ??
                responseData['order']?['_id']?.toString();

        if (receivedOrderId != null &&
            _currentOrderId != null &&
            receivedOrderId != _currentOrderId) {
          print('⚠️ [FRONTEND] Ignoring response — wrong order!');
          print('   Expected : $_currentOrderId');
          print('   Received : $receivedOrderId');
          return; // ✅ Not our order — silently drop it
        }

        print('✅ [FRONTEND] Order ID matches — processing response');
        print('🔄 [FRONTEND] Parsing response data...');

        _orderDetailsModel = OrderDetailsModel.fromJson(responseData);

        print('✅ [FRONTEND] Data parsed successfully');
        print('📋 [FRONTEND] Order ID: ${_orderDetailsModel?.order?.id}');
        print('📋 [FRONTEND] Customer: ${_orderDetailsModel?.customer?.fullName}');
        print('📋 [FRONTEND] Delivery status: ${_orderDetailsModel?.delivery?.status}');

        _isLoading = false;
        _error = null;
        notifyListeners();

        print('✅ [FRONTEND] UI notified — data ready to display');

        if (onSuccess != null && _orderDetailsModel != null) {
          onSuccess(_orderDetailsModel!);
        }
      } catch (e) {
        print('═══════════════════════════════════════════════════════════');
        print('❌ [FRONTEND] Parse error: $e');
        print('═══════════════════════════════════════════════════════════');
        _error = 'Failed to parse data: $e';
        _isLoading = false;
        notifyListeners();
      }
    });

    // ── Error listener ────────────────────────────────────────────────────────
    print('👂 [FRONTEND] Registering listener for "request-order-details-error"...');
    socket.on('request-order-details-error', (data) {
      print('═══════════════════════════════════════════════════════════');
      print('❌ [BACKEND] Error received on "request-order-details-error"');
      print('📥 [BACKEND] Raw error data: $data');
      print('═══════════════════════════════════════════════════════════');

      String errorMessage = 'Failed to fetch order details';

      if (data is String) {
        errorMessage = data;
      } else if (data is Map<String, dynamic>) {
        errorMessage = data['message']?.toString() ??
            data['error']?.toString() ??
            errorMessage;
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
    _currentOrderId = null; // ✅ Clear tracked orderId too
  }

  @override
  void dispose() {
    _clearListeners();
    _socketProvider = null;
    super.dispose();
  }
}