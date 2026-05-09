import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:dinmajur_customer/configs/res/app_url.dart';

/// Single ChangeNotifier that owns the Socket.IO connection.
/// Replaces SocketProvider + SocketService entirely.
///
/// Key design points:
/// - Singleton: one socket for the entire app lifetime.
/// - [onConnected] is called by NavigationScreen for its own needs
///   AND can be overridden by TrackOrderViewModel temporarily.
///   To support multiple listeners without a full event-bus, we use
///   a private list internally and expose [addConnectedListener] /
///   [removeConnectedListener] for screens/VMs that need to react
///   to (re)connection events.
class SocketManager extends ChangeNotifier {
  static final SocketManager _instance = SocketManager._internal();
  factory SocketManager() => _instance;
  SocketManager._internal();

  IO.Socket? _socket;
  String? _accessToken;

  bool get isConnected => _socket?.connected ?? false;

  // ── Multiple onConnected subscribers ──────────────────────────────
  // NavigationScreen sets [onConnected] for backward-compat.
  // TrackOrderViewModel uses [addConnectedListener] so both can
  // coexist without overwriting each other.
  VoidCallback? onConnected;

  final List<VoidCallback> _connectedListeners = [];

  /// Register an additional callback that fires on every (re)connect.
  /// Safe to call multiple times with the same callback — deduplicated.
  void addConnectedListener(VoidCallback cb) {
    if (!_connectedListeners.contains(cb)) {
      _connectedListeners.add(cb);
      if (kDebugMode) {
        print('👂 SocketManager: connected-listener added (total: ${_connectedListeners.length})');
      }
    }
  }

  /// Remove a previously registered callback.
  void removeConnectedListener(VoidCallback cb) {
    _connectedListeners.remove(cb);
    if (kDebugMode) {
      print('🧹 SocketManager: connected-listener removed (total: ${_connectedListeners.length})');
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // CONNECT
  // ═══════════════════════════════════════════════════════════════════

  Future<void> connect(String accessToken) async {
    _accessToken = accessToken;
    _destroySocket();

    _socket = IO.io(
      AppUrl.socketUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .enableForceNew()
          .disableReconnection()      // we handle retry ourselves
          .setAuth({'token': accessToken})
          .setTimeout(20000)
          .build(),
    );

    _attachEvents();
    _socket!.connect();
  }

  // ═══════════════════════════════════════════════════════════════════
  // DISCONNECT  – clears token so retry loop stops (e.g. on logout)
  // ═══════════════════════════════════════════════════════════════════

  void disconnect() {
    if (kDebugMode) {
      print('-----------------------------------');
      print('🔌 SocketManager: disconnect called');
      print('-----------------------------------');
    }
    _accessToken = null; // stops auto-retry
    _destroySocket();
    notifyListeners();
  }

  // ═══════════════════════════════════════════════════════════════════
  // APP RESUME
  // ═══════════════════════════════════════════════════════════════════

  Future<void> handleAppResume() async {
    if (isConnected) {
      // Already connected — just notify all listeners so screens refresh
      _fireConnectedCallbacks();
    } else if (_accessToken != null) {
      await _reconnectWithRetry();
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // EMIT / ON / OFF
  // ═══════════════════════════════════════════════════════════════════

  void emit(String event, dynamic data) {
    if (isConnected) {
      _socket!.emit(event, data);
      // if (kDebugMode) print('📤 SocketManager: emit "$event"');
    } else {
      if (kDebugMode) {
        print('⚠️ SocketManager: cannot emit "$event" – not connected');
      }
    }
  }

  void on(String event, Function(dynamic) handler) =>
      _socket?.on(event, handler);
  void off(String event) => _socket?.off(event);

  // ═══════════════════════════════════════════════════════════════════
  // PRIVATE
  // ═══════════════════════════════════════════════════════════════════

  void _attachEvents() {
    _socket!.onConnect((_) {
      if (kDebugMode) {
        print('-----------------------------------');
        print('🎉 Socket Connected Successfully');
        // print('   Socket ID : ${_socket?.id}');
        print('-----------------------------------');
      }
      notifyListeners();
      _fireConnectedCallbacks();
    });

    _socket!.onDisconnect((_) {
      if (kDebugMode) {
        print('-----------------------------------');
        print('🔌 Socket Disconnected');
        print('-----------------------------------');
      }
      notifyListeners();
      if (_accessToken != null) _reconnectWithRetry();
    });

    _socket!.onConnectError((error) {
      if (kDebugMode) {
        print('-----------------------------------');
        print('❌ Socket Connection Error');
        print('   Error : $error');
        print('-----------------------------------');
      }
      notifyListeners();
    });
  }

  /// Fires [onConnected] + every listener in [_connectedListeners].
  void _fireConnectedCallbacks() {
    onConnected?.call();
    for (final cb in List<VoidCallback>.from(_connectedListeners)) {
      cb();
    }
  }

  Future<void> _reconnectWithRetry({
    int maxAttempts = 5,
    Duration gap = const Duration(seconds: 3),
  }) async {
    for (int attempt = 1; attempt <= maxAttempts; attempt++) {
      if (isConnected || _accessToken == null) return;

      if (kDebugMode) {
        print('🔄 SocketManager: reconnect attempt $attempt/$maxAttempts');
      }

      await Future.delayed(gap);
      if (isConnected || _accessToken == null) return;

      try {
        await connect(_accessToken!);
        await Future.delayed(const Duration(milliseconds: 1500));
        if (isConnected) {
          if (kDebugMode) {
            print('✅ SocketManager: reconnected on attempt $attempt');
          }
          return;
        }
      } catch (e) {
        if (kDebugMode) {
          print('❌ SocketManager: attempt $attempt failed – $e');
        }
      }
    }
    if (kDebugMode) {
      print('❌ SocketManager: gave up after $maxAttempts attempts');
    }
  }

  void _destroySocket() {
    if (_socket != null) {
      _socket!.disconnect();
      _socket!.dispose();
      _socket = null;
    }
  }

  @override
  void dispose() {
    _destroySocket();
    _connectedListeners.clear();
    super.dispose();
  }
}