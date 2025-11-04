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
import 'package:dinmajur_customer/view_model/homeview_model/location_view_model/newlocation_view_model.dart';
import 'package:dinmajur_customer/view_model/homeview_model/nearby_retailers_and_order_view_models/nearby_retailers_view_model.dart';
import 'package:dinmajur_customer/view_model/homeview_model/profileview_model/profileview_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dorpdown_categories_selections_and_views/grocery/grocery_sction_widget.dart';
import 'dorpdown_categories_selections_and_views/premium_house_keeper/premium_house_keeper_widget.dart';

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

  // Key for SharedPreferences to track if location has been posted
  static const String _locationPostedKey = 'location_posted_once';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    storeTypes = {
      // 'Retail': AppLocalizations.of(context)!.storeType_retail,
      'Retail': AppLocalizations.of(context)!.storeType_grocery,
      'Premium House Keeper': AppLocalizations.of(context)!.storeType_housekeeper,
      // 'restaurant': AppLocalizations.of(context)!.storeType_restaurant,
      // 'pharmacy': AppLocalizations.of(context)!.storeType_pharmacy,
      // 'electronics': AppLocalizations.of(context)!.storeType_electronics,
      // 'clothing': AppLocalizations.of(context)!.storeType_clothing,
    };
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profileViewModel = Provider.of<ProfileViewViewModel>(context, listen: false);
      profileViewModel.fetchProfileViewUserDataApi();
    });

    _checkAndGetLocation();
  }

  // Check if location has already been posted, if not, get and post it
  Future<void> _checkAndGetLocation() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool locationAlreadyPosted = prefs.getBool(_locationPostedKey) ?? false;

    if (!locationAlreadyPosted) {
      await _getLocationWithAddress();
    } else {
      debugPrint('Location already posted. Skipping location fetch.');
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
      debugPrint('Error getting location with address: $e');
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
      debugPrint('Error posting location to API: $e');
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
            ).showSnackBar(const SnackBar(content: Text('Location not available. Please enable location services.'), backgroundColor: Colors.orange, duration: Duration(seconds: 3)));
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
                  nearbyStores = []; // Clear previous stores
                });

                if (newValue != null) {
                  debugPrint('Selected store type: $newValue');

                  // Only fetch nearby retailers for "Retail" type
                  if (newValue == 'Retail') {
                    _fetchNearbyRetailers(newValue);
                  }
                  // For Premium House Keeper, we don't fetch retailers
                }
              },
              valueToBengaliMap: storeTypes,
            ),
          ),
          SizedboxSpaccing.height02(context),

          // Conditionally show either Grocery Stores or Premium House Keeper
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
            PremiumHouseKeeperSection(),

          SizedboxSpaccing.height02(context),
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
              displayAddress = "Tap to set location";
            }
          } else if (_currentAddress != null && _currentAddress!.isNotEmpty) {
            displayAddress = _currentAddress!;
          } else {
            displayAddress = "Tap to set location";
          }
        } else if (_currentAddress != null && _currentAddress!.isNotEmpty) {
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
