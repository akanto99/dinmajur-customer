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
import 'package:dinmajur_customer/configs/utils/utils.dart';
import 'package:dinmajur_customer/configs/widgets/dynamic_dropdown.dart';
import 'package:dinmajur_customer/data/response/status.dart';
import 'package:dinmajur_customer/l10n/app_localizations.dart';
import 'package:dinmajur_customer/socket_connection_model/screens_sockets/home_sceens_socket/get_all_orders_socket/socket_get_all_order_retailer.dart';
import 'package:dinmajur_customer/socket_connection_model/socket_provider_services/socket_provider.dart';
import 'package:dinmajur_customer/view/screens/home/socket_get_all_order_screen/socket_getall_order/socket_getall_order_section.dart';
import 'package:dinmajur_customer/view_model/homeview_model/location_view_model/newlocation_view_model.dart';
import 'package:dinmajur_customer/view_model/homeview_model/nearby_retailers_view_models/nearby_retailers_view_model.dart';
import 'package:dinmajur_customer/view_model/homeview_model/profileview_model/profileview_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
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
  String? _shortAddress;
  bool _isLoadingLocation = false;

  late Map<String, String> storeTypes;

  // Key for SharedPreferences to track if location has been posted
  static const String _locationPostedKey = 'location_posted_once';

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


      /// SOCKET.IO
      // Future.delayed(Duration(milliseconds: 1500), () {
      //   if (mounted) {
      //     final socketProvider = Provider.of<SocketProvider>(context, listen: false);
      //     final orderSocketProvider = Provider.of<OrderSocketProvider>(context, listen: false);
      //
      //     // Initialize with automatic retry logic
      //     orderSocketProvider.initializeWithRetry(socketProvider);
      //   }
      // });


    });

    _checkAndGetLocation();
  }

  String _locationMessage = "Location not fetched yet.";

  // Check if location has already been posted, if not, get and post it
  Future<void> _checkAndGetLocation() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool locationAlreadyPosted = prefs.getBool(_locationPostedKey) ?? false;

    if (!locationAlreadyPosted) {
      // Location has not been posted yet, proceed to get location
      await _getLocationWithAddress();
    } else {
      // Location already posted, skip location fetch
      debugPrint('Location already posted. Skipping location fetch.');
    }
  }

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

        // Post location to API (only once)
        await _postLocationToApi(position.longitude, position.latitude, fullAddress);

        // Mark location as posted
        await _markLocationAsPosted();

        // Refresh profile to get updated address from API
        final profileViewModel = Provider.of<ProfileViewViewModel>(context, listen: false);
        await profileViewModel.fetchProfileViewUserDataApi();
      }
    } catch (e) {
      debugPrint('Error getting location with address: $e');
      if (mounted) {
        setState(() {
          _locationMessage = "Please enable location to use this app.";
          _isLoadingLocation = false;
        });

        // Show error message to user
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Location error: ${e.toString()}'), backgroundColor: Colors.red, duration: Duration(seconds: 3)));
      }
    }
  }

  // Mark that location has been posted successfully
  Future<void> _markLocationAsPosted() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_locationPostedKey, true);
    debugPrint('Location marked as posted. Will not fetch again on next app open.');
  }

  // Method to post location data to API
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
      debugPrint('Location data to post: $locationData');
      debugPrint('Location posted successfully to API');
    } catch (e) {
      debugPrint('Error posting location to API: $e');
      // Optional: Show error message to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to save location: ${e.toString()}'), backgroundColor: Colors.orange, duration: Duration(seconds: 3)));
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

        if (addressData?.geoLocation?.coordinates != null &&
            addressData!.geoLocation!.coordinates!.length >= 2) {
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
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Location not available. Please enable location services.'),
                backgroundColor: Colors.orange,
                duration: Duration(seconds: 3),
              ),
            );
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
            "coordinates": [customerLng, customerLat]
          },
          "fullAddress": fullAddress ?? ""
        },
        "businessType": businessType,
      };

      List<dynamic>? stores = await viewModel.nearbyRetailersPostApi(context, requestData);

      if (mounted) {
        if (stores != null && stores.isNotEmpty) {
          setState(() => nearbyStores = stores);
        } else {
          Utils.snackBar("No nearby stores found for this business type.", context);
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




  // @override
  // void dispose() {
  //   try {
  //     final orderSocketProvider = Provider.of<OrderSocketProvider>(context, listen: false);
  //     orderSocketProvider.cleanupListener();
  //   } catch (e) {
  //     if (kDebugMode) {
  //       print('🏠 HomeScreen: Dispose error - $e');
  //     }
  //   }
  //   super.dispose();
  // }


  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

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
        child: ResPonsiveUi(mobile: body(context), desktop: body(context), tablet: body(context)),
      ),
    );
  }
  Widget body(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return SingleChildScrollView(
      child: Column(
        children: [
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

          /// Loading indicator
          if (isLoadingStores)
            Container(
              width: screenWidth * 0.9,
              padding: EdgeInsets.all(screenHeight * 0.04),
              child: Column(
                children: [
                  Text("Fetching nearby stores...",
                    style: AppTextStyles.textSize16(context,
                        weight: FontWeight.w400,
                        color: AppColors.subtitle(context)
                    ),
                  ),
                ],
              ),
            ),

          // Show stores list only when not loading and stores are available
          if (!isLoadingStores && nearbyStores.isNotEmpty)
            Container(
              width: screenWidth * 0.9,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                          AppLocalizations.of(context)!.nearby_stores(nearbyStores.length),
                          style: AppTextStyles.textSize18(context, weight: FontWeight.w500)
                      ),
                      GestureDetector(
                        onTap: () {},
                        child: Text(
                            AppLocalizations.of(context)!.see_all,
                            style: AppTextStyles.textSize14(context, weight: FontWeight.w400)
                        ),
                      ),
                    ],
                  ),
                  Divider(height: 1, color: AppColors.border(context)),
                ],
              ),
            ),

          if (!isLoadingStores && nearbyStores.isNotEmpty)
            SizedboxSpaccing.height02(context),

          if (!isLoadingStores && nearbyStores.isNotEmpty)
            _buildStoresList(),

          SizedboxSpaccing.height02(context),
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

    final distanceData = store['distance'] as Map<String, dynamic>?;
    final distanceText = distanceData?['text'] ?? '0 m';
    final fullAddress = store['fullAddress'] ?? 'Address not found'; // CORRECT
    final status = store['status'];

    // Extract duration
    final durationData = store['duration'] as Map<String, dynamic>?;
    final durationText = durationData?['text'] ?? '0 min';

    final businessName = store['businessName'] ?? 'দোকানের নাম উপলব্ধ নেই';
    final businessType = store['businessType'] ?? 'অজানা';
    final userID = store['userId'] ?? '';
    final logo = store['logo'] as Map<String, dynamic>?;
    final logoUrl = logo?['url'];

    // CORRECT: Extract store coordinates
    final geoLocation = store['geoLocation'] as Map<String, dynamic>?;
    final coordinates = geoLocation?['coordinates'] as List?;
    final storeLatitude = coordinates != null && coordinates.length >= 2 ? coordinates[1] : null;
    final storeLongitude = coordinates != null && coordinates.length >= 2 ? coordinates[0] : null;

    return Container(
      width: screenWidth * 0.9,
      margin: EdgeInsets.only(bottom: screenHeight * 0.02),
      padding: EdgeInsets.all(screenHeight * 0.02),
      decoration: BoxDecoration(
        color: AppColors.containerBackground(context),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(width: 1, color: AppColors.oceanGreenColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    if (logoUrl != null)
                      Container(
                        height: 40,
                        width: 40,
                        margin: EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          image: DecorationImage(
                            image: NetworkImage(logoUrl),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                businessName,
                                style: AppTextStyles.textSize18(context, weight: FontWeight.w500,color: AppColors.button(context)),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Container(
                                height: 24,
                                width: 75,
                                decoration: BoxDecoration(
                                  color:status=="Available"? AppColors.oceanGreenColor : AppColors.darkRedColor,
                                  borderRadius: BorderRadius.circular(100),),
                                child: Center(
                                  child: Text(status,
                                    style: AppTextStyles.textSize10(context, color: AppColors.whiteColor, weight: FontWeight.w400),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Text(
                            storeTypes[businessType] ?? businessType,
                            style: AppTextStyles.textSize14(context, weight: FontWeight.w400, color: AppColors.subtitle(context)),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            ],
          ),
          SizedboxSpaccing.height01(context),
          Divider(height: 1,color: AppColors.border(context),),

          SizedboxSpaccing.height005(context),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 20,
                width: 12,
                alignment: Alignment.centerLeft,
                child: Icon(Icons.location_on, size: 16, color: AppColors.button(context)),
              ),
              SizedboxSpaccing.width03(context),
             Expanded(
               child: Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                   Text("Store Address",
                     style: AppTextStyles.textSize14(context, weight: FontWeight.w500, color: AppColors.button(context)),
                   ),
                   Text(
                     fullAddress,
                     style: AppTextStyles.textSize14(context, weight: FontWeight.w400, color: AppColors.subtitle(context)),
                     maxLines: 2,
                     overflow: TextOverflow.ellipsis,
                   ),
                   Row(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                       Container(
                         height: 20,
                         width: 12,
                         alignment: Alignment.centerLeft,
                         child: Icon(FontAwesomeIcons.car, size: 12, color: AppColors.textPrimary(context)),
                       ),
                       SizedboxSpaccing.width02(context),
                       Container(
                         child: Text(
                           distanceText,
                           style: AppTextStyles.textSize14(context, weight: FontWeight.w400, color: AppColors.button(context)),
                         ),
                       ),
                     ],
                   ),
                 ],
               ),
             )
            ],
          ),
          SizedboxSpaccing.height02(context),
          RoundButton(
            title: AppLocalizations.of(context)!.order_now,
            onPress: () {
              final profileViewModel = Provider.of<ProfileViewViewModel>(context, listen: false);

              double? customerLongitude;
              double? customerLatitude;
              String? customerFullAddress;
              // Map<String, dynamic>? customerGeoLocation;

              // Extract customer location from profile
              if (profileViewModel.profileviewUserData.status == Status.COMPLETED) {
                final addressData = profileViewModel.profileviewUserData.data?.data?.addresses;

                if (addressData?.geoLocation?.coordinates != null &&
                    addressData!.geoLocation!.coordinates!.length >= 2) {
                  customerLongitude = addressData.geoLocation!.coordinates![0];
                  customerLatitude = addressData.geoLocation!.coordinates![1];
                  customerFullAddress = addressData.fullAddress;
                }
              }

              // Fallback to current position if profile doesn't have address
              if (customerLongitude == null || customerLatitude == null) {
                if (_currentPosition != null) {
                  customerLongitude = _currentPosition!.longitude;
                  customerLatitude = _currentPosition!.latitude;
                  customerFullAddress = _currentAddress ?? "Current Location";
                }
              }

              Navigator.pushNamed(
                context,
                RoutesName.orderNow,
                arguments: {
                  // Store data
                  'storeData': store,
                  'retailer': store,
                  'distanceText': distanceText,
                  'durationText': durationText,
                  'businessName': businessName,
                  'status': status,
                  'businessType': businessType,
                  'selectedStoreType': selectedStoreType,
                  'userID': userID,
                  'logoUrl': logoUrl,
                  'storeFullAddress': fullAddress,
                  'storeLatitude': storeLatitude,
                  'storeLongitude': storeLongitude,

                  // Customer/User location data
                  'customerFullAddress': customerFullAddress,
                  'customerLongitude': customerLongitude,
                  'customerLatitude': customerLatitude,
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

    return Consumer<ProfileViewViewModel>(
      builder: (context, profileViewModel, _) {
        // Determine display address with priority logic
        String displayAddress;

        if (_isLoadingLocation) {
          // While fetching location, show loading message
          displayAddress = "Getting location...";
        } else if (profileViewModel.profileviewUserData.status == Status.COMPLETED) {
          // API completed - check if address exists in API
          final responseData = profileViewModel.profileviewUserData.data;

          // FIXED: Check if addresses object exists and has data
          if (responseData?.data?.addresses != null) {
            final addressData = responseData!.data!.addresses!;

            // Check if the address type is DELIVERY_ADDRESS and has fullAddress
            if (addressData.type == 'DELIVERY_ADDRESS' && addressData.fullAddress != null && addressData.fullAddress!.isNotEmpty) {
              displayAddress = addressData.fullAddress!;
            } else if (addressData.fullAddress != null && addressData.fullAddress!.isNotEmpty) {
              // Use any address if available
              displayAddress = addressData.fullAddress!;
            } else if (_currentAddress != null && _currentAddress!.isNotEmpty) {
              // Fallback to locally fetched address
              displayAddress = _currentAddress!;
            } else {
              displayAddress = "Tap to set location";
            }
          } else if (_currentAddress != null && _currentAddress!.isNotEmpty) {
            // API has no address yet, but we have fetched location - show it
            displayAddress = _currentAddress!;
          } else {
            displayAddress = "Tap to set location";
          }
        } else if (_currentAddress != null && _currentAddress!.isNotEmpty) {
          // API not completed yet but we have fetched location - show it immediately
          displayAddress = _currentAddress!;
        } else {
          displayAddress = "Tap to set location";
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

              // Handle user name properly - check for both null and empty strings
              final fullName = userData.fullName?.trim();

              if (fullName != null && fullName.isNotEmpty) {
                userName = '$fullName';
              }
              // If all are null or empty, userName remains 'Unknown User'
            }

            return _buildAppBarContent(screenWidth: screenWidth, screenHeight: screenHeight, userName: userName, displayAddress: displayAddress, profileImageUrl: profileImageUrl);

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

  Widget _buildAppBarContent({required double screenWidth, required double screenHeight, required String userName, required String displayAddress, String? profileImageUrl}) {
    return Container(
      height: 60,
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
              // Left Side - User Profile
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
                          height: 48,
                          width: 48,
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
                                Icon(Icons.location_on, size: 16, color: _isLoadingLocation ? AppColors.subtitle(context) : AppColors.textPrimary(context)),
                                Expanded(
                                  child: Text(
                                    displayAddress,
                                    style: AppTextStyles.textSize14(context, weight: FontWeight.w400, color: _isLoadingLocation ? AppColors.subtitle(context) : AppColors.textPrimary(context)),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(height: 45, alignment: Alignment.bottomCenter, child: Icon(Icons.arrow_drop_down_sharp, size: 25)),
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
