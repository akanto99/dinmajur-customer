import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:flutter/material.dart';

@Deprecated('Use CustomTextFieldWithFormField (customtext_with_formfield.dart) with prefixBoxText: "+88" instead.')
class CustomeMobileTextfield extends StatefulWidget {
  final String placeholder;
  final double? dynamicheight;
  final TextEditingController controller;
  final FocusNode? focusCurrent;
  final Function(String)? onChanged;
  final TextInputType keyboardType;
  final TextStyle? inputTextStyle;
  final TextStyle? hintTextStyle;
  final bool isReadOnly;

  const CustomeMobileTextfield({
    Key? key,
    required this.placeholder,
    required this.controller,
    this.dynamicheight,
    this.focusCurrent,
    this.onChanged,
    this.keyboardType = TextInputType.text,
    this.inputTextStyle,
    this.hintTextStyle,
    this.isReadOnly = false,
  }) : super(key: key);

  @override
  State<CustomeMobileTextfield> createState() => _CustomeMobileTextfieldState();
}

class _CustomeMobileTextfieldState extends State<CustomeMobileTextfield> {
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    widget.focusCurrent?.addListener(_handleFocusChange);
  }

  void _handleFocusChange() {
    if (mounted) setState(() => _isFocused = widget.focusCurrent!.hasFocus);
  }

  @override
  void dispose() {
    widget.focusCurrent?.removeListener(_handleFocusChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final borderColor = _isFocused ? AppColors.button(context) : AppColors.border(context);

    return Container(
      width: screenWidth * 0.75,
      child: Row(
        children: [
          // ── Country Code ─────────────────────────────────────────────
          Container(
            width: 57,
            height: widget.dynamicheight ?? 42,
            decoration: BoxDecoration(
              color: AppColors.containerBackground(context),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                bottomLeft: Radius.circular(8),
              ),
              border: Border(
                left:   BorderSide(width: 1, color: borderColor),
                top:    BorderSide(width: 1, color: borderColor),
                bottom: BorderSide(width: 1, color: borderColor),
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              "+88",
              style: AppTextStyles.textSize16(
                context,
                weight: FontWeight.w500,
                color: AppColors.textPrimary(context),
              ),
            ),
          ),

          // ── Phone Input ──────────────────────────────────────────────
          Expanded(
            child: Container(
              height: widget.dynamicheight ?? 42,
              decoration: BoxDecoration(
                color: AppColors.containerBackground(context),
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(8),
                  bottomRight: Radius.circular(8),
                ),
                border: Border.all(width: 1, color: borderColor),
              ),
              child: TextField(
                controller: widget.controller,
                focusNode: widget.focusCurrent,
                keyboardType: widget.keyboardType,
                maxLines: widget.keyboardType == TextInputType.multiline ? 5 : 1,
                readOnly: widget.isReadOnly,
                style: widget.inputTextStyle ??
                    AppTextStyles.textSize16(context, weight: FontWeight.w500),
                decoration: InputDecoration(
                  hintText: widget.placeholder,
                  hintStyle: widget.hintTextStyle ??
                      AppTextStyles.textSize16(
                        context,
                        color: AppColors.hintColor(context),
                        weight: FontWeight.w400,
                      ),
                  suffixIcon: widget.isReadOnly
                      ? Icon(Icons.lock_outline, size: 18, color: AppColors.subtitle(context))
                      : null,
                  border: const OutlineInputBorder(borderSide: BorderSide.none),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 10.0,
                    vertical: widget.keyboardType == TextInputType.multiline ? 10.0 : 0,
                  ),
                ),
                onChanged: widget.onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }
}