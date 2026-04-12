import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/sizedbox_spaccing.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:dinmajur_customer/configs/utils/amount_formatter/amount_formatter.dart';
import 'package:dinmajur_customer/configs/utils/utils.dart';
import 'package:dinmajur_customer/model/home_models/dropdown_categories_selection_models/premium_house_keeper_model/getall_premium_house_keeper_task_model.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class TaskDetailsDialog extends StatefulWidget {
  final Datum service;
  final Map<String, int> serviceQuantities;
  final Map<String, Set<String>> selectedTaskItems;
  final Function(String serviceId, int quantity, Set<String> selectedItems) onUpdate;

  const TaskDetailsDialog({Key? key, required this.service, required this.serviceQuantities, required this.selectedTaskItems, required this.onUpdate}) : super(key: key);

  @override
  State<TaskDetailsDialog> createState() => _TaskDetailsDialogState();
}

class _TaskDetailsDialogState extends State<TaskDetailsDialog> {
  late int tempQuantity;
  late Set<String> tempSelectedItems;

  @override
  void initState() {
    super.initState();

    // Store original quantity
    int originalQuantity = widget.serviceQuantities[widget.service.id ?? ''] ?? 0;

    // Get current selected items
    Set<String> currentSelectedItems = widget.selectedTaskItems[widget.service.id ?? ''] ?? {};

    // If quantity is 0 OR no items are selected, reset to all items (default state)
    if (originalQuantity == 0 || currentSelectedItems.isEmpty) {
      tempSelectedItems = widget.service.houseKeeperTaskItems?.map((item) => item.id ?? '').toSet() ?? {};
    } else {
      tempSelectedItems = Set<String>.from(currentSelectedItems);
    }

    // Create temporary quantity variable - minimum 1
    tempQuantity = originalQuantity > 0 ? originalQuantity : 1;
  }

  double _calculateOriginalPrice(Set<String> items) {
    double price = 0;
    for (var item in widget.service.houseKeeperTaskItems ?? []) {
      if (items.contains(item.id ?? '')) {
        price += item.price?.toDouble() ?? 0;
      }
    }
    return price;
  }

  double _calculateDiscountedPrice(double original) {
    if (widget.service.discountType != null && widget.service.discountValue != null && original > 0) {
      if (widget.service.discountType == 'PERCENTAGE') {
        return original - (original * widget.service.discountValue! / 100);
      } else if (widget.service.discountType == 'FLAT') {
        return original - widget.service.discountValue!.toDouble();
      }
    }
    return original;
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    double originalPricePerUnit = _calculateOriginalPrice(tempSelectedItems);
    double discountedPricePerUnit = _calculateDiscountedPrice(originalPricePerUnit);

    // Calculate total prices (multiplied by tempQuantity)
    double totalOriginalPrice = originalPricePerUnit * (tempQuantity > 0 ? tempQuantity : 1);
    double totalDiscountedPrice = discountedPricePerUnit * (tempQuantity > 0 ? tempQuantity : 1);

    bool allSelected = tempSelectedItems.length == (widget.service.houseKeeperTaskItems?.length ?? 0);

    return WillPopScope(
      onWillPop: () async {
        // Revert changes if dialog is closed without clicking "Update Items"
        return true;
      },
      child: Dialog(
        backgroundColor: AppColors.containerBackground(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        insetPadding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02, vertical: screenHeight * 0.01),
        child: Container(
          width: screenWidth,
          constraints: BoxConstraints(maxHeight: screenHeight * 0.7),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(context, totalDiscountedPrice, totalOriginalPrice, screenWidth),
              _buildRoomNumberSection(context, screenWidth),
              _buildSelectAllCheckbox(context, allSelected, screenWidth),
              _buildTaskItemsList(context, screenWidth),
              _buildUpdateButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, double totalDiscountedPrice, double totalOriginalPrice, double screenWidth) {
    return Container(
      width: screenWidth * 0.87,

      // padding: EdgeInsets.only(bottom: 15),
      padding: EdgeInsets.symmetric(vertical: 15),
      // decoration: BoxDecoration(
      //   border: Border(bottom: BorderSide(color: AppColors.border(context), width: 1)),
      // ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  height: 38,
                  width: 38,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.button(context).withOpacity(0.2)),
                  child: Icon(FontAwesomeIcons.close, color: AppColors.textPrimary(context), size: 20),
                ),
              ),
            ],
          ),
          SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  widget.service.name ?? '',
                  style: AppTextStyles.textSize16(context, weight: FontWeight.w600),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Row(
                children: [
                  Text('৳${AmountFormatter.format(totalDiscountedPrice)}', style: AppTextStyles.textSize16(context, weight: FontWeight.w600)),
                  if (widget.service.discountValue != null && totalOriginalPrice > 0) ...[
                    SizedboxSpaccing.width02(context),
                    Text(
                      // '${totalOriginalPrice.toStringAsFixed(2)}',
                      '৳${AmountFormatter.format(totalOriginalPrice)}',
                      style: AppTextStyles.textSize12(context, color: AppColors.subtitle(context), weight: FontWeight.w600).copyWith(decoration: TextDecoration.lineThrough),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRoomNumberSection(BuildContext context, double screenWidth) {
    final bool isHourly = widget.service.hasHour == true;

    return Container(
      width: screenWidth * 0.87,
      padding: EdgeInsets.only(bottom: 5, top: 15),
      // decoration: BoxDecoration(
      //   border: Border(bottom: BorderSide(color: AppColors.border(context), width: 1)),
      // ),
      child: Row(
        children: [
          Container(
            width: 13,
            height: 13,
            decoration: BoxDecoration(shape: BoxShape.circle, color: isHourly ? Colors.orange : AppColors.textPrimary(context)),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              isHourly ? 'Hourly Service' : 'Room Number',
              style: AppTextStyles.textSize14(context, weight: FontWeight.w500, color: isHourly ? Colors.orange : AppColors.textPrimary(context)),
            ),
          ),
          Row(
            children: [
              _buildQuantityButton(
                icon: FontAwesomeIcons.minus,
                onTap: () {
                  if (tempQuantity > 1) {
                    setState(() => tempQuantity--);
                  }
                },
              ),
              Container(
                width: 40,
                child: Center(
                  child: Text(tempQuantity.toString(), style: AppTextStyles.textSize16(context, weight: FontWeight.w600)),
                ),
              ),
              _buildQuantityButton(
                icon: FontAwesomeIcons.plus,
                onTap: () {
                  final canIncrement = widget.service.hasRoom == true || widget.service.hasHour == true;
                  if (!canIncrement) {
                    Utils.flushBarExclamatoryMessage(title: "Can't Add More", subtitle: "Additional quantity isn't available for this service.", context: context);
                  } else {
                    setState(() => tempQuantity++);
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 25,
        height: 25,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border(context)),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Icon(icon, size: 14),
      ),
    );
  }

  Widget _buildSelectAllCheckbox(BuildContext context, bool allSelected, double screenWidth) {
    return Container(
      width: screenWidth * 0.87,
      padding: EdgeInsets.symmetric(vertical: 15),
      decoration: BoxDecoration(
        color: AppColors.containerBackground(context),
        border: Border(bottom: BorderSide(width: 1, color: AppColors.border(context))),
      ),
      child: Row(
        // mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 20,
            width: 20,
            child: Checkbox(
              value: allSelected,
              checkColor: AppColors.whiteColor,
              activeColor: AppColors.button(context),
              side: BorderSide(color: AppColors.textPrimary(context), width: 1.5),
              onChanged: (bool? value) {
                setState(() {
                  if (value == true) {
                    tempSelectedItems = widget.service.houseKeeperTaskItems?.map((item) => item.id ?? '').toSet() ?? {};
                  } else {
                    tempSelectedItems.clear();
                  }
                });
              },
            ),
          ),
          SizedboxSpaccing.width02(context),
          Text('Select All', style: AppTextStyles.textSize16(context, weight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildTaskItemsList(BuildContext context, double screenWidth) {
    return Flexible(
      child: widget.service.houseKeeperTaskItems?.isEmpty == true
          ? Container(
              width: screenWidth * 0.87,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                child: Text('No task details available', style: AppTextStyles.textSize14(context)),
              ),
            )
          : Container(
              width: screenWidth * 0.87,
              child: ListView.separated(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: widget.service.houseKeeperTaskItems?.length ?? 0,
                separatorBuilder: (context, index) => Divider(height: 1, color: AppColors.border(context)),
                itemBuilder: (context, index) {
                  final task = widget.service.houseKeeperTaskItems![index];
                  bool isSelected = tempSelectedItems.contains(task.id ?? '');

                  return Container(
                    padding: EdgeInsets.symmetric(vertical: 15),
                    child: Row(
                      children: [
                        SizedBox(
                          height: 20,
                          width: 20,
                          child: Checkbox(
                            value: isSelected,
                            activeColor: AppColors.button(context),
                            checkColor: AppColors.whiteColor,
                            side: BorderSide(color: AppColors.textPrimary(context), width: 1.5),
                            onChanged: (bool? value) {
                              setState(() {
                                if (value == true) {
                                  tempSelectedItems.add(task.id ?? '');
                                } else {
                                  tempSelectedItems.remove(task.id ?? '');
                                }
                              });
                            },
                          ),
                        ),
                        SizedboxSpaccing.width02(context),
                        Expanded(
                          child: Text(task.name ?? '', style: AppTextStyles.textSize14(context, weight: FontWeight.w400)),
                        ),
                        SizedBox(width: 8),
                        // Text('${task.price ?? 0} Taka', style: AppTextStyles.textSize14(context, weight: FontWeight.w500)),
                        Text(   '${AmountFormatter.format(task.price ?? 0)} Taka', style: AppTextStyles.textSize14(context, weight: FontWeight.w500)),
                      ],
                    ),
                  );
                },
              ),
            ),
    );
  }

  Widget _buildUpdateButton(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      child: GestureDetector(
        onTap: () {
          // Call the callback with updated values
          widget.onUpdate(widget.service.id ?? '', tempSelectedItems.isEmpty ? 0 : tempQuantity, tempSelectedItems);
          Navigator.pop(context);
        },
        child: Container(
          width: double.infinity,
          height: 48,
          decoration: BoxDecoration(color: AppColors.button(context), borderRadius: BorderRadius.circular(8)),
          child: Center(
            child: Text(
              'Update Items',
              style: AppTextStyles.textSize16(context, weight: FontWeight.w600, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}
