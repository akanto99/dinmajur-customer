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

    } catch (e) {
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
    });

    _socket!.onConnectError((error) {
      _isConnected = false;
    });

    _socket!.onError((error) {
    });
  }

  /// Monitor connection with ping/pong
  void monitorConnection() {
    _socket?.on('ping', (_) {
    });
    _socket?.on('pong', (_) {
    });
  }

  void on(String event, Function(dynamic) callback) => _socket?.on(event, callback);
  void off(String event) => _socket?.off(event);

  void emit(String event, dynamic data) {
    if (_socket != null && _isConnected) {
      _socket!.emit(event, data);
    }
  }

  /// Disconnect socket — does NOT wipe _accessToken so reconnect still works
  Future<void> disconnect() async {
    try {

      if (_socket != null) {
        _socket!.disconnect();
        _socket!.dispose();
        _socket = null;
      }

      _isConnected = false;

    } catch (e) {
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

      if (_socket != null && !_isConnected) {
        // Try to reconnect on existing socket instance
        _socket!.connect();
      } else if (_accessToken != null) {
        // Socket was destroyed — reinitialize from saved token
        await initializeSocket(accessToken: _accessToken!);
      } else {
      }
    } catch (e) {
      rethrow;
    }
  }

  /// True when we have a token and are not currently connected
  bool canReconnect() => _accessToken != null && !_isConnected;
}