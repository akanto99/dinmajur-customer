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

  /// Connect socket with user credentials
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

      // Setup basic connection listeners
      _setupConnectionListeners();

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

  /// Setup basic connection event listeners
  void _setupConnectionListeners() {
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

    // User registration/unregistration confirmations
    _socketService.socket?.on('register-user', (data) {
      _lastActivity = DateTime.now().toString();
      notifyListeners();

      if (kDebugMode) {
        print('🔌 Socket Provider: User registered successfully - $data');
      }
    });

    _socketService.socket?.on('unregister-user', (data) {
      _lastActivity = DateTime.now().toString();
      notifyListeners();

      if (kDebugMode) {
        print('🔌 Socket Provider: User unregistered successfully - $data');
      }
    });
  }

  /// Unregister user and disconnect socket
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

        // Wait for server to process
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

  /// Force disconnect socket
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



  /// Emit custom events
  void emit(String event, dynamic data) {
    if (_isConnected && _socketService.socket != null) {
      _socketService.socket!.emit(event, data);
      _lastActivity = DateTime.now().toString();
      notifyListeners();
    }
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


  /// Reconnect socket
  Future<void> reconnect() async {
    try {
      _isConnecting = true;
      _connectionError = null;
      notifyListeners();

      if (kDebugMode) {
        print('🔌 Socket Provider: Attempting reconnection...');
      }

      // Check if we can reconnect
      if (!_socketService.canReconnect()) {
        throw Exception('Cannot reconnect: Missing user credentials');
      }

      // Attempt reconnection
      await _socketService.reconnect();

      _isConnecting = false;
      notifyListeners();

      if (kDebugMode) {
        print('🔌 Socket Provider: Reconnection attempt completed');
      }

    } catch (e) {
      _isConnecting = false;
      _connectionError = e.toString();
      _isConnected = false;
      notifyListeners();

      if (kDebugMode) {
        print('🔌 Socket Provider: Reconnection failed - $e');
      }
      rethrow;
    }
  }

  /// Auto-reconnect with retry logic
  Future<void> autoReconnect({int maxRetries = 3, Duration delay = const Duration(seconds: 2)}) async {
    int retryCount = 0;

    while (retryCount < maxRetries && !_isConnected) {
      try {
        if (kDebugMode) {
          print('🔌 Socket Provider: Auto-reconnect attempt ${retryCount + 1}/$maxRetries');
        }

        await reconnect();

        // Wait a bit to check if connection is successful
        await Future.delayed(Duration(milliseconds: 500));

        if (_isConnected) {
          if (kDebugMode) {
            print('🔌 Socket Provider: Auto-reconnect successful');
          }
          return;
        }

        retryCount++;

        if (retryCount < maxRetries) {
          await Future.delayed(delay);
        }

      } catch (e) {
        retryCount++;

        if (kDebugMode) {
          print('🔌 Socket Provider: Auto-reconnect attempt $retryCount failed - $e');
        }

        if (retryCount < maxRetries) {
          await Future.delayed(delay);
        }
      }
    }

    if (!_isConnected) {
      _connectionError = 'Failed to reconnect after $maxRetries attempts';
      notifyListeners();

      if (kDebugMode) {
        print('🔌 Socket Provider: Auto-reconnect failed after $maxRetries attempts');
      }
    }
  }
}
