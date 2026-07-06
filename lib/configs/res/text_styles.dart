import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/provider/language_change_provider/language_change_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class AppTextStyles {

  ///h1 large — hero numbers (e.g. prominent rating/stat displays)
  static TextStyle textSize36(BuildContext context, {FontWeight? weight, Color? color}) {
    final languageProvider = Provider.of<LanguageChangeProvider>(context, listen: false);
    final isBengali = languageProvider.appLocale?.languageCode == 'bn';
    return TextStyle(
      fontFamily: isBengali ? "hindSiliguri" : "poppins",
      fontSize: 36,
      fontWeight: weight ?? FontWeight.w600,
      color: color ?? AppColors.textPrimary(context),
    );
  }

  ///h1
  static TextStyle textSize32(BuildContext context, {FontWeight? weight, Color? color}) {
final languageProvider = Provider.of<LanguageChangeProvider>(context, listen: false);    final isBengali = languageProvider.appLocale?.languageCode == 'bn';
    return TextStyle(
      fontFamily: isBengali ? "hindSiliguri" : "poppins",
      fontSize: 32,
      fontWeight: weight ?? FontWeight.w600,
      color: color ?? AppColors.textPrimary(context),
    );
  }
  ///h2
  static TextStyle textSize28(BuildContext context, {FontWeight? weight, Color? color}) {
final languageProvider = Provider.of<LanguageChangeProvider>(context, listen: false);    final isBengali = languageProvider.appLocale?.languageCode == 'bn';
    return TextStyle(
      fontFamily: isBengali ? "hindSiliguri" : "poppins",
      fontSize: 28,
      fontWeight: weight ?? FontWeight.w600,
      color: color ?? AppColors.textPrimary(context),
    );
  }
  ///h3
  static TextStyle textSize24(BuildContext context, {FontWeight? weight, Color? color}) {
final languageProvider = Provider.of<LanguageChangeProvider>(context, listen: false);    final isBengali = languageProvider.appLocale?.languageCode == 'bn';
    return TextStyle(
      fontFamily: isBengali ? "hindSiliguri" : "poppins",
      fontSize: 24,
      fontWeight: weight ?? FontWeight.w600,
      color: color ?? AppColors.textPrimary(context),
    );
  }
  static TextStyle textSize26(BuildContext context, {FontWeight? weight, Color? color}) {
    final languageProvider = Provider.of<LanguageChangeProvider>(context, listen: false);    final isBengali = languageProvider.appLocale?.languageCode == 'bn';
    return TextStyle(
      fontFamily: isBengali ? "hindSiliguri" : "poppins",
      fontSize: 26,
      fontWeight: weight ?? FontWeight.w600,
      color: color ?? AppColors.textPrimary(context),
    );
  }
  ///18------------------
  static TextStyle textSize18(BuildContext context, {FontWeight? weight, Color? color}) {
final languageProvider = Provider.of<LanguageChangeProvider>(context, listen: false);    final isBengali = languageProvider.appLocale?.languageCode == 'bn';
    return TextStyle(
      fontFamily: isBengali ? "hindSiliguri" : "poppins",
      fontSize: 18,
      fontWeight: weight ?? FontWeight.w500,
      color: color ?? AppColors.textPrimary(context),
    );
  }
  ///10-------------------
  static TextStyle textSize10(BuildContext context, {FontWeight? weight, Color? color}) {
    final languageProvider = Provider.of<LanguageChangeProvider>(context, listen: false);    final isBengali = languageProvider.appLocale?.languageCode == 'bn';
    return TextStyle(
      fontFamily: isBengali ? "hindSiliguri" : "poppins",
      fontSize: 10,
      fontWeight: weight ?? FontWeight.w400,
      color: color ?? AppColors.textPrimary(context),
    );
  }


  ///12-------------------
  static TextStyle textSize12(BuildContext context, {FontWeight? weight, Color? color}) {
final languageProvider = Provider.of<LanguageChangeProvider>(context, listen: false);    final isBengali = languageProvider.appLocale?.languageCode == 'bn';
    return TextStyle(
      fontFamily: isBengali ? "hindSiliguri" : "poppins",
      fontSize: 12,
      fontWeight: weight ?? FontWeight.w400,
      color: color ?? AppColors.textPrimary(context),
    );
  }

  ///14-------------------
  static TextStyle textSize14(BuildContext context, {FontWeight? weight, Color? color}) {
final languageProvider = Provider.of<LanguageChangeProvider>(context, listen: false);    final isBengali = languageProvider.appLocale?.languageCode == 'bn';
    return TextStyle(
      fontFamily: isBengali ? "hindSiliguri" : "poppins",
      fontSize: 14,
      fontWeight: weight ?? FontWeight.w400,
      color: color ?? AppColors.textPrimary(context),
    );
  }

  ///13-------------------
  static TextStyle textSize13(BuildContext context, {FontWeight? weight, Color? color}) {
final languageProvider = Provider.of<LanguageChangeProvider>(context, listen: false);    final isBengali = languageProvider.appLocale?.languageCode == 'bn';
    return TextStyle(
      fontFamily: isBengali ? "hindSiliguri" : "poppins",
      fontSize: 13,
      fontWeight: weight ?? FontWeight.w400,
      color: color ?? AppColors.textPrimary(context),
    );
  }

  ///11-------------------
  static TextStyle textSize11(BuildContext context, {FontWeight? weight, Color? color}) {
final languageProvider = Provider.of<LanguageChangeProvider>(context, listen: false);    final isBengali = languageProvider.appLocale?.languageCode == 'bn';
    return TextStyle(
      fontFamily: isBengali ? "hindSiliguri" : "poppins",
      fontSize: 11,
      fontWeight: weight ?? FontWeight.w400,
      color: color ?? AppColors.textPrimary(context),
    );
  }
  ///16-------------------
  static TextStyle textSize16(BuildContext context, {FontWeight? weight, Color? color}) {
final languageProvider = Provider.of<LanguageChangeProvider>(context, listen: false);    final isBengali = languageProvider.appLocale?.languageCode == 'bn';
    return TextStyle(
      fontFamily: isBengali ? "hindSiliguri" : "poppins",
      fontSize: 16,
      fontWeight: weight ?? FontWeight.w400,
      color: color ?? AppColors.textPrimary(context),
    );
  }
  ///20-------------------
  static TextStyle textSize20(BuildContext context, {FontWeight? weight, Color? color}) {
final languageProvider = Provider.of<LanguageChangeProvider>(context, listen: false);
final isBengali = languageProvider.appLocale?.languageCode == 'bn';
    return TextStyle(
      fontFamily: isBengali ? "hindSiliguri" : "poppins",
      fontSize: 20,
      fontWeight: weight ?? FontWeight.w500,
      color: color ?? AppColors.textPrimary(context),
    );
  }
  static TextStyle textSize22(BuildContext context, {FontWeight? weight, Color? color}) {
    final languageProvider = Provider.of<LanguageChangeProvider>(context, listen: false);
    final isBengali = languageProvider.appLocale?.languageCode == 'bn';
    return TextStyle(
      fontFamily: isBengali ? "hindSiliguri" : "poppins",
      fontSize: 22,
      fontWeight: weight ?? FontWeight.w500,
      color: color ?? AppColors.textPrimary(context),
    );
  }

  ///30-------------------
  static TextStyle textSize30(BuildContext context, {FontWeight? weight, Color? color}) {
final languageProvider = Provider.of<LanguageChangeProvider>(context, listen: false);    final isBengali = languageProvider.appLocale?.languageCode == 'bn';
    return TextStyle(
      fontFamily: isBengali ? "hindSiliguri" : "poppins",
      fontSize: 30,
      fontWeight: weight ?? FontWeight.w500,
      color: color ?? AppColors.textPrimary(context),
    );
  }


}