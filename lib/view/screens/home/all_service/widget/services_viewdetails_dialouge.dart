import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:dinmajur_customer/model/home_models/all_service_models/services_view_getallcategories_model.dart' hide Image;

class ServicesViewDetailsDialouge extends StatefulWidget {
  final String? imageUrl;
  final String serviceName;
  final double discountedPrice;
  final double originalPrice;
  final bool showDiscount;

  // ── HTML content fields ──────────────────────────────────────────────────
  final String? description;
  final String? overview;
  final String? steps;
  final String? products;
  final String? benefits;
  final String? instructions;
  final String? details;

  // ── Structured fields ────────────────────────────────────────────────────
  final int? durationInMin;
  final List<Faq>? faqs;

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
    this.overview,
    this.steps,
    this.products,
    this.benefits,
    this.instructions,
    this.details,
    this.durationInMin,
    this.faqs,
    required this.onClose,
    required this.getButtonColor,
    required this.getBackgroundColor,
    required this.getBorderColor,
    required this.getTextColor,
  }) : super(key: key);

  @override
  State<ServicesViewDetailsDialouge> createState() => _ServicesViewDetailsDialougeState();
}

class _ServicesViewDetailsDialougeState extends State<ServicesViewDetailsDialouge> {
  // Tracks which FAQ items are expanded
  final Set<int> _expandedFaqs = {};

  // ── Helpers ───────────────────────────────────────────────────────────────

  String _toHtml(String? raw) {
    if (raw == null || raw.trim().isEmpty) return '';
    final bool looksLikeHtml = RegExp(r'<[a-zA-Z][^>]*>').hasMatch(raw);
    if (looksLikeHtml) return raw;
    final lines = raw
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .map((l) => '<p>$l</p>')
        .join();
    return lines;
  }

  bool _hasContent(String? value) => value != null && value.trim().isNotEmpty;

  bool get _hasDuration => widget.durationInMin != null && widget.durationInMin! > 0;

  bool get _hasFaqs => widget.faqs != null && widget.faqs!.isNotEmpty;

  String _formatDuration(int minutes) {
    if (minutes < 60) return '$minutes min';
    final h = minutes ~/ 60;
    final m = minutes % 60;
    if (m == 0) return '${h}h';
    return '${h}h ${m}min';
  }

  Map<String, Style> _htmlStyle(BuildContext context) => {
    "body": Style(margin: Margins.zero, padding: HtmlPaddings.zero, color: widget.getTextColor(context)),
    "p": Style(margin: Margins.only(bottom: 6), padding: HtmlPaddings.zero, color: widget.getTextColor(context)),
    "strong": Style(color: widget.getTextColor(context)),
    "em": Style(color: widget.getTextColor(context)),
    "li": Style(color: widget.getTextColor(context)),
    "ul": Style(color: widget.getTextColor(context)),
    "ol": Style(color: widget.getTextColor(context)),
    "h1": Style(color: widget.getTextColor(context)),
    "h2": Style(color: widget.getTextColor(context)),
    "h3": Style(color: widget.getTextColor(context)),
    "h4": Style(color: widget.getTextColor(context)),
    "h5": Style(color: widget.getTextColor(context)),
    "h6": Style(color: widget.getTextColor(context)),
  };

  // ── Section configs: label + icon for each HTML field ────────────────────
  static const List<Map<String, dynamic>> _htmlSections = [
    {'key': 'description', 'label': 'Description', 'icon': Icons.description_outlined},
    {'key': 'overview', 'label': 'Overview', 'icon': Icons.info_outline},
    {'key': 'steps', 'label': 'Steps', 'icon': Icons.format_list_numbered_outlined},
    {'key': 'products', 'label': 'Products Used', 'icon': Icons.inventory_2_outlined},
    {'key': 'benefits', 'label': 'Benefits', 'icon': Icons.star_outline},
    {'key': 'instructions', 'label': 'Instructions', 'icon': Icons.assignment_outlined},
    {'key': 'details', 'label': 'Details', 'icon': Icons.article_outlined},
  ];

  String? _fieldValue(String key) {
    switch (key) {
      case 'description': return widget.description;
      case 'overview': return widget.overview;
      case 'steps': return widget.steps;
      case 'products': return widget.products;
      case 'benefits': return widget.benefits;
      case 'instructions': return widget.instructions;
      case 'details': return widget.details;
      default: return null;
    }
  }

  bool get _hasAnyContent {
    return _htmlSections.any((s) => _hasContent(_fieldValue(s['key'] as String))) ||
        _hasDuration ||
        _hasFaqs;
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Dialog(
      backgroundColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      insetPadding: EdgeInsets.symmetric(horizontal: screenHeight * 0.02, vertical: screenHeight * 0.02),
      // insetPadding: EdgeInsets.zero,
      child: Container(
        width: screenWidth,
        height: screenHeight,
        decoration: BoxDecoration(color:AppColors.containerBackground(context),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildImageHeader(context),

            // ── Scrollable content ──────────────────────────────────────
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Service name
                    Text(
                      widget.serviceName,
                      style: AppTextStyles.textSize20(context, weight: FontWeight.w700),
                    ),
                    const SizedBox(height: 12),

                    // ── Duration chip ──────────────────────────────────
                    if (_hasDuration) ...[
                      _buildDurationChip(context),
                      const SizedBox(height: 16),
                    ],

                    // ── HTML sections ──────────────────────────────────
                    ..._htmlSections.expand((section) {
                      final value = _fieldValue(section['key'] as String);
                      if (!_hasContent(value)) return <Widget>[];
                      return [
                        _buildSectionHeader(
                          context,
                          label: section['label'] as String,
                          icon: section['icon'] as IconData,
                        ),
                        const SizedBox(height: 6),
                        Html(
                          data: _toHtml(value),
                          style: _htmlStyle(context),
                        ),
                        const SizedBox(height: 16),
                      ];
                    }),

                    // ── FAQs ───────────────────────────────────────────
                    if (_hasFaqs) ...[
                      _buildSectionHeader(
                        context,
                        label: 'FAQs',
                        icon: Icons.quiz_outlined,
                      ),
                      const SizedBox(height: 8),
                      _buildFaqList(context),
                      const SizedBox(height: 16),
                    ],

                    // ── Empty state ────────────────────────────────────
                    if (!_hasAnyContent)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 40),
                          child: Text(
                            'No details available',
                            style: AppTextStyles.textSize14(
                              context,
                              color: widget.getTextColor(context).withOpacity(0.5),
                            ),
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

  // ── Duration chip ─────────────────────────────────────────────────────────

  Widget _buildDurationChip(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.border(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(  color: AppColors.border(context),),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.access_time, size: 16, color: widget.getButtonColor(context)),
          const SizedBox(width: 6),
          Text(
            'Duration: ${_formatDuration(widget.durationInMin!)}',
            style: AppTextStyles.textSize14(
              context,
              weight: FontWeight.w500,
              color: AppColors.buttonTextColor(context),
            ),
          ),
        ],
      ),
    );
  }

  // ── Section header ────────────────────────────────────────────────────────

  Widget _buildSectionHeader(BuildContext context, {required String label, required IconData icon}) {
    return Row(
      children: [
        Icon(icon, size: 18, color: widget.getButtonColor(context)),
        const SizedBox(width: 6),
        Text(
          label,
          style: AppTextStyles.textSize16(
            context,
            weight: FontWeight.w600,
            color: widget.getTextColor(context),
          ),
        ),
      ],
    );
  }

  // ── FAQ list ──────────────────────────────────────────────────────────────

  Widget _buildFaqList(BuildContext context) {
    final faqs = widget.faqs!;
    return Column(
      children: List.generate(faqs.length, (i) {
        final faq = faqs[i];
        final isExpanded = _expandedFaqs.contains(i);
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            border: Border.all(color: widget.getBorderColor(context)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Question row (tappable)
              InkWell(
                onTap: () {
                  setState(() {
                    if (isExpanded) {
                      _expandedFaqs.remove(i);
                    } else {
                      _expandedFaqs.add(i);
                    }
                  });
                },
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          faq.question ?? '',
                          style: AppTextStyles.textSize14(
                            context,
                            weight: FontWeight.w600,
                            color: widget.getTextColor(context),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      AnimatedRotation(
                        turns: isExpanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 200),
                        child: Icon(
                          Icons.keyboard_arrow_down,
                          size: 20,
                          color: widget.getButtonColor(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Answer (animated)
              AnimatedCrossFade(
                firstChild: const SizedBox(width: double.infinity),
                secondChild: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Divider(color: widget.getBorderColor(context), height: 1),
                      const SizedBox(height: 10),
                      Text(
                        faq.answer ?? '',
                        style: AppTextStyles.textSize14(
                          context,
                          color: widget.getTextColor(context).withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                crossFadeState: isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 200),
              ),
            ],
          ),
        );
      }),
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
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
            color: widget.getBorderColor(context).withOpacity(0.1),
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
            child: widget.imageUrl != null && widget.imageUrl!.isNotEmpty
                ? Image.network(
              widget.imageUrl!,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => _buildPlaceholder(context),
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(widget.getButtonColor(context)),
                  ),
                );
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
            borderRadius: const BorderRadius.only(
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

        // Close button
        Positioned(
          top: 12,
          right: 12,
          child: GestureDetector(
            onTap: widget.onClose,
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
                    offset: const Offset(0, 2),
                  )
                ],
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
              color: widget.getButtonColor(context),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                )
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '৳${widget.discountedPrice.toStringAsFixed(2)}',
                  style: AppTextStyles.textSize18(context, weight: FontWeight.w700, color: Colors.white),
                ),
                if (widget.showDiscount) ...[
                  const SizedBox(width: 8),
                  Text(
                    '৳${widget.originalPrice.toStringAsFixed(2)}',
                    style: AppTextStyles.textSize12(context, weight: FontWeight.w400, color: Colors.white.withOpacity(0.8)).copyWith(
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
      child: Icon(Icons.spa, size: 60, color: widget.getBorderColor(context)),
    );
  }
}