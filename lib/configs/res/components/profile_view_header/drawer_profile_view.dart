import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/sizedbox_spaccing.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:dinmajur_customer/configs/utils/routes/routes_name.dart';
import 'package:dinmajur_customer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class DrawerProfileHeader extends StatelessWidget {
  final String title;
  final String phone;
  final VoidCallback? onImageTap;
  final VoidCallback? onCameraTap;
  final String? profileImage;
  final String? coverImage;
    final double rating;

  const DrawerProfileHeader({
    Key? key,
    required this.title,
    required this.phone,
    this.onImageTap,
    this.onCameraTap,
    this.profileImage,
    this.coverImage,
    required this.rating, // Changed parameter name

  }) : super(key: key);
  // Method to build star rating widget
  Widget _buildStarRating(BuildContext context, double rating) {
    List<Widget> stars = [];

    for (int i = 1; i <= 5; i++) {
      if (i <= rating.floor()) {
        // Full star
        stars.add(Icon(Icons.star, color: Colors.amber, size: 16));
      } else if (i == rating.floor() + 1 && rating % 1 != 0) {
        // Half star
        stars.add(Icon(Icons.star_half, color: Colors.amber, size: 16));
      } else {
        // Empty star
        stars.add(Icon(Icons.star_border, color: Colors.grey, size: 16));
      }
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [...stars, SizedboxSpaccing.width02(context), Text(rating.toStringAsFixed(1), style: AppTextStyles.textSize14(context, weight: FontWeight.w400))],
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width * 1;
    final screenHeight = MediaQuery.of(context).size.height * 1;
    return   Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Stack(
          children: [
            GestureDetector(
              onTap: onImageTap,
              child: Container(
                height: 96,
                width: 96,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.textFieldFill(context),
                    border: Border.all(
                        width: 2,
                        color: AppColors.border(context)
                    )
                ),

                child: Center(
                  child: Container(
                    height: 86,
                    width: 86,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.textFieldFill(context),
                        border: Border.all(
                            width: 1,
                            color: AppColors.button(context)
                        ),
                        image: DecorationImage(image: NetworkImage(profileImage!),fit: BoxFit.cover)
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 8,
              right: 0,
              child:  GestureDetector(
                onTap: onCameraTap,
                child: Container(
                  height: 25,
                  width: 25,
                  decoration: BoxDecoration(shape: BoxShape.circle,
                      color: AppColors.border(context)
                  ),
                  child: Icon(Icons.camera_alt,size: 15,),
                ),
              ),
            ),
          ],
        ),
        SizedboxSpaccing.height01(context),
        Text(title,
          style: AppTextStyles.textSize18(context,weight: FontWeight.w600),
        ),
        SizedboxSpaccing.height01(context),
        Text(phone, style:AppTextStyles.textSize14(context,weight: FontWeight.w400)),
        SizedboxSpaccing.height01(context),
        _buildStarRating(context, rating),

        // GestureDetector(
        //   onTap: () {
        //     Navigator.pushNamed(context, RoutesName.profileView);
        //   },
        //   child: Container(
        //     height: 35,
        //     width: 185,
        //     decoration: BoxDecoration(
        //         color: AppColors.textFieldFill(context),
        //         borderRadius: BorderRadius.circular(12),
        //         border: Border.all(
        //             width: 1,
        //             color: AppColors.border(context)
        //         )
        //     ),
        //     child: Row(
        //       mainAxisAlignment: MainAxisAlignment.center,
        //       children: [
        //         Icon(Icons.remove_red_eye, size: 20, color: AppColors.subtitle(context)),
        //
        //         SizedboxSpaccing.width03(context),
        //         Text('View Profile', style: AppTextStyles.poppins16(context, weight: FontWeight.w600, color: AppColors.subtitle(context))),
        //       ],
        //     ),
        //   ),
        // ),
      ],
    );
  }
}



class ProfileHeader extends StatelessWidget {
  final String title;
  final String phone;
  final String order;
  final String Wishlist;
  final String reviews;
  final bool isActive; // Added isActive parameter
  final VoidCallback? onImageTap;
  final VoidCallback? onCameraTap;
  final String? profileImage;
  final String? coverImage;

  const ProfileHeader({
    Key? key,
    required this.title,
    required this.phone,
    required this.order,
    required this.Wishlist,
    required this.reviews,
    required this.isActive, // Added required isActive
    this.onImageTap,
    this.onCameraTap,
    this.profileImage,
    this.coverImage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width * 1;
    final screenHeight = MediaQuery.of(context).size.height * 1;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedboxSpaccing.height025(context),
        Container(
          width: screenWidth * 0.9,
          padding: EdgeInsets.all(screenHeight * 0.02),
          decoration: BoxDecoration(
            color: AppColors.containerBackground(context),
            border: Border.all(width: 1, color: AppColors.border(context)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Stack(
                children: [
                  GestureDetector(
                    onTap: onImageTap,
                    child: Container(
                      height: 80,
                      width: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.textFieldFill(context),
                        border: Border.all(width: 2, color: AppColors.button(context)),
                        image: profileImage != null ? DecorationImage(image: NetworkImage(profileImage!), fit: BoxFit.cover) : null,
                      ),
                      child: profileImage == null ? Icon(Icons.person, size: 40, color: AppColors.form_hover(context)) : null,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: onCameraTap,
                      child: Container(
                        height: 25,
                        width: 25,
                        decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.button(context)),
                        child: Icon(Icons.camera_alt, size: 15, color: AppColors.whiteColor),
                      ),
                    ),
                  ),
                ],
              ),
              SizedboxSpaccing.width03(context),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.textSize18(context, weight: FontWeight.w600),
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedboxSpaccing.height005(context),
                    Text(
                      phone,
                      style: AppTextStyles.textSize14(context, weight: FontWeight.w400),
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedboxSpaccing.height005(context),
                    // Status container
                    Container(
                      height: 24,
                      width: 80,
                      decoration: BoxDecoration(color: _getStatusColor(), borderRadius: BorderRadius.circular(100)),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.circle, size: 10, color: Colors.green),
                            SizedboxSpaccing.width02(context),
                            Text(_getStatus(), style: AppTextStyles.textSize12(context, weight: FontWeight.w400,color: AppColors.blackColor)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedboxSpaccing.height025(context),
        _buildStatsCard(context),
        SizedboxSpaccing.height025(context),
      ],
    );
  }
  Widget _buildStatsCard(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width * 1;
    final screenHeight = MediaQuery.of(context).size.height * 1;
    return Container(
      width: screenWidth* 0.9,
      padding: EdgeInsets.all(screenHeight * 0.02),
      decoration: BoxDecoration(
        color: AppColors.containerBackground(context),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildStatItem(context, order, AppLocalizations.of(context)!.order),
          _buildStatItem(context, Wishlist, AppLocalizations.of(context)!.wishlist),
          _buildStatItem(context, reviews, AppLocalizations.of(context)!.reviews),
        ],
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String value, String label) {
    final screenWidth = MediaQuery.of(context).size.width * 1;
    final screenHeight = MediaQuery.of(context).size.height * 1;
    return Container(
      height: 76,
      width: screenWidth * 0.25,
      decoration: BoxDecoration(
        color: AppColors.appBackground(context),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: AppTextStyles.textSize20(
              context,
              weight: FontWeight.w500,
              color: const Color(0xff666666),
            ),
          ),
          Text(
            label,
            style: AppTextStyles.textSize12(context, weight: FontWeight.w400),
          ),
        ],
      ),
    );
  }
  // Fixed _getStatus method
  String _getStatus() {
    return isActive ? "Active" : "Offline";
  }

  // Fixed _getStatusColor method
  Color _getStatusColor() {
    return isActive ? Color(0xffDCFCE7) : Colors.grey.withOpacity(0.9);
  }
}
