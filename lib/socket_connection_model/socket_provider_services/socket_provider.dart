import 'package:dinmajur_customer/socket_connection_model/socket_provider_services/socket_services.dart';
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
  SocketService get socketService => _socketService;

  // Callback for when socket is ready
  List<Function()> _onReadyCallbacks = [];

  /// Register callback to be called when socket is ready
  void onSocketReady(Function() callback) {
    _onReadyCallbacks.add(callback);
  }

  /// Remove callback
  void removeSocketReadyCallback(Function() callback) {
    _onReadyCallbacks.remove(callback);
  }

  /// Connect socket with access token
  Future<void> connectWithToken({required String accessToken}) async {
    try {
      _isConnecting = true;
      _connectionError = null;
      notifyListeners();
      // Initialize socket with access token
      await _socketService.initializeSocket(accessToken: accessToken);

      // Setup basic connection listeners
      _setupConnectionListeners();

      _isConnecting = false;
      notifyListeners();

    } catch (e) {
      _isConnecting = false;
      _connectionError = e.toString();
      _isConnected = false;
      notifyListeners();

    }
  }

  /// Setup basic connection event listeners
  void _setupConnectionListeners() {
    _socketService.socket?.on('connect', (_) {
      _isConnected = true;
      _connectionError = null;
      _lastActivity = DateTime.now().toString();
      notifyListeners();


      // ✅ Trigger all ready callbacks
      for (var callback in _onReadyCallbacks) {
        try {
          callback();
        } catch (e) {
        }
      }
    });

    _socketService.socket?.on('disconnect', (_) {
      _isConnected = false;
      _lastActivity = DateTime.now().toString();
      notifyListeners();

    });

    _socketService.socket?.on('connect_error', (error) {
      _isConnected = false;
      _connectionError = error.toString();
      _lastActivity = DateTime.now().toString();
      notifyListeners();

    });
  }

  /// Disconnect socket
  Future<void> disconnect() async {
    try {

      await _socketService.disconnect();

      _isConnected = false;
      _connectionError = null;
      _lastActivity = DateTime.now().toString();
      _onReadyCallbacks.clear();
      notifyListeners();

    } catch (e) {

      // Update state even on error
      _isConnected = false;
      _connectionError = e.toString();
      _onReadyCallbacks.clear();
      notifyListeners();
    }
  }

  /// Emit custom events
  void emit(String event, dynamic data) {
    if (_isConnected && _socketService.socket != null) {
      _socketService.socket!.emit(event, data);
      _lastActivity = DateTime.now().toString();
      notifyListeners();

    } else {
    }
  }

  /// Get socket status as string
  String get statusText {
    if (_isConnecting) return 'Connecting...';
    if (_isConnected) return 'Connected';
    if (_connectionError != null) return 'Error: $_connectionError';
    return 'Disconnected';
  }

  /// Get status color
  int get statusColor {
    if (_isConnecting) return 0xFFFFA726; // Orange
    if (_isConnected) return 0xFF4CAF50; // Green
    if (_connectionError != null) return 0xFFF44336; // Red
    return 0xFF9E9E9E; // Grey
  }

  /// Reconnect socket
  Future<void> reconnect() async {
    try {
      _isConnecting = true;
      _connectionError = null;
      notifyListeners();


      // Check if we can reconnect
      if (!_socketService.canReconnect()) {
        throw Exception('Cannot reconnect: Missing access token');
      }

      // Attempt reconnection
      await _socketService.reconnect();

      _isConnecting = false;
      notifyListeners();

    } catch (e) {
      _isConnecting = false;
      _connectionError = e.toString();
      _isConnected = false;
      notifyListeners();

      rethrow;
    }
  }

  /// Auto-reconnect with retry logic
  Future<void> autoReconnect({
    int maxRetries = 1,
    Duration delay = const Duration(seconds: 2),
  }) async {
    int retryCount = 0;

    while (retryCount < maxRetries && !_isConnected) {
      try {

        await reconnect();

        // Wait to check if connection is successful
        await Future.delayed(Duration(milliseconds: 500));

        if (_isConnected) {
          return;
        }

        retryCount++;
        if (retryCount < maxRetries) {
          await Future.delayed(delay);
        }
      } catch (e) {
        retryCount++;

        if (retryCount < maxRetries) {
          await Future.delayed(delay);
        }
      }
    }

    if (!_isConnected) {
      _connectionError = 'Failed to reconnect after $maxRetries attempts';
      notifyListeners();

    }
  }

  @override
  void dispose() {
    _onReadyCallbacks.clear();
    super.dispose();
  }
}