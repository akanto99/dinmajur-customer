import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/sizedbox_spaccing.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:flutter/material.dart';

class DrawerProfileHeader extends StatelessWidget {
  final String title;
  final double rating; // Changed from String stars to double rating
  final String phone;
  final String skills;
  final VoidCallback? onImageTap;
  final VoidCallback? onCameraTap;
  final String? profileImage;
  final String? coverImage;

  const DrawerProfileHeader({
    Key? key,
    required this.title,
    required this.rating, // Changed parameter name
    required this.phone,
    required this.skills,
    this.onImageTap,
    this.onCameraTap,
    this.profileImage,
    this.coverImage,
  }) : super(key: key);

  // Method to build star rating widget
  Widget _buildStarRating(BuildContext context, double rating) {
    List<Widget> stars = [];

    for (int i = 1; i <= 5; i++) {
      if (i <= rating.floor()) {
        // Full star
        stars.add(Icon(
          Icons.star,
          color: Colors.amber,
          size: 16,
        ));
      } else if (i == rating.floor() + 1 && rating % 1 != 0) {
        // Half star
        stars.add(Icon(
          Icons.star_half,
          color: Colors.amber,
          size: 16,
        ));
      } else {
        // Empty star
        stars.add(Icon(
          Icons.star_border,
          color: Colors.grey,
          size: 16,
        ));
      }
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ...stars,
        SizedboxSpaccing.width02(context),
        Text(
          rating.toStringAsFixed(1),
          style: AppTextStyles.poppins14(context, weight: FontWeight.w400),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width * 1;
    final screenHeight = MediaQuery.of(context).size.height * 1;
    return Column(
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
                        image: profileImage != null
                            ? DecorationImage(
                            image: NetworkImage(profileImage!),
                            fit: BoxFit.cover
                        )
                            : null
                    ),
                    child: profileImage == null
                        ? Icon(Icons.person, size: 40, color: AppColors.form_hover(context))
                        : null,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 8,
              right: 0,
              child: GestureDetector(
                onTap: onCameraTap,
                child: Container(
                  height: 25,
                  width: 25,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.border(context)
                  ),
                  child: Icon(Icons.camera_alt, size: 15),
                ),
              ),
            ),
          ],
        ),
        SizedboxSpaccing.height015(context),
        Text(
          title,
          style: AppTextStyles.poppins18(context, weight: FontWeight.w600),
        ),
        SizedboxSpaccing.height005(context),
        Text(
            phone,
            style: AppTextStyles.poppins14(context, weight: FontWeight.w400)
        ),
        SizedboxSpaccing.height005(context),
        // Dynamic star rating
        _buildStarRating(context, rating),
        SizedboxSpaccing.height015(context),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                " $skills ",
                style: AppTextStyles.poppins14(context,
                    weight: FontWeight.w400,),
                textAlign: TextAlign.center,
                softWrap: true,
                overflow: TextOverflow.visible,
                maxLines: null,
              ),
            ),
          ],
        ),
      ],
    );
  }
}