import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:dinmajur_customer/model/order_models/get_all_order_model.dart';
import 'package:flutter/material.dart';

class OrderTabBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabChanged;
  final StatusCount? statusCount; // ← add this

  const OrderTabBar({
    super.key,
    required this.selectedIndex,
    required this.onTabChanged,
    this.statusCount, // ← add this
  });

  static const List<String> _tabs = ['Pending', 'Running', 'Completed'];

  String _tabLabel(int index) {
    switch (index) {
      case 0:
        final count = statusCount?.pending ?? 0;
        return count > 0 ? 'Pending($count)' : 'Pending';
      case 1:
        final count = statusCount?.running ?? 0;
        return count > 0 ? 'Running($count)' : 'Running';
      case 2:
        return 'Completed';
      default:
        return _tabs[index];
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      width: screenWidth,
      height: 50,
      color: AppColors.containerBackground(context),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          _tabs.length,
              (index) => _buildTab(context, _tabLabel(index), index, screenWidth),
        ),
      ),
    );
  }

  Widget _buildTab(BuildContext context, String title, int index, double screenWidth) {
    final isSelected = selectedIndex == index;

    return GestureDetector(
      onTap: () => onTabChanged(index),
      child: Container(
        width: screenWidth * 0.3,
        decoration: BoxDecoration(
          color: Colors.transparent,
          border: Border(bottom: BorderSide(color: AppColors.border(context), width: 1.0)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(height: 2),
            Text(
              title,
              style: AppTextStyles.textSize16(
                context,
                color: isSelected ? AppColors.button(context) : AppColors.form_hover(context),
                weight: FontWeight.w500,
              ),
            ),
            Container(
              width: screenWidth * 0.4,
              height: 2,
              color: isSelected ? AppColors.button(context) : AppColors.containerBackground(context),
            ),
          ],
        ),
      ),
    );
  }
}