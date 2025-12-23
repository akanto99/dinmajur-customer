import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../../model/home_models/socket_home_model/socket_get_all_orders_model/socket_get_allorders_model.dart';
import '../../../socket_provider_services/socket_provider.dart';

class OrderSocketProvider with ChangeNotifier {
  SocketProvider? _socketProvider;
  bool _listenerSetup = false;

  // String? _userId;
  // String? get userId => _userId;

  // Retry logic
  Timer? _retryTimer;
  int _retryCount = 0;
  static const int _maxRetries = 10;
  static const Duration _retryDelay = Duration(seconds: 2);
  static const Duration _initialDataTimeout = Duration(seconds: 10);

  // Order-specific data
  List<Datum> _retailerOrders = [];
  bool _isLoadingOrders = true;
  String? _ordersError;

  bool _hasReceivedInitialData = false;

  // Getters
  List<Datum> get retailerOrders => _retailerOrders;
  bool get isLoadingOrders => _isLoadingOrders;
  String? get ordersError => _ordersError;
  bool get isSocketConnected => _socketProvider?.isConnected ?? false;
  int get ordersCount => _retailerOrders.length;
  bool get hasOrders => _retailerOrders.isNotEmpty;
  bool get isListenerSetup => _listenerSetup;

  /// ✅ Initialize socket connection and load userId automatically
  Future<void> initializeWithRetry(SocketProvider socketProvider) async {
    if (_listenerSetup) {
      if (kDebugMode) print('📦 Get All Order: Listener already setup');
      return;
    }

    // final SharedPreferences sp = await SharedPreferences.getInstance();
    // _userId = sp.getString('userId');
    //
    // if (_userId == null || _userId!.isEmpty) {
    //   _ordersError = 'User ID not found. Please auth_login again.';
    //   _isLoadingOrders = false;
    //   notifyListeners();
    //   if (kDebugMode) print('📦 Get All Order: ❌ No userId found in SharedPreferences');
    //   return;
    // }

    if (_retryCount >= _maxRetries) {
      _ordersError = 'Max retries reached. Please check your connection.';
      _isLoadingOrders = false;
      notifyListeners();
      if (kDebugMode) print('📦 Get All Order: Max retries reached, stopping...');
      return;
    }

    try {
      _socketProvider = socketProvider;

      if (!socketProvider.isConnected) {
        _retryCount++;
        if (kDebugMode) {
          print(
              '📦 Get All Order: Socket not connected yet (attempt $_retryCount/$_maxRetries), retrying...');
        }

        _retryTimer?.cancel();
        _retryTimer = Timer(_retryDelay, () {
          initializeWithRetry(socketProvider);
        });
        return;
      }

      _setupSocketListener();
      _retryCount = 0;
      _listenerSetup = true;

      if (kDebugMode) print('📦 Get All Order: ✅ Socket setup complete for user _userId');
    } catch (e) {
      _retryCount++;
      if (kDebugMode) {
        print('📦 Get All Order: Setup error (attempt $_retryCount/$_maxRetries) - $e');
      }

      if (_retryCount < _maxRetries) {
        _retryTimer?.cancel();
        _retryTimer = Timer(_retryDelay, () {
          initializeWithRetry(socketProvider);
        });
      } else {
        _ordersError = 'Failed to connect after $_maxRetries attempts';
        _isLoadingOrders = false;
        notifyListeners();
      }
    }
  }

  /// ✅ Setup socket listener
  void _setupSocketListener() {
    if (_socketProvider?.socketService.socket == null
        // || _userId == null
    ) {
      if (kDebugMode) print('📦 Get All Order: Cannot setup listener - socket or userId is null');
      return;
    }

    final eventName = 'retailer-orders-summary';
        // '-$_userId';

    // Remove any existing listener
    _socketProvider!.socketService.socket!.off(eventName);

    // Listen for user-specific retailer orders
    _socketProvider!.socketService.socket!.on(eventName, (data) {
      if (kDebugMode) {
        print('📦 Get All Order: 🔥 NEW DATA RECEIVED for $eventName');
      }

      _hasReceivedInitialData = true;
      _handleOrdersData(data);
    });

    if (kDebugMode) {
      print('📦 Get All Order: ✅ Listening to $eventName...');
    }

    Future.delayed(_initialDataTimeout, () {
      if (_isLoadingOrders && !_hasReceivedInitialData) {
        _isLoadingOrders = false;
        if (kDebugMode)
          print('📦 Get All Order: Initial data timeout - no data received for _userId');
        notifyListeners();
      }
    });
  }

  void _handleOrdersData(dynamic data) {
    try {
      if (kDebugMode) {
        print('📦 Get All Order: 🔄 Processing new orders data for _userId');
        print('📦 Raw data: ${data.toString()}');
      }

      List<dynamic> ordersList = [];

      if (data is List) {
        ordersList = data;
      } else if (data is Map) {
        if (data.containsKey('data')) {
          var innerData = data['data'];
          if (innerData is List) {
            ordersList = innerData;
          } else if (innerData is Map && innerData.containsKey('data')) {
            var deepData = innerData['data'];
            ordersList = deepData is List ? deepData : [deepData];
          } else {
            ordersList = [innerData];
          }
        } else if (data.containsKey('orders')) {
          var orders = data['orders'];
          ordersList = orders is List ? orders : [orders];
        } else {
          ordersList = [data];
        }
      } else if (data != null) {
        ordersList = [data];
      }

      final newOrders = ordersList.map((item) {
        try {
          if (item is Map<String, dynamic>) {
            return Datum.fromJson(item);
          } else if (item is Map) {
            return Datum.fromJson(Map<String, dynamic>.from(item));
          }
          return null;
        } catch (e) {
          if (kDebugMode) print('📦 Get All Order: Error parsing item - $e');
          return null;
        }
      }).whereType<Datum>().toList();

      _retailerOrders = newOrders;
      _isLoadingOrders = false;
      _ordersError = null;

      if (kDebugMode) {
        print('📦 Get All Order: ✅ Updated ${_retailerOrders.length} orders for _userId');
      }

      notifyListeners();
    } catch (e) {
      _ordersError = 'Error processing orders: $e';
      _isLoadingOrders = false;
      notifyListeners();

      if (kDebugMode) {
        print('📦 Get All Order: ❌ Handle data error - $e');
      }
    }
  }

  // Utility methods
  void clearOrdersData() {
    _retailerOrders = [];
    _isLoadingOrders = false;
    _ordersError = null;
    _hasReceivedInitialData = false;
    notifyListeners();
    if (kDebugMode) print('📦 Get All Order: Orders data cleared');
  }

  List<Datum> getRecentOrders({int count = 3}) {
    return _retailerOrders.take(count).toList();
  }

  void refreshOrders() {
    if (kDebugMode) print('📦 Get All Order: Manual refresh requested...');
  }

  void resetRetryCount() {
    _retryCount = 0;
    _ordersError = null;
  }

  void cleanupListener() {
    _retryTimer?.cancel();
    _retryTimer = null;

    if (_socketProvider?.socketService.socket != null
        // && _userId != null
    ) {
      final eventName = 'retailer-orders-summary';
      _socketProvider!.socketService.socket!.off(eventName);
    }

    _listenerSetup = false;
    _retryCount = 0;
    _hasReceivedInitialData = false;

    if (kDebugMode) print('📦 Get All Order: Listener cleaned up for _userId');
  }

  @override
  void dispose() {
    cleanupListener();
    super.dispose();
    if (kDebugMode) print('📦 Get All Order: Provider disposed');
  }
}
