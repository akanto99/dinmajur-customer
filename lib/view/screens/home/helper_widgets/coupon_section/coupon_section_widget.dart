import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:dinmajur_customer/model/coupon/coupon_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// "Have a coupon?" apply box + a browsable list of coupons available for
/// this service, each copyable and marked "Used" once the customer has
/// exhausted their per-user limit on it. Shared across every checkout
/// screen so this UI/behavior stays identical everywhere.
class CouponSectionWidget extends StatelessWidget {
  final TextEditingController controller;
  final String? appliedCouponCode;
  final String? couponError;
  final bool isValidatingCoupon;
  final List<AvailableCoupon> availableCoupons;
  final bool isLoadingAvailableCoupons;
  final VoidCallback onApply;
  final VoidCallback onRemove;
  final ValueChanged<String> onSelectCoupon;

  const CouponSectionWidget({
    super.key,
    required this.controller,
    required this.appliedCouponCode,
    required this.couponError,
    required this.isValidatingCoupon,
    required this.availableCoupons,
    required this.isLoadingAvailableCoupons,
    required this.onApply,
    required this.onRemove,
    required this.onSelectCoupon,
  });

  void _copyCode(BuildContext context, String code) {
    Clipboard.setData(ClipboardData(text: code));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Copied "$code"'),
        duration: const Duration(seconds: 2),
        backgroundColor: AppColors.button(context),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool hasApplied = appliedCouponCode != null;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.containerBackground(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.local_offer_outlined, size: 18, color: AppColors.button(context)),
              const SizedBox(width: 6),
              Text('Have a coupon?', style: AppTextStyles.textSize14(context, weight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 10),
          if (hasApplied)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.08),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, size: 18, color: Colors.green),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '$appliedCouponCode applied',
                      style: AppTextStyles.textSize14(context, weight: FontWeight.w600, color: Colors.green),
                    ),
                  ),
                  TextButton(
                    onPressed: onRemove,
                    style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(0, 0)),
                    child: Text('Remove', style: AppTextStyles.textSize13(context, color: Colors.red)),
                  ),
                ],
              ),
            )
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    textCapitalization: TextCapitalization.characters,
                    style: AppTextStyles.textSize14(context, weight: FontWeight.w500),
                    decoration: InputDecoration(
                      hintText: 'Enter coupon code',
                      isDense: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: AppColors.border(context)),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  height: 44,
                  child: ElevatedButton(
                    onPressed: isValidatingCoupon ? null : onApply,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.button(context),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: isValidatingCoupon
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : Text('Apply', style: AppTextStyles.textSize14(context, weight: FontWeight.w600, color: Colors.white)),
                  ),
                ),
              ],
            ),
          if (couponError != null) ...[
            const SizedBox(height: 6),
            Text(couponError!, style: AppTextStyles.textSize12(context, color: Colors.red)),
          ],
          if (isLoadingAvailableCoupons) ...[
            const SizedBox(height: 14),
            Center(
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.button(context)),
              ),
            ),
          ] else if (availableCoupons.isNotEmpty) ...[
            const SizedBox(height: 14),
            Text(
              'Available Coupons',
              style: AppTextStyles.textSize13(context, weight: FontWeight.w600, color: AppColors.subtitle(context)),
            ),
            const SizedBox(height: 8),
            ...availableCoupons.map((c) => _buildCouponCard(context, c)),
          ],
        ],
      ),
    );
  }

  Widget _buildCouponCard(BuildContext context, AvailableCoupon coupon) {
    final bool isUsedUp = coupon.maxedOutByCustomer;
    final bool isApplied = appliedCouponCode == coupon.code;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isUsedUp
            ? AppColors.containerBackground(context)
            : AppColors.button(context).withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: isApplied ? Colors.green : AppColors.border(context)),
      ),
      child: Opacity(
        opacity: isUsedUp ? 0.55 : 1,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          coupon.code,
                          style: AppTextStyles.textSize14(context, weight: FontWeight.w700).copyWith(letterSpacing: 0.5),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: () => _copyCode(context, coupon.code),
                        child: Icon(Icons.copy_rounded, size: 15, color: AppColors.subtitle(context)),
                      ),
                      if (isUsedUp) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.25),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Used',
                            style: AppTextStyles.textSize10(context, weight: FontWeight.w600, color: Colors.grey.shade700),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    coupon.discountLabel,
                    style: AppTextStyles.textSize13(context, weight: FontWeight.w600, color: AppColors.button(context)),
                  ),
                  if (coupon.minBookingAmount != null)
                    Text(
                      'Min. order ৳${coupon.minBookingAmount!.toStringAsFixed(0)}',
                      style: AppTextStyles.textSize11(context, color: AppColors.subtitle(context)),
                    ),
                ],
              ),
            ),
            if (!isUsedUp)
              GestureDetector(
                onTap: () => onSelectCoupon(coupon.code),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isApplied ? Colors.green : AppColors.button(context),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    isApplied ? 'Applied' : 'Apply',
                    style: AppTextStyles.textSize12(context, weight: FontWeight.w600, color: Colors.white),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
