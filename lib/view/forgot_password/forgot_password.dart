import 'package:dinmajur_customer/configs/buttons/round_button.dart';
import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/components/header_appbar.dart';
import 'package:dinmajur_customer/configs/res/sizedbox_spaccing.dart';
import 'package:dinmajur_customer/configs/responsive/responsive_ui.dart';
import 'package:dinmajur_customer/configs/utils/routes/routes_name.dart';
import 'package:dinmajur_customer/configs/utils/utils.dart';
import 'package:dinmajur_customer/configs/widgets/customtext_with_formfield.dart';
import 'package:dinmajur_customer/l10n/app_localizations.dart';
import 'package:dinmajur_customer/view_model/forgot_password_models/post_forgot_otpsend_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  TextEditingController _phoneController = TextEditingController();
  final FocusNode _phoneFocus = FocusNode();

  @override
  void initState(){
    super.initState();
    _loadFormData();
  }

  @override
  void dispose() {
    super.dispose();
    _phoneController.dispose();
    _phoneFocus.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.containerBackground(context),
        body: ResPonsiveUi(mobile: body(), desktop: body(), tablet: body()),
      ),
    );
  }

  Widget body() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final forgotPasswordSendOTPMode = Provider.of<PostForgotOtpSendViewModel>(context, listen: false);

    return Column(
      children: [
        GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Container(
            height: 60,
            color: AppColors.containerBackground(context),
            child: Center(child: AppBarHeader( AppLocalizations.of(context)!.forgot_password_title)),
          ),
        ),
        SizedboxSpaccing.height025(context),
        Container(
          width: screenWidth*0.9,
          padding: EdgeInsets.all(screenHeight*0.02),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                  color: AppColors.textFieldFill(context),
                  width:1
              )
          ),
          child: CustomTextFieldWithFormFieldPoppins(
            titleText:AppLocalizations.of(context)!.mobile_number_required,
            placeholder:AppLocalizations.of(context)!.mobile_number_placeholder,
            controller: _phoneController,
            focusCurrent: _phoneFocus,
            keyboardType: TextInputType.number,
          ),
        ),
        SizedboxSpaccing.height025(context),
        Consumer<PostForgotOtpSendViewModel>(
          builder: (context, forgotOtpSendMode, child) {
            return Container(
              width: screenWidth * 0.8,
              child: RoundButton(
                title: AppLocalizations.of(context)!.next,
                iconData: Icons.arrow_forward_ios_rounded,
                loading: forgotOtpSendMode.otpAPiloading,
                onPress: () async {
                  // Validation checks
                  if (_phoneController.text.isEmpty) {
                    Utils.flushBarErrorMessage(AppLocalizations.of(context)!.error_enter_phone, context);
                    return;
                  }

                  if (_phoneController.text.trim().length < 11) {
                    Utils.flushBarErrorMessage(AppLocalizations.of(context)!.error_valid_phone, context);
                    return;
                  }

                  Map<String, dynamic> data = {
                    "phone": _phoneController.text.trim()
                  };

                  await _saveFormData();

                  // Call the API
                  // forgotOtpSendMode.otpSendPostAPI(
                  //   data,
                  //   context,
                  //   onSuccess: () async {
                  //     // Wait a bit for the data to be saved
                  //     await Future.delayed(const Duration(milliseconds: 500));
                  //
                  //     // Now read the saved data
                  //     final prefs = await SharedPreferences.getInstance();
                  //     final userID = prefs.getString('forgot_user_id') ?? '';
                  //     final token = prefs.getString('forgot_token') ?? '';
                  //     final phone = prefs.getString('forgot_phone') ?? '';
                  //     final role = prefs.getString('forgot_role') ?? '';
                  //
                  //     print('📊 Retrieved from SharedPreferences:');
                  //     print('User ID: $userID');
                  //     print('Token: $token');
                  //     print('Phone: $phone');
                  //     print('Role: $role');
                  //
                  //     // Navigate to OTP verification screen
                  //     Navigator.pushNamed(
                  //       context,
                  //       RoutesName.forgot_otpVerify,
                  //       arguments: {
                  //         'userID': userID,
                  //         'phone': phone,
                  //         'token': token,
                  //         'role': role,
                  //       },
                  //     );
                  //
                  //     // Clear form and temporary data
                  //     setState(() {
                  //       _phoneController.clear();
                  //     });
                  //
                  //     // Remove the temporary form data
                  //     await prefs.remove('f_phone');
                  //   },
                  // );
                  forgotOtpSendMode.otpSendPostAPI(
                    data,
                    context,
                    onSuccess: () async {
                      // Wait a bit for the data to be saved
                      await Future.delayed(const Duration(milliseconds: 500));

                      // Now read the saved data
                      final prefs = await SharedPreferences.getInstance();
                      final userID = prefs.getString('forgot_user_id') ?? '';
                      final token = prefs.getString('forgot_token') ?? '';
                      final phone = prefs.getString('forgot_phone') ?? '';
                      final role = prefs.getString('forgot_role') ?? '';

                      print('📊 Retrieved from SharedPreferences:');
                      print('User ID: $userID');
                      print('Token: $token');
                      print('Phone: $phone');
                      print('Role: $role');

                      // ✅ ADD ROLE VALIDATION HERE
                      if (role.toLowerCase() != 'customer') {
                        Utils.flushBarErrorMessage('This phone number is not registered as a customer account', context);

                        // Clear the stored data since it's not a customer
                        await forgotOtpSendMode.clearForgotPasswordData();

                        // Clear the phone field
                        setState(() {
                          _phoneController.clear();
                        });

                        return; // Don't navigate
                      }

                      // Navigate to OTP verification screen ONLY if role is customer
                      Navigator.pushNamed(
                        context,
                        RoutesName.forgot_otpVerify,
                        arguments: {
                          'userID': userID,
                          'phone': phone,
                          'token': token,
                          'role': role,
                        },
                      );

                      // Clear form and temporary data
                      setState(() {
                        _phoneController.clear();
                      });

                      // Remove the temporary form data
                      await prefs.remove('f_phone');
                    },
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }

  Future<void> _loadFormData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _phoneController.text = prefs.getString('f_phone') ?? '';
    });
  }

  Future<void> _saveFormData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('f_phone', _phoneController.text);
  }
}



