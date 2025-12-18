import 'package:dinmajur_customer/configs/buttons/round_button.dart';
import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/sizedbox_spaccing.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:dinmajur_customer/configs/utils/routes/routes_name.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Dynamic widget to display coverage check status for Premium House Keeper
/// Shows loading, success (Premium House Keeper content), or error states
class PremiumBeautyAndSalonCoverageWidget extends StatelessWidget {
  final bool isCheckingCoverage;
  final bool? isInsideServiceArea;
  final String customerName;
  final String customerPhone;
  final String customerAddress;

  const PremiumBeautyAndSalonCoverageWidget({
    Key? key,
    required this.isCheckingCoverage,
    required this.isInsideServiceArea,
    required this.customerName,
    required this.customerPhone,
    required this.customerAddress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    if (isCheckingCoverage) {
      return _buildLoadingState(context, screenWidth);
    } else if (isInsideServiceArea == true) {
      return _buildPremiumHouseKeeperSection(context, screenWidth, screenHeight);
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
            'Premium Home Beauty & Salon service is not available in your location.',
            style: AppTextStyles.textSize14(context, color: AppColors.subtitle(context)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Premium House Keeper Section - Main content when service is available
  Widget _buildPremiumHouseKeeperSection(BuildContext context, double screenWidth, double screenHeight) {
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
                              FontAwesomeIcons.houseChimneyUser,
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
                                "Home Beauty & Salon",
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
                  Navigator.pushNamed(context, RoutesName.bookNowHomeBeautySalonScreen, arguments: {
                    'customerName': customerName,
                    'customerPhone': customerPhone,
                    'customerAddress': customerAddress,
                  });


                },
                iconData: Icons.arrow_forward_ios_rounded,
              ),
            ],
          ),
        ),

        SizedboxSpaccing.height02(context),

        // // Running Offer Card
        // Container(
        //   width: screenWidth * 0.9,
        //   padding: EdgeInsets.all(screenHeight * 0.02),
        //   decoration: BoxDecoration(
        //     gradient: LinearGradient(colors: [AppColors.blackColor, AppColors.button(context)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        //     borderRadius: BorderRadius.circular(12),
        //   ),
        //   child: Column(
        //     crossAxisAlignment: CrossAxisAlignment.start,
        //     children: [
        //       Row(
        //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //         crossAxisAlignment: CrossAxisAlignment.start,
        //         children: [
        //           // Left side - Offer Details
        //           Expanded(
        //             child: Column(
        //               crossAxisAlignment: CrossAxisAlignment.start,
        //               children: [
        //                 Text(
        //                   "Running Offer!",
        //                   style: AppTextStyles.textSize18(context, weight: FontWeight.w500, color: AppColors.whiteColor),
        //                 ),
        //                 SizedboxSpaccing.height005(context),
        //                 Text(
        //                   "Get 70% discount on Premium House Keeper services",
        //                   style: AppTextStyles.textSize14(context, weight: FontWeight.w400, color: AppColors.whiteColor),
        //                 ),
        //               ],
        //             ),
        //           ),
        //           // Right side - Discount Badge
        //           Container(
        //             height: 64,
        //             width: 78,
        //             decoration: BoxDecoration(color: AppColors.containerBackground(context), borderRadius: BorderRadius.circular(8)),
        //             child: Column(
        //               mainAxisAlignment: MainAxisAlignment.center,
        //               children: [
        //                 Text(
        //                   "70%",
        //                   style: AppTextStyles.textSize20(context, weight: FontWeight.w600, color: AppColors.textPrimary(context)),
        //                 ),
        //                 Text(
        //                   "OFF",
        //                   style: AppTextStyles.textSize14(context, weight: FontWeight.w400, color: AppColors.textPrimary(context)),
        //                 ),
        //               ],
        //             ),
        //           ),
        //         ],
        //       ),
        //       SizedboxSpaccing.height02(context),
        //       // Promo Code Section
        //       Container(
        //         padding: EdgeInsets.all(screenHeight * 0.01),
        //         decoration: BoxDecoration(color: AppColors.button(context), borderRadius: BorderRadius.circular(12)),
        //         child: Row(
        //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //           children: [
        //             Text(
        //               "CLEANDAY",
        //               style: AppTextStyles.textSize18(context, weight: FontWeight.w500, color: AppColors.whiteColor),
        //               textAlign: TextAlign.center,
        //             ),
        //             GestureDetector(
        //               onTap: () => _copyPromoCode(context, "CLEANDAY"),
        //               child: Container(
        //                 height: 24,
        //                 width: 89,
        //                 decoration: BoxDecoration(color: AppColors.whiteColor, borderRadius: BorderRadius.circular(6)),
        //                 child: Center(
        //                   child: Text(
        //                     "Copy Code",
        //                     style: AppTextStyles.textSize12(context, weight: FontWeight.w500, color: AppColors.button(context)),
        //                   ),
        //                 ),
        //               ),
        //             ),
        //           ],
        //         ),
        //       ),
        //     ],
        //   ),
        // ),
        //
        // SizedboxSpaccing.height02(context),
      ],
    );
  }

  void _copyPromoCode(BuildContext context, String code) {
    Clipboard.setData(ClipboardData(text: code));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Promo code "$code" copied to clipboard!', style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.oceanGreenColor,
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
