import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CustomDatePickerFormField extends StatelessWidget {
  // Required
  final TextEditingController controller;

  // Title (Optional)
  final String? title;
  final TextStyle? titleTextStyle;
  final double? titleWidth;

  // Icons (Optional)
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool showDefaultPreffixIcon;
  final bool showDefaultSuffixIcon;

  // Colors & Styling
  final Color? backgroundColor;
  final Color? borderColor;
  final double? borderRadius;
  final double? borderWidth;
  final double? height;
  final double? width;

  // Text Styles
  final TextStyle? inputTextStyle;
  final TextStyle? hintTextStyle;
  final String? hintText;

  // Date Configuration
  final DateTime? initialDate;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final String dateFormat;

  // Picker Theme Colors
  final Color? pickerPrimaryColor;
  final Color? pickerBackgroundColor;
  final Color? pickerHeaderBackgroundColor;
  final Color? pickerHeaderForegroundColor;

  // Validation
  final String? Function(String?)? validator;
  final AutovalidateMode? autovalidateMode;

  // Callbacks
  final Function(DateTime)? onDateSelected;

  // Content Padding
  final EdgeInsetsGeometry? contentPadding;

  const CustomDatePickerFormField({
    Key? key,
    required this.controller,

    // Title
    this.title,
    this.titleTextStyle,
    this.titleWidth,

    // Icons
    this.prefixIcon,
    this.suffixIcon,
    this.showDefaultPreffixIcon = true,
    this.showDefaultSuffixIcon = true,

    // Styling
    this.backgroundColor,
    this.borderColor,
    this.borderRadius,
    this.borderWidth,
    this.height,
    this.width,

    // Text
    this.inputTextStyle,
    this.hintTextStyle,
    this.hintText,

    // Date Config
    this.initialDate,
    this.firstDate,
    this.lastDate,
    this.dateFormat = 'MMMM dd, yyyy',

    // Picker Theme
    this.pickerPrimaryColor,
    this.pickerBackgroundColor,
    this.pickerHeaderBackgroundColor,
    this.pickerHeaderForegroundColor,

    // Validation
    this.validator,
    this.autovalidateMode,

    // Callbacks
    this.onDateSelected,

    // Padding
    this.contentPadding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title (Optional)
        if (title != null)
          Container(
            width: titleWidth ?? screenWidth * 0.9,
            child: Text(
              title!,
              style: titleTextStyle ??  AppTextStyles.textSize18(context, weight: FontWeight.w500),
            ),
          ),
        if (title != null) SizedBox(height: screenHeight * 0.01),

        // Date Picker Field
        FormField<String>(
          validator: validator,
          autovalidateMode: autovalidateMode ?? AutovalidateMode.onUserInteraction,
          builder: (FormFieldState<String> state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: width ?? screenWidth * 0.9,
                  height: height ?? 42,
                  decoration: BoxDecoration(
                    color: backgroundColor ?? AppColors.fieldColor(context),
                    borderRadius: BorderRadius.circular(borderRadius ?? 12),
                    border: Border.all(
                      width: borderWidth ?? 1,
                      color: borderColor ?? AppColors.border(context),
                    ),
                  ),
                  child: TextFormField(
                    controller: controller,
                    keyboardType: TextInputType.datetime,
                    readOnly: true,
                    style: inputTextStyle ??  AppTextStyles.textSize16(context, weight: FontWeight.w500),
                    decoration: InputDecoration(
                      hintText: hintText ?? "Select date",
                      hintStyle: hintTextStyle ??       AppTextStyles.textSize16(
                        context,
                        color: AppColors.hintColor(context),
                        weight: FontWeight.w400,
                      ),

                      prefixIcon: prefixIcon ?? (showDefaultPreffixIcon? Icon(
                        Icons.calendar_today,
                        color: AppColors.textPrimary(context),
                        size: 20,
                      )
                          : null),
                      suffixIcon: suffixIcon ??
                          (showDefaultSuffixIcon
                              ? Icon(
                            Icons.keyboard_arrow_down,
                            color: AppColors.textPrimary(context),
                            size: 20,
                          )
                              : null),
                      border: OutlineInputBorder(borderSide: BorderSide.none),
                      contentPadding: contentPadding ?? EdgeInsets.symmetric(horizontal: 10.0),
                    ),
                    onTap: () => _selectDate(context, state),
                  ),
                ),
                if (state.hasError)
                  Container(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 4.0, left: 10),
                      child: Text(
                        state.errorText ?? '',
                        style: AppTextStyles.textSize12(context, weight: FontWeight.w400, color: Colors.red),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }

  Future<void> _selectDate(BuildContext context, FormFieldState<String> state) async {
    DateTime initialDateValue;

    // Try to parse existing date
    if (controller.text.isNotEmpty) {
      try {
        initialDateValue = DateFormat(dateFormat).parse(controller.text);
      } catch (e) {
        try {
          initialDateValue = DateFormat('dd/MM/yyyy').parse(controller.text);
        } catch (e) {
          initialDateValue = initialDate ?? DateTime.now();
        }
      }
    } else {
      initialDateValue = initialDate ?? DateTime.now();
    }

    DateTime? pickedDate = await showDatePicker(
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      context: context,
      initialDate: initialDateValue,
      firstDate: firstDate ?? DateTime.now(),
      lastDate: lastDate ?? DateTime(2101),
      builder: (BuildContext context, Widget? child) {
        final theme = Theme.of(context);
        return Theme(
          data: theme.copyWith(
            colorScheme: ColorScheme.light(
              primary: pickerPrimaryColor ??  AppColors.button(context),
              onPrimary: Colors.white,
              onSurface: pickerPrimaryColor ??  AppColors.button(context),
            ),
            datePickerTheme: DatePickerThemeData(
              headerBackgroundColor: AppColors.button(context),
              backgroundColor: pickerBackgroundColor ?? Colors.white,
              headerForegroundColor: pickerHeaderForegroundColor ?? Colors.white,
              surfaceTintColor: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      String formattedDate = DateFormat(dateFormat).format(pickedDate);
      controller.text = formattedDate;
      state.didChange(formattedDate);

      if (onDateSelected != null) {
        onDateSelected!(pickedDate);
      }
    }
  }
}
