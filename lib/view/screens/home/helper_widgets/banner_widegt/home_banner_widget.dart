import 'package:carousel_slider/carousel_slider.dart';
import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/sizedbox_spaccing.dart';
import 'package:dinmajur_customer/configs/utils/routes/routes_name.dart';
import 'package:dinmajur_customer/configs/utils/utils.dart';
import 'package:dinmajur_customer/data/response/status.dart';
import 'package:dinmajur_customer/model/home_models/banner_model/banner_model.dart';
import 'package:dinmajur_customer/respository/home_repositories/banner_repository/banner_repository.dart';
import 'package:dinmajur_customer/view_model/homeview_model/banner_view_model/banner_view_model.dart';
import 'package:dinmajur_customer/view_model/homeview_model/dropdown_categories_selection_view_models/premium_house_keeper_view_model/check_coverage_view_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

// Shared by the image/carousel/video banner renderers below so all three
// banner types stay visually consistent at whatever height is set here.
const double _kBannerHeight = 160;

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
  /// Render exactly this specific banner CMS document by id — used when
  /// the home page's section order comes from the admin-controlled Home
  /// Page Layout, where each banner is its own independently-positioned
  /// row rather than "whichever doc the home_page placement query
  /// returns". When null, falls back to the original shared/global
  /// BannerViewModel behavior.
  final String? cmsId;

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
    this.cmsId,
  });

  @override
  State<HomeBannerWidget> createState() => _HomeBannerWidgetState();
}

class _HomeBannerWidgetState extends State<HomeBannerWidget> {
  int _currentCarouselIndex = 0;
  bool _isBannerLoading = false;

  final _bannerRepository = BannerRepository();
  Status _byIdStatus = Status.LOADING;
  Data? _byIdData;

  @override
  void initState() {
    super.initState();
    if (widget.cmsId != null) _fetchById(widget.cmsId!);
  }

  @override
  void didUpdateWidget(covariant HomeBannerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.cmsId != null && widget.cmsId != oldWidget.cmsId) {
      _fetchById(widget.cmsId!);
    }
  }

  Future<void> _fetchById(String id) async {
    setState(() => _byIdStatus = Status.LOADING);
    try {
      final result = await _bannerRepository.fetchBannerById(id);
      if (!mounted) return;
      setState(() {
        _byIdData = result.data;
        _byIdStatus = Status.COMPLETED;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _byIdStatus = Status.ERROR);
    }
  }

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
    } finally {
      if (mounted) setState(() => _isBannerLoading = false);
    }
  }

  Widget _placeholder(BuildContext context, {Widget? child, double? height}) {
    return SizedBox(
      width: widget.screenWidth * 0.9,
      height: height ?? _kBannerHeight,
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

  Widget _buildNetworkImage(BuildContext context, String imageUrl, {double? height}) {
    final resolvedHeight = height ?? _kBannerHeight;
    return Container(
      width: widget.screenWidth * 0.9,
      height: resolvedHeight,
      decoration: BoxDecoration(color: AppColors.appBackground(context), borderRadius: BorderRadius.circular(12)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          imageUrl,
          width: widget.screenWidth * 0.9,
          height: resolvedHeight,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _placeholder(
            context,
            height: resolvedHeight,
            child: Center(child: Icon(Icons.broken_image_outlined, color: AppColors.textPrimary(context), size: 32)),
          ),
        ),
      ),
    );
  }

  /// Single banner — square (height == width), unlike the carousel/video
  /// banners which stay at the fixed rectangular _kBannerHeight.
  Widget _buildSingleBanner(BuildContext context, String imageUrl, String? slug, String? serviceId, String? serviceName, String? description) {
    final squareSize = widget.screenWidth * 0.9;
    return GestureDetector(
      onTap: () => _handleBannerTap(context, slug, serviceId, serviceName, description),
      child: SizedBox(width: squareSize, height: squareSize, child: _buildImageWithLoadingOverlay(context, _buildNetworkImage(context, imageUrl, height: squareSize))),
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
                height: _kBannerHeight,
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

  Widget _buildFromStatus(BuildContext context, Status? status, Data? bannerData) {
    switch (status) {
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
        if (bannerData == null) return const SizedBox.shrink();

        final type = bannerData.type ?? '';

        // ── Single banner ──
        if (type == 'single') {
          final image = bannerData.image;
          final imageUrl = image?.url ?? '';
          if (imageUrl.isEmpty) {
            return _placeholder(
              context,
              height: widget.screenWidth * 0.9,
              child: Center(child: Icon(Icons.image_not_supported_outlined, color: AppColors.textPrimary(context), size: 32)),
            );
          }
          return Column(
            children: [
              _buildSingleBanner(context, imageUrl, image?.service?.slug, image?.service?.id, image?.service?.name, image?.service?.description),
              SizedboxSpaccing.height025(context),
            ],
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
          return Column(
            children: [
              _buildCarouselBanner(context, items),
              SizedboxSpaccing.height025(context),
            ],
          );
        }

        // ── Video banner ──
        if (type == 'video') {
          final videoUrl = bannerData.video?.url ?? '';
          if (videoUrl.isEmpty) {
            return _placeholder(
              context,
              child: Center(child: Icon(Icons.videocam_off_outlined, color: AppColors.textPrimary(context), size: 32)),
            );
          }
          return Column(
            children: [
              _BannerVideoPlayer(key: ValueKey(videoUrl), videoUrl: videoUrl, screenWidth: widget.screenWidth),
              SizedboxSpaccing.height025(context),
            ],
          );
        }

        return _placeholder(context);

      default:
        return _placeholder(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    // A specific banner CMS doc, positioned per the admin's Home Page
    // Layout order — its own local fetch, not the shared global one.
    if (widget.cmsId != null) {
      return _buildFromStatus(context, _byIdStatus, _byIdData);
    }

    return Consumer<BannerViewModel>(
      builder: (context, bannerViewModel, _) {
        return _buildFromStatus(context, bannerViewModel.bannerData.status, bannerViewModel.bannerData.data?.data);
      },
    );
  }
}

/// Plays a single looping, muted-by-default banner video — matches the
/// image/carousel banners' fixed 120px height. No tap-to-navigate target:
/// the backend's `video` field carries no linked service/task (unlike
/// `image`/`items`), so this is playback-only with a tap-to-mute toggle.
class _BannerVideoPlayer extends StatefulWidget {
  final String videoUrl;
  final double screenWidth;

  const _BannerVideoPlayer({super.key, required this.videoUrl, required this.screenWidth});

  @override
  State<_BannerVideoPlayer> createState() => _BannerVideoPlayerState();
}

class _BannerVideoPlayerState extends State<_BannerVideoPlayer> {
  VideoPlayerController? _controller;
  bool _isMuted = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  void _initialize() {
    final controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
    _controller = controller;
    controller
        .initialize()
        .then((_) {
          if (!mounted) return;
          controller
            ..setLooping(true)
            ..setVolume(0)
            ..play();
          setState(() {});
        })
        .catchError((_) {
          if (mounted) setState(() => _hasError = true);
        });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _toggleMute() {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;
    setState(() {
      _isMuted = !_isMuted;
      controller.setVolume(_isMuted ? 0 : 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    final height = _kBannerHeight;

    if (_hasError || controller == null) {
      return SizedBox(
        width: widget.screenWidth * 0.9,
        height: height,
        child: Container(
          decoration: BoxDecoration(color: AppColors.appBackground(context), borderRadius: BorderRadius.circular(8)),
          child: Center(child: Icon(Icons.videocam_off_outlined, color: AppColors.textPrimary(context), size: 32)),
        ),
      );
    }

    if (!controller.value.isInitialized) {
      return SizedBox(
        width: widget.screenWidth * 0.9,
        height: height,
        child: Container(
          decoration: BoxDecoration(color: AppColors.appBackground(context), borderRadius: BorderRadius.circular(8)),
          child: const Center(child: CupertinoActivityIndicator()),
        ),
      );
    }

    return GestureDetector(
      onTap: _toggleMute,
      child: SizedBox(
        width: widget.screenWidth * 0.9,
        height: height,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Stack(
            fit: StackFit.expand,
            children: [
              FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: controller.value.size.width,
                  height: controller.value.size.height,
                  child: VideoPlayer(controller),
                ),
              ),
              Positioned(
                right: 8,
                bottom: 8,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(color: Colors.black.withOpacity(0.45), shape: BoxShape.circle),
                  child: Icon(_isMuted ? Icons.volume_off : Icons.volume_up, color: Colors.white, size: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
