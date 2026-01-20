import 'dart:io';
import 'dart:typed_data';
import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/components/dynamic_image_picker/dynamic_image_picker.dart';
import 'package:dinmajur_customer/configs/res/components/full_screen_image/full_image_viewer.dart';
import 'package:dinmajur_customer/configs/res/components/profile_view_header/drawer_profile_view.dart';
import 'package:dinmajur_customer/configs/res/sizedbox_spaccing.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:dinmajur_customer/configs/utils/routes/routes_name.dart';
import 'package:dinmajur_customer/configs/utils/utils.dart';
import 'package:dinmajur_customer/data/response/status.dart';
import 'package:dinmajur_customer/l10n/app_localizations.dart';
import 'package:dinmajur_customer/socket_connection_model/socket_provider_services/socket_provider.dart';
import 'package:dinmajur_customer/view/navigation_bar.dart';
import 'package:dinmajur_customer/view/screens/home/drawer/policies/cooking_policy.dart';
import 'package:dinmajur_customer/view_model/authview_model/login_logout_view_model.dart';
import 'package:dinmajur_customer/view_model/homeview_model/drawer_view_model/profile_update_view_model/profile_image_update_view_model.dart';
import 'package:dinmajur_customer/view_model/homeview_model/profileview_model/profileview_model.dart';
import 'package:dinmajur_customer/view_model/userview_model/userview_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../configs/res/components/header_appbar.dart';

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
    return Container(
      width: widget.screenWidth,
      color: AppColors.appBackground(context),
      child: Drawer(
        backgroundColor: AppColors.appBackground(context),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Container(height: 60,
                    color: AppColors.containerBackground(context),
                    child: AppBarHeader(AppLocalizations.of(context)!.profile_menu)),
              ),
         Expanded(child: SingleChildScrollView(
           child: Column(
             children: [
               _buildHeader(),
               _buildMenu(context),
               // SizedboxSpaccing.height025(context)
             ],
           ),
         )),


            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final patchprofileImageUpdateViewMode = Provider.of<PatchprofileImageUpdateViewModel>(context);
    return Consumer<ProfileViewViewModel>(
      builder: (context, profileViewModel, _) {
        // Debug print to check the status
        print("ProfileViewModel Status: ${profileViewModel.profileviewUserData.status}");

        switch (profileViewModel.profileviewUserData.status) {
          case Status.LOADING:
            return Container(height: 220,
                color: AppColors.containerBackground(context),
                child: Center(child: Container(height: 15, width: 50, child: LoadingAnimationWidget.progressiveDots(color: AppColors.button(context), size: 45))));

          case Status.ERROR:
            return Container(
              height: 220,
              color: AppColors.containerBackground(context),
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
              return SizedBox(height: widget.screenHeight * 0.29, child:  Center(child: Text(AppLocalizations.of(context)!.no_data_found,)));
            }

            final userData = profileViewModel.profileviewUserData.data!.data!.user!;
            final profileData = profileViewModel.profileviewUserData.data!.data!;

            String? profileImageUrl = userData.profilePicture?.url;
            String userName = '${userData.fullName ?? ''}'.trim();
            if (userName.isEmpty) userName = 'Unknown User';
            String userPhone = userData.phone ?? '0';

            return Container(
              height: 220,
              decoration: BoxDecoration(
                color: AppColors.containerBackground(context),
                border: Border(
                  bottom: BorderSide(
                    color: AppColors.border(context),
                    width: 1.0,
                  ),
                )
              ),
              child: DrawerProfileHeader(
                title: "$userName",
                phone: "$userPhone",
                rating: 0.0,
                onImageTap: () {
                  // if (imageUrl != null && imageUrl!.isNotEmpty) {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => FullScreenImage(imageUrl: "$profileImageUrl")));
                  // }
                },
                onCameraTap: patchprofileImageUpdateViewMode.profileImageUpdateLoading ? () {} : _handleImagePick,
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
    final screenWidth = MediaQuery.of(context).size.width * 1;
    final screenHeight = MediaQuery.of(context).size.height * 1;
    return Container(
        width: screenWidth,
        decoration: BoxDecoration(color: AppColors.containerBackground(context)),
    child: Center(
      child: Container(
        width: screenWidth* 0.85,
        padding: EdgeInsets.symmetric(vertical:screenHeight * 0.02),
        decoration: BoxDecoration(
          color: AppColors.containerBackground(context),
        ),
        child: Column(
          children: [
            // Container(
            //   height: 30,
            //   // color: Colors.yellow,
            //   color: Colors.transparent,
            //   alignment: Alignment.topLeft,
            //   child: Text(AppLocalizations.of(context)!.account_settings, style: AppTextStyles.textSize16(context, weight: FontWeight.w600)),
            // ),
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, RoutesName.viewProfile);
              },
              child: _buildDrawerItem(CupertinoIcons.person, AppLocalizations.of(context)!.view_profile),
            ),

            // GestureDetector(
            //   onTap: () {
            //     Navigator.pushNamed(context, RoutesName.paymentMethod);
            //   },
            //   child: _buildDrawerItem(Icons.payment, AppLocalizations.of(context)!.payment_method),
            // ),
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, RoutesName.addlocation);
              },
              child: _buildDrawerItem(Icons.maps_home_work_outlined, AppLocalizations.of(context)!.save_address),
            ),
            // GestureDetector(
            //   onTap: () {
            //     Navigator.pushNamed(context, RoutesName.ordersScreen);
            //   },
            //   child: _buildDrawerItem(Icons.shopping_bag_outlined, AppLocalizations.of(context)!.order),
            // ),
            // GestureDetector(
            //   onTap: () {
            //     Navigator.pushNamed(context, RoutesName.promoCodes);
            //   },
            //   child: _buildDrawerItem(Icons.view_sidebar_outlined, AppLocalizations.of(context)!.promo_codes),
            // ),
            GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => NavigationScreen(initialIndex: 2))),
              child: _buildDrawerItem(Icons.shopping_bag_outlined, AppLocalizations.of(context)!.order),
            ),
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, RoutesName.offers);
              },
              child: _buildDrawerItem(Icons.local_offer_outlined, AppLocalizations.of(context)!.offers),
            ),

            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, RoutesName.review);
              },
              child: _buildDrawerItem(Icons.star_border, AppLocalizations.of(context)!.reviews),
            ),
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, RoutesName.support);
              },
              child: _buildDrawerItem(CupertinoIcons.question_circle, AppLocalizations.of(context)!.support),
            ),
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, RoutesName.language);
              },
              child: _buildDrawerItem(CupertinoIcons.globe, AppLocalizations.of(context)!.language),
            ),
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, RoutesName.termsAndCondition);
              },
              child: _buildDrawerItem(Icons.description, AppLocalizations.of(context)!.terms_conditions),
            ),
            GestureDetector(
              onTap: () {

                Navigator.pushNamed(context, RoutesName.privacyPolicy);
              },
              child: _buildDrawerItem(FontAwesomeIcons.shieldHalved, AppLocalizations.of(context)!.privacy_policy),
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
                      AppLocalizations.of(context)!.sign_out,
                      style: AppTextStyles.textSize16(context, weight: FontWeight.w600, color: AppColors.whiteColor),
                    ),
                  ],
                ),
              ),
            ),
            SizedboxSpaccing.height025(context),
            Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 0,
              runSpacing: 8,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, RoutesName.cookiesPolicyScreen);
                  },
                  child: Container(
                   padding: EdgeInsets.symmetric(vertical: 5,),
                    color: Colors.transparent,
                    child: Text(
                      "Cooking Policy",
                      style: AppTextStyles.textSize12(context, weight: FontWeight.w400, color: AppColors.button(context)),
                    ),
                  ),
                ),
                Text(
                  " | ",
                  style: AppTextStyles.textSize14(context, weight: FontWeight.w400, color: AppColors.button(context)),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, RoutesName.deliveryPolicyScreen);
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 5,),
                    color: Colors.transparent,
                    child: Text(
                      "Delivery Policy",
                      style: AppTextStyles.textSize12(context, weight: FontWeight.w400, color: AppColors.button(context)),
                    ),
                  ),
                ),
                Text(
                  " | ",
                  style: AppTextStyles.textSize14(context, weight: FontWeight.w400, color: AppColors.button(context)),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, RoutesName.refundPolicyScreen);
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 5,),
                    color: Colors.transparent,
                    child: Text(
                      "Refund Policy",
                      style: AppTextStyles.textSize12(context, weight: FontWeight.w400, color: AppColors.button(context)),
                    ),
                  ),
                ),
                Text(
                  " | ",
                  style: AppTextStyles.textSize14(context, weight: FontWeight.w400, color: AppColors.button(context)),
                ),
                GestureDetector(
                  onTap: () => _launchURL('https://docs.google.com/document/d/157rhznRzYesD7MfCrKj_RGfTm77DxfciFKlEvr8p5Ro/edit?usp=sharing'),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 5,),
                    color: Colors.transparent,
                    child: Text(
                      "Terms & Conditions",
                      style: AppTextStyles.textSize12(context, weight: FontWeight.w400, color: AppColors.button(context)),
                    ),
                  ),
                ),
                Text(
                  " | ",
                  style: AppTextStyles.textSize14(context, weight: FontWeight.w400, color: AppColors.button(context)),
                ),
                GestureDetector(
                  onTap: () => _launchURL('https://docs.google.com/document/d/1wrU4DFajwzoO3kE5BERxNSnotvuqMbVP_JLn7iNxgqc/edit?usp=sharing'),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 5),
                    color: Colors.transparent,
                    child: Text(
                      "Privacy Policy",
                      style: AppTextStyles.textSize12(context, weight: FontWeight.w400, color: AppColors.button(context)),
                    ),
                  ),
                ),
              ],
            ),
            // SizedboxSpaccing.height025(context),

          ],
        ),
      ),
    )
    );
  }

  Future<void> _launchURL(String urlString) async {
    try {
      final Uri url = Uri.parse(urlString);
      if (await canLaunchUrl(url)) {
        await launchUrl(
          url,
          mode: LaunchMode.externalApplication, // Opens in browser
        );
      } else {
        if (mounted) {
          Utils.flushBarErrorMessage("Could not open the link", context);
        }
      }
    } catch (e) {
      print("Error launching URL: $e");
      if (mounted) {
        Utils.flushBarErrorMessage("Could not open the link", context);
      }
    }
  }
  Widget _buildDrawerItem(IconData icon, String title) {
    return Container(
      height: 50,
      // width: widget.screenWidth * 0.7,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            width: 1.0,
            color: AppColors.border(context),
          ),
        ),
      ),
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
                    child: Text(AppLocalizations.of(context)!.logout_confirm, style: AppTextStyles.textSize16(context, weight: FontWeight.w500)),
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
                        child: Text(AppLocalizations.of(context)!.cancel, style: AppTextStyles.textSize12(context, weight: FontWeight.w500)),
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
                          AppLocalizations.of(context)!.log_out,
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
          1,
          context
      );
    }
  }

  // Perform the actual logout
  Future<void> _performLogout() async {
    try {
      final loginLogoutViewModel = Provider.of<LoginLogoutViewModel>(context, listen: false);
      await loginLogoutViewModel.logoutUser(context);
    } catch (e) {
      print("🔥 CustomDrawer: Logout error - $e");

      // Only close dialog on error
      if (mounted) {
        // Try to close dialog if it's still open
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }

        Utils.flushBarErrorMessage("Logout failed. Please try again.", context);
      }
    }
  }

}
