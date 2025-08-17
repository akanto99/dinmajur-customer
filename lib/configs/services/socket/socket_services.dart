import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter/foundation.dart';

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  IO.Socket? _socket;
  bool _isConnected = false;
  String? _userId;
  String? _userRole;

  // Getters
  bool get isConnected => _isConnected;
  IO.Socket? get socket => _socket;

  // Initialize socket connection
  Future<void> initializeSocket({
    required String userId,
    String userRole = 'CUSTOMER',
  }) async {
    try {
      _userId = userId;
      _userRole = userRole;

      // Disconnect existing connection if any
      if (_socket != null) {
        await disconnect();
      }

      // Create socket connection
      _socket = IO.io(
        'https://api-staging.dinmajur.com',
        // 'http://192.168.1.4:4000',
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .enableAutoConnect()
            .enableForceNew()
            .setExtraHeaders({
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        })
            .build(),
      );

      _setupSocketListeners();

      // Connect to socket
      _socket!.connect();

      if (kDebugMode) {
        print('Socket initialization started for user: $userId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Socket initialization error: $e');
      }
    }
  }

  // Setup socket event listeners
  void _setupSocketListeners() {
    _socket!.onConnect((data) {
      _isConnected = true;
      if (kDebugMode) {
        print('Socket connected successfully');
      }

      // Register user after connection
      if (_userId != null && _userRole != null) {
        registerUser(_userId!, _userRole!);
      }
    });

    _socket!.onDisconnect((data) {
      _isConnected = false;
      if (kDebugMode) {
        print('Socket disconnected: $data');
      }
    });

    _socket!.onConnectError((error) {
      _isConnected = false;
      if (kDebugMode) {
        print('Socket connection error: $error');
      }
    });

    _socket!.onError((error) {
      if (kDebugMode) {
        print('Socket error: $error');
      }
    });

    // Listen for server welcome message
    _socket!.on('server-message', (data) {
      if (kDebugMode) {
        print('Server message: $data');
      }
    });

    // Listen for user registration confirmation
    _socket!.on('user-registered', (data) {
      if (kDebugMode) {
        print('User registration confirmed: $data');
      }
    });

    // Listen for user unregistration confirmation
    _socket!.on('user-unregistered', (data) {
      if (kDebugMode) {
        print('User unregistration confirmed: $data');
      }
    });

    // Listen for delivery requests (for freelancers)
    _socket!.on('deliveryRequest', (data) {
      if (kDebugMode) {
        print('Delivery request received: $data');
      }
      // Handle delivery request - you can add callback here
      _onDeliveryRequest(data);
    });

    // Listen for delivery acceptance notifications (for customers)
    _socket!.on('deliveryAccepted', (data) {
      if (kDebugMode) {
        print('Delivery accepted: $data');
      }
      // Handle delivery accepted - you can add callback here
      _onDeliveryAccepted(data);
    });

    // Listen for delivery taken notifications
    _socket!.on('deliveryTaken', (data) {
      if (kDebugMode) {
        print('Delivery taken by another freelancer: $data');
      }
      // Handle delivery taken - you can add callback here
      _onDeliveryTaken(data);
    });

    // Listen for real-time order updates
    _socket!.on('orderStatusUpdate', (data) {
      if (kDebugMode) {
        print('Order status update: $data');
      }
      _onOrderStatusUpdate(data);
    });

    // Listen for chat messages
    _socket!.on('newMessage', (data) {
      if (kDebugMode) {
        print('New message received: $data');
      }
      _onNewMessage(data);
    });
  }

  // Register user with the socket server using "register-user" event
  void registerUser(String userId, String role) {
    if (_socket != null && _isConnected) {
      _socket!.emit('register-user', {
        'userId': userId,
        'role': role,
      });

      if (kDebugMode) {
        print('🔌 User registration event sent - userId: $userId, role: $role');
      }
    } else {
      if (kDebugMode) {
        print('🔌 Cannot register user - socket not connected');
      }
    }
  }

  // Unregister user from the socket server using "unregister-user" event
  void unregisterUser(String userId, String role) {
    if (_socket != null && _isConnected) {
      _socket!.emit('unregister-user', {
        'userId': userId,
        'role': role,
      });

      if (kDebugMode) {
        print('🔌 User unregistration event sent - userId: $userId, role: $role');
      }
    } else {
      if (kDebugMode) {
        print('🔌 Cannot unregister user - socket not connected');
      }
    }
  }

  // Accept delivery (for freelancers)
  void acceptDelivery({
    required String orderId,
    required String freelancerId,
  }) {
    if (_socket != null && _isConnected) {
      _socket!.emit('freelancerAcceptDelivery', {
        'orderId': orderId,
        'freelancerId': freelancerId,
      });

      if (kDebugMode) {
        print('Delivery accepted for order: $orderId by freelancer: $freelancerId');
      }
    }
  }

  // Send chat message
  void sendMessage({
    required String conversationId,
    required String message,
    required String senderId,
    required String receiverId,
  }) {
    if (_socket != null && _isConnected) {
      _socket!.emit('sendMessage', {
        'conversationId': conversationId,
        'message': message,
        'senderId': senderId,
        'receiverId': receiverId,
        'timestamp': DateTime.now().toIso8601String(),
      });

      if (kDebugMode) {
        print('Message sent to conversation: $conversationId');
      }
    }
  }

  // Join a conversation room
  void joinConversation(String conversationId) {
    if (_socket != null && _isConnected) {
      _socket!.emit('joinConversation', {
        'conversationId': conversationId,
      });

      if (kDebugMode) {
        print('Joined conversation: $conversationId');
      }
    }
  }

  // Leave a conversation room
  void leaveConversation(String conversationId) {
    if (_socket != null && _isConnected) {
      _socket!.emit('leaveConversation', {
        'conversationId': conversationId,
      });

      if (kDebugMode) {
        print('Left conversation: $conversationId');
      }
    }
  }

  // Callback methods - override these or use listeners
  Function(Map<String, dynamic>)? onDeliveryRequest;
  Function(Map<String, dynamic>)? onDeliveryAccepted;
  Function(Map<String, dynamic>)? onDeliveryTaken;
  Function(Map<String, dynamic>)? onOrderStatusUpdate;
  Function(Map<String, dynamic>)? onNewMessage;

  void _onDeliveryRequest(dynamic data) {
    if (onDeliveryRequest != null && data is Map) {
      onDeliveryRequest!(Map<String, dynamic>.from(data));
    }
  }

  void _onDeliveryAccepted(dynamic data) {
    if (onDeliveryAccepted != null && data is Map) {
      onDeliveryAccepted!(Map<String, dynamic>.from(data));
    }
  }

  void _onDeliveryTaken(dynamic data) {
    if (onDeliveryTaken != null && data is Map) {
      onDeliveryTaken!(Map<String, dynamic>.from(data));
    }
  }

  void _onOrderStatusUpdate(dynamic data) {
    if (onOrderStatusUpdate != null && data is Map) {
      onOrderStatusUpdate!(Map<String, dynamic>.from(data));
    }
  }

  void _onNewMessage(dynamic data) {
    if (onNewMessage != null && data is Map) {
      onNewMessage!(Map<String, dynamic>.from(data));
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
        print('🔌 Emitted event: $event with data: $data');
      }
    } else {
      if (kDebugMode) {
        print('🔌 Cannot emit event $event - socket not connected');
      }
    }
  }

  // Get current user info
  Map<String, String?> getCurrentUser() {
    return {
      'userId': _userId,
      'role': _userRole,
    };
  }

  // Check if user is registered
  bool get hasRegisteredUser => _userId != null && _userRole != null;

  // Disconnect socket
  Future<void> disconnect() async {
    try {
      // Unregister user before disconnecting if registered
      if (_userId != null && _userRole != null && _isConnected) {
        unregisterUser(_userId!, _userRole!);
        // Give a moment for the unregister event to be processed
        await Future.delayed(Duration(milliseconds: 300));
      }

      if (_socket != null) {
        _socket!.disconnect();
        _socket!.dispose();
        _socket = null;
        _isConnected = false;

        if (kDebugMode) {
          print('🔌 Socket disconnected and disposed');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('🔌 Error during disconnect: $e');
      }
    } finally {
      // Reset state
      _isConnected = false;
      _userId = null;
      _userRole = null;
    }
  }

  // Reconnect socket with same user credentials
  Future<void> reconnect() async {
    if (_userId != null && _userRole != null) {
      await initializeSocket(userId: _userId!, userRole: _userRole!);
    } else {
      if (kDebugMode) {
        print('🔌 Cannot reconnect - no user credentials stored');
      }
    }
  }

  // Force disconnect without unregister (for emergency cases)
  Future<void> forceDisconnect() async {
    try {
      if (_socket != null) {
        _socket!.disconnect();
        _socket!.dispose();
        _socket = null;
      }
    } catch (e) {
      if (kDebugMode) {
        print('🔌 Error during force disconnect: $e');
      }
    } finally {
      _isConnected = false;
      _userId = null;
      _userRole = null;
    }
  }
}