// import 'dart:async';
// import 'dart:convert';
// import 'package:dinmajur_customer/configs/services/sse_notification_services/sse_notification_count/get_notificationCount_model.dart';
// import 'package:flutter/foundation.dart';
// import 'package:http/http.dart' as https;
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:dinmajur_customer/configs/res/app_url.dart';
//
// class SSENotificationService {
//   https.Client? _client;
//   StreamController<Map<String, dynamic>>? _notificationStreamController;
//   StreamController<int>? _countStreamController;
//   bool _isListening = false;
//   String? _currentEventType;
//   StringBuffer _dataBuffer = StringBuffer();
//   int _reconnectAttempts = 0;
//   static const int _maxReconnectAttempts = 5;
//   Timer? _reconnectTimer;
//
//   // Two separate streams
//   Stream<Map<String, dynamic>> get notificationStream =>
//       _notificationStreamController?.stream ?? Stream.empty();
//
//   Stream<int> get notificationCountStream =>
//       _countStreamController?.stream ?? Stream.empty();
//
//   Future<void> startListening() async {
//     if (_isListening) {
//       debugPrint('SSE already listening');
//       return;
//     }
//
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     String? accessToken = prefs.getString('accessToken');
//
//     if (accessToken == null || accessToken.isEmpty) {
//       debugPrint('❌ SSE: No access token found');
//       return;
//     }
//
//     _client = https.Client();
//     _notificationStreamController = StreamController<Map<String, dynamic>>.broadcast();
//     _countStreamController = StreamController<int>.broadcast();
//     _isListening = true;
//
//     try {
//       final url = Uri.parse('${AppUrl.baseUrl}/notifications/stream');
//       debugPrint('🔔 Starting SSE connection to: $url');
//
//       final request = https.Request('GET', url);
//       request.headers['Accept'] = 'text/event-stream';
//       request.headers['Cache-Control'] = 'no-cache';
//       request.headers['Connection'] = 'keep-alive';
//       request.headers['Authorization'] = 'Bearer $accessToken';
//
//       final response = await _client!.send(request);
//
//       if (response.statusCode == 200) {
//         debugPrint('✅ SSE connection established');
//         _reconnectAttempts = 0;
//
//         response.stream
//             .transform(utf8.decoder)
//             .transform(const LineSplitter())
//             .listen(
//               (line) => _handleSSELine(line),
//           onError: (error) {
//             debugPrint('❌ SSE stream error: $error');
//             _reconnect();
//           },
//           onDone: () {
//             debugPrint('⚠️ SSE stream closed');
//             _reconnect();
//           },
//           cancelOnError: false,
//         );
//       } else {
//         debugPrint('❌ SSE connection failed: ${response.statusCode}');
//         if (response.statusCode == 401) {
//           await stopListening();
//         } else {
//           _reconnect();
//         }
//       }
//     } catch (e) {
//       debugPrint('❌ SSE connection error: $e');
//       _reconnect();
//     }
//   }
//
//   void _handleSSELine(String line) {
//     if (line.isEmpty) {
//       if (_dataBuffer.isNotEmpty) {
//         _processEvent();
//       }
//       _currentEventType = null;
//       _dataBuffer.clear();
//       return;
//     }
//
//     if (line.startsWith('event:')) {
//       _currentEventType = line.substring(6).trim();
//       debugPrint('📨 SSE Event Type: $_currentEventType');
//     } else if (line.startsWith('data:')) {
//       final dataLine = line.substring(5).trim();
//       if (dataLine.isNotEmpty) {
//         if (_dataBuffer.isNotEmpty) {
//           _dataBuffer.write('\n');
//         }
//         _dataBuffer.write(dataLine);
//       }
//     } else if (line.startsWith(':')) {
//       debugPrint('💓 SSE heartbeat');
//     }
//   }
//
//   void _processEvent() {
//     try {
//       final jsonData = _dataBuffer.toString().trim();
//       if (jsonData.isEmpty) return;
//
//       debugPrint('🔍 Processing event: $_currentEventType');
//       debugPrint('📄 Raw data: $jsonData');
//
//       // Handle "notificationCount" event
//       if (_currentEventType == 'notificationCount') {
//         try {
//           // Try parsing as plain integer first (e.g., "5")
//           final count = int.parse(jsonData);
//           debugPrint('🔢 notificationCount (plain int): $count');
//           _countStreamController?.add(count);
//           return;
//         } catch (e) {
//           // If plain int fails, try JSON object with model
//           try {
//             final countModel = getSseNotificationCountModelFromJson(jsonData);
//             if (countModel.total != null) {
//               final count = countModel.total!;
//               debugPrint('🔢 notificationCount (Model): total = $count');
//               _countStreamController?.add(count);
//               return;
//             } else {
//               debugPrint('⚠️ notificationCount event missing "total" field');
//             }
//           } catch (e2) {
//             debugPrint('❌ Failed to parse notificationCount: $e2');
//             debugPrint('❌ Raw data was: $jsonData');
//           }
//         }
//         return;
//       }
//
//       // // Handle "ping" event (heartbeat - no data needed)
//       // if (_currentEventType == 'ping') {
//       //   debugPrint('💓 Ping/heartbeat received');
//       //   return;
//       // }
//       //
//       // // For all other events, parse as JSON
//       // final data = json.decode(jsonData) as Map<String, dynamic>;
//       //
//       // // Handle "notification" event
//       // if (_currentEventType == 'notification') {
//       //   if (data.containsKey('ssePayload')) {
//       //     debugPrint('📬 Notification event received');
//       //     debugPrint('📋 Notification type: ${data['ssePayload']['type']}');
//       //     debugPrint('💬 Message: ${data['ssePayload']['message']}');
//       //     _notificationStreamController?.add(data);
//       //   } else {
//       //     debugPrint('⚠️ Notification event missing "ssePayload"');
//       //   }
//       // } else {
//       //   debugPrint('⚠️ Unknown event type: $_currentEventType');
//       // }
//
//     } catch (e, stackTrace) {
//       debugPrint('❌ Error parsing SSE data: $e');
//       debugPrint('❌ Event type: $_currentEventType');
//       debugPrint('❌ Raw data: ${_dataBuffer.toString()}');
//       debugPrint('❌ Stack trace: $stackTrace');
//     }
//   }
//
//   void _reconnect() async {
//     if (!_isListening) return;
//     _reconnectTimer?.cancel();
//     _reconnectAttempts++;
//
//     if (_reconnectAttempts > _maxReconnectAttempts) {
//       debugPrint('❌ Max reconnection attempts reached');
//       await stopListening();
//       return;
//     }
//
//     final delaySeconds = (2 * _reconnectAttempts).clamp(2, 32);
//     debugPrint('🔄 Reconnecting in $delaySeconds seconds...');
//
//     _reconnectTimer = Timer(Duration(seconds: delaySeconds), () async {
//       if (_isListening) {
//         await stopListening();
//         await startListening();
//       }
//     });
//   }
//
//   Future<void> stopListening() async {
//     _isListening = false;
//     _currentEventType = null;
//     _dataBuffer.clear();
//     _reconnectTimer?.cancel();
//     _reconnectTimer = null;
//     _client?.close();
//     _client = null;
//     await _notificationStreamController?.close();
//     await _countStreamController?.close();
//     _notificationStreamController = null;
//     _countStreamController = null;
//     debugPrint('🛑 SSE connection stopped');
//   }
//
//   Future<void> restart() async {
//     await stopListening();
//     await startListening();
//   }
//
//   bool get isListening => _isListening;
//
//   Future<void> dispose() async {
//     await stopListening();
//   }
// }
import 'dart:async';
import 'dart:convert';
import 'package:dinmajur_customer/configs/services/sse_notification_services/sse_notification_count/get_notificationCount_model.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as https;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dinmajur_customer/configs/res/app_url.dart';

class SSENotificationService {
  https.Client? _client;
  StreamController<Map<String, dynamic>>? _notificationStreamController;

  // ✅ REMOVE the old _countStreamController - we only need ONE
  // StreamController<int>? _countStreamController;

  bool _isListening = false;
  String? _currentEventType;
  StringBuffer _dataBuffer = StringBuffer();
  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 5;
  Timer? _reconnectTimer;

  // ✅ Keep only this stream controller for notification count
  final StreamController<int> _notificationCountController =
  StreamController<int>.broadcast();

  int _currentCount = 0;

  // Streams
  Stream<Map<String, dynamic>> get notificationStream =>
      _notificationStreamController?.stream ?? Stream.empty();

  Stream<int> get notificationCountStream =>
      _notificationCountController.stream;

  // ✅ Getter for current count value
  int get currentCount => _currentCount;

  Future<void> startListening() async {
    if (_isListening) {
      debugPrint('SSE already listening');
      return;
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('accessToken');

    if (accessToken == null || accessToken.isEmpty) {
      debugPrint('❌ SSE: No access token found');
      return;
    }

    _client = https.Client();
    _notificationStreamController = StreamController<Map<String, dynamic>>.broadcast();

    // ✅ REMOVE initialization of old stream controller
    // _countStreamController = StreamController<int>.broadcast();

    _isListening = true;

    try {
      final url = Uri.parse('${AppUrl.baseUrl}/notifications/stream');
      debugPrint('🔔 Starting SSE connection to: $url');

      final request = https.Request('GET', url);
      request.headers['Accept'] = 'text/event-stream';
      request.headers['Cache-Control'] = 'no-cache';
      request.headers['Connection'] = 'keep-alive';
      request.headers['Authorization'] = 'Bearer $accessToken';

      final response = await _client!.send(request);

      if (response.statusCode == 200) {
        debugPrint('✅ SSE connection established');
        _reconnectAttempts = 0;

        response.stream
            .transform(utf8.decoder)
            .transform(const LineSplitter())
            .listen(
              (line) => _handleSSELine(line),
          onError: (error) {
            debugPrint('❌ SSE stream error: $error');
            _reconnect();
          },
          onDone: () {
            debugPrint('⚠️ SSE stream closed');
            _reconnect();
          },
          cancelOnError: false,
        );
      } else {
        debugPrint('❌ SSE connection failed: ${response.statusCode}');
        if (response.statusCode == 401) {
          await stopListening();
        } else {
          _reconnect();
        }
      }
    } catch (e) {
      debugPrint('❌ SSE connection error: $e');
      _reconnect();
    }
  }

  void _handleSSELine(String line) {
    if (line.isEmpty) {
      if (_dataBuffer.isNotEmpty) {
        _processEvent();
      }
      _currentEventType = null;
      _dataBuffer.clear();
      return;
    }

    if (line.startsWith('event:')) {
      _currentEventType = line.substring(6).trim();
      debugPrint('📨 SSE Event Type: $_currentEventType');
    } else if (line.startsWith('data:')) {
      final dataLine = line.substring(5).trim();
      if (dataLine.isNotEmpty) {
        if (_dataBuffer.isNotEmpty) {
          _dataBuffer.write('\n');
        }
        _dataBuffer.write(dataLine);
      }
    } else if (line.startsWith(':')) {
      debugPrint('💓 SSE heartbeat');
    }
  }

  void _processEvent() {
    try {
      final jsonData = _dataBuffer.toString().trim();
      if (jsonData.isEmpty) return;

      debugPrint('🔍 Processing event: $_currentEventType');
      debugPrint('📄 Raw data: $jsonData');

      // ✅ Handle "notificationCount" event
      if (_currentEventType == 'notificationCount') {
        _handleNotificationCount(jsonData);
        return;
      }

      // Handle "ping" event (heartbeat - no data needed)
      if (_currentEventType == 'ping') {
        debugPrint('💓 Ping/heartbeat received');
        return;
      }

      // For all other events, parse as JSON
      final data = json.decode(jsonData) as Map<String, dynamic>;

      // Handle "notification" event
      if (_currentEventType == 'notification') {
        if (data.containsKey('ssePayload')) {
          debugPrint('📬 Notification event received');
          debugPrint('📋 Notification type: ${data['ssePayload']['type']}');
          debugPrint('💬 Message: ${data['ssePayload']['message']}');
          _notificationStreamController?.add(data);
        } else {
          debugPrint('⚠️ Notification event missing "ssePayload"');
        }
      } else {
        debugPrint('⚠️ Unknown event type: $_currentEventType');
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Error parsing SSE data: $e');
      debugPrint('❌ Event type: $_currentEventType');
      debugPrint('❌ Raw data: ${_dataBuffer.toString()}');
      debugPrint('❌ Stack trace: $stackTrace');
    }
  }

  // ✅ Unified method to handle notification count
  void _handleNotificationCount(String jsonData) {
    try {
      // Try parsing as plain integer first (e.g., "5")
      try {
        final count = int.parse(jsonData);
        debugPrint('═══════════════════════════════════════════');
        debugPrint('📊 SSE: notificationCount (plain int): $count');
        debugPrint('═══════════════════════════════════════════');

        _currentCount = count;
        _notificationCountController.add(count);
        return;
      } catch (_) {
        // Not a plain integer, try JSON parsing
      }

      // Try parsing as JSON object with model
      final countModel = getSseNotificationCountModelFromJson(jsonData);
      if (countModel.total != null) {
        final count = countModel.total!;
        debugPrint('═══════════════════════════════════════════');
        debugPrint('📊 SSE: notificationCount (JSON): $count');
        debugPrint('═══════════════════════════════════════════');

        _currentCount = count;
        _notificationCountController.add(count);
      } else {
        debugPrint('⚠️ notificationCount event missing "total" field');
      }
    } catch (e) {
      debugPrint('❌ Failed to parse notificationCount: $e');
      debugPrint('❌ Raw data was: $jsonData');
    }
  }

  void _reconnect() async {
    if (!_isListening) return;
    _reconnectTimer?.cancel();
    _reconnectAttempts++;

    if (_reconnectAttempts > _maxReconnectAttempts) {
      debugPrint('❌ Max reconnection attempts reached');
      await stopListening();
      return;
    }

    final delaySeconds = (2 * _reconnectAttempts).clamp(2, 32);
    debugPrint('🔄 Reconnecting in $delaySeconds seconds...');

    _reconnectTimer = Timer(Duration(seconds: delaySeconds), () async {
      if (_isListening) {
        await stopListening();
        await startListening();
      }
    });
  }

  Future<void> stopListening() async {
    _isListening = false;
    _currentEventType = null;
    _dataBuffer.clear();
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _client?.close();
    _client = null;
    await _notificationStreamController?.close();

    // ✅ REMOVE closing of old stream controller
    // await _countStreamController?.close();

    _notificationStreamController = null;

    // ✅ REMOVE setting to null (we keep the broadcast controller alive)
    // _countStreamController = null;

    debugPrint('🛑 SSE connection stopped');
  }

  Future<void> restart() async {
    await stopListening();
    await startListening();
  }

  bool get isListening => _isListening;

  Future<void> dispose() async {
    await stopListening();
    // ✅ Close the notification count controller on final disposal
    await _notificationCountController.close();
  }
}