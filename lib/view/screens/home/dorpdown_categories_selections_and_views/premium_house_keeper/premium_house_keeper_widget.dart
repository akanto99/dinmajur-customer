import 'package:dinmajur_customer/configs/buttons/round_button.dart';
import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/sizedbox_spaccing.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:dinmajur_customer/configs/utils/routes/routes_name.dart';
import 'package:dinmajur_customer/configs/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class PremiumHouseKeeperSection extends StatelessWidget {
  const PremiumHouseKeeperSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Column(
      children: [
        // House Keeper Service Card
        Container(
          width: screenWidth * 0.9,
          padding: EdgeInsets.all(screenHeight * 0.025),
          decoration: BoxDecoration(
            color: AppColors.containerBackground(context),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(width: 1, color: AppColors.oceanGreenColor),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left side - Icon and Title
                  Row(
                    children: [
                      Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(color: AppColors.textPrimary(context), borderRadius: BorderRadius.circular(6)),
                        child: Icon(FontAwesomeIcons.houseChimneyUser, color: AppColors.containerBackground(context), size: 16),
                      ),
                      SizedboxSpaccing.width03(context),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "House Keeper",
                            style: AppTextStyles.textSize18(context, weight: FontWeight.w500, color: AppColors.button(context)),
                          ),
                          Text(
                            "Dinmajur Premium",
                            style: AppTextStyles.textSize14(context, weight: FontWeight.w400, color: AppColors.subtitle(context)),
                          ),
                        ],
                      ),
                    ],
                  ),
                  // Right side - Available Badge
                  Container(
                    height: 24,
                    width: 70,
                    decoration: BoxDecoration(color: AppColors.oceanGreenColor, borderRadius: BorderRadius.circular(100)),
                    child: Center(
                      child: Text(
                        "Available",
                        style: AppTextStyles.textSize10(context, color: AppColors.whiteColor, weight: FontWeight.w500),
                      ),
                    ),
                  ),
                ],
              ),
              SizedboxSpaccing.height02(context),
              // Book Now Button
              RoundButton(
                title: "Book Now",
                onPress: () {
                  Utils.snackBar("This feature is coming soon!", context);
                  // Navigator.pushNamed(context, RoutesName.bookNowPremiumHouseKeeper);
                },
                iconData: Icons.arrow_forward_ios_rounded,
              ),
            ],
          ),
        ),

        SizedboxSpaccing.height02(context),

        // Running Offer Card
        Container(
          width: screenWidth * 0.9,
          padding: EdgeInsets.all(screenHeight * 0.02),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [AppColors.blackColor, AppColors.button(context)], begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left side - Offer Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Running Offer!",
                          style: AppTextStyles.textSize18(context, weight: FontWeight.w500, color: AppColors.whiteColor),
                        ),
                        SizedboxSpaccing.height005(context),
                        Text(
                          "Get 70% discount on Premium House Keeper services",
                          style: AppTextStyles.textSize14(context, weight: FontWeight.w400, color: AppColors.whiteColor),
                        ),
                      ],
                    ),
                  ),
                  // Right side - Discount Badge
                  Container(
                    height: 64,
                    width: 78,
                    decoration: BoxDecoration(color: AppColors.containerBackground(context), borderRadius: BorderRadius.circular(8)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "70%",
                          style: AppTextStyles.textSize20(context, weight: FontWeight.w600, color: AppColors.textPrimary(context)),
                        ),
                        Text(
                          "OFF",
                          style: AppTextStyles.textSize14(context, weight: FontWeight.w400, color: AppColors.textPrimary(context)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedboxSpaccing.height02(context),
              // Promo Code Section
              Container(
                padding: EdgeInsets.all(screenHeight * 0.01),
                decoration: BoxDecoration(color: AppColors.button(context), borderRadius: BorderRadius.circular(12)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "CLEANDAY",
                      style: AppTextStyles.textSize18(context, weight: FontWeight.w500, color: AppColors.whiteColor),
                      textAlign: TextAlign.center,
                    ),
                    GestureDetector(
                      onTap: () => _copyPromoCode(context, "CLEANDAY"),
                      child: Container(
                        height: 24,
                        width: 89,
                        decoration: BoxDecoration(color: AppColors.whiteColor, borderRadius: BorderRadius.circular(6)),
                        child: Center(
                          child: Text(
                            "Copy Code",
                            style: AppTextStyles.textSize12(context, weight: FontWeight.w500, color: AppColors.button(context)),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        SizedboxSpaccing.height02(context),
      ],
    );
  }

  void _copyPromoCode(BuildContext context, String code) {
    Clipboard.setData(ClipboardData(text: code));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Promo code "$code" copied to clipboard!', style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.oceanGreenColor,
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
