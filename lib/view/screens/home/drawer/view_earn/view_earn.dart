import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/components/header_appbar.dart';
import 'package:dinmajur_customer/configs/res/sizedbox_spaccing.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:dinmajur_customer/configs/responsive/responsive_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ViewEarn extends StatefulWidget {
  const ViewEarn({super.key});

  @override
  State<ViewEarn> createState() => _ViewEarnState();
}

class _ViewEarnState extends State<ViewEarn> {

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: AppColors.containerBackground(context),
      body: SafeArea(child: ResPonsiveUi(mobile: body(), desktop: body(), tablet: body())),
    );
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
          child: Container(height: 60, color: AppColors.containerBackground(context), child: Center(child: AppBarHeader("Earnings"))),
        ),
        SizedboxSpaccing.height025(context),
        howToEarnMoneyWidget()
      ],
    );
  }

  Widget howToEarnMoneyWidget() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Column(
      children: [

        Container(
          width: screenWidth * 0.9,
          height: 150,
          padding: EdgeInsets.all(screenHeight * 0.02),
          decoration: BoxDecoration(
              color: AppColors.containerBackground(context),
              borderRadius: BorderRadius.circular(24), border: Border.all(color: AppColors.textFieldFill(context), width: 1)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Title
              Text('No Earnings Yet', style: AppTextStyles.textSize24(context, weight: FontWeight.w600, color: AppColors.button(context)), textAlign: TextAlign.center),

              SizedboxSpaccing.height01(context),

              // Description
              Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                child: Text(
                  "Complete tasks and jobs to start earning money on our platform",
                  style: AppTextStyles.textSize16(context, weight: FontWeight.w400),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
        SizedboxSpaccing.height04(context),
        SizedboxSpaccing.height04(context),
        Container(
          width: screenWidth*0.9,
          padding: EdgeInsets.all(screenHeight * 0.02),
          decoration: BoxDecoration(
            color: AppColors.containerBackground(context),
    borderRadius: BorderRadius.circular(24),
    border: Border.all(color: AppColors.textFieldFill(context), width: 1),

    // boxShadow: [
            //   BoxShadow(
            //     color: Colors.black.withOpacity(0.05),
            //     blurRadius: 10,
            //     offset: const Offset(0, 2),
            //   ),
            // ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'How to earn money?',
                style: AppTextStyles.textSize18(
                  context,
                  weight: FontWeight.w500,),
              ),
              SizedboxSpaccing.height02(context),
              _buildOptionItem(
                context,
                icon: FontAwesomeIcons.tasks,
                title: 'Complete available tasks',
                subtitle: 'Browse and accept tasks in your area',
                screenWidth: screenWidth,
                screenHeight: screenHeight,
              ),

              SizedboxSpaccing.height015(context),

              // Apply for jobs option
              _buildOptionItem(
                context,
                icon: FontAwesomeIcons.briefcase,
                title: 'Apply for jobs',
                subtitle: 'Find long-term opportunities',
                screenWidth: screenWidth,
                screenHeight: screenHeight,
              ),

            ],
          ),
        ),
        SizedboxSpaccing.height025(context),
        Container(
            height: screenHeight*0.055,
            width: screenWidth*0.9,
            decoration: BoxDecoration(
                color:Color(0xff00424D),
                borderRadius: BorderRadius.circular(8)
            ),
            child:     Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(FontAwesomeIcons.search, color: Colors.white, size: 16,),
                SizedboxSpaccing.width03(context),

                Text("Explore available tasks",style: AppTextStyles.textSize16(context,color: AppColors.whiteColor,weight: FontWeight.w600,),),


              ],
            )
        ),
      ],
    );
  }
  Widget howToEarnMoney() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Column(
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // Top spacing
            SizedBox(height: screenHeight * 0.05),
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.button(context),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: SvgPicture.asset('assets/images/home/home_screen/earnings.svg', color: AppColors.whiteColor,
                  width: 35,
                  height: 35,
                ),
              ),
            ),

            SizedboxSpaccing.height015(context),

            // Title
            Text(
              'No earnings yet',
              style: AppTextStyles.textSize24(context,),
              textAlign: TextAlign.center,
            ),

            SizedboxSpaccing.height015(context),

            // Description
            Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
              child: Text(
                'Complete tasks and jobs to start earning money on our platform',
                style: AppTextStyles.textSize14(
                  context,
                  weight: FontWeight.w400,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            SizedboxSpaccing.height015(context),


            Container(
              width: screenWidth*0.9,
              padding: EdgeInsets.all(screenWidth * 0.05),
              decoration: BoxDecoration(
                color: AppColors.containerBackground(context),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'How to earn money?',
                    style: AppTextStyles.textSize14(
                      context,
                      weight: FontWeight.w600,),
                  ),
                  SizedboxSpaccing.height015(context),
                  _buildOptionItem(
                    context,
                    icon: Icons.format_list_bulleted,
                    title: 'Complete available tasks',
                    subtitle: 'Browse and accept tasks in your area',
                    screenWidth: screenWidth,
                    screenHeight: screenHeight,
                  ),

                  SizedboxSpaccing.height015(context),

                  // Apply for jobs option
                  _buildOptionItem(
                    context,
                    icon: Icons.work_outline,
                    title: 'Apply for jobs',
                    subtitle: 'Find long-term opportunities',
                    screenWidth: screenWidth,
                    screenHeight: screenHeight,
                  ),

                ],
              ),
            ),
          ],
        ),
        SizedboxSpaccing.height015(context),
        SizedboxSpaccing.height015(context),
        Container(
            height: screenHeight*0.055,
            width: screenWidth*0.9,
            decoration: BoxDecoration(
                color:Color(0xff00424D),
                borderRadius: BorderRadius.circular(8)
            ),
            child:     Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search, color: Colors.white, size: 15,),
                SizedboxSpaccing.width02(context),

                Text("Explore available tasks",style: AppTextStyles.textSize12(context,color: AppColors.whiteColor,weight: FontWeight.w600,),),


              ],
            )
        ),
      ],
    );
  }

  Widget _buildOptionItem(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String subtitle,
        required double screenWidth,
        required double screenHeight,
      }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Icon container
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.appBackground(context),
           shape: BoxShape.circle
          ),
          child: Center(
            child: Icon(
              icon,
              color: AppColors.textPrimary(context),
              size: 18,
            ),
          ),
        ),

        SizedboxSpaccing.width03(context),

        // Text content
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppTextStyles.textSize16(
                context,
                weight: FontWeight.w500,),
            ),
            // SizedboxSpaccing.height005(context),
            Text(
              subtitle,
              style: AppTextStyles.textSize14(
                context,
                weight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ],
    );
  }

}
