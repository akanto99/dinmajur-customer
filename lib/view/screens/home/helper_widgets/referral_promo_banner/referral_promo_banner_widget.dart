import 'package:dinmajur_customer/configs/res/sizedbox_spaccing.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:dinmajur_customer/configs/utils/routes/routes_name.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Bottom-of-home-screen promo card that opens the Refer & Earn screen.
///
/// The gift-box/ribbon/sparkle illustration is a hand-drawn SVG asset
/// (assets/images/home/refer_banner_illustration.svg) used as the card's
/// full background — it's a fixed light-pastel graphic, so the overlaid
/// text uses hardcoded dark colors instead of the theme-driven text
/// styles (which would turn white and disappear in dark mode).
class ReferralPromoBannerWidget extends StatelessWidget {
  final double screenWidth;

  const ReferralPromoBannerWidget({super.key, required this.screenWidth});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
      child: GestureDetector(
        onTap: () => Navigator.pushNamed(context, RoutesName.referAndEarn),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: SizedBox(
            width: double.infinity,
            height: 120,
            child: Stack(
              fit: StackFit.expand,
              children: [
                SvgPicture.asset(
                  'assets/images/home/refer_banner_illustration.svg',
                  fit: BoxFit.cover,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Refer and get\nfree services',
                        style: AppTextStyles.textSize18(context, weight: FontWeight.w700, color: const Color(0xFF1F2937)),
                      ),
                      SizedboxSpaccing.height01(context),
                      Text(
                        'Invite and get coupon',
                        style: AppTextStyles.textSize13(context, weight: FontWeight.w500, color: const Color(0xFF4B5563)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
