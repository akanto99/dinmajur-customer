// import 'dart:async';
// import 'package:connectivity_plus/connectivity_plus.dart';
// import 'package:dinmajur_customer/configs/res/color.dart';
// import 'package:dinmajur_customer/configs/res/text_styles.dart';
// import 'package:dinmajur_customer/l10n/app_localizations.dart';
// import 'package:dinmajur_customer/provider/DarkAndLightTheme/theme_provider.dart';
// import 'package:dinmajur_customer/socket_connection_model/socket_provider_services/socket_provider.dart';
// import 'package:dinmajur_customer/view/screens/draft/draft_screen.dart';
// import 'package:dinmajur_customer/view/screens/home/drawer/offers/offers_screen.dart';
// import 'package:dinmajur_customer/view/screens/home/home_screen.dart';
// import 'package:dinmajur_customer/view/screens/order/order_screen_new.dart';
// import 'package:dinmajur_customer/view_model/userview_model/userview_model.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:internet_connection_checker/internet_connection_checker.dart';
// import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:upgrader/upgrader.dart';
//
// class NavigationScreen extends StatefulWidget {
//   final int initialIndex;
//
//   const NavigationScreen({super.key, this.initialIndex = 0});
//
//   @override
//   State<NavigationScreen> createState() => _NavigationScreenState();
// }
//
// // ✅ ADD: WidgetsBindingObserver to listen to app lifecycle changes
// class _NavigationScreenState extends State<NavigationScreen> with WidgetsBindingObserver {
//   int _currentIndex = 0;
//   final GlobalKey<ScaffoldState> _key = GlobalKey<ScaffoldState>();
//   final List<String> icons = [
//     "assets/images/navBar/navbar_new/home.svg",
//     "assets/images/navBar/navbar_new/offers.svg",
//     "assets/images/navBar/navbar_new/order.svg",
//     "assets/images/navBar/navbar_new/draft.svg",
//   ];
//
//   late List<String> labels;
//   late final List<Widget> _pages;
//   bool _socketInitialized = false;
//
//   @override
//   void initState() {
//     super.initState();
//
//     // ✅ ADD: Register lifecycle observer
//     WidgetsBinding.instance.addObserver(this);
//
//     _pages = [
//       HomeScreen(scaffoldKey: _key),
//       OffersScreen(),
//       OrderScreen(),
//       DraftScreen(),
//     ];
//
//     ///Network Connectivity initialize
//     initConnectivity();
//     getConnectivity();
//     _currentIndex = widget.initialIndex;
//
//     /// Initialize socket connection after widget is built
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _initializeSocketConnection();
//     });
//   }
//
//   // ✅ ADD: Override didChangeAppLifecycleState to handle app state changes
//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     super.didChangeAppLifecycleState(state);
//
//     print("🔌 NavigationScreen: App lifecycle state changed to: $state");
//
//     switch (state) {
//       case AppLifecycleState.resumed:
//       // App came to foreground - check and reconnect socket if needed
//         print("🔌 NavigationScreen: App resumed - checking socket connection");
//         _handleAppResumed();
//         break;
//
//       case AppLifecycleState.inactive:
//       // App is inactive (e.g., phone call, switching apps)
//         print("🔌 NavigationScreen: App inactive");
//         break;
//
//       case AppLifecycleState.paused:
//       // App is in background
//         print("🔌 NavigationScreen: App paused");
//         break;
//
//       case AppLifecycleState.detached:
//       // App is detached
//         print("🔌 NavigationScreen: App detached");
//         break;
//
//       case AppLifecycleState.hidden:
//       // App is hidden (iOS specific)
//         print("🔌 NavigationScreen: App hidden");
//         break;
//     }
//   }
//
//   // ✅ ADD: Handle app resumed - reconnect socket if needed
//   Future<void> _handleAppResumed() async {
//     try {
//       final socketProvider = Provider.of<SocketProvider>(context, listen: false);
//
//       // Get userId from SharedPreferences
//       SharedPreferences prefs = await SharedPreferences.getInstance();
//       String? userId = prefs.getString('userId');
//
//       if (userId != null && userId.isNotEmpty) {
//         print("🔌 NavigationScreen: Checking socket status after app resume");
//
//         // Check if socket is connected
//         if (!socketProvider.isConnected) {
//           print("🔌 NavigationScreen: Socket disconnected, reconnecting...");
//
//           // Wait a bit for network to stabilize
//           await Future.delayed(Duration(milliseconds: 500));
//
//           // Check internet connectivity first
//           bool hasInternet = await InternetConnectionChecker().hasConnection;
//
//           if (hasInternet) {
//             print("🔌 NavigationScreen: Internet available, reconnecting socket");
//
//             // Fully disconnect first
//             await socketProvider.disconnect();
//             await Future.delayed(Duration(milliseconds: 300));
//
//             // Reconnect with user credentials
//             await socketProvider.connectWithUser(userId: userId);
//
//             // Verify connection
//             await Future.delayed(Duration(milliseconds: 1000));
//
//             if (socketProvider.isConnected) {
//               print("🔌 NavigationScreen: ✅ Socket reconnected successfully on app resume");
//             } else {
//               print("🔌 NavigationScreen: ⚠️ Socket reconnection uncertain, trying auto-reconnect");
//               await socketProvider.autoReconnect(maxRetries: 2, delay: Duration(seconds: 2));
//             }
//           } else {
//             print("🔌 NavigationScreen: No internet connection, cannot reconnect socket");
//           }
//         } else {
//           print("🔌 NavigationScreen: Socket already connected");
//         }
//       } else {
//         print("🔌 NavigationScreen: No userId found, skipping socket reconnection");
//       }
//     } catch (e) {
//       print("🔌 NavigationScreen: Error handling app resume - $e");
//     }
//   }
//
//   // ✅ IMPROVED: Initialize socket connection with proper checks
//   Future<void> _initializeSocketConnection() async {
//     if (_socketInitialized) {
//       print("🔌 NavigationScreen: Socket already initialized, skipping");
//       return;
//     }
//
//     try {
//       final userViewModel = Provider.of<UserViewModel>(context, listen: false);
//       final socketProvider = Provider.of<SocketProvider>(context, listen: false);
//
//       // Load user data from preferences first
//       await userViewModel.loadUserFromPrefs();
//
//       // Get userId from SharedPreferences
//       SharedPreferences prefs = await SharedPreferences.getInstance();
//       String? userId = prefs.getString('userId');
//
//       if (userId != null && userId.isNotEmpty) {
//         print("🔌 NavigationScreen: Initializing socket for user: $userId");
//
//         if (!socketProvider.isConnected) {
//           print("🔌 NavigationScreen: Socket not connected, connecting now...");
//           await socketProvider.connectWithUser(userId: userId);
//           print("🔌 NavigationScreen: Socket connected successfully");
//           _socketInitialized = true;
//         } else {
//           print("🔌 NavigationScreen: Socket already connected");
//           _socketInitialized = true;
//         }
//       } else {
//         print("🔌 NavigationScreen: No userId found, skipping socket initialization");
//       }
//     } catch (e) {
//       print("🔌 NavigationScreen: Socket initialization failed - $e");
//       _socketInitialized = false;
//     }
//   }
//
//   // ✅ IMPROVED: Reconnect socket when internet connectivity is restored
//   Future<void> _reconnectSocketAfterConnectivity() async {
//     try {
//       final socketProvider = Provider.of<SocketProvider>(context, listen: false);
//
//       // Get userId from SharedPreferences
//       SharedPreferences prefs = await SharedPreferences.getInstance();
//       String? userId = prefs.getString('userId');
//
//       if (userId != null && userId.isNotEmpty) {
//         print("🔌 NavigationScreen: Checking socket connection status...");
//
//         // Check if socket is truly connected
//         if (!socketProvider.isConnected) {
//           print("🔌 NavigationScreen: Socket disconnected, initiating full reconnection...");
//
//           // IMPORTANT: Fully disconnect first to ensure clean state
//           await socketProvider.disconnect();
//
//           // Small delay to ensure clean disconnect
//           await Future.delayed(Duration(milliseconds: 500));
//
//           // Now reconnect with fresh connection
//           await socketProvider.connectWithUser(userId: userId);
//
//           print("🔌 NavigationScreen: Socket reconnection completed");
//
//           // Verify connection after a short delay
//           await Future.delayed(Duration(milliseconds: 1000));
//
//           if (socketProvider.isConnected) {
//             print("🔌 NavigationScreen: ✅ Socket reconnected and verified successfully");
//           } else {
//             print("🔌 NavigationScreen: ⚠️ Socket reconnection uncertain, attempting auto-reconnect...");
//             // Try auto-reconnect with retries
//             await socketProvider.autoReconnect(maxRetries: 3, delay: Duration(seconds: 2));
//           }
//         } else {
//           print("🔌 NavigationScreen: Socket already connected");
//         }
//       } else {
//         print("🔌 NavigationScreen: No userId found for reconnection");
//       }
//     } catch (e) {
//       print("🔌 NavigationScreen: Socket reconnection failed - $e");
//
//       // On failure, try one more time with auto-reconnect
//       try {
//         final socketProvider = Provider.of<SocketProvider>(context, listen: false);
//         await socketProvider.autoReconnect(maxRetries: 2, delay: Duration(seconds: 3));
//       } catch (retryError) {
//         print("🔌 NavigationScreen: Final reconnection attempt failed - $retryError");
//         _socketInitialized = false; // Reset flag for future attempts
//       }
//     }
//   }
//
//   bool isDeviceConnected = false;
//   bool isAlertSet = false;
//
//   late StreamSubscription<List<ConnectivityResult>> subscription;
//   List<ConnectivityResult> _connectionStatus = [ConnectivityResult.none];
//   final Connectivity _connectivity = Connectivity();
//
//   /// Initialize connectivity status
//   Future<void> initConnectivity() async {
//     late List<ConnectivityResult> result;
//     try {
//       result = await _connectivity.checkConnectivity();
//     } on PlatformException catch (e) {
//       print('Couldn\'t check connectivity status: $e');
//       return;
//     }
//
//     if (!mounted) {
//       return Future.value(null);
//     }
//
//     return _updateConnectionStatus(result);
//   }
//
//   ///Update connection status
//   Future<void> _updateConnectionStatus(List<ConnectivityResult> result) async {
//     setState(() {
//       _connectionStatus = result;
//     });
//
//     // Check if device has internet connection
//     isDeviceConnected = await InternetConnectionChecker().hasConnection;
//
//     // Check if we have any active connection
//     bool hasConnection = !result.contains(ConnectivityResult.none) &&
//         result.isNotEmpty &&
//         isDeviceConnected;
//
//     print('Connectivity changed: $_connectionStatus, Internet: $isDeviceConnected');
//
//     if (!hasConnection && !isAlertSet) {
//       showDialogBox();
//       setState(() => isAlertSet = true);
//     } else if (hasConnection && isAlertSet) {
//       Navigator.of(context, rootNavigator: true).pop(); // Close the dialog
//       setState(() => isAlertSet = false);
//
//       // ✅ Reconnect socket after connectivity is restored using WidgetsBinding
//       if (_socketInitialized) {
//         WidgetsBinding.instance.addPostFrameCallback((_) {
//           _reconnectSocketAfterConnectivity();
//         });
//       }
//
//       // Reset to home screen
//       setState(() {
//         _currentIndex = 0;
//       });
//     }
//   }
//
//   // ✅ Updated connectivity listener for v7.0.0
//   getConnectivity() => subscription = _connectivity.onConnectivityChanged.listen(
//         (List<ConnectivityResult> result) async {
//       await _updateConnectionStatus(result);
//     },
//   );
//
//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     _setSystemUIColors();
//     labels = [
//       AppLocalizations.of(context)!.home,
//       AppLocalizations.of(context)!.offers,
//       AppLocalizations.of(context)!.order,
//       AppLocalizations.of(context)!.draft,
//     ];
//   }
//
//   void _setSystemUIColors() {
//     final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
//     bool isDarkMode = themeProvider.isDarkMode;
//
//     SystemChrome.setSystemUIOverlayStyle(
//       SystemUiOverlayStyle(
//         systemNavigationBarColor: isDarkMode ? AppColors.blackColor : AppColors.whiteColor,
//         statusBarColor: isDarkMode ? AppColors.blackColor : AppColors.whiteColor,
//         statusBarIconBrightness: isDarkMode ? Brightness.light : Brightness.dark,
//         statusBarBrightness: isDarkMode ? Brightness.dark : Brightness.light,
//         systemNavigationBarIconBrightness: isDarkMode ? Brightness.light : Brightness.dark,
//         systemNavigationBarDividerColor: isDarkMode ? AppColors.blackColor : AppColors.whiteColor,
//       ),
//     );
//   }
//
//   @override
//   void dispose() {
//     // ✅ ADD: Remove lifecycle observer
//     WidgetsBinding.instance.removeObserver(this);
//     subscription.cancel();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final themeProvider = Provider.of<ThemeProvider>(context);
//     final isDarkMode = themeProvider.isDarkMode;
//     final screenHeight = MediaQuery.of(context).size.height;
//     final screenWidth = MediaQuery.of(context).size.width;
//
//     return AnnotatedRegion<SystemUiOverlayStyle>(
//       value: SystemUiOverlayStyle(
//         statusBarColor: isDarkMode ? AppColors.blackColor : AppColors.whiteColor,
//         statusBarIconBrightness: isDarkMode ? Brightness.light : Brightness.dark,
//         statusBarBrightness: isDarkMode ? Brightness.dark : Brightness.light,
//         systemNavigationBarColor: isDarkMode ? AppColors.blackColor : AppColors.whiteColor,
//         systemNavigationBarIconBrightness: isDarkMode ? Brightness.light : Brightness.dark,
//         systemNavigationBarDividerColor: isDarkMode ? AppColors.blackColor : AppColors.whiteColor,
//         systemNavigationBarContrastEnforced: false,
//       ),
//       child: UpgradeAlert(
//         barrierDismissible: false,
//         showLater: false,
//         showIgnore: false,
//         showReleaseNotes: false,
//         upgrader: Upgrader(),
//         child: SafeArea(
//           child: WillPopScope(
//             onWillPop: () async {
//               if (_currentIndex == 0 && _key.currentState != null && _key.currentState!.isDrawerOpen) {
//                 _key.currentState!.closeDrawer();
//                 return Future.value(false);
//               }
//               final value = await showDialog<bool>(
//                 context: context,
//                 builder: (context) {
//                   return AlertDialog(
//                     backgroundColor: AppColors.containerBackground(context),
//                     contentPadding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02, vertical: screenHeight * 0.02),
//                     insetPadding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1, vertical: screenHeight * 0.2),
//                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
//                     content: Text(
//                       "Are you sure you want to exit?",
//                       style: AppTextStyles.textSize16(context, weight: FontWeight.w600),
//                     ),
//                     actions: [
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           GestureDetector(
//                             onTap: () => Navigator.of(context).pop(false),
//                             child: Container(
//                               width: screenWidth * 0.2,
//                               padding: EdgeInsets.symmetric(vertical: screenHeight * 0.008),
//                               decoration: BoxDecoration(
//                                 color: AppColors.textFieldFill(context),
//                                 borderRadius: BorderRadius.circular(5),
//                               ),
//                               child: Center(
//                                 child: Text('No', style: AppTextStyles.textSize12(context, weight: FontWeight.w600)),
//                               ),
//                             ),
//                           ),
//                           SizedBox(width: screenWidth * 0.02),
//                           GestureDetector(
//                             onTap: () => SystemNavigator.pop(),
//                             child: Container(
//                               width: screenWidth * 0.2,
//                               padding: EdgeInsets.symmetric(vertical: screenHeight * 0.008),
//                               decoration: BoxDecoration(
//                                 color: AppColors.button(context),
//                                 borderRadius: BorderRadius.circular(5),
//                               ),
//                               child: Center(
//                                 child: Text(
//                                   'Yes',
//                                   style: GoogleFonts.hindSiliguri(
//                                     fontSize: 14,
//                                     fontWeight: FontWeight.w500,
//                                     color: AppColors.whiteColor,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   );
//                 },
//               );
//               return value ?? false;
//             },
//             child: Scaffold(
//               body: _pages[_currentIndex],
//               bottomNavigationBar: Container(
//                 height: 60,
//                 width: screenWidth * 0.9,
//                 decoration: BoxDecoration(
//                   color: AppColors.globalBlackWhite(context),
//                   boxShadow: [
//                     Theme.of(context).brightness == Brightness.dark
//                         ? BoxShadow(color: Colors.white12.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, -2))
//                         : BoxShadow(color: Colors.white10, blurRadius: 10, offset: const Offset(0, -2)),
//                   ],
//                 ),
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Divider(color: AppColors.border(context), height: 1),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceAround,
//                       children: List.generate(icons.length, (index) {
//                         bool isSelected = _currentIndex == index;
//                         return GestureDetector(
//                           onTap: () {
//                             if (index == 0 && _currentIndex == 0 && _key.currentState != null && _key.currentState!.isDrawerOpen) {
//                               _key.currentState!.closeDrawer();
//                             } else {
//                               setState(() {
//                                 _currentIndex = index;
//                               });
//                             }
//                           },
//                           child: Container(
//                             width: screenWidth * 0.2,
//                             color: Colors.transparent,
//                             child: Column(
//                               mainAxisSize: MainAxisSize.min,
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 SvgPicture.asset(
//                                   icons[index],
//                                   width: 18,
//                                   height: 18,
//                                   color: isSelected ? AppColors.button(context) : AppColors.subtitle(context),
//                                   semanticsLabel: labels[index],
//                                 ),
//                                 const SizedBox(height: 6),
//                                 Text(
//                                   labels[index],
//                                   style: AppTextStyles.textSize12(
//                                     context,
//                                     weight: isSelected ? FontWeight.w500 : FontWeight.w400,
//                                     color: isSelected ? AppColors.button(context) : AppColors.subtitle(context),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         );
//                       }),
//                     ),
//                     Container(height: 1),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   showDialogBox() => showCupertinoDialog<String>(
//     context: context,
//     builder: (BuildContext context) => CupertinoAlertDialog(
//       title: Column(
//         children: [
//           Icon(
//             CupertinoIcons.wifi_exclamationmark,
//             size: 40,
//             color: CupertinoColors.systemRed,
//           ),
//           SizedBox(height: 10),
//           Text(
//               'Connection Lost',
//               style:GoogleFonts.hindSiliguri(
//                 fontSize: 16,
//                 fontWeight: FontWeight.w600,
//                 color: AppColors.textPrimary(context),
//               )
//           ),
//         ],
//       ),
//       content: Padding(
//         padding: const EdgeInsets.only(top: 8.0),
//         child: Text(
//           'You seem to be offline. Check your connection to stay updated.',
//           textAlign: TextAlign.center,
//           style: GoogleFonts.hindSiliguri(
//             fontSize: 14,
//             fontWeight: FontWeight.w400,
//             color: AppColors.textPrimary(context),
//           ),
//         ),
//       ),
//       actions: <Widget>[
//         TextButton(
//           onPressed: () async {
//             Navigator.pop(context, 'Cancel');
//             setState(() => isAlertSet = false);
//
//             List<ConnectivityResult> result = await _connectivity.checkConnectivity();
//             bool hasInternet = await InternetConnectionChecker().hasConnection;
//             bool hasConnection = !result.contains(ConnectivityResult.none) &&
//                 result.isNotEmpty &&
//                 hasInternet;
//
//             if (hasConnection) {
//               print("🔌 NavigationScreen: Retry - Connection restored");
//
//               // ✅ Use the improved reconnection method
//               await _reconnectSocketAfterConnectivity();
//
//               setState(() {
//                 _currentIndex = 0;
//               });
//             } else {
//               print("🔌 NavigationScreen: Retry - Still no connection");
//               showDialogBox();
//               setState(() => isAlertSet = true);
//             }
//           },
//           child: Text(
//             'Retry',
//             style: TextStyle(
//               color: CupertinoColors.activeBlue,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ),
//       ],
//     ),
//   );
// }
import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:dinmajur_customer/l10n/app_localizations.dart';
import 'package:dinmajur_customer/provider/DarkAndLightTheme/theme_provider.dart';
import 'package:dinmajur_customer/socket_connection_model/socket_provider_services/socket_provider.dart';
import 'package:dinmajur_customer/view/screens/draft/draft_screen.dart';
import 'package:dinmajur_customer/view/screens/home/drawer/offers/offers_screen.dart';
import 'package:dinmajur_customer/view/screens/home/home_screen.dart';
import 'package:dinmajur_customer/view/screens/order/order_screen_new.dart';
import 'package:dinmajur_customer/view_model/userview_model/userview_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:upgrader/upgrader.dart';

class NavigationScreen extends StatefulWidget {
  final int initialIndex;

  const NavigationScreen({super.key, this.initialIndex = 0});

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> with WidgetsBindingObserver {
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
  bool _socketInitialized = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    _pages = [
      HomeScreen(scaffoldKey: _key),
      OffersScreen(),
      OrderScreen(),
      DraftScreen(),
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

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    print("🔌 NavigationScreen: App lifecycle state changed to: $state");

    switch (state) {
      case AppLifecycleState.resumed:
        print("🔌 NavigationScreen: App resumed - checking socket connection");
        _handleAppResumed();
        break;

      case AppLifecycleState.inactive:
        print("🔌 NavigationScreen: App inactive");
        break;

      case AppLifecycleState.paused:
        print("🔌 NavigationScreen: App paused");
        break;

      case AppLifecycleState.detached:
        print("🔌 NavigationScreen: App detached");
        break;

      case AppLifecycleState.hidden:
        print("🔌 NavigationScreen: App hidden");
        break;
    }
  }

  // ✅ UPDATED: Reset to home screen after app resume reconnection
  Future<void> _handleAppResumed() async {
    try {
      final socketProvider = Provider.of<SocketProvider>(context, listen: false);

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString('userId');

      if (userId != null && userId.isNotEmpty) {
        print("🔌 NavigationScreen: Checking socket status after app resume");

        if (!socketProvider.isConnected) {
          print("🔌 NavigationScreen: Socket disconnected, reconnecting...");

          await Future.delayed(Duration(milliseconds: 500));

          bool hasInternet = await InternetConnectionChecker().hasConnection;

          if (hasInternet) {
            print("🔌 NavigationScreen: Internet available, reconnecting socket");

            await socketProvider.disconnect();
            await Future.delayed(Duration(milliseconds: 300));

            await socketProvider.connectWithUser(userId: userId);

            await Future.delayed(Duration(milliseconds: 1000));

            if (socketProvider.isConnected) {
              print("🔌 NavigationScreen: ✅ Socket reconnected successfully on app resume");

              // ✅ ADDED: Reset to home screen after successful reconnection
              setState(() {
                _currentIndex = 0;
              });
            } else {
              print("🔌 NavigationScreen: ⚠️ Socket reconnection uncertain, trying auto-reconnect");
              await socketProvider.autoReconnect(maxRetries: 2, delay: Duration(seconds: 2));

              // ✅ ADDED: Reset to home screen even if uncertain
              setState(() {
                _currentIndex = 0;
              });
            }
          } else {
            print("🔌 NavigationScreen: No internet connection, cannot reconnect socket");
          }
        } else {
          print("🔌 NavigationScreen: Socket already connected");
        }
      } else {
        print("🔌 NavigationScreen: No userId found, skipping socket reconnection");
      }
    } catch (e) {
      print("🔌 NavigationScreen: Error handling app resume - $e");
    }
  }

  Future<void> _initializeSocketConnection() async {
    if (_socketInitialized) {
      print("🔌 NavigationScreen: Socket already initialized, skipping");
      return;
    }

    try {
      final userViewModel = Provider.of<UserViewModel>(context, listen: false);
      final socketProvider = Provider.of<SocketProvider>(context, listen: false);

      await userViewModel.loadUserFromPrefs();

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString('userId');

      if (userId != null && userId.isNotEmpty) {
        print("🔌 NavigationScreen: Initializing socket for user: $userId");

        if (!socketProvider.isConnected) {
          print("🔌 NavigationScreen: Socket not connected, connecting now...");
          await socketProvider.connectWithUser(userId: userId);
          print("🔌 NavigationScreen: Socket connected successfully");
          _socketInitialized = true;
        } else {
          print("🔌 NavigationScreen: Socket already connected");
          _socketInitialized = true;
        }
      } else {
        print("🔌 NavigationScreen: No userId found, skipping socket initialization");
      }
    } catch (e) {
      print("🔌 NavigationScreen: Socket initialization failed - $e");
      _socketInitialized = false;
    }
  }

  // ✅ UPDATED: Always reset to home screen after reconnection
  Future<void> _reconnectSocketAfterConnectivity() async {
    try {
      final socketProvider = Provider.of<SocketProvider>(context, listen: false);

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString('userId');

      if (userId != null && userId.isNotEmpty) {
        print("🔌 NavigationScreen: Checking socket connection status...");

        if (!socketProvider.isConnected) {
          print("🔌 NavigationScreen: Socket disconnected, initiating full reconnection...");

          await socketProvider.disconnect();

          await Future.delayed(Duration(milliseconds: 500));

          await socketProvider.connectWithUser(userId: userId);

          print("🔌 NavigationScreen: Socket reconnection completed");

          await Future.delayed(Duration(milliseconds: 1000));

          if (socketProvider.isConnected) {
            print("🔌 NavigationScreen: ✅ Socket reconnected and verified successfully");
          } else {
            print("🔌 NavigationScreen: ⚠️ Socket reconnection uncertain, attempting auto-reconnect...");
            await socketProvider.autoReconnect(maxRetries: 3, delay: Duration(seconds: 2));
          }

          // ✅ ADDED: Always reset to home screen after reconnection attempt
          setState(() {
            _currentIndex = 0;
          });
        } else {
          print("🔌 NavigationScreen: Socket already connected");
        }
      } else {
        print("🔌 NavigationScreen: No userId found for reconnection");
      }
    } catch (e) {
      print("🔌 NavigationScreen: Socket reconnection failed - $e");

      try {
        final socketProvider = Provider.of<SocketProvider>(context, listen: false);
        await socketProvider.autoReconnect(maxRetries: 2, delay: Duration(seconds: 3));
      } catch (retryError) {
        print("🔌 NavigationScreen: Final reconnection attempt failed - $retryError");
        _socketInitialized = false;
      }

      // ✅ ADDED: Reset to home screen even on failure
      setState(() {
        _currentIndex = 0;
      });
    }
  }

  bool isDeviceConnected = false;
  bool isAlertSet = false;

  late StreamSubscription<List<ConnectivityResult>> subscription;
  List<ConnectivityResult> _connectionStatus = [ConnectivityResult.none];
  final Connectivity _connectivity = Connectivity();

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

  // ✅ ALREADY CORRECT: This method already resets to index 0
  Future<void> _updateConnectionStatus(List<ConnectivityResult> result) async {
    setState(() {
      _connectionStatus = result;
    });

    isDeviceConnected = await InternetConnectionChecker().hasConnection;

    bool hasConnection = !result.contains(ConnectivityResult.none) &&
        result.isNotEmpty &&
        isDeviceConnected;

    print('Connectivity changed: $_connectionStatus, Internet: $isDeviceConnected');

    if (!hasConnection && !isAlertSet) {
      showDialogBox();
      setState(() => isAlertSet = true);
    } else if (hasConnection && isAlertSet) {
      Navigator.of(context, rootNavigator: true).pop();
      setState(() => isAlertSet = false);

      if (_socketInitialized) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _reconnectSocketAfterConnectivity();
        });
      }

      // ✅ ALREADY PRESENT: Reset to home screen
      setState(() {
        _currentIndex = 0;
      });
    }
  }

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
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
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

  // ✅ UPDATED: Reset to home screen in retry dialog
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

            List<ConnectivityResult> result = await _connectivity.checkConnectivity();
            bool hasInternet = await InternetConnectionChecker().hasConnection;
            bool hasConnection = !result.contains(ConnectivityResult.none) &&
                result.isNotEmpty &&
                hasInternet;

            if (hasConnection) {
              print("🔌 NavigationScreen: Retry - Connection restored");

              await _reconnectSocketAfterConnectivity();

              // ✅ ALREADY PRESENT: Reset to home screen after retry success
              setState(() {
                _currentIndex = 0;
              });
            } else {
              print("🔌 NavigationScreen: Retry - Still no connection");
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