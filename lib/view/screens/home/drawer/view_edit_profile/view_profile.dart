import 'dart:io';
import 'dart:typed_data';

import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/components/dynamic_image_picker/dynamic_image_picker.dart';
import 'package:dinmajur_customer/configs/res/components/exception_errorstate/exception_errorstate.dart';
import 'package:dinmajur_customer/configs/res/components/header_appbar.dart';
import 'package:dinmajur_customer/configs/res/sizedbox_spaccing.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:dinmajur_customer/configs/responsive/responsive_ui.dart';
import 'package:dinmajur_customer/configs/utils/amount_formatter/amount_formatter.dart';
import 'package:dinmajur_customer/configs/utils/routes/routes_name.dart';
import 'package:dinmajur_customer/data/response/status.dart';
import 'package:dinmajur_customer/view/navigation_bar.dart';
import 'package:dinmajur_customer/view_model/homeview_model/drawer_view_model/profile_update_view_model/profile_image_update_view_model.dart';
import 'package:dinmajur_customer/view_model/homeview_model/profileview_model/profileview_model.dart';
import 'package:dinmajur_customer/view_model/userview_model/userview_model.dart';
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
    "assets/images/navBar/navbar_new/offers.svg",
    "assets/images/navBar/navbar_new/order.svg",
    "assets/images/navBar/navbar_new/draft.svg",
  ];
  final List<String> labels = ["Home", "Offers", "Order", "Draft"];
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
      patchImagePostViewModel.profileImageUpdatePatchApi(_selectedProfileImageData!, _selectedProfileImageName!, "profilePicture", 2, context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.containerBackground(context),
      body: SafeArea(
        child: ResPonsiveUi(mobile: body(), desktop: body(), tablet: body()),
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
            Navigator.push(context, MaterialPageRoute(builder: (context) => NavigationScreen(initialIndex: 0)));
          },
          child: SizedBox(height: 60, child: AppBarHeader("My Profile")),
        ),

        // Scrollable content with Consumer
        Expanded(
          child: Consumer<ProfileViewViewModel>(
            builder: (context, profileViewModel, _) {

              switch (profileViewModel.profileviewUserData.status) {
                case Status.LOADING:
                  return Center(child: LoadingAnimationWidget.progressiveDots(color: AppColors.button(context), size: 45));

                case Status.ERROR:
                  return ErrorStateWidget(
                    // errorMessage: profileViewModel.profileviewUserData.message.toString(),
                    errorMessage: 'Failed to load profile',
                    onRetry: () {
                      profileViewModel.fetchProfileViewUserDataApi();
                    },
                  );
                case Status.COMPLETED:

                  if (profileViewModel.profileviewUserData.data?.data?.user == null) {
                    return Center(
                      child: Text('No data found', style: AppTextStyles.textSize16(context, weight: FontWeight.w400)),
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
                  final double totalSpend = orders?.totalSpend ?? 0.0;

                  // Address data
                  String deliveryAddress = addresses?.fullAddress ?? 'No address set';

                  // Recent order
                  String? recentOrderId = orders?.recentOrder?.id;
                  String? recentOrderStatus = orders?.recentOrder?.status;
                  int? recentOrderTotal = orders?.recentOrder?.total;

                  return RefreshIndicator(
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
                            _buildStatsCard(screenWidth, screenHeight, totalOrders, totalSpend),
                            SizedBox(height: screenHeight * 0.02),
                            _buildPersonalInformation(screenWidth, screenHeight, userPhone, userData.createdAt),
                            SizedBox(height: screenHeight * 0.02),
                            _buildDeliveryAddress(screenWidth, screenHeight, deliveryAddress),
                            SizedBox(height: screenHeight * 0.02),

                            _buildActionButton(screenWidth),
                            SizedBox(height: screenHeight * 0.02),
                          ],
                        ),
                      ),
                    ),
                  );

                default:
                  return Center(
                    child: Text('Unknown state', style: AppTextStyles.textSize14(context, weight: FontWeight.w400)),
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
      decoration: BoxDecoration(color: AppColors.globalBlackWhite(context), borderRadius: BorderRadius.circular(12)),
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
                      image: profileImageUrl != null && profileImageUrl.isNotEmpty ? DecorationImage(image: NetworkImage(profileImageUrl), fit: BoxFit.cover) : null,
                    ),
                    child: profileImageUrl == null || profileImageUrl.isEmpty ? Icon(Icons.person, size: 30, color: AppColors.subtitle(context)) : null,
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
                    decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.border(context)),
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

  Widget _buildStatsCard(double screenWidth, double screenHeight, int totalOrders, double totalSpend) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [_buildStatItem(totalOrders.toString(), "Orders"), _buildVerticalDivider(), _buildStatItem("৳ ${AmountFormatter.format(totalSpend)}", "Spent")],
    );
  }

  Widget _buildStatItem(String value, String label) {
    final screenWidth = MediaQuery.of(context).size.width * 1;
    final screenHeight = MediaQuery.of(context).size.height * 1;
    return Container(
      height: 68,
      width: screenWidth * 0.4,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(width: 1, color: AppColors.border(context)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: AppTextStyles.textSize18(context, weight: FontWeight.w500, color: AppColors.subtitle(context)),
          ),
          Text(
            label,
            style: AppTextStyles.textSize14(context, weight: FontWeight.w400, color: AppColors.subtitle(context)),
          ),
        ],
      ),
    );
  }

  Widget _buildVerticalDivider() {
    return Container(height: 40, width: 1, color: AppColors.border(context));
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
            child: Text("Personal Information", style: AppTextStyles.textSize18(context, weight: FontWeight.w500)),
          ),
          Container(
            padding: EdgeInsets.all(screenHeight * 0.02),
            decoration: BoxDecoration(
              color: AppColors.containerBackground(context),
              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(24), bottomRight: Radius.circular(24)),
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
          child: Text(text, style: AppTextStyles.textSize14(context, weight: FontWeight.w400)),
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
                Text("Delivery Address", style: AppTextStyles.textSize18(context, weight: FontWeight.w500)),
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
              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(24), bottomRight: Radius.circular(24)),
              border: Border(top: BorderSide(width: 1, color: AppColors.border(context))),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.location_on, size: 20, color: AppColors.subtitle(context)),
                SizedBox(width: 12),
                Expanded(
                  child: Text(address, style: AppTextStyles.textSize14(context, weight: FontWeight.w400)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(double screenWidth) {
    void _showDeleteConfirmationDialog() {
      final screenHeight = MediaQuery.of(context).size.height;

      showDialog(
        context: context,
        barrierDismissible: false,
        barrierColor: AppColors.showDialougeBackground(context),
        builder: (dialogContext) => Consumer<ProfileViewViewModel>(
          builder: (context, profileViewModel, _) {
            return Dialog(
              backgroundColor: AppColors.containerBackground(context),
              insetPadding: EdgeInsets.all(screenHeight * 0.02),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: EdgeInsets.all(screenHeight * 0.025),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Icon
                    Container(
                      height: 60,
                      width: 60,
                      decoration: BoxDecoration(color: AppColors.darkRedColor.withOpacity(0.1), shape: BoxShape.circle),
                      child: Icon(Icons.delete_outline, color: AppColors.darkRedColor, size: 30),
                    ),
                    SizedBox(height: screenHeight * 0.02),

                    // Title
                    Text('Delete Account', style: AppTextStyles.textSize18(context, weight: FontWeight.w600)),
                    SizedBox(height: screenHeight * 0.01),

                    // Message
                    Text(
                      'Are you sure you want to delete your account? This action cannot be undone.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.textSize14(context, weight: FontWeight.w400, color: AppColors.subtitle(context)),
                    ),
                    SizedBox(height: screenHeight * 0.025),

                    // Buttons
                    Row(
                      children: [
                        // No Button
                        Expanded(
                          child: GestureDetector(
                            onTap: profileViewModel.deleteAccountLoading ? null : () => Navigator.pop(dialogContext),
                            child: Container(
                              height: 48,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(width: 1, color: AppColors.border(context)),
                              ),
                              child: Center(
                                child: Text('No', style: AppTextStyles.textSize16(context, weight: FontWeight.w600)),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: MediaQuery.of(context).size.width * 0.03),

                        // Yes, Delete Button
                        Expanded(
                          child: GestureDetector(
                            onTap: profileViewModel.deleteAccountLoading
                                ? null
                                : () async {
                                    final success = await profileViewModel.deleteAccountApi(context);
                                    if (success) {
                                      // Clear cache
                                      profileViewModel.clearCache();


                                      final userPreference = Provider.of<UserViewModel>(context, listen: false);
                                      await userPreference.remove();

                                      // Close dialog & navigate to login
                                      Navigator.of(dialogContext).pop();
                                      Navigator.of(context).pushNamedAndRemoveUntil(RoutesName.authLoginWelcome, (Route<dynamic> route) => false);
                                    }
                                  },
                            child: Container(
                              height: 48,
                              decoration: BoxDecoration(color: AppColors.darkRedColor, borderRadius: BorderRadius.circular(8)),
                              child: Center(
                                child: profileViewModel.deleteAccountLoading
                                    ? SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.whiteColor))
                                    : Text(
                                        'Yes, Delete',
                                        style: AppTextStyles.textSize16(context, weight: FontWeight.w600, color: AppColors.whiteColor),
                                      ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    }

    return Column(
      children: [
        GestureDetector(
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
        ),

        SizedboxSpaccing.height02(context),

        if (!Platform.isAndroid) ...[
          SizedboxSpaccing.height02(context),
          GestureDetector(
            onTap: _showDeleteConfirmationDialog,
            child: Container(
              height: 50,
              width: screenWidth * 0.68,
              decoration: BoxDecoration(color: AppColors.darkRedColor, borderRadius: BorderRadius.circular(8)),
              child: Center(
                child: Text(
                  'Delete Account',
                  style: AppTextStyles.textSize16(context, weight: FontWeight.w600, color: AppColors.whiteColor),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildNavigationBar(double screenWidth, double screenHeight) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: AppColors.globalBlackWhite(context),
        boxShadow: [BoxShadow(color: Theme.of(context).brightness == Brightness.dark ? Colors.white12.withOpacity(0.02) : Colors.white10, blurRadius: 10, offset: Offset(0, -2))],
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
                      SvgPicture.asset(icons[index], width: 20, height: 20, color: isSelected ? AppColors.button(context) : AppColors.subtitle(context), semanticsLabel: labels[index]),
                      const SizedBox(height: 6),
                      Text(
                        labels[index],
                        style: AppTextStyles.textSize12(context, weight: isSelected ? FontWeight.w500 : FontWeight.w400, color: isSelected ? AppColors.button(context) : AppColors.subtitle(context)),
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
