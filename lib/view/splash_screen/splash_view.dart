import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:dinmajur_customer/configs/services/splash_services/splash_services.dart';
import 'package:dinmajur_customer/provider/DarkAndLightTheme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
    SplashService().navigateAfterDelay(context);
  }
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _setSystemUIColors();
  }

  void _setSystemUIColors() {
    // Get theme provider from context
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    bool isDarkMode = themeProvider.isDarkMode;

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        systemNavigationBarColor: isDarkMode ? AppColors.blackColor : AppColors.whiteColor,
        statusBarColor: isDarkMode ? AppColors.blackColor : AppColors.whiteColor,
        statusBarIconBrightness: isDarkMode ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDarkMode ? Brightness.dark : Brightness.light,
        // Add these for better control
        systemNavigationBarIconBrightness: isDarkMode ? Brightness.light : Brightness.dark,
        systemNavigationBarDividerColor: isDarkMode ? AppColors.blackColor : AppColors.whiteColor,
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    final themeProvider = Provider.of<ThemeProvider>(context);
    bool isDarkMode = themeProvider.isDarkMode;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        // Use dynamic colors based on theme instead of hardcoded red
        statusBarColor: isDarkMode ? AppColors.blackColor : AppColors.whiteColor,
        statusBarIconBrightness: isDarkMode ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDarkMode ? Brightness.dark : Brightness.light,
        systemNavigationBarColor: isDarkMode ? AppColors.blackColor : AppColors.whiteColor,
        systemNavigationBarIconBrightness: isDarkMode ? Brightness.light : Brightness.dark,
        systemNavigationBarDividerColor: isDarkMode ? AppColors.blackColor : AppColors.whiteColor,
        systemNavigationBarContrastEnforced: false,
      ),
      child: Scaffold(
        body: SafeArea(
          child: Container(
            height: screenHeight,
            width: screenWidth,
           color: AppColors.containerBackground(context),
            child: Stack(
              children: [
                Center(
                  child: Container(
                    height: screenHeight ,
                    width: screenWidth*0.6,
                   decoration: BoxDecoration(
                     shape: BoxShape.circle,
                     // color: Colors.red
                   ),
                    child: Image.asset('assets/images/splash/dinmajur.png'),
                  ),
                ),
                Positioned(
                 bottom: 50,
                  child:  Container(
                    width: screenWidth,
                    child: Column(
                      children: [
                        Center(
                          child:
                          // LoadingAnimationWidget.fourRotatingDots(
                          // color: AppColors.button(context),
                          // size: 50,
                          Container(
                            height: 15,
                            width: 50,
                            // color: Colors.red,
                            child: LoadingAnimationWidget.progressiveDots(
                              color: AppColors.button(context),
                              size: 50,
                            ),
                          ),
                        ),
                        Text("Loading",style: AppTextStyles.poppins14(context),),
                      ],
                    ),
                  ),)
              ],
            ),
          ),
        ),
      ),
    );
  }
}
