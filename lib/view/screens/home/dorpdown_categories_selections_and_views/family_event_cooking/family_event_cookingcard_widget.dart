import 'package:dinmajur_customer/configs/buttons/round_button.dart';
import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/sizedbox_spaccing.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:dinmajur_customer/configs/utils/routes/routes_name.dart';
import 'package:dinmajur_customer/configs/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Dynamic widget to display coverage check status for Premium House Keeper
/// Shows loading, success (Premium House Keeper content), or error states
class FamilyEventCardCoverageWidget extends StatelessWidget {
  final bool isCheckingCoverage;
  final bool? isInsideServiceArea;
  final String customerName;
  final String customerPhone;
  final String customerAddress;
  final Map<String, dynamic>? customerLocation;


  const FamilyEventCardCoverageWidget({
    Key? key,
    required this.isCheckingCoverage,
    required this.isInsideServiceArea,
    required this.customerName,
    required this.customerPhone,
    required this.customerAddress,
    required this.customerLocation,

  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    if (isCheckingCoverage) {
      return _buildLoadingState(context, screenWidth);
    } else if (isInsideServiceArea == true) {
      return _buildFamilyEventCookingSection(context, screenWidth, screenHeight);
    } else if (isInsideServiceArea == false) {
      return _buildErrorState(context, screenWidth);
    } else {
      return const SizedBox.shrink();
    }
  }

  /// Loading state UI - Checking service availability
  Widget _buildLoadingState(BuildContext context, double screenWidth) {
    return Container(
      width: screenWidth * 0.9,
      height: 120,
      child: Center(
        child: Text(
          'Checking service availability...',
          style: AppTextStyles.textSize16(context, weight: FontWeight.w400, color: AppColors.subtitle(context)),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  /// Error state UI - Service not available
  Widget _buildErrorState(BuildContext context, double screenWidth) {
    return Container(
      width: screenWidth * 0.9,
      height: 190,
      padding: EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
              width: 1,
              color: AppColors.border(context)
          )
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.location_off, size: 50, color: AppColors.subtitle(context)),
          const SizedBox(height: 10),
          Text(
            'Service Not Available',
            style: AppTextStyles.textSize18(context, weight: FontWeight.w600),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Family Event Cooking service is not available in your location.',
            style: AppTextStyles.textSize14(context, color: AppColors.subtitle(context)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Family Event Cooking Section - Main content when service is available
  Widget _buildFamilyEventCookingSection(BuildContext context, double screenWidth, double screenHeight) {
    return Column(
      children: [
        // House Keeper Service Card
        Container(
          width: screenWidth * 0.9,
          padding: EdgeInsets.all(screenHeight * 0.025),
          decoration: BoxDecoration(
            color: AppColors.containerBackground(context),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(width: 1, color: AppColors.oceanGreenColor),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 40,
                          width: 40,
                          decoration: BoxDecoration(
                              color: AppColors.textPrimary(context),
                              borderRadius: BorderRadius.circular(6)
                          ),
                          child: Icon(
                              FontAwesomeIcons.kitchenSet,
                              color: AppColors.containerBackground(context),
                              size: 16
                          ),
                        ),
                        SizedboxSpaccing.width03(context),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Home Cooking",
                                style: AppTextStyles.textSize18(
                                    context,
                                    weight: FontWeight.w500,
                                    color: AppColors.button(context)
                                ),
                                maxLines: 2, // Allow up to 2 lines
                                overflow: TextOverflow.ellipsis, // Add ellipsis if still too long
                              ),
                              Text(
                                "Dinmajur Premium",
                                style: AppTextStyles.textSize14(
                                    context,
                                    weight: FontWeight.w400,
                                    color: AppColors.subtitle(context)
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Right side - Available Badge
                  Container(
                    height: 24,
                    width: 70,
                    decoration: BoxDecoration(color: AppColors.oceanGreenColor, borderRadius: BorderRadius.circular(100)),
                    child: Center(
                      child: Text(
                        "Available",
                        style: AppTextStyles.textSize10(context, color: AppColors.whiteColor, weight: FontWeight.w500),
                      ),
                    ),
                  ),
                ],
              ),
              SizedboxSpaccing.height012(context),
              Divider(height: 1,color: AppColors.border(context),),
              SizedboxSpaccing.height012(context),
              RoundButton(
                title: "Book Now",
                onPress: () {
                  Navigator.pushNamed(context, RoutesName.familyEventCookingScreen, arguments: {
                    'customerName': customerName,
                    'customerPhone': customerPhone,
                    'customerAddress': customerAddress,
                    'isFromHome': true,
                     'customerLocation': customerLocation,

                  });
// Utils.flushBarErrorMessage("Coming Soon", context);

                },
                iconData: Icons.arrow_forward_ios_rounded,
              ),
            ],
          ),
        ),

        SizedboxSpaccing.height02(context),

      ],
    );
  }

}
