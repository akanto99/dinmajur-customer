///Customer


import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter/foundation.dart';

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  IO.Socket? _socket;
  bool _isConnected = false;
  String? _userId;

  // Getters
  bool get isConnected => _isConnected;
  IO.Socket? get socket => _socket;

  // Initialize socket connection
  Future<void> initializeSocket({required String userId}) async {
    try {
      _userId = userId;

      // Disconnect existing connection if any
      if (_socket != null) {
        await disconnect();
      }

      // Create socket connection
      _socket = IO.io(
        'https://api-staging.dinmajur.com',
        // 'https://api.dinmajur.com',
      //   IO.OptionBuilder().setTransports(['websocket'])
      //       .enableAutoConnect()
      //       .enableForceNew()
      //       .setReconnectionAttempts(10)
      //       .setReconnectionDelay(5000)
      //       .setReconnectionDelayMax(10000)
      //       .setExtraHeaders({'Accept': 'application/json', 'Content-Type': 'application/json'}).build(),
      // );
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .enableAutoConnect()
            .disableForceNew()
            .setReconnectionAttempts(10)
            .setReconnectionDelay(1000)
            .setReconnectionDelayMax(5000)
            .enableReconnection()
            .setTimeout(20000)
            .setExtraHeaders({'Accept': 'application/json', 'Content-Type': 'application/json'}).build(),

      );
      _setupSocketListeners();

      // Connect to socket
      _socket!.connect();

      if (kDebugMode) {
        print('🔌 Socket initialization started for user: $userId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('🔌 Socket initialization error: $e');
      }
    }
  }

  // Setup socket event listeners
  void _setupSocketListeners() {
    _socket!.onConnect((data) {
      _isConnected = true;
      if (kDebugMode) {
        print('🔌 Socket connected successfully');
      }
      monitorConnection();

      // Register user after connection
      if (_userId != null) {
        registerUser(_userId!);
      }
    });

    _socket!.onDisconnect((data) {
      _isConnected = false;
      if (kDebugMode) {
        print('🔌 Socket disconnected: $data');
      }
    });

    _socket!.onConnectError((error) {
      _isConnected = false;
      if (kDebugMode) {
        print('🔌 Socket connection error: $error');
      }
    });

    _socket!.onError((error) {
      if (kDebugMode) {
        print('🔌 Socket error: $error');
      }
    });
  }

  // Monitor connection with ping/pong
  void monitorConnection() {
    if (_socket != null) {
      _socket!.on('ping', (_) {
        if (kDebugMode) {
          print('🔌 Socket: Ping received - connection alive');
        }
      });

      _socket!.on('pong', (_) {
        if (kDebugMode) {
          print('🔌 Socket: Pong sent - connection alive');
        }
      });
    }
  }

  // Register user with the socket server
  void registerUser(String userId) {
    if (_socket != null && _isConnected) {
      _socket!.emit('register-user', {'userId': userId});

      if (kDebugMode) {
        print('🔌 User registration sent - userId: $userId');
      }
    }
  }

  // Custom event listener
  void on(String event, Function(dynamic) callback) {
    _socket?.on(event, callback);
  }

  // Remove event listener
  void off(String event) {
    _socket?.off(event);
  }

  // Emit custom events
  void emit(String event, dynamic data) {
    if (_socket != null && _isConnected) {
      _socket!.emit(event, data);

      if (kDebugMode) {
        print('🔌 Emitted event: $event');
      }
    }
  }

  // Disconnect socket
  Future<void> disconnect() async {
    try {
      if (_socket != null) {
        _socket!.disconnect();
        _socket!.dispose();
        _socket = null;
        _isConnected = false;

        if (kDebugMode) {
          print('🔌 Socket disconnected');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('🔌 Error during disconnect: $e');
      }
    } finally {
      _isConnected = false;
      _userId = null;
    }
  }

  // Reconnect to socket
  Future<void> reconnect() async {
    try {
      if (kDebugMode) {
        print('🔌 Attempting to reconnect socket...');
      }

      // If socket exists but disconnected, try to connect
      if (_socket != null && !_isConnected) {
        _socket!.connect();

        if (kDebugMode) {
          print('🔌 Reconnect initiated for existing socket');
        }
      }
      // If socket is null, reinitialize with previous credentials
      else if (_socket == null && _userId != null) {
        await initializeSocket(userId: _userId!);

        if (kDebugMode) {
          print('🔌 Socket reinitialized with userId: $_userId');
        }
      } else {
        if (kDebugMode) {
          print('🔌 Cannot reconnect: Missing credentials or socket already connected');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('🔌 Reconnect error: $e');
      }
      rethrow;
    }
  }

  // Check if reconnection is possible
  bool canReconnect() {
    return _userId != null && !_isConnected;
  }
}
