import 'dart:async';
import 'dart:convert';
import 'package:dinmajur_customer/configs/services/sse_notification_services/sse_notification_and_ordercount/get_notification_orderCount_model.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as https;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dinmajur_customer/configs/res/app_url.dart';

class SSENotificationService {
  https.Client? _client;
  StreamController<Map<String, dynamic>>? _notificationStreamController;

  bool _isListening = false;
  String? _currentEventType;
  StringBuffer _dataBuffer = StringBuffer();
  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 5;
  Timer? _reconnectTimer;

  /// Notification Count
  final StreamController<int> _notificationCountController = StreamController<int>.broadcast();

  /// ✅ NEW: Notification Increment Stream
  final StreamController<int> _notificationIncrementController = StreamController<int>.broadcast();

  /// Order Count
  final StreamController<int> _runningOrderCountController = StreamController<int>.broadcast();

  int _currentCount = 0;
  int _currentRunningOrderCount = 0;

  // Streams
  Stream<Map<String, dynamic>> get notificationStream => _notificationStreamController?.stream ?? Stream.empty();
  Stream<int> get notificationCountStream => _notificationCountController.stream;

  /// ✅ NEW: Increment stream
  Stream<int> get notificationIncrementStream => _notificationIncrementController.stream;

  Stream<int> get runningOrderCountStream => _runningOrderCountController.stream;

  // Getters
  int get currentCount => _currentCount;
  int get currentRunningOrderCount => _currentRunningOrderCount;

  Future<void> startListening() async {
    if (_isListening) {
      return;
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('accessToken');

    if (accessToken == null || accessToken.isEmpty) {
      return;
    }

    _client = https.Client();
    _notificationStreamController = StreamController<Map<String, dynamic>>.broadcast();
    _isListening = true;

    try {
      final url = Uri.parse('${AppUrl.baseUrl}/notifications/stream');

      final request = https.Request('GET', url);
      request.headers['Accept'] = 'text/event-stream';
      request.headers['Cache-Control'] = 'no-cache';
      request.headers['Connection'] = 'keep-alive';
      request.headers['Authorization'] = 'Bearer $accessToken';

      final response = await _client!.send(request);

      if (response.statusCode == 200) {
        _reconnectAttempts = 0;

        response.stream
            .transform(utf8.decoder)
            .transform(const LineSplitter())
            .listen(
              (line) => _handleSSELine(line),
          onError: (error) {
            _reconnect();
          },
          onDone: () {
            _reconnect();
          },
          cancelOnError: false,
        );
      } else {
        if (response.statusCode == 401) {
          await stopListening();
        } else {
          _reconnect();
        }
      }
    } catch (e) {
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
    } else if (line.startsWith('data:')) {
      final dataLine = line.substring(5).trim();
      if (dataLine.isNotEmpty) {
        if (_dataBuffer.isNotEmpty) {
          _dataBuffer.write('\n');
        }
        _dataBuffer.write(dataLine);
      }
    } else if (line.startsWith(':')) {
    }
  }

  void _processEvent() {
    try {
      final jsonData = _dataBuffer.toString().trim();
      if (jsonData.isEmpty) return;


      // ✅ Handle "init" event
      if (_currentEventType == 'init') {
        _handleNotificationCount(jsonData);
        return;
      }

      // ✅ Handle "notificationCount" event
      if (_currentEventType == 'notificationCount') {
        _handleNotificationCount(jsonData);
        return;
      }

      // ✅ NEW: Handle "notificationIncrement" event
      if (_currentEventType == 'notificationIncrement') {
        _handleNotificationIncrement(jsonData);
        return;
      }

      // ✅ Handle "runningOrderCount" event
      if (_currentEventType == 'runningOrderCount') {
        _handleNotificationCount(jsonData);
        return;
      }

      // Handle "connected" event
      if (_currentEventType == 'connected') {
        return;
      }

      // Handle "ping" event
      if (_currentEventType == 'ping') {
        return;
      }

      // For all other events, parse as JSON
      final data = json.decode(jsonData) as Map<String, dynamic>;

      // Handle "notification" event
      if (_currentEventType == 'notification') {
        if (data.containsKey('ssePayload')) {
          _notificationStreamController?.add(data);
        } else {
        }
      } else {
      }
    } catch (e, stackTrace) {
    }
  }

  void _handleNotificationCount(String jsonData) {
    try {
      // Try parsing as plain integer first
      try {
        final count = int.parse(jsonData);

        _currentCount = count;
        _notificationCountController.add(count);
        return;
      } catch (_) {
        // Not a plain integer, try JSON parsing
      }

      // Try parsing as JSON object with model
      final countModel = getSseNotificationAndOrderCountModelFromJson(jsonData);

      // Handle notification count
      if (countModel.notificationCount != null) {
        final count = countModel.notificationCount!;

        _currentCount = count;
        _notificationCountController.add(count);
      }

      // Handle running order count
      if (countModel.runningOrderCount != null) {
        final orderCount = countModel.runningOrderCount!;

        _currentRunningOrderCount = orderCount;
        _runningOrderCountController.add(orderCount);
      }
    } catch (e) {
    }
  }

  // ✅ NEW: Handle notification increment event
  void _handleNotificationIncrement(String jsonData) {
    try {

      final data = json.decode(jsonData) as Map<String, dynamic>;

      if (data.containsKey('value')) {
        final incrementValue = data['value'] as int;


        // Update internal count
        _currentCount += incrementValue;


        // Emit the increment value through increment stream
        _notificationIncrementController.add(incrementValue);

        // Also emit updated total count
        _notificationCountController.add(_currentCount);

      } else {
      }
    } catch (e) {
    }
  }

  void _reconnect() async {
    if (!_isListening) return;
    _reconnectTimer?.cancel();
    _reconnectAttempts++;

    if (_reconnectAttempts > _maxReconnectAttempts) {
      await stopListening();
      return;
    }

    final delaySeconds = (2 * _reconnectAttempts).clamp(2, 32);

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
    _notificationStreamController = null;
  }

  bool get isListening => _isListening;

  Future<void> dispose() async {
    await stopListening();
    await _notificationCountController.close();
    await _notificationIncrementController.close();
    await _runningOrderCountController.close();
  }
}