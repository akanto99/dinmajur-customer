import 'package:flutter/foundation.dart';

class CartItem {
  final String id;
  final String name;
  final int quantity;
  final double unitPrice;
  final String? imageUrl;

  const CartItem({
    required this.id,
    required this.name,
    required this.quantity,
    required this.unitPrice,
    this.imageUrl,
  });

  double get subtotal => unitPrice * quantity;
}

class GlobalCartProvider extends ChangeNotifier {
  int _itemCount = 0;
  double _totalPrice = 0.0;
  String _serviceName = '';
  VoidCallback? _onViewCart;
  List<CartItem> _items = [];

  int get itemCount => _itemCount;
  double get totalPrice => _totalPrice;
  String get serviceName => _serviceName;
  VoidCallback? get onViewCart => _onViewCart;
  bool get hasItems => _itemCount > 0;
  List<CartItem> get items => List.unmodifiable(_items);

  void update({
    required int itemCount,
    required double totalPrice,
    required String serviceName,
    required VoidCallback onViewCart,
    List<CartItem> items = const [],
  }) {
    _itemCount = itemCount;
    _totalPrice = totalPrice;
    _serviceName = serviceName;
    _onViewCart = onViewCart;
    _items = List.of(items);
    notifyListeners();
  }

  void clear() {
    _itemCount = 0;
    _totalPrice = 0.0;
    _serviceName = '';
    _onViewCart = null;
    _items = [];
    notifyListeners();
  }
}
