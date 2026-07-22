class CouponValidationResult {
  final bool valid;
  final double discountAmount;
  final String? code;
  final String? name;
  final String? discountType;
  final double? discountValue;

  CouponValidationResult({
    required this.valid,
    required this.discountAmount,
    this.code,
    this.name,
    this.discountType,
    this.discountValue,
  });

  factory CouponValidationResult.fromJson(Map<String, dynamic> json) {
    final coupon = json['coupon'] as Map<String, dynamic>?;
    return CouponValidationResult(
      valid: json['valid'] ?? false,
      discountAmount: (json['discountAmount'] ?? 0).toDouble(),
      code: coupon?['code'],
      name: coupon?['name'],
      discountType: coupon?['discountType'],
      discountValue: coupon?['discountValue'] != null ? (coupon!['discountValue']).toDouble() : null,
    );
  }
}

/// A coupon shown in the "have a coupon?" browse list — one entry per
/// coupon currently usable for the service being checked out.
class AvailableCoupon {
  final String code;
  final String name;
  final String discountType;
  final double discountValue;
  final double? maxDiscountAmount;
  final double? minBookingAmount;
  final DateTime? validUntil;
  final bool usedByCustomer;
  final bool maxedOutByCustomer;

  AvailableCoupon({
    required this.code,
    required this.name,
    required this.discountType,
    required this.discountValue,
    this.maxDiscountAmount,
    this.minBookingAmount,
    this.validUntil,
    required this.usedByCustomer,
    required this.maxedOutByCustomer,
  });

  factory AvailableCoupon.fromJson(Map<String, dynamic> json) {
    return AvailableCoupon(
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      discountType: json['discountType'] ?? 'FIXED',
      discountValue: (json['discountValue'] ?? 0).toDouble(),
      maxDiscountAmount: json['maxDiscountAmount'] != null ? (json['maxDiscountAmount']).toDouble() : null,
      minBookingAmount: json['minBookingAmount'] != null ? (json['minBookingAmount']).toDouble() : null,
      validUntil: json['validUntil'] != null ? DateTime.tryParse(json['validUntil']) : null,
      usedByCustomer: json['usedByCustomer'] ?? false,
      maxedOutByCustomer: json['maxedOutByCustomer'] ?? false,
    );
  }

  /// e.g. "20% OFF" or "৳100 OFF"
  String get discountLabel =>
      discountType == 'PERCENTAGE' ? '${discountValue.toStringAsFixed(0)}% OFF' : '৳${discountValue.toStringAsFixed(0)} OFF';
}
