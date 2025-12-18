import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/sizedbox_spaccing.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:flutter/material.dart';

class TrendingServicesWidget extends StatelessWidget {
  final List<String> services;

  const TrendingServicesWidget({
    Key? key,
    this.services = const [
      "House Keeper",
      "Home Beauty Parlour",
      "তাৎক্ষণিক বাজার",
    ],
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Container(
      width: screenWidth * 0.9,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Trending Services~",
            style: AppTextStyles.textSize12(
              context,
              weight: FontWeight.w400,
              color: AppColors.form_hover(context),
            ),
          ),
          SizedboxSpaccing.height012(context),
          Wrap(
            spacing: 5, // Horizontal space between items
            runSpacing: 8, // Vertical space between lines
            children: services.map((service) => _buildServiceChip(context, service)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceChip(BuildContext context, String label) {
    return IntrinsicWidth(
      child: Container(
        height: 22,
        padding: EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: AppColors.textFieldFill(context),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(width: 1, color: AppColors.border(context)),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: AppTextStyles.textSize10(
            context,
            weight: FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
