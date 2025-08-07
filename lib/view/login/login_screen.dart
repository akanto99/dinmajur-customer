import 'package:dinmajur_customer/configs/buttons/round_button.dart';
import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/components/header_appbar.dart';
import 'package:dinmajur_customer/configs/res/sizedbox_spaccing.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:dinmajur_customer/configs/responsive/responsive_ui.dart';
import 'package:dinmajur_customer/configs/utils/routes/routes_name.dart';
import 'package:dinmajur_customer/configs/utils/utils.dart';
import 'package:dinmajur_customer/configs/widgets/customtext_with_formfield.dart';
import 'package:dinmajur_customer/configs/widgets/reusable_passwordfield.dart';
import 'package:dinmajur_customer/l10n/app_localizations.dart';
import 'package:dinmajur_customer/view_model/authview_model/login_logout_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  ValueNotifier<bool> _obsecurePassword = ValueNotifier<bool>(true);

  final FocusNode _phoneFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _obsecurePassword.dispose();


    _phoneFocus.dispose();
    _passwordFocus.dispose();
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
    final loginMode = Provider.of<LoginLogoutViewModel>(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return SingleChildScrollView(
      child: Column(
        children: [
          GestureDetector(
              onTap: (){
                Navigator.pop(context);
              },
              child: Container(
                  height: 60,
                  child: AppBarHeader(AppLocalizations.of(context)!.log_in))),
          Center(child: SizedboxSpaccing.height025(context)),
          Text(AppLocalizations.of(context)!.log_in ,style: AppTextStyles.textSize32(context,weight: FontWeight.w600),),
          SizedboxSpaccing.height005(context),
          Text(AppLocalizations.of(context)!.log_in_subtitle, style: AppTextStyles.textSize18(context,weight: FontWeight.w500),),
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
             titleText: AppLocalizations.of(context)!.phone,
             placeholder:  AppLocalizations.of(context)!.phone_hint,
             controller: _phoneController,
             focusCurrent: _phoneFocus,
             keyboardType: TextInputType.number,
           ),
           SizedboxSpaccing.height015(context),
           CustomPasswordFieldPoppins(
             titleText: AppLocalizations.of(context)!.password,
             controller: _passwordController,
             focusNode: _passwordFocus,
             obsecurePassword: _obsecurePassword,
           ),
           SizedboxSpaccing.height01(context),
           Container(
             width: screenWidth * 0.85,
             child: GestureDetector(
               onTap: (){
                 Navigator.pushNamed(context, RoutesName.forgotPassword);
               },
               child: Align(
                 alignment: Alignment.centerRight,
                 child: Text(
                   AppLocalizations.of(context)!.forgot_password,
                   style: GoogleFonts.poppins(
                     fontSize: 16,
                     color: AppColors.textPrimary(context),
                     fontWeight: FontWeight.w400,
                     decoration: TextDecoration.underline,
                     decorationColor: AppColors.textPrimary(context),
                   ),
                 ),
               ),
             ),
           ),

         ],
       ),
     ),

          SizedboxSpaccing.height025(context),

          Container(
            width: screenWidth*0.9,
            child: RoundButton(
              title: AppLocalizations.of(context)!.sign_in,
              iconData: Icons.arrow_forward_ios_rounded,
              loading: loginMode.loading,
              onPress: () {
                if (_phoneController.text.isEmpty) {
                  Utils.flushBarErrorMessage('Please enter phone number', context);
                } else if (_passwordController.text.isEmpty) {
                  Utils.flushBarErrorMessage(
                      'Please enter your password', context);
                } else if (_passwordController.text.length < 6) {
                  Utils.flushBarErrorMessage(
                      'Please enter correct password', context);
                } else {
                  Map data = {
                    'phone': _phoneController.text.toString(),
                    'password': _passwordController.text.toString(),
                  };

                  loginMode.loginApi(data, context);
                  print('api hit');
                }
                // Navigator.pushNamed(context, RoutesName.navigationBar);
              },
            ),
          ),
          SizedboxSpaccing.height025(context),
          GestureDetector(
            onTap: (){
              Navigator.pushNamed(context, RoutesName.register);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(AppLocalizations.of(context)!.new_user,   style: AppTextStyles.textSize16(context,weight: FontWeight.w500)),
                Text(" ${AppLocalizations.of(context)!.register}",   style: AppTextStyles.textSize16(context,weight: FontWeight.w500,color: AppColors.button(context))),
                // Text("Register",    style: GoogleFonts.hindSiliguri(fontSize: 12,   color: AppColors.textPrimary(context), fontWeight: FontWeight.w400, decoration: TextDecoration
                //     .underline, decorationColor:  AppColors.textPrimary(context),),),
              ],
            ),
          ),

        ],
      ),
    );
  }
}
