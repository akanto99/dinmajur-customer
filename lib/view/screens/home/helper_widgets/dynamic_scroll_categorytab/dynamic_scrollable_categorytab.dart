import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CategoryTabs<T> extends StatefulWidget {
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
  final Color Function(BuildContext) getSelectedIconColor;
  final Color Function(BuildContext) getSelectedImageColor;
  final TextStyle Function(BuildContext, bool isSelected) getTextStyle;
  final IconData defaultIcon;
  final bool supportSvg;
  final double horizontalPadding;
  final double iconSize;
  final double iconPadding;

  const CategoryTabs({
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
    required this.getSelectedIconColor,
    required this.getSelectedImageColor,
    this.height = 105,
    this.defaultIcon = Icons.category,
    this.supportSvg = true,
    this.horizontalPadding = 0.05,
    this.iconSize = 48,
    this.iconPadding = 12,
  }) : super(key: key);

  @override
  State<CategoryTabs<T>> createState() => _CategoryTabsState<T>();
}

class _CategoryTabsState<T> extends State<CategoryTabs<T>> {

  @override
  Widget build(BuildContext context) {
    if (widget.categories.isEmpty) return SizedBox();

    final screenWidth = MediaQuery.of(context).size.width;

    return Column(
      children: [
        Container(
          height: widget.height,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: screenWidth * widget.horizontalPadding),
            itemCount: widget.categories.length,
            itemBuilder: (context, index) {
              final category = widget.categories[index];
              final isSelected = widget.selectedIndex == index;
              final imageUrl = widget.getImageUrl(category);
              final name = widget.getName(category);

              final isSvg = widget.supportSvg && (imageUrl?.toLowerCase().endsWith('.svg') ?? false);

              return GestureDetector(
                onTap: () {
                  print("---------------------$index");
                  widget.onCategoryTap(index);
                },
                child: Container(
                  margin: EdgeInsets.only(right: 15),
                  child: Column(
                    children: [
                      Container(
                        width: widget.iconSize,
                        height: widget.iconSize,
                        decoration: BoxDecoration(
                          color: isSelected ? widget.getButtonColor(context) : widget.getBackgroundColor(context),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? widget.getButtonColor(context) : widget.getBorderColor(context),
                            width: 2,
                          ),
                        ),
                        child: _buildCategoryIcon(context, imageUrl, isSvg, isSelected),
                      ),
                      SizedBox(height: 8),
                      SizedBox(
                        width: 70,
                        child: Text(
                          name,
                          style: widget.getTextStyle(context, isSelected),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryIcon(BuildContext context, String? imageUrl, bool isSvg, bool isSelected) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return Icon(
        widget.defaultIcon,
        color: isSelected ? AppColors.whiteColor : AppColors.blackColor,
      );
    }

    return ClipOval(
      child: isSvg
          ? Padding(
        padding: EdgeInsets.all(widget.iconPadding),
        child: SvgPicture.network(
          imageUrl,
          colorFilter: ColorFilter.mode(
            isSelected ? widget.getSelectedImageColor(context) : widget.getTextColor(context),
            BlendMode.srcIn,
          ),
        ),
      )
          : Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Icon(
          widget.defaultIcon,
          color: widget.getSelectedImageColor(context),
        ),
      ),
    );
  }
}