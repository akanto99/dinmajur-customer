import 'dart:io';
import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/components/full_screen_image/full_image_viewer.dart';
import 'package:dinmajur_customer/configs/res/components/profile_view_header/drawer_profile_view.dart';
import 'package:dinmajur_customer/configs/res/sizedbox_spaccing.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:dinmajur_customer/configs/services/socket/socket_provider.dart';
import 'package:dinmajur_customer/configs/utils/routes/routes_name.dart';
import 'package:dinmajur_customer/configs/utils/utils.dart';
import 'package:dinmajur_customer/data/response/status.dart';
import 'package:dinmajur_customer/view_model/authview_model/login_logout_view_model.dart';
import 'package:dinmajur_customer/view_model/homeview_model/profileview_model/profileview_model.dart';
import 'package:dinmajur_customer/view_model/userview_model/userview_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'header_appbar.dart';

class CustomDrawer extends StatefulWidget {
  final double screenHeight;
  final double screenWidth;

  const CustomDrawer({super.key, required this.screenHeight, required this.screenWidth});

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  @override
  void initState() {
    super.initState();
    // Fetch data when widget initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profileViewModel = Provider.of<ProfileViewViewModel>(context, listen: false);
      profileViewModel.fetchProfileViewUserDataApi();
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width * 1;
    final screenHeight = MediaQuery.of(context).size.height * 1;
    return Container(
      width: widget.screenWidth,
      color: AppColors.appBackground(context),
      child: Drawer(
        backgroundColor: AppColors.containerBackground(context),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Container(height: 60, child: AppBarHeader("Profile Menu")),
              ),
              _buildHeader(),
              _buildMenu(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Consumer<ProfileViewViewModel>(
      builder: (context, profileViewModel, _) {
        // Debug print to check the status
        print("ProfileViewModel Status: ${profileViewModel.profileviewUserData.status}");

        switch (profileViewModel.profileviewUserData.status) {
          case Status.LOADING:
            return Container(height: 245, child: Center(child: Container(height: 15, width: 50, child: LoadingAnimationWidget.progressiveDots(color: AppColors.button(context), size: 45))));

          case Status.ERROR:
            return Container(
              height: 245,
              color: AppColors.appBackground(context),
              child: Center(
                child: GestureDetector(
                  onTap: () {
                    profileViewModel.fetchProfileViewUserDataApi();
                  },
                  child: Icon(Icons.restart_alt_outlined, size: 30),
                ),
              ),
            );
          case Status.COMPLETED:
            // Debug print to check data
            print("Data: ${profileViewModel.profileviewUserData.data}");

            // Check if data is null
            if (profileViewModel.profileviewUserData.data?.data?.user == null) {
              return SizedBox(height: widget.screenHeight * 0.29, child: const Center(child: Text('No data found')));
            }

            final userData = profileViewModel.profileviewUserData.data!.data!.user!;
            final profileData = profileViewModel.profileviewUserData.data!.data!;

            String? profileImageUrl = userData.profilePicture?.url;
            String userName = userData.firstName ?? userData.lastName ?? '${userData.firstName ?? ''} ${userData.lastName ?? ''}'.trim();
            if (userName.isEmpty) userName = 'Unknown User';
            String userExperience = userData.experience?.toString() ?? '0';
            String userPhone = userData.phone ?? '0';
            String allSkillsCategory = profileData.skills?.where((skill) => skill.category != null).map((skill) => skill.category!).join(' ও ') ?? 'No skills';

            return Container(
              height: 245,
              // padding: EdgeInsets.all(widget.screenHeight * 0.02),
              decoration: BoxDecoration(
                color: AppColors.containerBackground(context),
                border: Border(
                  bottom: BorderSide(
                    color: AppColors.border(context),
                    width: 1.0, // or your desired width
                  ),
                ),
              ),
              child: DrawerProfileHeader(
                title: "$userName",
                rating: 0.0,
                phone: "$userPhone",
                skills: "$allSkillsCategory",
                onImageTap: () {
                  // if (imageUrl != null && imageUrl!.isNotEmpty) {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => FullScreenImage(imageUrl: "$profileImageUrl")));
                  // }
                },
                onCameraTap: (){},
                profileImage: "$profileImageUrl",
              ),
            );
          default:
            return Container();
        }
      },
    );
  }


  Widget _buildMenu(BuildContext context) {
    return Column(
      children: [
        SizedboxSpaccing.height025(context),
        GestureDetector(
          onTap: () {
            // Navigator.pushNamed(context, RoutesName.viewProfile);
          },
          child: _buildDrawerItem(CupertinoIcons.person, "View Profile"),
        ),

        GestureDetector(
          onTap: () {
            // Navigator.pushNamed(context, RoutesName.passwordChange);
          },
          child: _buildDrawerItem(Icons.lock_outline, "Change Password"),
        ),

        GestureDetector(
          onTap: () {
            // Navigator.pushNamed(context, RoutesName.paymentMethod);
          },
          child: _buildDrawerItem(Icons.payment, "Payment Method"),
        ),

        GestureDetector(
          onTap: () {
            // Navigator.pushNamed(context, RoutesName.viewEarn);
          },
          child: _buildDrawerItem(Icons.history, "View Earn"),
        ),

        GestureDetector(
          onTap: () {
            // Navigator.pushNamed(context, RoutesName.review);
          },
          child: _buildDrawerItem(Icons.star_border, "Reviews"),
        ),

        GestureDetector(
          onTap: () {
            // Navigator.pushNamed(context, RoutesName.support);
          },
          child: _buildDrawerItem(CupertinoIcons.question_circle, "Support"),
        ),

        SizedboxSpaccing.height025(context),
        GestureDetector(
          onTap: () {
            _showLogoutDialog();
          },
          child: Container(
            height: 48,
            width: widget.screenWidth * 0.85,
            decoration: BoxDecoration(color: AppColors.button(context), borderRadius: BorderRadius.circular(8)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.rotationY(3.1416),
                  child: Icon(Icons.logout, size: 18, color: AppColors.whiteColor),
                ),

                SizedboxSpaccing.width03(context),
                SizedboxSpaccing.width03(context),
                Text(
                  'Sign Out',
                  style: AppTextStyles.textSize16(context, weight: FontWeight.w600, color: AppColors.whiteColor),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }


  Widget _buildDrawerItem(IconData icon, String title) {
    return Container(
      height: 50,
      width: widget.screenWidth * 0.7,
      // color: Colors.green,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                height: 50,
                width: widget.screenWidth * 0.1,
                // color: Colors.red,
                color: Colors.transparent,
                child: Icon(icon, color: AppColors.textPrimary(context), size: 20),
              ),
              Container(
                height: 50,
                width: widget.screenWidth * 0.4,
                // color: Colors.yellow,
                color: Colors.transparent,
                alignment: Alignment.centerLeft,
                child: Text(title, style: AppTextStyles.textSize16(context, weight: FontWeight.w500)),
              ),
            ],
          ),
          Container(
            height: 50,
            width: widget.screenWidth * 0.1,
            color: Colors.transparent,
            child: Icon(Icons.arrow_forward_ios, color: AppColors.textPrimary(context), size: 14),
          ),
        ],
      ),
    );
  }

  // Logout confirmation dialog
  Future<void> _showLogoutDialog() async {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must tap button to dismiss
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.appBackground(context),

          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          insetPadding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02, vertical: screenHeight * 0.01),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 32,
                    width: 32,
                    decoration: BoxDecoration(color: AppColors.button(context).withOpacity(0.1), shape: BoxShape.circle),
                    child: Center(
                      child: Container(
                        height: 16,
                        width: 16,
                        decoration: BoxDecoration(color: AppColors.button(context), shape: BoxShape.circle),
                        child: Center(child: Icon(CupertinoIcons.exclamationmark, color: Colors.white, size: 10)),
                      ),
                    ),
                  ),
                  SizedboxSpaccing.width03(context),
                  Expanded(
                    child: Text('Are you sure you\'d like to Log Out?', style: AppTextStyles.textSize16(context, weight: FontWeight.w500)),
                  ),
                ],
              ),
              SizedboxSpaccing.height02(context),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(false),
                    child: Container(
                      width: screenWidth * 0.25,
                      height: 38,
                      decoration: BoxDecoration(
                        color: AppColors.textFieldFill(context),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(width: 1, color: AppColors.border(context)),
                      ),
                      child: Center(
                        child: Text('Cancel', style: AppTextStyles.textSize12(context, weight: FontWeight.w500)),
                      ),
                    ),
                  ),
                  SizedboxSpaccing.width03(context),
                  SizedboxSpaccing.width03(context),
                  GestureDetector(
                    onTap: () async {
                      await _performLogout();
                      // exit(0);
                    },
                    child: Container(
                      width: screenWidth * 0.25,
                      height: 38,
                      padding: EdgeInsets.symmetric(vertical: screenHeight * 0.008),
                      decoration: BoxDecoration(color: AppColors.button(context), borderRadius: BorderRadius.circular(8)),
                      child: Center(
                        child: Text(
                          'Log out',
                          style: AppTextStyles.textSize12(context, weight: FontWeight.w500, color: AppColors.whiteColor),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // Perform the actual logout
  Future<void> _performLogout() async {
    try {
      print("🔓 CustomDrawer: Starting logout process...");

      // Close the dialog first
      Navigator.of(context).pop();

      // Use the LoginLogoutViewModel's logout method which handles socket disconnection
      final loginLogoutViewModel = Provider.of<LoginLogoutViewModel>(context, listen: false);
      await loginLogoutViewModel.logoutUser(context);

      // Additional cleanup if needed
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove("isDeliveryPerson");

      print("🔓 CustomDrawer: Logout completed successfully");

    } catch (e) {
      print("🔥 CustomDrawer: Logout error - $e");

      // Show error message if needed
      if (mounted) {
        Utils.flushBarErrorMessage("Logout failed. Please try again.", context);
      }

      // Fallback: manual cleanup if socket logout fails
      try {
        final userViewModel = Provider.of<UserViewModel>(context, listen: false);
        final socketProvider = Provider.of<SocketProvider>(context, listen: false);

        // Get user data before clearing
        final currentUser = userViewModel.currentUser;
        final userId = currentUser?.data?.user?.userId ?? '';
        final userRole = currentUser?.data?.user?.role ?? '';

        // Disconnect socket manually
        if (userId.isNotEmpty && userRole.isNotEmpty) {
          await socketProvider.unregisterAndDisconnect(
            userId: userId,
            role: userRole,
          );
        }

        // Clear user data
        await userViewModel.remove();

        // Navigate to login
        if (mounted) {
          Navigator.pushNamedAndRemoveUntil(context, RoutesName.welcomeLoginSignup, (route) => false);
        }

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.remove("isDeliveryPerson");

      } catch (fallbackError) {
        print("🔥 CustomDrawer: Fallback logout also failed - $fallbackError");
      }
    }
}}
