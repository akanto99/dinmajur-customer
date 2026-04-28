import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/view/screens/home/all_service/widget/api_services_widget.dart';
import 'package:dinmajur_customer/view/screens/home/drawer/drawer.dart';
import 'package:dinmajur_customer/configs/res/components/exception_errorstate/exception_errorstate.dart';
import 'package:dinmajur_customer/configs/res/components/notifications/resuable_notifications.dart';
import 'package:dinmajur_customer/configs/res/sizedbox_spaccing.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:dinmajur_customer/configs/responsive/responsive_ui.dart';
import 'package:dinmajur_customer/configs/services/location_services/location_getting.dart';
import 'package:dinmajur_customer/configs/services/sse_notification_services/sse_notification_and_ordercount/notification_count_view_model.dart';
import 'package:dinmajur_customer/configs/utils/routes/routes_name.dart';
import 'package:dinmajur_customer/data/response/status.dart';
import 'package:dinmajur_customer/l10n/app_localizations.dart';
import 'package:dinmajur_customer/view/screens/home/helper_widgets/banner_widegt/home_banner_widget.dart';
import 'package:dinmajur_customer/view/screens/home/helper_widgets/dynamic_nearestheader_widget.dart';
import 'package:dinmajur_customer/view/screens/home/helper_widgets/nostore_founddialouge_widget.dart';
import 'package:dinmajur_customer/view/screens/home/helper_widgets/show_name_dialouge.dart';
import 'package:dinmajur_customer/view/screens/home/trending_service_widget/trending_service_widget.dart';
import 'package:dinmajur_customer/view_model/homeview_model/all_service_view_models/get_all_service_view_model.dart';
import 'package:dinmajur_customer/view_model/homeview_model/all_service_view_models/services_view_getallcategories_view_model.dart';
import 'package:dinmajur_customer/view_model/homeview_model/banner_view_model/banner_view_model.dart';
import 'package:dinmajur_customer/view_model/homeview_model/profileview_model/profileview_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'dorpdown_categories_selections_and_views/grocery/grocery_sction_widget.dart';
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
  bool _nameDialogShown = false;
  bool _locationFlowStarted = false;

  // Retail (তাৎক্ষণিক বাজার) nearest section
  List<dynamic> nearbyStores = [];
  bool isLoadingStores = false;
  bool _showRetailNearest = false;

  String? _loadingServiceSlug;

  // Location related variables
  final LocationService _locationService = LocationService();
  Position? _currentPosition;
  String? _currentAddress;
  bool _isLoadingLocation = false;

  late Map<String, String> storeTypes;

  static const String _locationPostedKey = 'location_posted_once';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    storeTypes = {
      'Premium House Keeper': AppLocalizations.of(context)!.storeType_housekeeper,
      'Premium Home Beauty & Salon': AppLocalizations.of(context)!.storeType_beauty_salon,
      'Retail': AppLocalizations.of(context)!.storeType_grocery,
      'Family Event Cooking': AppLocalizations.of(context)!.storeType_family_event_cooking,
    };
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profileViewModel = Provider.of<ProfileViewViewModel>(context, listen: false);
      profileViewModel.fetchProfileViewUserDataApi();

      final allServiceViewModel = Provider.of<GetAllServiceViewModel>(context, listen: false);
      allServiceViewModel.fetchGetAllServices();

      final bannerViewModel = Provider.of<BannerViewModel>(context, listen: false);
      bannerViewModel.fetchBannerData();

      final trendingServiceViewModel = Provider.of<ServicesViewGetAllCategoriesViewModel>(context, listen: false);
      trendingServiceViewModel.fetchServicesViewGetAllCategoriesGetApi("69eca7bdbe6d8b46e00655ed");
    });
  }

  Future<void> _handleRefresh() async {
    try {
      debugPrint('🔄 HomeScreen: Pull to refresh triggered');
      final profileViewModel = Provider.of<ProfileViewViewModel>(context, listen: false);
      await profileViewModel.refreshProfileData();
      final allServiceViewModel = Provider.of<GetAllServiceViewModel>(context, listen: false);
      allServiceViewModel.fetchGetAllServices();
      final bannerViewModel = Provider.of<BannerViewModel>(context, listen: false);
      bannerViewModel.fetchBannerData();

      final trendingServiceViewModel = Provider.of<ServicesViewGetAllCategoriesViewModel>(context, listen: false);
      trendingServiceViewModel.fetchServicesViewGetAllCategoriesGetApi("69eca7bdbe6d8b46e00655ed");

      if (_showRetailNearest) {
        await _fetchNearbyRetailers('Retail');
      }
    } catch (e) {
      if (mounted) {
        Utils.flushBarErrorMessage("Refresh failed", context);
      }
    }
  }

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
        await profileViewModel.fetchProfileViewUserDataApi(forceRefresh: true);
      }
    } catch (e) {
      debugPrint('Error getting location with address: $e');
      if (mounted) {
        setState(() {
          _isLoadingLocation = false;
        });
        print(e.toString());
        // Utils.flushBarErrorMessage("Location permission is disabled.\nPlease enable it from your device settings.", context);
      }
    }
  }

  Future<void> _markLocationAsPosted() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_locationPostedKey, true);
    debugPrint('Location marked as posted.');
  }

  String _stripSuffix(String raw) => raw.replaceAll(RegExp(r'\s*(District|Division|Zila|Upazila|Sadar|জেলা|বিভাগ|উপজেলা|সদর)\s*$', caseSensitive: false), '').trim();

  String _normalizeCity(String city) {
    const variants = {'chittagong', 'chattogram', 'chottogram', 'chattagam', 'চট্টগ্রাম', 'চট্টগ্রাম জেলা', 'চট্টগ্রাম বিভাগ'};
    if (variants.contains(city.toLowerCase().trim())) return 'Chittagong';
    return city;
  }

  Future<void> _postLocationToApi(double longitude, double latitude, String fullAddress) async {
    try {
      String city = '';
      String country = '';
      try {
        final placemarks = await placemarkFromCoordinates(latitude, longitude);
        if (placemarks.isNotEmpty) {
          final p = placemarks.first;
          final rawCity = p.subAdministrativeArea?.isNotEmpty == true ? p.subAdministrativeArea! : p.administrativeArea ?? '';
          city = _normalizeCity(_stripSuffix(rawCity));
          country = p.country ?? '';
        }
      } catch (_) {}

      final locationData = {
        "geoLocation": {
          "type": "Point",
          "coordinates": [longitude, latitude],
        },
        "fullAddress": fullAddress,
        "city": city,
        "country": country,
        "type": "DELIVERY_ADDRESS",
      };
      final addLocationViewModel = Provider.of<AddLocationViewModel>(context, listen: false);
      await addLocationViewModel.addLocationPostApi(context, locationData, false);
    } catch (e) {
      debugPrint('Error posting location to API: $e');
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

  /// Called from AllServicesGridWidget when instant-bazar slug is tapped
  Future<void> handleInstantBazarTap() async {
    if (_loadingServiceSlug != null) return;

    if (!_hasValidLocation()) {
      _showLocationRequiredDialog();
      return;
    }

    setState(() {
      _loadingServiceSlug = 'instant-bazar';
      _showRetailNearest = false;
      nearbyStores = [];
    });

    try {
      await _fetchNearbyRetailers('Retail');
      if (!mounted) return;

      if (nearbyStores.isEmpty) {
        NoStoresFoundDialog.show(context);
      } else {
        setState(() => _showRetailNearest = true);
      }
    } finally {
      if (mounted) setState(() => _loadingServiceSlug = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final homeBody = body(context);

    return Scaffold(
      key: widget.scaffoldKey,
      backgroundColor: AppColors.containerBackground(context),
      drawer: CustomDrawer(screenHeight: screenHeight, screenWidth: screenWidth),
      body: SafeArea(
        child: ResPonsiveUi(mobile: homeBody, desktop: homeBody, tablet: homeBody),
      ),
    );
  }

  body(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;

    return RefreshIndicator(
      onRefresh: _handleRefresh,
      color: AppColors.textPrimary(context),
      backgroundColor: AppColors.containerBackground(context),
      displacement: 40,
      strokeWidth: 2.0,
      child: Column(
        children: [
          _customAppBar(context),
          Expanded(
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  SizedboxSpaccing.height025(context),
                  // ── Banner Section ──
                  Consumer<ProfileViewViewModel>(
                    builder: (context, profileViewModel, _) {
                      String customerName = '';
                      String customerPhone = '';
                      String customerAddress = '';
                      Map<String, dynamic>? customerLocation;

                      if (profileViewModel.profileviewUserData.status == Status.COMPLETED) {
                        final userData = profileViewModel.profileviewUserData.data?.data;
                        if (userData?.user?.fullName != null) customerName = userData!.user!.fullName!;
                        if (userData?.user?.phone != null) customerPhone = userData!.user!.phone!;
                        if (userData?.addresses?.fullAddress != null) customerAddress = userData!.addresses!.fullAddress!;
                        final addressData = userData?.addresses;
                        if (addressData != null) {
                          customerLocation = {
                            "fullAddress": addressData.fullAddress ?? '',
                            "country": addressData.country ?? '',
                            "city": addressData.city ?? '',
                            "geoLocation": {
                              "type": addressData.geoLocation?.type ?? "Point",
                              "coordinates": addressData.geoLocation?.coordinates ?? [],
                              "timestamp": DateTime.now().toUtc().toIso8601String(),
                            },
                          };
                        }
                      }

                      return HomeBannerWidget(
                        screenWidth: screenWidth,
                        customerName: customerName,
                        customerPhone: customerPhone,
                        customerAddress: customerAddress,
                        customerLocation: customerLocation,
                        hasValidLocation: _hasValidLocation(),
                        onLocationRequired: _showLocationRequiredDialog,
                        onInstantBazarTap: handleInstantBazarTap,
                        loadingServiceSlug: _loadingServiceSlug,
                      );
                    },
                  ),


                  // ── All Services Grid ──
                  Consumer<ProfileViewViewModel>(
                    builder: (context, profileViewModel, _) {
                      String customerName = '';
                      String customerPhone = '';
                      String customerAddress = '';
                      Map<String, dynamic>? customerLocation;

                      if (profileViewModel.profileviewUserData.status == Status.COMPLETED) {
                        final userData = profileViewModel.profileviewUserData.data?.data;
                        if (userData?.user?.fullName != null) customerName = userData!.user!.fullName!;
                        if (userData?.user?.phone != null) customerPhone = userData!.user!.phone!;
                        if (userData?.addresses?.fullAddress != null) customerAddress = userData!.addresses!.fullAddress!;
                        final addressData = userData?.addresses;
                        if (addressData != null) {
                          customerLocation = {
                            "fullAddress": addressData.fullAddress ?? '',
                            "country": addressData.country ?? '',
                            "city": addressData.city ?? '',
                            "geoLocation": {
                              "type": addressData.geoLocation?.type ?? "Point",
                              "coordinates": addressData.geoLocation?.coordinates ?? [],
                              "timestamp": DateTime.now().toUtc().toIso8601String(),
                            },
                          };
                        }
                      }

                      return SizedBox(
                        width: screenWidth * 0.9,
                        child: AllServicesGridWidget(
                          selectedServiceId: null,
                          customerName: customerName,
                          customerPhone: customerPhone,
                          customerAddress: customerAddress,
                          customerLocation: customerLocation,
                          hasValidLocation: _hasValidLocation(),
                          onLocationRequired: _showLocationRequiredDialog,
                          onInstantBazarTap: handleInstantBazarTap,
                          loadingServiceSlug: _loadingServiceSlug,
                        ),
                      );
                    },
                  ),

                  // ── Retail nearest section (only when stores found) ──
                  if (_showRetailNearest) ...[
                    SizedboxSpaccing.height025(context),
                    DynamicNearestHeader(
                      selectedStoreType: 'Retail',
                      storeCount: nearbyStores.length,
                      screenWidth: screenWidth,
                      isInsideServiceArea: null,
                      onSeeAllTap: () => _handleRetailSeeAll(context),
                    ),
                    SizedboxSpaccing.height025(context),
                    GroceryStoresSection(
                      isLoading: isLoadingStores,
                      stores: nearbyStores,
                      storeTypes: storeTypes,
                      selectedStoreType: 'Retail',
                      currentPosition: _currentPosition,
                      currentAddress: _currentAddress,
                    ),
                  ],
                  TrendingServicesWidget(
                    hasValidLocation: _hasValidLocation(),
                    onLocationRequired: _showLocationRequiredDialog,
                  ),
                  SizedboxSpaccing.height02(context),

                ],
              ),
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
          displayAddress = "Getting location...";
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
              displayAddress = "Tap to set location...";
            }
          } else if (_currentAddress != null && _currentAddress!.isNotEmpty) {
            displayAddress = _currentAddress!;
          } else {
            displayAddress = "Tap to set location...";
          }
        } else if (_currentAddress != null && _currentAddress!.isNotEmpty) {
          displayAddress = _currentAddress!;
        } else {
          displayAddress = "Tap to set location...";
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

            _checkAndShowNameDialog(userName);

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
    bool isAddressMissing = displayAddress == "Tap to set location..." && userName != "Loading...";

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
                                color: Colors.transparent,
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
                                    Text(
                                      displayAddress,
                                      style: AppTextStyles.textSize12(
                                        context,
                                        weight: FontWeight.w400,
                                        color: isAddressMissing ? Colors.red : (_isLoadingLocation ? AppColors.subtitle(context) : AppColors.textPrimary(context)),
                                      ),
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

  void _handleRetailSeeAll(BuildContext context) {
    Navigator.pushNamed(
      context,
      RoutesName.unifiedSeeAllScreen,
      arguments: {'storeType': 'Retail', 'stores': nearbyStores, 'storeTypes': storeTypes, 'currentPosition': _currentPosition, 'currentAddress': _currentAddress},
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
        child: RepaintBoundary(
          child: SvgPicture.asset(svgAsset, color: AppColors.textPrimary(context), fit: BoxFit.contain),
        ),
      ),
    );
  }

  void _checkAndShowNameDialog(String userName) {
    if (!_nameDialogShown && (userName.trim().isEmpty || userName == 'Unknown User')) {
      _nameDialogShown = true;

      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await showNameEntryDialog(context);

        if (mounted && !_locationFlowStarted) {
          _locationFlowStarted = true;
          await _checkAndGetLocation();
        }
      });
    } else {
      if (!_locationFlowStarted) {
        _locationFlowStarted = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _checkAndGetLocation();
        });
      }
    }
  }

  bool _hasValidLocation() {
    final profileViewModel = Provider.of<ProfileViewViewModel>(context, listen: false);

    if (profileViewModel.profileviewUserData.status == Status.COMPLETED) {
      final addressData = profileViewModel.profileviewUserData.data?.data?.addresses;

      if (addressData?.fullAddress != null && addressData!.fullAddress!.isNotEmpty && addressData.fullAddress != "Tap to set location...") {
        return true;
      }
    }

    return false;
  }

  void _showLocationRequiredDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: AppColors.containerBackground(context),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Container(
            padding: EdgeInsets.all(15),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Location Required', style: AppTextStyles.textSize20(context)),
                SizedboxSpaccing.height02(context),
                Text('Please set your delivery location first to view available services.', style: AppTextStyles.textSize14(context)),
                SizedboxSpaccing.height02(context),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
                    SizedboxSpaccing.width02(context),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, RoutesName.addlocation);
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(color: AppColors.button(context), borderRadius: BorderRadius.circular(100)),
                        child: Text('Set Location', style: AppTextStyles.textSize14(context, color: AppColors.whiteColor)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
