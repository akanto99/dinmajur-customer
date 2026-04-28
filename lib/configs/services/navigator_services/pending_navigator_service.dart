// lib/configs/services/navigator_services/pending_navigation_service.dart

import 'package:flutter/cupertino.dart';

class PendingNavigationService {
  static final PendingNavigationService _instance = PendingNavigationService._internal();
  factory PendingNavigationService() => _instance;
  PendingNavigationService._internal();

  String? _pendingRoute;
  Map<String, dynamic>? _pendingArguments;

  void setPending(String route, Map<String, dynamic> arguments) {
    _pendingRoute = route;
    _pendingArguments = arguments;
  }

  bool get hasPending => _pendingRoute != null;

  Future<void> consumePending(NavigatorState navigator) async {
    if (_pendingRoute != null) {
      final route = _pendingRoute!;
      final args = _pendingArguments;
      _pendingRoute = null;
      _pendingArguments = null;
      navigator.pushNamed(route, arguments: args);
    }
  }

  void clear() {
    _pendingRoute = null;
    _pendingArguments = null;
  }
}