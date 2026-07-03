import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:dinmajur_customer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// Simple button API, kept for existing call sites.
/// Internally delegates to [RoundButtonFlexible] so there is a single
/// real button implementation in the app.
class RoundButton extends StatelessWidget {
  final String title;
  final bool loading;
  final VoidCallback onPress;
  final IconData? iconData;
  const RoundButton({Key? key, required this.title, this.loading = false, required this.onPress, this.iconData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RoundButtonFlexible(
      title: title,
      loading: loading,
      onPress: onPress,
      width: double.infinity,
      showRightIcon: iconData != null,
      rightIcon: iconData,
    );
  }
}

class RoundButtonFlexible extends StatelessWidget {
  // Content
  final String title;
  final bool loading;
  final VoidCallback onPress;

  // Icons
  final IconData? rightIcon;
  final IconData? leftIcon;
  final bool showRightIcon;
  final bool showLeftIcon;
  final double? iconSize;

  // Dimensions
  final double? height;
  final double? width;
  final double? borderRadius;
  final double? borderWidth;
  final EdgeInsetsGeometry? padding;

  // Colors
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? textColor;
  final Color? iconColor;
  final Color? loadingTextColor;

  // Text Style
  final TextStyle? textStyle;
  final TextStyle? loadingTextStyle;

  // Layout
  final MainAxisAlignment? contentAlignment;
  final double? spaceBetweenItems;

  // Loading
  final Widget? customLoadingWidget;
  final String? customLoadingText;

  // Elevation & Shadow
  final double? elevation;
  final List<BoxShadow>? boxShadow;

  const RoundButtonFlexible({
    Key? key,
    required this.title,
    this.loading = false,
    required this.onPress,

    // Icons with defaults
    this.rightIcon = Icons.arrow_forward_ios_rounded,
    this.leftIcon,
    this.showRightIcon = true,
    this.showLeftIcon = false,
    this.iconSize,

    // Dimensions with defaults
    this.height,
    this.width,
    this.borderRadius,
    this.borderWidth,
    this.padding,

    // Colors with defaults
    this.backgroundColor,
    this.borderColor,
    this.textColor,
    this.iconColor,
    this.loadingTextColor,

    // Text styles
    this.textStyle,
    this.loadingTextStyle,

    // Layout
    this.contentAlignment,
    this.spaceBetweenItems,

    // Loading
    this.customLoadingWidget,
    this.customLoadingText,

    // Elevation
    this.elevation,
    this.boxShadow,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Default values
    final double actualHeight = height ?? 50;
    final double actualWidth = width ?? screenWidth * 0.9;
    final double actualBorderRadius = borderRadius ?? 8;
    final double actualBorderWidth = borderWidth ?? 1.5;
    final double actualIconSize = iconSize ?? 16;
    final MainAxisAlignment actualAlignment = contentAlignment ?? MainAxisAlignment.spaceEvenly;
    final double actualSpacing = spaceBetweenItems ?? 0;

    // Colors
    final Color effectiveBgColor = backgroundColor ?? AppColors.button(context);
    final Color effectiveTextColor = textColor ?? Colors.white;
    final Color effectiveIconColor = iconColor ?? Colors.white;
    final Color effectiveLoadingTextColor = loadingTextColor ?? effectiveTextColor;

    return GestureDetector(
      onTap: loading ? null : onPress,
      child: Container(
        height: actualHeight,
        width: actualWidth,
        padding: padding,
        decoration: BoxDecoration(
          color: effectiveBgColor,
          borderRadius: BorderRadius.circular(actualBorderRadius),
          border: borderColor != null ? Border.all(color: borderColor!, width: actualBorderWidth) : null,
          boxShadow: boxShadow ?? (elevation != null && elevation! > 0 ? [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: elevation!, offset: Offset(0, elevation! / 2))] : null),
        ),
        child: Center(
          child: loading ? _buildLoadingState(context, effectiveLoadingTextColor) : _buildNormalState(context, effectiveTextColor, effectiveIconColor, actualIconSize, actualAlignment, actualSpacing),
        ),
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context, Color loadingColor) {
    if (customLoadingWidget != null) {
      return customLoadingWidget!;
    }

    final String loadingText = customLoadingText ?? AppLocalizations.of(context)!.wait;

    return Text(
      loadingText,
      style: loadingTextStyle ?? textStyle ?? AppTextStyles.textSize16(context, color: loadingColor, weight: FontWeight.w600),
    );
  }

  Widget _buildNormalState(BuildContext context, Color textColor, Color iconColor, double iconSize, MainAxisAlignment alignment, double spacing) {
    final List<Widget> children = [];

    // Left Icon
    if (showLeftIcon && leftIcon != null) {
      children.add(Icon(leftIcon, color: iconColor, size: iconSize));
    } else if (alignment == MainAxisAlignment.spaceEvenly || alignment == MainAxisAlignment.spaceBetween) {
      children.add(SizedBox(width: iconSize));
    }

    // Add spacing if custom spacing is set
    if (spacing > 0 && children.isNotEmpty) {
      children.add(SizedBox(width: spacing));
    }

    // Center Text
    children.add(
      Text(
        title,
        style: textStyle ?? AppTextStyles.textSize16(context, color: textColor, weight: FontWeight.w600),
      ),
    );

    // Add spacing if custom spacing is set
    if (spacing > 0) {
      children.add(SizedBox(width: spacing));
    }

    // Right Icon
    if (showRightIcon && rightIcon != null) {
      children.add(Icon(rightIcon, color: iconColor, size: iconSize));
    } else if (alignment == MainAxisAlignment.spaceEvenly || alignment == MainAxisAlignment.spaceBetween) {
      children.add(SizedBox(width: iconSize));
    }

    return Row(mainAxisAlignment: alignment, children: children);
  }
}
