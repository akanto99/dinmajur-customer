import 'package:another_flushbar/flushbar.dart';
import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';


class Utils {
  static void fieldFocusChange(BuildContext context, FocusNode current, FocusNode nextFocus) {
    current.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

  static toastMessage(String message) {
    Fluttertoast.showToast(
      msg: message,
      backgroundColor: Colors.black,
      textColor: Colors.white,
    );
  }



  static void flushBarSuccessMessage(String message, BuildContext context) {
    Flushbar(
      forwardAnimationCurve: Curves.decelerate,
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: EdgeInsets.all(15),
      messageText: Text(
        message,
        style: AppTextStyles.poppins14(context,weight: FontWeight.w400),
      ),
      duration: Duration(seconds: 3),
      borderRadius: BorderRadius.circular(8),
      flushbarPosition: FlushbarPosition.TOP,
      backgroundColor: AppColors.appBackground(context),
      reverseAnimationCurve: Curves.easeInOut,
      positionOffset: 20,
      boxShadows: [
        BoxShadow(
          color:AppColors.flushbarColor(context),
          offset: Offset(0, 2),
          blurRadius: 6,
        ),
      ],
      icon: Icon(Icons.offline_pin_outlined, size: 28, color: Colors.green),
    )..show(context);
  }


  static void flushBarErrorMessage(String message, BuildContext context) {
    Flushbar(
      forwardAnimationCurve: Curves.decelerate,
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: EdgeInsets.all(15),
      messageText: Text(
        message,
        style: AppTextStyles.poppins14(context,weight: FontWeight.w400),
      ),
      duration: Duration(seconds: 3),
      borderRadius: BorderRadius.circular(8),
      flushbarPosition: FlushbarPosition.TOP,
      backgroundColor: AppColors.appBackground(context),
      reverseAnimationCurve: Curves.easeInOut,
      positionOffset: 20,
      boxShadows: [
        BoxShadow(
          color:AppColors.flushbarColor(context),
          offset: Offset(0, 2),
          blurRadius: 6,
        ),
      ],
      icon: Icon(Icons.error_outline, size: 28, color: Colors.red),
    )..show(context);
  }


  static snackBar(String message, BuildContext context) {
    return ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: AppColors.button(context),
      content: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Text(
          message,
          style: AppTextStyles.poppins14(context,weight: FontWeight.w400),
        ),
      ),
    ));
  }

}
