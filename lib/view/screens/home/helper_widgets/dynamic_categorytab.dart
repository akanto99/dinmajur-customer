import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// A reusable category tabs widget that can display either icons or images
/// with optional SVG support
class DynamicCategoryTabs<T> extends StatelessWidget {
  final List<T> categories;
  final int selectedIndex;
  final Function(int) onCategoryTap;
  final String Function(T) getName;
  final String? Function(T) getImageUrl;
  final double height;
  final Color Function(BuildContext) getButtonColor;
  final Color Function(BuildContext) getBackgroundColor;
  final Color Function(BuildContext) getBorderColor;
  final Color Function(BuildContext) getTextColor;
  final TextStyle Function(BuildContext, bool isSelected) getTextStyle;
  final IconData defaultIcon;
  final bool supportSvg;
  final double horizontalPadding;
  final double iconSize;
  final double iconPadding;

  const DynamicCategoryTabs({
    Key? key,
    required this.categories,
    required this.selectedIndex,
    required this.onCategoryTap,
    required this.getName,
    required this.getImageUrl,
    required this.getButtonColor,
    required this.getBackgroundColor,
    required this.getBorderColor,
    required this.getTextColor,
    required this.getTextStyle,
    this.height = 110,
    this.defaultIcon = Icons.category,
    this.supportSvg = true,
    this.horizontalPadding = 0.05,
    this.iconSize = 60,
    this.iconPadding = 12,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) return SizedBox();

    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      height: height,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: screenWidth * horizontalPadding),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = selectedIndex == index;
          final imageUrl = getImageUrl(category);
          final name = getName(category);

          // Check if the URL is an SVG (only if SVG support is enabled)
          final isSvg = supportSvg && (imageUrl?.toLowerCase().endsWith('.svg') ?? false);

          return GestureDetector(
            onTap: () => onCategoryTap(index),
            child: Container(
              margin: EdgeInsets.only(right: 10),
              child: Column(
                children: [
                  // Category Icon/Image
                  Container(
                    width: iconSize,
                    height: iconSize,
                    decoration: BoxDecoration(
                      color: isSelected ? getButtonColor(context).withOpacity(0.1) : getBackgroundColor(context),
                      shape: BoxShape.circle,
                      border: Border.all(color: isSelected ? getButtonColor(context) : getBorderColor(context), width: 2),
                    ),
                    child: _buildCategoryIcon(context, imageUrl, isSvg, isSelected),
                  ),
                  SizedBox(height: 8),
                  // Category Name
                  SizedBox(
                    width: 80,
                    child: Text(name, style: getTextStyle(context, isSelected), textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoryIcon(BuildContext context, String? imageUrl, bool isSvg, bool isSelected) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return Icon(defaultIcon, color: getButtonColor(context));
    }

    return ClipOval(
      child: isSvg
          ? Padding(
              padding: EdgeInsets.all(iconPadding),
              child: SvgPicture.network(imageUrl, colorFilter: ColorFilter.mode(isSelected ? getButtonColor(context) : getTextColor(context), BlendMode.srcIn)),
            )
          : Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Icon(defaultIcon, color: getButtonColor(context)),
              // loadingBuilder: (context, child, loadingProgress) {
              //   if (loadingProgress == null) return child;
              //   return const Center(child: CircularProgressIndicator(strokeWidth: 2));
              // },
            ),
    );
  }
}
