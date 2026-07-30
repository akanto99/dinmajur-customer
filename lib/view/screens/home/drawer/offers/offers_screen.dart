import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/components/header_appbar.dart';
import 'package:dinmajur_customer/configs/res/sizedbox_spaccing.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:dinmajur_customer/configs/responsive/responsive_ui.dart';
import 'package:dinmajur_customer/view/screens/home/helper_widgets/all_coupons_widget/all_coupons_widget.dart';
import 'package:flutter/material.dart';

class OffersScreen extends StatefulWidget {
  const OffersScreen({super.key});

  @override
  State<OffersScreen> createState() => _OffersScreenState();
}

class _OffersScreenState extends State<OffersScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.containerBackground(context),
      body: SafeArea(
        child: ResPonsiveUi(mobile: body(), desktop: body(), tablet: body()),
      ),
    );
  }

  Widget body() {
    final screenWidth = MediaQuery.of(context).size.width;

    return Column(
      children: [
        GestureDetector(onTap: () => Navigator.pop(context), child: AppBarHeader("Offers")),
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Registration bonus, referral rewards, and service offers — all in one place. Enter any code below at checkout to get a discount.',
                  style: AppTextStyles.textSize14(context, color: AppColors.subtitle(context)),
                ),
                SizedboxSpaccing.height02(context),
                const AllCouponsWidget(),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
