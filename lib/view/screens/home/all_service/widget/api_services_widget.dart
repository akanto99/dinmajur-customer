
import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/sizedbox_spaccing.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:dinmajur_customer/data/response/status.dart';
import 'package:dinmajur_customer/model/home_models/all_service_models/get_all_service_models.dart';
import 'package:dinmajur_customer/view/screens/home/all_service/widget/service_tap_handler.dart';
import 'package:dinmajur_customer/view_model/homeview_model/all_service_view_models/get_all_service_view_model.dart';
import 'package:dinmajur_customer/view_model/homeview_model/profileview_model/profileview_model.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';

class AllServicesGridWidget extends StatefulWidget {
  final String? selectedServiceId;
  final String customerName;
  final String customerPhone;
  final String customerAddress;
  final Map<String, dynamic>? customerLocation;

  /// Passed from HomeScreen to handle location guard
  final bool hasValidLocation;
  final VoidCallback onLocationRequired;

  /// Callback for instant-bazar slug — handled entirely in HomeScreen
  final Future<void> Function() onInstantBazarTap;

  /// Slug currently loading (set by HomeScreen for instant-bazar)
  final String? loadingServiceSlug;

  const AllServicesGridWidget({
    Key? key,
    this.selectedServiceId,
    required this.customerName,
    required this.customerPhone,
    required this.customerAddress,
    required this.customerLocation,
    required this.hasValidLocation,
    required this.onLocationRequired,
    required this.onInstantBazarTap,
    this.loadingServiceSlug,
  }) : super(key: key);

  @override
  State<AllServicesGridWidget> createState() => _AllServicesGridWidgetState();
}

class _AllServicesGridWidgetState extends State<AllServicesGridWidget> {
  /// Tracks which service card is in a loading state (by id)
  String? _loadingServiceId;

  Future<void> _handleServiceTap(Datum service) async {
    // Prevent double-tap
    if (_loadingServiceId != null) return;
    // Also block if HomeScreen is already loading instant-bazar
    if (widget.loadingServiceSlug != null) return;

    // Location guard
    if (!widget.hasValidLocation) {
      widget.onLocationRequired();
      return;
    }

    final slug = service.slug ?? '';

    // ── instant-bazar: delegate entirely to HomeScreen ──
    if (slug == 'instant-bazar') {
      await widget.onInstantBazarTap();
      return;
    }

    // ── All other slugs: coverage check + route by slug ──
    setState(() => _loadingServiceId = service.id);

    try {
      // ── Build customer data from profile ──
      final profileViewModel = Provider.of<ProfileViewViewModel>(context, listen: false);
      String customerName = widget.customerName;
      String customerPhone = widget.customerPhone;
      String customerAddress = widget.customerAddress;
      Map<String, dynamic>? customerLocation = widget.customerLocation;

      if (profileViewModel.profileviewUserData.status == Status.COMPLETED) {
        final userData = profileViewModel.profileviewUserData.data?.data;
        customerName = userData?.user?.fullName ?? customerName;
        customerPhone = userData?.user?.phone ?? customerPhone;
        customerAddress = userData?.addresses?.fullAddress ?? customerAddress;
        final addr = userData?.addresses;
        if (addr != null) {
          customerLocation = {
            "fullAddress": addr.fullAddress ?? '',
            "country": addr.country ?? '',
            "city": addr.city ?? '',
            "geoLocation": {"type": addr.geoLocation?.type ?? "Point", "coordinates": addr.geoLocation?.coordinates ?? [], "timestamp": DateTime.now().toUtc().toIso8601String()},
          };
        }
      }

      await navigateToService(
        context,
        service,
        customerName: customerName,
        customerPhone: customerPhone,
        customerAddress: customerAddress,
        customerLocation: customerLocation,
      );
    } catch (e) {
    } finally {
      if (mounted) {
        setState(() => _loadingServiceId = null);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Consumer<GetAllServiceViewModel>(
      builder: (context, viewModel, _) {
        switch (viewModel.getAllServicesData.status) {
          case Status.LOADING:
            return Container(
              width: screenWidth * 0.9,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "All Home Services",
                    style: AppTextStyles.textSize16(context, weight: FontWeight.w600, color: AppColors.textPrimary(context)),
                  ),
                  SizedboxSpaccing.height025(context),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(3, (_) => _buildShimmerCard(context)),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(3, (_) => _buildShimmerCard(context)),
                  ),
                ],
              ),
            );

          case Status.ERROR:
            return SizedBox.shrink();

          case Status.COMPLETED:
            final services = viewModel.getAllServicesData.data?.data ?? [];
            if (services.isEmpty) return SizedBox.shrink();

            return Container(
              width: screenWidth * 0.9,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "All Home Services",
                    style: AppTextStyles.textSize16(context, weight: FontWeight.w600, color: AppColors.textPrimary(context)),
                  ),
                  SizedboxSpaccing.height025(context),
                  _buildServicesGrid(context, services),
                  SizedboxSpaccing.height025(context),
                ],
              ),
            );

          default:
            return SizedBox.shrink();
        }
      },
    );
  }

  static const int _visibleLimit = 8;

  Widget _buildServicesGrid(BuildContext context, List<Datum> services) {
    final filteredServices = services.where((s) => s.id != '69eca7bdbe6d8b46e00655ed').toList();

    final visibleServices = filteredServices.take(_visibleLimit).toList();
    final hiddenServices = filteredServices.skip(_visibleLimit).toList();

    // Build a flat list of 9 slots: 8 services + optional "More" tile
    final List<Widget> tiles = visibleServices
        .map((s) => _buildServiceCard(context, s))
        .toList();

    if (hiddenServices.isNotEmpty) {
      tiles.add(_buildMoreCard(context, hiddenServices));
    }

    // Lay tiles out in rows of 3
    List<Widget> rows = [];
    for (int i = 0; i < tiles.length; i += 3) {
      final rowTiles = tiles.skip(i).take(3).toList();
      rows.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...rowTiles,
            ...List.generate(3 - rowTiles.length, (_) => const SizedBox(width: 105)),
          ],
        ),
      );
      if (i + 3 < tiles.length) rows.add(const SizedBox(height: 24));
    }

    return Column(children: rows);
  }

  Widget _buildMoreCard(BuildContext context, List<Datum> hiddenServices) {
    return GestureDetector(
      onTap: () => _showMoreServicesSheet(context, hiddenServices),
      child: Column(
        children: [
          Container(
            height: 105,
            width: 105,
            decoration: BoxDecoration(
              color: AppColors.containerBackground(context),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(width: 1, color: AppColors.border(context)),
            ),
            child: Center(
              child: Icon(Icons.apps_rounded, size: 36, color: AppColors.textPrimary(context)),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: 105,
            child: Text(
              'More',
              textAlign: TextAlign.center,
              style: AppTextStyles.textSize12(context, weight: FontWeight.w600, color: AppColors.textPrimary(context)),
            ),
          ),
        ],
      ),
    );
  }

  void _showMoreServicesSheet(BuildContext context, List<Datum> services) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _MoreServicesSheet(
        services: services,
        onServiceTap: _handleServiceTap,
        loadingServiceId: _loadingServiceId,
        loadingServiceSlug: widget.loadingServiceSlug,
        selectedServiceId: widget.selectedServiceId,
      ),
    );
  }
  Widget _buildServiceCard(BuildContext context, Datum service) {
    final isSelected = widget.selectedServiceId == service.id;

    // A card is "loading" if it's the tapped card OR if HomeScreen is loading
    // instant-bazar and this card has that slug
    final isLoading = _loadingServiceId == service.id || (widget.loadingServiceSlug == 'instant-bazar' && service.slug == 'instant-bazar');

    return GestureDetector(
      onTap: () => _handleServiceTap(service),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 105,
                width: 105,
                decoration: BoxDecoration(
                  color: AppColors.containerBackground(context),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    width: isLoading ? 2 : 1,
                    color: isLoading
                        ? AppColors.textPrimary(context)
                        : isSelected
                        ? AppColors.textPrimary(context)
                        : AppColors.border(context),
                  ),
                ),
                child: Center(
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: isLoading ? 0.3 : 1.0,
                    child: SizedBox(
                      height: 80,
                      width: 80,
                      child: service.image?.url != null && service.image!.url!.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: service.image!.url!,
                              fit: BoxFit.contain,
                              errorWidget: (context, url, error) => Icon(Icons.design_services_outlined, color: AppColors.subtitle(context), size: 32),
                            )
                          : Icon(Icons.design_services_outlined, color: AppColors.subtitle(context), size: 32),
                    ),
                  ),
                ),
              ),

              if (isLoading)
                Container(
                  height: 105,
                  width: 105,
                  decoration: BoxDecoration(color: AppColors.containerBackground(context).withOpacity(0.5), borderRadius: BorderRadius.circular(12)),
                  child: Center(
                    child: SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.textPrimary(context))),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: 105,
            child: Text(
              service.name ?? '',
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.textSize12(context, weight: isLoading ? FontWeight.w600 : FontWeight.w500, color: AppColors.textPrimary(context)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerCard(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 100,
          width: 100,
          decoration: BoxDecoration(color: AppColors.border(context), borderRadius: BorderRadius.circular(12)),
        ),
        const SizedBox(height: 8),
        Container(
          height: 12,
          width: 60,
          decoration: BoxDecoration(color: AppColors.border(context), borderRadius: BorderRadius.circular(4)),
        ),
      ],
    );
  }
}

// ── Bottom sheet shown when "More" is tapped ─────────────────────────────────
class _MoreServicesSheet extends StatelessWidget {
  final List<Datum> services;
  final Future<void> Function(Datum) onServiceTap;
  final String? loadingServiceId;
  final String? loadingServiceSlug;
  final String? selectedServiceId;

  const _MoreServicesSheet({
    required this.services,
    required this.onServiceTap,
    required this.loadingServiceId,
    required this.loadingServiceSlug,
    required this.selectedServiceId,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: screenHeight * 0.55),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.containerBackground(context),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.only(top: 12, left: 20, right: 20, bottom: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // drag handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: AppColors.border(context), borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('All Services', style: AppTextStyles.textSize16(context, weight: FontWeight.w600)),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Icon(Icons.close, size: 22, color: AppColors.textPrimary(context)),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Flexible(
              child: SingleChildScrollView(
                child: _buildGrid(context, screenWidth),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGrid(BuildContext context, double screenWidth) {
    List<Widget> rows = [];
    for (int i = 0; i < services.length; i += 3) {
      final rowItems = services.skip(i).take(3).toList();
      rows.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...rowItems.map((s) => _buildCard(context, s)),
            ...List.generate(3 - rowItems.length, (_) => const SizedBox(width: 95)),
          ],
        ),
      );
      if (i + 3 < services.length) rows.add(const SizedBox(height: 20));
    }
    return Column(children: rows);
  }

  Widget _buildCard(BuildContext context, Datum service) {
    final isLoading = loadingServiceId == service.id ||
        (loadingServiceSlug == 'instant-bazar' && service.slug == 'instant-bazar');
    final isSelected = selectedServiceId == service.id;

    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        onServiceTap(service);
      },
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 95,
                width: 95,
                decoration: BoxDecoration(
                  color: AppColors.containerBackground(context),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    width: isLoading || isSelected ? 2 : 1,
                    color: isLoading || isSelected ? AppColors.textPrimary(context) : AppColors.border(context),
                  ),
                ),
                child: Center(
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: isLoading ? 0.3 : 1.0,
                    child: SizedBox(
                      height: 70,
                      width: 70,
                      child: service.image?.url != null && service.image!.url!.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: service.image!.url!,
                              fit: BoxFit.contain,
                              errorWidget: (_, __, ___) => Icon(Icons.design_services_outlined, color: AppColors.subtitle(context), size: 28),
                            )
                          : Icon(Icons.design_services_outlined, color: AppColors.subtitle(context), size: 28),
                    ),
                  ),
                ),
              ),
              if (isLoading)
                Container(
                  height: 95,
                  width: 95,
                  decoration: BoxDecoration(color: AppColors.containerBackground(context).withOpacity(0.5), borderRadius: BorderRadius.circular(12)),
                  child: Center(child: SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.textPrimary(context)))),
                ),
            ],
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: 95,
            child: Text(
              service.name ?? '',
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.textSize12(context, weight: FontWeight.w500, color: AppColors.textPrimary(context)),
            ),
          ),
        ],
      ),
    );
  }
}
