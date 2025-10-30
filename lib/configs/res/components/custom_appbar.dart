import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/components/notifications/resuable_notifications.dart';
import 'package:dinmajur_customer/configs/res/sizedbox_spaccing.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomAppBar extends StatelessWidget {
  final String appBarTitle;

  const CustomAppBar({
    Key? key,
    required this.appBarTitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.containerBackground(context),
        border: Border(
          bottom: BorderSide(
            color: AppColors.border(context),
            width: 1.0,
          ),
        ),
      ),
      child: Center(
        child: Container(
          height: 60,
          width: screenWidth * 0.9,
          padding: EdgeInsets.symmetric(vertical: screenHeight * 0.01),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    height: 15,
                    width: 15,
                    alignment: Alignment.centerLeft,
                    child: SvgPicture.asset(
                      "assets/images/header_arrow.svg",
                    ),
                  ),
                  SizedboxSpaccing.width03(context),
                  Text(
                    appBarTitle,
                    style: AppTextStyles.textSize18(
                      context,
                      weight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              // Right Side Icons
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildIconButton(
                    onTap: () {
                      NotificationDialog.show(
                        context,
                        message: 'Empty Inbox',
                        icon: CupertinoIcons.text_bubble,
                        iconColor: AppColors.textPrimary(context),
                        iconBackgroundColor: AppColors.appBackground(context),
                      );
                    },
                    svgAsset: 'assets/images/home/email.svg',
                    context: context,
                  ),
                  SizedboxSpaccing.width02(context),
                  _buildIconButton(
                    onTap: () {
                      NotificationDialog.show(
                        context,
                        message: 'No Notification Yet',
                        icon: Icons.notifications_outlined,
                        iconColor: AppColors.textPrimary(context),
                        iconBackgroundColor: AppColors.appBackground(context),
                      );
                    },
                    svgAsset: 'assets/images/home/notification.svg',
                    context: context,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Helper Icon Button Builder
  Widget _buildIconButton({
    required VoidCallback onTap,
    required String svgAsset,
    required BuildContext context,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 24,
        width: 24,
        padding: const EdgeInsets.all(2),
        child: SvgPicture.asset(
          svgAsset,
          color: AppColors.textPrimary(context),
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
