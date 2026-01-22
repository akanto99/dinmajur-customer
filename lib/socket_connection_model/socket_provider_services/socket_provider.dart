// ///Customer
//
// import 'package:dinmajur_customer/socket_connection_model/socket_provider_services/socket_services.dart';
// import 'package:flutter/foundation.dart';
//
// class SocketProvider with ChangeNotifier {
//   final SocketService _socketService = SocketService();
//
//   bool _isConnected = false;
//   bool _isConnecting = false;
//   String? _connectionError;
//   String? _lastActivity;
//
//   // Getters
//   bool get isConnected => _isConnected;
//   bool get isConnecting => _isConnecting;
//   String? get connectionError => _connectionError;
//   String? get lastActivity => _lastActivity;
//   SocketService get socketService => _socketService;
//
//   // ✅ Callback for when socket is fully ready (connected + user registered)
//   List<Function()> _onReadyCallbacks = [];
//
//   /// ✅ Register callback to be called when socket is ready
//   void onSocketReady(Function() callback) {
//     _onReadyCallbacks.add(callback);
//
//     // If already connected, call immediately
//     if (_isConnected) {
//       callback();
//     }
//   }
//
//   /// ✅ Remove callback
//   void removeSocketReadyCallback(Function() callback) {
//     _onReadyCallbacks.remove(callback);
//   }
//
//   /// Connect socket with user credentials
//   Future<void> connectWithUser({
//     required String userId,
//   }) async {
//     try {
//       _isConnecting = true;
//       _connectionError = null;
//       notifyListeners();
//
//       // Initialize socket with user credentials
//       await _socketService.initializeSocket(userId: userId);
//
//       // Setup basic connection listeners
//       _setupConnectionListeners();
//
//       _isConnecting = false;
//       notifyListeners();
//
//       if (kDebugMode) {
//         print('🔌 Socket Provider: Connected with user $userId');
//       }
//
//     } catch (e) {
//       _isConnecting = false;
//       _connectionError = e.toString();
//       _isConnected = false;
//       notifyListeners();
//
//       if (kDebugMode) {
//         print('🔌 Socket Provider: Connection failed - $e');
//       }
//     }
//   }
//
//   /// Setup basic connection event listeners
//   void _setupConnectionListeners() {
//     _socketService.socket?.on('connect', (_) {
//       _isConnected = true;
//       _connectionError = null;
//       _lastActivity = DateTime.now().toString();
//       notifyListeners();
//
//       if (kDebugMode) {
//         print('🔌 Socket Provider: Connected successfully');
//       }
//     });
//
//     _socketService.socket?.on('disconnect', (_) {
//       _isConnected = false;
//       _lastActivity = DateTime.now().toString();
//       notifyListeners();
//
//       if (kDebugMode) {
//         print('🔌 Socket Provider: Disconnected');
//       }
//     });
//
//     _socketService.socket?.on('connect_error', (error) {
//       _isConnected = false;
//       _connectionError = error.toString();
//       _lastActivity = DateTime.now().toString();
//       notifyListeners();
//
//       if (kDebugMode) {
//         print('🔌 Socket Provider: Connection error - $error');
//       }
//     });
//
//     // User registration/unregistration confirmations
//     _socketService.socket?.on('register-user', (data) {
//       _lastActivity = DateTime.now().toString();
//       notifyListeners();
//
//       if (kDebugMode) {
//         print('🔌 Socket Provider: User registered - socket is READY');
//       }
//
//       // ✅ Trigger all ready callbacks
//       for (var callback in _onReadyCallbacks) {
//         try {
//           callback();
//         } catch (e) {
//           if (kDebugMode) {
//             print('🔌 Socket Provider: Error in ready callback - $e');
//           }
//         }
//       }
//     });
//
//     _socketService.socket?.on('unregister-user', (data) {
//       _lastActivity = DateTime.now().toString();
//       notifyListeners();
//
//       if (kDebugMode) {
//         print('🔌 Socket Provider: User unregistered successfully - $data');
//       }
//     });
//   }
//
//   /// Unregister user and disconnect socket
//   Future<void> unregisterAndDisconnect({
//     required String userId,
//   }) async {
//     try {
//       if (kDebugMode) {
//         print('🔌 Socket Provider: Starting unregister and disconnect for user $userId');
//         print('🔌 Socket Provider: Current state - isConnected: $_isConnected, socket: ${_socketService.socket != null ? 'exists' : 'null'}');
//       }
//
//       // Check if socket exists and is connected
//       if (_socketService.socket != null) {
//         if (_isConnected) {
//           if (kDebugMode) {
//             print('🔌 Socket Provider: Socket is connected, emitting unregister-user event');
//           }
//
//           try {
//             // Emit unregister-user event
//             _socketService.socket!.emit('unregister-user', {
//               'userId': userId,
//             });
//
//             if (kDebugMode) {
//               print('🔌 Socket Provider: Unregister event emitted for user $userId');
//             }
//
//             // Wait for server to process the unregister event
//             await Future.delayed(Duration(milliseconds: 800));
//           } catch (emitError) {
//             if (kDebugMode) {
//               print('🔌 Socket Provider: ⚠️ Error emitting unregister event: $emitError');
//             }
//             // Continue with disconnect even if emit fails
//           }
//         } else {
//           if (kDebugMode) {
//             print('🔌 Socket Provider: Socket exists but not connected, skipping unregister event');
//           }
//         }
//       } else {
//         if (kDebugMode) {
//           print('🔌 Socket Provider: No socket exists, skipping unregister event');
//         }
//       }
//
//       // Disconnect socket (whether connected or not)
//       if (kDebugMode) {
//         print('🔌 Socket Provider: Disconnecting socket...');
//       }
//
//       await _socketService.disconnect();
//
//       // Update state
//       _isConnected = false;
//       _connectionError = null;
//       _lastActivity = DateTime.now().toString();
//
//       // Clear callbacks on disconnect
//       _onReadyCallbacks.clear();
//
//       notifyListeners();
//
//       if (kDebugMode) {
//         print('🔌 Socket Provider: ✅ User unregistered and socket disconnected successfully');
//       }
//
//     } catch (e) {
//       if (kDebugMode) {
//         print('🔌 Socket Provider: ⚠️ Unregister/disconnect error - $e');
//       }
//
//       // Force cleanup even on error
//       try {
//         await _socketService.disconnect();
//       } catch (disconnectError) {
//         if (kDebugMode) {
//           print('🔌 Socket Provider: ⚠️ Force disconnect also failed - $disconnectError');
//         }
//       }
//
//       _isConnected = false;
//       _connectionError = e.toString();
//       _onReadyCallbacks.clear();
//       notifyListeners();
//
//       // Don't rethrow - we want logout to succeed even if socket disconnect fails
//     }
//   }
//
//   /// Force disconnect socket
//   Future<void> disconnect() async {
//     try {
//       if (kDebugMode) {
//         print('🔌 Socket Provider: Force disconnect called');
//       }
//
//       await _socketService.disconnect();
//
//       _isConnected = false;
//       _connectionError = null;
//       _lastActivity = DateTime.now().toString();
//       _onReadyCallbacks.clear();
//
//       notifyListeners();
//
//       if (kDebugMode) {
//         print('🔌 Socket Provider: Force disconnected successfully');
//       }
//
//     } catch (e) {
//       if (kDebugMode) {
//         print('🔌 Socket Provider: Force disconnect error - $e');
//       }
//
//       // Update state even on error
//       _isConnected = false;
//       _connectionError = e.toString();
//       _onReadyCallbacks.clear();
//       notifyListeners();
//     }
//   }
//
//   /// Emit custom events
//   void emit(String event, dynamic data) {
//     if (_isConnected && _socketService.socket != null) {
//       _socketService.socket!.emit(event, data);
//       _lastActivity = DateTime.now().toString();
//       notifyListeners();
//
//       if (kDebugMode) {
//         print('🔌 Socket Provider: Emitted event: $event');
//       }
//     } else {
//       if (kDebugMode) {
//         print('🔌 Socket Provider: Cannot emit $event - socket not connected');
//       }
//     }
//   }
//
//   // Get socket status as string
//   String get statusText {
//     if (_isConnecting) return 'Connecting...';
//     if (_isConnected) return 'Connected';
//     if (_connectionError != null) return 'Error: $_connectionError';
//     return 'Disconnected';
//   }
//
//   // Get status color
//   int get statusColor {
//     if (_isConnecting) return 0xFFFFA726; // Orange
//     if (_isConnected) return 0xFF4CAF50; // Green
//     if (_connectionError != null) return 0xFFF44336; // Red
//     return 0xFF9E9E9E; // Grey
//   }
//
//   /// Reconnect socket
//   Future<void> reconnect() async {
//     try {
//       _isConnecting = true;
//       _connectionError = null;
//       notifyListeners();
//
//       if (kDebugMode) {
//         print('🔌 Socket Provider: Attempting reconnection...');
//       }
//
//       // Check if we can reconnect
//       if (!_socketService.canReconnect()) {
//         throw Exception('Cannot reconnect: Missing user credentials');
//       }
//
//       // Attempt reconnection
//       await _socketService.reconnect();
//
//       _isConnecting = false;
//       notifyListeners();
//
//       if (kDebugMode) {
//         print('🔌 Socket Provider: Reconnection attempt completed');
//       }
//
//     } catch (e) {
//       _isConnecting = false;
//       _connectionError = e.toString();
//       _isConnected = false;
//       notifyListeners();
//
//       if (kDebugMode) {
//         print('🔌 Socket Provider: Reconnection failed - $e');
//       }
//       rethrow;
//     }
//   }
//
//   /// Auto-reconnect with retry logic
//   Future<void> autoReconnect({int maxRetries = 3, Duration delay = const Duration(seconds: 2)}) async {
//     int retryCount = 0;
//
//     while (retryCount < maxRetries && !_isConnected) {
//       try {
//         if (kDebugMode) {
//           print('🔌 Socket Provider: Auto-reconnect attempt ${retryCount + 1}/$maxRetries');
//         }
//
//         await reconnect();
//
//         // Wait a bit to check if connection is successful
//         await Future.delayed(Duration(milliseconds: 500));
//
//         if (_isConnected) {
//           if (kDebugMode) {
//             print('🔌 Socket Provider: Auto-reconnect successful');
//           }
//           return;
//         }
//
//         retryCount++;
//
//         if (retryCount < maxRetries) {
//           await Future.delayed(delay);
//         }
//
//       } catch (e) {
//         retryCount++;
//
//         if (kDebugMode) {
//           print('🔌 Socket Provider: Auto-reconnect attempt $retryCount failed - $e');
//         }
//
//         if (retryCount < maxRetries) {
//           await Future.delayed(delay);
//         }
//       }
//     }
//
//     if (!_isConnected) {
//       _connectionError = 'Failed to reconnect after $maxRetries attempts';
//       notifyListeners();
//
//       if (kDebugMode) {
//         print('🔌 Socket Provider: Auto-reconnect failed after $maxRetries attempts');
//       }
//     }
//   }
//
//   @override
//   void dispose() {
//     if (kDebugMode) {
//       print('🔌 Socket Provider: Disposing...');
//     }
//     _onReadyCallbacks.clear();
//     super.dispose();
//   }
// }

import 'package:dinmajur_customer/socket_connection_model/socket_provider_services/socket_services.dart';
import 'package:flutter/foundation.dart';

class SocketProvider with ChangeNotifier {
  final SocketService _socketService = SocketService();

  bool _isConnected = false;
  bool _isConnecting = false;
  bool _isUserRegistered = false; // ✅ NEW: Track registration status
  String? _connectionError;
  String? _lastActivity;

  // Getters
  bool get isConnected => _isConnected;
  bool get isConnecting => _isConnecting;
  bool get isUserRegistered => _isUserRegistered; // ✅ NEW
  String? get connectionError => _connectionError;
  String? get lastActivity => _lastActivity;
  SocketService get socketService => _socketService;

  // ✅ Check if socket is fully ready (connected AND user registered)
  bool get isSocketReady => _isConnected && _isUserRegistered;

  // Callback for when socket is fully ready
  List<Function()> _onReadyCallbacks = [];

  /// Register callback to be called when socket is ready
  void onSocketReady(Function() callback) {
    _onReadyCallbacks.add(callback);

    // If already connected AND registered, call immediately
    if (isSocketReady) {
      callback();
    }
  }

  /// Remove callback
  void removeSocketReadyCallback(Function() callback) {
    _onReadyCallbacks.remove(callback);
  }

  /// Connect socket with user credentials
  Future<void> connectWithUser({required String userId}) async {
    try {
      _isConnecting = true;
      _connectionError = null;
      notifyListeners();

      // Initialize socket with user credentials
      await _socketService.initializeSocket(userId: userId);

      // Setup basic connection listeners
      _setupConnectionListeners();

      _isConnecting = false;
      notifyListeners();

      if (kDebugMode) {
        print('🔌 Socket Provider: Connection initiated for user $userId');
      }
    } catch (e) {
      _isConnecting = false;
      _connectionError = e.toString();
      _isConnected = false;
      _isUserRegistered = false;
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
      _isUserRegistered = false; // ✅ Reset until we get register-success
      _connectionError = null;
      _lastActivity = DateTime.now().toString();
      notifyListeners();

      if (kDebugMode) {
        print('🔌 Socket Provider: Connected successfully');
      }
    });

    _socketService.socket?.on('disconnect', (_) {
      _isConnected = false;
      _isUserRegistered = false;
      _lastActivity = DateTime.now().toString();
      notifyListeners();

      if (kDebugMode) {
        print('🔌 Socket Provider: Disconnected');
      }
    });

    _socketService.socket?.on('connect_error', (error) {
      _isConnected = false;
      _isUserRegistered = false;
      _connectionError = error.toString();
      _lastActivity = DateTime.now().toString();
      notifyListeners();

      if (kDebugMode) {
        print('🔌 Socket Provider: Connection error - $error');
      }
    });

    // ✅ IMPORTANT: Listen for register-success from server
    _socketService.socket?.on('register-success', (data) {
      _isUserRegistered = true;
      _lastActivity = DateTime.now().toString();
      notifyListeners();

      if (kDebugMode) {
        print('-----------------------------------');
        print('🎉 Socket Provider: Connection Established Successfully');
        print('📋 Data: $data');
        print('-----------------------------------');
      }

      // ✅ Trigger all ready callbacks ONLY after register-success
      for (var callback in _onReadyCallbacks) {
        try {
          callback();
        } catch (e) {
          if (kDebugMode) {
            print('🔌 Socket Provider: Error in ready callback - $e');
          }
        }
      }
    });

    // ✅ Listen for unregister-success
    _socketService.socket?.on('unregister-success', (data) {
      _isUserRegistered = false;
      _lastActivity = DateTime.now().toString();
      notifyListeners();

      if (kDebugMode) {
        print('🔌 Socket Provider: User unregistered successfully - $data');
      }
    });

    // ✅ Optional: Keep the register-user listener for debugging
    _socketService.socket?.on('register-user', (data) {
      _lastActivity = DateTime.now().toString();

      if (kDebugMode) {
        print('🔌 Socket Provider: register-user event received (for debugging)');
      }
    });
  }

  /// Unregister user and disconnect socket
  Future<void> unregisterAndDisconnect({required String userId}) async {
    try {
      if (kDebugMode) {
        print('🔌 Socket Provider: Starting unregister and disconnect for user $userId');
        print('🔌 Socket Provider: Current state - isConnected: $_isConnected, isUserRegistered: $_isUserRegistered');
      }

      // Check if socket exists and is connected
      if (_socketService.socket != null) {
        if (_isConnected) {
          if (kDebugMode) {
            print('🔌 Socket Provider: Socket is connected, emitting unregister-user event');
          }

          try {
            // Emit unregister-user event
            _socketService.socket!.emit('unregister-user', {
              'userId': userId,
            });

            if (kDebugMode) {
              print('🔌 Socket Provider: Unregister event emitted for user $userId');
            }

            // Wait for server to process the unregister event
            await Future.delayed(Duration(milliseconds: 800));
          } catch (emitError) {
            if (kDebugMode) {
              print('🔌 Socket Provider: ⚠️ Error emitting unregister event: $emitError');
            }
          }
        } else {
          if (kDebugMode) {
            print('🔌 Socket Provider: Socket exists but not connected, skipping unregister event');
          }
        }
      } else {
        if (kDebugMode) {
          print('🔌 Socket Provider: No socket exists, skipping unregister event');
        }
      }

      // Disconnect socket
      if (kDebugMode) {
        print('🔌 Socket Provider: Disconnecting socket...');
      }

      await _socketService.disconnect();

      // Update state
      _isConnected = false;
      _isUserRegistered = false;
      _connectionError = null;
      _lastActivity = DateTime.now().toString();

      // Clear callbacks on disconnect
      _onReadyCallbacks.clear();
      notifyListeners();

      if (kDebugMode) {
        print('🔌 Socket Provider: ✅ User unregistered and socket disconnected successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('🔌 Socket Provider: ⚠️ Unregister/disconnect error - $e');
      }

      // Force cleanup even on error
      try {
        await _socketService.disconnect();
      } catch (disconnectError) {
        if (kDebugMode) {
          print('🔌 Socket Provider: ⚠️ Force disconnect also failed - $disconnectError');
        }
      }

      _isConnected = false;
      _isUserRegistered = false;
      _connectionError = e.toString();
      _onReadyCallbacks.clear();
      notifyListeners();
    }
  }

  /// Force disconnect socket
  Future<void> disconnect() async {
    try {
      if (kDebugMode) {
        print('🔌 Socket Provider: Force disconnect called');
      }

      await _socketService.disconnect();

      _isConnected = false;
      _isUserRegistered = false;
      _connectionError = null;
      _lastActivity = DateTime.now().toString();
      _onReadyCallbacks.clear();
      notifyListeners();

      if (kDebugMode) {
        print('🔌 Socket Provider: Force disconnected successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('🔌 Socket Provider: Force disconnect error - $e');
      }

      // Update state even on error
      _isConnected = false;
      _isUserRegistered = false;
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

      if (kDebugMode) {
        print('🔌 Socket Provider: Emitted event: $event');
      }
    } else {
      if (kDebugMode) {
        print('🔌 Socket Provider: Cannot emit $event - socket not connected');
      }
    }
  }

  // Get socket status as string
  String get statusText {
    if (_isConnecting) return 'Connecting...';
    if (_isConnected && !_isUserRegistered) return 'Registering...';
    if (_isConnected && _isUserRegistered) return 'Connected & Registered';
    if (_connectionError != null) return 'Error: $_connectionError';
    return 'Disconnected';
  }

  // Get status color
  int get statusColor {
    if (_isConnecting) return 0xFFFFA726; // Orange
    if (_isConnected && !_isUserRegistered) return 0xFFFFC107; // Amber
    if (_isConnected && _isUserRegistered) return 0xFF4CAF50; // Green
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
      _isUserRegistered = false;
      notifyListeners();

      if (kDebugMode) {
        print('🔌 Socket Provider: Reconnection failed - $e');
      }
      rethrow;
    }
  }

  /// Auto-reconnect with retry logic
  Future<void> autoReconnect({
    int maxRetries = 3,
    Duration delay = const Duration(seconds: 2),
  }) async {
    int retryCount = 0;

    while (retryCount < maxRetries && !isSocketReady) {
      try {
        if (kDebugMode) {
          print('🔌 Socket Provider: Auto-reconnect attempt ${retryCount + 1}/$maxRetries');
        }

        await reconnect();

        // Wait to check if connection is successful
        await Future.delayed(Duration(milliseconds: 500));

        if (isSocketReady) {
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

    if (!isSocketReady) {
      _connectionError = 'Failed to reconnect after $maxRetries attempts';
      notifyListeners();

      if (kDebugMode) {
        print('🔌 Socket Provider: Auto-reconnect failed after $maxRetries attempts');
      }
    }
  }

  @override
  void dispose() {
    if (kDebugMode) {
      print('🔌 Socket Provider: Disposing...');
    }
    _onReadyCallbacks.clear();
    super.dispose();
  }
}