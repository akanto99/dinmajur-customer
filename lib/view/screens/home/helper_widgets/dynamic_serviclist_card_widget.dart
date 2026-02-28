
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/components/cached_image/cached_image.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:flutter/material.dart';

/// Dynamic Service List Widget
/// Handles both flat lists (Beauty Salon) and grouped lists (House Keeper)
class DynamicServiceList<T, S> extends StatelessWidget {
  final List<T> categories;
  final Map<int, GlobalKey> categoryKeys;
  final double screenWidth;
  final double screenHeight;

  // For flat list (Beauty Salon)
  final List<S>? Function(T)? getItems;
  final String? Function(T)? getCategoryName;

  // For simple list (House Keeper)
  final bool isSimpleList;

  // Service card builder - UPDATED TO INCLUDE isLastItem
  final Widget Function(S service, double width, double height, bool isLastItem) buildServiceCard;


  // Text styles
  final TextStyle Function(BuildContext) categoryHeaderStyle;
  final TextStyle Function(BuildContext) emptyStateStyle;
  final Widget Function(BuildContext) emptyStateSpacing;

  const DynamicServiceList({
    Key? key,
    required this.categories,
    required this.categoryKeys,
    required this.screenWidth,
    required this.screenHeight,
    required this.buildServiceCard,
    required this.categoryHeaderStyle,
    required this.emptyStateStyle,
    required this.emptyStateSpacing,
    this.getItems,
    this.getCategoryName,
    this.isSimpleList = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) {
      return Center(child: Text('No services available', style: emptyStateStyle(context)));
    }

    return Container(
      width: screenWidth * 0.9,
      child: ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];

          if (isSimpleList) {
            // Simple list mode (House Keeper) - each category IS a service
            return Container(
                key: categoryKeys[index],
                child: buildServiceCard(category as S, screenWidth, screenHeight, false)
            );
          } else {
            // Grouped list mode (Beauty Salon) - categories contain items
            final items = getItems?.call(category) ?? [];
            final categoryName = getCategoryName?.call(category) ?? '';

            return Container(
              key: categoryKeys[index],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category Header
                  Text(categoryName, style: categoryHeaderStyle(context)),
                  Divider(height: 20,color: AppColors.border(context),),

                  // Services under this category - UPDATED TO PASS isLastItem
                  ...items.asMap().entries.map((entry) {
                    int itemIndex = entry.key;
                    S service = entry.value;
                    bool isLastItem = itemIndex == items.length - 1;

                    return buildServiceCard(service, screenWidth, screenHeight, isLastItem);
                  }),

                  emptyStateSpacing(context),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}

/// Dynamic Service Card Widget
/// Handles different service card layouts
class DynamicServiceCard extends StatelessWidget {
  final String? imageUrl;
  final IconData defaultIcon;
  final String serviceName;
  final String? viewDetailsText;
  final VoidCallback? onViewDetails;
  final double discountedPrice;
  final double originalPrice;
  final bool showDiscount;
  final int quantity;
  final VoidCallback onAdd;
  final VoidCallback onRemove;
  final VoidCallback onIncrease;
  final bool showRoomNumber;
  final bool? hasRoom;
  final bool? hasHour;
  final String? roomNumberLabel;
  final Color Function(BuildContext) getButtonColor;
  final Color Function(BuildContext) getBackgroundColor;
  final Color Function(BuildContext) getBorderColor;
  final Color Function(BuildContext) getSubtitleColor;
  final Color Function(BuildContext) getTextColor;
  final TextStyle Function(BuildContext, {FontWeight? weight, Color? color}) getTextStyle;
  final Widget Function(BuildContext) getSpacing;
  final bool isLastItem;

  const DynamicServiceCard({
    Key? key,
    required this.imageUrl,
    required this.defaultIcon,
    required this.serviceName,
    this.viewDetailsText,
    this.onViewDetails,
    required this.discountedPrice,
    required this.originalPrice,
    required this.showDiscount,
    required this.quantity,
    required this.onAdd,
    required this.onRemove,
    required this.onIncrease,
    this.hasRoom = false,
    this.hasHour = false,
    this.showRoomNumber = false,
    this.roomNumberLabel,
    required this.getButtonColor,
    required this.getBackgroundColor,
    required this.getBorderColor,
    required this.getSubtitleColor,
    required this.getTextColor,
    required this.getTextStyle,
    required this.getSpacing,
    this.isLastItem = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      // margin: EdgeInsets.only(bottom: 15),
      padding: isLastItem?EdgeInsets.only(top: 15,bottom: 25): EdgeInsets.symmetric(vertical: 15),
      decoration: BoxDecoration(
        color: getBackgroundColor(context),
        // borderRadius: BorderRadius.circular(12),
        // border: Border.all(color: getBorderColor(context)
        border: isLastItem
            ? null
            : Border(
          bottom: BorderSide(
            color: getBorderColor(context),
            width: 1,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [



          // Details
          Expanded(child: _buildDetails(context)),
          getSpacing(context),
          // Image with Quantity Controls
          DynamicCachedImage(
            imageUrl: imageUrl,
            width: 83,
            height: 73,
            borderRadius: 8,
            defaultIcon: defaultIcon,
            iconSize: 40,
            backgroundColor: Colors.grey[200],
            fit: BoxFit.cover,
            loadingColor: getButtonColor(context),
            iconColor: Colors.grey,
            showLoadingIndicator: true,
            // Quantity controls
            quantity: quantity,
            onAdd: onAdd,
            onRemove: onRemove,
            onIncrease: onIncrease,
            hasRoom: hasRoom,
            hasHour: hasHour,
            showRoomNumber: showRoomNumber,
            roomNumberLabel: roomNumberLabel,
            getButtonColor: getButtonColor,
            getBorderColor: getBorderColor,
            // Cache optimization
            memCacheHeight: 200,
            memCacheWidth: 200,
            maxHeightDiskCache: 400,
            maxWidthDiskCache: 400,
            // Smooth animations
            fadeInDuration: Duration(milliseconds: 300),
            fadeOutDuration: Duration(milliseconds: 100),
          ),

        ],
      ),
    );
  }

  Widget _buildDetails(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          serviceName,
          style: getTextStyle(context, weight: FontWeight.w500, color: getTextColor(context)),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),

        SizedBox(height: 4),
        Row(
          children: [
            Text(
              '৳${discountedPrice.toStringAsFixed(2)}',
              style: AppTextStyles.textSize14(context,weight: FontWeight.w500),
            ),
            if (showDiscount && originalPrice > discountedPrice) ...[
              SizedBox(width: 8),
              Text(
                '৳${originalPrice.toStringAsFixed(2)}',
                style: TextStyle(fontSize: 10, color: getSubtitleColor(context), decoration: TextDecoration.lineThrough),
              ),
            ],
          ],
        ),
        if (viewDetailsText != null && onViewDetails != null) ...[
          SizedBox(height: 4),
          GestureDetector(
            onTap: onViewDetails,
            child: Row(
              children: [
                Text(
                    viewDetailsText!,
                    style: AppTextStyles.textSize10(context,weight: FontWeight.w500,color: AppColors.buttonTextColor(context))
                ),
                Icon(Icons.chevron_right, size: 12, color: getButtonColor(context)),
              ],
            ),
          ),
        ],
      ],
    );
  }
}