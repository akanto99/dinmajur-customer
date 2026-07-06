import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

/// Recursively converts arbitrary cart data (model objects, Sets, DateTimes,
/// callbacks) into JSON-safe primitives so the cart can survive an app
/// restart. Objects exposing `toJson()` (all API model classes in this app)
/// are unwrapped via dynamic dispatch so this provider doesn't need to
/// depend on every service's model types.
dynamic _sanitizeForStorage(dynamic value) {
  if (value == null || value is String || value is num || value is bool) return value;
  if (value is Function) return null;
  if (value is DateTime) return value.toIso8601String();
  if (value is Set) return value.map(_sanitizeForStorage).toList();
  if (value is Map) return value.map((k, v) => MapEntry(k.toString(), _sanitizeForStorage(v)));
  if (value is List) return value.map(_sanitizeForStorage).toList();
  try {
    return _sanitizeForStorage((value as dynamic).toJson());
  } catch (_) {
    return null;
  }
}

Map<String, dynamic>? _sanitizeCheckoutArgs(Map<String, dynamic>? args) {
  if (args == null) return null;
  final result = <String, dynamic>{};
  args.forEach((key, value) {
    if (value is Function) return;
    result[key] = _sanitizeForStorage(value);
  });
  return result;
}

class GlobalCartProvider extends ChangeNotifier {
  static const _prefsKey = 'global_cart_v1';

  final Map<String, ServiceCartEntry> _serviceCarts = {};
  bool _hydrated = false;

  /// Restores previously saved cart contents from disk. Call once at app
  /// startup; safe to call multiple times.
  Future<void> hydrate() async {
    if (_hydrated) return;
    _hydrated = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefsKey);
      if (raw == null || raw.isEmpty) return;

      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      decoded.forEach((serviceId, value) {
        final entryMap = value as Map<String, dynamic>;
        final items = (entryMap['items'] as List? ?? [])
            .map((i) => CartItem(
                  id: i['id'] as String? ?? '',
                  name: i['name'] as String? ?? '',
                  quantity: (i['quantity'] as num?)?.toInt() ?? 0,
                  unitPrice: (i['unitPrice'] as num?)?.toDouble() ?? 0,
                  imageUrl: i['imageUrl'] as String?,
                ))
            .toList();
        if (items.isEmpty) return;

        _serviceCarts[serviceId] = ServiceCartEntry(
          serviceName: entryMap['serviceName'] as String? ?? '',
          items: items,
          checkoutArgs: (entryMap['checkoutArgs'] as Map?)?.cast<String, dynamic>(),
        );
      });
      notifyListeners();
    } catch (_) {
      // Corrupt or incompatible cache — start with an empty cart rather than crash.
    }
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final payload = <String, dynamic>{};
      _serviceCarts.forEach((serviceId, entry) {
        payload[serviceId] = {
          'serviceName': entry.serviceName,
          'items': entry.items
              .map((i) => {
                    'id': i.id,
                    'name': i.name,
                    'quantity': i.quantity,
                    'unitPrice': i.unitPrice,
                    'imageUrl': i.imageUrl,
                  })
              .toList(),
          'checkoutArgs': _sanitizeCheckoutArgs(entry.checkoutArgs),
        };
      });
      await prefs.setString(_prefsKey, jsonEncode(payload));
    } catch (_) {
      // Best-effort persistence; losing a write shouldn't crash the app.
    }
  }

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
    _persist();
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
    _persist();
  }

  void clearService(String serviceId) {
    _serviceCarts.remove(serviceId);
    notifyListeners();
    _persist();
  }

  void clear() {
    _serviceCarts.clear();
    notifyListeners();
    _persist();
  }
}
