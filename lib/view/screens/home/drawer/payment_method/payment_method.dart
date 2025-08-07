import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/components/header_appbar.dart';
import 'package:dinmajur_customer/configs/res/sizedbox_spaccing.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:dinmajur_customer/configs/responsive/responsive_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mobkit_dashed_border/mobkit_dashed_border.dart';

class PaymentMethod extends StatefulWidget {
  const PaymentMethod({super.key});

  @override
  State<PaymentMethod> createState() => _PaymentMethodState();
}

class _PaymentMethodState extends State<PaymentMethod> {
  TextEditingController _bikashController = TextEditingController();
  TextEditingController _nogodController = TextEditingController();



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.containerBackground(context),
      body: SafeArea(child: ResPonsiveUi(mobile: body(), desktop: body(), tablet: body())),
    );
  }

  Widget body() {
    final screenWidth = MediaQuery.of(context).size.width * 1;
    final screenHeight = MediaQuery.of(context).size.height * 1;
    return SingleChildScrollView(
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Container(
              height: 60,
              color: AppColors.containerBackground(context),
              child: Center(child: AppBarHeader("Payment Method")),
            ),
          ),
          // SizedboxSpaccing.height025(context),
          addPaymentAccountsWidget()
        ],
      ),
    );
  }



  Widget addPaymentAccountsWidget() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [





          Container(
              width: screenWidth,
              color: AppColors.containerBackground(context),
              padding: EdgeInsets.symmetric(horizontal:screenWidth * 0.04,vertical: screenHeight * 0.015),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [ Text(
                    'Mobile Banking',
                    style: AppTextStyles.textSize18(context,weight: FontWeight.w500,color:AppColors.form_hover(context)),
                  ),

                    SizedBox(height: screenHeight * 0.015),

                    // Bkash Account Card
                    _buildMobileBankingCard(
                      context,
                      svgImg: "assets/images/home/drawer/bikash.svg",
                      title: 'Add your Bkash Account',
                      description: 'Add your Bkash mobile number to receive payments',
                      inputLabel: 'Bkash Number',
                      buttonText: 'Add Bkash Account',
                      controller:_bikashController,
                      button: Color(0xffDB2777),
                      screenWidth: screenWidth,
                      screenHeight: screenHeight,
                      onAddPressed: (){},
                    ),
                    SizedboxSpaccing.height015(context),
                    _buildMobileBankingCard(
                      context,
                      svgImg: "assets/images/home/drawer/nogod.svg",
                      title: 'Add your Nagad Account',
                      description: 'Add your Nagad mobile number to receive payments',
                      inputLabel: 'Nagad Number',
                      buttonText: 'Add Nagad Account',
                      controller: _nogodController,
                      button: Color(0xffEA1D25),
                      screenWidth: screenWidth,
                      screenHeight: screenHeight,
                      onAddPressed: (){},
                    ),

                  ])),
        ],
      ),
    );
  }

  Widget _buildMobileBankingCard(
      BuildContext context, {
        required String svgImg,
        required String title,
        required String description,
        required String inputLabel,
        required String buttonText,
        required Color button,
        required double screenWidth,
        required double screenHeight,
        required VoidCallback onAddPressed,
        required TextEditingController controller,
      }) {
    return Container(
      padding: EdgeInsets.all(screenHeight * 0.01),
      decoration: BoxDecoration(
        // color: AppColors.appBackground(context).withOpacity(0.5),
        color: AppColors.containerBackground(context),
        border: DashedBorder(
          dashLength: 2,
          left: BorderSide(color: AppColors.dashBorder(context), width: 1),
          top: BorderSide(color: AppColors.dashBorder(context), width: 1),
          right: BorderSide(color: AppColors.dashBorder(context), width: 1),
          bottom: BorderSide(color: AppColors.dashBorder(context), width: 1),
        ),
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: Column(
        children: [
          SizedboxSpaccing.height01(context),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 24,
                height: 24,
                color: button,
                child:SvgPicture.asset(svgImg),
              ),

              SizedboxSpaccing.width03(context),

              // Text content
              Container(
                width: screenWidth * 0.72,
                // color: Colors.red,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.textSize14(
                        context,
                        weight: FontWeight.w500,
                      ),
                    ),
                    SizedboxSpaccing.height01(context),
                    Text(
                      description,
                      style: AppTextStyles.textSize12(
                        context,
                        weight: FontWeight.w400,
                      ),
                    ),
                    SizedboxSpaccing.height01(context),
                    Container(
                      width: screenWidth * 0.75,
                      child:  Text(inputLabel, style: AppTextStyles.textSize14(context, weight: FontWeight.w600)),
                    ),
                    SizedboxSpaccing.height012(context),
                    Container(
                      width: screenWidth * 0.75,
                      height: 42,
                      decoration: BoxDecoration(
                        color: AppColors.textFieldFill(context),
                        borderRadius: BorderRadius.circular(10),
                        border:Border.all(
                          width: 1,
                          color: AppColors.border(context),
                        ),
                      ),
                      child: TextFormField(
                        controller: controller,
                        keyboardType: TextInputType.number,
                        style:  AppTextStyles.textSize14(context, weight: FontWeight.w500),
                        decoration: InputDecoration(
                          hintText: "01XXXXXXXXX",
                          hintStyle:  AppTextStyles.textSize12(context,color: AppColors.form_hover(context), weight: FontWeight.w400),
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: EdgeInsets.symmetric( horizontal: 10.0),
                        ),
                      ),
                    ),
                    SizedboxSpaccing.height015(context),
                    Container(
                      height: 50,
                      width: screenWidth * 0.75,
                      decoration: BoxDecoration(
                        color: button,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                            buttonText,
                            style:AppTextStyles.textSize16(context,weight: FontWeight.w600, color: AppColors.whiteColor)
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Container( width: 24,
                height: 24,)
            ],
          ),
          SizedboxSpaccing.height01(context),
        ],
      ),
    );
  }
}
