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

class ServiceCartEntry {
  final String serviceName;
  final List<CartItem> items;
  final Map<String, dynamic>? checkoutArgs;

  const ServiceCartEntry({
    required this.serviceName,
    required this.items,
    this.checkoutArgs,
  });

  double get subtotal => items.fold(0.0, (sum, item) => sum + item.subtotal);
  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);
}

class GlobalCartProvider extends ChangeNotifier {
  final Map<String, ServiceCartEntry> _serviceCarts = {};

  Map<String, ServiceCartEntry> get serviceCarts => Map.unmodifiable(_serviceCarts);

  bool get hasItems => _serviceCarts.values.any((s) => s.items.isNotEmpty);

  int get itemCount => _serviceCarts.values.fold(0, (sum, s) => sum + s.itemCount);

  double get totalPrice => _serviceCarts.values.fold(0.0, (sum, s) => sum + s.subtotal);

  List<CartItem> get items => _serviceCarts.values.expand((s) => s.items).toList();

  // Legacy single-service compat
  String get serviceName =>
      _serviceCarts.values.isNotEmpty ? _serviceCarts.values.first.serviceName : '';

  Map<String, dynamic>? get checkoutArgs =>
      _serviceCarts.values.isNotEmpty ? _serviceCarts.values.first.checkoutArgs : null;

  Map<String, int> getQuantitiesForService(String serviceId) {
    final entry = _serviceCarts[serviceId];
    if (entry == null) return {};
    return {for (final item in entry.items) item.id: item.quantity};
  }

  Map<String, dynamic>? getCheckoutArgsForService(String serviceId) {
    return _serviceCarts[serviceId]?.checkoutArgs;
  }

  void updateService(
    String serviceId, {
    required String serviceName,
    required List<CartItem> items,
    Map<String, dynamic>? checkoutArgs,
  }) {
    if (items.isEmpty) {
      _serviceCarts.remove(serviceId);
    } else {
      _serviceCarts[serviceId] = ServiceCartEntry(
        serviceName: serviceName,
        items: List.of(items),
        checkoutArgs: checkoutArgs,
      );
    }
    notifyListeners();
  }

  void updateItemQuantity(String serviceId, String itemId, int delta) {
    final entry = _serviceCarts[serviceId];
    if (entry == null) return;

    final items = List.of(entry.items);
    final idx = items.indexWhere((item) => item.id == itemId);
    if (idx == -1) return;

    final current = items[idx];
    final newQty = current.quantity + delta;

    if (newQty <= 0) {
      items.removeAt(idx);
    } else {
      items[idx] = CartItem(
        id: current.id,
        name: current.name,
        quantity: newQty,
        unitPrice: current.unitPrice,
        imageUrl: current.imageUrl,
      );
    }

    _replaceServiceItems(serviceId, entry, items, itemId, newQty <= 0 ? 0 : newQty);
  }

  void removeItem(String serviceId, String itemId) {
    final entry = _serviceCarts[serviceId];
    if (entry == null) return;
    final items = entry.items.where((item) => item.id != itemId).toList();
    _replaceServiceItems(serviceId, entry, items, itemId, 0);
  }

  void _replaceServiceItems(
      String serviceId, ServiceCartEntry entry, List<CartItem> items, String changedItemId, int newQty) {
    Map<String, dynamic>? updatedArgs;
    if (entry.checkoutArgs != null) {
      final raw = entry.checkoutArgs!['serviceQuantities'];
      final serviceQtys = <String, int>{};
      if (raw is Map) {
        raw.forEach((k, v) => serviceQtys[k.toString()] = (v as num).toInt());
      }
      if (newQty <= 0) {
        serviceQtys.remove(changedItemId);
      } else {
        serviceQtys[changedItemId] = newQty;
      }
      updatedArgs = {
        ...entry.checkoutArgs!,
        'serviceQuantities': serviceQtys,
        'totalPrice': items.fold(0.0, (s, i) => s + i.subtotal),
      };
    }

    if (items.isEmpty) {
      _serviceCarts.remove(serviceId);
    } else {
      _serviceCarts[serviceId] = ServiceCartEntry(
        serviceName: entry.serviceName,
        items: items,
        checkoutArgs: updatedArgs,
      );
    }
    notifyListeners();
  }

  void clearService(String serviceId) {
    _serviceCarts.remove(serviceId);
    notifyListeners();
  }

  void clear() {
    _serviceCarts.clear();
    notifyListeners();
  }
}
