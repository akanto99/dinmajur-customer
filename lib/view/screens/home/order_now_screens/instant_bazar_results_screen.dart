import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/components/header_appbar.dart';
import 'package:dinmajur_customer/configs/res/sizedbox_spaccing.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:dinmajur_customer/configs/responsive/responsive_ui.dart';
import 'package:dinmajur_customer/data/response/status.dart';
import 'package:dinmajur_customer/view/screens/home/dorpdown_categories_selections_and_views/grocery/grocery_sction_widget.dart';
import 'package:dinmajur_customer/view/screens/home/helper_widgets/dynamic_nearestheader_widget.dart';
import 'package:dinmajur_customer/view_model/homeview_model/nearby_retailers_and_order_view_models/nearby_retailers_view_model.dart';
import 'package:dinmajur_customer/view_model/homeview_model/profileview_model/profileview_model.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

class InstantBazarResultsScreen extends StatefulWidget {
  final List<dynamic> stores;
  final Map<String, String> storeTypes;
  final Position? currentPosition;
  final String? currentAddress;
  final VoidCallback? onSeeAllTap;

  const InstantBazarResultsScreen({
    Key? key,
    required this.stores,
    required this.storeTypes,
    this.currentPosition,
    this.currentAddress,
    this.onSeeAllTap,
  }) : super(key: key);

  @override
  State<InstantBazarResultsScreen> createState() => _InstantBazarResultsScreenState();
}

class _InstantBazarResultsScreenState extends State<InstantBazarResultsScreen> {
  late List<dynamic> _stores;

  @override
  void initState() {
    super.initState();
    _stores = widget.stores;
  }

  Future<void> _handleRefresh() async {
    final profileViewModel = Provider.of<ProfileViewViewModel>(context, listen: false);

    double? customerLng;
    double? customerLat;
    String? fullAddress;

    if (profileViewModel.profileviewUserData.status == Status.COMPLETED) {
      final addressData = profileViewModel.profileviewUserData.data?.data?.addresses;
      if (addressData?.geoLocation?.coordinates != null && addressData!.geoLocation!.coordinates!.length >= 2) {
        customerLng = addressData.geoLocation!.coordinates![0];
        customerLat = addressData.geoLocation!.coordinates![1];
        fullAddress = addressData.fullAddress;
      }
    }

    if (customerLng == null || customerLat == null) {
      if (widget.currentPosition != null) {
        customerLng = widget.currentPosition!.longitude;
        customerLat = widget.currentPosition!.latitude;
        fullAddress ??= widget.currentAddress ?? "Current Location";
      } else {
        return;
      }
    }

    final requestData = {
      "deliveryAddress": {
        "geoLocation": {
          "type": "Point",
          "coordinates": [customerLng, customerLat],
        },
        "fullAddress": fullAddress ?? "",
      },
      "businessType": "Retail",
    };

    final viewModel = Provider.of<PostNearbyRetailersViewModel>(context, listen: false);
    final stores = await viewModel.nearbyRetailersPostApi(context, requestData);

    if (mounted && stores != null) {
      setState(() => _stores = stores);
    }
  }

  @override
  Widget build(BuildContext context) {
    final body = _body(context);
    return Scaffold(
      backgroundColor: AppColors.containerBackground(context),
      body: SafeArea(
        child: ResPonsiveUi(mobile: body, desktop: body, tablet: body),
      ),
    );
  }

  Widget _body(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Column(
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: AppBarHeader('Instant Bazar'),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _handleRefresh,
            color: AppColors.textPrimary(context),
            backgroundColor: AppColors.containerBackground(context),
            displacement: 40,
            strokeWidth: 2.0,
            child: _stores.isEmpty
                ? SingleChildScrollView(
              // ← needed so RefreshIndicator works even when empty
              physics: const AlwaysScrollableScrollPhysics(),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.7,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.store_mall_directory_outlined, size: 64, color: AppColors.subtitle(context)),
                      SizedboxSpaccing.height02(context),
                      Text(
                        'No stores found nearby',
                        style: AppTextStyles.textSize18(context, weight: FontWeight.w500),
                      ),
                      SizedboxSpaccing.height01(context),
                      Text(
                        'Pull down to refresh or try again later',
                        style: AppTextStyles.textSize14(context, color: AppColors.subtitle(context)),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            )
                : SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  SizedboxSpaccing.height025(context),
                  DynamicNearestHeader(
                    selectedStoreType: 'Retail',
                    storeCount: _stores.length,
                    screenWidth: screenWidth,
                    isInsideServiceArea: null,
                    onSeeAllTap: widget.onSeeAllTap ?? () => Navigator.pop(context),
                  ),
                  SizedboxSpaccing.height025(context),
                  GroceryStoresSection(
                    isLoading: false,
                    stores: _stores,
                    storeTypes: widget.storeTypes,
                    selectedStoreType: 'Retail',
                    currentPosition: widget.currentPosition,
                    currentAddress: widget.currentAddress,
                  ),
                  SizedboxSpaccing.height02(context),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}