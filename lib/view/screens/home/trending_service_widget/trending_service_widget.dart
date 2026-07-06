import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/sizedbox_spaccing.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:dinmajur_customer/configs/utils/routes/routes_name.dart';
import 'package:dinmajur_customer/configs/utils/utils.dart';
import 'package:dinmajur_customer/data/response/status.dart';
import 'package:dinmajur_customer/model/home_models/all_service_models/services_view_getallcategories_model.dart';
import 'package:dinmajur_customer/view_model/homeview_model/all_service_view_models/services_view_getallcategories_view_model.dart';
import 'package:dinmajur_customer/view_model/homeview_model/dropdown_categories_selection_view_models/premium_house_keeper_view_model/check_coverage_view_model.dart';
import 'package:dinmajur_customer/view_model/homeview_model/profileview_model/profileview_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TrendingServicesWidget extends StatefulWidget {
  final bool hasValidLocation;
  final VoidCallback onLocationRequired;

  const TrendingServicesWidget({Key? key, required this.hasValidLocation, required this.onLocationRequired}) : super(key: key);

  @override
  State<TrendingServicesWidget> createState() => _TrendingServicesWidgetState();
}

class _TrendingServicesWidgetState extends State<TrendingServicesWidget> {
  final ScrollController _scrollController = ScrollController();
  Timer? _autoScrollTimer;

  // Card width + gap — tweak these two numbers to taste
  static const double _cardWidth = 135.0;
  static const double _cardGap = 14.0;
  static const double _cardHeight = 150.0;

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted) return;
      if (!_scrollController.hasClients) return;

      final maxScroll = _scrollController.position.maxScrollExtent;
      final current = _scrollController.offset;

      // If near the end, jump silently back to start, then continue
      if (current >= maxScroll - 1) {
        _scrollController.jumpTo(0);
        return;
      }

      // Scroll exactly one card width + gap per tick
      final next = (current + _cardWidth + _cardGap).clamp(0.0, maxScroll);
      _scrollController.animateTo(next, duration: const Duration(milliseconds: 600), curve: Curves.easeInOut);
    });
  }

  List<Task> _getAllTasks(ServicesViewGetAllCategoriesViewModel vm) {
    if (vm.servicesViewGetAllCategoryData.status != Status.COMPLETED) return [];
    final categories = vm.servicesViewGetAllCategoryData.data?.data?.categories ?? <Category>[];
    return categories.expand((c) => c.tasks ?? <Task>[]).toList().cast<Task>();
  }

  String? _getServiceId(ServicesViewGetAllCategoriesViewModel vm) {
    return vm.servicesViewGetAllCategoryData.data?.data?.serviceId;
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  String? _loadingTaskId;

  Future<void> _handleTaskTap(BuildContext context, Task task) async {
    if (_loadingTaskId != null) return;

    // ── Read location directly from Provider at tap time ──
    // Don't trust widget.hasValidLocation — it may be stale
    final profileViewModel = Provider.of<ProfileViewViewModel>(context, listen: false);

    bool hasLocation = false;
    if (profileViewModel.profileviewUserData.status == Status.COMPLETED) {
      final addressData = profileViewModel.profileviewUserData.data?.data?.addresses;
      hasLocation = addressData?.fullAddress != null && addressData!.fullAddress!.isNotEmpty && addressData.fullAddress != "Tap to set location...";
    }

    if (!hasLocation) {
      widget.onLocationRequired();
      return;
    }

    setState(() => _loadingTaskId = task.id);

    try {
      final checkCoverageViewModel = Provider.of<CheckCoverageViewModel>(context, listen: false);
      await checkCoverageViewModel.fetchCheckCoverageDataApi();

      if (!context.mounted) return;

      final isInside = checkCoverageViewModel.checkCoverageData.data?.data?.insideServiceArea ?? false;
      if (!isInside) {
        Utils.flushBarErrorMessage("Service not available in your area", context);
        return;
      }

      // ── Build customer data ──
      String customerName = '';
      String customerPhone = '';
      String customerAddress = '';
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
            "geoLocation": {"type": addr.geoLocation?.type ?? "Point", "coordinates": addr.geoLocation?.coordinates ?? [], "timestamp": DateTime.now().toUtc().toIso8601String()},
          };
        }
      }

      final vm = Provider.of<ServicesViewGetAllCategoriesViewModel>(context, listen: false);
      final serviceId = _getServiceId(vm);
      final serviceName = vm.servicesViewGetAllCategoryData.data?.data?.serviceName ?? "Trending Service";
      final serviceDescription = (vm.servicesViewGetAllCategoryData.data?.data?.serviceDescription ?? '').isNotEmpty
          ? vm.servicesViewGetAllCategoryData.data?.data?.serviceDescription!
          : "Explore our trending home services — trusted professionals services right at your doorstep.";      Navigator.pushNamed(
        context,
        RoutesName.servicesViewScreen,
        arguments: {
          'serviceId': serviceId,
          'customerName': customerName,
          'customerPhone': customerPhone,
          'customerAddress': customerAddress,
          'serviceName':serviceName,
          'description': serviceDescription,
          'isFromHome': true,
          'customerLocation': customerLocation,
        },
      );
    } catch (e) {
    } finally {
      if (mounted) setState(() => _loadingTaskId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Consumer<ServicesViewGetAllCategoriesViewModel>(
      builder: (context, vm, _) {
        switch (vm.servicesViewGetAllCategoryData.status) {
          case Status.LOADING:
            return _buildShimmer(context, screenWidth);
          case Status.ERROR:
            return const SizedBox.shrink();
          case Status.COMPLETED:
            final tasks = _getAllTasks(vm);
            if (tasks.isEmpty) return const SizedBox.shrink();
            return _buildSection(context, tasks, screenWidth);
          default:
            return const SizedBox.shrink();
        }
      },
    );
  }

  Widget _buildSection(BuildContext context, List<Task> tasks, double screenWidth) {
    return Container(
      width: screenWidth * 0.9,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Trending Services~",
            style: AppTextStyles.textSize16(context, weight: FontWeight.w500, color: AppColors.textPrimary(context)),
          ),
          SizedboxSpaccing.height025(context),
          SizedBox(
            height: _cardHeight,
            child: ListView.separated(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.only(right: _cardWidth / 2),
              itemCount: tasks.length,
              separatorBuilder: (_, __) => const SizedBox(width: _cardGap),
              itemBuilder: (context, index) => _buildTaskCard(context, tasks[index]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCard(BuildContext context, Task task) {
    final imageUrl = task.images?.isNotEmpty == true ? task.images!.first.url : null;
    final salePrice = task.price?.salePrice;
    final basePrice = task.price?.basePrice;
    final hasDiscount = salePrice != null && basePrice != null && salePrice < basePrice;

    final isLoading = _loadingTaskId == task.id; // ← check

    return GestureDetector(
      onTap: () => _handleTaskTap(context, task),
      child: SizedBox(
        width: _cardWidth,
        height: _cardHeight,
        child: Stack(
          // ← wrap in Stack for overlay
          children: [
            Container(
              decoration: BoxDecoration(
                color: AppColors.containerBackground(context),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isLoading
                      ? AppColors.textPrimary(context) // ← highlight border when loading
                      : AppColors.border(context),
                  width: isLoading ? 2 : 1,
                ),
                boxShadow: [
                  BoxShadow(color: Theme.of(context).brightness == Brightness.dark ? Colors.black.withOpacity(0.2) : Colors.grey.withOpacity(0.08), blurRadius: 8, offset: const Offset(0, 2)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      opacity: isLoading ? 0.3 : 1.0, // ← dim when loading
                      child: Container(
                        width: _cardWidth,
                        height: 88,
                        child: imageUrl != null && imageUrl.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: imageUrl,
                                fit: BoxFit.cover,
                                errorWidget: (_, __, ___) => Container(
                                  color: AppColors.border(context),
                                  child: Icon(Icons.home_repair_service_outlined, color: AppColors.subtitle(context), size: 32),
                                ),
                              )
                            : Container(
                                color: AppColors.border(context),
                                child: Icon(Icons.home_repair_service_outlined, color: AppColors.subtitle(context), size: 32),
                              ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            task.name ?? '',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.textSize12(context, weight: FontWeight.w600),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              if (salePrice != null)
                                Text(
                                  '৳${salePrice.toStringAsFixed(0)}',
                                  style: AppTextStyles.textSize12(context, weight: FontWeight.w700, color: AppColors.button(context)),
                                ),
                              if (hasDiscount) ...[
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    '৳${basePrice!.toStringAsFixed(0)}',
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTextStyles.textSize12(context, weight: FontWeight.w400, color: Colors.grey).copyWith(decoration: TextDecoration.lineThrough),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ← Loading overlay (same pattern as AllServicesGridWidget)
            if (isLoading)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(color: AppColors.containerBackground(context).withOpacity(0.5), borderRadius: BorderRadius.circular(14)),
                  child: Center(
                    child: SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.textPrimary(context))),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmer(BuildContext context, double screenWidth) {
    return Container(
      width: screenWidth * 0.9,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 25,
            width: 180,
            decoration: BoxDecoration(
              color: AppColors.border(context),
              borderRadius: BorderRadius.circular(100),
            ),
          ),
          SizedboxSpaccing.height025(context),
          SizedBox(
            height: _cardHeight, // 150
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 4,
              itemBuilder: (_, __) => Container(
                width: _cardWidth, // 135
                margin: const EdgeInsets.only(right: _cardGap), // 14
                decoration: BoxDecoration(
                  color: AppColors.border(context),
                  borderRadius: BorderRadius.circular(14),
                ),
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
        ],
      ),
    );
  }
}
