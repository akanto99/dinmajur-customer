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

  // Service card builder
  final Widget Function(S service, double width, double height) buildServiceCard;

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
      return Center(
        child: Text(
          'No services available',
          style: emptyStateStyle(context),
        ),
      );
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
              child: buildServiceCard(category as S, screenWidth, screenHeight),
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
                  Padding(
                    padding: EdgeInsets.only(bottom: 10),
                    child: Text(
                      categoryName,
                      style: categoryHeaderStyle(context),
                    ),
                  ),

                  // Services under this category
                  ...items.map((service) =>
                      buildServiceCard(service, screenWidth, screenHeight)
                  ),

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
  final String? roomNumberLabel;
  final Color Function(BuildContext) getButtonColor;
  final Color Function(BuildContext) getBackgroundColor;
  final Color Function(BuildContext) getBorderColor;
  final Color Function(BuildContext) getSubtitleColor;
  final Color Function(BuildContext) getTextColor;
  final TextStyle Function(BuildContext, {FontWeight? weight, Color? color}) getTextStyle;
  final Widget Function(BuildContext) getSpacing;

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
    this.showRoomNumber = false,
    this.roomNumberLabel,
    required this.getButtonColor,
    required this.getBackgroundColor,
    required this.getBorderColor,
    required this.getSubtitleColor,
    required this.getTextColor,
    required this.getTextStyle,
    required this.getSpacing,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 15),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: getBackgroundColor(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: getBorderColor(context)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          _buildImage(context),
          getSpacing(context),

          // Details
          Expanded(
            child: _buildDetails(context),
          ),

          // Quantity Controls
        ],
      ),
    );
  }

  Widget _buildImage(BuildContext context) {
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey[200],
      ),
      child: imageUrl != null
          ? ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          imageUrl!,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Icon(
            defaultIcon,
            size: 40,
            color: Colors.grey,
          ),
        ),
      )
          : Icon(defaultIcon, size: 40, color: Colors.grey),
    );
  }
  Widget _buildDetails(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          serviceName,
          style: getTextStyle(context, weight: FontWeight.w600, color: getTextColor(context)),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (viewDetailsText != null && onViewDetails != null) ...[
                  SizedBox(height: 4),
                  GestureDetector(
                    onTap: onViewDetails,
                    child: Row(
                      children: [
                        Text(
                          viewDetailsText!,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: getButtonColor(context),
                          ),
                        ),
                        Icon(Icons.chevron_right, size: 16, color: getButtonColor(context)),
                      ],
                    ),
                  ),
                ],
                SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      '৳${discountedPrice.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: getButtonColor(context),
                      ),
                    ),
                    if (showDiscount && originalPrice > discountedPrice) ...[
                      SizedBox(width: 8),
                      Text(
                        '৳${originalPrice.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 14,
                          color: getSubtitleColor(context),
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
            _buildQuantityControls(context),
          ],
        ),
      ],
    );
  }

  Widget _buildQuantityControls(BuildContext context) {
    if (quantity == 0) {
      return GestureDetector(
        onTap: onAdd,
        child: Container(
          width: 70,
          height: 25,
          decoration: BoxDecoration(
            color: getButtonColor(context),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              'ADD +',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      );
    }

    if (showRoomNumber) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (roomNumberLabel != null)
            Text(
              roomNumberLabel!,
              style: TextStyle(
                fontSize: 10,
                color: getButtonColor(context),
              ),
            ),
          SizedBox(height: 4),
          Row(
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
          ),
        ],
      );
    }

    return Row(
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

  Widget _buildQuantityButton(BuildContext context, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 25,
        height: 25,
        decoration: BoxDecoration(
          border: Border.all(color: getBorderColor(context)),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Icon(icon, size: 16),
      ),
    );
  }
}