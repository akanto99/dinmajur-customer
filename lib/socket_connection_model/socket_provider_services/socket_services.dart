import 'package:dinmajur_customer/configs/res/app_url.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter/foundation.dart';

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  IO.Socket? _socket;
  bool _isConnected = false;
  String? _accessToken;

  // Getters
  bool get isConnected => _isConnected;
  IO.Socket? get socket => _socket;

  /// Initialize socket connection with access token
  Future<void> initializeSocket({required String accessToken}) async {
    try {
      _accessToken = accessToken;

      // Disconnect existing connection if any
      if (_socket != null) {
        await disconnect();
      }

      // Create socket connection with access token in headers
      _socket = IO.io(
        "${AppUrl.socketUrl}",
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .enableAutoConnect()
            .disableForceNew()
            .setReconnectionAttempts(10)
            .setReconnectionDelay(1000)
            .setReconnectionDelayMax(5000)
            .enableReconnection()
            .setTimeout(20000)
            .setExtraHeaders({
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken', // ✅ Pass token in header
        })
            .build(),
      );

      _setupSocketListeners();

      // Connect to socket
      _socket!.connect();

      if (kDebugMode) {
        print('🔌 Socket initialization started with token');
      }
    } catch (e) {
      if (kDebugMode) {
        print('🔌 Socket initialization error: $e');
      }
    }
  }

  /// Setup socket event listeners
  void _setupSocketListeners() {
    _socket!.onConnect((data) {
      _isConnected = true;

      if (kDebugMode) {
        print('-----------------------------------');
        print('🎉 Socket Connected Successfully');
        print('-----------------------------------');
      }

      monitorConnection();
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

  /// Monitor connection with ping/pong
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

  /// Custom event listener
  void on(String event, Function(dynamic) callback) {
    _socket?.on(event, callback);
  }

  /// Remove event listener
  void off(String event) {
    _socket?.off(event);
  }

  /// Emit custom events
  void emit(String event, dynamic data) {
    if (_socket != null && _isConnected) {
      _socket!.emit(event, data);

      if (kDebugMode) {
        print('🔌 Emitted event: $event');
      }
    }
  }

  /// Disconnect socket
  Future<void> disconnect() async {
    try {
      if (kDebugMode) {
        print('🔌 SocketService: disconnect() called');
        print('🔌 SocketService: _socket is ${_socket == null ? 'NULL' : 'NOT NULL'}');
        print('🔌 SocketService: _isConnected = $_isConnected');
      }

      if (_socket != null) {
        if (kDebugMode) {
          print('🔌 SocketService: Calling socket.disconnect()...');
        }

        // Disconnect the socket
        _socket!.disconnect();

        if (kDebugMode) {
          print('🔌 SocketService: ✅ socket.disconnect() called successfully');
          print('🔌 SocketService: Calling socket.dispose()...');
        }

        // Dispose the socket
        _socket!.dispose();

        if (kDebugMode) {
          print('🔌 SocketService: ✅ socket.dispose() called successfully');
        }

        // Clear socket reference
        _socket = null;

        if (kDebugMode) {
          print('🔌 SocketService: ✅ Socket reference set to null');
        }
      } else {
        if (kDebugMode) {
          print('🔌 SocketService: Socket was already null, nothing to disconnect');
        }
      }

      // Update connection state
      _isConnected = false;

      if (kDebugMode) {
        print('🔌 SocketService: ✅✅✅ Socket disconnected successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('🔌 SocketService: ⚠️ Error during disconnect: $e');
      }
    } finally {
      // Ensure state is cleared even if error occurs
      _isConnected = false;
      _accessToken = null;

      if (kDebugMode) {
        print('🔌 SocketService: Cleanup completed in finally block');
        print('🔌 SocketService: Final state - _socket: ${_socket == null ? 'NULL' : 'NOT NULL'}, _isConnected: $_isConnected');
      }
    }
  }

  /// Reconnect to socket
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
      // If socket is null, reinitialize with previous token
      else if (_socket == null && _accessToken != null) {
        await initializeSocket(accessToken: _accessToken!);

        if (kDebugMode) {
          print('🔌 Socket reinitialized with access token');
        }
      } else {
        if (kDebugMode) {
          print('🔌 Cannot reconnect: Missing token or socket already connected');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('🔌 Reconnect error: $e');
      }
      rethrow;
    }
  }

  /// Check if reconnection is possible
  bool canReconnect() {
    return _accessToken != null && !_isConnected;
  }
}