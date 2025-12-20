import 'package:dinmajur_customer/configs/buttons/round_button.dart';
import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/components/header_appbar.dart';
import 'package:dinmajur_customer/configs/res/sizedbox_spaccing.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:dinmajur_customer/configs/responsive/responsive_ui.dart';
import 'package:dinmajur_customer/configs/utils/utils.dart';
import 'package:dinmajur_customer/l10n/app_localizations.dart';
import 'package:dinmajur_customer/provider/countdown/countdown/countdown.dart';
import 'package:dinmajur_customer/view_model/auth_view_model_new/customer_authlogin_view_model.dart';
import 'package:dinmajur_customer/view_model/auth_view_model_new/customer_otp_view_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';

class CustomerAuthOtpScreen extends StatefulWidget {
  const CustomerAuthOtpScreen({super.key});

  @override
  State<CustomerAuthOtpScreen> createState() => _CustomerAuthOtpScreenState();
}

class _CustomerAuthOtpScreenState extends State<CustomerAuthOtpScreen> {
  final TextEditingController pinTEController = TextEditingController();

  @override
  void dispose() {
    pinTEController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.globalBlackWhite(context),
      body: SafeArea(
        child: ResPonsiveUi(mobile: body(), desktop: body(), tablet: body()),
      ),
    );
  }

  Widget body() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final String fullName = args?['fullName'] ?? '';
    String phone = args?['phone'] ?? '';
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
                      animationCurve: Curves.linear,
                      animationDuration: Duration(milliseconds: 0),
                      textStyle: AppTextStyles.textSize16(context, weight: FontWeight.w600),
                      enablePinAutofill: false,
                      pinTheme: PinTheme(
                        fieldWidth: 60,
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
                      cursorColor: AppColors.coursorColor(context),
                    ),
                  ),
                ],
              ),
            ),
            SizedboxSpaccing.height025(context),
            Consumer<AuthOtpVerifyViewModel>(
              builder: (context, verify, child) {
                return Container(
                  width: screenWidth * 0.79,
                  child: RoundButton(
                    title: AppLocalizations.of(context)!.next,
                    iconData: Icons.arrow_forward_ios_rounded,
                    loading: verify.authOTPVerifyloading,
                    onPress: () async {
                      if (pinTEController.text.isEmpty || pinTEController.text.length < 4) {
                        Utils.flushBarErrorMessage(AppLocalizations.of(context)!.please_enter_valid_otp, context);
                      } else {
                        Map data = {'otpCode': pinTEController.text.toString()};
                        await verify.authOtpVerify(data, context);

                        // ✅ Clear PIN controller after verification attempt
                        setState(() {
                          pinTEController.clear();
                        });
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
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(AppLocalizations.of(context)!.havent_received_code, style: AppTextStyles.textSize16(context, weight: FontWeight.w500)),
                      Text(
                        "${timerProvider.formattedTime}",
                        style: AppTextStyles.textSize16(context, weight: FontWeight.w500, color: AppColors.button(context)),
                      ),
                    ],
                  ),
                  SizedboxSpaccing.height01(context),
                  GestureDetector(
                    onTap: () {
                      if (timerProvider.canResend) {
                        final customerAuthLoginViewModel = Provider.of<CustomerAuthLoginViewModel>(context, listen: false);

                        Map data = {"fullName": fullName, 'phone': phone, "role": role};

                        customerAuthLoginViewModel.authApiSendOtp(
                          data,
                          context,
                          onSuccess: () async {
                            // ✅ Clear PIN controller when resending OTP
                            pinTEController.clear();
                            Utils.flushBarSuccessMessage(AppLocalizations.of(context)!.otp_sent_success, context);
                          },
                        );
                      }
                    },
                    child: Builder(
                      builder: (context) {
                        final textStyle = GoogleFonts.hindSiliguri(fontSize: 18, color: timerProvider.canResend ? AppColors.button(context) : Colors.grey, fontWeight: FontWeight.w500);

                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [Center(child: Text(AppLocalizations.of(context)!.send_again, style: textStyle))],
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
