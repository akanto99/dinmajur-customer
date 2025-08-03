import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


class AppTextStyles {
  ///Poppins
  ///h1
  static TextStyle poppinsH1(BuildContext context, {FontWeight? weight, Color? color}) {
    return GoogleFonts.poppins(
      fontSize: 32,
      fontWeight: weight ?? FontWeight.w600,
      color: color ?? AppColors.textPrimary(context),
    );
  }
  ///h2
  static TextStyle poppinsH2(BuildContext context, {FontWeight? weight, Color? color}) {
    return GoogleFonts.poppins(
      fontSize: 28,
      fontWeight: weight ?? FontWeight.w600,
      color: color ?? AppColors.textPrimary(context),
    );
  }
  ///h3
  static TextStyle poppinsH3(BuildContext context,{weight,Color? color}) {
    return GoogleFonts.poppins(
      fontSize: 24,
      fontWeight:weight,
      color: color?? AppColors.textPrimary(context),
    );
  }
  ///18------------------
  static TextStyle poppins18(BuildContext context,{weight,Color? color}) {
    return GoogleFonts.poppins(
      fontSize: 18,
      fontWeight: weight,
      color: color ?? AppColors.textPrimary(context),
    );
  }
  ///12-------------------
  static TextStyle poppins12(BuildContext context, {FontWeight? weight, Color? color}) {
    return GoogleFonts.poppins(
      fontSize: 12,
      fontWeight: weight ?? FontWeight.w400,
      color: color ?? AppColors.textPrimary(context),
    );
  }

  ///14-------------------
  static TextStyle poppins14(BuildContext context,{weight, Color? color}) {
    return GoogleFonts.poppins(
      fontSize: 14,
      fontWeight: weight,
      color: color ?? AppColors.textPrimary(context),
    );
  }
  ///16-------------------
  static TextStyle poppins16(BuildContext context, {FontWeight? weight, Color? color}) {
    return GoogleFonts.poppins(
      fontSize: 16,
      fontWeight: weight ?? FontWeight.w400,
      color: color ?? AppColors.textPrimary(context),
    );
  }
  ///20-------------------
  static TextStyle poppins20(BuildContext context, {FontWeight? weight, Color? color}) {
    return GoogleFonts.poppins(
      fontSize: 20,
      fontWeight: weight ?? FontWeight.w500,
      color: color ?? AppColors.textPrimary(context),
    );
  }
  ///24-------------------
  static TextStyle poppins24(BuildContext context, {FontWeight? weight, Color? color}) {
    return GoogleFonts.poppins(
      fontSize: 24,
      fontWeight: weight ?? FontWeight.w500,
      color: color ?? AppColors.textPrimary(context),
    );
  }

  ///28-------------------
  static TextStyle poppins28(BuildContext context, {FontWeight? weight, Color? color}) {
    return GoogleFonts.poppins(
      fontSize: 28,
      fontWeight: weight ?? FontWeight.w500,
      color: color ?? AppColors.textPrimary(context),
    );
  }

  ///30-------------------
  static TextStyle poppins30(BuildContext context, {FontWeight? weight, Color? color}) {
    return GoogleFonts.poppins(
      fontSize: 30,
      fontWeight: weight ?? FontWeight.w500,
      color: color ?? AppColors.textPrimary(context),
    );
  }



}