
import 'dart:typed_data';

import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/components/dynamic_image_picker/dynamic_image_picker.dart';
import 'package:dinmajur_customer/configs/res/components/header_appbar.dart';
import 'package:dinmajur_customer/configs/res/sizedbox_spaccing.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:dinmajur_customer/configs/responsive/responsive_ui.dart';
import 'package:dinmajur_customer/configs/utils/routes/routes_name.dart';
import 'package:dinmajur_customer/data/response/status.dart';
import 'package:dinmajur_customer/view/navigation_bar.dart';
import 'package:dinmajur_customer/view_model/homeview_model/drawer_view_model/profile_update_view_model/profile_image_update_view_model.dart';
import 'package:dinmajur_customer/view_model/homeview_model/profileview_model/profileview_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class ViewProfile extends StatefulWidget {
  const ViewProfile({super.key});

  @override
  State<ViewProfile> createState() => _ViewProfileState();
}

class _ViewProfileState extends State<ViewProfile> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profileViewModel = Provider.of<ProfileViewViewModel>(context, listen: false);
      profileViewModel.fetchProfileViewUserDataApi();
    });
  }
  Future<void> _handleRefresh() async {
    final profileViewModel = Provider.of<ProfileViewViewModel>(context, listen: false);
    await profileViewModel.fetchProfileViewUserDataApi();
  }
  int _currentIndex = 0;
  final List<String> icons = [
    "assets/images/navBar/navbar_new/home.svg",
    "assets/images/navBar/navbar_new/scan.svg",
    "assets/images/navBar/navbar_new/order.svg",
    "assets/images/navBar/navbar_new/stores.svg",
    "assets/images/navBar/navbar_new/income.svg",
  ];
  final List<String> labels = ["Home", "Scan", "Task", "Stores", "Income"];
  Uint8List? _selectedProfileImageData;
  String? _selectedProfileImageName;
  String? _selectedProfileDisplayName;

  void _handleImagePick() {
    DynamicImagePicker.pickImage(
      context: context,
      imageType: ImageType.profilePicture,
      onImageSelected: (imageData, actualName, displayName) {
        if (mounted) {
          setState(() {
            _selectedProfileImageData = imageData;
            _selectedProfileImageName = actualName;
            _selectedProfileDisplayName = displayName;
          });
        }
      },
      onApiCall: () {
        _callprofileImageAPI();
      },
    );
  }

  void _callprofileImageAPI() {
    if (_selectedProfileImageData != null && _selectedProfileImageName != null) {
      final patchImagePostViewModel = Provider.of<PatchprofileImageUpdateViewModel>(context, listen: false);
      patchImagePostViewModel.profileImageUpdatePatchApi(
          _selectedProfileImageData!,
          _selectedProfileImageName!,
          "profilePicture",
          2,
          context
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.containerBackground(context),
      body: SafeArea(
        child: ResPonsiveUi(
          mobile: body(),
          desktop: body(),
          tablet: body(),
        ),
      ),
    );
  }

  Widget body() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Column(
      children: [
        // Header
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => NavigationScreen(initialIndex: 0),
              ),
            );
          },
          child: SizedBox(height: 60, child: AppBarHeader("My Profile")),
        ),

        // Scrollable content with Consumer
        Expanded(
          child: Consumer<ProfileViewViewModel>(
            builder: (context, profileViewModel, _) {
              print("ProfileViewModel Status: ${profileViewModel.profileviewUserData.status}");

              switch (profileViewModel.profileviewUserData.status) {
                case Status.LOADING:
                  return Center(
                    child: LoadingAnimationWidget.progressiveDots(
                      color: AppColors.button(context),
                      size: 45,
                    ),
                  );

                case Status.ERROR:
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 60, color: AppColors.subtitle(context)),
                        SizedBox(height: 16),
                        Text(
                          'Failed to load profile',
                          style: AppTextStyles.textSize16(context, weight: FontWeight.w500),
                        ),
                        SizedBox(height: 16),
                        GestureDetector(
                          onTap: () {
                            profileViewModel.fetchProfileViewUserDataApi();
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            decoration: BoxDecoration(
                              color: AppColors.button(context),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.restart_alt_outlined, size: 20, color: AppColors.whiteColor),
                                SizedBox(width: 8),
                                Text(
                                  'Retry',
                                  style: AppTextStyles.textSize14(
                                    context,
                                    weight: FontWeight.w600,
                                    color: AppColors.whiteColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );

                case Status.COMPLETED:
                  print("Data: ${profileViewModel.profileviewUserData.data}");

                  if (profileViewModel.profileviewUserData.data?.data?.user == null) {
                    return Center(
                      child: Text(
                        'No data found',
                        style: AppTextStyles.textSize16(context, weight: FontWeight.w400),
                      ),
                    );
                  }

                  final userData = profileViewModel.profileviewUserData.data!.data!.user!;
                  final addresses = profileViewModel.profileviewUserData.data!.data!.addresses;
                  final orders = profileViewModel.profileviewUserData.data!.data!.orders;

                  String? profileImageUrl = userData.profilePicture?.url;
                  String userName = userData.fullName?.trim() ?? 'Unknown User';
                  String userPhone = userData.phone ?? 'N/A';

                  // Orders data
                  int totalOrders = orders?.totalOrders ?? 0;
                  int totalSpend = orders?.totalSpend ?? 0;
                  int totalReviews = orders?.totalReviews ?? 0;

                  // Address data
                  String deliveryAddress = addresses?.fullAddress ?? 'No address set';

                  // Recent order
                  String? recentOrderId = orders?.recentOrder?.id;
                  String? recentOrderStatus = orders?.recentOrder?.status;
                  int? recentOrderTotal = orders?.recentOrder?.total;

                  return  RefreshIndicator(
                    onRefresh: _handleRefresh,
                    color: AppColors.textPrimary(context),
                    backgroundColor: AppColors.containerBackground(context),
                    displacement: 40,
                    strokeWidth: 2.0,
                    child: SingleChildScrollView(
                      physics: AlwaysScrollableScrollPhysics(),
                      child: Container(
                        width: screenWidth * 0.9,
                        child: Column(
                          children: [
                            _buildProfileCard(screenWidth, screenHeight, profileImageUrl, userName, userPhone),
                            _buildStatsCard(screenWidth, screenHeight, totalOrders, totalSpend, totalReviews),
                            SizedBox(height: screenHeight * 0.02),
                            _buildPersonalInformation(screenWidth, screenHeight, userPhone, userData.createdAt),
                            SizedBox(height: screenHeight * 0.02),
                            _buildDeliveryAddress(screenWidth, screenHeight, deliveryAddress),
                            SizedBox(height: screenHeight * 0.02),
                            // _buildRecentOrders(screenWidth, screenHeight,),
                            // SizedBox(height: screenHeight * 0.02),
                            _buildBackButton(screenWidth),
                            SizedBox(height: screenHeight * 0.02),
                          ],
                        ),
                      ),
                    ),
                  );

                default:
                  return Center(
                    child: Text(
                      'Unknown state',
                      style: AppTextStyles.textSize14(context, weight: FontWeight.w400),
                    ),
                  );
              }
            },
          ),
        ),

        /// Fixed navigation bar at bottom
        _buildNavigationBar(screenWidth, screenHeight),
      ],
    );
  }

  Widget _buildProfileCard(double screenWidth, double screenHeight, String? profileImageUrl, String userName, String userPhone) {
    final patchprofileImageUpdateViewMode = Provider.of<PatchprofileImageUpdateViewModel>(context);

    return Container(
      padding: EdgeInsets.all(screenHeight * 0.02),
      decoration: BoxDecoration(
        color: AppColors.globalBlackWhite(context),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Stack(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.textFieldFill(context),
                  shape: BoxShape.circle,
                  border: Border.all(width: 2, color: AppColors.border(context)),
                ),
                child: Center(
                  child: Container(
                    height: 54,
                    width: 54,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.textFieldFill(context),
                      border: Border.all(width: 1, color: AppColors.button(context)),
                      image: profileImageUrl != null && profileImageUrl.isNotEmpty
                          ? DecorationImage(image: NetworkImage(profileImageUrl), fit: BoxFit.cover)
                          : null,
                    ),
                    child: profileImageUrl == null || profileImageUrl.isEmpty
                        ? Icon(Icons.person, size: 30, color: AppColors.subtitle(context))
                        : null,
                  ),
                ),
              ),
              Positioned(
                bottom: 10,
                right: 0,
                child: GestureDetector(
                  onTap: patchprofileImageUpdateViewMode.profileImageUpdateLoading ? () {} : _handleImagePick,
                  child: Container(
                    height: 19,
                    width: 19,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.border(context),
                    ),
                    child: Icon(Icons.camera_alt, size: 10, color: AppColors.textPrimary(context)),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(width: screenWidth * 0.04),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userName,
                  style: AppTextStyles.textSize18(context, weight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4),
                Text(
                  userPhone,
                  style: AppTextStyles.textSize14(context, weight: FontWeight.w400),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard(double screenWidth, double screenHeight, int totalOrders, int totalSpend, int totalReviews) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildStatItem(totalOrders.toString(), "Orders"),
        _buildVerticalDivider(),
        _buildStatItem("৳${totalSpend}", "Spent"),
        _buildVerticalDivider(),
        _buildStatItem(totalReviews.toString(), "Reviews"),
      ],
    );
  }
  Widget _buildStatItem(String value, String label) {
    final screenWidth = MediaQuery.of(context).size.width*1;
    final screenHeight = MediaQuery.of(context).size.height*1;
    return Container(
      height: 68,
      width: screenWidth*0.26,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          width: 1,
          color: AppColors.border(context)
        )
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: AppTextStyles.textSize18(context, weight: FontWeight.w500,    color: AppColors.subtitle(context),),
          ),
          Text(
            label,
            style: AppTextStyles.textSize14(
              context,
              weight: FontWeight.w400,
              color: AppColors.subtitle(context),
            ),
          ),
        ],
      )
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      height: 40,
      width: 1,
      color: AppColors.border(context),
    );
  }

  Widget _buildPersonalInformation(double screenWidth, double screenHeight, String phone, DateTime? createdAt) {
    // Format the date
    String memberSince = 'N/A';
    if (createdAt != null) {
      memberSince = DateFormat('dd MMM, yyyy').format(createdAt);
    }

    return Container(
      width: screenWidth * 0.9,
      decoration: BoxDecoration(
        color: AppColors.containerBackground(context),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(width: 1, color: AppColors.border(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(screenHeight * 0.02),
            child: Text(
              "Personal Information",
              style: AppTextStyles.textSize18(context, weight: FontWeight.w500),
            ),
          ),
          Container(
            padding: EdgeInsets.all(screenHeight * 0.02),
            decoration: BoxDecoration(
              color: AppColors.containerBackground(context),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
              border: Border(top: BorderSide(width: 1, color: AppColors.border(context))),
            ),
            child: Column(
              children: [
                _buildInfoRow(Icons.phone, phone),
                SizedBox(height: screenHeight * 0.015),
                _buildInfoRow(Icons.calendar_today_outlined, "Member since: $memberSince"),
              ],
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.textPrimary(context)),
        SizedboxSpaccing.width03(context),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.textSize14(context, weight: FontWeight.w400),
          ),
        ),
      ],
    );
  }

  Widget _buildDeliveryAddress(double screenWidth, double screenHeight, String address) {
    return Container(
      width: screenWidth * 0.9,
      decoration: BoxDecoration(
        color: AppColors.containerBackground(context),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(width: 1, color: AppColors.border(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(screenHeight * 0.02),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Delivery Address",
                  style: AppTextStyles.textSize18(context, weight: FontWeight.w500),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, RoutesName.addlocation);
                  },
                  child: Text(
                    "Change",
                    style: AppTextStyles.textSize12(context, weight: FontWeight.w500, color: AppColors.button(context)),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(screenHeight * 0.02),
            decoration: BoxDecoration(
              color: AppColors.containerBackground(context),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
              border: Border(top: BorderSide(width: 1, color: AppColors.border(context))),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.location_on, size: 20, color: AppColors.subtitle(context)),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    address,
                    style: AppTextStyles.textSize14(context, weight: FontWeight.w400),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentOrders(double screenWidth, double screenHeight) {
    return Container(
      width: screenWidth * 0.9,
      decoration: BoxDecoration(
        color: AppColors.containerBackground(context),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(width: 1, color: AppColors.border(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(screenHeight * 0.02),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Recent Orders",
                  style: AppTextStyles.textSize16(context, weight: FontWeight.w600),
                ),
                GestureDetector(
                  onTap: (){

                  },
                  child: Text(
                    "View All",
                    style: AppTextStyles.textSize12(context, weight: FontWeight.w500,     color: AppColors.button(context),),
                  ),
                ),
              ],
            ),
          ),

          Container(
              padding: EdgeInsets.all(screenHeight * 0.02),
              decoration: BoxDecoration(
                color: AppColors.containerBackground(context),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
                border: Border(top: BorderSide(
                    width: 1, color: AppColors.border(context)
                )
                ),
              ),
              child: _buildOrderItem("Order #1024", "Delivered", "\$125.50")),
        ],
      ),
    );
  }

  Widget _buildOrderItem(String orderId, String status, String amount) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.containerBackground(context),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: AppColors.textFieldFill(context),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.shopping_bag, color: AppColors.subtitle(context)),
          ),
        SizedboxSpaccing.width03(context),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  orderId,
                  style: AppTextStyles.textSize14(context, weight: FontWeight.w400,color: AppColors.textPrimary(context)),
                ),
                Text(
                  status,
                  style: AppTextStyles.textSize12(
                    context,
                    weight: FontWeight.w400,
                    color: AppColors.subtitle(context),
                  ),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: AppTextStyles.textSize14(context, weight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildBackButton(double screenWidth) {
    return           GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => NavigationScreen(initialIndex: 0)));
      },
      child: Container(
        height: 50,
        width: screenWidth * 0.68,
        decoration: BoxDecoration(color: AppColors.button(context), borderRadius: BorderRadius.circular(8)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(FontAwesomeIcons.arrowLeft, size: 16, color: AppColors.whiteColor),
            SizedboxSpaccing.width03(context),
            Text(
              'Back to Dashboard',
              style: AppTextStyles.textSize16(context, weight: FontWeight.w600, color: AppColors.whiteColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationBar(double screenWidth, double screenHeight) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: AppColors.globalBlackWhite(context),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).brightness == Brightness.dark ? Colors.white12.withOpacity(0.02) : Colors.white10,
            blurRadius: 10,
            offset: Offset(0, -2),
          )
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
                onTap: () async {
                  await Future.delayed(Duration(milliseconds: 300));
                  Navigator.push(context, MaterialPageRoute(builder: (context) => NavigationScreen(initialIndex: index)));
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
                        width: 20,
                        height: 20,
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
    );
  }
}