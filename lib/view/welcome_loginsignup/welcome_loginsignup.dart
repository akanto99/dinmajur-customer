import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/components/language_changer/language_changer_widgets.dart';
import 'package:dinmajur_customer/configs/res/sizedbox_spaccing.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:dinmajur_customer/configs/responsive/responsive_ui.dart';
import 'package:dinmajur_customer/configs/services/navigator_services/navigator_services_refreshToken.dart';
import 'package:dinmajur_customer/configs/utils/routes/routes_name.dart';
import 'package:dinmajur_customer/l10n/app_localizations.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:upgrader/upgrader.dart';


class WelcomeLoginSignup extends StatefulWidget {
  const WelcomeLoginSignup({super.key});

  @override
  State<WelcomeLoginSignup> createState() => _WelcomeLoginSignupState();
}

class _WelcomeLoginSignupState extends State<WelcomeLoginSignup> {
  @override
  Widget build(BuildContext context) {
    return UpgradeAlert(
      navigatorKey: NavigationService.navigatorKey,

      barrierDismissible: false,
      showLater: false,
      showIgnore: false,
      showReleaseNotes: false,
      upgrader: Upgrader(
        // debugDisplayAlways: true,
        // debugLogging: true,
        // debugDisplayAlways: kDebugMode,
        // debugLogging: kDebugMode,
      ),
      child: Scaffold(
        backgroundColor: AppColors.containerBackground(context),
        body: SafeArea(
          child: ResPonsiveUi(mobile: body(), desktop: body(), tablet: body()),
        ),
      ),
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
            height: screenHeight * 0.48,
            width: screenWidth,
            color: AppColors.border(context),
            child: SvgPicture.asset("assets/images/login/welcome.svg", fit: BoxFit.cover),
          ),
        ),
        Positioned(
          bottom: 0,
          child: Container(
            color: AppColors.border(context),
            child: Center(
              child: Container(
                height: screenHeight * 0.49,
                width: screenWidth,
                decoration: BoxDecoration(
                  // color: AppColors.darkRedColor,
                  color: AppColors.containerBackground(context),
                  borderRadius: BorderRadius.only(topRight: Radius.circular(30), topLeft: Radius.circular(30)),
                ),
                child: Column(
                  children: [
                    SizedBox(height: 55,),
                    // SizedboxSpaccing.height04(context),
                    // SizedboxSpaccing.height015(context),
                    Text(AppLocalizations.of(context)!.welcome, style: AppTextStyles.textSize24(context, weight: FontWeight.w600)),
                    // SizedboxSpaccing.height005(context),
                    Text(AppLocalizations.of(context)!.welcome_subtitle, style: AppTextStyles.textSize18(context, weight: FontWeight.w500)),
                    SizedboxSpaccing.height02(context),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, RoutesName.login);
                      },
                      child: Container(
                        height: 50,
                        width: screenWidth * 0.75,
                        decoration: BoxDecoration(
                          color: AppColors.textFieldFill(context),
                          // borderRadius: BorderRadius.circular(16),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(width: 1, color: AppColors.border(context)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Icon(Icons.arrow_forward_ios_rounded, size:14 ,color: Colors.transparent),
                            Text(AppLocalizations.of(context)!.login,  style: AppTextStyles.textSize16(context, color: AppColors.textPrimary(context), weight: FontWeight.w700),),
                              Icon(Icons.arrow_forward_ios_rounded, color: AppColors.textPrimary(context), size: 14),
                          ],
                        ),
                      ),
                    ),
                    SizedboxSpaccing.height02(context),
                    // SizedBox(height: 16,),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, RoutesName.register);
                      },
                      child: Container(
                        height: 50,
                        width: screenWidth * 0.75,
                        decoration: BoxDecoration(
                            color:AppColors.button(context),
                            // borderRadius: BorderRadius.circular(16)
                            borderRadius: BorderRadius.circular(8)
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Icon(Icons.arrow_forward_ios_rounded, size:14 ,color: Colors.transparent),
                            Text(
                              AppLocalizations.of(context)!.register,
                              style: AppTextStyles.textSize16(context, color: AppColors.whiteColor, weight: FontWeight.w700),
                            ),
                            Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 14),
                          ],
                        ),
                      ),
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
}
