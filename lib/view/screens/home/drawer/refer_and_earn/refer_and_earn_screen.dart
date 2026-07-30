import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/components/header_appbar.dart';
import 'package:dinmajur_customer/configs/res/sizedbox_spaccing.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:dinmajur_customer/configs/responsive/responsive_ui.dart';
import 'package:dinmajur_customer/configs/utils/routes/routes_name.dart';
import 'package:dinmajur_customer/configs/utils/utils.dart';
import 'package:dinmajur_customer/data/response/status.dart';
import 'package:dinmajur_customer/model/referral/referral_model.dart';
import 'package:dinmajur_customer/view/screens/home/helper_widgets/all_coupons_widget/all_coupons_widget.dart';
import 'package:dinmajur_customer/view_model/referral/referral_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

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
      Provider.of<ReferralViewModel>(context, listen: false).fetchReferralOverview();
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
    return RefreshIndicator(
      onRefresh: () {
        final vm = Provider.of<ReferralViewModel>(context, listen: false);
        return Future.wait([vm.fetchReferralOverview(), vm.fetchMyCoupons()]);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _heroCard(context, overview),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.05),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedboxSpaccing.height03(context),
                  _howItWorksCard(context),
                  SizedboxSpaccing.height02(context),
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, RoutesName.termsAndCondition),
                    child: Text(
                      '•  Terms and conditions',
                      style: AppTextStyles.textSize13(context, weight: FontWeight.w500, color: AppColors.buttonTextColor(context)),
                    ),
                  ),
                  SizedboxSpaccing.height03(context),
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
                  Text('All Coupons', style: AppTextStyles.textSize16(context, weight: FontWeight.w600)),
                  SizedboxSpaccing.height005(context),
                  Text(
                    'Registration bonus, referral rewards, and service offers — all in one place.',
                    style: AppTextStyles.textSize12(context, color: AppColors.subtitle(context)),
                  ),
                  SizedboxSpaccing.height01(context),
                  const AllCouponsWidget(),
                  SizedboxSpaccing.height02(context),
                  _earnReminderStrip(context),
                  SizedboxSpaccing.height02(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _heroCard(BuildContext context, ReferralOverview overview) {
    final screenWidth = MediaQuery.of(context).size.width;
    final code = overview.referralCode ?? '';
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final heroText = isDark ? Colors.white : const Color(0xFF1F2937);
    final heroSubtext = isDark ? Colors.white70 : const Color(0xFF4B5563);
    final heroDivider = isDark ? Colors.white24 : const Color(0xFFB9B4E8);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05, vertical: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark ? [const Color(0xFF2B2A4A), const Color(0xFF1E2F3D)] : [const Color(0xFFEEECFF), const Color(0xFFE3F1FF)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Invite your friends to try Dinmajur services. They get a reward coupon instantly. You win a coupon once they take a service.',
            style: AppTextStyles.textSize14(context, color: heroSubtext),
          ),
          SizedboxSpaccing.height02(context),
          Row(
            children: [
              Expanded(
                child: Text(
                  code,
                  style: AppTextStyles.textSize24(context, weight: FontWeight.w700, color: heroText),
                ),
              ),
              GestureDetector(
                onTap: () => _copyCode(context, code),
                child: Icon(Icons.copy_rounded, color: heroText, size: 22),
              ),
            ],
          ),
          SizedboxSpaccing.height02(context),
          Row(
            children: [
              Expanded(child: Divider(color: heroDivider)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text('Refer via', style: AppTextStyles.textSize13(context, color: heroSubtext)),
              ),
              Expanded(child: Divider(color: heroDivider)),
            ],
          ),
          SizedboxSpaccing.height02(context),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _shareButton(
                context,
                icon: FontAwesomeIcons.whatsapp,
                iconColor: const Color(0xFF25D366),
                label: 'Whatsapp',
                onTap: () => _shareViaWhatsApp(overview),
              ),
              _shareButton(
                context,
                icon: FontAwesomeIcons.facebookMessenger,
                iconColor: const Color(0xFF0084FF),
                label: 'Messenger',
                onTap: () => _shareViaMessenger(overview),
              ),
              _shareButton(
                context,
                icon: Icons.link_rounded,
                iconColor: Colors.white,
                circleColor: AppColors.button(context),
                label: 'Copy Link',
                onTap: () => _copyLink(context, overview.referralLink ?? ''),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// WhatsApp/Messenger use a neutral circle with the brand's own icon
  /// color; Copy Link passes a solid `circleColor` (the app's brand color)
  /// with a white icon instead, matching the reference design.
  Widget _shareButton(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String label,
    required VoidCallback onTap,
    Color? circleColor,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: circleColor ?? (isDark ? Colors.white.withOpacity(0.12) : Colors.white),
              shape: BoxShape.circle,
              border: circleColor == null ? Border.all(color: AppColors.border(context)) : null,
            ),
            child: Center(child: Icon(icon, color: iconColor, size: 24)),
          ),
          SizedboxSpaccing.height005(context),
          Text(label, style: AppTextStyles.textSize12(context, color: AppColors.subtitle(context))),
        ],
      ),
    );
  }

  Widget _howItWorksCard(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF20263A) : const Color(0xFFEDEFFC),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('How it works?', style: AppTextStyles.textSize18(context, weight: FontWeight.w700)),
          SizedboxSpaccing.height02(context),
          _stepRow(context, number: 1, text: 'Invite your friends & get rewarded', isLast: false),
          _stepRow(context, number: 2, text: 'They get a coupon on their first service', isLast: false),
          _stepRow(context, number: 3, text: 'You get a coupon once their service is completed', isLast: true),
        ],
      ),
    );
  }

  Widget _stepRow(BuildContext context, {required int number, required String text, required bool isLast}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final circleColor = isDark ? Colors.white24 : const Color(0xFFE0E0E6);
    final numberColor = isDark ? Colors.white : const Color(0xFF1F2937);
    final connectorColor = isDark ? Colors.white24 : const Color(0xFFD1D1D8);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(color: circleColor, shape: BoxShape.circle),
                child: Center(
                  child: Text(
                    '$number',
                    style: AppTextStyles.textSize13(context, weight: FontWeight.w700, color: numberColor),
                  ),
                ),
              ),
              if (!isLast) Expanded(child: Container(width: 2, color: connectorColor)),
            ],
          ),
          SizedboxSpaccing.width03(context),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 24, top: 3),
              child: Text(text, style: AppTextStyles.textSize14(context, weight: FontWeight.w500)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _earnReminderStrip(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.button(context).withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Text('🎁', style: TextStyle(fontSize: 18)),
          SizedboxSpaccing.width02(context),
          Expanded(
            child: Text(
              'Earn a coupon on every successful referral',
              style: AppTextStyles.textSize13(context, weight: FontWeight.w500),
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
    if (link.isEmpty) return;
    Clipboard.setData(ClipboardData(text: link));
    Utils.flushBarSuccessMessage('Referral link copied', context);
  }

  Future<void> _shareViaWhatsApp(ReferralOverview overview) async {
    final message = overview.referralLink != null
        ? 'Join Dinmajur using my referral code ${overview.referralCode} — we\'ll both get a reward coupon right away! ${overview.referralLink}'
        : 'Join Dinmajur using my referral code ${overview.referralCode}!';
    final uri = Uri.parse('https://wa.me/?text=${Uri.encodeComponent(message)}');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else if (mounted) {
        Utils.flushBarErrorMessage('WhatsApp not available', context);
      }
    } catch (_) {
      if (mounted) Utils.flushBarErrorMessage('WhatsApp not available', context);
    }
  }

  Future<void> _shareViaMessenger(ReferralOverview overview) async {
    final link = overview.referralLink;
    if (link == null || link.isEmpty) {
      Utils.flushBarErrorMessage('Referral link not available', context);
      return;
    }
    final uri = Uri.parse('fb-messenger://share?link=${Uri.encodeComponent(link)}');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else if (mounted) {
        Utils.flushBarErrorMessage('Messenger not installed', context);
      }
    } catch (_) {
      if (mounted) Utils.flushBarErrorMessage('Messenger not installed', context);
    }
  }
}
