import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/components/header_appbar.dart';
import 'package:dinmajur_customer/configs/res/sizedbox_spaccing.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:dinmajur_customer/configs/responsive/responsive_ui.dart';
import 'package:dinmajur_customer/configs/utils/routes/routes_name.dart';
import 'package:dinmajur_customer/data/response/status.dart';
import 'package:dinmajur_customer/model/home_models/all_service_models/nearby_service_stores_model/getall_nearby_service_stores_model.dart';
import 'package:dinmajur_customer/view_model/homeview_model/all_service_view_models/nearby_service_stores_view_model/nearby_servic_stores_view_model.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';

class GetAllNearbyServiceStoresScreen extends StatefulWidget {
  const GetAllNearbyServiceStoresScreen({super.key});

  @override
  State<GetAllNearbyServiceStoresScreen> createState() => _GetAllNearbyServiceStoresScreenState();
}

class _GetAllNearbyServiceStoresScreenState extends State<GetAllNearbyServiceStoresScreen> {
  late String serviceId;
  late String serviceName;
  late String description;
  late String customerName;
  late String customerPhone;
  late String customerAddress;
  Map<String, dynamic>? customerLocation;

  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      serviceId = args?['serviceId'] as String? ?? '';
      serviceName = args?['serviceName'] as String? ?? '';
      description = args?['description'] as String? ?? '';
      customerName = args?['customerName'] as String? ?? '';
      customerPhone = args?['customerPhone'] as String? ?? '';
      customerAddress = args?['customerAddress'] as String? ?? '';
      customerLocation = args?['customerLocation'] as Map<String, dynamic>?;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        Provider.of<GetAllNearbyServicStoresViewModel>(context, listen: false).fetchGetAllNearbyServiceStores(serviceId);
      });
    }
  }

  Future<void> _handleRefresh() async {
    await Provider.of<GetAllNearbyServicStoresViewModel>(context, listen: false).fetchGetAllNearbyServiceStores(serviceId);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final body = _body(screenWidth, screenHeight);

    return Scaffold(
      backgroundColor: AppColors.containerBackground(context),
      body: SafeArea(
        child: ResPonsiveUi(mobile: body, desktop: body, tablet: body),
      ),
    );
  }

  Widget _body(double screenWidth, double screenHeight) {
    return Column(
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: SizedBox(height: 60, child: AppBarHeader(serviceName)),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _handleRefresh,
            color: AppColors.textPrimary(context),
            backgroundColor: AppColors.containerBackground(context),
            displacement: 40,
            strokeWidth: 2.0,
            child: Consumer<GetAllNearbyServicStoresViewModel>(
              builder: (context, viewModel, _) {
                switch (viewModel.getAllNearbyServiceStoresData.status) {
                  case Status.LOADING:
                    return Center(child: LoadingAnimationWidget.progressiveDots(color: AppColors.button(context), size: 50));

                  case Status.ERROR:
                    return Center(
                      child: GestureDetector(
                        onTap: _handleRefresh,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(color: AppColors.button(context), borderRadius: BorderRadius.circular(8)),
                          child: Text('Retry', style: AppTextStyles.textSize14(context, color: AppColors.whiteColor)),
                        ),
                      ),
                    );

                  case Status.COMPLETED:
                    final stores = viewModel.getAllNearbyServiceStoresData.data?.data ?? [];
                    if (stores.isEmpty) {
                      // A non-scrollable child (e.g. a bare Center) can't be
                      // dragged, so RefreshIndicator never sees the pull
                      // gesture — this needs a scrollable so pull-to-refresh
                      // still works on the empty state.
                      return LayoutBuilder(
                        builder: (context, constraints) => ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            ConstrainedBox(
                              constraints: BoxConstraints(minHeight: constraints.maxHeight),
                              child: Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.store_mall_directory_outlined, size: 64, color: AppColors.subtitle(context).withOpacity(0.4)),
                                    const SizedBox(height: 16),
                                    Text('No stores available', style: AppTextStyles.textSize16(context, weight: FontWeight.w600, color: AppColors.textPrimary(context))),
                                    const SizedBox(height: 6),
                                    Text('There are no stores for this service\nin your area yet.', textAlign: TextAlign.center, style: AppTextStyles.textSize13(context, color: AppColors.subtitle(context))),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05, vertical: screenHeight * 0.02),
                      itemCount: stores.length,
                      itemBuilder: (context, index) => _buildStoreCard(context, stores[index], screenWidth, screenHeight),
                    );

                  default:
                    return const SizedBox.shrink();
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStoreCard(BuildContext context, Datum store, double screenWidth, double screenHeight) {
    final logoUrl = store.logo?.url;
    final distanceText = store.distance?.text ?? '0 m';
    final durationText = store.duration?.text ?? '0 min';
    final isAvailable = store.isAvailable ?? false;

    return Container(
      margin: EdgeInsets.only(bottom: screenHeight * 0.02),
      padding: EdgeInsets.all(screenHeight * 0.02),
      decoration: BoxDecoration(
        color: AppColors.containerBackground(context),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(width: 1, color: AppColors.border(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Store header ──
          Row(
            children: [
              Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: AppColors.appBackground(context),
                  border: Border.all(width: 1, color: AppColors.border(context)),
                  image: logoUrl != null && logoUrl.isNotEmpty ? DecorationImage(image: NetworkImage(logoUrl), fit: BoxFit.cover) : null,
                ),
                child: logoUrl == null || logoUrl.isEmpty ? Icon(Icons.store, color: AppColors.subtitle(context), size: 24) : null,
              ),
              SizedboxSpaccing.width02(context),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            store.businessName ?? '',
                            style: AppTextStyles.textSize18(context, weight: FontWeight.w500),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          height: 24,
                          width: 80,
                          decoration: BoxDecoration(color: isAvailable ? AppColors.button(context) : Colors.red.shade400, borderRadius: BorderRadius.circular(100)),
                          child: Center(
                            child: Text(
                              isAvailable ? 'Available' : 'N/A',
                              style: AppTextStyles.textSize10(context, color: AppColors.whiteColor, weight: FontWeight.w500),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      serviceName,
                      style: AppTextStyles.textSize14(context, weight: FontWeight.w400, color: AppColors.subtitle(context)),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedboxSpaccing.height012(context),
          Divider(height: 1, color: AppColors.border(context)),
          SizedboxSpaccing.height012(context),

          // ── Address + distance ──
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 20,
                width: 12,
                alignment: Alignment.centerLeft,
                child: Icon(Icons.location_on, size: 16, color: AppColors.button(context)),
              ),
              SizedboxSpaccing.width03(context),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Store Address",
                      style: AppTextStyles.textSize14(context, weight: FontWeight.w500, color: AppColors.buttonTextColor(context)),
                    ),
                    Text(
                      store.fullAddress ?? '',
                      style: AppTextStyles.textSize12(context, color: AppColors.subtitle(context)),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedboxSpaccing.height005(context),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 20,
                          width: 12,
                          alignment: Alignment.centerLeft,
                          child: Icon(FontAwesomeIcons.car, size: 12, color: AppColors.textPrimary(context)),
                        ),
                        SizedboxSpaccing.width02(context),
                        Container(
                          child: Text(
                            distanceText,
                            style: AppTextStyles.textSize14(context, weight: FontWeight.w400, color: AppColors.buttonTextColor(context)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedboxSpaccing.height012(context),
          Divider(height: 1, color: AppColors.border(context)),
          SizedboxSpaccing.height012(context),

          // ── View Details button ──
          GestureDetector(
            onTap: () => _navigateToServicesView(store),
            child: Container(
              height: 42,
              width: double.infinity,
              decoration: BoxDecoration(color: AppColors.button(context), borderRadius: BorderRadius.circular(8)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Book Service',
                    style: AppTextStyles.textSize14(context, color: AppColors.whiteColor, weight: FontWeight.w600),
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 14),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToServicesView(Datum store) {
    print("----------------------------------${store.userId}");
    Navigator.pushNamed(
      context,
      RoutesName.servicesViewScreen,
      arguments: {
        'serviceId': serviceId,
        'customerName': customerName,
        'customerPhone': customerPhone,
        'customerAddress': customerAddress,
        'serviceName': serviceName,
        'description': description,
        'isFromHome': true,
        'customerLocation': customerLocation,

        'retailerId': store.userId ?? '',
      },
    );
  }
}
