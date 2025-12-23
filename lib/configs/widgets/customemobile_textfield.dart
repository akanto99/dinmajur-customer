import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:flutter/material.dart';

/// Poppins TextField with customizable text styles
class CustomeMobileTextfield extends StatefulWidget {
  final String? titleText;
  final String? requiredStar;
  final String placeholder;
  final double? dynamicheight;
  final TextEditingController controller;
  final FocusNode? focusCurrent;
  final FocusNode? focusNext;
  final String? Function(String?)? validator;
  final Function(String)? onChanged;
  final TextInputType keyboardType;

  // ✨ NEW: Customizable text styles
  final TextStyle? titleTextStyle;
  final TextStyle? inputTextStyle;
  final TextStyle? hintTextStyle;
  final TextStyle? errorTextStyle;

  final bool isReadOnly;

  CustomeMobileTextfield({
    Key? key,
    this.titleText,
    this.requiredStar,
    this.dynamicheight,
    required this.placeholder,
    required this.controller,
    this.focusCurrent,
    this.focusNext,
    this.validator,
    this.onChanged,
    this.keyboardType = TextInputType.text,
    // Custom text styles (optional - uses defaults if null)
    this.titleTextStyle,
    this.inputTextStyle,
    this.hintTextStyle,
    this.errorTextStyle,

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

    return Container(
      width: screenWidth*0.75,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title Text
          if (widget.titleText != null)
            Container(
              child: Text('${widget.titleText}', style: widget.titleTextStyle ?? AppTextStyles.textSize18(context, weight: FontWeight.w500)),
            ),

          if (widget.titleText != null) SizedBox(height: screenHeight * 0.012),

          // Form Field
          FormField<String>(
            validator: widget.validator,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            builder: (FormFieldState<String> fieldState) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Country Code Container
                      Container(
                        width: 57,
                        height: 42,
                        decoration: BoxDecoration(
                          color: AppColors.containerBackground(context),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(8),
                            bottomLeft: Radius.circular(8),
                          ),
                          border: Border(
                            left: BorderSide(width: 1, color: fieldState.hasError ? Colors.red : (_isFocused ? AppColors.button(context) : AppColors.border(context))),
                            top: BorderSide(width: 1, color: fieldState.hasError ? Colors.red : (_isFocused ? AppColors.button(context) : AppColors.border(context))),
                            bottom: BorderSide(width: 1, color: fieldState.hasError ? Colors.red : (_isFocused ? AppColors.button(context) : AppColors.border(context))),
                          ),
                        ),
                        child: Center(
                            child: Text(
                                "+880",
                                style: widget.titleTextStyle ?? AppTextStyles.textSize16(context, weight: FontWeight.w500, color: AppColors.textPrimary(context))
                            )
                        ),
                      ),
                      // Phone Number Input Field
                      Expanded(
                        child: Container(
                          height: widget.dynamicheight ?? 42,
                          decoration: BoxDecoration(
                            color: AppColors.containerBackground(context),
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(8),
                              bottomRight: Radius.circular(8),
                            ),
                            border: Border.all(
                              width: 1,
                              color: fieldState.hasError ? Colors.red : (_isFocused ? AppColors.button(context) : AppColors.border(context)),
                            ),
                          ),
                          child: TextFormField(
                            controller: widget.controller,
                            focusNode: widget.focusCurrent,
                            keyboardType: widget.keyboardType,
                            maxLines: widget.keyboardType == TextInputType.multiline ? 5 : 1,
                            readOnly: widget.isReadOnly,
                            style: widget.inputTextStyle ?? AppTextStyles.textSize16(context, weight: FontWeight.w500),
                            decoration: InputDecoration(
                              hintText: widget.placeholder,
                              hintStyle: widget.hintTextStyle ?? AppTextStyles.textSize16(context, color: AppColors.hintColor(context), weight: FontWeight.w400),
                              suffixIcon: widget.isReadOnly ? Icon(Icons.lock_outline, size: 18, color: AppColors.subtitle(context)) : null,
                              border: OutlineInputBorder(borderSide: BorderSide.none),
                              contentPadding: EdgeInsets.symmetric(horizontal: 10.0, vertical: widget.keyboardType == TextInputType.multiline ? 10.0 : 0),
                            ),

                            onChanged: (value) {
                              fieldState.didChange(value);
                              if (widget.onChanged != null) {
                                widget.onChanged!(value);
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Error Text
                  if (fieldState.hasError)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0, left: 10.0),
                      child: Text(
                        fieldState.errorText ?? '',
                        style: widget.errorTextStyle ?? const TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: Colors.red, letterSpacing: 0.2),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}