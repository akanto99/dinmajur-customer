import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/sizedbox_spaccing.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class PaymentMethodWidget extends StatelessWidget {
  final String? selectedPaymentMethod;
  final List<Map<String, dynamic>> paymentMethods;
  final Function(String) onPaymentMethodChanged;

  const PaymentMethodWidget({
    Key? key,
    required this.selectedPaymentMethod,
    required this.paymentMethods,
    required this.onPaymentMethodChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Column(
      children: paymentMethods.asMap().entries.map((entry) {
        final index = entry.key;
        final methodData = entry.value;
        return _buildPaymentMethodItem(context, methodData, index, paymentMethods.length, screenHeight);
      }).toList(),
    );
  }

  Widget _buildPaymentMethodItem(BuildContext context, Map<String, dynamic> methodData, int index, int totalCount, double screenHeight) {
    final method = methodData['method'];
    final title = methodData['title'];
    final iconName = methodData['icon'];
    final iconColor = Color(methodData['color']);
    final isSelected = selectedPaymentMethod == method;

    // Map icon names to FontAwesome icons
    final icon = iconName == 'wallet' ? FontAwesomeIcons.wallet : FontAwesomeIcons.sackDollar;

    return Padding(
      padding: EdgeInsets.only(bottom: index == totalCount - 1 ? screenHeight * 0.015 : screenHeight * 0.01),
      child: GestureDetector(
        onTap: () => onPaymentMethodChanged(method),
        child: Container(
          padding: EdgeInsets.all(screenHeight * 0.015),
          decoration: BoxDecoration(
            color: AppColors.containerBackground(context),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(width: 1, color: AppColors.border(context)),
          ),
          child: Row(
            children: [
              Container(
                height: 24,
                width: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: isSelected ? AppColors.button(context) : AppColors.border(context), width: 2),
                ),
                child: isSelected
                    ? Center(
                  child: Container(
                    height: 12,
                    width: 12,
                    decoration: BoxDecoration(color: AppColors.button(context), shape: BoxShape.circle),
                  ),
                )
                    : null,
              ),
              SizedboxSpaccing.width03(context),
              Expanded(child: Text(title, style: AppTextStyles.textSize16(context, weight: FontWeight.w400))),
              if (method == 'online') ...[
                Container(
                  height: 24,
                  width: 90,
                  // color: Colors.deepOrange,
                  child: Image.asset(
                    'assets/images/home/drawer/ssl.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}