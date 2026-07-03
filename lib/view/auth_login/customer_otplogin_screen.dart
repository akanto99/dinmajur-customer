import 'package:dinmajur_customer/configs/buttons/round_button.dart';
import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/components/header_appbar.dart';
import 'package:dinmajur_customer/configs/res/sizedbox_spaccing.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:dinmajur_customer/configs/services/sms_retriver_autofill/sms_retriver_autofill_service.dart';
import 'package:dinmajur_customer/configs/utils/utils.dart';
import 'package:dinmajur_customer/l10n/app_localizations.dart';
import 'package:dinmajur_customer/provider/countdown/countdown/countdown.dart';
import 'package:dinmajur_customer/view_model/auth_view_model_new/customer_otp_view_model.dart';
import 'package:dinmajur_customer/view_model/auth_view_model_new/resend_otp_view_model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';
import 'package:smart_auth/smart_auth.dart';

class CustomerAuthOtpScreen extends StatefulWidget {
  const CustomerAuthOtpScreen({super.key});

  @override
  State<CustomerAuthOtpScreen> createState() => _CustomerAuthOtpScreenState();
}

class _CustomerAuthOtpScreenState extends State<CustomerAuthOtpScreen> {
  final TextEditingController pinController = TextEditingController();
  final FocusNode focusNode = FocusNode();
  late SmsRetriever smsRetriever;

  // ✅ Extract args once in initState — not on every rebuild
  String _phone = '';
  String _role = 'CUSTOMER';

  @override
  void initState() {
    super.initState();
    _initializeSmsRetriever();

    // ✅ Read args once after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (mounted) {
        setState(() {
          _phone = args?['phone'] ?? '';
          _role = 'CUSTOMER';
        });
      }
    });
  }

  void _initializeSmsRetriever() {
    smsRetriever = SmsRetrieverImpl(
      SmartAuth.instance,
      onSmsReceived: (code) {
        if (mounted && code != null) {
          setState(() {
            pinController.text = code;
          });
        }
      },
    );
  }

  Future<void> _restartSmsListener() async {
    try {
      await smsRetriever.dispose();
      _initializeSmsRetriever();
    } catch (e) {
    }
  }

  @override
  void dispose() {
    pinController.dispose();
    focusNode.dispose();
    smsRetriever.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.globalBlackWhite(context),
      // ✅ true so keyboard pushes content up naturally
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: _buildBody(context),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final defaultPinTheme = PinTheme(
      width: 60,
      height: 55,
      textStyle: AppTextStyles.textSize16(context, weight: FontWeight.w600),
      decoration: BoxDecoration(
        color: AppColors.textFieldFill(context),
        borderRadius: BorderRadius.circular(5),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyDecorationWith(
      color: AppColors.textFieldFill(context),
      borderRadius: BorderRadius.circular(5),
    );

    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration?.copyWith(
        color: AppColors.textFieldFill(context),
      ),
    );

    return Consumer<CountdownTimerProvider>(
      builder: (context, timerProvider, _) {
        return SingleChildScrollView(
          // ✅ whole screen scrolls when keyboard opens — no lag
          physics: ClampingScrollPhysics(),
          child: Column(
            children: [
              // App Bar
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: SizedBox(
                  height: 60,
                  child: AppBarHeader(AppLocalizations.of(context)!.otp_verification_title),
                ),
              ),

              SizedboxSpaccing.height025(context),

              // OTP Card
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
                    Text(
                      AppLocalizations.of(context)!.verify_your_number,
                      style: AppTextStyles.textSize18(context, weight: FontWeight.w600),
                    ),
                    Text(
                      AppLocalizations.of(context)!.sent_code_to_number,
                      style: AppTextStyles.textSize14(context, weight: FontWeight.w500),
                    ),
                    SizedboxSpaccing.height01(context),
                    Text(
                      "+88$_phone",
                      style: AppTextStyles.textSize18(context, weight: FontWeight.w500),
                    ),
                    SizedboxSpaccing.height025(context),

                    // Pinput
                    SizedBox(
                      width: 320,
                      height: 55,
                      child: Pinput(
                        controller: pinController,
                        focusNode: focusNode,
                        length: 4,
                        smsRetriever: smsRetriever,
                        defaultPinTheme: defaultPinTheme,
                        focusedPinTheme: focusedPinTheme,
                        submittedPinTheme: submittedPinTheme,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        hapticFeedbackType: HapticFeedbackType.lightImpact,
                        cursor: Container(height: 22, width: 1.5, color: AppColors.coursorColor(context)),
                        onCompleted: (pin) {},
                        onChanged: (value) {},
                      ),
                    ),
                  ],
                ),
              ),

              SizedboxSpaccing.height025(context),

              // Verify Button
              // ✅ Consumer only wraps button — minimal rebuild scope
              Consumer<AuthOtpVerifyViewModel>(
                builder: (context, verify, child) {
                  return SizedBox(
                    width: screenWidth * 0.79,
                    child: RoundButton(
                      title: AppLocalizations.of(context)!.next,
                      iconData: Icons.arrow_forward_ios_rounded,
                      loading: verify.authOTPVerifyloading,
                      onPress: () async {
                        if (pinController.text.isEmpty || pinController.text.length < 4) {
                          Utils.flushBarErrorMessage(
                            AppLocalizations.of(context)!.please_enter_valid_otp,
                            context,
                          );
                        } else {
                          final Map data = {'otpCode': pinController.text.toString()};
                          await verify.authOtpVerify(data, context);
                          if (mounted) {
                            setState(() => pinController.clear());
                          }
                        }
                      },
                    ),
                  );
                },
              ),

              SizedboxSpaccing.height025(context),

              // Timer + Resend
              SizedBox(
                width: screenWidth * 0.85,
                child: Column(
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.havent_received_code,
                          style: AppTextStyles.textSize16(context, weight: FontWeight.w500),
                        ),
                        Text(
                          timerProvider.formattedTime,
                          style: AppTextStyles.textSize16(
                            context,
                            weight: FontWeight.w500,
                            color: AppColors.button(context),
                          ),
                        ),
                      ],
                    ),

                    SizedboxSpaccing.height01(context),

                    // ✅ Consumer only wraps resend button
                    Consumer<ResendOtpViewModel>(
                      builder: (context, resendOtpViewModel, child) {
                        final canResend = timerProvider.canResend && !resendOtpViewModel.resendOTPloading;
                        final textStyle = AppTextStyles.textSize18(context, weight: FontWeight.w500, color: canResend ? AppColors.button(context) : Colors.grey);

                        return GestureDetector(
                          onTap: () async {
                            if (canResend) {
                              final Map data = {'phone': _phone, "role": _role};
                              resendOtpViewModel.reSendOtp(
                                data,
                                context,
                                onSuccess: () async {
                                  pinController.clear();
                                  await _restartSmsListener();
                                  if (mounted) {
                                    Utils.flushBarSuccessMessage(
                                      AppLocalizations.of(context)!.otp_sent_success,
                                      context,
                                    );
                                  }
                                },
                              );
                            }
                          },
                          child: Center(
                            child: resendOtpViewModel.resendOTPloading
                                ? Text("Sending...", style: textStyle)
                                : Text(AppLocalizations.of(context)!.send_again, style: textStyle),
                          ),
                        );
                      },
                    ),

                    SizedboxSpaccing.height04(context),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}