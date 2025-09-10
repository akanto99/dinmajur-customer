import 'package:dinmajur_customer/configs/buttons/round_button.dart';
import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/components/header_appbar.dart';
import 'package:dinmajur_customer/configs/res/sizedbox_spaccing.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:dinmajur_customer/configs/responsive/responsive_ui.dart';
import 'package:dinmajur_customer/configs/utils/utils.dart';
import 'package:dinmajur_customer/l10n/app_localizations.dart';
import 'package:dinmajur_customer/provider/countdown/countdown/countdown.dart';
import 'package:dinmajur_customer/view_model/authview_model/authview_model.dart';
import 'package:dinmajur_customer/view_model/authview_model/otp_verify_view_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final TextEditingController pinTEController = TextEditingController();
  @override
  void dispose() {
    pinTEController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: AppColors.globalBlackWhite(context),
        body: SafeArea(child: ResPonsiveUi(mobile: body(), desktop: body(), tablet: body())));
  }

  Widget body() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final String phone = args?['phone'] ?? '';
    String password = args?['password'] ?? '';
    String role = "CUSTOMER";

    return Consumer<CountdownTimerProvider>(
      builder: (context, timerProvider, _) {
        return Column(
          children: [
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Container(height: 60, child: AppBarHeader(AppLocalizations.of(context)!.otp_verification_title)),
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
                  Text(AppLocalizations.of(context)!.verify_your_number, style: AppTextStyles.textSize18(context, weight: FontWeight.w600)),
                  Text(AppLocalizations.of(context)!.sent_code_to_number, style: AppTextStyles.textSize14(context, weight: FontWeight.w500)),
                  SizedboxSpaccing.height01(context),
                  Container(
                    child: Text("+88$phone", style: AppTextStyles.textSize18(context, weight: FontWeight.w500)),
                  ),
                  SizedboxSpaccing.height025(context),
                  Container(
                    width: 320,
                    height: 55,
                    child: PinCodeTextField(
                      keyboardType: TextInputType.number,
                      controller: pinTEController,
                      backgroundColor: Colors.transparent,
                      appContext: (context),
                      length: 4,
                      obscureText: false,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      // obscuringCharacter: 'X',
                      // animationCurve:Curves.bounceOut,
                      animationCurve: Curves.linear,
                      animationDuration: Duration(milliseconds: 0),

                      textStyle: AppTextStyles.textSize16(context, weight: FontWeight.w600),
                      enablePinAutofill: false,
                      pinTheme: PinTheme(
                        fieldWidth: 60,
                        fieldHeight: 55,
                        // activeFillColor: AppColors.textFieldColor,
                        // activeFillColor: AppColors.textFieldColor,
                        activeFillColor: AppColors.textFieldFill(context),
                        // selectedFillColor: AppColors.textFieldColor,
                        selectedFillColor: AppColors.textFieldFill(context),
                        // inactiveFillColor: AppColors.textFieldColor,
                        inactiveFillColor: AppColors.textFieldFill(context),

                        /// inactiveColor: Colors.red,
                        // inactiveColor: AppColors.textFieldColor,
                        inactiveColor: AppColors.textFieldFill(context),

                        /// selectedColor: Colors.black,
                        // selectedColor: AppColors.textFieldColor,
                        selectedColor: AppColors.textFieldFill(context),

                        /// activeColor: Colors.yellow,
                        // activeColor: AppColors.textFieldColor,
                        activeColor: AppColors.textFieldFill(context),
                        shape: PinCodeFieldShape.box,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      enableActiveFill: true,
                      cursorColor: AppColors.coursorColor(context),

                    ),
                  ),

                ],
              ),
            ),
            SizedboxSpaccing.height025(context),

            Consumer<OtpVerifyViewModel>(
              builder: (context, verify, child) {
                return Container(
                  width: screenWidth * 0.79,
                  child: RoundButton(
                    title: AppLocalizations.of(context)!.next,
                    iconData: Icons.arrow_forward_ios_rounded,
                    loading: verify.otpVerifyloading,
                    onPress: () async {
                      if (pinTEController.text.isEmpty || pinTEController.text.length < 4) {
                        Utils.flushBarErrorMessage(AppLocalizations.of(context)!.please_enter_valid_otp, context);
                      } else {
                        Map data = {'otpCode': pinTEController.text.toString()};
                        verify.otpVerify(data, context);
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setBool("isPhoneVerified", true);
                        setState(() {
                          pinTEController.clear();
                          prefs.remove('otpphone');
                          prefs.remove('otppassword');
                          prefs.remove('re_enterpassword');
                        });
                        // Navigator.pushNamed(context, RoutesName.multistep);
                      }
                    },
                  ),
                );
              },
            ),

            SizedboxSpaccing.height025(context),

            Container(
              width: screenWidth * 0.85,
              child: Column(
                children: [
                  GestureDetector(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(AppLocalizations.of(context)!.havent_received_code, style: AppTextStyles.textSize16(context, weight: FontWeight.w500)),
                        Text(
                         "${timerProvider.formattedTime}",
                          style: AppTextStyles.textSize16(context, weight: FontWeight.w500, color: AppColors.button(context)),
                        ),
                      ],
                    ),
                  ),
                  SizedboxSpaccing.height01(context),

                  GestureDetector(
                    onTap: (){
                      if (timerProvider.canResend) {
                        // Resend OTP API call
                        final authViewModel = Provider.of<AuthenticationViewModel>(context, listen: false);
                        Map data = {'phone': phone, 'password': password, 'role': role};

                        authViewModel.otpApi(
                          data,
                          context,
                          onSuccess: () async {
                            pinTEController.clear();
                            Utils.flushBarSuccessMessage(AppLocalizations.of(context)!.otp_sent_success, context);
                          },
                        );
                      }
                    },
                    child: Builder(
                      builder: (context) {
                        final textStyle = GoogleFonts.hindSiliguri(fontSize: 18, color: timerProvider.canResend ? AppColors.button(context) : Colors.grey, fontWeight: FontWeight.w500);

                        final textPainter = TextPainter(
                          text: TextSpan(text: "Send Again", style: textStyle),
                          textDirection: TextDirection.ltr,
                        );
                        textPainter.layout();

                        // final textWidth = textPainter.size.width;

                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Center(child: Text(AppLocalizations.of(context)!.send_again, style: textStyle)),
                            // Center(
                            //   child: DottedLine(
                            //     direction: Axis.horizontal,
                            //     lineLength: textWidth,
                            //     lineThickness: 1.0,
                            //     dashLength: 1.0,
                            //     dashColor: timerProvider.canResend ? AppColors.button(context) : Colors.grey,
                            //     dashRadius: 1,
                            //     dashGapLength: 2.0,
                            //     dashGapColor: Colors.transparent,
                            //   ),
                            // ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
