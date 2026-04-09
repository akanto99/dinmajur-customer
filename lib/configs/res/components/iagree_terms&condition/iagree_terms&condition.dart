import 'package:dinmajur_customer/configs/res/sizedbox_spaccing.dart';
import 'package:flutter/material.dart';

class DynamicTermsCheckbox extends StatelessWidget {
  final bool isAccepted;
  final ValueChanged<bool> onChanged;
  final BuildContext context;
  final VoidCallback? onTermsTap;
  final VoidCallback? onPrivacyTap;
  final VoidCallback? onRefundTap;

  // Color getters
  final Color Function(BuildContext) getButtonColor;
  final Color Function(BuildContext) getBorderColor;
  final Color Function(BuildContext) getWhiteColor;

  // Text style getter
  final TextStyle Function(BuildContext, {FontWeight? weight}) getTextStyle;

  // Customization properties
  final double checkboxSize;
  final double checkIconSize;
  final double spacing;
  final EdgeInsets? padding;
  final double borderRadius;
  final double borderWidth;

  // Text customization
  final String prefixText;
  final String termsText;
  final String privacyText;
  final String refundText;
  final String middleText1;
  final String middleText2;
  final String suffixText;

  const DynamicTermsCheckbox({
    Key? key,
    required this.isAccepted,
    required this.onChanged,
    required this.context,
    required this.getButtonColor,
    required this.getBorderColor,
    required this.getWhiteColor,
    required this.getTextStyle,
    this.onTermsTap,
    this.onPrivacyTap,
    this.onRefundTap,
    this.checkboxSize = 20.0,
    this.checkIconSize = 16.0,
    this.spacing = 10.0,
    this.padding,
    this.borderRadius = 2.0,
    this.borderWidth = 2.0,
    this.prefixText = 'I agree to the ',
    this.termsText = 'Terms & Conditions',
    this.privacyText = 'Privacy Policy',
    this.refundText = 'Return Refund/Cancellation Policy',
    this.middleText1 = ', ',
    this.middleText2 = ', and ',
    this.suffixText = '.',
  }) : super(key: key);

  @override
  Widget build(BuildContext _) {
    return   GestureDetector(
      onTap: () => onChanged(!isAccepted),
      child: Container(
        padding: padding ?? EdgeInsets.all(12),
        color: Colors.transparent,
        child: Column(
          children: [
            SizedboxSpaccing.height01(context),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Checkbox
                Container(
                  width: checkboxSize,
                  height: checkboxSize,
                  margin: EdgeInsets.only(top: 2),
                  decoration: BoxDecoration(
                    color: isAccepted ? getButtonColor(context) : Colors.transparent,
                    border: Border.all(color: isAccepted ? getButtonColor(context) : getBorderColor(context), width: borderWidth),
                    borderRadius: BorderRadius.circular(borderRadius),
                  ),
                  child: isAccepted ? Icon(Icons.check, size: checkIconSize, color: getWhiteColor(context)) : null,
                ),
                SizedBox(width: spacing),

                // Terms text
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: getTextStyle(context, weight: FontWeight.w400),
                      children: [
                        TextSpan(text: prefixText),

                        // Terms & Conditions link
                        if (onTermsTap != null)
                          WidgetSpan(
                            child: GestureDetector(
                              onTap: onTermsTap,
                              child: Text(
                                termsText,
                                style: getTextStyle(context, weight: FontWeight.w400).copyWith(decoration: TextDecoration.underline),
                              ),
                            ),
                          )
                        else
                          TextSpan(text: termsText),

                        TextSpan(text: middleText1),

                        // Privacy Policy link
                        if (onPrivacyTap != null)
                          WidgetSpan(
                            child: GestureDetector(
                              onTap: onPrivacyTap,
                              child: Text(
                                privacyText,
                                style: getTextStyle(context, weight: FontWeight.w400).copyWith(decoration: TextDecoration.underline),
                              ),
                            ),
                          )
                        else
                          TextSpan(text: privacyText),

                        TextSpan(text: middleText2),

                        // Refund Policy link
                        if (onRefundTap != null)
                          WidgetSpan(
                            child: GestureDetector(
                              onTap: onRefundTap,
                              child: Text(
                                refundText,
                                style: getTextStyle(context, weight: FontWeight.w400).copyWith(decoration: TextDecoration.underline),
                              ),
                            ),
                          )
                        else
                          TextSpan(text: refundText),

                        TextSpan(text: suffixText),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
