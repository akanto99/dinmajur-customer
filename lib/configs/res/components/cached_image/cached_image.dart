import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Dynamic Cached Network Image Component
/// Reusable widget for loading images with caching support
class DynamicCachedImage extends StatelessWidget {
  /// Image URL to load
  final String? imageUrl;

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
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        color: backgroundColor ?? Colors.grey[200],
        border: borderWidth != null
            ? Border.all(
          color: borderColor ?? Colors.transparent,
          width: borderWidth!,
        )
            : null,
      ),
      child: _buildImageContent(context),
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
}