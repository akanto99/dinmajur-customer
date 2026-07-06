import 'package:cached_network_image/cached_network_image.dart';
import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:dinmajur_customer/configs/utils/routes/routes_name.dart';
import 'package:dinmajur_customer/configs/utils/utils.dart';
import 'package:dinmajur_customer/data/response/status.dart';
import 'package:dinmajur_customer/model/home_models/all_service_models/get_all_service_models.dart';
import 'package:dinmajur_customer/view_model/homeview_model/all_service_view_models/get_all_service_view_model.dart';
import 'package:dinmajur_customer/view_model/homeview_model/dropdown_categories_selection_view_models/premium_house_keeper_view_model/check_coverage_view_model.dart';
import 'package:dinmajur_customer/view_model/homeview_model/profileview_model/profileview_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  String _query = '';
  String? _loadingServiceId;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() => _query = _searchController.text.trim().toLowerCase());
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _focusNode.requestFocus());
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  List<Datum> _getAllServices(GetAllServiceViewModel vm) {
    if (vm.getAllServicesData.status != Status.COMPLETED) return [];
    return vm.getAllServicesData.data?.data ?? <Datum>[];
  }

  List<Datum> _getFilteredServices(GetAllServiceViewModel vm) {
    final all = _getAllServices(vm);
    if (_query.isEmpty) return all;
    return all.where((s) {
      final name = (s.name ?? '').toLowerCase();
      final desc = (s.description ?? '').toLowerCase();
      final categoryMatch = (s.categories ?? []).any((c) => (c.name ?? '').toLowerCase().contains(_query));
      return name.contains(_query) || desc.contains(_query) || categoryMatch;
    }).toList();
  }

  String _matchingCategories(Datum service) {
    if (_query.isEmpty) return '';
    return (service.categories ?? [])
        .where((c) => (c.name ?? '').toLowerCase().contains(_query))
        .map((c) => c.name ?? '')
        .join(', ');
  }

  Future<void> _handleServiceTap(BuildContext context, Datum service) async {
    if (_loadingServiceId != null) return;

    final profileViewModel = Provider.of<ProfileViewViewModel>(context, listen: false);
    bool hasLocation = false;
    if (profileViewModel.profileviewUserData.status == Status.COMPLETED) {
      final addressData = profileViewModel.profileviewUserData.data?.data?.addresses;
      hasLocation = addressData?.fullAddress != null &&
          addressData!.fullAddress!.isNotEmpty &&
          addressData.fullAddress != "Tap to set location...";
    }
    if (!hasLocation) {
      _showLocationRequired();
      return;
    }

    setState(() => _loadingServiceId = service.id);
    try {
      final checkCoverageViewModel = Provider.of<CheckCoverageViewModel>(context, listen: false);
      await checkCoverageViewModel.fetchCheckCoverageDataApi();
      if (!mounted) return;
      final isInside = checkCoverageViewModel.checkCoverageData.data?.data?.insideServiceArea ?? false;
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

      final slug = service.slug ?? '';
      switch (slug) {
        case 'house-keeper':
          Navigator.pushNamed(context, RoutesName.bookNowPremiumHouseKeeper, arguments: {
            'customerName': customerName,
            'customerPhone': customerPhone,
            'customerAddress': customerAddress,
            'serviceName': service.name,
            'description': service.description,
            'customerLocation': customerLocation,
          });
          break;
        case 'beauty-parlour':
          Navigator.pushNamed(context, RoutesName.bookNowHomeBeautySalonScreen, arguments: {
            'customerName': customerName,
            'customerPhone': customerPhone,
            'customerAddress': customerAddress,
            'serviceName': service.name,
            'description': service.description,
            'customerLocation': customerLocation,
          });
          break;
        case 'family-event-cooking':
          Navigator.pushNamed(context, RoutesName.familyEventCookingScreen, arguments: {
            'customerName': customerName,
            'customerPhone': customerPhone,
            'customerAddress': customerAddress,
            'serviceName': service.name,
            'description': service.description,
            'customerLocation': customerLocation,
          });
          break;
        default:
          Navigator.pushNamed(context, RoutesName.servicesViewScreen, arguments: {
            'serviceId': service.id,
            'customerName': customerName,
            'customerPhone': customerPhone,
            'customerAddress': customerAddress,
            'serviceName': service.name,
            'description': service.description,
            'isFromHome': true,
            'customerLocation': customerLocation,
          });
          break;
      }
    } catch (e) {
      debugPrint('Search service tap failed: $e');
    } finally {
      if (mounted) setState(() => _loadingServiceId = null);
    }
  }

  void _showLocationRequired() {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: AppColors.containerBackground(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Location Required', style: AppTextStyles.textSize18(context, weight: FontWeight.w600)),
              const SizedBox(height: 12),
              Text('Please set your delivery location first.', style: AppTextStyles.textSize14(context)),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(ctx);
                      Navigator.pushNamed(context, RoutesName.addlocation);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.button(context),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Text('Set Location', style: AppTextStyles.textSize14(context, color: AppColors.whiteColor)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: AppColors.containerBackground(context),
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchBar(context),
            Expanded(
              child: Consumer<GetAllServiceViewModel>(
                builder: (context, vm, _) {
                  if (vm.getAllServicesData.status == Status.LOADING) {
                    return Center(child: CircularProgressIndicator(color: AppColors.button(context)));
                  }
                  final services = _getFilteredServices(vm);
                  final allServices = _getAllServices(vm);
                  return SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: sw * 0.05),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        if (_query.isEmpty) ...[
                          _buildTrendingChips(context, allServices),
                          const SizedBox(height: 24),
                          _buildAllServices(context, allServices),
                        ] else ...[
                          _buildSearchResults(context, services),
                        ],
                        const SizedBox(height: 80),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.containerBackground(context),
        border: Border(bottom: BorderSide(color: AppColors.border(context), width: 0.8)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Icon(Icons.arrow_back, color: AppColors.textPrimary(context), size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.appBackground(context),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.button(context), width: 1.2),
              ),
              child: TextField(
                controller: _searchController,
                focusNode: _focusNode,
                style: AppTextStyles.textSize14(context),
                decoration: InputDecoration(
                  hintText: 'Look for services',
                  hintStyle: AppTextStyles.textSize14(context, color: AppColors.subtitle(context)),
                  prefixIcon: Icon(Icons.search, color: AppColors.button(context), size: 20),
                  suffixIcon: _query.isNotEmpty
                      ? GestureDetector(
                          onTap: () => _searchController.clear(),
                          child: Icon(Icons.close, color: AppColors.subtitle(context), size: 18),
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 13),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendingChips(BuildContext context, List<Datum> services) {
    if (services.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.trending_up_rounded, size: 16, color: AppColors.button(context)),
            const SizedBox(width: 6),
            Text('Trending Searches', style: AppTextStyles.textSize13(context, weight: FontWeight.w600, color: AppColors.textPrimary(context))),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: services.take(6).map((s) {
            return GestureDetector(
              onTap: () {
                _searchController.text = s.name ?? '';
                setState(() => _query = (s.name ?? '').toLowerCase());
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.button(context).withOpacity(0.07),
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(color: AppColors.button(context).withOpacity(0.25)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.trending_up_rounded, size: 13, color: AppColors.button(context)),
                    const SizedBox(width: 5),
                    Text(s.name ?? '', style: AppTextStyles.textSize12(context, weight: FontWeight.w500, color: AppColors.button(context))),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildAllServices(BuildContext context, List<Datum> services) {
    if (services.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.grid_view_rounded, size: 16, color: AppColors.subtitle(context)),
            const SizedBox(width: 6),
            Text('All Services', style: AppTextStyles.textSize13(context, weight: FontWeight.w600, color: AppColors.subtitle(context))),
          ],
        ),
        const SizedBox(height: 12),
        ...services.map((s) => _buildServiceTile(context, s)).toList(),
      ],
    );
  }

  Widget _buildSearchResults(BuildContext context, List<Datum> services) {
    if (services.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 60),
          child: Column(
            children: [
              Icon(Icons.search_off, size: 48, color: AppColors.subtitle(context)),
              const SizedBox(height: 12),
              Text('No services found for "$_query"',
                  style: AppTextStyles.textSize14(context, color: AppColors.subtitle(context))),
            ],
          ),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('${services.length} result${services.length == 1 ? '' : 's'}',
            style: AppTextStyles.textSize12(context, color: AppColors.subtitle(context))),
        const SizedBox(height: 12),
        ...services.map((s) => _buildServiceTile(context, s)).toList(),
      ],
    );
  }

  Widget _buildServiceTile(BuildContext context, Datum service) {
    final isLoading = _loadingServiceId == service.id;
    final imageUrl = service.image?.url;
    final matchedCats = _matchingCategories(service);

    return GestureDetector(
      onTap: () => _handleServiceTap(context, service),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.appBackground(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isLoading ? AppColors.button(context) : AppColors.border(context)),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: imageUrl != null && imageUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: imageUrl,
                      width: 44,
                      height: 44,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => _placeholder(context),
                    )
                  : _placeholder(context),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(service.name ?? '',
                      style: AppTextStyles.textSize14(context, weight: FontWeight.w600)),
                  if (matchedCats.isNotEmpty)
                    Text(
                      matchedCats,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.textSize12(context, color: AppColors.button(context)),
                    )
                  else if ((service.description ?? '').isNotEmpty)
                    Text(
                      service.description!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.textSize12(context, color: AppColors.subtitle(context)),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            if (isLoading)
              SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.button(context)))
            else
              Icon(Icons.arrow_forward_ios, size: 13, color: AppColors.subtitle(context)),
          ],
        ),
      ),
    );
  }

  Widget _placeholder(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.border(context),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(Icons.home_repair_service_outlined, color: AppColors.subtitle(context), size: 22),
    );
  }
}
