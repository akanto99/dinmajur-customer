import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/sizedbox_spaccing.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';

/// A dynamic time selection dropdown widget
class DynamicTimeSelectionWidget<T> extends StatelessWidget {
  // Required
  final BuildContext context;
  final List<T> items;
  final String? selectedValue;
  final ValueChanged<String?>? onChanged;
  final String Function(T item) getDisplayText;
  final bool Function(T item) isItemBooked;

  // Optional - UI State
  final bool isLoading;
  final String? title;
  final double? width;
  final double? height;

  // Optional - Colors (with AppColors defaults)
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? dropdownColor;
  final Color? iconColor;
  final Color? textPrimaryColor;
  final Color? subtitleColor;

  // Optional - Text Styles (with AppTextStyles defaults)
  final TextStyle? titleStyle;
  final TextStyle? selectedTextStyle;
  final TextStyle? itemTextStyle;
  final TextStyle? loadingTextStyle;
  final TextStyle? emptyTextStyle;
  final TextStyle? hintTextStyle;
  final TextStyle? badgeTextStyle;

  // Optional - Styling
  final double? borderRadius;
  final double? borderWidth;

  // Optional - Icons
  final bool showPrefixIcon;
  final bool showSuffixIcon;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final double? iconSize;

  // Optional - Messages
  final String? loadingText;
  final String? emptyText;
  final String? allBookedHintText;
  final String? bookedBadgeText;

  // Optional - Badge
  final Color? badgeBackgroundColor;
  final Color? badgeBorderColor;
  final Color? badgeTextColor;

  // Optional - Spacing
  final EdgeInsets? contentPadding;
  final Widget Function(BuildContext)? titleSpacing;

  // Optional - Dropdown
  final double? menuMaxHeight;
  final double? menuBorderRadius;

  const DynamicTimeSelectionWidget({
    Key? key,
    required this.context,
    required this.items,
    required this.selectedValue,
    required this.onChanged,
    required this.getDisplayText,
    required this.isItemBooked,
    this.isLoading = false,
    this.title,
    this.width,
    this.height,
    this.backgroundColor,
    this.borderColor,
    this.dropdownColor,
    this.iconColor,
    this.textPrimaryColor,
    this.subtitleColor,
    this.titleStyle,
    this.selectedTextStyle,
    this.itemTextStyle,
    this.loadingTextStyle,
    this.emptyTextStyle,
    this.hintTextStyle,
    this.badgeTextStyle,
    this.borderRadius,
    this.borderWidth,
    this.showPrefixIcon = false,
    this.showSuffixIcon = true,
    this.prefixIcon,
    this.suffixIcon,
    this.iconSize,
    this.loadingText,
    this.emptyText,
    this.allBookedHintText,
    this.bookedBadgeText,
    this.badgeBackgroundColor,
    this.badgeBorderColor,
    this.badgeTextColor,
    this.contentPadding,
    this.titleSpacing,
    this.menuMaxHeight,
    this.menuBorderRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final availableItems = items.where((item) => !isItemBooked(item)).toList();

    return Container(
      width: width ?? screenWidth * 0.9,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(title!, style: titleStyle ?? AppTextStyles.textSize18(context, weight: FontWeight.w500)),
            if (titleSpacing != null) titleSpacing!(context) else SizedBox(height: 8),
          ],
          if (isLoading) _buildLoadingContainer(context) else if (items.isNotEmpty) _buildDropdownContainer(context, availableItems) else _buildEmptyContainer(context),
        ],
      ),
    );
  }

  Widget _buildLoadingContainer(BuildContext context) {
    return Container(
      height: height ?? 42,
      padding: contentPadding ?? EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.containerBackground(context),
        borderRadius: BorderRadius.circular(borderRadius ?? 6),
        border: Border.all(color: borderColor ?? AppColors.border(context), width: borderWidth ?? 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (showPrefixIcon && prefixIcon != null) ...[Icon(prefixIcon, color: iconColor ?? AppColors.textPrimary(context), size: iconSize), SizedBox(width: 20)],
          Expanded(
            child: Text(loadingText ?? 'Updating...', style: loadingTextStyle ?? AppTextStyles.textSize14(context, weight: FontWeight.w400)),
          ),
          if (showSuffixIcon) Icon(suffixIcon ?? Icons.keyboard_arrow_down, color: iconColor ?? AppColors.textPrimary(context), size: iconSize),
        ],
      ),
    );
  }

  Widget _buildDropdownContainer(BuildContext context, List<T> availableItems) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      height: height ?? 42,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.containerBackground(context),
        borderRadius: BorderRadius.circular(borderRadius ?? 6),
        border: Border.all(color: borderColor ?? AppColors.border(context), width: borderWidth ?? 1),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton2<String>(
          isExpanded: true,
          value: selectedValue,

          /// ✅ PREFIX ICON INSIDE DROPDOWN (hint)
          hint: availableItems.isEmpty
              ? _buildAllBookedHint(context)
              : Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  child: Row(
                    children: [
                      if (showPrefixIcon && prefixIcon != null) ...[Icon(prefixIcon, size: iconSize ?? 18, color: iconColor ?? AppColors.textPrimary(context)), const SizedBox(width: 8)],
                      Expanded(
                        child: Text(
                          'Select time',
                          style: hintTextStyle ?? AppTextStyles.textSize14(context, color: subtitleColor ?? AppColors.subtitle(context)),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),

          /// ✅ KEEP PREFIX AFTER SELECTION
          selectedItemBuilder: (context) {
            return items.map((item) {
              final text = getDisplayText(item);
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                  children: [
                    if (showPrefixIcon && prefixIcon != null) ...[Icon(prefixIcon, size: iconSize ?? 20, color: iconColor ?? AppColors.textPrimary(context)), SizedBox(width: 20)],
                    Expanded(
                      child: Text(
                        text,
                        style: selectedTextStyle ?? AppTextStyles.textSize14(context, weight: FontWeight.w400, color: textPrimaryColor ?? AppColors.textPrimary(context)),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            }).toList();
          },

          items: items.map((item) {
            final displayText = getDisplayText(item);
            final isBooked = isItemBooked(item);

            return DropdownMenuItem<String>(value: displayText, enabled: !isBooked, child: _buildDropdownItem(context, displayText, isBooked));
          }).toList(),

          onChanged: onChanged,

          /// ✅ SUFFIX ICON
          iconStyleData: IconStyleData(
            icon: Icon(suffixIcon ?? Icons.keyboard_arrow_down, size: iconSize ?? 22, color: iconColor ?? AppColors.textPrimary(context)),
          ),

          buttonStyleData: ButtonStyleData(
            height: height ?? 42,
            width: screenWidth,
            padding: const EdgeInsets.only(left: 0, right: 15),
            decoration: const BoxDecoration(color: Colors.transparent),
          ),
          menuItemStyleData: const MenuItemStyleData(height: 42),
          dropdownStyleData: DropdownStyleData(
            maxHeight: menuMaxHeight ?? 200,
            width: screenWidth * 0.9,
            decoration: BoxDecoration(color: dropdownColor ?? AppColors.containerBackground(context), borderRadius: BorderRadius.circular(menuBorderRadius ?? 0)),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownItem(BuildContext context, String displayText, bool isBooked) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: (borderColor ?? AppColors.border(context)).withOpacity(0.3), width: 0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              displayText,
              style:
                  itemTextStyle ??
                  AppTextStyles.textSize16(
                    context,
                    weight: FontWeight.w500,
                    color: isBooked ? (subtitleColor ?? AppColors.subtitle(context)).withOpacity(0.5) : textPrimaryColor ?? AppColors.textPrimary(context),
                  ),
            ),
          ),
          if (isBooked) _buildBookedBadge(context),
        ],
      ),
    );
  }

  Widget _buildBookedBadge(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: badgeBackgroundColor ?? Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: badgeBorderColor ?? Colors.red.withOpacity(0.3)),
      ),
      child: Text(
        bookedBadgeText ?? 'Booked',
        style: badgeTextStyle ?? AppTextStyles.textSize10(context, color: badgeTextColor ?? Colors.red, weight: FontWeight.w600),
      ),
    );
  }

  Widget _buildAllBookedHint(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.warning_amber_rounded, size: 18, color: Colors.red),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            allBookedHintText ?? 'All time slots are booked',
            style: hintTextStyle ?? AppTextStyles.textSize14(context, color: Colors.red, weight: FontWeight.w500),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyContainer(BuildContext context) {
    return Container(
      height: height ?? 42,
      padding: contentPadding ?? EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.textFieldFill(context),
        borderRadius: BorderRadius.circular(borderRadius ?? 6),
        border: Border.all(color: borderColor ?? AppColors.border(context), width: borderWidth ?? 1),
      ),
      child: Center(
        child: Text(emptyText ?? 'No shift times available', style: emptyTextStyle ?? AppTextStyles.textSize14(context, color: subtitleColor ?? AppColors.subtitle(context))),
      ),
    );
  }
}
