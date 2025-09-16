import 'package:dinmajur_customer/configs/buttons/round_button.dart';
import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/components/drawer.dart';
import 'package:dinmajur_customer/configs/res/components/exception_errorstate/exception_errorstate.dart';
import 'package:dinmajur_customer/configs/res/components/notifications/resuable_notifications.dart';
import 'package:dinmajur_customer/configs/res/sizedbox_spaccing.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:dinmajur_customer/configs/responsive/responsive_ui.dart';
import 'package:dinmajur_customer/configs/services/location_services/location_getting.dart';
import 'package:dinmajur_customer/configs/utils/routes/routes_name.dart';
import 'package:dinmajur_customer/configs/widgets/dynamic_dropdown.dart';
import 'package:dinmajur_customer/data/response/status.dart';
import 'package:dinmajur_customer/l10n/app_localizations.dart';
import 'package:dinmajur_customer/view_model/homeview_model/location_view_model/post_newlocation_view_model.dart';
import 'package:dinmajur_customer/view_model/homeview_model/nearby_retailers_view_models/nearby_retailers_view_model.dart';
import 'package:dinmajur_customer/view_model/homeview_model/profileview_model/profileview_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

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
  // Location related variables
  final LocationService _locationService = LocationService();
  Position? _currentPosition;
  String? _currentAddress;
  String? _shortAddress;
  bool _isLoadingLocation = false;


  late Map<String, String> storeTypes;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    storeTypes = {
      'Retail': AppLocalizations.of(context)!.storeType_retail,
      'grocery': AppLocalizations.of(context)!.storeType_grocery,
      'restaurant': AppLocalizations.of(context)!.storeType_restaurant,
      'pharmacy': AppLocalizations.of(context)!.storeType_pharmacy,
      'electronics': AppLocalizations.of(context)!.storeType_electronics,
      'clothing': AppLocalizations.of(context)!.storeType_clothing,
    };
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profileViewModel = Provider.of<ProfileViewViewModel>(context, listen: false);
      profileViewModel.fetchProfileViewUserDataApi();
    });

    _getLocationWithAddress();
  }
  String _locationMessage = "Location not fetched yet.";

  Future<void> _getLocationWithAddress() async {
    if (!mounted) return;
    setState(() {
      _isLoadingLocation = true;
    });

    try {
      // Get location and address
      Map<String, dynamic> locationData = await _locationService.getCurrentLocationWithAddress();
      Position position = locationData['position'];
      String fullAddress = locationData['address'];
      // Get short address for app bar
      String shortAddr = await _locationService.getShortAddress(position.latitude, position.longitude);

      if (mounted) {
        setState(() {
          _currentPosition = position;
          _currentAddress = fullAddress;
          _shortAddress = shortAddr;
          _locationMessage = "Latitude: ${position.latitude}, Longitude: ${position.longitude}";
          _isLoadingLocation = false;
        });

        // Print detailed location info in terminal
        debugPrint('========== CURRENT LOCATION WITH ADDRESS ==========');
        debugPrint('Latitude: ${position.latitude}');
        debugPrint('Longitude: ${position.longitude}');
        debugPrint('Full Address: $fullAddress');
        debugPrint('Short Address: $shortAddr');
        debugPrint('Accuracy: ${position.accuracy} meters');
        debugPrint('Altitude: ${position.altitude} meters');
        debugPrint('Timestamp: ${position.timestamp}');
        debugPrint('==================================================');

        // *** AUTOMATICALLY POST LOCATION TO API ***
        await _postLocationToApi(position.longitude, position.latitude, fullAddress);
      }
    } catch (e) {
      debugPrint('Error getting location with address: $e');
      if (mounted) {
        setState(() {
          _locationMessage = "Please enable location to use this app.";
          _isLoadingLocation = false;
        });

        // Show error message to user
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Location error: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  // New method to post location data to API
  Future<void> _postLocationToApi(double longitude, double latitude, String fullAddress) async {
    try {
      final locationData = {
        "geoLocation": {
          "type": "Point",
          "coordinates": [longitude, latitude]
        },
        "fullAddress": fullAddress
      };
      final addLocationViewModel = Provider.of<AddLocationViewModel>(context, listen: false);
      await addLocationViewModel.addLocationPostApi(context, locationData);
      debugPrint('Location data to post: $locationData');
      // debugPrint('Location posted successfully to API');
    } catch (e) {
      debugPrint('Error posting location to API: $e');
      // Optional: Show error message to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save location: ${e.toString()}'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  // Method to fetch nearby retailers
  Future<void> _fetchNearbyRetailers(String businessType) async {
    if (!mounted) return;

    debugPrint('Starting to fetch retailers for: $businessType');

    setState(() {
      isLoadingStores = true;
      nearbyStores = [];
    });

    try {
      final viewModel = Provider.of<PostNearbyRetailersViewModel>(context, listen: false);

      final requestData = {"customer_lng": 90.2484202, "customer_lat": 24.0089881, "businessType": businessType};
      debugPrint('Request data: $requestData');

      // Call the API and get the response
      List<dynamic>? stores = await viewModel.nearbyRetailersPostApi(context, requestData);

      debugPrint('Received stores from API: $stores');
      debugPrint('Stores count: ${stores?.length ?? 0}');

      if (mounted && stores != null) {
        setState(() {
          nearbyStores = stores;
        });
        debugPrint('Updated nearbyStores in state: ${nearbyStores.length}');
      }
    } catch (e) {
      debugPrint('Error fetching nearby retailers: $e');
    } finally {
      if (mounted) {
        setState(() {
          isLoadingStores = false;
        });
        debugPrint('Loading finished. Final nearbyStores count: ${nearbyStores.length}');
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    // Only print in debug mode
    debugPrint('Current locale: ${Localizations.localeOf(context)}');
    debugPrint('Current nearbyStores length: ${nearbyStores.length}');
    debugPrint('Is loading: $isLoadingStores');
    debugPrint('Selected store type: $selectedStoreType');

    return Scaffold(
      key: widget.scaffoldKey,
      backgroundColor: AppColors.containerBackground(context),
      drawer: CustomDrawer(screenHeight: screenHeight, screenWidth: screenWidth),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: Container(
          color: AppColors.containerBackground(context),
          child: Center(child: _customAppBar(context)),
        ),
      ),
      body: SafeArea(
        child: ResPonsiveUi(mobile: _buildBody(context), desktop: _buildBody(context), tablet: _buildBody(context)),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return SingleChildScrollView(
      child: Column(
        children: [
          // if (_isLoadingLocation)
          //   Text(
          //     'Getting your location and address...',
          //     style: AppTextStyles.textSize14(context, color: Colors.blue.shade700),
          //   ),
          //
          // // Show current location and address if available
          // if (_currentPosition != null && _currentAddress != null && !_isLoadingLocation)
          //   Container(
          //     width: screenWidth * 0.9,
          //     padding: EdgeInsets.all(screenHeight * 0.015),
          //     margin: EdgeInsets.only(bottom: screenHeight * 0.02),
          //     decoration: BoxDecoration(
          //       color: Colors.green.shade50,
          //       borderRadius: BorderRadius.circular(12),
          //       border: Border.all(color: Colors.green.shade200),
          //     ),
          //     child: Column(
          //       crossAxisAlignment: CrossAxisAlignment.start,
          //       children: [
          //         Row(
          //           children: [
          //             Icon(Icons.location_on, color: Colors.green.shade700, size: 16),
          //             SizedboxSpaccing.width01(context),
          //             Expanded(
          //               child: Text(
          //                 'Current Location',
          //                 style: AppTextStyles.textSize14(context,
          //                     color: Colors.green.shade700,
          //                     weight: FontWeight.w600),
          //               ),
          //             ),
          //             GestureDetector(
          //               onTap: () => _getLocationWithAddress(),
          //               child: Icon(Icons.refresh, color: Colors.green.shade700, size: 16),
          //             ),
          //           ],
          //         ),
          //         SizedboxSpaccing.height005(context),
          //         Text(
          //           _currentAddress!,
          //           style: AppTextStyles.textSize12(context, color: Colors.green.shade600),
          //           maxLines: 2,
          //           overflow: TextOverflow.ellipsis,
          //         ),
          //         SizedboxSpaccing.height005(context),
          //         Text(
          //           'Coordinates: ${_currentPosition!.latitude.toStringAsFixed(6)}, ${_currentPosition!.longitude.toStringAsFixed(6)}',
          //           style: AppTextStyles.textSize16(context, color: Colors.green.shade500),
          //         ),
          //       ],
          //     ),
          //   ),

          // Language Slide Switcher
          Center(child: SizedboxSpaccing.height02(context)),

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
                });

                // Fetch nearby retailers when selection changes
                if (newValue != null) {
                  debugPrint('Selected store type: $newValue');
                  _fetchNearbyRetailers(newValue);
                }
              },
              valueToBengaliMap: storeTypes,
            ),
          ),

          SizedboxSpaccing.height02(context),

          if (nearbyStores.isNotEmpty)
            Container(
              width: screenWidth * 0.9,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(AppLocalizations.of(context)!.nearby_stores(nearbyStores.length), style: AppTextStyles.textSize18(context, weight: FontWeight.w500)),
                      GestureDetector(
                        onTap: () {},
                        child: Text(AppLocalizations.of(context)!.see_all, style: AppTextStyles.textSize14(context, weight: FontWeight.w400)),
                      ),
                    ],
                  ),

                  Divider(height: 1, color: AppColors.border(context)),
                ],
              ),
            ),
          SizedboxSpaccing.height02(context),
          _buildStoresList(),
        ],
      ),
    );
  }

  Widget _buildStoresList() {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      width: screenWidth * 0.9,
      child: ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: nearbyStores.length,
        itemBuilder: (context, index) {
          final store = nearbyStores[index];
          return _buildStoreCard(store, screenHeight, screenWidth);
        },
      ),
    );
  }

  Widget _buildStoreCard(Map<String, dynamic> store, double screenHeight, double screenWidth) {
    debugPrint('Building store card for: $store');

    final retailer = store['retailer'] ?? {};
    final distance = store['distance']?.toDouble() ?? 0.0;
    final address = store['fullAddress'] ?? 'ঠিকানা উপলব্ধ নেই';
    final businessName = retailer['businessName'] ?? 'দোকানের নাম উপলব্ধ নেই';
    final businessType = retailer['businessType'] ?? 'অজানা';
    final userID = store['userId'] ?? '';

    debugPrint('Store details - Name: $businessName, Distance: $distance, Address: $address');

    return Container(
      width: screenWidth * 0.9,
      padding: EdgeInsets.all(screenHeight * 0.02),
      decoration: BoxDecoration(
        color: AppColors.containerBackground(context),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(width: 1, color: AppColors.border(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  businessName,
                  style: AppTextStyles.textSize18(context, weight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Row(
                children: [
                  Icon(Icons.check_circle, size: 16, color: Colors.green),
                  SizedboxSpaccing.width01(context),
                  Text(
                    AppLocalizations.of(context)!.available,
                    style: AppTextStyles.textSize14(context, color: Colors.green, weight: FontWeight.w400),
                  ),
                ],
              ),
            ],
          ),
          Text(
            storeTypes[address] ?? address,
            style: AppTextStyles.textSize14(context, weight: FontWeight.w400, color: AppColors.subtitle(context)),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedboxSpaccing.height005(context),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 20,
                width: 12,
                // color: Colors.red,
                alignment: Alignment.centerLeft,
                child: Icon(Icons.location_on, size: 12, color: AppColors.textPrimary(context)),
              ),
              SizedboxSpaccing.width01(context),
              Text(
                AppLocalizations.of(context)!.distance_away(distance.toStringAsFixed(0)),
                style: AppTextStyles.textSize14(context, weight: FontWeight.w400, color: AppColors.subtitle(context)),
              ),
            ],
          ),
          SizedboxSpaccing.height01(context),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 20,
                width: 12,
                // color: Colors.red,
                alignment: Alignment.centerLeft,
                child: Icon(Icons.access_time_filled, size: 12, color: AppColors.textPrimary(context)),
              ),
              SizedboxSpaccing.width01(context),
              Container(
                // height: 20,
                // color: Colors.red,
                child: Text(
                  AppLocalizations.of(context)!.delivery_time,
                  style: AppTextStyles.textSize14(context, weight: FontWeight.w400, color: AppColors.subtitle(context)),
                ),
              ),
            ],
          ),
          SizedboxSpaccing.height02(context),
          RoundButton(
            title: AppLocalizations.of(context)!.order_now,
            onPress: () {
              Navigator.pushNamed(
                context,
                RoutesName.orderNow,
                arguments: {
                  'storeData': store,
                  'retailer': retailer,
                  'distance': distance,
                  'address': address,
                  'businessName': businessName,
                  'businessType': businessType,
                  'selectedStoreType': selectedStoreType,
                  'userID': userID,
                },
              );
            },
            iconData: Icons.arrow_forward_ios_rounded,
          ),
        ],
      ),
    );
  }

  Widget _customAppBar(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Determine display address ONCE at the top
    String displayAddress;
    if (_isLoadingLocation) {
      displayAddress = "Getting location...";
    } else if (_currentAddress != null && _currentAddress!.isNotEmpty) {
      displayAddress = _currentAddress!;
    } else if (_currentAddress != null && _currentAddress!.isNotEmpty) {
      displayAddress = _currentAddress!;
    } else {
      displayAddress = "Tap to get location";
    }

    return Consumer<ProfileViewViewModel>(
      builder: (context, profileViewModel, _) {
        switch (profileViewModel.profileviewUserData.status) {
          case Status.LOADING:
            return Container(
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.border(context), width: 1.0)),
              ),
              child: Center(
                child: Container(
                  width: screenWidth * 0.9,
                  padding: EdgeInsets.symmetric(vertical: screenHeight * 0.01),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Left Side - User Profile (Loading State)
                      Flexible(
                        flex: 3,
                        child: Row(
                          children: [
                            Builder(
                              builder: (context) => GestureDetector(
                                onTap: () {
                                  Scaffold.of(context).openDrawer();
                                },
                                child: Container(
                                  height: 48,
                                  width: 48,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.appBackground(context),
                                    border: Border.all(width: 1, color: AppColors.textPrimary(context)),
                                  ),
                                  child: Icon(Icons.person, color: AppColors.textPrimary(context), size: 20),
                                ),
                              ),
                            ),
                            SizedboxSpaccing.width02(context),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Unknown User",
                                    style: AppTextStyles.textSize18(context, weight: FontWeight.w600),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Row(
                                    children: [
                                      Icon(
                                          Icons.location_on,
                                          size: 16,
                                          color: _isLoadingLocation
                                              ? AppColors.subtitle(context)
                                              : AppColors.textPrimary(context)
                                      ),
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: _isLoadingLocation ? null : () {
                                            _getLocationWithAddress();
                                          },
                                          child: Text(
                                            displayAddress,
                                            style: AppTextStyles.textSize14(
                                                context,
                                                weight: FontWeight.w400,
                                                color: _isLoadingLocation
                                                    ? AppColors.subtitle(context)
                                                    : AppColors.textPrimary(context)
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Right Side Icons
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
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
                          _buildIconButton(
                            onTap: () {
                              NotificationDialog.show(
                                context,
                                message: AppLocalizations.of(context)!.no_notification,
                                icon: Icons.notifications_outlined,
                                iconColor: AppColors.textPrimary(context),
                                iconBackgroundColor: AppColors.appBackground(context),
                              );
                            },
                            svgAsset: 'assets/images/home/notification.svg',
                            context: context,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );

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
            if (responseData?.data?.user == null) {
              return Container(
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: AppColors.border(context), width: 1.0)),
                ),
                child: Center(
                  child: Container(
                    width: screenWidth * 0.9,
                    padding: EdgeInsets.symmetric(vertical: screenHeight * 0.01),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          flex: 3,
                          child: Row(
                            children: [
                              Builder(
                                builder: (context) => GestureDetector(
                                  onTap: () {
                                    Scaffold.of(context).openDrawer();
                                  },
                                  child: Container(
                                    height: 48,
                                    width: 48,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppColors.appBackground(context),
                                      border: Border.all(width: 1, color: AppColors.textPrimary(context)),
                                    ),
                                    child: Icon(Icons.person, color: AppColors.textPrimary(context), size: 20),
                                  ),
                                ),
                              ),
                              SizedboxSpaccing.width02(context),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Unknown User",
                                      style: AppTextStyles.textSize18(context, weight: FontWeight.w600),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Row(
                                      children: [
                                        Icon(
                                            Icons.location_on,
                                            size: 16,
                                            color: _isLoadingLocation
                                                ? AppColors.subtitle(context)
                                                : AppColors.textPrimary(context)
                                        ),
                                        Expanded(
                                          child: GestureDetector(
                                            // onTap: _isLoadingLocation ? null : () {
                                            //   _getLocationWithAddress();
                                            // },
                                            child: Text(
                                              displayAddress,
                                              style: AppTextStyles.textSize14(
                                                  context,
                                                  weight: FontWeight.w400,
                                                  color: _isLoadingLocation
                                                      ? AppColors.subtitle(context)
                                                      : AppColors.textPrimary(context)
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),

                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
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
                            _buildIconButton(
                              onTap: () {
                                NotificationDialog.show(
                                  context,
                                  message: AppLocalizations.of(context)!.no_notification,
                                  icon: Icons.notifications_outlined,
                                  iconColor: AppColors.textPrimary(context),
                                  iconBackgroundColor: AppColors.appBackground(context),
                                );
                              },
                              svgAsset: 'assets/images/home/notification.svg',
                              context: context,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            final userData = responseData!.data!.user!;
            String? profileImageUrl = userData.profilePicture?.url;
            String userName = '';

            // Handle user name properly
            if (userData.firstName != null && userData.lastName != null) {
              userName = '${userData.firstName!} ${userData.lastName!}'.trim();
            } else if (userData.firstName != null) {
              userName = userData.firstName!;
            } else if (userData.lastName != null) {
              userName = userData.lastName!;
            } else {
              userName = 'Unknown User';
            }

            return Container(
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.border(context), width: 1.0)),
              ),
              child: Center(
                child: Container(
                  width: screenWidth * 0.9,
                  padding: EdgeInsets.symmetric(vertical: screenHeight * 0.01),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Left Side - User Profile
                      Flexible(
                        flex: 3,
                        child: Row(
                          children: [
                            Builder(
                              builder: (context) => GestureDetector(
                                onTap: () {
                                  Scaffold.of(context).openDrawer();
                                },
                                child: Container(
                                  height: 48,
                                  width: 48,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.appBackground(context),
                                    border: Border.all(width: 1, color: AppColors.textPrimary(context)),
                                    image: profileImageUrl != null
                                        ? DecorationImage(
                                      image: NetworkImage(profileImageUrl),
                                      fit: BoxFit.cover,
                                    )
                                        : null,
                                  ),
                                  child: profileImageUrl == null
                                      ? Icon(Icons.person, color: AppColors.textPrimary(context), size: 20)
                                      : null,
                                ),
                              ),
                            ),
                            SizedboxSpaccing.width02(context),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    userName,
                                    style: AppTextStyles.textSize18(context, weight: FontWeight.w600),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Row(
                                    children: [
                                      Icon(
                                          Icons.location_on,
                                          size: 16,
                                          color: _isLoadingLocation
                                              ? AppColors.subtitle(context)
                                              : AppColors.textPrimary(context)
                                      ),
                                      Expanded(
                                        child: GestureDetector(
                                          // onTap: _isLoadingLocation ? null : () {
                                          //   _getLocationWithAddress();
                                          // },
                                          child: Text(
                                            displayAddress,
                                            style: AppTextStyles.textSize14(
                                                context,
                                                weight: FontWeight.w400,
                                                color: _isLoadingLocation
                                                    ? AppColors.subtitle(context)
                                                    : AppColors.textPrimary(context)
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Right Side Icons
                      Row(
                        children: [
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
                          _buildIconButton(
                            onTap: () {
                              NotificationDialog.show(
                                context,
                                message: AppLocalizations.of(context)!.no_notification,
                                icon: Icons.notifications_outlined,
                                iconColor: AppColors.textPrimary(context),
                                iconBackgroundColor: AppColors.appBackground(context),
                              );
                            },
                            svgAsset: 'assets/images/home/notification.svg',
                            context: context,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );

          default:
            return Container(
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.border(context), width: 1.0)),
              ),
              height: 80,
            );
        }
      },
    );
  }



  Widget _buildIconButton({required VoidCallback onTap, required String svgAsset, required BuildContext context}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 30,
        width: 30,
        padding: const EdgeInsets.all(2),
        child: SvgPicture.asset(svgAsset, color: AppColors.textPrimary(context), fit: BoxFit.contain),
      ),
    );
  }
}
