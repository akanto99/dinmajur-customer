import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/components/drawer.dart';
import 'package:dinmajur_customer/configs/res/components/exception_errorstate/exception_errorstate.dart';
import 'package:dinmajur_customer/configs/res/components/notifications/resuable_notifications.dart';
import 'package:dinmajur_customer/configs/res/sizedbox_spaccing.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:dinmajur_customer/configs/responsive/responsive_ui.dart';
import 'package:dinmajur_customer/configs/utils/routes/routes_name.dart';
import 'package:dinmajur_customer/configs/widgets/dynamic_dropdown.dart';
import 'package:dinmajur_customer/data/response/status.dart';
import 'package:dinmajur_customer/l10n/app_localizations.dart';
import 'package:dinmajur_customer/view_model/homeview_model/dropdown_categories_selection_view_models/premium_house_keeper_view_model/check_coverage_view_model.dart';
import 'package:dinmajur_customer/view_model/homeview_model/profileview_model/profileview_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'dorpdown_categories_selections_and_views/grocery/grocery_sction_widget.dart';
import 'dorpdown_categories_selections_and_views/premium_house_keeper/premium_house_keeper_widget.dart';
import 'home_notifier.dart'; // Import the notifier

class HomeScreen extends StatefulWidget {
  final GlobalKey<ScaffoldState>? scaffoldKey;
  const HomeScreen({super.key, this.scaffoldKey});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Map<String, String> storeTypes;
  bool _isInitialized = false; // Prevent multiple initializations

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Initialize localized store types
    storeTypes = {
      'Retail': AppLocalizations.of(context)!.storeType_grocery,
      'Premium House Keeper': AppLocalizations.of(context)!.storeType_housekeeper,
    };

    // Initialize notifier only once after dependencies are ready
    if (!_isInitialized) {
      _isInitialized = true;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _initializeScreen();
      });
    }
  }

  @override
  void initState() {
    super.initState();
    // Don't call notifier methods here that need context
    // Use didChangeDependencies or addPostFrameCallback instead
  }

  /// Initialize screen data
  void _initializeScreen() {
    // Initialize HomeNotifier
    final homeNotifier = Provider.of<HomeNotifier>(context, listen: false);
    homeNotifier.initialize(context);

    // Fetch profile data
    final profileViewModel = Provider.of<ProfileViewViewModel>(context, listen: false);
    profileViewModel.fetchProfileViewUserDataApi();
  }

  @override
  void dispose() {
    // Clean up if needed
    super.dispose();
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
        child: ResPonsiveUi(
          mobile: _body(context),
          desktop: _body(context),
          tablet: _body(context),
        ),
      ),
    );
  }

  Widget _body(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Consumer2<HomeNotifier, ProfileViewViewModel>(
      builder: (context, homeNotifier, profileViewModel, _) {
        return RefreshIndicator(
          onRefresh: () => homeNotifier.handleRefresh(context, profileViewModel),
          color: AppColors.textPrimary(context),
          backgroundColor: AppColors.containerBackground(context),
          displacement: 40,
          strokeWidth: 2.0,
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                Center(child: SizedboxSpaccing.height02(context)),

                // Dropdown Container
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
                    selectedItem: homeNotifier.selectedStoreType,
                    hintText: AppLocalizations.of(context)!.select_store_type_hint,
                    onChanged: (String? newValue) {
                      homeNotifier.setSelectedStoreType(newValue);

                      if (newValue != null) {
                        debugPrint('🔄 Selected store type: $newValue');

                        if (newValue == 'Retail') {
                          homeNotifier.fetchNearbyRetailers(
                            context,
                            newValue,
                            profileViewModel,
                          );
                        } else if (newValue == 'Premium House Keeper') {
                          final checkCoverageViewModel = Provider.of<CheckCoverageViewModel>(
                            context,
                            listen: false,
                          );
                          homeNotifier.checkCoverage(context, checkCoverageViewModel);
                        }
                      }
                    },
                    valueToBengaliMap: storeTypes,
                  ),
                ),

                SizedboxSpaccing.height02(context),

                // Conditional Content
                if (homeNotifier.selectedStoreType == 'Retail')
                  GroceryStoresSection(
                    isLoading: homeNotifier.isLoadingStores,
                    stores: homeNotifier.nearbyStores,
                    storeTypes: storeTypes,
                    selectedStoreType: homeNotifier.selectedStoreType,
                    currentPosition: homeNotifier.currentPosition,
                    currentAddress: homeNotifier.currentAddress,
                  )
                else if (homeNotifier.selectedStoreType == 'Premium House Keeper')
                  _buildPremiumHouseKeeperSection(profileViewModel, homeNotifier),

                SizedboxSpaccing.height02(context),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPremiumHouseKeeperSection(
      ProfileViewViewModel profileViewModel,
      HomeNotifier homeNotifier,
      ) {
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

    return PremiumHouseKeeperCoverageWidget(
      isCheckingCoverage: homeNotifier.isCheckingCoverage,
      isInsideServiceArea: homeNotifier.isInsideServiceArea,
      customerName: customerName,
      customerPhone: customerPhone,
      customerAddress: customerAddress,
    );
  }

  Widget _customAppBar(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Consumer2<ProfileViewViewModel, HomeNotifier>(
      builder: (context, profileViewModel, homeNotifier, _) {
        String displayAddress;

        if (homeNotifier.isLoadingLocation) {
          displayAddress = "Getting location...";
        } else if (profileViewModel.profileviewUserData.status == Status.COMPLETED) {
          final responseData = profileViewModel.profileviewUserData.data;

          if (responseData?.data?.addresses != null) {
            final addressData = responseData!.data!.addresses!;

            if (addressData.type == 'DELIVERY_ADDRESS' &&
                addressData.fullAddress != null &&
                addressData.fullAddress!.isNotEmpty) {
              displayAddress = addressData.fullAddress!;
            } else if (addressData.fullAddress != null && addressData.fullAddress!.isNotEmpty) {
              displayAddress = addressData.fullAddress!;
            } else if (homeNotifier.currentAddress != null &&
                homeNotifier.currentAddress!.isNotEmpty) {
              displayAddress = homeNotifier.currentAddress!;
            } else {
              displayAddress = "Tap to set location";
            }
          } else if (homeNotifier.currentAddress != null &&
              homeNotifier.currentAddress!.isNotEmpty) {
            displayAddress = homeNotifier.currentAddress!;
          } else {
            displayAddress = "Tap to set location";
          }
        } else if (homeNotifier.currentAddress != null &&
            homeNotifier.currentAddress!.isNotEmpty) {
          displayAddress = homeNotifier.currentAddress!;
        } else {
          displayAddress = "Tap to set location";
        }

        switch (profileViewModel.profileviewUserData.status) {
          case Status.LOADING:
            return _buildAppBarContent(
              screenWidth: screenWidth,
              screenHeight: screenHeight,
              userName: "Loading...",
              displayAddress: displayAddress,
              profileImageUrl: null,
              isLoadingLocation: homeNotifier.isLoadingLocation,
            );

          case Status.ERROR:
            return ErrorStateEmptyHeaderWidget(
              errorMessage: profileViewModel.profileviewUserData.message.toString(),
              onRetry: () {
                profileViewModel.fetchProfileViewUserDataApi();
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
                userName = fullName;
              }
            }

            return _buildAppBarContent(
              screenWidth: screenWidth,
              screenHeight: screenHeight,
              userName: userName,
              displayAddress: displayAddress,
              profileImageUrl: profileImageUrl,
              isLoadingLocation: homeNotifier.isLoadingLocation,
            );

          default:
            return Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: AppColors.border(context), width: 1.0),
                ),
              ),
              height: 80,
            );
        }
      },
    );
  }

  Widget _buildAppBarContent({
    required double screenWidth,
    required double screenHeight,
    required String userName,
    required String displayAddress,
    String? profileImageUrl,
    required bool isLoadingLocation,
  }) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        color: AppColors.containerBackground(context),
        border: Border(
          bottom: BorderSide(color: AppColors.border(context), width: 1.0),
        ),
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
                            border: Border.all(
                              width: 1,
                              color: AppColors.textPrimary(context),
                            ),
                            image: profileImageUrl != null
                                ? DecorationImage(
                              image: NetworkImage(profileImageUrl),
                              fit: BoxFit.cover,
                            )
                                : null,
                          ),
                          child: profileImageUrl == null
                              ? Icon(
                            Icons.person,
                            color: AppColors.textPrimary(context),
                            size: 20,
                          )
                              : null,
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
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    userName,
                                    style: AppTextStyles.textSize18(
                                      context,
                                      weight: FontWeight.w600,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.location_on,
                                        size: 16,
                                        color: isLoadingLocation
                                            ? AppColors.subtitle(context)
                                            : AppColors.textPrimary(context),
                                      ),
                                      SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          displayAddress,
                                          style: AppTextStyles.textSize14(
                                            context,
                                            weight: FontWeight.w400,
                                            color: isLoadingLocation
                                                ? AppColors.subtitle(context)
                                                : AppColors.textPrimary(context),
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: 25,
                              height: 45,
                              alignment: Alignment.bottomCenter,
                              child: Icon(Icons.arrow_drop_down_sharp, size: 25),
                            ),
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

  Widget _buildIconButton({
    required VoidCallback onTap,
    required String svgAsset,
    required BuildContext context,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 30,
        width: 30,
        padding: const EdgeInsets.all(2),
        child: SvgPicture.asset(
          svgAsset,
          color: AppColors.textPrimary(context),
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}