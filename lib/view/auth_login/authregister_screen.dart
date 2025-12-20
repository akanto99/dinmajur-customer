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
import 'package:dinmajur_customer/view_model/auth_view_model_new/customer_authlogin_view_model.dart';
import 'package:dinmajur_customer/view_model/authview_model/login_logout_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class AuthLoginSendOTPScreen extends StatefulWidget {
  const AuthLoginSendOTPScreen({super.key});

  @override
  State<AuthLoginSendOTPScreen> createState() => _AuthLoginSendOTPScreenState();
}

class _AuthLoginSendOTPScreenState extends State<AuthLoginSendOTPScreen> {
  TextEditingController _fullNameController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();

  final FocusNode _fullNameFocus = FocusNode();
  final FocusNode _phoneFocus = FocusNode();


  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _fullNameFocus.dispose();
    _fullNameFocus.dispose();

    _phoneController.dispose();
    _phoneFocus.dispose();

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
             titleText: AppLocalizations.of(context)!.fullName,
             placeholder:  AppLocalizations.of(context)!.fullName_hint,
             controller: _fullNameController,
             focusCurrent: _fullNameFocus,
             keyboardType: TextInputType.name,
           ),
           SizedboxSpaccing.height015(context),
           CustomTextFieldWithFormFieldPoppins(
             titleText: AppLocalizations.of(context)!.phone,
             placeholder:  AppLocalizations.of(context)!.phone_hint,
             controller: _phoneController,
             focusCurrent: _phoneFocus,
             keyboardType: TextInputType.number,
           ),
         ],
       ),
     ),

          SizedboxSpaccing.height025(context),

          Consumer<CustomerAuthLoginViewModel>(
              builder: (context, customerAuthLoginViewModel, child) {
                return Container(
                width: screenWidth*0.9,
                child: RoundButton(
                  title: AppLocalizations.of(context)!.sign_in,
                  iconData: Icons.arrow_forward_ios_rounded,
                  loading: loginMode.loading,
                  onPress: () {
                    Map data = {
                      "fullName":_fullNameController.text.toString(),
                      'phone': _phoneController.text.toString(),
                      "role":"CUSTOMER"
                    };

                    customerAuthLoginViewModel.authApiSendOtp(
                      data,
                      context,
                      onSuccess: () async {
                        await Future.delayed(const Duration(seconds: 1));

                        if (mounted) {
                          Navigator.pushNamed(
                            context,
                            RoutesName.authOtp,
                            arguments: {
                              "fullName":_fullNameController.text.toString(),
                              'phone': _phoneController.text.toString(),
                              "role":"CUSTOMER"
                            },
                          );

                        }
                      },
                    );
                    // loginMode.loginApi(data, context);
                    // // print('api hit');
                  },
                ),
              );
            }
          ),
        ],
      ),
    );
  }
}
