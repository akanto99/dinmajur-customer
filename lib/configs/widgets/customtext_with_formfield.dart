// import 'package:dinmajur_customer/configs/res/color.dart';
// import 'package:dinmajur_customer/configs/res/text_styles.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
//
// ///Poppins
// class CustomTextFieldWithFormFieldPoppins extends StatefulWidget {
//   final String ?titleText;
//   final String? requiredStar;
//   final String placeholder;
//   final double? dynamicheight;
//   final TextEditingController controller;
//   final FocusNode? focusCurrent;
//   final FocusNode? focusNext;
//   final String? Function(String?)? validator;
//   final Function(String)? onChanged;
//   final TextInputType keyboardType;
//
//   CustomTextFieldWithFormFieldPoppins({
//     Key? key,
//     this.titleText,
//     this.requiredStar,
//     this.dynamicheight,
//     required this.placeholder,
//     required this.controller,
//     this.focusCurrent,
//     this.focusNext,
//     this.validator,
//     this.onChanged,
//     this.keyboardType = TextInputType.text,
//   }) : super(key: key);
//
//   @override
//   State<CustomTextFieldWithFormFieldPoppins> createState() => _CustomTextFieldWithFormFieldPoppinsState();
// }
//
// class _CustomTextFieldWithFormFieldPoppinsState extends State<CustomTextFieldWithFormFieldPoppins> {
//   bool _isFocused = false;
//
//   @override
//   void initState() {
//     super.initState();
//     widget.focusCurrent?.addListener(_handleFocusChange);
//   }
//
//   void _handleFocusChange() {
//     if (mounted) {
//       setState(() {
//         _isFocused = widget.focusCurrent!.hasFocus;
//       });
//     }
//   }
//
//   @override
//   void dispose() {
//     widget.focusCurrent?.removeListener(_handleFocusChange);
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final screenHeight = MediaQuery.of(context).size.height*1;
//     final screenWidth = MediaQuery.of(context).size.width*1;
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Container(
//           // width: screenWidth * 0.75,
//           child:  Text('${widget.titleText}', style: AppTextStyles.textSize18(context, weight: FontWeight.w500)),
//         ),
//         SizedBox(height: screenHeight * 0.012,),
//         FormField<String>(
//           validator: widget.validator,
//           autovalidateMode: AutovalidateMode.onUserInteraction,
//           builder: (FormFieldState<String> fieldState) {
//             return Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Container(
//                   // width: screenWidth * 0.75,
//                   height: 42,
//                   // height: screenHeight*0.05,
//                   decoration: BoxDecoration(
//                     color: AppColors.textFieldFill(context),
//                     borderRadius: BorderRadius.circular(12),
//                     border:Border.all(
//                       width: 1,
//                       color: AppColors.border(context),
//                     ),
//                   ),
//                   child: TextFormField(
//                     controller: widget.controller,
//                     focusNode: widget.focusCurrent,
//                     keyboardType: widget.keyboardType,
//                     maxLines: widget.keyboardType == TextInputType.multiline ? 5 : 1,
//                     style:  AppTextStyles.textSize16(context, weight: FontWeight.w500),
//                     decoration: InputDecoration(
//                       hintText: widget.placeholder,
//                       hintStyle:  AppTextStyles.textSize16(context,      color: AppColors.hintColor(context), weight: FontWeight.w400),
//                       border: OutlineInputBorder(
//                         borderSide: BorderSide.none,
//                       ),
//                       // focusedBorder: OutlineInputBorder(
//                       //   borderRadius: BorderRadius.circular(8.0),
//                       //   borderSide: BorderSide(
//                       //     color: Colors.green,
//                       //     width: 1,
//                       //   ),
//                       // ),
//                       contentPadding: EdgeInsets.symmetric( horizontal: 10.0),
//                     ),
//                     onChanged: (value) {
//                       fieldState.didChange(value);
//                       if (widget.onChanged != null) {
//                         widget.onChanged!(value);
//                       }
//                     },
//                   ),
//                 ),
//                 if (fieldState.hasError)
//                   Container(
//                     width: screenWidth * 0.85,
//                     child: Padding(
//                       padding: const EdgeInsets.only(top: 4.0, left: 10.0),
//                       child: Text(
//                         fieldState.errorText ?? '',
//                         style: const TextStyle(
//                             fontSize: 12,
//                             fontWeight: FontWeight.w400,
//                             color: Colors.red,
//                             letterSpacing: 0.2
//                         ),
//                       ),
//                     ),
//                   ),
//               ],
//             );
//           },
//         ),
//       ],
//     );
//   }
// }
//
//
//
//
//
//
//
//

import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:flutter/material.dart';

/// Poppins TextField with customizable text styles
class CustomTextFieldWithFormFieldPoppins extends StatefulWidget {
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

  CustomTextFieldWithFormFieldPoppins({
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
  State<CustomTextFieldWithFormFieldPoppins> createState() => _CustomTextFieldWithFormFieldPoppinsState();
}

class _CustomTextFieldWithFormFieldPoppinsState extends State<CustomTextFieldWithFormFieldPoppins> {
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

    return Column(
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
                Container(
                  height: widget.dynamicheight ?? 42,
                  decoration: BoxDecoration(
                    color: AppColors.textFieldFill(context),
                    borderRadius: BorderRadius.circular(12),
                    border:Border.all(
                      width: 1,
                      color: AppColors.border(context),
                    ),
                    // border: Border.all(width: 1, color: fieldState.hasError ? Colors.red : (_isFocused ? AppColors.button(context) : AppColors.border(context))),
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
    );
  }
}
