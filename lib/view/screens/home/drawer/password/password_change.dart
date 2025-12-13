import 'package:dinmajur_customer/configs/buttons/round_button.dart';
import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/components/header_appbar.dart';
import 'package:dinmajur_customer/configs/res/sizedbox_spaccing.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:dinmajur_customer/configs/responsive/responsive_ui.dart';
import 'package:dinmajur_customer/configs/utils/utils.dart';
import 'package:dinmajur_customer/configs/validations/change_password_validation/change_password_validation.dart';
import 'package:dinmajur_customer/configs/widgets/reusable_passwordfield.dart';
import 'package:dinmajur_customer/l10n/app_localizations.dart';
import 'package:dinmajur_customer/view_model/homeview_model/post_change_passwordview_model/post_change_passwordview_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PasswordChange extends StatefulWidget {
  const PasswordChange({super.key});

  @override
  State<PasswordChange> createState() => _PasswordChangeState();
}

class _PasswordChangeState extends State<PasswordChange> {
  TextEditingController _oldPassController = TextEditingController();
  ValueNotifier<bool> _oldobsecurePassword = ValueNotifier<bool>(true);

  TextEditingController _passwordController = TextEditingController();
  ValueNotifier<bool> _obsecurePassword = ValueNotifier<bool>(true);

  TextEditingController _reenterPasswordController = TextEditingController();
  ValueNotifier<bool> _reObsecurePassword = ValueNotifier<bool>(true);

  final FocusNode _oldFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _rePasswordFocus = FocusNode();

  // Create an instance of ChangePasswordValidation
  final ChangePasswordValidation _newPasswordValidation = ChangePasswordValidation();
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_onPasswordChanged);
    _reenterPasswordController.addListener(_onPasswordChanged); // Added listener for re-enter password
    _isInitialized = true;
  }
  void _onPasswordChanged() {
    if (_isInitialized && mounted) {
      setState(() {
        // _newPasswordValidation.checkPasswordStrength(_passwordController.text);
      });
    }
  }
  bool get passwordsMatch {
    if (_reenterPasswordController.text.isEmpty) return true;
    return _passwordController.text == _reenterPasswordController.text;
  }
  @override
  void dispose() {
    _oldPassController.dispose();
    _passwordController.dispose();
    _reenterPasswordController.dispose();

    _oldobsecurePassword.dispose();
    _obsecurePassword.dispose();
    _reObsecurePassword.dispose();

    _oldFocus.dispose();
    _passwordFocus.dispose();
    _rePasswordFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.containerBackground(context),
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
    final screenWidth = MediaQuery.of(context).size.width * 1;
    final screenHeight = MediaQuery.of(context).size.height * 1;
    final changePasswordMode = Provider.of<PostChangePasswordViewModel>(context, listen: false);
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Container(
            height: 60,
            color: AppColors.containerBackground(context),
            child: AppBarHeader("Change Password"),
          ),
        ),
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
                    border: Border.all(
                      color: AppColors.border(context),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      CustomPasswordFieldPoppins(
                        titleText: "Old Password *",
                        controller: _oldPassController,
                        focusNode: _oldFocus,
                        obsecurePassword: _oldobsecurePassword,
                      ),
                      SizedboxSpaccing.height025(context),
                      CustomPasswordFieldPoppins(
                        titleText: "New Password *",
                        controller: _passwordController,
                        focusNode: _passwordFocus,
                        obsecurePassword: _obsecurePassword,
                      ),

                      // if (_passwordController.text.isNotEmpty) ...[
                      //   SizedboxSpaccing.height01(context),
                      //   _newPasswordValidation.buildProgressBar(),
                      // ],
                      SizedboxSpaccing.height025(context),
                      CustomPasswordFieldPoppins(
                        titleText: "Re-enter Password *",
                        controller: _reenterPasswordController,
                        focusNode: _rePasswordFocus,
                        obsecurePassword: _reObsecurePassword,
                      ),
                      if (_reenterPasswordController.text.isNotEmpty) ...[
                        SizedboxSpaccing.height005(context),
                        Container(
                          // width: screenWidth*0.9,
                          alignment: Alignment.centerRight,
                          child: Text(
                              passwordsMatch
                                  ? AppLocalizations.of(context)!.password_matched
                                  : AppLocalizations.of(context)!.password_notmatched,
                              style:AppTextStyles.textSize12(context, color: passwordsMatch ? Colors.green : Colors.red, )
                          ),
                        ),
                        // SizedboxSpaccing.height025(context),
                      ],
                      // SizedboxSpaccing.height025(context),
                      // Row(
                      //   children: [
                      //     SizedBox(
                      //       width: 15,
                      //     ),
                      //     _newPasswordValidation.buildRequirementsList(context),
                      //   ],
                      // ),
                    ],
                  ),
                ),
                SizedboxSpaccing.height025(context),
                Consumer<PostChangePasswordViewModel>(
                  builder: (context, changepassMode, child) {
                    return  Container(
                      width: screenWidth * 0.8,
                      child: RoundButton(
                        title: 'Confirm',
                        iconData: Icons.arrow_forward_ios_rounded,
                        loading: changepassMode.createPostChangePasswordLoading,
                        onPress: () {
                          FocusScope.of(context).unfocus();
                          // Use the validation method from ChangePasswordValidation
                          String? validationMessage = _newPasswordValidation.getValidationMessage(
                            _passwordController.text,
                            _reenterPasswordController.text,
                          );

                          // Check old password
                          if (_oldPassController.text.isEmpty || _oldPassController.text.length < 6) {
                            Utils.flushBarErrorMessage(
                              'Please enter your old password & at least 6 characters',
                              context,
                            );
                            return;
                          }

                          // Check validation message
                          if (validationMessage != null) {
                            Utils.flushBarErrorMessage(validationMessage, context);
                            return;
                          }

                          // If all validations pass, proceed with password change
                          Map<String, dynamic> fields = {
                            "oldPassword": _oldPassController.text,
                            "newPassword": _passwordController.text,
                          };
                          changePasswordMode.changePasswordPostApi(context, fields);
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