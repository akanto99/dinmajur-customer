import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:dinmajur_customer/configs/services/socket/socket_provider.dart';
import 'package:dinmajur_customer/l10n/app_localizations.dart';
import 'package:dinmajur_customer/provider/DarkAndLightTheme/theme_provider.dart';
import 'package:dinmajur_customer/view/screens/home/home_screen.dart';
import 'package:dinmajur_customer/view/screens/task_screen.dart';
import 'package:dinmajur_customer/view/screens/testscreen2.dart';
import 'package:dinmajur_customer/view/screens/testscreen3.dart';
import 'package:dinmajur_customer/view/screens/testscreen4.dart';
import 'package:dinmajur_customer/view_model/userview_model/userview_model.dart';
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
    "assets/images/navBar/navbar_new/task.svg",
    "assets/images/navBar/navbar_new/scan.svg",
    "assets/images/navBar/navbar_new/stores.svg",
    "assets/images/navBar/navbar_new/income.svg",
  ];

  late List<String> labels;
  late final List<Widget> _pages;
  bool _socketInitialized = false;



  @override
  void initState() {
    super.initState();
    _pages = [
      HomeScreen(scaffoldKey: _key),
      // SocketStatusWidget(),
      TaskScreen(),
      TestScreen2(),
      TestScreen3(),
      TestScreen4(),
    ];
    ///Network Connectivity initialize
    initConnectivity();
    getConnectivity();
    _currentIndex = widget.initialIndex;

    /// Initialize socket connection after widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeSocketConnection();
    });
  }

  // ✅ IMPROVED: Initialize socket connection with proper checks
  Future<void> _initializeSocketConnection() async {

    if (_socketInitialized) {
      print("🔌 NavigationScreen: Socket already initialized, skipping");
      return;
    }

    try {
      final userViewModel = Provider.of<UserViewModel>(context, listen: false);
      final socketProvider = Provider.of<SocketProvider>(context, listen: false);

      // Load user data from preferences first
      await userViewModel.loadUserFromPrefs();

      // Check if user is authenticated and get user data
      if (userViewModel.isAuthenticated && userViewModel.currentUser != null) {
        final userId = userViewModel.currentUser?.data?.user?.userId ?? '';
        final userRole = userViewModel.currentUser?.data?.user?.role ?? '';

        print("🔌 NavigationScreen: Initializing socket for user: $userId, role: $userRole");

        if (userId.isNotEmpty && userRole.isNotEmpty) {
          // ✅ Check if socket is not already connected AND not connecting
          if (!socketProvider.isConnected) {
            print("🔌 NavigationScreen: Socket not connected, connecting now...");
            await socketProvider.connectWithUser(
              userId: userId,
              role: userRole,
            );
            print("🔌 NavigationScreen: Socket connected successfully");
            _socketInitialized = true; // ✅ Mark as initialized
          } else {
            print("🔌 NavigationScreen: Socket already connected");
            _socketInitialized = true; // ✅ Mark as initialized
          }
        } else {
          print("🔌 NavigationScreen: Missing user credentials for socket connection");
        }
      } else {
        print("🔌 NavigationScreen: User not authenticated, skipping socket connection");
      }
    } catch (e) {
      print("🔌 NavigationScreen: Socket initialization failed - $e");
      _socketInitialized = false; // ✅ Reset flag on failure
    }
  }

  // ✅ IMPROVED: Reconnect socket when internet connectivity is restored
  Future<void> _reconnectSocketAfterConnectivity() async {
    try {
      final userViewModel = Provider.of<UserViewModel>(context, listen: false);
      final socketProvider = Provider.of<SocketProvider>(context, listen: false);

      if (userViewModel.isAuthenticated && userViewModel.currentUser != null) {
        final userId = userViewModel.currentUser?.data?.user?.userId ?? '';
        final userRole = userViewModel.currentUser?.data?.user?.role ?? '';

        if (userId.isNotEmpty && userRole.isNotEmpty) {
          // ✅ Only reconnect if not already connected
          if (!socketProvider.isConnected) {
            print("🔌 NavigationScreen: Reconnecting socket after connectivity restored...");
            await socketProvider.connectWithUser(
              userId: userId,
              role: userRole,
            );
            print("🔌 NavigationScreen: Socket reconnected successfully");
          } else {
            print("🔌 NavigationScreen: Socket already connected, no need to reconnect");
          }
        }
      }
    } catch (e) {
      print("🔌 NavigationScreen: Socket reconnection failed - $e");
    }
  }

  bool isDeviceConnected = false;
  bool isAlertSet = false;


  late StreamSubscription<List<ConnectivityResult>> subscription;
  List<ConnectivityResult> _connectionStatus = [ConnectivityResult.none];
  final Connectivity _connectivity = Connectivity();
  /// Initialize connectivity status
  Future<void> initConnectivity() async {
    late List<ConnectivityResult> result;
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      print('Couldn\'t check connectivity status: $e');
      return;
    }

    if (!mounted) {
      return Future.value(null);
    }

    return _updateConnectionStatus(result);
  }

  ///Update connection status
  Future<void> _updateConnectionStatus(List<ConnectivityResult> result) async {
    setState(() {
      _connectionStatus = result;
    });

    // Check if device has internet connection
    isDeviceConnected = await InternetConnectionChecker().hasConnection;

    // Check if we have any active connection (not just 'none')
    bool hasConnection = !result.contains(ConnectivityResult.none) &&
        result.isNotEmpty &&
        isDeviceConnected;

    print('Connectivity changed: $_connectionStatus, Internet: $isDeviceConnected');

    if (!hasConnection && !isAlertSet) {
      showDialogBox();
      setState(() => isAlertSet = true);
    } else if (hasConnection && isAlertSet) {
      Navigator.of(context, rootNavigator: true).pop(); // Close the dialog
      setState(() => isAlertSet = false);

      // ✅ IMPROVED: Only reconnect if socket was initialized before
      if (_socketInitialized) {
        await _reconnectSocketAfterConnectivity();
      }

      Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => NavigationScreen(initialIndex: 0))
      );
    }
  }

  // ✅ Updated connectivity listener for v7.0.0
  getConnectivity() => subscription = _connectivity.onConnectivityChanged.listen(
        (List<ConnectivityResult> result) async {
      await _updateConnectionStatus(result);
    },
  );


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _setSystemUIColors();
    labels = [
      AppLocalizations.of(context)!.home,
      AppLocalizations.of(context)!.task,
      AppLocalizations.of(context)!.scan,
      AppLocalizations.of(context)!.stores,
      AppLocalizations.of(context)!.income,
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
  void dispose() {
    subscription.cancel();
    super.dispose();
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
                                child: Text('No', style: AppTextStyles.textSize12(context, weight: FontWeight.w600)),
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
                                  width: 18,
                                  height: 18,
                                  color: isSelected ? AppColors.button(context) : AppColors.subtitle(context),
                                  semanticsLabel: labels[index],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  labels[index],
                                  style: AppTextStyles.textSize12(
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
            CupertinoIcons.wifi_exclamationmark,
            size: 40,
            color: CupertinoColors.systemRed,
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
            isDeviceConnected = await InternetConnectionChecker().hasConnection;
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
              color: CupertinoColors.activeBlue,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    ),
  );
}