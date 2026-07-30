import 'dart:convert';

import 'package:dinmajur_customer/model/coupon/coupon_model.dart';
import 'package:dinmajur_customer/respository/coupon_repository/coupon_repository.dart';
import 'package:flutter/material.dart';

/// Shared "apply a coupon at checkout" state/behavior, mixed into each
/// vertical's own checkout ChangeNotifier (matching this app's convention of
/// narrow per-screen view-models rather than one global provider).
mixin CouponStateMixin on ChangeNotifier {
  final CouponRepository _couponRepository = CouponRepository();

  String? _appliedCouponCode;
  double _couponDiscountAmount = 0;
  String? _couponError;
  bool _isValidatingCoupon = false;
  List<AvailableCoupon> _availableCoupons = [];
  bool _isLoadingAvailableCoupons = false;
  List<AvailableCoupon> _publicCoupons = [];
  bool _isLoadingPublicCoupons = false;

  String? get appliedCouponCode => _appliedCouponCode;
  double get couponDiscountAmount => _couponDiscountAmount;
  String? get couponError => _couponError;
  bool get isValidatingCoupon => _isValidatingCoupon;
  List<AvailableCoupon> get availableCoupons => _availableCoupons;
  bool get isLoadingAvailableCoupons => _isLoadingAvailableCoupons;
  List<AvailableCoupon> get publicCoupons => _publicCoupons;
  bool get isLoadingPublicCoupons => _isLoadingPublicCoupons;

  Future<void> applyCoupon({
    required String code,
    required double amount,
    String? serviceId,
    String? serviceKey,
  }) async {
    if (code.trim().isEmpty) return;
    _isValidatingCoupon = true;
    _couponError = null;
    notifyListeners();
    try {
      final response = await _couponRepository.validateCouponPostApi({
        'code': code.trim(),
        if (serviceId != null) 'serviceId': serviceId,
        if (serviceKey != null) 'serviceKey': serviceKey,
        'amount': amount,
      });
      final result = CouponValidationResult.fromJson(response['data']);
      _appliedCouponCode = result.code ?? code.trim().toUpperCase();
      _couponDiscountAmount = result.discountAmount;
      _couponError = null;
    } catch (e) {
      _appliedCouponCode = null;
      _couponDiscountAmount = 0;
      _couponError = _extractCouponErrorMessage(e);
    } finally {
      _isValidatingCoupon = false;
      notifyListeners();
    }
  }

  void removeCoupon() {
    _appliedCouponCode = null;
    _couponDiscountAmount = 0;
    _couponError = null;
    notifyListeners();
  }

  Future<void> fetchPublicCoupons({String? serviceId, String? serviceKey}) async {
    _isLoadingPublicCoupons = true;
    notifyListeners();
    try {
      final response = await _couponRepository.getPublicCouponsApi(serviceId: serviceId, serviceKey: serviceKey);
      final List<dynamic> data = response['data'] ?? [];
      _publicCoupons = data.map((e) => AvailableCoupon.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      _publicCoupons = [];
    } finally {
      _isLoadingPublicCoupons = false;
      notifyListeners();
    }
  }

  Future<void> fetchAvailableCoupons({String? serviceId, String? serviceKey}) async {
    _isLoadingAvailableCoupons = true;
    notifyListeners();
    try {
      final response = await _couponRepository.getAvailableCouponsApi(serviceId: serviceId, serviceKey: serviceKey);
      final List<dynamic> data = response['data'] ?? [];
      _availableCoupons = data.map((e) => AvailableCoupon.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      _availableCoupons = [];
    } finally {
      _isLoadingAvailableCoupons = false;
      notifyListeners();
    }
  }
  void resetCoupon() {
    _appliedCouponCode = null;
    _couponDiscountAmount = 0;
    _couponError = null;
    notifyListeners();
  }

  String _extractCouponErrorMessage(dynamic error) {
    String errorMessage = 'Invalid coupon code';
    try {
      final errorBody = error.toString();
      final jsonStartIndex = errorBody.indexOf('{');
      if (jsonStartIndex != -1) {
        final decoded = jsonDecode(errorBody.substring(jsonStartIndex));
        errorMessage = decoded['message'] ?? errorMessage;
      }
    } catch (_) {}
    return errorMessage;
  }
}
