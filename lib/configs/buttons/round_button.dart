import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:dinmajur_customer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class RoundButton extends StatelessWidget {
  final String title;
  final bool loading;
  final VoidCallback onPress;
  final IconData? iconData;
  const RoundButton({Key? key, required this.title, this.loading = false, required this.onPress, this.iconData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height * 1;
    final screenWidth = MediaQuery.of(context).size.width * 1;
    return GestureDetector(
      onTap: onPress,
      child: Container(
        // height: screenHeight*0.055,
        height: 50,
        // width: screenWidth*0.65,
        decoration: BoxDecoration(
          color: Color(0xff00424D),
          // borderRadius: BorderRadius.circular(16)
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: loading
              ? Text(
                  AppLocalizations.of(context)!.wait,
                  style: AppTextStyles.textSize16(context, color: AppColors.whiteColor, weight: FontWeight.w600),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.transparent),
                    Text(
                      title,
                      style: AppTextStyles.textSize16(context, color: AppColors.whiteColor, weight: FontWeight.w600),
                    ),
                    if (iconData != null) ...[Icon(iconData, color: Colors.white, size: 16)],
                  ],
                ),
        ),
      ),
    );
  }
}

class RoundButtonFlexible extends StatelessWidget {
  final String title;
  final bool loading;
  final VoidCallback onPress;
  final IconData? rightIcon; // default right icon
  final IconData? leftIcon; // optional left icon
  final bool showRightIcon; // control right icon visibility
  final bool showLeftIcon; // control left icon visibility

  // 🎨 Custom style options
  final Color? backgroundColor; // default: teal
  final Color? borderColor; // optional border
  final double borderWidth; // optional border width
  final Color? textColor; // custom text color
  final Color? iconColor; // custom icon color

  const RoundButtonFlexible({
    Key? key,
    required this.title,
    this.loading = false,
    required this.onPress,
    this.rightIcon = Icons.arrow_forward_ios_rounded,
    this.leftIcon,
    this.showRightIcon = true,
    this.showLeftIcon = false,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth = 1.5,
    this.textColor,
    this.iconColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final Color effectiveBgColor = backgroundColor ?? AppColors.button(context);
    final Color effectiveTextColor = textColor ?? Colors.white;
    final Color effectiveIconColor = iconColor ?? Colors.white;

    return GestureDetector(
      onTap: onPress,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: effectiveBgColor,
          borderRadius: BorderRadius.circular(8),
          border: borderColor != null ? Border.all(color: borderColor!, width: borderWidth) : null,
        ),
        child: Center(
          child: loading
              ? Text(
                  AppLocalizations.of(context)!.wait,
                  style: AppTextStyles.textSize16(context, color: effectiveTextColor, weight: FontWeight.w600),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    showLeftIcon && leftIcon != null ? Icon(leftIcon, color: effectiveIconColor, size: 16) : const SizedBox(width: 16),

                    // CENTER TEXT
                    Text(
                      title,
                      style: AppTextStyles.textSize16(context, color: effectiveTextColor, weight: FontWeight.w600),
                    ),
                    // RIGHT ICON or placeholder
                    showRightIcon && rightIcon != null ? Icon(rightIcon, color: effectiveIconColor, size: 16) : const SizedBox(width: 16),
                  ],
                ),
        ),
      ),
    );
  }
}
