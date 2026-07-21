import 'package:cached_network_image/cached_network_image.dart';
import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/sizedbox_spaccing.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:dinmajur_customer/configs/utils/routes/routes_name.dart';
import 'package:dinmajur_customer/configs/utils/utils.dart';
import 'package:dinmajur_customer/data/response/status.dart';
import 'package:dinmajur_customer/model/home_models/featured_services_model/featured_services_model.dart';
import 'package:dinmajur_customer/view_model/homeview_model/dropdown_categories_selection_view_models/premium_house_keeper_view_model/check_coverage_view_model.dart';
import 'package:dinmajur_customer/view_model/homeview_model/featured_services_view_model/featured_services_view_model.dart';
import 'package:dinmajur_customer/view_model/homeview_model/profileview_model/profileview_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FeaturedServicesWidget extends StatefulWidget {
  final bool hasValidLocation;
  final VoidCallback onLocationRequired;
  final String? sectionId;

  const FeaturedServicesWidget({
    Key? key,
    required this.hasValidLocation,
    required this.onLocationRequired,
    this.sectionId,
  }) : super(key: key);

  @override
  State<FeaturedServicesWidget> createState() => _FeaturedServicesWidgetState();
}

class _FeaturedServicesWidgetState extends State<FeaturedServicesWidget> {
  String? _loadingItemId;

  Future<void> _handleItemTap(BuildContext context, FeaturedItem item) async {
    if (_loadingItemId != null) return;

    final profileViewModel = Provider.of<ProfileViewViewModel>(context, listen: false);
    bool hasLocation = false;
    if (profileViewModel.profileviewUserData.status == Status.COMPLETED) {
      final addr = profileViewModel.profileviewUserData.data?.data?.addresses;
      hasLocation = addr?.fullAddress != null &&
          addr!.fullAddress!.isNotEmpty &&
          addr.fullAddress != "Tap to set location...";
    }
    if (!hasLocation) {
      widget.onLocationRequired();
      return;
    }

    setState(() => _loadingItemId = item.id);
    try {
      final checkCoverage = Provider.of<CheckCoverageViewModel>(context, listen: false);
      await checkCoverage.fetchCheckCoverageDataApi();
      if (!context.mounted) return;

      final isInside = checkCoverage.checkCoverageData.data?.data?.insideServiceArea ?? false;
      if (!isInside) {
        Utils.flushBarErrorMessage("Service not available in your area", context);
        return;
      }

      String customerName = '', customerPhone = '', customerAddress = '';
      Map<String, dynamic>? customerLocation;
      if (profileViewModel.profileviewUserData.status == Status.COMPLETED) {
        final userData = profileViewModel.profileviewUserData.data?.data;
        customerName = userData?.user?.fullName ?? '';
        customerPhone = userData?.user?.phone ?? '';
        customerAddress = userData?.addresses?.fullAddress ?? '';
        final addr = userData?.addresses;
        if (addr != null) {
          customerLocation = {
            "fullAddress": addr.fullAddress ?? '',
            "country": addr.country ?? '',
            "city": addr.city ?? '',
            "geoLocation": {
              "type": addr.geoLocation?.type ?? "Point",
              "coordinates": addr.geoLocation?.coordinates ?? [],
              "timestamp": DateTime.now().toUtc().toIso8601String(),
            },
          };
        }
      }

      final slug = item.serviceSlug ?? '';
      final serviceName = item.serviceName ?? '';
      final description = item.service?.description ?? item.task?.service?.name ?? '';
      final serviceId = item.serviceId ?? '';

      switch (slug) {
        case 'house-keeper':
          Navigator.pushNamed(context, RoutesName.bookNowPremiumHouseKeeper, arguments: {
            'customerName': customerName,
            'customerPhone': customerPhone,
            'customerAddress': customerAddress,
            'serviceName': serviceName,
            'description': description,
            'customerLocation': customerLocation,
          });
          break;
        case 'beauty-parlour':
          Navigator.pushNamed(context, RoutesName.bookNowHomeBeautySalonScreen, arguments: {
            'customerName': customerName,
            'customerPhone': customerPhone,
            'customerAddress': customerAddress,
            'serviceName': serviceName,
            'description': description,
            'customerLocation': customerLocation,
            'preselectTaskId': item.task?.id,
          });
          break;
        case 'family-event-cooking':
          Navigator.pushNamed(context, RoutesName.familyEventCookingScreen, arguments: {
            'customerName': customerName,
            'customerPhone': customerPhone,
            'customerAddress': customerAddress,
            'serviceName': serviceName,
            'description': description,
            'customerLocation': customerLocation,
          });
          break;
        case 'mens-salon':
          Navigator.pushNamed(context, RoutesName.getAllNearbyServiceStoresScreen, arguments: {
            'serviceId': serviceId,
            'customerName': customerName,
            'customerPhone': customerPhone,
            'customerAddress': customerAddress,
            'serviceName': serviceName,
            'description': description,
            'customerLocation': customerLocation,
          });
          break;
        default:
          Navigator.pushNamed(context, RoutesName.servicesViewScreen, arguments: {
            'serviceId': serviceId,
            'customerName': customerName,
            'customerPhone': customerPhone,
            'customerAddress': customerAddress,
            'serviceName': serviceName,
            'description': description,
            'isFromHome': true,
            'customerLocation': customerLocation,
            'preselectTaskId': item.task?.id,
          });
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => _loadingItemId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Consumer<FeaturedServicesViewModel>(
      builder: (context, vm, _) {
        if (vm.featuredServicesData.status == Status.LOADING) {
          return _buildShimmer(context, screenWidth);
        }
        if (vm.featuredServicesData.status != Status.COMPLETED) {
          return const SizedBox.shrink();
        }

        final sections = vm.featuredServicesData.data?.data?.data ?? [];
        final active = sections
            .where((s) =>
                (s.isActive ?? false) &&
                (s.items?.isNotEmpty ?? false) &&
                (widget.sectionId == null || s.id == widget.sectionId))
            .toList();
        if (active.isEmpty) return const SizedBox.shrink();

        return Column(
          children: active.map((section) => _buildSection(context, section, screenWidth)).toList(),
        );
      },
    );
  }

  Widget _buildSection(BuildContext context, FeaturedSection section, double screenWidth) {
    final items = (section.items ?? [])
        .where((i) => (i.isActive ?? true) && (i.service != null || i.task != null))
        .toList()
      ..sort((a, b) => (a.position ?? 0).compareTo(b.position ?? 0));

    if (items.isEmpty) return const SizedBox.shrink();

    final hasSubtitle = section.subtitle != null && section.subtitle!.isNotEmpty;

    return Container(
      width: screenWidth * 0.9,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: title + subtitle + "See all"
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      section.title ?? 'Featured Services',
                      style: AppTextStyles.textSize16(context, weight: FontWeight.w700),
                    ),
                    if (hasSubtitle) ...[
                      const SizedBox(height: 2),
                      Text(
                        section.subtitle!,
                        style: AppTextStyles.textSize12(context, weight: FontWeight.w400, color: AppColors.subtitle(context)),
                      ),
                    ],
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {},
                child: Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    'See all',
                    style: AppTextStyles.textSize12(context, weight: FontWeight.w600, color: AppColors.button(context)),
                  ),
                ),
              ),
            ],
          ),
          SizedboxSpaccing.height025(context),
          SizedBox(
            height: 195,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.only(right: 16),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) => _buildCard(context, items[index]),
            ),
          ),
          SizedboxSpaccing.height02(context),
        ],
      ),
    );
  }

  Widget _buildCard(BuildContext context, FeaturedItem item) {
    final isLoading = _loadingItemId == item.id;

    return SizedBox(
      width: 155,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppColors.containerBackground(context),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isLoading ? AppColors.textPrimary(context) : AppColors.border(context),
                width: isLoading ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.black.withOpacity(0.2)
                      : Colors.grey.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image with ADD button floating over its bottom edge.
                // NOTE: the outer SizedBox height (88 + 15) must cover the
                // button's full extent — a Stack's own hit-test bounds are
                // clipped to its layout size regardless of clipBehavior, so a
                // Positioned child sticking out past that size (as with the
                // old `bottom: -15` inside an 88-tall Stack) is only tappable
                // in the sliver still inside the box, making the button feel
                // unresponsive.
                SizedBox(
                  width: 155,
                  height: 103,
                  child: Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.bottomCenter,
                    children: [
                      Positioned(
                        top: 0,
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                          child: AnimatedOpacity(
                            duration: const Duration(milliseconds: 200),
                            opacity: isLoading ? 0.3 : 1.0,
                            child: SizedBox(
                              width: 155,
                              height: 88,
                              child: item.displayImageUrl != null && item.displayImageUrl!.isNotEmpty
                                  ? CachedNetworkImage(
                                      imageUrl: item.displayImageUrl!,
                                      fit: BoxFit.cover,
                                      errorWidget: (_, __, ___) => _placeholder(context),
                                    )
                                  : _placeholder(context),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        child: GestureDetector(
                          onTap: isLoading ? null : () => _handleItemTap(context, item),
                          child: Container(
                            width: 73,
                            height: 30,
                            decoration: BoxDecoration(
                              color: AppColors.button(context),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(width: 1, color: AppColors.border(context)),
                            ),
                            child: Center(
                              child: isLoading
                                  ? SizedBox(
                                      height: 14,
                                      width: 14,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.whiteColor),
                                    )
                                  : Text(
                                      'ADD',
                                      style: AppTextStyles.textSize14(context, weight: FontWeight.w700, color: AppColors.whiteColor),
                                    ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Info
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 16, 8, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.displayName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.textSize12(context, weight: FontWeight.w600),
                      ),
                      if (item.task?.price?.salePrice != null) ...[
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Text(
                              '৳${item.task!.price!.salePrice!.toStringAsFixed(0)}',
                              style: AppTextStyles.textSize12(context, weight: FontWeight.w700, color: AppColors.button(context)),
                            ),
                            if (item.task?.price?.basePrice != null && item.task!.price!.basePrice! > item.task!.price!.salePrice!) ...[
                              const SizedBox(width: 3),
                              Flexible(
                                child: Text(
                                  '৳${item.task!.price!.basePrice!.toStringAsFixed(0)}',
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.textSize12(context, weight: FontWeight.w400, color: Colors.grey).copyWith(decoration: TextDecoration.lineThrough),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (isLoading)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.containerBackground(context).withOpacity(0.3),
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _placeholder(BuildContext context) => Container(
        color: AppColors.border(context),
        child: Icon(Icons.home_repair_service_outlined, color: AppColors.subtitle(context), size: 32),
      );

  Widget _buildShimmer(BuildContext context, double screenWidth) {
    return Container(
      width: screenWidth * 0.9,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 20,
            width: 160,
            decoration: BoxDecoration(color: AppColors.border(context), borderRadius: BorderRadius.circular(100)),
          ),
          SizedboxSpaccing.height025(context),
          SizedBox(
            height: 150,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 3,
              itemBuilder: (_, __) => Container(
                width: 135,
                margin: const EdgeInsets.only(right: 14),
                decoration: BoxDecoration(color: AppColors.border(context), borderRadius: BorderRadius.circular(14)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 88,
                      decoration: BoxDecoration(
                        color: AppColors.border(context).withOpacity(0.6),
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(height: 12, width: 100, decoration: BoxDecoration(color: AppColors.border(context).withOpacity(0.5), borderRadius: BorderRadius.circular(4))),
                          const SizedBox(height: 6),
                          Container(height: 12, width: 60, decoration: BoxDecoration(color: AppColors.border(context).withOpacity(0.5), borderRadius: BorderRadius.circular(4))),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedboxSpaccing.height02(context),
        ],
      ),
    );
  }
}
