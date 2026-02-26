import 'package:dinmajur_customer/configs/buttons/round_button.dart';
import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/components/language_changer/language_changer_widgets.dart';
import 'package:dinmajur_customer/configs/res/sizedbox_spaccing.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:dinmajur_customer/configs/responsive/responsive_ui.dart';
import 'package:dinmajur_customer/configs/utils/routes/routes_name.dart';
import 'package:dinmajur_customer/configs/utils/utils.dart';
import 'package:dinmajur_customer/configs/validations/authentication_validation/welcome_login_validation.dart';
import 'package:dinmajur_customer/configs/widgets/customemobile_textfield.dart';
import 'package:dinmajur_customer/l10n/app_localizations.dart';
import 'package:dinmajur_customer/provider/DarkAndLightTheme/theme_provider.dart';
import 'package:dinmajur_customer/view_model/auth_view_model_new/customer_authlogin_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:upgrader/upgrader.dart';


class WelcomeLoginScreen extends StatefulWidget {
  const WelcomeLoginScreen({super.key});

  @override
  State<WelcomeLoginScreen> createState() => _WelcomeLoginSignupState();
}

class _WelcomeLoginSignupState extends State<WelcomeLoginScreen> {
  TextEditingController _phoneController = TextEditingController();

  final FocusNode _phoneFocus = FocusNode();


  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _phoneController.dispose();
    _phoneFocus.dispose();

  }

  // @override
  // Widget build(BuildContext context) {
  //   return UpgradeAlert(
  //     navigatorKey: NavigationService.navigatorKey,
  //
  //     barrierDismissible: false,
  //     showLater: false,
  //     showIgnore: false,
  //     showReleaseNotes: false,
  //     upgrader: Upgrader(
  //
  //    //   debugDisplayAlways: kDebugMode,
  //    //   debugLogging: kDebugMode,
  //       countryCode: 'BD',
  //       languageCode: 'en',
  //     ),
  //     child: Scaffold(
  //       backgroundColor: AppColors.containerBackground(context),
  //       body: SafeArea(
  //         child: ResPonsiveUi(mobile: body(), desktop: body(), tablet: body()),
  //       ),
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Builder(
        builder: (context) {
          // Check if upgrade is needed
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _checkForUpgrade(context);
          });
        return Scaffold(
          backgroundColor: AppColors.containerBackground(context),
          body: SafeArea(
            child: ResPonsiveUi(mobile: body(), desktop: body(), tablet: body()),
          ),
        );
      }
    );
  }

  Widget body() {
    final screenWidth = MediaQuery.of(context).size.width * 1;
    final screenHeight = MediaQuery.of(context).size.height * 1;

    return Stack(
      children: [
        Container(
          height: screenHeight,
          alignment: Alignment.topCenter,
          child: Container(
            height: screenHeight * 0.5,
            padding: EdgeInsets.symmetric(horizontal: screenWidth*0.01),
            width: screenWidth,
            color: AppColors.border(context),
            // child: SvgPicture.asset("assets/images/login/welcome.svg", fit: BoxFit.cover),
            child: SvgPicture.asset("assets/images/login/welcome.svg", fit: BoxFit.cover),
          ),
        ),
        Positioned(
          bottom: 0,
          child: Container(
            color: AppColors.border(context),
            child: Center(
              child: Container(
                height: screenHeight * 0.5,
                width: screenWidth,
                decoration: BoxDecoration(
                  // color: AppColors.darkRedColor,
                  color: AppColors.containerBackground(context),
                  borderRadius: BorderRadius.only(topRight: Radius.circular(30), topLeft: Radius.circular(30)),
                ),
                child: Column(
                  children: [
                    SizedboxSpaccing.height04(context),
                    Text(AppLocalizations.of(context)!.welcome, style: AppTextStyles.textSize24(context, weight: FontWeight.w600)),
                    Text(AppLocalizations.of(context)!.welcome_subtitle, style: AppTextStyles.textSize18(context, weight: FontWeight.w500)),
                    SizedboxSpaccing.height04(context),
                    // CustometextFormfield(
                    //   placeholder:  AppLocalizations.of(context)!.fullName_hint,
                    //   controller: _fullNameController,
                    //   focusCurrent: _fullNameFocus,
                    //   keyboardType: TextInputType.name,
                    // ),
                    // SizedboxSpaccing.height02(context),
                    CustomeMobileTextfield(
                      placeholder:  AppLocalizations.of(context)!.phone_hint_new,
                      controller: _phoneController,
                      focusCurrent: _phoneFocus,
                      keyboardType: TextInputType.number,
                    ),
                    SizedboxSpaccing.height025(context),

                    Consumer<CustomerAuthLoginViewModel>(
                        builder: (context, customerAuthLoginViewModel, child) {
                          return Container(
                            width: screenWidth*0.75,
                            child: RoundButton(
                              title: AppLocalizations.of(context)!.login_with_otp,
                              iconData: Icons.arrow_forward_ios_rounded,
                              loading: customerAuthLoginViewModel.authApiSendOtploading,
                              onPress: () {
                                String? firstError = WelcomeLoginValidation.getFirstLoginError(
                                  // fullName: _fullNameController.text,
                                  phone: _phoneController.text,
                                );

                                if (firstError != null) {
                                  Utils.flushBarErrorMessage(firstError, context);
                                  return;
                                }
                                Map data = {
                                  // "fullName":_fullNameController.text.toString(),
                                  // 'phone': "0${_phoneController.text.toString()}",
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
                                          // "fullName":_fullNameController.text.toString(),
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
              ),
            ),
          ),
        ),
        Positioned(
          top: 5,
          right: 5,
          child:   Container(
          child: LanguageSlideSwitcher(
            backgroundColor: AppColors.textPrimary(context),
            activeColor: Colors.white,
            inactiveColor: AppColors.textPrimary(context),
            borderRadius: BorderRadius.circular(25),
            animationDuration: Duration(milliseconds: 250),
          ),
        ),)
      ],
    );
  }




  // Add this method to your _NavigationScreenState class
  void _checkForUpgrade(BuildContext context) async {
    final upgrader = Upgrader(
        // debugDisplayAlways: kDebugMode, debugLogging: kDebugMode,
        countryCode: 'BD', languageCode: 'en');

    await upgrader.initialize();

    if (upgrader.shouldDisplayUpgrade()) {
      _showCustomUpgradeDialog(context, upgrader);
    }
  }

  void _showCustomUpgradeDialog(BuildContext context, Upgrader upgrader) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDarkMode = themeProvider.isDarkMode;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: AppColors.showDialougeBackground(context),
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: AppColors.containerBackground(context),
          insetPadding: EdgeInsets.all(screenHeight * 0.02),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding:EdgeInsets.all(screenHeight * 0.02),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 20),
                Icon(FontAwesomeIcons.cloudArrowDown, color: AppColors.button(context), size: 50),
                SizedBox(height: 10),
                Text('Update Available', style: AppTextStyles.textSize18(context, weight: FontWeight.w600)),
                SizedBox(height: 20),

                Text('A new version is available!', textAlign: TextAlign.center, style: AppTextStyles.textSize14(context)),
                SizedBox(height: 5),
                Text(
                  'Version ${upgrader.currentAppStoreVersion ?? 'Unknown'} is now available. You are using version ${upgrader.currentInstalledVersion ?? 'Unknown'}.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.textSize12(context, color: AppColors.subtitle(context)),
                ),

                SizedBox(height: 20),
                GestureDetector(
                  onTap: () async {
                    Navigator.of(context).pop();
                    await upgrader.sendUserToAppStore();
                  },
                  child: Container(
                    width: screenWidth*0.5,
                    height: 45,
                    decoration: BoxDecoration(color: AppColors.button(context), borderRadius: BorderRadius.circular(100)),
                    child: Center(
                      child: Text(
                        'Update Now',
                        style: AppTextStyles.textSize14(context, color: AppColors.whiteColor, weight: FontWeight.w600),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }
}
