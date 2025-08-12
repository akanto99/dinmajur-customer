import 'package:dinmajur_customer/configs/buttons/round_button.dart';
import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/components/header_appbar.dart';
import 'package:dinmajur_customer/configs/res/sizedbox_spaccing.dart';
import 'package:dinmajur_customer/configs/responsive/responsive_ui.dart';
import 'package:dinmajur_customer/configs/utils/utils.dart';
import 'package:dinmajur_customer/configs/validations/forgotpasword_validation/newpassword_validation.dart';
import 'package:dinmajur_customer/configs/widgets/reusable_passwordfield.dart';
import 'package:dinmajur_customer/l10n/app_localizations.dart';
import 'package:dinmajur_customer/view_model/forgot_password_models/helper_forgotpassword/helper_forpassword.dart';
import 'package:dinmajur_customer/view_model/forgot_password_models/post_forgotresetpassword_view_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NewPassword extends StatefulWidget {
  const NewPassword({super.key});

  @override
  State<NewPassword> createState() => _NewPasswordState();
}

class _NewPasswordState extends State<NewPassword> {
  TextEditingController _passwordController = TextEditingController();
  ValueNotifier<bool> _obsecurePassword = ValueNotifier<bool>(true);

  TextEditingController _reenterPasswordController = TextEditingController();
  ValueNotifier<bool> _reObsecurePassword = ValueNotifier<bool>(true);

  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _rePasswordFocus = FocusNode();

  // Password validation instance
  late NewPasswordValidation _newPasswordValidation;

  @override
  void initState() {
    super.initState();
    _newPasswordValidation = NewPasswordValidation();
    _passwordController.addListener(_onPasswordChanged);
  }

  void _onPasswordChanged() {
    setState(() {
      _newPasswordValidation.checkPasswordStrength(_passwordController.text);
    });
  }

  @override
  void dispose() {
    super.dispose();
    _passwordController.dispose();
    _reenterPasswordController.dispose();
    _obsecurePassword.dispose();
    _reObsecurePassword.dispose();
    _passwordFocus.dispose();
    _rePasswordFocus.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.globalBlackWhite(context),
      body: SafeArea(
        child: ResPonsiveUi(
          mobile: body(),
          desktop: body(),
          tablet: body(),
        ),
      ),
    );
  }

  Widget body() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Column(
      children: [
        // Fixed header
        GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Container(
            height: 60,
            width: double.infinity,
            color: AppColors.containerBackground(context),
            child: AppBarHeader(AppLocalizations.of(context)!.new_password_title),
          ),
        ),
        // Scrollable content
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedboxSpaccing.height025(context),
                Container(
                  width: screenWidth * 0.9,
                  padding: EdgeInsets.all(screenHeight * 0.02),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColors.border(context), width: 1)
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomPasswordFieldPoppins(
                        titleText: AppLocalizations.of(context)!.password_required,
                        controller: _passwordController,
                        focusNode: _passwordFocus,
                        obsecurePassword: _obsecurePassword,
                      ),
                      // Password strength indicator
                      if (_passwordController.text.isNotEmpty) ...[
                        SizedboxSpaccing.height025(context),
                        _newPasswordValidation.buildProgressBar(),
                      ],
                      SizedboxSpaccing.height025(context),
                      CustomPasswordFieldPoppins(
                        titleText:AppLocalizations.of(context)!.reenter_password,
                        controller: _reenterPasswordController,
                        focusNode: _rePasswordFocus,
                        obsecurePassword: _reObsecurePassword,
                      ),
                      // Password requirements
                      SizedboxSpaccing.height025(context),
                      Padding(
                        padding: const EdgeInsets.only(left: 15.0),
                        child: _newPasswordValidation.buildRequirementsList(context),
                      ),
                    ],
                  ),
                ),
                SizedboxSpaccing.height025(context),
                Consumer<PostNewForgotPasswordViewModel>(
                  builder: (context, forgotNewPasswordMode, child) {
                    return Container(
                      width: screenWidth * 0.8,
                      child: RoundButton(
                        title: AppLocalizations.of(context)!.confirm,
                        iconData: Icons.arrow_forward_ios_rounded,
                        loading: forgotNewPasswordMode.newPasswordLoading,
                        onPress: () async {
                          String? validationMessage = _newPasswordValidation
                              .getValidationMessageWithoutPhone(
                            _passwordController.text,
                            _reenterPasswordController.text,
                            context
                          );

                          if (validationMessage != null) {
                            Utils.flushBarErrorMessage(validationMessage, context);
                          } else {
                            String? phone = await ForgotPasswordHelper.getForgotPhone();
                            Map<String, dynamic> fields = {
                              "phone": "88$phone",
                              "password": _passwordController.text,
                            };
                            forgotNewPasswordMode.newPasswordPostApi(context, fields);
                            print("88$phone");
                          }
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),

      ],
    );
  }
}