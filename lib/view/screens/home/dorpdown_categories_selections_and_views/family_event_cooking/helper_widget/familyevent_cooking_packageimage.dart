import 'package:cached_network_image/cached_network_image.dart';
import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:flutter/material.dart';

/// Custom widget for Family Event Cooking Package Image with Selection
/// Custom widget for Family Event Cooking Package Image with Selection
class FamilyEventCookingPackageImage extends StatelessWidget {
  final String? imageUrl;
  final bool isSelected;
  final bool canSelect;
  final VoidCallback onToggle;
  final Color Function(BuildContext) getButtonColor;
  final Color Function(BuildContext) getBorderColor;

  const FamilyEventCookingPackageImage({
    Key? key,
    required this.imageUrl,
    required this.isSelected,
    required this.canSelect,
    required this.onToggle,
    required this.getButtonColor,
    required this.getBorderColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 88, // 73 image + 15 button
          width: 83,
          child: Stack(
            children: [
              // Image Container with CachedNetworkImage
              Container(
                width: 83,
                height: 73,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[200],
                ),
                child: imageUrl != null && imageUrl!.isNotEmpty
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl: imageUrl!,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            getButtonColor(context),
                          ),
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Icon(
                      Icons.restaurant_menu,
                      size: 40,
                      color: Colors.grey,
                    ),
                  ),
                )
                    : Icon(Icons.restaurant_menu, size: 40, color: Colors.grey),
              ),

              // ADD/ADDED Button
              Positioned(
                bottom: 0,
                child: GestureDetector(
                  onTap: onToggle, // Remove the canSelect check here
                  child: Container(
                    width: 83,
                    child: Center(
                      child: Container(
                        width: 73,
                        height: 30,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.containerBackground(context)
                              : getButtonColor(context),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            width: 1,
                            color: isSelected
                                ? getButtonColor(context)
                                : AppColors.border(context),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            isSelected ? 'ADDED' : 'ADD',
                            style: AppTextStyles.textSize14(
                              context,
                              weight: FontWeight.w700,
                              color: isSelected
                                  ? AppColors.buttonTextColor(context)
                                  : AppColors.whiteColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}