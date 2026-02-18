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
      // ✅ Save token BEFORE disconnect so canReconnect() stays true
      _accessToken = accessToken;

      // Completely destroy old socket first
      await disconnect();

      print("=============== SOCKET ACCESS TOKEN ========================= $accessToken");

      _socket = IO.io(
        AppUrl.socketUrl,
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .disableAutoConnect()
            .enableForceNew()
            .disableReconnection()
            .setAuth({'token': accessToken})
            .setTimeout(20000)
            .build(),
      );

      _setupSocketListeners();
      _socket!.connect();

      print('🔌 [SocketService] Clean socket initialized');
    } catch (e) {
      print('🔌 [SocketService] Initialization error: $e');
    }
  }

  /// Setup socket event listeners
  void _setupSocketListeners() {
    _socket!.onConnect((data) {
      _isConnected = true;
      if (kDebugMode) {
        print('-----------------------------------');
        print('🎉 [SocketService] Connected Successfully — id: ${_socket?.id}');
        print('-----------------------------------');
      }
      monitorConnection();
    });

    _socket!.onDisconnect((data) {
      _isConnected = false;
      if (kDebugMode) print('🔌 [SocketService] Disconnected: $data');
    });

    _socket!.onConnectError((error) {
      _isConnected = false;
      if (kDebugMode) print('🔌 [SocketService] Connection error: $error');
    });

    _socket!.onError((error) {
      if (kDebugMode) print('🔌 [SocketService] Error: $error');
    });
  }

  /// Monitor connection with ping/pong
  void monitorConnection() {
    _socket?.on('ping', (_) {
      if (kDebugMode) print('🔌 [SocketService] Ping received');
    });
    _socket?.on('pong', (_) {
      if (kDebugMode) print('🔌 [SocketService] Pong sent');
    });
  }

  void on(String event, Function(dynamic) callback) => _socket?.on(event, callback);
  void off(String event) => _socket?.off(event);

  void emit(String event, dynamic data) {
    if (_socket != null && _isConnected) {
      _socket!.emit(event, data);
      if (kDebugMode) print('🔌 [SocketService] Emitted: $event');
    }
  }

  /// Disconnect socket — does NOT wipe _accessToken so reconnect still works
  Future<void> disconnect() async {
    try {
      if (kDebugMode) {
        print('🔌 [SocketService] disconnect() — socket is ${_socket == null ? 'NULL' : 'LIVE'}');
      }

      if (_socket != null) {
        _socket!.disconnect();
        _socket!.dispose();
        _socket = null;
        if (kDebugMode) print('🔌 [SocketService] ✅ Socket destroyed');
      }

      _isConnected = false;

      if (kDebugMode) print('🔌 [SocketService] ✅ disconnect() complete');
    } catch (e) {
      if (kDebugMode) print('🔌 [SocketService] ⚠️ disconnect error: $e');
      // Still clean up state
      _socket = null;
      _isConnected = false;
    }
    // ✅ NOTE: _accessToken is intentionally NOT cleared here.
    // canReconnect() needs it to reinitialize the socket without
    // requiring the caller to pass the token again.
  }

  /// Reconnect socket
  Future<void> reconnect() async {
    try {
      if (kDebugMode) print('🔌 [SocketService] reconnect()');

      if (_socket != null && !_isConnected) {
        // Try to reconnect on existing socket instance
        _socket!.connect();
        if (kDebugMode) print('🔌 [SocketService] connect() called on existing socket');
      } else if (_accessToken != null) {
        // Socket was destroyed — reinitialize from saved token
        await initializeSocket(accessToken: _accessToken!);
        if (kDebugMode) print('🔌 [SocketService] Reinitialized from saved token');
      } else {
        if (kDebugMode) print('🔌 [SocketService] ❌ Cannot reconnect: no token and no socket');
      }
    } catch (e) {
      if (kDebugMode) print('🔌 [SocketService] reconnect error: $e');
      rethrow;
    }
  }

  /// True when we have a token and are not currently connected
  bool canReconnect() => _accessToken != null && !_isConnected;
}