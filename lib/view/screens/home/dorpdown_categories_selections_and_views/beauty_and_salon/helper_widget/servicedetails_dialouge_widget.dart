import 'package:dinmajur_customer/configs/utils/amount_formatter/amount_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';

class ServiceDetailsDialog extends StatelessWidget {
  final String? imageUrl;
  final String serviceName;
  final double discountedPrice;
  final double originalPrice;
  final bool showDiscount;
  final String? details;
  final VoidCallback onClose;
  final Color Function(BuildContext) getButtonColor;
  final Color Function(BuildContext) getBackgroundColor;
  final Color Function(BuildContext) getBorderColor;
  final Color Function(BuildContext) getTextColor;

  const ServiceDetailsDialog({
    Key? key,
    this.imageUrl,
    required this.serviceName,
    required this.discountedPrice,
    required this.originalPrice,
    required this.showDiscount,
    this.details,
    required this.onClose,
    required this.getButtonColor,
    required this.getBackgroundColor,
    required this.getBorderColor,
    required this.getTextColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Dialog(
      backgroundColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      insetPadding: EdgeInsets.symmetric(horizontal: screenHeight * 0.02, vertical: screenHeight * 0.02),
      child: Container(
        width: screenWidth,
        constraints: BoxConstraints(maxHeight: screenHeight * 0.85),
        decoration: BoxDecoration(
          color: getBackgroundColor(context),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Image Header with Close Button and Price
            _buildImageHeader(context),

            // Scrollable Details Content
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Service Name
                    Text(
                      serviceName,
                      style: AppTextStyles.textSize20(context, weight: FontWeight.w700),
                    ),
                    SizedBox(height: 16),

                    // HTML Content - Render exactly as admin sets it
                    if (details != null && details!.isNotEmpty)
                      Html(
                        data: details,
                        style: {
                          // Only set basic color to match theme
                          "body": Style(
                            margin: Margins.zero,
                            padding: HtmlPaddings.zero,
                            color: getTextColor(context),
                          ),
                          // Let all other tags (p, strong, em, h1-h6, ul, ol, li)
                          // render with their default HTML styling
                        },
                      )
                    else
                      Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 40),
                          child: Text(
                            'No details available',
                            style: AppTextStyles.textSize14(context, color: getTextColor(context).withOpacity(0.5)),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageHeader(BuildContext context) {
    return Stack(
      children: [
        // Image Container
        Container(
          width: double.infinity,
          height: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
            color: getBorderColor(context).withOpacity(0.1),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
            child: imageUrl != null && imageUrl!.isNotEmpty
                ? Image.network(
              imageUrl!,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => _buildPlaceholder(context),
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(getButtonColor(context)),
                  ),
                );
              },
            )
                : _buildPlaceholder(context),
          ),
        ),

        // Gradient Overlay for better text visibility
        Container(
          width: double.infinity,
          height: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.3),
                Colors.transparent,
                Colors.black.withOpacity(0.5),
              ],
            ),
          ),
        ),

        // Close Button (Top Right)
        Positioned(
          top: 12,
          right: 12,
          child: GestureDetector(
            onTap: onClose,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(Icons.close, size: 20, color: Colors.black87),
            ),
          ),
        ),

        // Price Container (Bottom Right)
        Positioned(
          bottom: 12,
          right: 12,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: getButtonColor(context),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  // '৳${discountedPrice.toStringAsFixed(2)}',
                  '৳${AmountFormatter.format(discountedPrice)}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                if (showDiscount) ...[
                  SizedBox(width: 8),
                  Text(
                    '৳${AmountFormatter.format(originalPrice)}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withOpacity(0.8),
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceholder(BuildContext context) {
    return Center(
      child: Icon(
        Icons.spa,
        size: 60,
        color: getBorderColor(context),
      ),
    );
  }
}