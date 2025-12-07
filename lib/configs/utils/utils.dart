import 'package:another_flushbar/flushbar.dart';
import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Utils {
  static void fieldFocusChange(BuildContext context, FocusNode current, FocusNode nextFocus) {
    current.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

  static toastMessage(String message) {
    Fluttertoast.showToast(msg: message, backgroundColor: Colors.black, textColor: Colors.white);
  }

  static void flushBarSuccessMessage(String message, BuildContext context) {
    Flushbar(
      forwardAnimationCurve: Curves.decelerate,
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: EdgeInsets.all(15),
      messageText: Text(message, style: AppTextStyles.textSize14(context, weight: FontWeight.w400)),
      duration: Duration(seconds: 3),
      borderRadius: BorderRadius.circular(8),
      flushbarPosition: FlushbarPosition.TOP,
      backgroundColor: AppColors.appBackground(context),
      reverseAnimationCurve: Curves.easeInOut,
      positionOffset: 20,
      boxShadows: [BoxShadow(color: AppColors.flushbarColor(context), offset: Offset(0, 2), blurRadius: 6)],
      icon: Icon(Icons.offline_pin_outlined, size: 28, color: Colors.green),
    )..show(context);
  }

  static void flushBarErrorMessage(String message, BuildContext context) {
    Flushbar(
      forwardAnimationCurve: Curves.decelerate,
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: EdgeInsets.all(15),
      messageText: Text(message, style: AppTextStyles.textSize14(context, weight: FontWeight.w400)),
      duration: Duration(seconds: 3),
      borderRadius: BorderRadius.circular(8),
      flushbarPosition: FlushbarPosition.TOP,
      backgroundColor: AppColors.appBackground(context),
      reverseAnimationCurve: Curves.easeInOut,
      positionOffset: 20,
      boxShadows: [BoxShadow(color: AppColors.flushbarColor(context), offset: Offset(0, 2), blurRadius: 6)],
      icon: Icon(Icons.error_outline, size: 28, color: Colors.red),
    )..show(context);
  }

  static void flushBarExclamatoryMessage({required String title, required String subtitle, required BuildContext context}) {
    Flushbar(
      forwardAnimationCurve: Curves.decelerate,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(10),
      borderRadius: BorderRadius.circular(10),
      duration: const Duration(seconds: 3),
      flushbarPosition: FlushbarPosition.TOP,
      reverseAnimationCurve: Curves.easeInOut,
      backgroundColor: const Color(0xffFFFBEB),
      borderColor: Colors.yellow,
      positionOffset: 18,
      boxShadows: [BoxShadow(color: AppColors.flushbarColor(context), offset: const Offset(0, 2), blurRadius: 10)],

      messageText: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(FontAwesomeIcons.triangleExclamation, size: 20, color: Colors.deepOrangeAccent),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.textSize16(context, weight: FontWeight.w600, color: Colors.black),
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          Text(
            subtitle,
            style: AppTextStyles.textSize14(context, weight: FontWeight.w400, color: Colors.black),
          ),
        ],
      ),
    ).show(context);
  }

  static snackBar(String message, BuildContext context) {
    return ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.button(context),
        content: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Text(
            message,
            style: AppTextStyles.textSize14(context, weight: FontWeight.w400, color: AppColors.whiteColor),
          ),
        ),
      ),
    );
  }
}
