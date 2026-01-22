import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:flutter/material.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final bool showSeeAll;
  final VoidCallback? onSeeAllTap;
  final double? titleWidth;
  final double? seeAllWidth;
  final double containerWidthFactor;
  final TextStyle? titleStyle;
  final TextStyle? seeAllStyle;
  final String seeAllText;
  final bool showDivider;
  final Color? dividerColor;
  final double dividerHeight;
  final double? spacing;

  const SectionHeader({
    Key? key,
    required this.title,
    this.showSeeAll = true,
    this.onSeeAllTap,
    this.titleWidth,
    this.seeAllWidth,
    this.containerWidthFactor = 0.9,
    this.titleStyle,
    this.seeAllStyle,
    this.seeAllText = 'See All',
    this.showDivider = true,
    this.dividerColor,
    this.dividerHeight = 1,
    this.spacing,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      width: screenWidth * containerWidthFactor,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: titleWidth ?? screenWidth * 0.4,
                color: Colors.transparent,
                child: Text(title, style: titleStyle ?? AppTextStyles.textSize18(context, weight: FontWeight.w500)),
              ),
              if (showSeeAll)
                GestureDetector(
                  onTap: onSeeAllTap,
                  child: Container(
                    width: seeAllWidth ?? screenWidth * 0.2,
                    alignment: Alignment.centerRight,
                    color: Colors.transparent,
                    child: Text(seeAllText, style: seeAllStyle ?? AppTextStyles.textSize12(context, weight: FontWeight.w500)),
                  ),
                ),
            ],
          ),
          SizedBox(height: spacing ?? screenHeight * 0.005),
          if (showDivider) Divider(height: dividerHeight, color: dividerColor ?? AppColors.border(context)),
        ],
      ),
    );
  }
}
