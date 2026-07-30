import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/sizedbox_spaccing.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:dinmajur_customer/configs/utils/utils.dart';
import 'package:dinmajur_customer/data/response/status.dart';
import 'package:dinmajur_customer/model/coupon/coupon_model.dart';
import 'package:dinmajur_customer/view_model/referral/referral_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';

/// Every coupon the customer can currently use — registration bonus,
/// referral rewards, and public service coupons all come back from the
/// same `/coupons/available` call, so they render here as one combined
/// list. Reused by the Refer & Earn screen and the drawer's Offers screen
/// so both surfaces show the same set instead of duplicating the fetch.
class AllCouponsWidget extends StatefulWidget {
  const AllCouponsWidget({super.key});

  @override
  State<AllCouponsWidget> createState() => _AllCouponsWidgetState();
}

class _AllCouponsWidgetState extends State<AllCouponsWidget> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ReferralViewModel>(context, listen: false).fetchMyCoupons();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ReferralViewModel>(
      builder: (context, vm, _) {
        switch (vm.myCoupons.status) {
          case Status.LOADING:
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: LoadingAnimationWidget.progressiveDots(color: AppColors.button(context), size: 32),
              ),
            );
          case Status.ERROR:
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: GestureDetector(
                  onTap: () => vm.fetchMyCoupons(),
                  child: Icon(Icons.restart_alt_outlined, size: 26, color: AppColors.subtitle(context)),
                ),
              ),
            );
          case Status.COMPLETED:
            final coupons = vm.myCoupons.data ?? [];
            if (coupons.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: Text(
                    'No coupons yet — earn one by referring a friend or checking back for offers.',
                    style: AppTextStyles.textSize13(context, color: AppColors.subtitle(context)),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }
            return Column(children: coupons.map((c) => _couponCard(context, c)).toList());
          default:
            return const SizedBox.shrink();
        }
      },
    );
  }

  Widget _couponCard(BuildContext context, AvailableCoupon coupon) {
    final bool isUsedUp = coupon.maxedOutByCustomer;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isUsedUp ? AppColors.containerBackground(context) : AppColors.button(context).withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Opacity(
        opacity: isUsedUp ? 0.55 : 1,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (coupon.name.isNotEmpty) ...[
              Text(
                coupon.name,
                style: AppTextStyles.textSize13(context, weight: FontWeight.w600),
              ),
              SizedboxSpaccing.height005(context),
            ],
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
                    decoration: BoxDecoration(color: Colors.grey.withOpacity(0.25), borderRadius: BorderRadius.circular(4)),
                    child: Text('Used', style: AppTextStyles.textSize10(context, weight: FontWeight.w600, color: Colors.grey.shade700)),
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
            if (coupon.validUntil != null)
              Text(
                'Expires ${coupon.validUntil!.toLocal().toString().split(' ').first}',
                style: AppTextStyles.textSize11(context, color: AppColors.subtitle(context)),
              ),
          ],
        ),
      ),
    );
  }

  void _copyCode(BuildContext context, String code) {
    if (code.isEmpty) return;
    Clipboard.setData(ClipboardData(text: code));
    Utils.flushBarSuccessMessage('Coupon code copied', context);
  }
}
