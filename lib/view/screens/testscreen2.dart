import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/components/header_appbar.dart';
import 'package:dinmajur_customer/configs/res/sizedbox_spaccing.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:dinmajur_customer/configs/responsive/responsive_ui.dart';
import 'package:dinmajur_customer/view/navigation_bar.dart';
import 'package:flutter/material.dart';

class TestScreen2 extends StatefulWidget {
  const TestScreen2({super.key});

  @override
  State<TestScreen2> createState() => _TestScreen2State();
}

class _TestScreen2State extends State<TestScreen2> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.containerBackground(context),
      body: SafeArea(
          child: ResPonsiveUi(
              mobile: body(),
              desktop: body(),
              tablet: body()
          )
      ),
    );
  }

  Widget body() {
    final screenWidth = MediaQuery.of(context).size.width * 1;
    final screenHeight = MediaQuery.of(context).size.height * 1;

    return Column(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context)=>NavigationScreen(initialIndex: 0)));
            },
            child: AppBarHeader("Offers"),
          ),
          Center(child: SizedboxSpaccing.height025(context)),
          _buildSection(title: 'Offers', count: '(0)', emptyMessage: 'No Offers Yet'),

        ]);
  }
  Widget _buildSection({required String title, required String count, required String emptyMessage}) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Container(
      width: screenWidth * 0.9,
      child: Column(
        children: [
          Container(
            // height: 30,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('$title $count', style: AppTextStyles.textSize18(context, weight: FontWeight.w500)),
                    // GestureDetector(
                    //   onTap: () {},
                    //   child: Text('See All', style: AppTextStyles.poppins12(context, weight: FontWeight.w500)),
                    // ),
                  ],
                ),
                Divider(height: 1, color: AppColors.border(context)),
              ],
            ),
          ),
          SizedboxSpaccing.height02(context),
          Container(
            width: double.infinity,
            height: 120,
            decoration: BoxDecoration(color: AppColors.appBackground(context), borderRadius: BorderRadius.circular(12),border: Border.all(width: 1,
                color: AppColors.border(context))),
            child: Center(
              child: Text(
                emptyMessage,
                style: AppTextStyles.textSize18(context,weight: FontWeight.w500, color: AppColors.form_hover(context)),
              ),
            ),
          ),
        ],
      ),
    );
  }

}
