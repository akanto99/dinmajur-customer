import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:dinmajur_customer/provider/DarkAndLightTheme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class CustomTextFormField extends StatefulWidget {
  final String ?titleText;
  final String? requiredStar;
  final String placeholder;
  final double? dynamicheight;
  final TextEditingController controller;
  final FocusNode? focusCurrent;
  final FocusNode? focusNext;
  final String? Function(String?)? validator;
  final Function(String)? onChanged;
  final TextInputType keyboardType;

  CustomTextFormField({
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
  }) : super(key: key);

  @override
  State<CustomTextFormField> createState() => _CustomTextFormFieldState();
}

class _CustomTextFormFieldState extends State<CustomTextFormField> {
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    return Column(
      children: [
        Container(
          width: screenWidth * 0.9,
          child:  Text('${widget.titleText}', style: AppTextStyles.poppins18(context, weight: FontWeight.w500)),
        ),
        SizedBox(height: screenHeight * 0.012,),
        Container(
          width: screenWidth * 0.9,
          height: 42,
          // height: screenHeight*0.05,
          decoration: BoxDecoration(
              color: AppColors.textFieldFill(context),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  width: 1,
                  color: AppColors.border(context)
              )
          ),
          child: TextFormField(
            controller: widget.controller,
            focusNode: widget.focusCurrent,
            keyboardType: widget.keyboardType,
            maxLines: widget.keyboardType == TextInputType.multiline ? 2 : 1,
            style:  AppTextStyles.poppins16(context, weight: FontWeight.w500),
            decoration: InputDecoration(
              hintText: widget.placeholder,
              hintStyle:  AppTextStyles.poppins16(context,      color: AppColors.hintColor(context), weight: FontWeight.w400),
              border: OutlineInputBorder(
                borderSide: BorderSide.none,
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 10.0),
            ),
            validator: widget.validator,
            onChanged: (value) {
              if (widget.onChanged != null) {
                widget.onChanged!(value);
              }
            },
          ),
        ),
      ],
    );
  }
}
