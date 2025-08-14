
import 'package:flutter/material.dart';

class AppColors {
  static const Color whiteColor = Colors.white;
  static const Color blackColor = Colors.black;


  ///Drawer
  static const Color darkRedColor = Color(0xffDC2626);
  static const Color splashScreenColor = Color(0xff6A8990);






///Global Bg
  static Color globalBlackWhite(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? Colors.black
          :  Colors.white;
///Application Bg
  static Color appBackground(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? Color(0xff221E20)
          : const Color(0xffF5F5F5);

///textFiled Fill
  static Color textFieldFill(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? Colors.grey[900]!
          : const Color(0xffF9F9F9);
///textFiled hint
  static Color hintColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? Colors.grey[400]!
          : const Color(0xffB7B7B7);
///border
  static Color border(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? Colors.grey[600]!
          // : const Color(0xffE7E9E9);
          : const Color(0xffE0E0E0);


///Container fill
  static Color containerBackground(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? Colors.black
          : Colors.white;

///button bg /Branding
  static Color button(BuildContext context) => const Color(0xff00424D);

  ///Global svgImages
  static Color svgImages(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ?   Colors.white :Color(0xff00424D);

  ///Logout
  static Color logoutColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? Colors.white
          :  Color(0xffDC2626);

  ///Deeeep Greay
  static Color CircleDeepGrey(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? Colors.grey.withOpacity(0.1)
          : const Color(0xffE0E0E0);

  ///Deeeep SVG
  static Color form_hover(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? const Color(0xffFAFAFA)
          : const Color(0xffB7B7B7);
  ///Subtitle
  static Color subtitle(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? const Color(0xffFAFAFA)
          : const Color(0xff676767);

///Dash Border
  static Color dashBorder(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? Colors.grey[600]!
          : const Color(0xffE0E0E0);

  ///flushbar Color
  static Color flushbarColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? Colors.black12
          :Colors.white12;

  ///Cursor Color
  static Color coursorColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? Colors.white
          : Colors.black;




  ///TextPrimary (black/white)
  static Color textPrimary(BuildContext context) =>
  Theme.of(context).brightness == Brightness.dark
  ? const Color(0xffFAFAFA)
      : const Color(0xff221E20);
///TextSecondary ()
  static Color textSecondarySubtitle(BuildContext context) =>
  Theme.of(context).brightness == Brightness.dark
  ? Colors.grey[400]!
      : const Color(0xff737373);



}
