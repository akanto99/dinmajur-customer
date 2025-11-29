import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:dinmajur_customer/l10n/app_localizations.dart';
import 'package:dinmajur_customer/provider/DarkAndLightTheme/theme_provider.dart';
import 'package:dinmajur_customer/view/screens/draft/draft_screen.dart';
import 'package:dinmajur_customer/view/screens/home/drawer/offers/offers_screen.dart';
import 'package:dinmajur_customer/view/screens/home/home_screen.dart';
import 'package:dinmajur_customer/view/screens/order/order_screen_new.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
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
    "assets/images/navBar/navbar_new/offers.svg",
    "assets/images/navBar/navbar_new/order.svg",
    "assets/images/navBar/navbar_new/draft.svg",
  ];

  late List<String> labels;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();

    _pages = [
      HomeScreen(scaffoldKey: _key),
      OffersScreen(),
      OrderScreen(),
      DraftScreen(),
    ];

    _currentIndex = widget.initialIndex;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _setSystemUIColors();

    labels = [
      AppLocalizations.of(context)!.home,
      AppLocalizations.of(context)!.offers,
      AppLocalizations.of(context)!.order,
      AppLocalizations.of(context)!.draft,
    ];
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
        child: WillPopScope(
          onWillPop: () async {
            // Handle drawer close if open
            if (_currentIndex == 0 && _key.currentState != null && _key.currentState!.isDrawerOpen) {
              _key.currentState!.closeDrawer();
              return Future.value(false);
            }

            // Show exit confirmation dialog
            final value = await showDialog<bool>(
              context: context,
              builder: (context) {
                return AlertDialog(
                  backgroundColor: AppColors.containerBackground(context),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.02,
                    vertical: screenHeight * 0.02,
                  ),
                  insetPadding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.1,
                    vertical: screenHeight * 0.2,
                  ),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                  content: Text(
                    "Are you sure you want to exit?",
                    style: AppTextStyles.textSize16(context, weight: FontWeight.w600),
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
                              child: Text(
                                'No',
                                style: AppTextStyles.textSize12(context, weight: FontWeight.w600),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: screenWidth * 0.02),
                        GestureDetector(
                          onTap: () => SystemNavigator.pop(),
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
            backgroundColor: AppColors.containerBackground(context),
            body: _pages[_currentIndex],
            bottomNavigationBar: SafeArea(
              child: Container(
                height: 60,
                width: screenWidth * 0.9,
                decoration: BoxDecoration(
                  color: AppColors.globalBlackWhite(context),
                  boxShadow: [
                    Theme.of(context).brightness == Brightness.dark
                        ? BoxShadow(
                      color: Colors.white12.withOpacity(0.02),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    )
                        : BoxShadow(
                      color: Colors.white10,
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
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
                            // If already on home and drawer is open, close it
                            if (index == 0 &&
                                _currentIndex == 0 &&
                                _key.currentState != null &&
                                _key.currentState!.isDrawerOpen) {
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
                                  width: 18,
                                  height: 18,
                                  color: isSelected
                                      ? AppColors.button(context)
                                      : AppColors.subtitle(context),
                                  semanticsLabel: labels[index],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  labels[index],
                                  style: AppTextStyles.textSize12(
                                    context,
                                    weight: isSelected ? FontWeight.w500 : FontWeight.w400,
                                    color: isSelected
                                        ? AppColors.button(context)
                                        : AppColors.subtitle(context),
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
}