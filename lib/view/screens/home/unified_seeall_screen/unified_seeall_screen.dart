import 'package:dinmajur_customer/configs/res/components/header_appbar.dart';
import 'package:dinmajur_customer/configs/responsive/responsive_ui.dart';
import 'package:flutter/material.dart';
import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:dinmajur_customer/configs/res/sizedbox_spaccing.dart';
import 'package:dinmajur_customer/configs/buttons/round_button.dart';
import 'package:dinmajur_customer/configs/utils/routes/routes_name.dart';
import 'package:dinmajur_customer/view/screens/home/dorpdown_categories_selections_and_views/premium_house_keeper/premium_house_keeper_widget.dart';
import 'package:dinmajur_customer/view/screens/home/dorpdown_categories_selections_and_views/beauty_and_salon/beauty_and_salon_widget.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';

class UnifiedSeeAllScreen extends StatefulWidget {
  final String storeType;
  final List<dynamic>? stores;
  final Map<String, String>? storeTypes;
  final Position? currentPosition;
  final String? currentAddress;
  final bool? isCheckingCoverage;
  final bool? isInsideServiceArea;
  final String? customerName;
  final String? customerPhone;
  final String? customerAddress;

  const UnifiedSeeAllScreen({
    Key? key,
    required this.storeType,
    this.stores,
    this.storeTypes,
    this.currentPosition,
    this.currentAddress,
    this.isCheckingCoverage,
    this.isInsideServiceArea,
    this.customerName,
    this.customerPhone,
    this.customerAddress,
  }) : super(key: key);

  @override
  State<UnifiedSeeAllScreen> createState() => _UnifiedSeeAllScreenState();
}

class _UnifiedSeeAllScreenState extends State<UnifiedSeeAllScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.containerBackground(context),
      body: SafeArea(
        child: ResPonsiveUi(mobile: body(), desktop: body(), tablet: body()),
      ),
    );
  }

  Widget body() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Column(
      children: [
        GestureDetector(onTap: () => Navigator.pop(context), child: AppBarHeader(_getAppBarTitle())),
        Expanded(child: _buildBody(context, screenWidth)),
      ],
    );
  }

  String _getAppBarTitle() {
    if (widget.storeType == 'Retail') {
      return 'All Grocery Stores (${widget.stores?.length ?? 0})';
    } else if (widget.storeType == 'Premium House Keeper') {
      return 'Premium House Keeper';
    } else if (widget.storeType == 'Premium Home Beauty & Salon') {
      return 'Beauty & Salon';
    }
    return 'All Services';
  }

  Widget _buildBody(BuildContext context, double screenWidth) {
    if (widget.storeType == 'Retail') {
      return _buildGroceryStoresList(context, screenWidth);
    } else if (widget.storeType == 'Premium House Keeper') {
      return _buildPremiumHouseKeeperView(context, screenWidth);
    } else if (widget.storeType == 'Premium Home Beauty & Salon') {
      return _buildPremiumBeautySalonView(context, screenWidth);
    }
    return _buildEmptyState(context, screenWidth);
  }

  // ============================================================
  Widget _buildGroceryStoresList(BuildContext context, double screenWidth) {
    if (widget.stores == null || widget.stores!.isEmpty) {
      return _buildEmptyState(context, screenWidth);
    }

    final screenHeight = MediaQuery.of(context).size.height;

    return ListView.builder(
      padding: EdgeInsets.all(screenWidth * 0.05),
      itemCount: widget.stores!.length,
      itemBuilder: (context, index) {
        final store = widget.stores![index];
        return _buildStoreCard(context, store, screenHeight, screenWidth);
      },
    );
  }

  Widget _buildStoreCard(BuildContext context, Map<String, dynamic> store, double screenHeight, double screenWidth) {
    final distanceData = store['distance'] as Map<String, dynamic>?;
    final distanceText = distanceData?['text'] ?? '0 m';
    final fullAddress = store['fullAddress'] ?? 'Address not found';
    final bool isAvailable = store['isAvailable'];
    final durationData = store['duration'] as Map<String, dynamic>?;
    final durationText = durationData?['text'] ?? '0 min';
    final businessName = store['businessName'] ?? 'Store name unavailable';
    final businessType = store['businessType'] ?? 'Unknown';
    final userID = store['userId'] ?? '';
    final logo = store['logo'] as Map<String, dynamic>?;
    final logoUrl = logo?['url'];
    final geoLocation = store['geoLocation'] as Map<String, dynamic>?;
    final coordinates = geoLocation?['coordinates'] as List?;
    final storeLatitude = coordinates != null && coordinates.length >= 2 ? coordinates[1] : null;
    final storeLongitude = coordinates != null && coordinates.length >= 2 ? coordinates[0] : null;

    return Container(
      width: screenWidth * 0.9,
      margin: EdgeInsets.only(bottom: screenHeight * 0.02),
      padding: EdgeInsets.all(screenHeight * 0.02),
      decoration: BoxDecoration(
        color: AppColors.containerBackground(context),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(width: 1, color: AppColors.oceanGreenColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (logoUrl != null)
                Container(
                  height: 40,
                  width: 40,
                  margin: EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(width: 1, color: AppColors.border(context)),
                    image: DecorationImage(image: NetworkImage(logoUrl), fit: BoxFit.cover),
                  ),
                ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            businessName,
                            style: AppTextStyles.textSize18(context, weight: FontWeight.w500, color: AppColors.button(context)),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedboxSpaccing.width02(context),
                        Container(
                          height: 24,
                          width: 75,
                          decoration: BoxDecoration(color: isAvailable ? AppColors.oceanGreenColor : AppColors.darkRedColor, borderRadius: BorderRadius.circular(100)),
                          child: Center(
                            child: Text(
                              isAvailable ? "Available" : 'N/A',
                              style: AppTextStyles.textSize10(context, color: AppColors.whiteColor, weight: FontWeight.w400),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      widget.storeTypes?[businessType] ?? businessType,
                      style: AppTextStyles.textSize14(context, weight: FontWeight.w400, color: AppColors.subtitle(context)),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedboxSpaccing.height01(context),
          Divider(height: 1, color: AppColors.border(context)),
          SizedboxSpaccing.height005(context),
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
                      style: AppTextStyles.textSize14(context, weight: FontWeight.w500, color: AppColors.button(context)),
                    ),
                    Text(
                      fullAddress,
                      style: AppTextStyles.textSize14(context, weight: FontWeight.w400, color: AppColors.subtitle(context)),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Row(
                      children: [
                        Container(
                          height: 20,
                          width: 12,
                          alignment: Alignment.centerLeft,
                          child: Icon(FontAwesomeIcons.car, size: 12, color: AppColors.textPrimary(context)),
                        ),
                        SizedboxSpaccing.width02(context),
                        Text(
                          distanceText,
                          style: AppTextStyles.textSize14(context, weight: FontWeight.w400, color: AppColors.button(context)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedboxSpaccing.height02(context),
          RoundButton(
            title: "Order Now",
            onPress: () => Navigator.pushNamed(
              context,
              RoutesName.orderNow,
              arguments: {
                'storeData': store,
                'retailer': store,
                'distanceText': distanceText,
                'durationText': durationText,
                'businessName': businessName,
                'isAvailable': isAvailable,
                'businessType': businessType,
                'selectedStoreType': widget.storeType,
                'userID': userID,
                'logoUrl': logoUrl,
                'storeFullAddress': fullAddress,
                'storeLatitude': storeLatitude,
                'storeLongitude': storeLongitude,
              },
            ),
            iconData: Icons.arrow_forward_ios_rounded,
          ),
        ],
      ),
    );
  }

  // ============================================================
  Widget _buildPremiumHouseKeeperView(BuildContext context, double screenWidth) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(screenWidth * 0.05),
      child: PremiumHouseKeeperCoverageWidget(
        isCheckingCoverage: widget.isCheckingCoverage ?? false,
        isInsideServiceArea: widget.isInsideServiceArea,
        customerName: widget.customerName ?? '',
        customerPhone: widget.customerPhone ?? '',
        customerAddress: widget.customerAddress ?? '',
      ),
    );
  }

  // ============================================================
  Widget _buildPremiumBeautySalonView(BuildContext context, double screenWidth) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(screenWidth * 0.05),
      child: PremiumBeautyAndSalonCoverageWidget(
        isCheckingCoverage: widget.isCheckingCoverage ?? false,
        isInsideServiceArea: widget.isInsideServiceArea,
        customerName: widget.customerName ?? '',
        customerPhone: widget.customerPhone ?? '',
        customerAddress: widget.customerAddress ?? '',
      ),
    );
  }

  // ============================================================
  Widget _buildEmptyState(BuildContext context, double screenWidth) {
    return Center(
      child: Container(
        width: screenWidth * 0.9,
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.store_outlined, size: 80, color: AppColors.subtitle(context)),
            SizedBox(height: 20),
            Text('No Services Found', style: AppTextStyles.textSize20(context, weight: FontWeight.w600)),
            SizedBox(height: 10),
            Text(
              'No services available in your area.',
              style: AppTextStyles.textSize14(context, color: AppColors.subtitle(context)),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
