import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/sizedbox_spaccing.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:dinmajur_customer/configs/utils/amount_formatter/amount_formatter.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Dynamic Cart Header Widget
/// Reusable widget for displaying cart header with item count, total price, and close button
class DynamicCartHeader extends StatelessWidget {
  final int itemCount;
  final double totalPrice;
  final double originalPrice;
  final double savedAmount;
  final VoidCallback onClose;
  final double? width;
  final EdgeInsets? padding;
  final String? title;
  final TextStyle? titleStyle;
  final TextStyle? itemCountStyle;
  final TextStyle? totalPriceStyle;
  final TextStyle? originalPriceStyle;
  final Color? borderColor;
  final double? borderWidth;
  final Color? closeButtonColor;
  final double? closeButtonSize;
  final IconData? closeIcon;

  const DynamicCartHeader({
    Key? key,
    required this.itemCount,
    required this.totalPrice,
    required this.originalPrice,
    required this.savedAmount,
    required this.onClose,
    this.width,
    this.padding,
    this.title,
    this.titleStyle,
    this.itemCountStyle,
    this.totalPriceStyle,
    this.originalPriceStyle,
    this.borderColor,
    this.borderWidth,
    this.closeButtonColor,
    this.closeButtonSize,
    this.closeIcon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      width: width ?? screenWidth * 0.87,
      padding: padding ?? EdgeInsets.symmetric(vertical: 15),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: borderColor ?? AppColors.border(context),
            width: borderWidth ?? 1,
          ),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(),
              GestureDetector(
                onTap: onClose,
                child: Container(
                  height: closeButtonSize ?? 38,
                  width: closeButtonSize ?? 38,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: (closeButtonColor ?? AppColors.button(context))
                        .withOpacity(0.2),
                  ),
                  child: Icon(
                    closeIcon ?? FontAwesomeIcons.close,
                    color: AppColors.textPrimary(context),
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title ?? 'CART',
                style: titleStyle ??
                    AppTextStyles.textSize16(context, weight: FontWeight.w600),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$itemCount service${itemCount > 1 ? 's' : ''}',
                    style: itemCountStyle ??
                        AppTextStyles.textSize14(
                          context,
                          color: AppColors.subtitle(context),
                        ),
                  ),
                  Row(
                    children: [
                      Text(
                        // 'Total ৳${totalPrice.toStringAsFixed(2)}',
                        'Total ৳${AmountFormatter.format(totalPrice)}',
                        style: totalPriceStyle ??
                            AppTextStyles.textSize14(
                              context,
                              weight: FontWeight.w600,
                            ),
                      ),
                      SizedboxSpaccing.width02(context),
                      if (savedAmount > 0)
                        Text(
                          '${AmountFormatter.format(originalPrice)}',
                          style: (originalPriceStyle ??
                              AppTextStyles.textSize12(
                                context,
                                color: AppColors.subtitle(context),
                                weight: FontWeight.w600,
                              ))
                              .copyWith(decoration: TextDecoration.lineThrough),
                        ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}