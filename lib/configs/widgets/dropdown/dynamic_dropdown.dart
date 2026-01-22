import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

class DynamicDropdown extends StatelessWidget {
  // Required fields
  final List<String> items;
  final String? selectedItem;
  final void Function(String?) onChanged;

  // Optional title
  final String? titleText;
  final TextStyle? titleStyle;

  // Optional hint
  final String? hintText;
  final TextStyle? hintStyle;

  // Styling options
  final double? width;
  final double? height;
  final double? dropdownMaxHeight;
  final double? borderRadius;
  final double? borderWidth;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? contentPadding;
  final double? itemHeight; // NEW: Control individual item height

  // Colors
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? dropdownBackgroundColor;
  final Color? iconColor;

  // Icon
  final IconData? icon;
  final double? iconSize;

  // Text styling
  final TextStyle? itemTextStyle;
  final TextStyle? selectedTextStyle;
  final Map<String, String>? valueToBengaliMap;

  // Spacing
  final double? titleSpacing;

  const DynamicDropdown({
    Key? key,
    required this.items,
    required this.selectedItem,
    required this.onChanged,
    this.titleText,
    this.titleStyle,
    this.hintText,
    this.hintStyle,
    this.width,
    this.height,
    this.dropdownMaxHeight,
    this.borderRadius,
    this.borderWidth,
    this.padding,
    this.contentPadding,
    this.itemHeight, // NEW parameter
    this.backgroundColor,
    this.borderColor,
    this.dropdownBackgroundColor,
    this.iconColor,
    this.icon,
    this.iconSize,
    this.itemTextStyle,
    this.selectedTextStyle,
    this.valueToBengaliMap,
    this.titleSpacing,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Default values
    final double actualWidth = width ?? (screenWidth * 0.9);
    final double actualHeight = height ?? 50;
    final double actualBorderRadius = borderRadius ?? 12;
    final double actualBorderWidth = borderWidth ?? 1;
    final double actualDropdownMaxHeight = dropdownMaxHeight ?? 200;
    final double actualIconSize = iconSize ?? 25;
    final IconData actualIcon = icon ?? Icons.keyboard_arrow_down;
    final double actualTitleSpacing = titleSpacing ?? (screenHeight * 0.012);
    final double actualItemHeight = itemHeight ?? 35;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Optional Title
        if (titleText != null) ...[
          Container(
            width: actualWidth,
            child: Text(
              titleText!,
              style: titleStyle ?? AppTextStyles.textSize18(context, weight: FontWeight.w500),
            ),
          ),
          SizedBox(height: actualTitleSpacing),
        ],

        // Dropdown
        Container(
          height: actualHeight,
          width: actualWidth,
          child: DropdownButtonHideUnderline(
            child: DropdownButton2<String>(
              isExpanded: true,
              value: selectedItem,
              style: selectedTextStyle ?? AppTextStyles.textSize16(context, weight: FontWeight.w500),
              hint: hintText != null
                  ? Text(
                hintText!,
                style: hintStyle ??
                    AppTextStyles.textSize16(
                      context,
                      color: AppColors.hintColor(context),
                      weight: FontWeight.w400,
                    ),
              )
                  : null,
              iconStyleData: IconStyleData(
                icon: Icon(
                  actualIcon,
                  size: actualIconSize,
                  color: iconColor ?? AppColors.textPrimary(context),
                ),
              ),
              buttonStyleData: ButtonStyleData(
                width: actualWidth,
                height: actualHeight,
                decoration: BoxDecoration(
                  color: backgroundColor ?? AppColors.containerBackground(context),
                  borderRadius: BorderRadius.circular(actualBorderRadius),
                  border: Border.all(
                    width: actualBorderWidth,
                    color: borderColor ?? AppColors.border(context),
                  ),
                ),
                padding: contentPadding ?? const EdgeInsets.symmetric(horizontal: 15),
              ),
              dropdownStyleData: DropdownStyleData(
                maxHeight: actualDropdownMaxHeight,
                width: actualWidth,
                decoration: BoxDecoration(
                  color: dropdownBackgroundColor ?? AppColors.textFieldFill(context),
                  borderRadius: BorderRadius.circular(actualBorderRadius),
                ),
                padding: padding,
              ),
              menuItemStyleData: MenuItemStyleData(
                height: actualItemHeight, // CHANGED: Using actualItemHeight instead of actualHeight
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 0), // CHANGED: vertical padding to 0
              ),
              items: items.map((item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(
                    valueToBengaliMap?[item] ?? item,
                    style: itemTextStyle ?? AppTextStyles.textSize16(context, weight: FontWeight.w500),
                  ),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}