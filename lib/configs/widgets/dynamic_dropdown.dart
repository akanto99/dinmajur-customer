import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

class CustomDropdown extends StatelessWidget {
  final String titleText;
  final List<String> items;
  final String? selectedItem;
  final String hintText;
  final void Function(String?) onChanged;
  final Map<String, String>? valueToBengaliMap;
  final double? dynamicWidth;

  const CustomDropdown({
    Key? key,
    required this.titleText,
    required this.items,
    required this.selectedItem,
    required this.hintText,
    required this.onChanged,
    this.valueToBengaliMap,
    this.dynamicWidth,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width * 1;
    final screenHeight = MediaQuery.of(context).size.height *1;
    final double actualWidth = dynamicWidth ?? (screenWidth * 0.8);
    return Column(
      children: [
        Container(
            width: screenWidth * 0.9,
            child: Text(titleText,  style: AppTextStyles.poppins18(context, weight: FontWeight.w500))),
        SizedBox(height: screenHeight * 0.012,),
        Container(
          height: 42,
          // height: screenHeight * 0.05,
          child: DropdownButtonHideUnderline(
            child: DropdownButton2<String>(
              isExpanded: true,
              value: selectedItem,
              style:  AppTextStyles.poppins16(context, weight: FontWeight.w500),
              hint: Text(hintText ,style:  AppTextStyles.poppins16(context,color: AppColors.hintColor(context), weight: FontWeight.w400),),
              buttonStyleData: ButtonStyleData(
                width: screenWidth * 0.9,
                height: 42,
                // height: screenHeight * 0.06,
                decoration: BoxDecoration(
                    color: AppColors.textFieldFill(context),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        width: 1,
                        color: AppColors.border(context)
                    )
                ),
                padding: const EdgeInsets.symmetric(horizontal: 10,),
              ),
              dropdownStyleData: DropdownStyleData(
                // padding: EdgeInsets.all( screenHeight*0.01),
                maxHeight: 200,
                width: actualWidth,
                decoration: BoxDecoration(
                  color: AppColors.textFieldFill(context),
                ),
              ),
              items: items.map((item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(valueToBengaliMap?[item] ?? item, style:  AppTextStyles.poppins16(context, weight: FontWeight.w500),
                  ),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
