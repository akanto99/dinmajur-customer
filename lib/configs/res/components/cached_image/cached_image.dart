import 'package:cached_network_image/cached_network_image.dart';
import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/sizedbox_spaccing.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Dynamic Cached Network Image Component
/// Reusable widget for loading images with caching support and quantity controls
class DynamicCachedImage extends StatelessWidget {
  /// Image URL to load
  final String? imageUrl;

  /// Quantity controls
  final int quantity;
  final VoidCallback onAdd;
  final VoidCallback onRemove;
  final VoidCallback onIncrease;
  final bool showRoomNumber;
  final String? roomNumberLabel;
  final Color Function(BuildContext) getButtonColor;
  final Color Function(BuildContext) getBorderColor;

  /// Width of the image container
  final double width;

  /// Height of the image container
  final double height;

  /// Border radius for the image
  final double borderRadius;

  /// Fallback icon when image is null or fails to load
  final IconData defaultIcon;

  /// Size of the fallback icon
  final double iconSize;

  /// Background color of the container
  final Color? backgroundColor;

  /// Box fit for the image
  final BoxFit fit;

  /// Loading indicator color
  final Color? loadingColor;

  /// Whether to show loading indicator
  final bool showLoadingIndicator;

  /// Custom placeholder widget (overrides default loading indicator)
  final Widget? customPlaceholder;

  /// Custom error widget (overrides default icon)
  final Widget? customErrorWidget;

  /// Memory cache height (optimization)
  final int? memCacheHeight;

  /// Memory cache width (optimization)
  final int? memCacheWidth;

  /// Disk cache max height
  final int? maxHeightDiskCache;

  /// Disk cache max width
  final int? maxWidthDiskCache;

  /// Fade in duration
  final Duration fadeInDuration;

  /// Fade out duration
  final Duration fadeOutDuration;

  /// Border width
  final double? borderWidth;

  /// Border color
  final Color? borderColor;

  /// Icon color
  final Color? iconColor;

  const DynamicCachedImage({
    Key? key,
    required this.imageUrl,
    required this.quantity,
    required this.onAdd,
    required this.onRemove,
    required this.onIncrease,
    this.showRoomNumber = false,
    this.roomNumberLabel,
    required this.getButtonColor,
    required this.getBorderColor,
    this.width = 70,
    this.height = 70,
    this.borderRadius = 8,
    this.defaultIcon = Icons.image,
    this.iconSize = 40,
    this.backgroundColor,
    this.fit = BoxFit.cover,
    this.loadingColor,
    this.showLoadingIndicator = true,
    this.customPlaceholder,
    this.customErrorWidget,
    this.memCacheHeight = 200,
    this.memCacheWidth = 200,
    this.maxHeightDiskCache = 400,
    this.maxWidthDiskCache = 400,
    this.fadeInDuration = const Duration(milliseconds: 300),
    this.fadeOutDuration = const Duration(milliseconds: 100),
    this.borderWidth,
    this.borderColor,
    this.iconColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: height+15,
          width: width,
          // color: AppColors.darkRedColor,
          child: Stack(
            children: [
              // Image Container
              Container(
                width: width,
                height: height,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(borderRadius),
                  color: backgroundColor ?? Colors.grey[200],
                  // border: borderWidth != null
                  //     ? Border.all(
                  //   color: borderColor ?? Colors.transparent,
                  //   width: borderWidth!,
                  // )
                  //     : null,
                ),
                child: _buildImageContent(context),
              ),

              // SizedBox(height: 8),

              // Quantity Controls
              Positioned(
                  bottom: 0,
                  child: Container(
                      width: width,
                      child: Center(child: _buildQuantityControls(context)))),
            ],
          ),
        ),
        if (roomNumberLabel != null && quantity > 0)...[
          SizedboxSpaccing.height005(context),
          Text(
            roomNumberLabel!,
            style: TextStyle(
              fontSize: 10,
              color: AppColors.buttonTextColor(context),
            ),
          ),
        ]

      ],
    );
  }

  Widget _buildImageContent(BuildContext context) {
    // Check if imageUrl is valid
    if (imageUrl == null || imageUrl!.isEmpty) {
      return _buildDefaultIcon();
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: CachedNetworkImage(
        imageUrl: imageUrl!,
        fit: fit,

        // Placeholder widget
        placeholder: customPlaceholder != null
            ? (context, url) => customPlaceholder!
            : (showLoadingIndicator
            ? (context, url) => _buildLoadingIndicator(context)
            : (context, url) => _buildDefaultIcon()),

        // Error widget
        errorWidget: customErrorWidget != null
            ? (context, url, error) => customErrorWidget!
            : (context, url, error) => _buildDefaultIcon(),

        // Cache configuration
        memCacheHeight: memCacheHeight,
        memCacheWidth: memCacheWidth,
        maxHeightDiskCache: maxHeightDiskCache,
        maxWidthDiskCache: maxWidthDiskCache,

        // Animation
        fadeInDuration: fadeInDuration,
        fadeOutDuration: fadeOutDuration,
      ),
    );
  }

  /// Build loading indicator
  Widget _buildLoadingIndicator(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            loadingColor ?? Colors.grey.shade400,
          ),
        ),
      ),
    );
  }

  /// Build default icon
  Widget _buildDefaultIcon() {
    return Icon(
      defaultIcon,
      size: iconSize,
      color: iconColor ?? Colors.grey,
    );
  }

  /// Build quantity controls (ADD button or +/- buttons)
  Widget _buildQuantityControls(BuildContext context) {
    if (quantity == 0) {
      // Show ADD button when quantity is 0
      return GestureDetector(
        onTap: onAdd,
        child: Container(
          width: 73,
          height: 30,
          decoration: BoxDecoration(
            color: getButtonColor(context),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              width: 1,
              color: AppColors.border(context)
            )
          ),
          child: Center(
            child: Text(
              'ADD',
              style: AppTextStyles.textSize14(context,weight: FontWeight.w700,color: AppColors.whiteColor),
            ),
          ),
        ),
      );
    }

    // Show +/- buttons when quantity > 0
    if (showRoomNumber) {
      // With room number label
      return Container(
        width: 73,
        height: 30,
        decoration: BoxDecoration(
            color: AppColors.containerBackground(context),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
                width: 1,
                color: AppColors.border(context)
            )
        ),
        child:      Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildQuantityButton(context,  FontAwesomeIcons.minus, onRemove),
            Container(
              // width: 30,
              child: Center(
                child: Text(
                  quantity.toString(),
                  style: AppTextStyles.textSize14(context,weight: FontWeight.w700),
                ),
              ),
            ),
            _buildQuantityButton(context, FontAwesomeIcons.plus, onIncrease,),
          ],
        ),
      );
    }

    // Without room number label
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildQuantityButton(context, Icons.remove, onRemove),
        Container(
          width: 30,
          child: Center(
            child: Text(
              quantity.toString(),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        _buildQuantityButton(context, Icons.add, onIncrease),
      ],
    );
  }

  /// Build individual quantity button (+ or -)
  Widget _buildQuantityButton(BuildContext context, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 25,
        height: 25,
        color: Colors.transparent,
        child: Icon(icon, size: 14),
      ),
    );
  }
}