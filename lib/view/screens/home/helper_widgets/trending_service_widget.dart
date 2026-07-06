import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/sizedbox_spaccing.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class TrendingServicesWidget extends StatelessWidget {
  final List<String> services;
  final Function(String)? onServiceTap;
  final String? selectedService;
  final String? loadingService; // ✅ NEW: which card is showing spinner

  const TrendingServicesWidget({
    Key? key,
    this.services = const ["House Keeper", "Beauty Parlour", "তাৎক্ষণিক বাজার", "Family Event Cooking"],
    this.onServiceTap,
    this.selectedService,
    this.loadingService, // ✅ NEW
  }) : super(key: key);

  String _getServiceIcon(String serviceName) {
    switch (serviceName) {
      case "House Keeper":
        return 'assets/images/home/house.svg';
      case "Beauty Parlour":
        return 'assets/images/home/salon.svg';
      case "তাৎক্ষণিক বাজার":
        return 'assets/images/home/bazar.svg';
      case "Family Event Cooking":
        return 'assets/images/home/eventcoking.svg';
      default:
        return 'assets/images/home/house.svg';
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    List<String> topServices = services.where((s) => s != "Family Event Cooking").toList();
    bool hasFamilyEventCooking = services.contains("Family Event Cooking");

    return Container(
      width: screenWidth * 0.9,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "All Home Services~",
            style: AppTextStyles.textSize16(context, weight: FontWeight.w500, color: AppColors.textPrimary(context)),
          ),
          SizedboxSpaccing.height02(context),

          // Top row — 3 services
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: topServices.map((service) {
              return _buildServiceCard(context, service);
            }).toList(),
          ),

          // Family Event Cooking card (full width)
          if (hasFamilyEventCooking) ...[const SizedBox(height: 16), _buildFamilyEventCookingCard(context)],
        ],
      ),
    );
  }

  Widget _buildServiceCard(BuildContext context, String serviceName) {
    final isSelected = selectedService == serviceName;
    final isLoading = loadingService == serviceName;

    return GestureDetector(
      onTap: (onServiceTap != null && loadingService == null)
          ? () => onServiceTap!(serviceName)
          : null,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 100,
                width: 100, // ✅ fixed size
                decoration: BoxDecoration(
                  color: AppColors.containerBackground(context),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    width: isLoading ? 2 : 1,
                    color: isLoading
                        ? AppColors.textPrimary(context)
                        : isSelected
                        ? AppColors.textPrimary(context)
                        : AppColors.border(context),
                  ),
                ),
                child: Center(
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: isLoading ? 0.3 : 1.0,
                    child: SizedBox(
                      height: 80,
                      width: 80,
                      child: RepaintBoundary(
                        child: SvgPicture.asset(_getServiceIcon(serviceName)),
                      ),
                    ),
                  ),
                ),
              ),
              if (isLoading)
                SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: AppColors.textPrimary(context),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            serviceName,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.textSize12(
              context,
              weight: FontWeight.w500,
              color: AppColors.textPrimary(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFamilyEventCookingCard(BuildContext context) {
    final serviceName = "Family Event Cooking";
    final isSelected = selectedService == serviceName;
    final isLoading = loadingService == serviceName; // ✅

    return GestureDetector(
      onTap: (onServiceTap != null && loadingService == null) ? () => onServiceTap!(serviceName) : null,
      child: Stack(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: AppColors.textFieldFill(context),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                width: isLoading ? 2 : 1,
                color: isLoading
                    ? AppColors.textPrimary(context)
                    : isSelected
                    ? AppColors.textPrimary(context)
                    : AppColors.border(context),
              ),
            ),
            padding: const EdgeInsets.all(12),
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: isLoading ? 0.4 : 1.0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          serviceName,
                          style: AppTextStyles.textSize14(context, weight: FontWeight.w500, color: isSelected ? AppColors.buttonTextColor(context) : AppColors.textPrimary(context)),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Professional chefs for your gatherings",
                          style: AppTextStyles.textSize12(context, weight: FontWeight.w400, color: AppColors.subtitle(context)),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 28,
                          width: 106,
                          decoration: BoxDecoration(color: const Color(0xff45A986), borderRadius: BorderRadius.circular(100)),
                          child: Center(
                            child: Text(
                              "New Service",
                              style: AppTextStyles.textSize12(context, weight: FontWeight.w600, color: AppColors.whiteColor),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  ClipOval(
                    child: SizedBox(
                      width: 80,
                      height: 80,
                      child: SvgPicture.asset(_getServiceIcon(serviceName), fit: BoxFit.cover),
                    ),
                  ),                ],
              ),
            ),
          ),

          // ✅ Loading overlay for Family Event card
          if (isLoading)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(color: AppColors.containerBackground(context).withOpacity(0.5), borderRadius: BorderRadius.circular(12)),
                child: Center(
                  child: SizedBox(height: 28, width: 28, child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.textPrimary(context))),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
