import 'package:flutter/material.dart';
import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/sizedbox_spaccing.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:url_launcher/url_launcher.dart';

/// Reusable Customer Care Support Card Component
class CustomerCareSupportCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String phoneNumber;
  final bool isClickable;
  final VoidCallback? onTap;

  const CustomerCareSupportCard({
    Key? key,
    this.title = 'Customer Care Hotline',
    this.subtitle = 'Available 24/7 for your assistance',
    this.phoneNumber = '01929600600',
    this.isClickable = true,
    this.onTap,
  }) : super(key: key);

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);

    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      // Handle error - phone call not available
      print('Could not launch phone call to $phoneNumber');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return GestureDetector(
      onTap: isClickable ? (onTap ?? () => _makePhoneCall(phoneNumber)) : null,
      child: Container(
        width: screenWidth * 0.9,
        padding: EdgeInsets.all(screenHeight * 0.02),
        decoration: BoxDecoration(
          color: AppColors.containerBackground(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(width: 1, color: AppColors.border(context)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon Container
            Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(color: AppColors.textPrimary(context), shape: BoxShape.circle),
              child: Icon(Icons.headset_mic, color: AppColors.containerBackground(context), size: 24),
            ),

            SizedboxSpaccing.width03(context),
            SizedboxSpaccing.width01(context),

            // Text Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.textSize18(context, weight: FontWeight.w500)),

                  SizedboxSpaccing.height005(context),

                  Text(subtitle, style: AppTextStyles.textSize12(context)),

                  SizedboxSpaccing.height01(context),

                  Text(phoneNumber, style: AppTextStyles.textSize24(context, weight: FontWeight.w600)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
