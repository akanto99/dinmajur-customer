import 'package:flutter/foundation.dart';
import '../../../../model/home_models/socket_home_model/socket_get_all_orders_model/socket_orderdetails_model.dart';
import '../../../socket_provider_services/socket_provider.dart';

class OrderDetailsSocketProvider with ChangeNotifier {
  SocketProvider? _socketProvider;

  // Order Details State
  OrderDetailsModel? _orderDetailsModel;
  bool _isLoadingOrderDetails = false;
  String? _orderDetailsError;
  Function(OrderDetailsModel)? _orderDetailsListener;
  Function(String)? _orderDetailsErrorListener;

  // Instance tracking
  String? _currentOrderId;
  bool _listenersInitialized = false;
  String? _lastSocketId;

  // Getters - Updated for new model structure
  OrderDetailsModel? get orderDetailsModel => _orderDetailsModel;
  Retailer? get retailerData => orderDetailsModel?.retailer;
  Freelancer? get freelancerData => orderDetailsModel?.freelancer;
  Delivery? get deliveryData => orderDetailsModel?.delivery;
  bool get isLoadingOrderDetails => _isLoadingOrderDetails;
  String? get orderDetailsError => _orderDetailsError;
  String? get currentOrderId => _currentOrderId;


  void initializeWithSocketProvider(SocketProvider socketProvider) {
    String? newSocketId = socketProvider.socketService.socket?.id;
    bool isNewConnection = _lastSocketId != newSocketId && newSocketId != null;

    if (isNewConnection || _socketProvider != socketProvider) {
      _fullReset();
      _socketProvider = socketProvider;
      _lastSocketId = newSocketId;
      _setupOrderDetailsListeners();
      _listenersInitialized = true;
    } else if (_listenersInitialized) {
      return;
    } else {
      _socketProvider = socketProvider;
      _setupOrderDetailsListeners();
      _listenersInitialized = true;
    }
  }

  void _fullReset() {
    _cleanupSocketListeners();
    _orderDetailsModel = null;
    _isLoadingOrderDetails = false;
    _orderDetailsError = null;
    _currentOrderId = null;
    _orderDetailsListener = null;
    _orderDetailsErrorListener = null;
    _listenersInitialized = false;
  }

  void setOrderDetailsListener(Function(OrderDetailsModel) listener) {
    _orderDetailsListener = listener;
  }

  void setOrderDetailsErrorListener(Function(String) listener) {
    _orderDetailsErrorListener = listener;
  }

  void clearOrderDetailsListeners() {
    _orderDetailsListener = null;
    _orderDetailsErrorListener = null;
  }

  void _cleanupSocketListeners() {
    if (_socketProvider?.socketService.socket != null && _listenersInitialized) {
      try {
        _socketProvider!.socketService.socket!.off('get-order-details');
        _socketProvider!.socketService.socket!.off('request-order-details-error');
        _socketProvider!.socketService.socket!.off('error');
        _socketProvider!.socketService.socket!.offAny();
      } catch (e) {
        // Handle cleanup error silently
      }
    }
    _listenersInitialized = false;
  }

  Future<void> viewOrderDetails(String orderId) async {
    try {
      if (_socketProvider?.socketService.socket == null || !_socketProvider!.isConnected) {
        throw Exception('Socket not connected');
      }

      if (orderId.isEmpty || orderId == 'N/A') {
        throw Exception('Invalid order ID: $orderId');
      }

      if (!_listenersInitialized) {
        _setupOrderDetailsListeners();
        _listenersInitialized = true;
        await Future.delayed(Duration(milliseconds: 100));
      }

      if (_isLoadingOrderDetails && _currentOrderId == orderId) {
        return;
      }

      _currentOrderId = orderId;
      _isLoadingOrderDetails = true;
      _orderDetailsError = null;
      notifyListeners();

      _socketProvider!.socketService.socket!.emit('request-order-details', {
        'orderId': orderId,
      });
    } catch (e) {
      _isLoadingOrderDetails = false;
      _orderDetailsError = e.toString();
      _currentOrderId = null;
      _orderDetailsErrorListener?.call(e.toString());
      notifyListeners();
    }
  }

  void _setupOrderDetailsListeners() {
    if (_socketProvider?.socketService.socket == null) {
      return;
    }
    _socketProvider!.socketService.socket!.off('get-order-details');
    _socketProvider!.socketService.socket!.off('request-order-details-error');
    _socketProvider!.socketService.socket!.off('error');

    _socketProvider!.socketService.socket!.on('get-order-details', (data) {
      try {
        print('==================== RAW SOCKET RESPONSE ====================');
        print('Response Type: ${data.runtimeType}');
        print('Response Data: $data');
        print('============================================================');
        if (data != null) {
          OrderDetailsModel orderDetailsModel = _parseSocketResponse(data);
          String? receivedOrderId = orderDetailsModel.order?.id;

          if (_currentOrderId != null && receivedOrderId != null && receivedOrderId != _currentOrderId) {
            return;
          }

          _orderDetailsModel = orderDetailsModel;
          _isLoadingOrderDetails = false;
          _orderDetailsError = null;
          _orderDetailsListener?.call(_orderDetailsModel!);
          notifyListeners();
        } else {
          throw Exception('Received null data for OrderDetails');
        }
      } catch (e) {
        _isLoadingOrderDetails = false;
        _orderDetailsError = 'Failed to parse order details: $e';
        _orderDetailsErrorListener?.call(_orderDetailsError!);
        notifyListeners();
      }
    });

    _socketProvider!.socketService.socket!.on('error', (data) {
      try {
        if (data != null && _isLoadingOrderDetails) {
          String errorMessage = 'Socket error occurred';

          if (data is String) {
            errorMessage = data;
          } else if (data is Map<String, dynamic>) {
            if (data['message'] != null) {
              errorMessage = data['message'].toString();
            } else if (data['error'] != null) {
              errorMessage = data['error'].toString();
            }
          }

          _isLoadingOrderDetails = false;
          _orderDetailsError = errorMessage;
          _currentOrderId = null;
          _orderDetailsErrorListener?.call(errorMessage);
          notifyListeners();
        }
      } catch (e) {
        // Handle error silently
      }
    });

    _socketProvider!.socketService.socket!.on('request-order-details-error', (data) {
      try {
        String errorMessage = 'Unknown error occurred';

        if (data != null) {
          if (data is String) {
            errorMessage = data;
          } else if (data is Map<String, dynamic> && data['message'] != null) {
            errorMessage = data['message'].toString();
          } else if (data is Map<String, dynamic> && data['error'] != null) {
            errorMessage = data['error'].toString();
          }
        }

        _isLoadingOrderDetails = false;
        _orderDetailsError = errorMessage;
        _currentOrderId = null;
        _orderDetailsErrorListener?.call(errorMessage);
        notifyListeners();
      } catch (e) {
        // Handle error silently
      }
    });
  }

  OrderDetailsModel _parseSocketResponse(dynamic data) {
    try {
      Map<String, dynamic> responseData;

      if (data is Map<String, dynamic>) {
        // Check if data already has the correct structure (order, retailer, freelancer, delivery)
        if (data.containsKey('order') && data.containsKey('retailer')) {
          responseData = data;
        }
        // If data is wrapped in another structure
        else if (data.containsKey('data')) {
          responseData = data['data'];
        }
        else {
          throw Exception('Invalid response structure from socket');
        }
      } else {
        throw Exception('Invalid data format received from socket');
      }

      return OrderDetailsModel.fromJson(responseData);
    } catch (e) {
      if (kDebugMode) {
        print('🔌 Parse error: $e');
      }
      throw Exception('Failed to parse order details: $e');
    }
  }

  void onUserLogout() {
    _fullReset();
    notifyListeners();
  }

  void clearOrderDetailsData() {
    _orderDetailsModel = null;
    _isLoadingOrderDetails = false;
    _orderDetailsError = null;
    _currentOrderId = null;
    notifyListeners();
  }

  bool isLoadingOrder(String orderId) {
    return _isLoadingOrderDetails && _currentOrderId == orderId;
  }

  OrderDetailsModel? getCachedOrderDetails(String orderId) {
    if (_currentOrderId == orderId && _orderDetailsModel != null) {
      return _orderDetailsModel;
    }
    return null;
  }

  void reset() {
    _cleanupSocketListeners();
    _orderDetailsModel = null;
    _isLoadingOrderDetails = false;
    _orderDetailsError = null;
    _currentOrderId = null;
    _orderDetailsListener = null;
    _orderDetailsErrorListener = null;
    _listenersInitialized = false;
    _lastSocketId = null;
    _socketProvider = null;
    notifyListeners();

    print('🔄 OrderDetailsSocketProvider fully reset');
  }

  @override
  void dispose() {
    _cleanupSocketListeners();
    clearOrderDetailsListeners();
    clearOrderDetailsData();
    _socketProvider = null;
    _lastSocketId = null;
    super.dispose();
  }
}