import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


class CustomDatePickerFormField extends StatelessWidget {
  final String title;
  final TextEditingController controller;
  final String? Function(String?)? validator;

  const CustomDatePickerFormField({
    Key? key,
    required this.title,
    required this.controller,
    this.validator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: screenWidth * 0.9,
          child: Text(
            title,
              style: AppTextStyles.textSize18(context, weight: FontWeight.w500)
          ),
        ),
        SizedBox(height: screenHeight * 0.01,),
        FormField<String>(
          validator: validator,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          builder: (FormFieldState<String> state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: screenWidth * 0.9,
                  height: 42,
                  // height: screenHeight*0.05,
                  decoration: BoxDecoration(
                      color: AppColors.textFieldFill(context),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          width: 1,
                          color: AppColors.border(context)
                      )
                  ),
                  child: TextFormField(
                    controller: controller,
                    keyboardType: TextInputType.datetime,
                    readOnly: true,
                      style:  AppTextStyles.textSize16(context, weight: FontWeight.w500),
                      decoration: InputDecoration(
                        hintText: "dd/mm/yy",
                        hintStyle: AppTextStyles.textSize16(context,color: AppColors.hintColor(context), weight: FontWeight.w400),
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 10.0),
                      ),

                      onTap: () async {
                        DateTime? initialDate = controller.text.isNotEmpty
                            ? DateFormat('dd/MM/yyyy').parse(controller.text)
                            : DateTime.now();

                        DateTime? pickedDate = await showDatePicker(
                          initialEntryMode: DatePickerEntryMode.calendarOnly,
                          context: context,
                          initialDate: initialDate,
                          firstDate: DateTime(1950),
                          lastDate: DateTime(2101),
                          builder: (BuildContext context, Widget? child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme:  ColorScheme.light(
                                  primary:  AppColors.button(context),
                                  onPrimary: Colors.white,
                                  onSurface:  AppColors.button(context),
                                ),
                                datePickerTheme:  DatePickerThemeData(
                                  headerBackgroundColor: AppColors.button(context),
                                  backgroundColor: Colors.white,
                                  headerForegroundColor: Colors.white,
                                  surfaceTintColor: Colors.white,
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );

                        if (pickedDate != null) {
                          String formattedDate = DateFormat('dd/MM/yyyy').format(pickedDate);
                          controller.text = formattedDate;
                          state.didChange(formattedDate);
                        }
                      }


                  ),
                ),
                if (state.hasError)
                  Container(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 4.0, left: 10),
                      child: Text(
                        state.errorText ?? '',
                        style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.w400,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  )

              ],
            );
          },
        ),
      ],
    );
  }
}
