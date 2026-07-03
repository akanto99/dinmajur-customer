import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:dinmajur_customer/configs/utils/amount_formatter/amount_formatter.dart';
import 'package:flutter/material.dart';

/// Dynamic Bottom Cart Bar Widget
/// A reusable cart bar that displays total services, price, and savings
class DynamicBottomCartBar extends StatelessWidget {
  final int totalServices;
  final double totalPrice;
  final double savedAmount;
  final VoidCallback onCartTap;
  final double screenWidth;
  final double screenHeight;

  // Style customization
  final Color Function(BuildContext) getButtonColor;
  final Color Function(BuildContext) getBlackColor;
  final Color Function(BuildContext) getWhiteColor;
  final TextStyle Function(BuildContext, {FontWeight? weight, Color? color}) getTextStyle;

  // Optional customization
  final String cartButtonText;
  final IconData cartIcon;
  final bool showShadow;
  final double horizontalPaddingMultiplier;
  final double verticalPadding;

  const DynamicBottomCartBar({
    Key? key,
    required this.totalServices,
    required this.totalPrice,
    required this.savedAmount,
    required this.onCartTap,
    required this.screenWidth,
    required this.screenHeight,
    required this.getButtonColor,
    required this.getBlackColor,
    required this.getWhiteColor,
    required this.getTextStyle,
    this.cartButtonText = 'Cart',
    this.cartIcon = Icons.arrow_forward,
    this.showShadow = true,
    this.horizontalPaddingMultiplier = 0.02,
    this.verticalPadding = 10,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Don't show if no services selected
    if (totalServices == 0) return SizedBox();

    return Container(
      width: screenWidth,
      padding: EdgeInsets.symmetric(horizontal: screenHeight * horizontalPaddingMultiplier, vertical: verticalPadding),
      decoration: BoxDecoration(
        color: getButtonColor(context),
        boxShadow: showShadow ? [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: Offset(0, -5))] : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Price Information
          _buildPriceInfo(context),

          // Cart Button
          _buildCartButton(context),
        ],
      ),
    );
  }

  Widget _buildPriceInfo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Service count - UPDATED TEXT
        Text(
          'Total Services ($totalServices Item${totalServices > 1 ? 's' : ''})',
          style: getTextStyle(context, color: getWhiteColor(context)),
        ),
        SizedBox(height: 4),

        // Price and savings
        Row(
          children: [
            // Total price
            Text(
              // '৳${totalPrice.toStringAsFixed(2)}',
              '৳${AmountFormatter.format(totalPrice)}',
              style: getTextStyle(context, weight: FontWeight.w700, color: getWhiteColor(context)),
            ),

            // Saved amount (if any)
            if (savedAmount > 0) ...[
              SizedBox(width: 8),
              Text(
                'Saved ৳${AmountFormatter.format(savedAmount)}',
                style: AppTextStyles.textSize12(context, weight: FontWeight.w600, color: getWhiteColor(context)),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildCartButton(BuildContext context) {
    return GestureDetector(
      onTap: onCartTap,
      child: Container(
        width: 110,
        height: 40,
        decoration: BoxDecoration(
          color: getBlackColor(context),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(width: 1, color: getWhiteColor(context)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              cartButtonText,
              style: AppTextStyles.textSize16(context, weight: FontWeight.w600, color: getWhiteColor(context)),
            ),
            SizedBox(width: 8),
            Icon(cartIcon, color: getWhiteColor(context), size: 20),
          ],
        ),
      ),
    );
  }
}

/// Extension for easier usage with service quantities map
extension CartCalculations on Map<String, int> {
  /// Get total number of unique services (entries with value > 0)
  /// This counts unique items/services, not the total quantity
  int get totalServices => entries.where((entry) => entry.value > 0).length;

  /// Get total number of items (sum of all quantities)
  /// This counts the total quantity across all services
  int get totalItems => values.fold(0, (sum, qty) => sum + qty);
}