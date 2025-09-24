import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';


class AppBarHeader extends StatelessWidget {
  final String appTitle;

  const AppBarHeader(this.appTitle, {super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      // padding: EdgeInsets.symmetric(horizontal: screenHeight * 0.02),
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        color: AppColors.containerBackground(context),
        border: Border(bottom: BorderSide(color: AppColors.border(context), width: 1.0)),
      ),
      child: Center(
        child: Container(
          width: screenWidth * 0.9,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(height: 20, width: 24,
                  alignment: Alignment.centerLeft,
                  child: SvgPicture.asset("assets/images/header_arrow.svg")),

              Text(appTitle, style: AppTextStyles.textSize24(context, weight: FontWeight.w600,color: AppColors.textPrimary(context))),

              Container(width: 20, height: 24),
            ],
          ),
        ),
      ),
    );
  }
}