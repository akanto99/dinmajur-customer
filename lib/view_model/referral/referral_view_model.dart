import 'package:dinmajur_customer/data/response/api_response.dart';
import 'package:dinmajur_customer/model/coupon/coupon_model.dart';
import 'package:dinmajur_customer/model/referral/referral_model.dart';
import 'package:dinmajur_customer/respository/coupon_repository/coupon_repository.dart';
import 'package:dinmajur_customer/respository/referral_repository/referral_repository.dart';
import 'package:flutter/material.dart';

class ReferralViewModel with ChangeNotifier {
  final _myRepo = ReferralRepository();
  final _couponRepo = CouponRepository();

  ApiResponse<ReferralOverview> referralOverview = ApiResponse.loading();
  ApiResponse<List<AvailableCoupon>> myCoupons = ApiResponse.loading();

  void _setOverview(ApiResponse<ReferralOverview> response) {
    referralOverview = response;
    notifyListeners();
  }

  void _setCoupons(ApiResponse<List<AvailableCoupon>> response) {
    myCoupons = response;
    notifyListeners();
  }

  Future<void> fetchReferralOverview({bool forceRefresh = false}) async {
    _setOverview(ApiResponse.loading());
    try {
      final value = await _myRepo.getReferralOverviewApi();
      final overview = ReferralOverview.fromJson(value['data']);
      _setOverview(ApiResponse.completed(overview));
    } catch (error) {
      _setOverview(ApiResponse.error(error.toString()));
    }
  }

  /// Every coupon currently usable by this customer — includes coupons
  /// earned via the referral program (assigned specifically to them) as
  /// well as any public promo coupons, same set the checkout screens show.
  Future<void> fetchMyCoupons() async {
    _setCoupons(ApiResponse.loading());
    try {
      final value = await _couponRepo.getAvailableCouponsApi();
      final coupons = ((value['data'] as List<dynamic>?) ?? [])
          .map((e) => AvailableCoupon.fromJson(e as Map<String, dynamic>))
          .toList();
      _setCoupons(ApiResponse.completed(coupons));
    } catch (error) {
      _setCoupons(ApiResponse.error(error.toString()));
    }
  }
}
