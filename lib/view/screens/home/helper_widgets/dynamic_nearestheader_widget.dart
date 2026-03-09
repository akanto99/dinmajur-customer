import 'package:dinmajur_customer/configs/res/sizedbox_spaccing.dart';
import 'package:flutter/material.dart';
import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';

class DynamicNearestHeader extends StatelessWidget {
  final String? selectedStoreType;
  final int storeCount;
  final double screenWidth;
  final VoidCallback? onSeeAllTap;
  final bool? isInsideServiceArea;
  const DynamicNearestHeader({Key? key, this.selectedStoreType, required this.storeCount, required this.screenWidth, this.onSeeAllTap,
    this.isInsideServiceArea,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: screenWidth * 0.9,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: screenWidth*0.4,
                  color: Colors.transparent,
                  child: Text(_getHeaderTitle(), style: AppTextStyles.textSize18(context, weight: FontWeight.w500))),
              GestureDetector(
                onTap: onSeeAllTap ?? _defaultSeeAllAction,
                child: Container(
                    width: screenWidth*0.2,
                    alignment: Alignment.centerRight,
                    color: Colors.transparent,
                    child: Text('See All', style: AppTextStyles.textSize12(context, weight: FontWeight.w500))),
              ),
            ],
          ),
          SizedboxSpaccing.height005(context),
          Divider(height: 1, color: AppColors.border(context)),
        ],
      ),
    );
  }

  String _getHeaderTitle() {
    if (selectedStoreType == null) return 'Nearest';

    if (selectedStoreType == 'Retail') {
      return 'Nearest ($storeCount)';
    }

    if (selectedStoreType == 'Premium House Keeper' ||
        selectedStoreType == 'Premium Home Beauty & Salon' ||
        selectedStoreType == 'Family Event Cooking') {
      // ✅ Only show (1) if service is confirmed available
      if (isInsideServiceArea == true) return 'Nearest (1)';
      return 'Nearest (0)'; // not available or still checking
    }

    return 'Nearest';
  }

  void _defaultSeeAllAction() {
    debugPrint('See All tapped for: ${selectedStoreType ?? "default"}');
  }
}
