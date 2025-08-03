import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:flutter/material.dart';


class CustomPasswordFieldPoppins extends StatefulWidget {
  final TextEditingController controller;
  final String ?titleText;
  final FocusNode? focusNode;
  final ValueNotifier<bool> obsecurePassword;


  const CustomPasswordFieldPoppins({
    Key? key,
    required this.controller,
    this.titleText,
    required this.obsecurePassword,
    this.focusNode,
  }) : super(key: key);

  @override
  State<CustomPasswordFieldPoppins> createState() => _CustomPasswordFieldPoppinsState();
}

class _CustomPasswordFieldPoppinsState extends State<CustomPasswordFieldPoppins> {
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    widget.focusNode?.addListener(_handleFocusChange);
  }

  void _handleFocusChange() {
    if (mounted) {
      setState(() {
        _isFocused = widget.focusNode!.hasFocus;
      });
    }
  }

  @override
  void dispose() {
    widget.focusNode?.removeListener(_handleFocusChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Center(
      child: ValueListenableBuilder(
        valueListenable: widget.obsecurePassword,
        builder: (context, value, child) {
          return Column(
            children: [
              Container(
                width: screenWidth * 0.85,
                child:  Text('${widget.titleText}', style: AppTextStyles.poppins18(context, weight: FontWeight.w500)),
              ),
              SizedBox(height: screenHeight * 0.01,),
              Container(
                width: screenWidth * 0.85,
                height: 42,
                // height: screenHeight*0.05,
                decoration: BoxDecoration(
                  color: AppColors.textFieldFill(context),
                  borderRadius: BorderRadius.circular(12),
                  border:Border.all(
                    width: 1,
                    color: AppColors.border(context),
                  ),
                ),
                child: TextFormField(
                  controller: widget.controller,
                  obscureText: value,
                  focusNode: widget.focusNode,
                  obscuringCharacter: "*",
                  style:  AppTextStyles.poppins16(context, weight: FontWeight.w500),
                  decoration: InputDecoration(
                    // border: InputBorder.none,
                    // hintText: 'Enter 8 characters or more',
                    // hintStyle:  AppTextStyles.siliguri12HintTextField(context, weight: FontWeight.w400),
                    contentPadding: EdgeInsets.symmetric( horizontal: 10.0),
                    hintText:'Enter 8 characters or more',
                    hintStyle:  AppTextStyles.poppins16(context,  color: AppColors.hintColor(context),weight: FontWeight.w400),
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                    ),
                    suffixIcon: GestureDetector(
                      onTap: () {
                        widget.obsecurePassword.value = !widget.obsecurePassword.value;
                      },
                      child: Icon(
                        value
                            ? Icons.visibility_off_outlined
                            : Icons.visibility,
                        color: Color(0xffB7B7B7),
                        size: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
