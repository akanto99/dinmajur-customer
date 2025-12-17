import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/components/drawer.dart';
import 'package:dinmajur_customer/configs/res/components/exception_errorstate/exception_errorstate.dart';
import 'package:dinmajur_customer/configs/res/components/notifications/resuable_notifications.dart';
import 'package:dinmajur_customer/configs/res/sizedbox_spaccing.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:dinmajur_customer/configs/responsive/responsive_ui.dart';
import 'package:dinmajur_customer/configs/services/location_services/location_getting.dart';
import 'package:dinmajur_customer/configs/services/navigator_services/navigator_services_refreshToken.dart';
import 'package:dinmajur_customer/configs/services/sse_notification_services/sse_notification_count/notification_count_view_model.dart';
import 'package:dinmajur_customer/configs/services/sse_notification_services/sse_notification_service.dart';
import 'package:dinmajur_customer/configs/services/sse_notification_services/sse_notification/sse_notification_view_model.dart';
import 'package:dinmajur_customer/configs/utils/routes/routes_name.dart';
import 'package:dinmajur_customer/configs/widgets/dynamic_dropdown.dart';
import 'package:dinmajur_customer/data/response/status.dart';
import 'package:dinmajur_customer/l10n/app_localizations.dart';
import 'package:dinmajur_customer/view/screens/home/dorpdown_categories_selections_and_views/beauty_and_salon/beauty_and_salon_widget.dart';
import 'package:dinmajur_customer/view/screens/home/helper_widgets/dynamic_nearestheader_widget.dart';
import 'package:dinmajur_customer/view_model/homeview_model/dropdown_categories_selection_view_models/premium_house_keeper_view_model/check_coverage_view_model.dart';
import 'package:dinmajur_customer/view_model/homeview_model/profileview_model/profileview_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:upgrader/upgrader.dart';
import 'dorpdown_categories_selections_and_views/grocery/grocery_sction_widget.dart';
import 'dorpdown_categories_selections_and_views/premium_house_keeper/premium_house_keeper_widget.dart';
import 'package:dinmajur_customer/configs/utils/utils.dart';
import 'package:dinmajur_customer/view_model/homeview_model/location_view_model/newlocation_view_model.dart';
import 'package:dinmajur_customer/view_model/homeview_model/nearby_retailers_and_order_view_models/nearby_retailers_view_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  final GlobalKey<ScaffoldState>? scaffoldKey;
  const HomeScreen({super.key, this.scaffoldKey});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? selectedStoreType;
  List<dynamic> nearbyStores = [];
  bool isLoadingStores = false;

  // Location related variables
  final LocationService _locationService = LocationService();
  Position? _currentPosition;
  String? _currentAddress;
  bool _isLoadingLocation = false;

  late Map<String, String> storeTypes;

  // Key for SharedPreferences to track if location_screens has been posted
  static const String _locationPostedKey = 'location_posted_once';

  ///Check Coverage
  bool isCheckingCoverage = false;
  bool? isInsideServiceArea;

  // ✅ Add SSE listener flag
  bool _sseListenerInitialized = false;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    storeTypes = {
      // 'Retail': AppLocalizations.of(context)!.storeType_retail,
      'Retail': AppLocalizations.of(context)!.storeType_grocery,
      'Premium House Keeper': AppLocalizations.of(context)!.storeType_housekeeper,
      'Premium Home Beauty & Salon': AppLocalizations.of(context)!.storeType_beauty_salon,
      // 'restaurant': AppLocalizations.of(context)!.storeType_restaurant,
      // 'pharmacy': AppLocalizations.of(context)!.storeType_pharmacy,
      // 'electronics': AppLocalizations.of(context)!.storeType_electronics,
      // 'clothing': AppLocalizations.of(context)!.storeType_clothing,
    };
    // ✅ Initialize ONLY count listener in home screen
    // if (!_sseListenerInitialized) {
    //   _initializeSSECountListener();
    //   _sseListenerInitialized = true;
    // }
  }

  // void _initializeSSECountListener() {
  //   try {
  //     final sseService = Provider.of<SSENotificationService>(context, listen: false);
  //     final countViewModel = Provider.of<NotificationCountViewModel>(context, listen: false);
  //
  //     // Connect only count stream
  //     countViewModel.initializeCountListener(sseService.notificationCountStream);
  //
  //     debugPrint('✅ HomeScreen: notificationCount listener initialized');
  //   } catch (e) {
  //     debugPrint('❌ HomeScreen: Error initializing count listener: $e');
  //   }
  // }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profileViewModel = Provider.of<ProfileViewViewModel>(context, listen: false);

      // Only fetch if not already initialized (first load only)
      profileViewModel.fetchProfileViewUserDataApi();
    });

    _checkAndGetLocation();
  }

  Future<void> _handleRefresh() async {
    try {
      debugPrint('🔄 HomeScreen: Pull to refresh triggered');

      // 1. Force refresh profile data
      final profileViewModel = Provider.of<ProfileViewViewModel>(context, listen: false);
      await profileViewModel.refreshProfileData(); // Use refreshProfileData instead

      // 2. If a store type is selected and it's Retail, refresh nearby retailers
      if (selectedStoreType == 'Retail') {
        await _fetchNearbyRetailers(selectedStoreType!);
      }
    } catch (e) {
      if (mounted) {
        Utils.flushBarErrorMessage("Refresh failed", context);
      }
    }
  }

  // Check if location_screens has already been posted, if not, get and post it
  Future<void> _checkAndGetLocation() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool locationAlreadyPosted = prefs.getBool(_locationPostedKey) ?? false;

    if (!locationAlreadyPosted) {
      await _getLocationWithAddress();
    } else {
      debugPrint('Location already posted. Skipping location_screens fetch.');
    }
  }

  Future<void> _getLocationWithAddress() async {
    if (!mounted) return;
    setState(() {
      _isLoadingLocation = true;
    });

    try {
      Map<String, dynamic> locationData = await _locationService.getCurrentLocationWithAddress();
      Position position = locationData['position'];
      String fullAddress = locationData['address'];
      String shortAddr = await _locationService.getShortAddress(position.latitude, position.longitude);

      if (mounted) {
        setState(() {
          _currentPosition = position;
          _currentAddress = fullAddress;
          _isLoadingLocation = false;
        });

        debugPrint('========== CURRENT LOCATION WITH ADDRESS ==========');
        debugPrint('Latitude: ${position.latitude}');
        debugPrint('Longitude: ${position.longitude}');
        debugPrint('Full Address: $fullAddress');
        debugPrint('Short Address: $shortAddr');
        debugPrint('==================================================');

        await _postLocationToApi(position.longitude, position.latitude, fullAddress);
        await _markLocationAsPosted();

        final profileViewModel = Provider.of<ProfileViewViewModel>(context, listen: false);
        await profileViewModel.fetchProfileViewUserDataApi();
      }
    } catch (e) {
      debugPrint('Error getting location_screens with address: $e');
      if (mounted) {
        setState(() {
          _isLoadingLocation = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Location error: ${e.toString()}'), backgroundColor: Colors.red, duration: Duration(seconds: 3)));
      }
    }
  }

  Future<void> _markLocationAsPosted() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_locationPostedKey, true);
    debugPrint('Location marked as posted.');
  }

  Future<void> _postLocationToApi(double longitude, double latitude, String fullAddress) async {
    try {
      final locationData = {
        "geoLocation": {
          "type": "Point",
          "coordinates": [longitude, latitude],
        },
        "fullAddress": fullAddress,
        "type": "DELIVERY_ADDRESS",
      };
      final addLocationViewModel = Provider.of<AddLocationViewModel>(context, listen: false);
      await addLocationViewModel.addLocationPostApi(context, locationData);
      debugPrint('Location posted successfully to API');
    } catch (e) {
      debugPrint('Error posting location_screens to API: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to save location_screens: ${e.toString()}'), backgroundColor: Colors.orange, duration: Duration(seconds: 3)));
      }
    }
  }

  /// Method to fetch nearby retailers
  Future<void> _fetchNearbyRetailers(String businessType) async {
    if (!mounted) return;

    setState(() {
      isLoadingStores = true;
      nearbyStores = [];
    });

    try {
      final profileViewModel = Provider.of<ProfileViewViewModel>(context, listen: false);

      double? customerLng;
      double? customerLat;
      String? fullAddress;

      if (profileViewModel.profileviewUserData.status == Status.COMPLETED) {
        final addressData = profileViewModel.profileviewUserData.data?.data?.addresses;

        if (addressData?.geoLocation?.coordinates != null && addressData!.geoLocation!.coordinates!.length >= 2) {
          customerLng = addressData.geoLocation!.coordinates![0];
          customerLat = addressData.geoLocation!.coordinates![1];
          fullAddress = addressData.fullAddress;
        }
      }

      if (customerLng == null || customerLat == null) {
        if (_currentPosition != null) {
          customerLng = _currentPosition!.longitude;
          customerLat = _currentPosition!.latitude;
          fullAddress ??= "Current Location";
        } else {
          if (mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Location not available. Please enable location_screens services.'), backgroundColor: Colors.orange, duration: Duration(seconds: 3)));
          }
          setState(() => isLoadingStores = false);
          return;
        }
      }

      final viewModel = Provider.of<PostNearbyRetailersViewModel>(context, listen: false);

      final requestData = {
        "deliveryAddress": {
          "geoLocation": {
            "type": "Point",
            "coordinates": [customerLng, customerLat],
          },
          "fullAddress": fullAddress ?? "",
        },
        "businessType": businessType,
      };

      List<dynamic>? stores = await viewModel.nearbyRetailersPostApi(context, requestData);
      if (mounted) {
        if (stores != null && stores.isNotEmpty) {
          setState(() => nearbyStores = stores);
        } else {
          // Utils.snackBar("No nearby stores found for this business type.", context);
        }
      }
    } catch (e) {
      if (mounted) {
        Utils.flushBarErrorMessage("Failed to fetch nearby stores", context);
      }
    } finally {
      if (mounted) {
        setState(() => isLoadingStores = false);
      }
    }
  }

  /// Method to fetch Premium House keeper Check Coverage
  // Future<void> _checkCoverage() async {
  //   if (!mounted) return;
  //
  //   // Set loading state FIRST
  //   setState(() {
  //     isCheckingCoverage = true;
  //     isInsideServiceArea = null;
  //   });
  //
  //   try {
  //     final checkCoverageViewModel = Provider.of<CheckCoverageViewModel>(context, listen: false);
  //
  //     // Call the API
  //     await checkCoverageViewModel.fetchCheckCoverageDataApi();
  //     if (!mounted) return;
  //
  //     // Check the status
  //     if (checkCoverageViewModel.checkCoverageData.status == Status.COMPLETED) {
  //       final responseData = checkCoverageViewModel.checkCoverageData.data;
  //       if (responseData?.data?.insideServiceArea == true) {
  //         setState(() {
  //           isInsideServiceArea = true;
  //           isCheckingCoverage = false;
  //         });
  //       } else {
  //         setState(() {
  //           isInsideServiceArea = false;
  //           isCheckingCoverage = false;
  //         });
  //         // Utils.flushBarErrorMessage(
  //         //   responseData?.message ?? "Service is not available in your location.",
  //         //   context,
  //         // );
  //       }
  //     } else if (checkCoverageViewModel.checkCoverageData.status == Status.ERROR) {
  //       setState(() {
  //         isInsideServiceArea = false;
  //         isCheckingCoverage = false;
  //       });
  //       Utils.flushBarErrorMessage("Failed to check service coverage", context);
  //     } else {
  //       await Future.delayed(Duration(milliseconds: 500));
  //       if (mounted) {
  //         _checkCoverage(); // Retry
  //       }
  //     }
  //   } catch (e) {
  //     if (mounted) {
  //       setState(() {
  //         isInsideServiceArea = false;
  //         isCheckingCoverage = false;
  //       });
  //       Utils.flushBarErrorMessage("Failed to check service coverage", context);
  //     }
  //   }
  // }
  Future<void> _checkCoverage() async {
    if (!mounted) return;

    setState(() {
      isCheckingCoverage = true;
      isInsideServiceArea = null;
    });

    try {
      final checkCoverageViewModel = Provider.of<CheckCoverageViewModel>(context, listen: false);

      await checkCoverageViewModel.fetchCheckCoverageDataApi();
      if (!mounted) return;

      if (checkCoverageViewModel.checkCoverageData.status == Status.COMPLETED) {
        final responseData = checkCoverageViewModel.checkCoverageData.data;
        setState(() {
          isInsideServiceArea = responseData?.data?.insideServiceArea ?? false;
          isCheckingCoverage = false;
        });

        if (isInsideServiceArea == false) {
          Utils.flushBarErrorMessage(
            responseData?.message ?? "Service is not available in your location.",
            context,
          );
        }
      } else if (checkCoverageViewModel.checkCoverageData.status == Status.ERROR) {
        setState(() {
          isInsideServiceArea = false;
          isCheckingCoverage = false;
        });

        // ✅ Show specific error message
        String errorMsg = checkCoverageViewModel.checkCoverageData.message ?? "Failed to check service coverage";
        Utils.flushBarErrorMessage(errorMsg, context);

        // ✅ REMOVE the retry logic that was causing infinite loop
        // Don't call _checkCoverage() again here!
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isInsideServiceArea = false;
          isCheckingCoverage = false;
        });
        Utils.flushBarErrorMessage("Failed to check service coverage", context);
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return UpgradeAlert(
      navigatorKey: NavigationService.navigatorKey,
      barrierDismissible: false,
      showLater: false,
      showIgnore: false,
      showReleaseNotes: false,
      upgrader: Upgrader(),
      child: Scaffold(
        key: widget.scaffoldKey,
        backgroundColor: AppColors.containerBackground(context),
        drawer: CustomDrawer(screenHeight: screenHeight, screenWidth: screenWidth),
        // appBar: PreferredSize(
        //   preferredSize:  Size.fromHeight(100),
        //   child: Container(
        //     color: AppColors.containerBackground(context),
        //     child: Center(child: _customAppBar(context)),
        //   ),
        // ),
        body: SafeArea(
          child: ResPonsiveUi(mobile: body(context), desktop: body(context), tablet: body(context)),
        ),
      ),
    );
  }

  Widget body(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return RefreshIndicator(
      onRefresh: _handleRefresh,
      color: AppColors.textPrimary(context),
      backgroundColor: AppColors.containerBackground(context),
      displacement: 40,
      strokeWidth: 2.0,
      child: Column(
        children: [
          _customAppBar(context),
          SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [

                SizedboxSpaccing.height02(context),
                Container(
                  width: screenWidth * 0.9,
                  padding: EdgeInsets.all(screenHeight * 0.02),
                  decoration: BoxDecoration(
                    color: AppColors.containerBackground(context),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(width: 1, color: AppColors.border(context)),
                  ),
                  child: CustomDropdown(
                    titleText: AppLocalizations.of(context)!.select_store_type,
                    items: storeTypes.keys.toList(),
                    selectedItem: selectedStoreType,
                    hintText: AppLocalizations.of(context)!.select_store_type_hint,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedStoreType = newValue;
                        nearbyStores = [];
                        isInsideServiceArea = null;
                        isCheckingCoverage = false;
                      });

                      if (newValue != null) {
                        debugPrint('🔄 Selected store type: $newValue');

                        if (newValue == 'Retail') {
                          _fetchNearbyRetailers(newValue);
                        } else if (newValue == 'Premium House Keeper') {
                          _checkCoverage();
                        }else if (newValue == 'Premium Home Beauty & Salon') {
                          _checkCoverage();
                        }
                      }
                    },
                    valueToBengaliMap: storeTypes,
                  ),
                ),
                Center(child: SizedboxSpaccing.height02(context)),
                DynamicNearestHeader(
                  selectedStoreType: selectedStoreType,
                  storeCount: nearbyStores.length,
                  screenWidth: screenWidth,
                  onSeeAllTap: () => _handleSeeAllNavigation(context),
                ),
                SizedboxSpaccing.height02(context),

                // Conditionally show content based on selection and coverage
                if (selectedStoreType == 'Retail')
                  GroceryStoresSection(
                    isLoading: isLoadingStores,
                    stores: nearbyStores,
                    storeTypes: storeTypes,
                    selectedStoreType: selectedStoreType,
                    currentPosition: _currentPosition,
                    currentAddress: _currentAddress,
                  )
                else if (selectedStoreType == 'Premium House Keeper')
                  Consumer<ProfileViewViewModel>(
                    builder: (context, profileViewModel, _) {
                      // Extract customer data from profile
                      String customerName = '';
                      String customerPhone = '';
                      String customerAddress = '';

                      if (profileViewModel.profileviewUserData.status == Status.COMPLETED) {
                        final userData = profileViewModel.profileviewUserData.data?.data;

                        // Get name
                        if (userData?.user?.fullName != null) {
                          customerName = userData!.user!.fullName!;
                        }

                        // Get phone
                        if (userData?.user?.phone != null) {
                          customerPhone = userData!.user!.phone!;
                        }

                        // Get address
                        if (userData?.addresses?.fullAddress != null) {
                          customerAddress = userData!.addresses!.fullAddress!;
                        }
                      }

                      return PremiumHouseKeeperCoverageWidget(
                        isCheckingCoverage: isCheckingCoverage,
                        isInsideServiceArea: isInsideServiceArea,
                        customerName: customerName,
                        customerPhone: customerPhone,
                        customerAddress: customerAddress,
                      );
                    },
                  )
                else if (selectedStoreType == 'Premium Home Beauty & Salon')
                  Consumer<ProfileViewViewModel>(
                    builder: (context, profileViewModel, _) {
                      // Extract customer data from profile
                      String customerName = '';
                      String customerPhone = '';
                      String customerAddress = '';

                      if (profileViewModel.profileviewUserData.status == Status.COMPLETED) {
                        final userData = profileViewModel.profileviewUserData.data?.data;

                        // Get name
                        if (userData?.user?.fullName != null) {
                          customerName = userData!.user!.fullName!;
                        }

                        // Get phone
                        if (userData?.user?.phone != null) {
                          customerPhone = userData!.user!.phone!;
                        }

                        // Get address
                        if (userData?.addresses?.fullAddress != null) {
                          customerAddress = userData!.addresses!.fullAddress!;
                        }
                      }

                      return PremiumBeautyAndSalonCoverageWidget(
                        isCheckingCoverage: isCheckingCoverage,
                        isInsideServiceArea: isInsideServiceArea,
                        customerName: customerName,
                        customerPhone: customerPhone,
                        customerAddress: customerAddress,
                      );
                    },
                  ),

                SizedboxSpaccing.height02(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _customAppBar(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Consumer<ProfileViewViewModel>(
      builder: (context, profileViewModel, _) {
        String displayAddress;

        if (_isLoadingLocation) {
          displayAddress = "Getting location_screens...";
        } else if (profileViewModel.profileviewUserData.status == Status.COMPLETED) {
          final responseData = profileViewModel.profileviewUserData.data;

          if (responseData?.data?.addresses != null) {
            final addressData = responseData!.data!.addresses!;

            if (addressData.type == 'DELIVERY_ADDRESS' && addressData.fullAddress != null && addressData.fullAddress!.isNotEmpty) {
              displayAddress = addressData.fullAddress!;
            } else if (addressData.fullAddress != null && addressData.fullAddress!.isNotEmpty) {
              displayAddress = addressData.fullAddress!;
            } else if (_currentAddress != null && _currentAddress!.isNotEmpty) {
              displayAddress = _currentAddress!;
            } else {
              displayAddress = "Tap to set location_screens";
            }
          } else if (_currentAddress != null && _currentAddress!.isNotEmpty) {
            displayAddress = _currentAddress!;
          } else {
            displayAddress = "Tap to set location_screens";
          }
        } else if (_currentAddress != null && _currentAddress!.isNotEmpty) {
          displayAddress = _currentAddress!;
        } else {
          displayAddress = "Tap to set location_screens";
        }

        switch (profileViewModel.profileviewUserData.status) {
          case Status.LOADING:
            return _buildAppBarContent(screenWidth: screenWidth, screenHeight: screenHeight, userName: "Loading...", displayAddress: displayAddress, profileImageUrl: null);

          case Status.ERROR:
            return ErrorStateEmptyHeaderWidget(
              errorMessage: profileViewModel.profileviewUserData.message.toString(),
              onRetry: () {
                final profileCompletionModel = Provider.of<ProfileViewViewModel>(context, listen: false);
                profileCompletionModel.fetchProfileViewUserDataApi();
              },
            );

          case Status.COMPLETED:
            final responseData = profileViewModel.profileviewUserData.data;
            String userName = 'Unknown User';
            String? profileImageUrl;

            if (responseData?.data?.user != null) {
              final userData = responseData!.data!.user!;
              profileImageUrl = userData.profilePicture?.url;

              final fullName = userData.fullName?.trim();

              if (fullName != null && fullName.isNotEmpty) {
                userName = '$fullName';
              }
            }

            return _buildAppBarContent(screenWidth: screenWidth, screenHeight: screenHeight, userName: userName, displayAddress: displayAddress, profileImageUrl: profileImageUrl);

          default:
            return Container(
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.border(context), width: 1.0)),
              ),
              height: 75,
            );
        }
      },
    );
  }

  Widget _buildAppBarContent({required double screenWidth, required double screenHeight, required String userName, required String displayAddress, String? profileImageUrl}) {
    return Container(
      height: 75,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(24), bottomRight: Radius.circular(24)),
        color: AppColors.containerBackground(context),
        border: Border(bottom: BorderSide(color: AppColors.border(context), width: 1.0)),
      ),
      child: Center(
        child: Container(
          width: screenWidth * 0.9,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Left Side - User Profile (your existing code)
              Expanded(
                flex: 3,
                child: Row(
                  children: [
                    Builder(
                      builder: (context) => GestureDetector(
                        onTap: () {
                          Scaffold.of(context).openDrawer();
                        },
                        child: Container(
                          height: 45,
                          width: 45,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.appBackground(context),
                            border: Border.all(width: 1, color: AppColors.textPrimary(context)),
                            image: profileImageUrl != null ? DecorationImage(image: NetworkImage(profileImageUrl), fit: BoxFit.cover) : null,
                          ),
                          child: profileImageUrl == null ? Icon(Icons.person, color: AppColors.textPrimary(context), size: 20) : null,
                        ),
                      ),
                    ),
                    SizedboxSpaccing.width02(context),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, RoutesName.addlocation);
                        },
                        child: Row(
                          children: [
                            Flexible(
                              child: Container(
                                color:Colors.transparent,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      userName,
                                      style: AppTextStyles.textSize18(context, weight: FontWeight.w600),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                    // Row(
                                    //   children: [
                                    //     Icon(Icons.location_on, size: 16, color: _isLoadingLocation ? AppColors.subtitle(context) : AppColors.textPrimary(context)),
                                    //     SizedBox(width: 4),
                                    //     Expanded(
                                    //       child: Text(
                                    //         displayAddress,
                                    //         style: AppTextStyles.textSize12(context, weight: FontWeight.w400, color: _isLoadingLocation ? AppColors.subtitle(context) : AppColors.textPrimary(context)),
                                    //         overflow: TextOverflow.ellipsis,
                                    //         maxLines: 1,
                                    //       ),
                                    //     ),
                                    //   ],
                                    // ),
                                Text(
                                          displayAddress,
                                          style: AppTextStyles.textSize12(context, weight: FontWeight.w400, color: _isLoadingLocation ? AppColors.subtitle(context) : AppColors.textPrimary(context)),
                                          overflow: TextOverflow.ellipsis,

                                        ),
                                  ],
                                ),
                              ),
                            ),
                            Container(width: 22, height: 45, alignment: Alignment.bottomCenter, child: Icon(Icons.arrow_drop_down_sharp, size: 25)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Right Side Icons
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedboxSpaccing.width03(context),

                  // Email Icon
                  _buildIconButton(
                    onTap: () {
                      NotificationDialog.show(
                        context,
                        message: AppLocalizations.of(context)!.empty_inbox,
                        icon: CupertinoIcons.text_bubble,
                        iconColor: AppColors.textPrimary(context),
                        iconBackgroundColor: AppColors.appBackground(context),
                      );
                    },
                    svgAsset: 'assets/images/home/email.svg',
                    context: context,
                  ),

                  SizedboxSpaccing.width02(context),

                  // ✅ Notification Icon - Shows count from notificationCount event
                  Consumer<NotificationCountViewModel>(
                    builder: (context, countViewModel, _) {
                      return GestureDetector(
                        onTap: () {
                          debugPrint('🔔 Notification tapped');
                          debugPrint('Count: ${countViewModel.notificationCount}');
                          Navigator.pushNamed(context, RoutesName.notificationsListScreen);
                        },
                        child: Stack(
                          children: [
                            _buildIconButton(svgAsset: 'assets/images/home/notification.svg', context: context),

                            // Badge showing count from notificationCount event
                            if (countViewModel.hasNotifications)
                              Positioned(
                                right: 0,
                                top: 2,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: AppColors.containerBackground(context), width: 1),
                                  ),
                                  constraints: BoxConstraints(minWidth: 14, minHeight: 14),
                                  child: Text(
                                    '${countViewModel.notificationCount > 9 ? '9+' : countViewModel.notificationCount}',
                                    style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  void _handleSeeAllNavigation(BuildContext context) {
    if (selectedStoreType == null) {
      debugPrint('No store type selected');
      return;
    }

    // Prepare common arguments
    Map<String, dynamic> arguments = {
      'storeType': selectedStoreType,
    };

    if (selectedStoreType == 'Retail') {
      // Add Retail-specific data
      arguments.addAll({
        'stores': nearbyStores,
        'storeTypes': storeTypes,
        'currentPosition': _currentPosition,
        'currentAddress': _currentAddress,
      });
    } else if (selectedStoreType == 'Premium House Keeper' ||
        selectedStoreType == 'Premium Home Beauty & Salon') {
      // Get customer data from profile for premium services
      final profileViewModel = Provider.of<ProfileViewViewModel>(context, listen: false);

      String customerName = '';
      String customerPhone = '';
      String customerAddress = '';

      if (profileViewModel.profileviewUserData.status == Status.COMPLETED) {
        final userData = profileViewModel.profileviewUserData.data?.data;

        if (userData?.user?.fullName != null) {
          customerName = userData!.user!.fullName!;
        }
        if (userData?.user?.phone != null) {
          customerPhone = userData!.user!.phone!;
        }
        if (userData?.addresses?.fullAddress != null) {
          customerAddress = userData!.addresses!.fullAddress!;
        }
      }

      // Add Premium service-specific data
      arguments.addAll({
        'isCheckingCoverage': isCheckingCoverage,
        'isInsideServiceArea': isInsideServiceArea,
        'customerName': customerName,
        'customerPhone': customerPhone,
        'customerAddress': customerAddress,
      });
    }

    // Navigate to unified screen
    Navigator.pushNamed(
      context,
      RoutesName.unifiedSeeAllScreen,
      arguments: arguments,
    );
  }
  Widget _buildIconButton({VoidCallback? onTap, required String svgAsset, required BuildContext context}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 30,
        width: 30,
        padding: const EdgeInsets.all(2),
        color: Colors.transparent,
        child: SvgPicture.asset(svgAsset, color: AppColors.textPrimary(context), fit: BoxFit.contain),
      ),
    );
  }
}
