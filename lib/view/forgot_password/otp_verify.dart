import 'package:dinmajur_customer/configs/buttons/round_button.dart';
import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/components/header_appbar.dart';
import 'package:dinmajur_customer/configs/res/sizedbox_spaccing.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:dinmajur_customer/configs/responsive/responsive_ui.dart';
import 'package:dinmajur_customer/configs/utils/utils.dart';
import 'package:dinmajur_customer/provider/countdown/forgotpassword_countdown/forgotPassword_countdown.dart';
import 'package:dinmajur_customer/view_model/forgot_password_models/post_forgot_otpsend_view_model.dart';
import 'package:dinmajur_customer/view_model/forgot_password_models/post_forgotverifyotp_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OtpVerify extends StatefulWidget {
  const OtpVerify({super.key});

  @override
  State<OtpVerify> createState() => _OtpVerifyState();
}

class _OtpVerifyState extends State<OtpVerify> {
  final TextEditingController pinTEController = TextEditingController();

  @override
  void dispose() {
    pinTEController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            backgroundColor: AppColors.globalBlackWhite(context),
            body: ResPonsiveUi(mobile: body(), desktop: body(), tablet: body())
        )
    );
  }

  Widget body() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final String phone = args?['phone'] ?? '';
    final String userID = args?['userID'] ?? '';
    final String token = args?['token'] ?? '';
    final String role = args?['role'] ?? '';

    return Consumer<ForgotPasswordCountdown>(
        builder: (context, timerProvider, child) {
         return Column(
           children: [
             GestureDetector(
               onTap: () {
                 Navigator.pop(context);
               },
               child: Container(height: 60, child: AppBarHeader("OTP Verification")),
             ),
             SizedboxSpaccing.height025(context),

             Container(
               width: screenWidth * 0.9,
               padding: EdgeInsets.all(screenHeight * 0.02),
               decoration: BoxDecoration(
                 borderRadius: BorderRadius.circular(24),
                 border: Border.all(color: AppColors.border(context), width: 1),
               ),
               child: Column(
                 mainAxisSize: MainAxisSize.min,
                 children: [
                   Text("Verify your number", style: AppTextStyles.poppins18(context, weight: FontWeight.w600)),
                   Text("Sent a code to your number", style: AppTextStyles.poppins14(context, weight: FontWeight.w500)),
                   SizedboxSpaccing.height01(context),
                   Container(
                     child: Text("+88$phone", style: AppTextStyles.poppins18(context, weight: FontWeight.w500)),
                   ),
                   SizedboxSpaccing.height025(context),
                   Container(
                     width: 320,
                     height: 55,
                     child: PinCodeTextField(
                       keyboardType: TextInputType.number,
                       controller: pinTEController,
                       backgroundColor: Colors.transparent,
                       appContext: context,
                       length: 4,
                       obscureText: false,
                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                       animationCurve: Curves.linear,
                       animationDuration: Duration(milliseconds: 0),
                       textStyle: AppTextStyles.poppins16(context, weight: FontWeight.w500),
                       enablePinAutofill: false,
                       pinTheme: PinTheme(
                         fieldWidth: 70,
                         fieldHeight: 55,
                         activeFillColor: AppColors.textFieldFill(context),
                         selectedFillColor: AppColors.textFieldFill(context),
                         inactiveFillColor: AppColors.textFieldFill(context),
                         inactiveColor: AppColors.textFieldFill(context),
                         selectedColor: AppColors.textFieldFill(context),
                         activeColor: AppColors.textFieldFill(context),
                         shape: PinCodeFieldShape.box,
                         borderRadius: BorderRadius.circular(5),
                       ),
                       enableActiveFill: true,
                       // cursorColor: AppColors.coursorColor(context),
                       cursorColor: AppColors.darkRedColor,
                       onChanged: (value) {},
                     ),
                   ),
                 ],
               ),
             ),
             SizedboxSpaccing.height025(context),

             // Verify Button
             Consumer<PostForgotOtpVerifyViewModel>(
               builder: (context, verifyViewModel, child) {
                 return Container(
                   width: screenWidth * 0.8,
                   child: RoundButton(
                     title: 'verify',
                     iconData: Icons.arrow_forward_ios_rounded,
                     loading: verifyViewModel.verifyOTPLoading,
                     onPress: () async {
                       String otpValue = pinTEController.text.trim();

                       if (otpValue.isEmpty) {
                         Utils.flushBarErrorMessage('Enter the OTP', context);
                         return;
                       }

                       if (otpValue.length != 4) {
                         Utils.flushBarErrorMessage('Enter a 4-digit OTP', context);
                         return;
                       }

                       Map<String, dynamic> fields = {
                         "otp": otpValue,
                         "phone": phone,
                         "userId": userID,
                       };

                       verifyViewModel.verifyOtpPostApi(context, fields,onSuccess: (){
                         timerProvider.stopTimer();
                       });
                       pinTEController.clear();
                     },
                   ),
                 );
               },
             ),
             SizedboxSpaccing.height025(context),

             // Resend OTP Section
             Container(
               width: screenWidth * 0.85,
               child: Column(
                 children: [
                   GestureDetector(
                     onTap: () {
                       if (timerProvider.canResend) {
                         // Resend OTP API call
                         final forgotOtpSendViewModel = Provider.of<PostForgotOtpSendViewModel>(context, listen: false);
                         Map<String, dynamic> data = {'phone': phone};

                         forgotOtpSendViewModel.otpSendPostAPI(
                           data,
                           context,
                           onSuccess: () {
                             pinTEController.clear();
                             Utils.flushBarSuccessMessage('নতুন OTP পাঠানো হয়েছে', context);
                           },
                         );
                       }
                     },
                     child: Column(
                       mainAxisAlignment: MainAxisAlignment.center,
                       children: [
                         Text("Haven't received any code? ", style: AppTextStyles.poppins18(context, weight: FontWeight.w500)),
                         Text(
                           timerProvider.formattedTime,
                           style: AppTextStyles.poppins18(context, weight: FontWeight.w500, color: AppColors.button(context)),
                         ),
                       ],
                     ),
                   ),
                   SizedboxSpaccing.height01(context),
                   Builder(
                     builder: (context) {
                       final textStyle = GoogleFonts.poppins(fontSize: 18, color: timerProvider.canResend ? AppColors.button(context) : Colors.grey, fontWeight: FontWeight.w500);

                       final textPainter = TextPainter(
                         text: TextSpan(text: "Send Again", style: textStyle),
                         textDirection: TextDirection.ltr,
                       );
                       textPainter.layout();

                       final textWidth = textPainter.size.width;

                       return Column(
                         mainAxisSize: MainAxisSize.min,
                         children: [
                           Center(child: Text("Send Again", style: textStyle)),
                           // Center(
                           //   child: DottedLine(
                           //     direction: Axis.horizontal,
                           //     lineLength: textWidth,
                           //     lineThickness: 1.0,
                           //     dashLength: 1.0,
                           //     dashColor: timerProvider.canResend
                           //         ? AppColors.button(context)
                           //         : Colors.grey,
                           //     dashRadius: 1,
                           //     dashGapLength: 2.0,
                           //     dashGapColor: Colors.transparent,
                           //   ),
                           // ),
                         ],
                       );
                     },
                   ),
                 ],
               ),
             ),
           ],
         );
        }
    );
  }
}