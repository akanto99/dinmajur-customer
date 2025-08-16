import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketProvider extends ChangeNotifier {
  IO.Socket? _socket;

  IO.Socket? get socket => _socket;
  bool get isConnected => _socket?.connected ?? false;

  void connect() {
    if (_socket != null && _socket!.connected) {
      debugPrint("ℹ️ Already connected to WebSocket");
      return;
    }

    // আপনার API URL এবং পোর্ট সঠিকভাবে দিন
    _socket = IO.io(
      'https://api-staging.dinmajur.com',
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .enableForceNew()
          .build(),
    );

    _socket!.connect();

    _socket!.onConnect((_) {
      debugPrint('✅ WebSocket Connected');
      notifyListeners();
    });

    _socket!.onDisconnect((_) {
      debugPrint('❌ WebSocket Disconnected');
      notifyListeners();
    });

    _socket!.onError((data) {
      debugPrint('⚠️ WebSocket Error: $data');
    });

    _socket!.onConnectError((data) {
      debugPrint('🚫 WebSocket Connect Error: $data');
    });
  }

  void disconnect() {
    _socket?.disconnect();
    _socket = null;
    debugPrint("🔌 WebSocket Disconnected Manually");
    notifyListeners();
  }
}
