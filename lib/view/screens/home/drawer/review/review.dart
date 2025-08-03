import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/components/header_appbar.dart';
import 'package:dinmajur_customer/configs/res/sizedbox_spaccing.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:dinmajur_customer/configs/responsive/responsive_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Review extends StatefulWidget {
  const Review({super.key});

  @override
  State<Review> createState() => _ReviewState();
}

class _ReviewState extends State<Review> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: AppColors.containerBackground(context), body: SafeArea(child: ResPonsiveUi(mobile: body(), desktop: body(), tablet: body())));
  }

  Widget body() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Container(height: 60, color: AppColors.containerBackground(context), child: Center(child: AppBarHeader("Reviews"))),
        ),
        SizedboxSpaccing.height025(context),

        Container(
          width: screenWidth * 0.9,
          padding: EdgeInsets.all(screenHeight * 0.02),
          decoration: BoxDecoration(
              color: AppColors.containerBackground(context),borderRadius: BorderRadius.circular(24), border: Border.all(color: AppColors.textFieldFill(context), width: 1)),
          child: Column(
            children: [
              // Title
              Text('No Reviews Yet', style: AppTextStyles.poppinsH3(context, weight: FontWeight.w600, color: AppColors.button(context)), textAlign: TextAlign.center),

              SizedboxSpaccing.height01(context),

              // Description
              Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                child: Text(
                  "You don't have any customer reviews yet. Reviews will appear here once customers start rating your services.",
                  style: AppTextStyles.poppins16(context, weight: FontWeight.w400),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget noTasksWidget() {
    final screenWidth = MediaQuery.of(context).size.width * 1;
    final screenHeight = MediaQuery.of(context).size.height * 1;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedboxSpaccing.height01(context),
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(color: AppColors.button(context), shape: BoxShape.circle),
          child: Center(child: Icon(CupertinoIcons.star, size: 40, color: AppColors.whiteColor)),
        ),

        SizedboxSpaccing.height015(context),

        // Title
        Text('No Reviews Yet', style: AppTextStyles.poppins24(context), textAlign: TextAlign.center),

        SizedboxSpaccing.height015(context),

        // Description
        Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
          child: Text(
            "You don't have any customer reviews yet. Reviews will appear here once customers start rating your services.",
            style: AppTextStyles.poppins24(context, weight: FontWeight.w400),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget noReview() {
    final screenWidth = MediaQuery.of(context).size.width * 1;
    final screenHeight = MediaQuery.of(context).size.height * 1;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedboxSpaccing.height01(context),
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(color: AppColors.button(context), shape: BoxShape.circle),
          child: Center(child: Icon(CupertinoIcons.star, size: 40, color: AppColors.whiteColor)),
        ),

        SizedboxSpaccing.height015(context),

        // Title
        Text('No Reviews Yet', style: AppTextStyles.poppins24(context), textAlign: TextAlign.center),

        SizedboxSpaccing.height015(context),

        // Description
        Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
          child: Text(
            "You don't have any customer reviews yet. Reviews will appear here once customers start rating your services.",
            style: AppTextStyles.poppins14(context, weight: FontWeight.w400),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
