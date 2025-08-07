import 'package:dinmajur_customer/configs/buttons/round_button.dart';
import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/components/header_appbar.dart';
import 'package:dinmajur_customer/configs/res/sizedbox_spaccing.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:dinmajur_customer/configs/responsive/responsive_ui.dart';
import 'package:dinmajur_customer/configs/utils/routes/routes_name.dart';
import 'package:dinmajur_customer/configs/utils/utils.dart';
import 'package:dinmajur_customer/configs/validations/authentication_validation/authentication_validation.dart';
import 'package:dinmajur_customer/configs/validations/forgotpasword_validation/newpassword_validation.dart';
import 'package:dinmajur_customer/configs/widgets/customtext_with_formfield.dart';
import 'package:dinmajur_customer/configs/widgets/reusable_passwordfield.dart';
import 'package:dinmajur_customer/view_model/authview_model/authview_model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
class AuthenticationScreen extends StatefulWidget {
  const AuthenticationScreen({super.key});

  @override
  State<AuthenticationScreen> createState() => _AuthenticationScreenState();
}

class _AuthenticationScreenState extends State<AuthenticationScreen> {
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  ValueNotifier<bool> _obsecurePassword = ValueNotifier<bool>(true);

  TextEditingController _reenterPasswordController = TextEditingController();
  ValueNotifier<bool> _reObsecurePassword = ValueNotifier<bool>(true);

  final FocusNode _phoneFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _rePasswordFocus = FocusNode();

  // Password validation instance
  late NewPasswordValidation _newPasswordValidation;
  bool _isInitialized = false;

  void _onPasswordChanged() {
    if (_isInitialized && mounted) {
      setState(() {
        _newPasswordValidation.checkPasswordStrength(_passwordController.text);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _newPasswordValidation = NewPasswordValidation();
    _passwordController.addListener(_onPasswordChanged);
    _isInitialized = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadFormData();
    });

  }
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _obsecurePassword.dispose();
    _reObsecurePassword.dispose();

    _phoneFocus.dispose();
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
        GestureDetector(
            onTap: (){
              Navigator.pop(context);
            },
            child: Container(
                height: 60,
                child: AppBarHeader("Registration"))),
        Expanded(
          child: SingleChildScrollView(
           child: Column(
             children: [

               Center(child: SizedboxSpaccing.height025(context)),
               Text("Create an Account" ,style: AppTextStyles.textSize32(context,weight: FontWeight.w600),),
               SizedboxSpaccing.height005(context),
               Text("Daily Work, Daily Earn!", style: AppTextStyles.textSize18(context,weight: FontWeight.w500),),
               // Text("ব্যস্ত জীবন, সহজ সমাধান",style:TextStyle(color: AppColors.blackColor.withOpacity(0.6),fontFamily: )),
               SizedboxSpaccing.height025(context),


               Container(
                 width: screenWidth*0.9,
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
                     CustomTextFieldWithFormFieldPoppins(
                       titleText: "Mobile Number*",
                       placeholder: "01XXXXXXXXX",
                       controller: _phoneController,
                       focusCurrent: _phoneFocus,
                       keyboardType: TextInputType.number,
                     ),
                     SizedboxSpaccing.height015(context),
                     CustomPasswordFieldPoppins(
                       titleText: "Password*",
                       controller: _passwordController,
                       focusNode: _passwordFocus,
                       obsecurePassword: _obsecurePassword,
                     ),
                     if (_passwordController.text.isNotEmpty && _isInitialized) ...[
                       SizedboxSpaccing.height01(context),
                       _buildPasswordValidationSafely(),
                     ],
                     SizedboxSpaccing.height015(context),
                     CustomPasswordFieldPoppins(
                       titleText: "Re-enter password*",
                       controller: _reenterPasswordController,
                       focusNode: _rePasswordFocus,
                       obsecurePassword: _reObsecurePassword,
                     ),
                     SizedboxSpaccing.height015(context),
                     Row(
                       children: [
                         SizedBox(width: 15),
                         Expanded(
                           child: _buildPasswordRequirementsSafely(),
                         ),
                       ],
                     ),
                   ],
                 ),
               ),
               SizedboxSpaccing.height025(context),
               Consumer<AuthenticationViewModel>(
                 builder: (context, authenticationViewMode, child) {
                   return     Container(
                     width: screenWidth*0.9,
                     // padding: EdgeInsets.all(screenHeight * 0.02),
                     child: RoundButton(
                       title: 'Next',
                       iconData: Icons.arrow_forward_ios_rounded,
                       loading: authenticationViewMode.otpAPiloading,
                       onPress: () => _handleSubmit(authenticationViewMode),
                     ),
                   );
                 },
               ),



               SizedboxSpaccing.height025(context),
               GestureDetector(
                 onTap: (){
                   Navigator.pushNamed(context, RoutesName.login);
                 },
                 child: Row(
                   mainAxisAlignment: MainAxisAlignment.center,
                   children: [
                     Text("Already have an account? ",   style: AppTextStyles.textSize16(context,weight: FontWeight.w500)),
                     Text("Login",    style: GoogleFonts.poppins(fontSize: 16,   color: AppColors.button(context), fontWeight: FontWeight.w500, decoration: TextDecoration.underline,
                       decorationColor:  AppColors.button(context),),),
                   ],
                 ),
               ),

             ],
           ),
         ),
       ),

      ],
    );
  }







  // Safe wrapper for password validation widgets
  Widget _buildPasswordValidationSafely() {
    try {
      return _newPasswordValidation.buildProgressBar();
    } catch (e) {
      // Fallback UI in case of error
      return Container(
        height: 20,
        child: Text(
          'Loading validation...',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
      );
    }
  }

  Widget _buildPasswordRequirementsSafely() {
    try {
      return _newPasswordValidation.buildRequirementsList(context);
    } catch (e) {
      // Fallback UI in case of error
      return Container(
        height: 100,
        child: Text(
          'Loading requirements...',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
      );
    }
  }

  Future<void> _handleSubmit(AuthenticationViewModel authenticationViewMode) async {
    try {
      await _saveFormData();
      // First validate using new password validation
      String? validationMessage = _newPasswordValidation.getValidationMessage(
        _phoneController.text,
        _passwordController.text,
        _reenterPasswordController.text,
      );

      if (validationMessage != null) {
        Utils.flushBarErrorMessage(validationMessage, context);
        return;
      }

      // Additional validation using existing validation
      String? error = AutheticationValidation.getFirstError(
        phone: _phoneController.text.trim(),
        password: _passwordController.text.trim(),
        reenterPassword: _reenterPasswordController.text.trim(),
      );

      if (error != null) {
        Utils.flushBarErrorMessage(error, context);
        return;
      }
      Map data = {
        'phone': _phoneController.text.trim(),
        'password': _passwordController.text.trim(),
        'role': 'CUSTOMER'
      };

      print(data);

      // Call API
      authenticationViewMode.otpApi(
        data,
        context,
        onSuccess: () async {
          await _saveFormData();
          await Future.delayed(const Duration(seconds: 1));

          if (mounted) {
            Navigator.pushNamed(
              context,
              RoutesName.otp,
              arguments: {
                'phone': _phoneController.text.trim(),
                'password': _passwordController.text.trim(),
                'role': 'CUSTOMER'
              },
            );

            // Clear form data after successful navigation
            await _clearFormDataAndControllers();
          }
        },
      );
    } catch (e) {
      print('Error in _handleSubmit: $e');
      if (mounted) {
        Utils.flushBarErrorMessage('An error occurred. Please try again.', context);
      }
    }
  }

  Future<void> _loadFormData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (mounted) {
        setState(() {
          _phoneController.text = prefs.getString('otpphone') ?? '';
          _passwordController.text = prefs.getString('otppassword') ?? '';
          _reenterPasswordController.text = prefs.getString('re_enterpassword') ?? '';
        });
      }
    } catch (e) {
      print('Error loading form data: $e');
    }
  }

  Future<void> _saveFormData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('otpphone', _phoneController.text);
      await prefs.setString('otppassword', _passwordController.text);
      await prefs.setString('re_enterpassword', _reenterPasswordController.text);
    } catch (e) {
      print('Error saving form data: $e');
    }
  }

  Future<void> _clearFormDataAndControllers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('otpphone');
      await prefs.remove('otppassword');
      await prefs.remove('re_enterpassword');

      if (mounted) {
        setState(() {
          _phoneController.clear();
          _passwordController.clear();
          _reenterPasswordController.clear();
        });
      }
    } catch (e) {
      print('Error clearing form data: $e');
    }
  }

}
