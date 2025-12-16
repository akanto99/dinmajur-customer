// import 'package:dinmajur_customer/configs/buttons/round_button.dart';
// import 'package:dinmajur_customer/configs/res/color.dart';
// import 'package:dinmajur_customer/configs/res/components/drawer.dart';
// import 'package:dinmajur_customer/configs/res/components/exception_errorstate/exception_errorstate.dart';
// import 'package:dinmajur_customer/configs/res/components/notifications/resuable_notifications.dart';
// import 'package:dinmajur_customer/configs/res/sizedbox_spaccing.dart';
// import 'package:dinmajur_customer/configs/res/text_styles.dart';
// import 'package:dinmajur_customer/configs/responsive/responsive_ui.dart';
// import 'package:dinmajur_customer/configs/services/location_services/location_getting.dart';
// import 'package:dinmajur_customer/configs/services/sse_notification_services/sse_notification_view_model.dart';
// import 'package:dinmajur_customer/configs/utils/routes/routes_name.dart';
// import 'package:dinmajur_customer/configs/utils/utils.dart';
// import 'package:dinmajur_customer/configs/widgets/dynamic_dropdown.dart';
// import 'package:dinmajur_customer/data/response/status.dart';
// import 'package:dinmajur_customer/l10n/app_localizations.dart';
// import 'package:dinmajur_customer/view/screens/home/home_notifier.dart';
// import 'package:dinmajur_customer/view_model/homeview_model/dropdown_categories_selection_view_models/premium_house_keeper_view_model/check_coverage_view_model.dart';
// import 'package:dinmajur_customer/view_model/homeview_model/location_view_model/newlocation_view_model.dart';
// import 'package:dinmajur_customer/view_model/homeview_model/nearby_retailers_and_order_view_models/nearby_retailers_view_model.dart';
// import 'package:dinmajur_customer/view_model/homeview_model/profileview_model/profileview_model.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'dorpdown_categories_selections_and_views/grocery/grocery_sction_widget.dart';
// import 'dorpdown_categories_selections_and_views/premium_house_keeper/premium_house_keeper_widget.dart';
//
// class HomeScreenOld extends StatefulWidget {
//   final GlobalKey<ScaffoldState>? scaffoldKey;
//   const HomeScreenOld({super.key, this.scaffoldKey});
//
//   @override
//   State<HomeScreenOld> createState() => _HomeScreenOldState();
// }
//
// class _HomeScreenOldState extends State<HomeScreenOld> {
//   late Map<String, String> storeTypes;
//   bool _isInitialized = false;
//
//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//
//     storeTypes = {
//       'Retail': AppLocalizations.of(context)!.storeType_grocery,
//       'Premium House Keeper': AppLocalizations.of(context)!.storeType_housekeeper,
//     };
//
//     if (!_isInitialized) {
//       _isInitialized = true;
//
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         _initializeScreen();
//       });
//     }
//   }
//
//   @override
//   void initState() {
//     super.initState();
//   }
//
//   /// Initialize screen data and SSE
//   void _initializeScreen() {
//     // Initialize HomeNotifier
//     final homeNotifier = Provider.of<HomeNotifier>(context, listen: false);
//     homeNotifier.initialize(context);
//
//     // Fetch profile data
//     final profileViewModel = Provider.of<ProfileViewViewModel>(context, listen: false);
//     profileViewModel.fetchProfileViewUserDataApi().then((_) {
//       // After profile is loaded, initialize SSE
//       if (profileViewModel.profileviewUserData.status == Status.COMPLETED) {
//         final userId = profileViewModel.profileviewUserData.data?.data?.user?.id ?? '';
//
//         if (userId.isNotEmpty) {
//           final notificationViewModel = Provider.of<NotificationViewModel>(context, listen: false);
//           homeNotifier.initializeSSE(userId, notificationViewModel);
//         }
//       }
//     });
//   }
//
//   @override
//   void dispose() {
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final screenHeight = MediaQuery.of(context).size.height;
//     final screenWidth = MediaQuery.of(context).size.width;
//
//     return Scaffold(
//       key: widget.scaffoldKey,
//       backgroundColor: AppColors.containerBackground(context),
//       drawer: CustomDrawer(screenHeight: screenHeight, screenWidth: screenWidth),
//       appBar: PreferredSize(
//         preferredSize: const Size.fromHeight(80),
//         child: Container(
//           color: AppColors.containerBackground(context),
//           child: Center(child: _customAppBar(context)),
//         ),
//       ),
//       body: SafeArea(
//         child: ResPonsiveUi(
//           mobile: _body(context),
//           desktop: _body(context),
//           tablet: _body(context),
//         ),
//       ),
//     );
//   }
//
//   Widget _body(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;
//     final screenHeight = MediaQuery.of(context).size.height;
//
//     return Consumer2<HomeNotifier, ProfileViewViewModel>(
//       builder: (context, homeNotifier, profileViewModel, _) {
//         return RefreshIndicator(
//           onRefresh: () => homeNotifier.handleRefresh(context, profileViewModel),
//           color: AppColors.textPrimary(context),
//           backgroundColor: AppColors.containerBackground(context),
//           displacement: 40,
//           strokeWidth: 2.0,
//           child: SingleChildScrollView(
//             physics: AlwaysScrollableScrollPhysics(),
//             child: Column(
//               children: [
//                 Center(child: SizedboxSpaccing.height02(context)),
//
//                 Container(
//                   width: screenWidth * 0.9,
//                   padding: EdgeInsets.all(screenHeight * 0.02),
//                   decoration: BoxDecoration(
//                     color: AppColors.containerBackground(context),
//                     borderRadius: BorderRadius.circular(24),
//                     border: Border.all(width: 1, color: AppColors.border(context)),
//                   ),
//                   child: CustomDropdown(
//                     titleText: AppLocalizations.of(context)!.select_store_type,
//                     items: storeTypes.keys.toList(),
//                     selectedItem: homeNotifier.selectedStoreType,
//                     hintText: AppLocalizations.of(context)!.select_store_type_hint,
//                     onChanged: (String? newValue) {
//                       homeNotifier.setSelectedStoreType(newValue);
//
//                       if (newValue != null) {
//                         debugPrint('🔄 Selected store type: $newValue');
//
//                         if (newValue == 'Retail') {
//                           homeNotifier.fetchNearbyRetailers(
//                             context,
//                             newValue,
//                             profileViewModel,
//                           );
//                         } else if (newValue == 'Premium House Keeper') {
//                           final checkCoverageViewModel = Provider.of<CheckCoverageViewModel>(
//                             context,
//                             listen: false,
//                           );
//                           homeNotifier.checkCoverage(context, checkCoverageViewModel);
//                         }
//                       }
//                     },
//                     valueToBengaliMap: storeTypes,
//                   ),
//                 ),
//
//                 SizedboxSpaccing.height02(context),
//
//                 if (homeNotifier.selectedStoreType == 'Retail')
//                   GroceryStoresSection(
//                     isLoading: homeNotifier.isLoadingStores,
//                     stores: homeNotifier.nearbyStores,
//                     storeTypes: storeTypes,
//                     selectedStoreType: homeNotifier.selectedStoreType,
//                     currentPosition: homeNotifier.currentPosition,
//                     currentAddress: homeNotifier.currentAddress,
//                   )
//                 else if (homeNotifier.selectedStoreType == 'Premium House Keeper')
//                   _buildPremiumHouseKeeperSection(profileViewModel, homeNotifier),
//
//                 SizedboxSpaccing.height02(context),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
//
//   Widget _buildPremiumHouseKeeperSection(
//       ProfileViewViewModel profileViewModel,
//       HomeNotifier homeNotifier,
//       ) {
//     String customerName = '';
//     String customerPhone = '';
//     String customerAddress = '';
//
//     if (profileViewModel.profileviewUserData.status == Status.COMPLETED) {
//       final userData = profileViewModel.profileviewUserData.data?.data;
//
//       if (userData?.user?.fullName != null) {
//         customerName = userData!.user!.fullName!;
//       }
//
//       if (userData?.user?.phone != null) {
//         customerPhone = userData!.user!.phone!;
//       }
//
//       if (userData?.addresses?.fullAddress != null) {
//         customerAddress = userData!.addresses!.fullAddress!;
//       }
//     }
//
//     return PremiumHouseKeeperCoverageWidget(
//       isCheckingCoverage: homeNotifier.isCheckingCoverage,
//       isInsideServiceArea: homeNotifier.isInsideServiceArea,
//       customerName: customerName,
//       customerPhone: customerPhone,
//       customerAddress: customerAddress,
//     );
//   }
//
//   Widget _customAppBar(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;
//     final screenHeight = MediaQuery.of(context).size.height;
//
//     return Consumer2<ProfileViewViewModel, HomeNotifier>(
//       builder: (context, profileViewModel, homeNotifier, _) {
//         String displayAddress;
//
//         if (homeNotifier.isLoadingLocation) {
//           displayAddress = "Getting location...";
//         } else if (profileViewModel.profileviewUserData.status == Status.COMPLETED) {
//           final responseData = profileViewModel.profileviewUserData.data;
//
//           if (responseData?.data?.addresses != null) {
//             final addressData = responseData!.data!.addresses!;
//
//             if (addressData.type == 'DELIVERY_ADDRESS' &&
//                 addressData.fullAddress != null &&
//                 addressData.fullAddress!.isNotEmpty) {
//               displayAddress = addressData.fullAddress!;
//             } else if (addressData.fullAddress != null && addressData.fullAddress!.isNotEmpty) {
//               displayAddress = addressData.fullAddress!;
//             } else if (homeNotifier.currentAddress != null &&
//                 homeNotifier.currentAddress!.isNotEmpty) {
//               displayAddress = homeNotifier.currentAddress!;
//             } else {
//               displayAddress = "Tap to set location";
//             }
//           } else if (homeNotifier.currentAddress != null &&
//               homeNotifier.currentAddress!.isNotEmpty) {
//             displayAddress = homeNotifier.currentAddress!;
//           } else {
//             displayAddress = "Tap to set location";
//           }
//         } else if (homeNotifier.currentAddress != null &&
//             homeNotifier.currentAddress!.isNotEmpty) {
//           displayAddress = homeNotifier.currentAddress!;
//         } else {
//           displayAddress = "Tap to set location";
//         }
//
//         switch (profileViewModel.profileviewUserData.status) {
//           case Status.LOADING:
//             return _buildAppBarContent(
//               screenWidth: screenWidth,
//               screenHeight: screenHeight,
//               userName: "Loading...",
//               displayAddress: displayAddress,
//               profileImageUrl: null,
//               isLoadingLocation: homeNotifier.isLoadingLocation,
//             );
//
//           case Status.ERROR:
//             return ErrorStateEmptyHeaderWidget(
//               errorMessage: profileViewModel.profileviewUserData.message.toString(),
//               onRetry: () {
//                 profileViewModel.fetchProfileViewUserDataApi();
//               },
//             );
//
//           case Status.COMPLETED:
//             final responseData = profileViewModel.profileviewUserData.data;
//             String userName = 'Unknown User';
//             String? profileImageUrl;
//
//             if (responseData?.data?.user != null) {
//               final userData = responseData!.data!.user!;
//               profileImageUrl = userData.profilePicture?.url;
//
//               final fullName = userData.fullName?.trim();
//
//               if (fullName != null && fullName.isNotEmpty) {
//                 userName = fullName;
//               }
//             }
//
//             return _buildAppBarContent(
//               screenWidth: screenWidth,
//               screenHeight: screenHeight,
//               userName: userName,
//               displayAddress: displayAddress,
//               profileImageUrl: profileImageUrl,
//               isLoadingLocation: homeNotifier.isLoadingLocation,
//             );
//
//           default:
//             return Container(
//               decoration: BoxDecoration(
//                 border: Border(
//                   bottom: BorderSide(color: AppColors.border(context), width: 1.0),
//                 ),
//               ),
//               height: 80,
//             );
//         }
//       },
//     );
//   }
//
//   Widget _buildAppBarContent({
//     required double screenWidth,
//     required double screenHeight,
//     required String userName,
//     required String displayAddress,
//     String? profileImageUrl,
//     required bool isLoadingLocation,
//   }) {
//     return Container(
//       height: 60,
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.only(
//           bottomLeft: Radius.circular(24),
//           bottomRight: Radius.circular(24),
//         ),
//         color: AppColors.containerBackground(context),
//         border: Border(
//           bottom: BorderSide(color: AppColors.border(context), width: 1.0),
//         ),
//       ),
//       child: Center(
//         child: Container(
//           width: screenWidth * 0.9,
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               // Left Side - User Profile
//               Expanded(
//                 flex: 3,
//                 child: Row(
//                   children: [
//                     Builder(
//                       builder: (context) => GestureDetector(
//                         onTap: () {
//                           Scaffold.of(context).openDrawer();
//                         },
//                         child: Container(
//                           height: 48,
//                           width: 48,
//                           decoration: BoxDecoration(
//                             shape: BoxShape.circle,
//                             color: AppColors.appBackground(context),
//                             border: Border.all(
//                               width: 1,
//                               color: AppColors.textPrimary(context),
//                             ),
//                             image: profileImageUrl != null
//                                 ? DecorationImage(
//                               image: NetworkImage(profileImageUrl),
//                               fit: BoxFit.cover,
//                             )
//                                 : null,
//                           ),
//                           child: profileImageUrl == null
//                               ? Icon(
//                             Icons.person,
//                             color: AppColors.textPrimary(context),
//                             size: 20,
//                           )
//                               : null,
//                         ),
//                       ),
//                     ),
//                     SizedboxSpaccing.width02(context),
//                     Expanded(
//                       child: GestureDetector(
//                         onTap: () {
//                           Navigator.pushNamed(context, RoutesName.addlocation);
//                         },
//                         child: Row(
//                           children: [
//                             Flexible(
//                               child: Column(
//                                 mainAxisAlignment: MainAxisAlignment.center,
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(
//                                     userName,
//                                     style: AppTextStyles.textSize18(
//                                       context,
//                                       weight: FontWeight.w600,
//                                     ),
//                                     overflow: TextOverflow.ellipsis,
//                                     maxLines: 1,
//                                   ),
//                                   Row(
//                                     children: [
//                                       Icon(
//                                         Icons.location_on,
//                                         size: 16,
//                                         color: isLoadingLocation
//                                             ? AppColors.subtitle(context)
//                                             : AppColors.textPrimary(context),
//                                       ),
//                                       SizedBox(width: 4),
//                                       Expanded(
//                                         child: Text(
//                                           displayAddress,
//                                           style: AppTextStyles.textSize14(
//                                             context,
//                                             weight: FontWeight.w400,
//                                             color: isLoadingLocation
//                                                 ? AppColors.subtitle(context)
//                                                 : AppColors.textPrimary(context),
//                                           ),
//                                           overflow: TextOverflow.ellipsis,
//                                           maxLines: 1,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ],
//                               ),
//                             ),
//                             Container(
//                               width: 25,
//                               height: 45,
//                               alignment: Alignment.bottomCenter,
//                               child: Icon(Icons.arrow_drop_down_sharp, size: 25),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//
//               // Right Side Icons
//               Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   SizedboxSpaccing.width03(context),
//                   _buildIconButton(
//                     onTap: () {
//                       NotificationDialog.show(
//                         context,
//                         message: AppLocalizations.of(context)!.empty_inbox,
//                         icon: CupertinoIcons.text_bubble,
//                         iconColor: AppColors.textPrimary(context),
//                         iconBackgroundColor: AppColors.appBackground(context),
//                       );
//                     },
//                     svgAsset: 'assets/images/home/email.svg',
//                     context: context,
//                   ),
//                   SizedboxSpaccing.width02(context),
//                   _buildNotificationIconWithBadge(context),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   // Regular icon button for email
//   Widget _buildIconButton({
//     required VoidCallback onTap,
//     required String svgAsset,
//     required BuildContext context,
//   }) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         height: 30,
//         width: 30,
//         padding: const EdgeInsets.all(2),
//         child: SvgPicture.asset(
//           svgAsset,
//           color: AppColors.textPrimary(context),
//           fit: BoxFit.contain,
//         ),
//       ),
//     );
//   }
//
//   // Notification icon with badge
//   Widget _buildNotificationIconWithBadge(BuildContext context) {
//     return Consumer<NotificationViewModel>(
//       builder: (context, notificationViewModel, _) {
//         final unreadCount = notificationViewModel.unreadNotificationCount;
//
//         return GestureDetector(
//           onTap: () {
//             _showNotificationsDialog(context, notificationViewModel);
//           },
//           child: Stack(
//             clipBehavior: Clip.none,
//             children: [
//               Container(
//                 height: 30,
//                 width: 30,
//                 padding: const EdgeInsets.all(2),
//                 child: SvgPicture.asset(
//                   'assets/images/home/notification.svg',
//                   color: AppColors.textPrimary(context),
//                   fit: BoxFit.contain,
//                 ),
//               ),
//
//               // Badge
//               if (unreadCount > 0)
//                 Positioned(
//                   right: -4,
//                   top: -4,
//                   child: Container(
//                     padding: EdgeInsets.all(unreadCount > 9 ? 4 : 6),
//                     decoration: BoxDecoration(
//                       color: Colors.red,
//                       shape: BoxShape.circle,
//                       border: Border.all(
//                         color: AppColors.containerBackground(context),
//                         width: 2,
//                       ),
//                     ),
//                     constraints: BoxConstraints(
//                       minWidth: 18,
//                       minHeight: 18,
//                     ),
//                     child: Center(
//                       child: Text(
//                         unreadCount > 99 ? '99+' : unreadCount.toString(),
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontSize: unreadCount > 9 ? 9 : 10,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//             ],
//           ),
//         );
//       },
//     );
//   }
//
//   // Show notifications dialog
//   void _showNotificationsDialog(
//       BuildContext context,
//       NotificationViewModel notificationViewModel,
//       ) {
//     if (notificationViewModel.notifications.isEmpty) {
//       NotificationDialog.show(
//         context,
//         message: AppLocalizations.of(context)!.no_notification,
//         icon: Icons.notifications_outlined,
//         iconColor: AppColors.textPrimary(context),
//         iconBackgroundColor: AppColors.appBackground(context),
//       );
//       return;
//     }
//
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (context) => Container(
//         height: MediaQuery.of(context).size.height * 0.7,
//         decoration: BoxDecoration(
//           color: AppColors.containerBackground(context),
//           borderRadius: BorderRadius.only(
//             topLeft: Radius.circular(24),
//             topRight: Radius.circular(24),
//           ),
//         ),
//         child: Column(
//           children: [
//             // Header
//             Padding(
//               padding: EdgeInsets.all(16),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     'Notifications',
//                     style: AppTextStyles.textSize20(context, weight: FontWeight.bold),
//                   ),
//                   Row(
//                     children: [
//                       TextButton(
//                         onPressed: () {
//                           notificationViewModel.markAllAsRead();
//                         },
//                         child: Text('Mark all as read'),
//                       ),
//                       IconButton(
//                         onPressed: () => Navigator.pop(context),
//                         icon: Icon(Icons.close),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//
//             Divider(),
//
//             // Notifications List
//             Expanded(
//               child: ListView.builder(
//                 itemCount: notificationViewModel.notifications.length,
//                 itemBuilder: (context, index) {
//                   final notification = notificationViewModel.notifications[index];
//                   final isRead = notification['isRead'] == true;
//
//                   return ListTile(
//                     leading: Container(
//                       width: 40,
//                       height: 40,
//                       decoration: BoxDecoration(
//                         color: isRead
//                             ? AppColors.appBackground(context)
//                             : AppColors.textPrimary(context).withOpacity(0.1),
//                         shape: BoxShape.circle,
//                       ),
//                       child: Icon(
//                         Icons.notifications,
//                         color: isRead
//                             ? AppColors.subtitle(context)
//                             : AppColors.textPrimary(context),
//                       ),
//                     ),
//                     title: Text(
//                       notification['title'] ?? 'New Notification',
//                       style: AppTextStyles.textSize16(
//                         context,
//                         weight: isRead ? FontWeight.normal : FontWeight.bold,
//                       ),
//                     ),
//                     subtitle: Text(
//                       notification['message'] ?? '',
//                       style: AppTextStyles.textSize14(context),
//                     ),
//                     tileColor: isRead
//                         ? null
//                         : AppColors.textPrimary(context).withOpacity(0.05),
//                     onTap: () {
//                       notificationViewModel.markAsRead(index);
//                       // Handle notification tap - navigate to specific screen if needed
//                     },
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }