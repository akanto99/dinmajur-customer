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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
              width: screenWidth*0.4,
              color: Colors.transparent,
              child: Text(_getHeaderTitle(), style: AppTextStyles.textSize18(context, weight: FontWeight.w500))),

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
    return 'Nearest';
  }
}
