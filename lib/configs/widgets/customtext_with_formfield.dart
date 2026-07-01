import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:flutter/material.dart';

/// Fully customizable TextField with all styling options
class CustomTextFieldWithFormField extends StatefulWidget {
  // Text content
  final String? titleText;
  final String? requiredStar;
  final String placeholder;

  // Controllers and focus
  final TextEditingController controller;
  final FocusNode? focusCurrent;
  final FocusNode? focusNext;
  final String? Function(String?)? validator;
  final Function(String)? onChanged;
  final TextInputType keyboardType;
  final bool isReadOnly;

  // Dimensions
  final double? height;
  final double? width;
  final double? borderRadius;
  final double? borderWidth;
  final EdgeInsetsGeometry? contentPadding;
  final double? titleSpacing;

  // Colors
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? focusedBorderColor;
  final Color? errorBorderColor;

  // Text styles
  final TextStyle? titleTextStyle;
  final TextStyle? inputTextStyle;
  final TextStyle? hintTextStyle;
  final TextStyle? errorTextStyle;

  // Icons
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool showLockIconWhenReadOnly;

  // Multiline
  final int? maxLines;
  final int? minLines;

  // Password-style input
  final bool obscureText;

  // Country-code style leading box (e.g. "+88"), rendered as its own
  // bordered box to the left of the field instead of inline prefix text.
  final String? prefixBoxText;
  final double prefixBoxWidth;

  const CustomTextFieldWithFormField({
    Key? key,
    this.titleText,
    this.requiredStar,
    required this.placeholder,
    required this.controller,
    this.focusCurrent,
    this.focusNext,
    this.validator,
    this.onChanged,
    this.keyboardType = TextInputType.text,
    this.isReadOnly = false,

    // Dimensions with defaults
    this.height,
    this.width,
    this.borderRadius,
    this.borderWidth,
    this.contentPadding,
    this.titleSpacing,

    // Colors with defaults
    this.backgroundColor,
    this.borderColor,
    this.focusedBorderColor,
    this.errorBorderColor,

    // Text styles with defaults
    this.titleTextStyle,
    this.inputTextStyle,
    this.hintTextStyle,
    this.errorTextStyle,

    // Icons
    this.prefixIcon,
    this.suffixIcon,
    this.showLockIconWhenReadOnly = true,

    // Multiline
    this.maxLines,
    this.minLines,

    // Password-style input
    this.obscureText = false,

    // Country-code style leading box
    this.prefixBoxText,
    this.prefixBoxWidth = 57,
  }) : super(key: key);

  @override
  State<CustomTextFieldWithFormField> createState() => _CustomTextFieldWithFormFieldState();
}

class _CustomTextFieldWithFormFieldState extends State<CustomTextFieldWithFormField> {
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    widget.focusCurrent?.addListener(_handleFocusChange);
  }

  void _handleFocusChange() {
    if (mounted) {
      setState(() {
        _isFocused = widget.focusCurrent!.hasFocus;
      });
    }
  }

  @override
  void dispose() {
    widget.focusCurrent?.removeListener(_handleFocusChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    // Default values
    final double actualHeight = widget.height ?? 50;
    final double actualWidth = widget.width ?? screenWidth * 0.9;
    final double actualBorderRadius = widget.borderRadius ?? 12;
    final double actualBorderWidth = widget.borderWidth ?? 1;
    final double actualTitleSpacing = widget.titleSpacing ?? (screenHeight * 0.012);

    final Color actualBackgroundColor = widget.backgroundColor ?? AppColors.textFieldFill(context);
    final Color actualBorderColor = widget.borderColor ?? AppColors.border(context);
    final Color actualFocusedBorderColor = widget.focusedBorderColor ?? AppColors.button(context);
    final Color actualErrorBorderColor = widget.errorBorderColor ?? Colors.red;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title Text
        if (widget.titleText != null) ...[
          SizedBox(
            width: actualWidth,
            child: Text(
              '${widget.titleText}${widget.requiredStar ?? ""}',
              style: widget.titleTextStyle ??
                  AppTextStyles.textSize16(
                      context,
                      weight: FontWeight.w600,
                      color: AppColors.textPrimary(context)
                  ),
            ),
          ),
          SizedBox(height: actualTitleSpacing),
        ],

        // Form Field
        FormField<String>(
          validator: widget.validator,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          builder: (FormFieldState<String> fieldState) {
            // Determine border color based on state: error takes priority,
            // then focus, then the resting border color.
            final Color currentBorderColor = fieldState.hasError
                ? actualErrorBorderColor
                : (_isFocused ? actualFocusedBorderColor : actualBorderColor);

            final Widget fieldContainer = Container(
              height: actualHeight,
              width: widget.prefixBoxText == null ? actualWidth : null,
              decoration: BoxDecoration(
                color: actualBackgroundColor,
                borderRadius: widget.prefixBoxText == null
                    ? BorderRadius.circular(actualBorderRadius)
                    : BorderRadius.only(
                        topRight: Radius.circular(actualBorderRadius),
                        bottomRight: Radius.circular(actualBorderRadius),
                      ),
                border: Border.all(
                  width: actualBorderWidth,
                  color: currentBorderColor,
                ),
              ),
              child: TextFormField(
                controller: widget.controller,
                focusNode: widget.focusCurrent,
                keyboardType: widget.keyboardType,
                obscureText: widget.obscureText,
                maxLines: widget.obscureText ? 1 : widget.maxLines ?? (widget.keyboardType == TextInputType.multiline ? 5 : 1),
                minLines: widget.minLines,
                readOnly: widget.isReadOnly,
                style: widget.inputTextStyle ??
                    AppTextStyles.textSize14(
                        context,
                        weight: FontWeight.w500,
                        color: AppColors.textPrimary(context)
                    ),
                decoration: InputDecoration(
                  hintText: widget.placeholder,
                  hintStyle: widget.hintTextStyle ??
                      AppTextStyles.textSize14(
                          context,
                          color: AppColors.subtitle(context).withOpacity(0.5),
                          weight: FontWeight.w400
                      ),
                  prefixIcon: widget.prefixIcon,
                  suffixIcon: widget.suffixIcon ??
                      (widget.isReadOnly && widget.showLockIconWhenReadOnly
                          ? Icon(
                          Icons.lock_outline,
                          size: 18,
                          color: AppColors.subtitle(context)
                      )
                          : null),
                  border: OutlineInputBorder(borderSide: BorderSide.none),
                  contentPadding: widget.contentPadding ??
                      EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: widget.keyboardType == TextInputType.multiline ? 12.0 : 0
                      ),
                ),
                onChanged: (value) {
                  fieldState.didChange(value);
                  if (widget.onChanged != null) {
                    widget.onChanged!(value);
                  }
                },
                onFieldSubmitted: (_) {
                  if (widget.focusNext != null) {
                    FocusScope.of(context).requestFocus(widget.focusNext);
                  }
                },
              ),
            );

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                widget.prefixBoxText == null
                    ? fieldContainer
                    : SizedBox(
                        width: actualWidth,
                        child: Row(
                          children: [
                            Container(
                              width: widget.prefixBoxWidth,
                              height: actualHeight,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: actualBackgroundColor,
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(actualBorderRadius),
                                  bottomLeft: Radius.circular(actualBorderRadius),
                                ),
                                border: Border(
                                  left: BorderSide(width: actualBorderWidth, color: currentBorderColor),
                                  top: BorderSide(width: actualBorderWidth, color: currentBorderColor),
                                  bottom: BorderSide(width: actualBorderWidth, color: currentBorderColor),
                                ),
                              ),
                              child: Text(
                                widget.prefixBoxText!,
                                style: widget.inputTextStyle ?? AppTextStyles.textSize16(context, weight: FontWeight.w500, color: AppColors.textPrimary(context)),
                              ),
                            ),
                            Expanded(child: fieldContainer),
                          ],
                        ),
                      ),

                // Error Text
                if (fieldState.hasError)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0, left: 12.0),
                    child: Text(
                      fieldState.errorText ?? '',
                      style: widget.errorTextStyle ??
                          const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: Colors.red,
                              letterSpacing: 0.2
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
}