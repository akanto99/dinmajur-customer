import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/components/header_appbar.dart';
import 'package:dinmajur_customer/configs/res/sizedbox_spaccing.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:dinmajur_customer/configs/responsive/responsive_ui.dart';
import 'package:dinmajur_customer/configs/utils/utils.dart';
import 'package:dinmajur_customer/data/response/status.dart';
import 'package:dinmajur_customer/model/coupon/coupon_model.dart';
import 'package:dinmajur_customer/model/referral/referral_model.dart';
import 'package:dinmajur_customer/view_model/referral/referral_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

class ReferAndEarnScreen extends StatefulWidget {
  const ReferAndEarnScreen({super.key});

  @override
  State<ReferAndEarnScreen> createState() => _ReferAndEarnScreenState();
}

class _ReferAndEarnScreenState extends State<ReferAndEarnScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = Provider.of<ReferralViewModel>(context, listen: false);
      vm.fetchReferralOverview();
      vm.fetchMyCoupons();
    });
  }

  @override
  Widget build(BuildContext context) {
    final body = _body();
    return Scaffold(
      backgroundColor: AppColors.containerBackground(context),
      body: SafeArea(
        child: ResPonsiveUi(mobile: body, desktop: body, tablet: body),
      ),
    );
  }

  Widget _body() {
    return Column(
      children: [
        GestureDetector(onTap: () => Navigator.pop(context), child: AppBarHeader('Referral')),
        Expanded(
          child: Consumer<ReferralViewModel>(
            builder: (context, vm, _) {
              switch (vm.referralOverview.status) {
                case Status.LOADING:
                  return Center(
                    child: LoadingAnimationWidget.progressiveDots(color: AppColors.button(context), size: 45),
                  );
                case Status.ERROR:
                  return Center(
                    child: GestureDetector(
                      onTap: () => vm.fetchReferralOverview(),
                      child: Icon(Icons.restart_alt_outlined, size: 30, color: AppColors.subtitle(context)),
                    ),
                  );
                case Status.COMPLETED:
                  final overview = vm.referralOverview.data;
                  if (overview == null) return const SizedBox.shrink();
                  return _content(context, overview);
                default:
                  return const SizedBox.shrink();
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _content(BuildContext context, ReferralOverview overview) {
    final screenWidth = MediaQuery.of(context).size.width;

    return RefreshIndicator(
      onRefresh: () {
        final vm = Provider.of<ReferralViewModel>(context, listen: false);
        return Future.wait([vm.fetchReferralOverview(), vm.fetchMyCoupons()]);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Share your code with friends. The moment they apply it, you both get a reward coupon.',
              style: AppTextStyles.textSize14(context, color: AppColors.subtitle(context)),
            ),
            SizedboxSpaccing.height02(context),
            _codeCard(context, overview),
            SizedboxSpaccing.height02(context),
            Row(
              children: [
                Expanded(child: _statTile(context, 'Referred', overview.stats.totalReferred.toString())),
                SizedboxSpaccing.width03(context),
                Expanded(child: _statTile(context, 'Pending', overview.stats.pending.toString())),
                SizedboxSpaccing.width03(context),
                Expanded(child: _statTile(context, 'Rewarded', overview.stats.rewarded.toString())),
              ],
            ),
            SizedboxSpaccing.height03(context),
            Text('Your referrals', style: AppTextStyles.textSize16(context, weight: FontWeight.w600)),
            SizedboxSpaccing.height01(context),
            if (overview.referrals.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: Text(
                    'No referrals yet — share your code to get started.',
                    style: AppTextStyles.textSize13(context, color: AppColors.subtitle(context)),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            else
              ...overview.referrals.map((r) => _referralRow(context, r)),
            SizedboxSpaccing.height03(context),
            Text('My coupons', style: AppTextStyles.textSize16(context, weight: FontWeight.w600)),
            SizedboxSpaccing.height01(context),
            _couponsSection(context),
          ],
        ),
      ),
    );
  }

  Widget _couponsSection(BuildContext context) {
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
                    'No coupons yet — earn one by referring a friend.',
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
          ],
        ),
      ),
    );
  }

  Widget _codeCard(BuildContext context, ReferralOverview overview) {
    final code = overview.referralCode ?? '';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.button(context).withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.button(context).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Your referral code', style: AppTextStyles.textSize13(context, color: AppColors.subtitle(context))),
          SizedboxSpaccing.height01(context),
          Row(
            children: [
              Expanded(
                child: Text(
                  code,
                  style: AppTextStyles.textSize24(context, weight: FontWeight.w700),
                ),
              ),
              GestureDetector(
                onTap: () => _copyCode(context, code),
                child: Icon(Icons.copy_rounded, color: AppColors.button(context), size: 22),
              ),
            ],
          ),
          if (overview.referralLink != null) ...[
            SizedboxSpaccing.height01(context),
            GestureDetector(
              onTap: () => _copyLink(context, overview.referralLink!),
              child: Row(
                children: [
                  Icon(Icons.link_rounded, size: 15, color: AppColors.subtitle(context)),
                  SizedboxSpaccing.width01(context),
                  Expanded(
                    child: Text(
                      overview.referralLink!,
                      style: AppTextStyles.textSize12(context, color: AppColors.subtitle(context)),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    'Copy',
                    style: AppTextStyles.textSize12(context, weight: FontWeight.w600, color: AppColors.button(context)),
                  ),
                ],
              ),
            ),
          ],
          SizedboxSpaccing.height02(context),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.button(context),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: code.isEmpty ? null : () => _shareCode(overview),
              icon: const Icon(Icons.share_rounded, size: 18, color: Colors.white),
              label: Text('Share invite link', style: AppTextStyles.textSize14(context, weight: FontWeight.w600, color: AppColors.whiteColor)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statTile(BuildContext context, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.textFieldFill(context),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(value, style: AppTextStyles.textSize18(context, weight: FontWeight.w700)),
          SizedboxSpaccing.height005(context),
          Text(label, style: AppTextStyles.textSize11(context, color: AppColors.subtitle(context))),
        ],
      ),
    );
  }

  Widget _referralRow(BuildContext context, ReferredUser user) {
    final isRewarded = user.status == 'REWARDED';
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border(context)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(user.displayName, style: AppTextStyles.textSize14(context, weight: FontWeight.w500)),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: (isRewarded ? Colors.green : Colors.orange).withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              isRewarded ? 'Rewarded' : 'Pending',
              style: AppTextStyles.textSize11(context, weight: FontWeight.w600, color: isRewarded ? Colors.green : Colors.orange),
            ),
          ),
        ],
      ),
    );
  }

  void _copyCode(BuildContext context, String code) {
    if (code.isEmpty) return;
    Clipboard.setData(ClipboardData(text: code));
    Utils.flushBarSuccessMessage('Referral code copied', context);
  }

  void _copyLink(BuildContext context, String link) {
    Clipboard.setData(ClipboardData(text: link));
    Utils.flushBarSuccessMessage('Referral link copied', context);
  }

  void _shareCode(ReferralOverview overview) {
    final text = overview.referralLink != null
        ? 'Join Dinmajur using my referral code ${overview.referralCode} — we\'ll both get a reward coupon right away! ${overview.referralLink}'
        : 'Join Dinmajur using my referral code ${overview.referralCode}!';
    Share.share(text);
  }
}
