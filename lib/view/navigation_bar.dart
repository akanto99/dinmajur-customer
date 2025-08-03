import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:dinmajur_customer/provider/DarkAndLightTheme/theme_provider.dart';
import 'package:dinmajur_customer/view/screens/home/home_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:provider/provider.dart';
import 'package:upgrader/upgrader.dart';

class NavigationScreen extends StatefulWidget {
  final int initialIndex;

  const NavigationScreen({super.key, this.initialIndex = 0});

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  int _currentIndex = 0;
  final GlobalKey<ScaffoldState> _key = GlobalKey<ScaffoldState>();
  final List<String> icons = [
    "assets/images/navBar/navbar_new/home.svg",
    "assets/images/navBar/navbar_new/scan.svg",
    "assets/images/navBar/navbar_new/task.svg",
    "assets/images/navBar/navbar_new/stores.svg",
    "assets/images/navBar/navbar_new/income.svg",
  ];

  // final List<String> labels = ["Home", "Task", "Scan", "Shop", "Job"];
  final List<String> labels = ["Home", "Scan", "Task", "Stores", "Income"];
    late final List<Widget> _pages;
  @override
  void initState() {
    super.initState();
    _pages = [
      HomeScreen(scaffoldKey: _key),
      Text("1"),
      Text("2"),
      Text("3"),
      Text("4"),
    ];
    getConnectivity();
    _currentIndex = widget.initialIndex;
  }
  late StreamSubscription subscription;
  bool isDeviceConnected = false;
  bool isAlertSet = false;

  getConnectivity() =>
      subscription = Connectivity().onConnectivityChanged.listen(
            (ConnectivityResult result) async {
          isDeviceConnected = await InternetConnectionChecker().hasConnection;
          if (!isDeviceConnected && !isAlertSet) {
            showDialogBox();
            setState(() => isAlertSet = true);
          } else if (isDeviceConnected && isAlertSet) {
            Navigator.of(context, rootNavigator: true)
                .pop(); // Close the dialog
            setState(() => isAlertSet = false);
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => NavigationScreen(initialIndex: 0)));
          }
        },
      );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _setSystemUIColors();
  }

  void _setSystemUIColors() {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    bool isDarkMode = themeProvider.isDarkMode;

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        systemNavigationBarColor: isDarkMode ? AppColors.blackColor : AppColors.whiteColor,
        statusBarColor: isDarkMode ? AppColors.blackColor : AppColors.whiteColor,
        statusBarIconBrightness: isDarkMode ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDarkMode ? Brightness.dark : Brightness.light,
        systemNavigationBarIconBrightness: isDarkMode ? Brightness.light : Brightness.dark,
        systemNavigationBarDividerColor: isDarkMode ? AppColors.blackColor : AppColors.whiteColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: isDarkMode ? AppColors.blackColor : AppColors.whiteColor,
        statusBarIconBrightness: isDarkMode ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDarkMode ? Brightness.dark : Brightness.light,
        systemNavigationBarColor: isDarkMode ? AppColors.blackColor : AppColors.whiteColor,
        systemNavigationBarIconBrightness: isDarkMode ? Brightness.light : Brightness.dark,
        systemNavigationBarDividerColor: isDarkMode ? AppColors.blackColor : AppColors.whiteColor,
        systemNavigationBarContrastEnforced: false,
      ),
      child: UpgradeAlert(
        barrierDismissible: false,
        showLater: false,
        showIgnore: false,
        showReleaseNotes: false,
        upgrader: Upgrader(),
        child: SafeArea(
          child: WillPopScope(
            onWillPop: () async {
              if (_currentIndex == 0 && _key.currentState != null && _key.currentState!.isDrawerOpen) {
                _key.currentState!.closeDrawer();
                return Future.value(false);
              }
              final value = await showDialog<bool>(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    backgroundColor: AppColors.containerBackground(context),
                    contentPadding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02, vertical: screenHeight * 0.02),
                    insetPadding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1, vertical: screenHeight * 0.2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                    content: Text(
                      "Are you sure you want to exit?",
                      style: AppTextStyles.poppins16(context, weight: FontWeight.w600),
                    ),
                    actions: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.of(context).pop(false),
                            child: Container(
                              width: screenWidth * 0.2,
                              padding: EdgeInsets.symmetric(vertical: screenHeight * 0.008),
                              decoration: BoxDecoration(
                                color: AppColors.textFieldFill(context),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Center(
                                child: Text('No', style: AppTextStyles.poppins12(context, weight: FontWeight.w600)),
                              ),
                            ),
                          ),
                          SizedBox(width: screenWidth * 0.02),
                          GestureDetector(
                            onTap: () => SystemNavigator.pop(), // Use SystemNavigator.pop() instead of exit(0)
                            child: Container(
                              width: screenWidth * 0.2,
                              padding: EdgeInsets.symmetric(vertical: screenHeight * 0.008),
                              decoration: BoxDecoration(
                                color: AppColors.button(context),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Center(
                                child: Text(
                                  'Yes',
                                  style: GoogleFonts.hindSiliguri(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.whiteColor,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              );
              return value ?? false;
            },
            child: Scaffold(
              body: _pages[_currentIndex],
              bottomNavigationBar: Container(
                height: 60,
                width: screenWidth * 0.9,
                decoration: BoxDecoration(
                  color: AppColors.globalBlackWhite(context),
                  boxShadow: [
                    Theme.of(context).brightness == Brightness.dark
                        ? BoxShadow(color: Colors.white12.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, -2))
                        : BoxShadow(color: Colors.white10, blurRadius: 10, offset: const Offset(0, -2)),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Divider(color: AppColors.border(context), height: 1),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: List.generate(icons.length, (index) {
                        bool isSelected = _currentIndex == index;
                        return GestureDetector(
                          onTap: () {
                            if (index == 0 && _currentIndex == 0 && _key.currentState != null && _key.currentState!.isDrawerOpen) {
                              _key.currentState!.closeDrawer();
                            } else {
                              setState(() {
                                _currentIndex = index;
                              });
                            }
                          },
                          child: Container(
                            width: screenWidth * 0.2,
                            color: Colors.transparent,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SvgPicture.asset(
                                  icons[index],
                                  width: 20,
                                  height: 20,
                                  color: isSelected ? AppColors.button(context) : AppColors.subtitle(context),
                                  semanticsLabel: labels[index], // Accessibility
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  labels[index],
                                  style: AppTextStyles.poppins12(
                                    context,
                                    weight: isSelected ? FontWeight.w500 : FontWeight.w400,
                                    color: isSelected ? AppColors.button(context) : AppColors.subtitle(context),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ),
                    Container(height: 1),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }




  showDialogBox() => showCupertinoDialog<String>(
    context: context,
    builder: (BuildContext context) => CupertinoAlertDialog(
      title: Column(
        children: [
          Icon(
            CupertinoIcons
                .wifi_exclamationmark,
            size: 40,
            color: CupertinoColors
                .systemRed,
          ),
          SizedBox(height: 10),
          Text(
            'Connection Lost',
            style:GoogleFonts.hindSiliguri(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary(context),
            )
          ),
        ],
      ),
      content: Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: Text(
          'You seem to be offline. Check your connection to stay updated.',
          textAlign: TextAlign.center,
          style: GoogleFonts.hindSiliguri(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: AppColors.textPrimary(context),
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () async {
            Navigator.pop(context, 'Cancel');
            setState(() => isAlertSet = false);
            isDeviceConnected =
            await InternetConnectionChecker().hasConnection;
            if (isDeviceConnected) {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => NavigationScreen(initialIndex: 0)));
            } else if (!isDeviceConnected && !isAlertSet) {
              showDialogBox();
              setState(() => isAlertSet = true);
            }
          },
          child: Text(
            'Retry',
            style: TextStyle(
              color: CupertinoColors.activeBlue, // A familiar blue color
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    ),
  );
}
