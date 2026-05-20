import 'package:carousel_slider/carousel_slider.dart';
import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/sizedbox_spaccing.dart';
import 'package:dinmajur_customer/configs/utils/routes/routes_name.dart';
import 'package:dinmajur_customer/configs/utils/utils.dart';
import 'package:dinmajur_customer/data/response/status.dart';
import 'package:dinmajur_customer/model/home_models/banner_model/banner_model.dart';
import 'package:dinmajur_customer/view_model/homeview_model/banner_view_model/banner_view_model.dart';
import 'package:dinmajur_customer/view_model/homeview_model/dropdown_categories_selection_view_models/premium_house_keeper_view_model/check_coverage_view_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeBannerWidget extends StatefulWidget {
  final double screenWidth;
  final String customerName;
  final String customerPhone;
  final String customerAddress;
  final Map<String, dynamic>? customerLocation;
  final bool hasValidLocation;
  final VoidCallback onLocationRequired;
  final Future<void> Function() onInstantBazarTap;
  final String? loadingServiceSlug;

  const HomeBannerWidget({
    super.key,
    required this.screenWidth,
    required this.customerName,
    required this.customerPhone,
    required this.customerAddress,
    required this.customerLocation,
    required this.hasValidLocation,
    required this.onLocationRequired,
    required this.onInstantBazarTap,
    required this.loadingServiceSlug,
  });

  @override
  State<HomeBannerWidget> createState() => _HomeBannerWidgetState();
}

class _HomeBannerWidgetState extends State<HomeBannerWidget> {
  int _currentCarouselIndex = 0;
  bool _isBannerLoading = false;

  // ── Updated signature — add description param ──
  Future<void> _handleBannerTap(
    BuildContext context,
    String? slug,
    String? serviceId,
    String? serviceName,
    String? description, // ← added
  ) async {
    if (_isBannerLoading) return;
    if (widget.loadingServiceSlug != null) return;

    if (!widget.hasValidLocation) {
      widget.onLocationRequired();
      return;
    }

    final resolvedSlug = slug ?? '';

    if (resolvedSlug == 'instant-bazar') {
      await widget.onInstantBazarTap();
      return;
    }

    setState(() => _isBannerLoading = true);

    try {
      final checkCoverageViewModel = Provider.of<CheckCoverageViewModel>(context, listen: false);
      await checkCoverageViewModel.fetchCheckCoverageDataApi();

      if (!mounted) return;

      final isInside = checkCoverageViewModel.checkCoverageData.data?.data?.insideServiceArea ?? false;

      if (!isInside) {
        Utils.flushBarErrorMessage("Service not available in your area", context);
        return;
      }

      switch (resolvedSlug) {
        case 'house-keeper':
          Navigator.pushNamed(
            context,
            RoutesName.bookNowPremiumHouseKeeper,
            arguments: {
              'customerName': widget.customerName,
              'customerPhone': widget.customerPhone,
              'customerAddress': widget.customerAddress,
              'serviceName': serviceName,
              'description': description, // ← now populated
              'customerLocation': widget.customerLocation,
            },
          );
          break;

        case 'beauty-parlour':
          Navigator.pushNamed(
            context,
            RoutesName.bookNowHomeBeautySalonScreen,
            arguments: {
              'customerName': widget.customerName,
              'customerPhone': widget.customerPhone,
              'customerAddress': widget.customerAddress,
              'serviceName': serviceName,
              'description': description,
              'customerLocation': widget.customerLocation,
            },
          );
          break;

        case 'family-event-cooking':
          Navigator.pushNamed(
            context,
            RoutesName.familyEventCookingScreen,
            arguments: {
              'customerName': widget.customerName,
              'customerPhone': widget.customerPhone,
              'customerAddress': widget.customerAddress,
              'serviceName': serviceName,
              'description': description,
              'customerLocation': widget.customerLocation,
            },
          );
          break;

        default:
          if (serviceId != null && serviceId.isNotEmpty) {
            Navigator.pushNamed(
              context,
              RoutesName.servicesViewScreen,
              arguments: {
                'serviceId': serviceId,
                'customerName': widget.customerName,
                'customerPhone': widget.customerPhone,
                'customerAddress': widget.customerAddress,
                'serviceName': serviceName,
                'description': description,
                'isFromHome': true,
                'customerLocation': widget.customerLocation,
              },
            );
          }
          break;
      }
    } catch (e) {
      debugPrint('Banner tap / coverage check failed: $e');
    } finally {
      if (mounted) setState(() => _isBannerLoading = false);
    }
  }

  Widget _placeholder(BuildContext context, {Widget? child}) {
    return SizedBox(
      width: widget.screenWidth * 0.9,
      height: 120,
      child: Container(
        decoration: BoxDecoration(color: AppColors.appBackground(context), borderRadius: BorderRadius.circular(8)),
        child: child,
      ),
    );
  }

  Widget _buildImageWithLoadingOverlay(BuildContext context, Widget imageWidget) {
    return Stack(
      children: [
        imageWidget,
        if (_isBannerLoading)
          Positioned.fill(
            child: Center(
              child: Container(
                width: widget.screenWidth * 0.9,
                decoration: BoxDecoration(color: Colors.transparent, borderRadius: BorderRadius.circular(8)),
                child: Center(
                  child: SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.textPrimary(context))),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildNetworkImage(BuildContext context, String imageUrl) {
    return Container(
      width: widget.screenWidth * 0.9,
      height: 120,
      decoration: BoxDecoration(color: AppColors.appBackground(context), borderRadius: BorderRadius.circular(12)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          imageUrl,
          width: widget.screenWidth * 0.9,
          height: 120,
          fit: BoxFit.cover,
          // loadingBuilder: (context, child, loadingProgress) {
          //   if (loadingProgress == null) return child;
          //   return Container(
          //     width: widget.screenWidth * 0.9,
          //     height: 120,
          //     decoration: BoxDecoration(color: AppColors.appBackground(context), borderRadius: BorderRadius.circular(12)),
          //   );
          // },
          errorBuilder: (context, error, stackTrace) => _placeholder(
            context,
            child: Center(child: Icon(Icons.broken_image_outlined, color: AppColors.textPrimary(context), size: 32)),
          ),
        ),
      ),
    );
  }

  /// Single banner — description from image.service.description
  Widget _buildSingleBanner(BuildContext context, String imageUrl, String? slug, String? serviceId, String? serviceName, String? description) {
    return GestureDetector(
      onTap: () => _handleBannerTap(context, slug, serviceId, serviceName, description),
      child: SizedBox(width: widget.screenWidth * 0.9, height: 120, child: _buildImageWithLoadingOverlay(context, _buildNetworkImage(context, imageUrl))),
    );
  }

  /// Carousel banner — description from each item's service.description
  Widget _buildCarouselBanner(BuildContext context, List<BannerItem> items) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            if (_currentCarouselIndex >= items.length) return;
            final current = items[_currentCarouselIndex];
            _handleBannerTap(context, current.service?.slug, current.service?.id, current.service?.name, current.service?.description);
          },
          child: _buildImageWithLoadingOverlay(
            context,
            CarouselSlider(
              options: CarouselOptions(
                height: 120,
                viewportFraction: 1.0,
                autoPlay: true,
                autoPlayInterval: const Duration(seconds: 4),
                autoPlayAnimationDuration: const Duration(milliseconds: 600),
                autoPlayCurve: Curves.fastOutSlowIn,
                enlargeCenterPage: false,
                onPageChanged: (index, reason) {
                  setState(() => _currentCarouselIndex = index);
                },
              ),
              items: items.map((item) {
                final url = item.url ?? '';
                return url.isNotEmpty
                    ? _buildNetworkImage(context, url)
                    : _placeholder(
                        context,
                        child: Center(child: Icon(Icons.image_not_supported_outlined, color: AppColors.textPrimary(context), size: 32)),
                      );
              }).toList(),
            ),
          ),
        ),

        if (items.length > 1) ...[
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: items.asMap().entries.map((entry) {
              final isActive = entry.key == _currentCarouselIndex;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: isActive ? 16 : 6,
                height: 6,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(4), color: isActive ? AppColors.textPrimary(context) : AppColors.textPrimary(context).withOpacity(0.3)),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BannerViewModel>(
      builder: (context, bannerViewModel, _) {
        switch (bannerViewModel.bannerData.status) {
          case Status.LOADING:
            return Column(children: [_placeholder(context), SizedboxSpaccing.height025(context)]);

          case Status.ERROR:
            return Column(
              children: [
                _placeholder(
                  context,
                  child: Center(child: Icon(Icons.broken_image_outlined, color: AppColors.textPrimary(context), size: 32)),
                ),
                SizedboxSpaccing.height025(context),
              ],
            );

          case Status.COMPLETED:
            final bannerData = bannerViewModel.bannerData.data?.data;
            if (bannerData == null) return const SizedBox.shrink();

            final type = bannerData.type ?? '';

            // ── Single banner ──
            if (type == 'single') {
              final image = bannerData.image;
              final imageUrl = image?.url ?? '';
              if (imageUrl.isEmpty) {
                return _placeholder(
                  context,
                  child: Center(child: Icon(Icons.image_not_supported_outlined, color: AppColors.textPrimary(context), size: 32)),
                );
              }
              return Column(
                children: [_buildSingleBanner(context, imageUrl, image?.service?.slug, image?.service?.id, image?.service?.name, image?.service?.description), SizedboxSpaccing.height025(context)],
              );
            }

            // ── Carousel banner ──
            if (type == 'carousel') {
              final items = bannerData.items ?? [];
              if (items.isEmpty) {
                return _placeholder(
                  context,
                  child: Center(child: Icon(Icons.image_not_supported_outlined, color: AppColors.textPrimary(context), size: 32)),
                );
              }
              return Column(children: [_buildCarouselBanner(context, items), SizedboxSpaccing.height025(context)]);
            }

            return _placeholder(context);

          default:
            return _placeholder(context);
        }
      },
    );
  }
}
