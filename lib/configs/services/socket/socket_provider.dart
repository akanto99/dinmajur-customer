// import 'package:flutter/foundation.dart';
// import 'package:socket_io_client/socket_io_client.dart' as IO;
//
// class SocketProvider extends ChangeNotifier {
//   IO.Socket? _socket;
//
//   IO.Socket? get socket => _socket;
//   bool get isConnected => _socket?.connected ?? false;
//
//   void connect() {
//     if (_socket != null && _socket!.connected) {
//       debugPrint("ℹ️ Already connected to WebSocket");
//       return;
//     }
//
//     // আপনার API URL এবং পোর্ট সঠিকভাবে দিন
//     _socket = IO.io(
//       'https://api-staging.dinmajur.com',
//       IO.OptionBuilder()
//           .setTransports(['websocket'])
//           .disableAutoConnect()
//           .enableForceNew()
//           .build(),
//     );
//
//     _socket!.connect();
//
//     _socket!.onConnect((_) {
//       debugPrint('✅ WebSocket Connected');
//       notifyListeners();
//     });
//
//     _socket!.onDisconnect((_) {
//       debugPrint('❌ WebSocket Disconnected');
//       notifyListeners();
//     });
//
//     _socket!.onError((data) {
//       debugPrint('⚠️ WebSocket Error: $data');
//     });
//
//     _socket!.onConnectError((data) {
//       debugPrint('🚫 WebSocket Connect Error: $data');
//     });
//   }
//
//   void disconnect() {
//     _socket?.disconnect();
//     _socket = null;
//     debugPrint("🔌 WebSocket Disconnected Manually");
//     notifyListeners();
//   }
// }
import 'package:dinmajur_customer/configs/services/socket/socket_services.dart';
import 'package:flutter/foundation.dart';

class SocketProvider with ChangeNotifier {
  final SocketService _socketService = SocketService();

  bool _isConnected = false;
  bool _isConnecting = false;
  String? _connectionError;
  String? _lastActivity;

  // Getters
  bool get isConnected => _isConnected;
  bool get isConnecting => _isConnecting;
  String? get connectionError => _connectionError;
  String? get lastActivity => _lastActivity;

  // Connect socket with user credentials
  Future<void> connectWithUser({
    required String userId,
    required String role,
  }) async {
    try {
      _isConnecting = true;
      _connectionError = null;
      notifyListeners();

      // Initialize socket with user credentials
      await _socketService.initializeSocket(
        userId: userId,
        userRole: role,
      );

      // Setup socket event listeners
      _setupSocketListeners();

      _isConnecting = false;
      notifyListeners();

      if (kDebugMode) {
        print('🔌 Socket Provider: Connected with user $userId, role: $role');
      }

    } catch (e) {
      _isConnecting = false;
      _connectionError = e.toString();
      _isConnected = false;
      notifyListeners();

      if (kDebugMode) {
        print('🔌 Socket Provider: Connection failed - $e');
      }
    }
  }

  // Setup socket event listeners
  void _setupSocketListeners() {
    // Listen for connection status
    _socketService.socket?.on('connect', (_) {
      _isConnected = true;
      _connectionError = null;
      _lastActivity = DateTime.now().toString();
      notifyListeners();

      if (kDebugMode) {
        print('🔌 Socket Provider: Connected successfully');
      }
    });

    _socketService.socket?.on('disconnect', (_) {
      _isConnected = false;
      _lastActivity = DateTime.now().toString();
      notifyListeners();

      if (kDebugMode) {
        print('🔌 Socket Provider: Disconnected');
      }
    });

    _socketService.socket?.on('connect_error', (error) {
      _isConnected = false;
      _connectionError = error.toString();
      _lastActivity = DateTime.now().toString();
      notifyListeners();

      if (kDebugMode) {
        print('🔌 Socket Provider: Connection error - $error');
      }
    });

    // Listen for user registration confirmation
    _socketService.socket?.on('user-registered', (data) {
      _lastActivity = DateTime.now().toString();
      notifyListeners();

      if (kDebugMode) {
        print('🔌 Socket Provider: User registered successfully - $data');
      }
    });

    // Listen for user unregistration confirmation
    _socketService.socket?.on('user-unregistered', (data) {
      _lastActivity = DateTime.now().toString();
      notifyListeners();

      if (kDebugMode) {
        print('🔌 Socket Provider: User unregistered successfully - $data');
      }
    });

    // Listen for delivery-related events
    _socketService.socket?.on('deliveryRequest', (data) {
      _lastActivity = DateTime.now().toString();
      notifyListeners();

      if (kDebugMode) {
        print('🔌 Socket Provider: Delivery request received - $data');
      }
    });

    _socketService.socket?.on('deliveryAccepted', (data) {
      _lastActivity = DateTime.now().toString();
      notifyListeners();

      if (kDebugMode) {
        print('🔌 Socket Provider: Delivery accepted - $data');
      }
    });

    _socketService.socket?.on('deliveryTaken', (data) {
      _lastActivity = DateTime.now().toString();
      notifyListeners();

      if (kDebugMode) {
        print('🔌 Socket Provider: Delivery taken - $data');
      }
    });
  }

  // Unregister user and disconnect socket
  Future<void> unregisterAndDisconnect({
    required String userId,
    required String role,
  }) async {
    try {
      if (_socketService.socket != null && _isConnected) {
        // Emit unregister-user event
        _socketService.socket!.emit('unregister-user', {
          'userId': userId,
          'role': role,
        });

        if (kDebugMode) {
          print('🔌 Socket Provider: Unregistering user $userId');
        }

        // Wait a moment for the server to process
        await Future.delayed(Duration(milliseconds: 500));
      }

      // Disconnect socket
      await _socketService.disconnect();

      _isConnected = false;
      _connectionError = null;
      _lastActivity = DateTime.now().toString();
      notifyListeners();

      if (kDebugMode) {
        print('🔌 Socket Provider: User unregistered and disconnected');
      }

    } catch (e) {
      _connectionError = e.toString();
      notifyListeners();

      if (kDebugMode) {
        print('🔌 Socket Provider: Unregister/disconnect failed - $e');
      }
    }
  }

  // Force disconnect socket
  Future<void> disconnect() async {
    try {
      await _socketService.disconnect();
      _isConnected = false;
      _connectionError = null;
      _lastActivity = DateTime.now().toString();
      notifyListeners();

      if (kDebugMode) {
        print('🔌 Socket Provider: Force disconnected');
      }

    } catch (e) {
      _connectionError = e.toString();
      notifyListeners();

      if (kDebugMode) {
        print('🔌 Socket Provider: Force disconnect failed - $e');
      }
    }
  }

  // Reconnect socket
  Future<void> reconnect() async {
    try {
      await _socketService.reconnect();
      _setupSocketListeners();

      if (kDebugMode) {
        print('🔌 Socket Provider: Reconnected');
      }

    } catch (e) {
      _connectionError = e.toString();
      _isConnected = false;
      notifyListeners();

      if (kDebugMode) {
        print('🔌 Socket Provider: Reconnection failed - $e');
      }
    }
  }

  // Emit custom events
  void emit(String event, dynamic data) {
    if (_isConnected) {
      _socketService.emit(event, data);
      _lastActivity = DateTime.now().toString();
      notifyListeners();
    }
  }

  // Listen to custom events
  void on(String event, Function(dynamic) callback) {
    _socketService.on(event, (data) {
      _lastActivity = DateTime.now().toString();
      notifyListeners();
      callback(data);
    });
  }

  // Get socket status as string
  String get statusText {
    if (_isConnecting) return 'Connecting...';
    if (_isConnected) return 'Connected';
    if (_connectionError != null) return 'Error: $_connectionError';
    return 'Disconnected';
  }

  // Get status color
  int get statusColor {
    if (_isConnecting) return 0xFFFFA726; // Orange
    if (_isConnected) return 0xFF4CAF50; // Green
    if (_connectionError != null) return 0xFFF44336; // Red
    return 0xFF9E9E9E; // Grey
  }
}