import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:flutter/material.dart';

class DualTermsCheckbox extends StatelessWidget {
  final bool isTermsAccepted;
  final bool isReviewAccepted;
  final ValueChanged<bool> onTermsChanged;
  final ValueChanged<bool> onReviewChanged;
  final BuildContext context;

  final VoidCallback? onTermsTap;
  final VoidCallback? onPrivacyTap;
  final VoidCallback? onRefundTap;

  final Color Function(BuildContext) getButtonColor;
  final Color Function(BuildContext) getBorderColor;
  final Color Function(BuildContext) getWhiteColor;
  final TextStyle Function(BuildContext, {FontWeight? weight}) getTextStyle;

  final double checkboxSize;
  final double checkIconSize;
  final double spacing;
  final double borderRadius;
  final double borderWidth;
  final double itemSpacing;

  const DualTermsCheckbox({
    Key? key,
    required this.isTermsAccepted,
    required this.isReviewAccepted,
    required this.onTermsChanged,
    required this.onReviewChanged,
    required this.context,
    required this.getButtonColor,
    required this.getBorderColor,
    required this.getWhiteColor,
    required this.getTextStyle,
    this.onTermsTap,
    this.onPrivacyTap,
    this.onRefundTap,
    this.checkboxSize = 18.0,
    this.checkIconSize = 13.0,
    this.spacing = 10.0,
    this.borderRadius = 2.0,
    this.borderWidth = 2.0,
    this.itemSpacing = 12,
  }) : super(key: key);

  @override
  Widget build(BuildContext _) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Checkbox 1: Terms, Privacy & Refund ──────────────────────────────
        _CheckboxRow(
          isAccepted: isTermsAccepted,
          onChanged: onTermsChanged,
          context: context,
          checkboxSize: checkboxSize,
          checkIconSize: checkIconSize,
          spacing: spacing,
          borderRadius: borderRadius,
          borderWidth: borderWidth,
          getButtonColor: getButtonColor,
          getBorderColor: getBorderColor,
          getWhiteColor: getWhiteColor,
          child: RichText(
            text: TextSpan(
              style: getTextStyle(context, weight: FontWeight.w400),
              children: [
                const TextSpan(text: 'I agree to the '),
                if (onTermsTap != null)
                  WidgetSpan(
                    child: GestureDetector(
                      onTap: onTermsTap,
                      child: Text(
                        'Terms & Conditions',
                        style: getTextStyle(context, weight: FontWeight.w400)
                            .copyWith(decoration: TextDecoration.underline),
                      ),
                    ),
                  )
                else
                  const TextSpan(text: 'Terms & Conditions'),
                const TextSpan(text: ', '),
                if (onPrivacyTap != null)
                  WidgetSpan(
                    child: GestureDetector(
                      onTap: onPrivacyTap,
                      child: Text(
                        'Privacy Policy',
                        style: getTextStyle(context, weight: FontWeight.w400)
                            .copyWith(decoration: TextDecoration.underline),
                      ),
                    ),
                  )
                else
                  const TextSpan(text: 'Privacy Policy'),
                const TextSpan(text: ', and '),
                if (onRefundTap != null)
                  WidgetSpan(
                    child: GestureDetector(
                      onTap: onRefundTap,
                      child: Text(
                        'Return Refund/Cancellation Policy',
                        style: getTextStyle(context, weight: FontWeight.w400)
                            .copyWith(decoration: TextDecoration.underline),
                      ),
                    ),
                  )
                else
                  const TextSpan(text: 'Return Refund/Cancellation Policy'),
                const TextSpan(text: '.'),
              ],
            ),
          ),
        ),

        SizedBox(height: itemSpacing),

        // ── Checkbox 2: Review & Pay ──────────────────────────────────────────
        _CheckboxRow(
          isAccepted: isReviewAccepted,
          onChanged: onReviewChanged,
          context: context,
          checkboxSize: checkboxSize,
          checkIconSize: checkIconSize,
          spacing: spacing,
          borderRadius: borderRadius,
          borderWidth: borderWidth,
          getButtonColor: getButtonColor,
          getBorderColor: getBorderColor,
          getWhiteColor: getWhiteColor,
          child: Text(
            'I have reviewed the final items and agree to pay the total amount.',
            style: getTextStyle(context, weight: FontWeight.w400),
          ),
        ),
      ],
    );
  }
}

// ── Private reusable checkbox row ─────────────────────────────────────────────

class _CheckboxRow extends StatelessWidget {
  final bool isAccepted;
  final ValueChanged<bool> onChanged;
  final BuildContext context;
  final double checkboxSize;
  final double checkIconSize;
  final double spacing;
  final double borderRadius;
  final double borderWidth;
  final Color Function(BuildContext) getButtonColor;
  final Color Function(BuildContext) getBorderColor;
  final Color Function(BuildContext) getWhiteColor;
  final Widget child;

  const _CheckboxRow({
    required this.isAccepted,
    required this.onChanged,
    required this.context,
    required this.checkboxSize,
    required this.checkIconSize,
    required this.spacing,
    required this.borderRadius,
    required this.borderWidth,
    required this.getButtonColor,
    required this.getBorderColor,
    required this.getWhiteColor,
    required this.child,
  });

  @override
  Widget build(BuildContext _) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => onChanged(!isAccepted),
          child: Container(
            width: checkboxSize,
            height: checkboxSize,
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              color: isAccepted ? getButtonColor(context) : Colors.transparent,
              border: Border.all(
                color: isAccepted
                    ? getButtonColor(context)
                    : AppColors.textPrimary(context),
                width: borderWidth,
              ),
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            child: isAccepted
                ? Icon(Icons.check, size: checkIconSize, color: getWhiteColor(context))
                : null,
          ),
        ),
        SizedBox(width: spacing),
        Expanded(
          child: GestureDetector(
            onTap: () => onChanged(!isAccepted),
            child: child,
          ),
        ),
      ],
    );
  }
}