import 'package:flutter/foundation.dart';

class GlobalCartProvider extends ChangeNotifier {
  int _itemCount = 0;
  double _totalPrice = 0.0;
  String _serviceName = '';
  VoidCallback? _onViewCart;

  int get itemCount => _itemCount;
  double get totalPrice => _totalPrice;
  String get serviceName => _serviceName;
  VoidCallback? get onViewCart => _onViewCart;
  bool get hasItems => _itemCount > 0;

  void update({
    required int itemCount,
    required double totalPrice,
    required String serviceName,
    required VoidCallback onViewCart,
  }) {
    _itemCount = itemCount;
    _totalPrice = totalPrice;
    _serviceName = serviceName;
    _onViewCart = onViewCart;
    notifyListeners();
  }

  void clear() {
    _itemCount = 0;
    _totalPrice = 0.0;
    _serviceName = '';
    _onViewCart = null;
    notifyListeners();
  }
}
