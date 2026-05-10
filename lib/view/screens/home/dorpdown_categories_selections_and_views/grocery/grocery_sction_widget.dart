import 'package:dinmajur_customer/configs/buttons/round_button.dart';
import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/sizedbox_spaccing.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:dinmajur_customer/configs/utils/routes/routes_name.dart';
import 'package:dinmajur_customer/data/response/status.dart';
import 'package:dinmajur_customer/l10n/app_localizations.dart';
import 'package:dinmajur_customer/view_model/homeview_model/profileview_model/profileview_model.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

class GroceryStoresSection extends StatelessWidget {
  final bool isLoading;
  final List<dynamic> stores;
  final Map<String, String> storeTypes;
  final String? selectedStoreType;
  final Position? currentPosition;
  final String? currentAddress;

  const GroceryStoresSection({Key? key, required this.isLoading, required this.stores, required this.storeTypes, this.selectedStoreType, this.currentPosition, this.currentAddress}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _buildRetailStoresList(context);
  }

  Widget _buildRetailStoresList(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      width: screenWidth * 0.9,
      child: ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: stores.length,
        itemBuilder: (context, index) {
          final store = stores[index];
          return _buildRetailStoreCard(context, store, screenHeight, screenWidth);
        },
      ),
    );
  }

  Widget _buildRetailStoreCard(BuildContext context, Map<String, dynamic> store, double screenHeight, double screenWidth) {
    final distanceData = store['distance'] as Map<String, dynamic>?;
    final distanceText = distanceData?['text'] ?? '0 m';
    final fullAddress = store['fullAddress'] ?? 'Address not found';
    final bool isAvailable = store['isAvailable'];

    final durationData = store['duration'] as Map<String, dynamic>?;
    final durationText = durationData?['text'] ?? '0 min';

    final businessName = store['businessName'] ?? 'দোকানের নাম উপলব্ধ নেই';
    final businessType = store['businessType'] ?? 'অজানা';
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
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
                                  style: AppTextStyles.textSize18(context, weight: FontWeight.w500, color: AppColors.buttonTextColor(context)),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              SizedboxSpaccing.width02(context),
                              Container(
                                height: 24,
                                width: 75,
                                decoration: BoxDecoration(color: isAvailable == true ? AppColors.oceanGreenColor : AppColors.darkRedColor, borderRadius: BorderRadius.circular(100)),
                                child: Center(
                                  child: Text(
                                    isAvailable == true ? "Available" : 'N/A',
                                    style: AppTextStyles.textSize10(context, color: AppColors.whiteColor, weight: FontWeight.w400),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Text(
                            storeTypes[businessType] ?? businessType,
                            style: AppTextStyles.textSize14(context, weight: FontWeight.w400, color: AppColors.subtitle(context)),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
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
                      style: AppTextStyles.textSize14(context, weight: FontWeight.w500, color: AppColors.buttonTextColor(context)),
                    ),
                    Text(
                      fullAddress,
                      style: AppTextStyles.textSize14(context, weight: FontWeight.w400, color: AppColors.subtitle(context)),
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
          RoundButton(
            title: AppLocalizations.of(context)!.order_now,
            onPress: () => _navigateToOrderScreen(context, store, distanceText, durationText, businessName, isAvailable, businessType, userID, logoUrl, fullAddress, storeLatitude, storeLongitude),
            iconData: Icons.arrow_forward_ios_rounded,
          ),
        ],
      ),
    );
  }

  void _navigateToOrderScreen(
    BuildContext context,
    Map<String, dynamic> store,
    String distanceText,
    String durationText,
    String businessName,
    bool isAvailable,
    String businessType,
    String userID,
    String? logoUrl,
    String fullAddress,
    double? storeLatitude,
    double? storeLongitude,
  ) {
    final profileViewModel = Provider.of<ProfileViewViewModel>(context, listen: false);

    double? customerLongitude;
    double? customerLatitude;
    String? customerFullAddress;

    // Extract customer location_screens from profile
    if (profileViewModel.profileviewUserData.status == Status.COMPLETED) {
      final addressData = profileViewModel.profileviewUserData.data?.data?.addresses;

      if (addressData?.geoLocation?.coordinates != null && addressData!.geoLocation!.coordinates!.length >= 2) {
        customerLongitude = addressData.geoLocation!.coordinates![0];
        customerLatitude = addressData.geoLocation!.coordinates![1];
        customerFullAddress = addressData.fullAddress;
      }
    }

    // Fallback to current position if profile doesn't have address
    if (customerLongitude == null || customerLatitude == null) {
      if (currentPosition != null) {
        customerLongitude = currentPosition!.longitude;
        customerLatitude = currentPosition!.latitude;
        customerFullAddress = currentAddress ?? "Current Location";
      }
    }

    Navigator.pushNamed(
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
        'selectedStoreType': selectedStoreType,
        'userID': userID,
        'logoUrl': logoUrl,
        'storeFullAddress': fullAddress,
        'storeLatitude': storeLatitude,
        'storeLongitude': storeLongitude,
        'customerFullAddress': customerFullAddress,
        'customerLongitude': customerLongitude,
        'customerLatitude': customerLatitude,
      },
    );
  }
}
