import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';

class ServicesViewDetailsDialouge extends StatelessWidget {
  final String? imageUrl;
  final String serviceName;
  final double discountedPrice;
  final double originalPrice;
  final bool showDiscount;
  final String? description;
  final String? details;
  final VoidCallback onClose;
  final Color Function(BuildContext) getButtonColor;
  final Color Function(BuildContext) getBackgroundColor;
  final Color Function(BuildContext) getBorderColor;
  final Color Function(BuildContext) getTextColor;

  const ServicesViewDetailsDialouge({
    Key? key,
    this.imageUrl,
    required this.serviceName,
    required this.discountedPrice,
    required this.originalPrice,
    required this.showDiscount,
    this.description,
    this.details,
    required this.onClose,
    required this.getButtonColor,
    required this.getBackgroundColor,
    required this.getBorderColor,
    required this.getTextColor,
  }) : super(key: key);

  // ── Wraps plain text in a minimal HTML body so flutter_html renders it ──
  String _toHtml(String? raw, BuildContext context) {
    if (raw == null || raw.trim().isEmpty) return '';

    // Already looks like HTML (contains at least one tag)
    final bool looksLikeHtml = RegExp(r'<[a-zA-Z][^>]*>').hasMatch(raw);
    if (looksLikeHtml) return raw;

    // Plain text → wrap each line in <p> so spacing is consistent
    final lines = raw.split('\n').map((l) => l.trim()).where((l) => l.isNotEmpty).map((l) => '<p>$l</p>').join();
    return lines;
  }

  bool get _hasDescription => description != null && description!.trim().isNotEmpty;

  bool get _hasDetails => details != null && details!.trim().isNotEmpty;

  // ── Shared HTML style map ─────────────────────────────────────────────────

  Map<String, Style> _htmlStyle(BuildContext context) => {
    "body": Style(margin: Margins.zero, padding: HtmlPaddings.zero, color: getTextColor(context)),
    "p": Style(margin: Margins.only(bottom: 6), padding: HtmlPaddings.zero, color: getTextColor(context)),
    "strong": Style(color: getTextColor(context)),
    "em": Style(color: getTextColor(context)),
    "li": Style(color: getTextColor(context)),
    "h1": Style(color: getTextColor(context)),
    "h2": Style(color: getTextColor(context)),
    "h3": Style(color: getTextColor(context)),
    "h4": Style(color: getTextColor(context)),
    "h5": Style(color: getTextColor(context)),
    "h6": Style(color: getTextColor(context)),
  };

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Dialog(
      backgroundColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      insetPadding: EdgeInsets.zero,
      child: Container(
        width: screenWidth,
        height: screenHeight,
        decoration: BoxDecoration(color: getBackgroundColor(context)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildImageHeader(context),

            // ── Scrollable content ────────────────────────────────────────
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Service name
                    Text(serviceName, style: AppTextStyles.textSize20(context, weight: FontWeight.w700)),
                    const SizedBox(height: 16),

                    // ── Description ────────────────────────────────────────
                    if (_hasDescription) ...[
                      Text(
                        'Description',
                        style: AppTextStyles.textSize16(context, weight: FontWeight.w600, color: getTextColor(context)),
                      ),
                      const SizedBox(height: 6),
                      Html(data: _toHtml(description, context), style: _htmlStyle(context)),
                      const SizedBox(height: 12),
                    ],

                    if (_hasDetails) ...[
                      Text(
                        'Details',
                        style: AppTextStyles.textSize16(context, weight: FontWeight.w600, color: getTextColor(context)),
                      ),
                      const SizedBox(height: 6),
                      Html(data: _toHtml(details, context), style: _htmlStyle(context)),
                      const SizedBox(height: 12),
                    ],

                    // ── Empty state ────────────────────────────────────────
                    if (!_hasDescription && !_hasDetails)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 40),
                          child: Text('No details available', style: AppTextStyles.textSize14(context, color: getTextColor(context).withOpacity(0.5))),
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

  // ── Image header ──────────────────────────────────────────────────────────

  Widget _buildImageHeader(BuildContext context) {
    return Stack(
      children: [
        // Image
        Container(
          width: double.infinity,
          height: 200,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
            color: getBorderColor(context).withOpacity(0.1),
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
            child: imageUrl != null && imageUrl!.isNotEmpty
                ? Image.network(
                    imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => _buildPlaceholder(context),
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(getButtonColor(context))));
                    },
                  )
                : _buildPlaceholder(context),
          ),
        ),

        // Gradient overlay
        Container(
          width: double.infinity,
          height: 200,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
            gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.black.withOpacity(0.3), Colors.transparent, Colors.black.withOpacity(0.5)]),
          ),
        ),

        // Close button
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
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 2))],
              ),
              child: const Icon(Icons.close, size: 20, color: Colors.black87),
            ),
          ),
        ),

        // Price badge
        Positioned(
          bottom: 12,
          right: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: getButtonColor(context),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 2))],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '৳${discountedPrice.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white),
                ),
                if (showDiscount) ...[
                  const SizedBox(width: 8),
                  Text(
                    '৳${originalPrice.toStringAsFixed(2)}',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: Colors.white.withOpacity(0.8), decoration: TextDecoration.lineThrough),
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
    return Center(child: Icon(Icons.spa, size: 60, color: getBorderColor(context)));
  }
}
