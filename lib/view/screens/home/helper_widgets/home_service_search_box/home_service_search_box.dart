import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/sizedbox_spaccing.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:dinmajur_customer/data/response/status.dart';
import 'package:dinmajur_customer/model/home_models/all_service_models/get_all_service_models.dart';
import 'package:dinmajur_customer/view/screens/home/all_service/widget/service_tap_handler.dart';
import 'package:dinmajur_customer/view_model/homeview_model/all_service_view_models/get_all_service_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Search box for the Home Screen — filters the already-fetched "All Home
/// Services" list by name/description and routes to the matching service's
/// screen on tap, via the same [navigateToService] logic used by the grid.
class HomeServiceSearchBox extends StatefulWidget {
  final String customerName;
  final String customerPhone;
  final String customerAddress;
  final Map<String, dynamic>? customerLocation;
  final bool hasValidLocation;
  final VoidCallback onLocationRequired;
  final Future<void> Function() onInstantBazarTap;

  const HomeServiceSearchBox({
    Key? key,
    required this.customerName,
    required this.customerPhone,
    required this.customerAddress,
    required this.customerLocation,
    required this.hasValidLocation,
    required this.onLocationRequired,
    required this.onInstantBazarTap,
  }) : super(key: key);

  @override
  State<HomeServiceSearchBox> createState() => _HomeServiceSearchBoxState();
}

class _HomeServiceSearchBoxState extends State<HomeServiceSearchBox> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  String _query = '';
  String? _loadingServiceId;

  // Typewriter animation
  static const List<String> _hintExamples = ['Facial', 'Kitchen Cleaning', 'AC Service'];
  int _hintIndex = 0;
  String _animatedHint = '';
  bool _showCursor = true;
  Timer? _cursorTimer;

  @override
  void initState() {
    super.initState();
    _cursorTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      if (mounted) setState(() => _showCursor = !_showCursor);
    });
    _runTypewriter();
  }

  void _runTypewriter() async {
    await Future.delayed(const Duration(milliseconds: 600));
    while (mounted) {
      final word = _hintExamples[_hintIndex];

      // Type out
      for (int i = 0; i <= word.length; i++) {
        if (!mounted) return;
        setState(() => _animatedHint = word.substring(0, i));
        await Future.delayed(const Duration(milliseconds: 85));
      }

      // Pause at full word
      await Future.delayed(const Duration(milliseconds: 1400));

      // Erase
      for (int i = word.length; i >= 0; i--) {
        if (!mounted) return;
        setState(() => _animatedHint = word.substring(0, i));
        await Future.delayed(const Duration(milliseconds: 45));
      }

      await Future.delayed(const Duration(milliseconds: 350));
      _hintIndex = (_hintIndex + 1) % _hintExamples.length;
    }
  }

  @override
  void dispose() {
    _cursorTimer?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  List<Datum> _filter(List<Datum> services) {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return [];
    return services.where((s) {
      if (s.id == '69eca7bdbe6d8b46e00655ed') return false;
      final name = (s.name ?? '').toLowerCase();
      final desc = (s.description ?? '').toLowerCase();
      final categoryMatch = (s.categories ?? []).any((c) => (c.name ?? '').toLowerCase().contains(q));
      return name.contains(q) || desc.contains(q) || categoryMatch;
    }).toList();
  }

  String _matchingCategories(Datum service) {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return '';
    return (service.categories ?? [])
        .where((c) => (c.name ?? '').toLowerCase().contains(q))
        .map((c) => c.name ?? '')
        .join(', ');
  }

  void _clearSearch() {
    _controller.clear();
    _focusNode.unfocus();
    setState(() => _query = '');
  }

  Future<void> _onServiceTap(Datum service) async {
    if (_loadingServiceId != null) return;

    if (!widget.hasValidLocation) {
      widget.onLocationRequired();
      return;
    }

    final slug = service.slug ?? '';
    if (slug == 'instant-bazar') {
      _clearSearch();
      await widget.onInstantBazarTap();
      return;
    }

    setState(() => _loadingServiceId = service.id);
    try {
      await navigateToService(
        context,
        service,
        customerName: widget.customerName,
        customerPhone: widget.customerPhone,
        customerAddress: widget.customerAddress,
        customerLocation: widget.customerLocation,
      );
      if (mounted) _clearSearch();
    } finally {
      if (mounted) setState(() => _loadingServiceId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Consumer<GetAllServiceViewModel>(
      builder: (context, viewModel, _) {
        final allServices = viewModel.getAllServicesData.status == Status.COMPLETED ? (viewModel.getAllServicesData.data?.data ?? <Datum>[]) : <Datum>[];
        final results = _filter(allServices);
        final showResults = _query.trim().isNotEmpty;

        return SizedBox(
          width: screenWidth * 0.9,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 46,
                decoration: BoxDecoration(
                  color: AppColors.containerBackground(context),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(width: 1.5, color: AppColors.border(context)),
                ),
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  style: AppTextStyles.textSize14(context, weight: FontWeight.w400),
                  decoration: InputDecoration(
                    hintText: _query.isEmpty
                        ? (_animatedHint.isEmpty ? "Search For '" : "Search For '$_animatedHint${_showCursor ? '|' : ''}'")
                        : '',
                    hintStyle: AppTextStyles.textSize14(context, color: AppColors.subtitle(context), weight: FontWeight.w400),
                    prefixIcon: Padding(
                      padding: const EdgeInsets.only(left: 12, right: 6),
                      child: Icon(Icons.search, size: 25, color: AppColors.textPrimary(context)),
                    ),
                    prefixIconConstraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                    suffixIcon: showResults
                        ? GestureDetector(
                            onTap: _clearSearch,
                            child: Icon(Icons.close, color: AppColors.textPrimary(context), size: 18),
                          )
                        : null,
                    border: OutlineInputBorder(borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                  onChanged: (value) => setState(() => _query = value),
                ),
              ),

              if (showResults) ...[
                SizedboxSpaccing.height015(context),
                Container(
                  constraints: const BoxConstraints(maxHeight: 280),
                  decoration: BoxDecoration(
                    color: AppColors.containerBackground(context),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(width: 1.5, color: AppColors.border(context)),
                  ),
                  child: results.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                          child: Row(
                            children: [
                              Icon(Icons.search_off_rounded, size: 18, color: AppColors.subtitle(context)),
                              const SizedBox(width: 8),
                              Text("No services found", style: AppTextStyles.textSize14(context, color: AppColors.subtitle(context))),
                            ],
                          ),
                        )
                      : ListView.separated(
                          shrinkWrap: true,
                          padding: EdgeInsets.zero,
                          itemCount: results.length,
                          separatorBuilder: (_, __) => Divider(height: 1, color: AppColors.border(context)),
                          itemBuilder: (context, index) {
                            final service = results[index];
                            final isLoading = _loadingServiceId == service.id;

                            final cats = _matchingCategories(service);
                            return ListTile(
                              dense: true,
                              onTap: () => _onServiceTap(service),
                              leading: SizedBox(
                                height: 36,
                                width: 36,
                                child: service.image?.url != null && service.image!.url!.isNotEmpty
                                    ? CachedNetworkImage(
                                        imageUrl: service.image!.url!,
                                        fit: BoxFit.contain,
                                        errorWidget: (context, url, error) => Icon(Icons.design_services_outlined, color: AppColors.subtitle(context)),
                                      )
                                    : Icon(Icons.design_services_outlined, color: AppColors.subtitle(context)),
                              ),
                              title: Text(service.name ?? '', style: AppTextStyles.textSize14(context, weight: FontWeight.w500)),
                              subtitle: cats.isNotEmpty
                                  ? Text(
                                      cats,
                                      style: AppTextStyles.textSize12(context, color: AppColors.subtitle(context)),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    )
                                  : null,
                              trailing: isLoading ? SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.buttonTextColor(context))) : null,
                            );
                          },
                        ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
