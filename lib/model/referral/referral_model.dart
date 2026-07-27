class MyReferralCode {
  final String? referralCode;
  final String? referralLink;
  final String? shareText;

  MyReferralCode({this.referralCode, this.referralLink, this.shareText});

  factory MyReferralCode.fromJson(Map<String, dynamic> json) {
    return MyReferralCode(
      referralCode: json['referralCode'],
      referralLink: json['referralLink'],
      shareText: json['shareText'],
    );
  }
}

class ReferralStats {
  final int totalReferred;
  final int rewarded;
  final int pending;

  ReferralStats({this.totalReferred = 0, this.rewarded = 0, this.pending = 0});

  factory ReferralStats.fromJson(Map<String, dynamic>? json) {
    if (json == null) return ReferralStats();
    return ReferralStats(
      totalReferred: json['totalReferred'] ?? 0,
      rewarded: json['rewarded'] ?? 0,
      pending: json['pending'] ?? 0,
    );
  }
}

class ReferredUser {
  final String? id;
  final String firstName;
  final String lastName;
  final String phone;
  final String? joinedAt;
  final String status; // PENDING | REWARDED

  ReferredUser({
    this.id,
    this.firstName = '',
    this.lastName = '',
    this.phone = '',
    this.joinedAt,
    this.status = 'PENDING',
  });

  String get displayName {
    final name = '$firstName $lastName'.trim();
    return name.isEmpty ? phone : name;
  }

  factory ReferredUser.fromJson(Map<String, dynamic> json) {
    return ReferredUser(
      id: json['_id'],
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      phone: json['phone'] ?? '',
      joinedAt: json['joinedAt'],
      status: json['status'] ?? 'PENDING',
    );
  }
}

/// The coupon handed to the referee the moment they successfully apply a
/// referral code — rewards are immediate, not tied to a later order.
class AppliedReferralCoupon {
  final String code;
  final String discountType;
  final double discountValue;
  final double? maxDiscountAmount;
  final double? minBookingAmount;
  final DateTime? validUntil;

  AppliedReferralCoupon({
    required this.code,
    required this.discountType,
    required this.discountValue,
    this.maxDiscountAmount,
    this.minBookingAmount,
    this.validUntil,
  });

  factory AppliedReferralCoupon.fromJson(Map<String, dynamic> json) {
    return AppliedReferralCoupon(
      code: json['code'] ?? '',
      discountType: json['discountType'] ?? 'FIXED',
      discountValue: (json['discountValue'] ?? 0).toDouble(),
      maxDiscountAmount: json['maxDiscountAmount'] != null ? (json['maxDiscountAmount']).toDouble() : null,
      minBookingAmount: json['minBookingAmount'] != null ? (json['minBookingAmount']).toDouble() : null,
      validUntil: json['validUntil'] != null ? DateTime.tryParse(json['validUntil']) : null,
    );
  }

  String get discountLabel =>
      discountType == 'PERCENTAGE' ? '${discountValue.toStringAsFixed(0)}% OFF' : '৳${discountValue.toStringAsFixed(0)} OFF';
}

class ReferralOverview {
  final String? referralCode;
  final String? referralLink;
  final ReferralStats stats;
  final List<ReferredUser> referrals;

  ReferralOverview({
    this.referralCode,
    this.referralLink,
    required this.stats,
    this.referrals = const [],
  });

  factory ReferralOverview.fromJson(Map<String, dynamic> json) {
    return ReferralOverview(
      referralCode: json['referralCode'],
      referralLink: json['referralLink'],
      stats: ReferralStats.fromJson(json['stats']),
      referrals: (json['referrals'] as List<dynamic>? ?? [])
          .map((e) => ReferredUser.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
