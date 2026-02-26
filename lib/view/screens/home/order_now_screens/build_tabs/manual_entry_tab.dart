import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:dinmajur_customer/configs/res/sizedbox_spaccing.dart';
import 'package:dinmajur_customer/configs/widgets/custom_textfield.dart';

class ManualEntryTab extends StatefulWidget {
  final List<Map<String, dynamic>> orderItems;
  final Function(Map<String, dynamic>) onAddItem;
  final Function(int) onRemoveItem;
  final TextEditingController notesController;
  final TextEditingController budgetController;
  final Function(String?) onDeliveryTimeSelected;
  final String? initialDeliveryTime;

  const ManualEntryTab({
    Key? key,
    required this.orderItems,
    required this.onAddItem,
    required this.onRemoveItem,
    required this.notesController,
    required this.budgetController,
    required this.onDeliveryTimeSelected,
    this.initialDeliveryTime,
  }) : super(key: key);

  @override
  State<ManualEntryTab> createState() => _ManualEntryTabState();
}

class _ManualEntryTabState extends State<ManualEntryTab> {
  final TextEditingController itemNameController = TextEditingController();
  final TextEditingController itemWeightController = TextEditingController();

  // Weight types mapping with display names
  final Map<String, String> weightTypes = {
    'gm': 'Grams',
    'kg': 'Kilograms',
    'L': 'Liters',
    'ml': 'Milliliters',
    'pcs': 'Pieces',
    'pack': 'Packet',
    'bottle': 'Bottle',
    'other': 'Others',
  };
  String? selectedWeightType = 'gm';
  String? selectedDeliveryTime;

  @override
  void initState() {
    super.initState();
    selectedDeliveryTime = widget.initialDeliveryTime;
  }

  @override
  void didUpdateWidget(ManualEntryTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialDeliveryTime != oldWidget.initialDeliveryTime) {
      setState(() {
        selectedDeliveryTime = widget.initialDeliveryTime;
      });
    }
  }

  void _addItem() {
    if (itemNameController.text.trim().isNotEmpty && itemWeightController.text.trim().isNotEmpty) {
      final newItem = {
        'name': itemNameController.text.trim(),
        'quantity': itemWeightController.text.trim(),
        'quantityType': selectedWeightType ?? 'gm',
        'weightType': weightTypes[selectedWeightType ?? 'gm'] ?? 'Grams',
      };

      widget.onAddItem(newItem);

      itemNameController.clear();
      itemWeightController.clear();
      setState(() {
        selectedWeightType = 'gm';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppColors.containerBackground(context),
            border: Border.all(
                width: 1, color: AppColors.border(context)
              // top: BorderSide.none,
              // right: BorderSide(width: 1, color: AppColors.border(context)),
              // left: BorderSide(width: 1, color: AppColors.border(context)),
              // bottom: BorderSide(width: 1, color: AppColors.border(context)),
            ),
            borderRadius:  BorderRadius.circular(24),
          ),
          padding: EdgeInsets.symmetric(horizontal: screenHeight * 0.02),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedboxSpaccing.height02(context),
              CustomTextFormField(titleText: "Item Name", placeholder: "e.g., Tomatoes, Basmati Rice...", controller: itemNameController),
              SizedboxSpaccing.height02(context),
              _buildQuantityTypeSelector(),
              SizedboxSpaccing.height02(context),
              _buildAddItemButton(),
              SizedboxSpaccing.height02(context),
            ],
          ),
        ),
        SizedboxSpaccing.height02(context),
        if (widget.orderItems.isNotEmpty) ...[_buildOrderItemsList(), SizedboxSpaccing.height02(context)],
        _buildDeliveryTimeSection(),
        SizedboxSpaccing.height02(context),
        _buildNotesSection(),
        SizedboxSpaccing.height02(context),
      ],
    );
  }

  Widget _buildDeliveryTimeSection() {
    return Container(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Set Delivery Time', style: AppTextStyles.textSize18(context, weight: FontWeight.w500)),
              if (selectedDeliveryTime != null) Icon(Icons.check_circle, color: Colors.green, size: 20),
            ],
          ),
          SizedboxSpaccing.height005(context),
          Divider(height: 1, color: AppColors.border(context)),
          SizedboxSpaccing.height02(context),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              DeliveryTimeCard(
                icon: FontAwesomeIcons.bolt,
                iconColor: const Color(0xffEF4444),
                label: 'ASAP',
                isSelected: selectedDeliveryTime == 'ASAP',
                onTap: () {
                  setState(() {
                    selectedDeliveryTime = 'ASAP';
                  });
                  widget.onDeliveryTimeSelected('ASAP');
                },
              ),
              DeliveryTimeCard(
                icon: Icons.timelapse,
                iconColor: AppColors.textPrimary(context),
                label: '30 mins',
                isSelected: selectedDeliveryTime == '30 mins',
                onTap: () {
                  setState(() {
                    selectedDeliveryTime = '30 mins';
                  });
                  widget.onDeliveryTimeSelected('30 mins');
                },
              ),
            ],
          ),
          SizedboxSpaccing.height02(context),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              DeliveryTimeCard(
                icon: Icons.timelapse,
                iconColor: AppColors.textPrimary(context),
                label: '1 hour',
                isSelected: selectedDeliveryTime == '1 hour',
                onTap: () {
                  setState(() {
                    selectedDeliveryTime = '1 hour';
                  });
                  widget.onDeliveryTimeSelected('1 hour');
                },
              ),
              DeliveryTimeCard(
                icon: Icons.timelapse,
                iconColor: AppColors.textPrimary(context),
                label: '2 hour',
                isSelected: selectedDeliveryTime == '2 hour',
                onTap: () {
                  setState(() {
                    selectedDeliveryTime = '2 hour';
                  });
                  widget.onDeliveryTimeSelected('2 hour');
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItemsList() {
    final screenHeight = MediaQuery.of(context).size.height;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Order Items (${widget.orderItems.length})", style: AppTextStyles.textSize18(context, weight: FontWeight.w500)),
        SizedboxSpaccing.height01(context),
        Container(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.orderItems.length,
            separatorBuilder: (context, index) => SizedBox(height: screenHeight * 0.01),
            itemBuilder: (context, index) {
              final item = widget.orderItems[index];

              return Container(
                decoration: BoxDecoration(
                  color: AppColors.textFieldFill(context),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(width: 1, color: AppColors.border(context)),
                ),
                padding: EdgeInsets.all(screenHeight * 0.015),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item['name'], style: AppTextStyles.textSize14(context, weight: FontWeight.w500)),
                          Text("${item['quantity']} ${item['quantityType']}", style: AppTextStyles.textSize12(context, color: Colors.grey)),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => widget.onRemoveItem(index),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                        child: const Icon(Icons.delete, size: 16, color: Colors.red),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildQuantityTypeSelector() {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: screenWidth * 0.9,
          child: Text("Weight/Quantity", style: AppTextStyles.textSize18(context, weight: FontWeight.w500)),
        ),
        SizedBox(height: screenHeight * 0.012),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: screenWidth * 0.38,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.textFieldFill(context),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(width: 1, color: AppColors.border(context)),
              ),
              child: TextFormField(
                controller: itemWeightController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: AppTextStyles.textSize16(context, weight: FontWeight.w400),
                decoration: InputDecoration(
                  hintText: selectedWeightType == 'pics' ? "5" : "500",
                  hintStyle: AppTextStyles.textSize16(context, color: AppColors.hintColor(context), weight: FontWeight.w400),
                  border: const OutlineInputBorder(borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10.0),
                ),
              ),
            ),
            Container(
              width: screenWidth * 0.38,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.textFieldFill(context),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(width: 1, color: AppColors.border(context)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton2<String>(
                  isExpanded: true,
                  value: selectedWeightType,
                  style: AppTextStyles.textSize16(context, weight: FontWeight.w400),
                  hint: Text(
                    "Select Unit",
                    style: AppTextStyles.textSize16(context, color: AppColors.hintColor(context), weight: FontWeight.w400),
                  ),
                  iconStyleData: IconStyleData(icon: Icon(Icons.keyboard_arrow_down, size: 25, color: AppColors.form_hover(context))),
                  buttonStyleData: ButtonStyleData(width: screenWidth * 0.38, height: 42, padding: const EdgeInsets.symmetric(horizontal: 10)),
                  dropdownStyleData: DropdownStyleData(
                    maxHeight: 200,
                    width: screenWidth * 0.38,
                    decoration: BoxDecoration(color: AppColors.textFieldFill(context), borderRadius: BorderRadius.circular(12)),
                  ),
                  items: weightTypes.entries.map((entry) {
                    return DropdownMenuItem<String>(
                      value: entry.key,
                      child: Text(entry.value, style: AppTextStyles.textSize16(context, weight: FontWeight.w400)),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedWeightType = newValue;
                      if (newValue == 'pics') {
                        itemWeightController.text = '';
                      }
                    });
                  },
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAddItemButton() {
    return GestureDetector(
      onTap: _addItem,
      child: Container(
        height: 48,
        decoration: BoxDecoration(color: AppColors.button(context), borderRadius: BorderRadius.circular(8)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add, color: Colors.white, size: 20),
            SizedboxSpaccing.width01(context),
            Text(
              "Add Item",
              style: AppTextStyles.textSize16(context, color: Colors.white, weight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesSection() {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      color: AppColors.containerBackground(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Notes", style: AppTextStyles.textSize18(context, weight: FontWeight.w500)),
          SizedboxSpaccing.height012(context),
          Container(
            width: screenWidth * 0.9,
            decoration: BoxDecoration(
              color: AppColors.textFieldFill(context),
              borderRadius: BorderRadius.circular(5),
              border: Border.all(width: 1, color: AppColors.border(context)),
            ),
            child: TextField(
              controller: widget.notesController,
              maxLines: 5,
              style: AppTextStyles.textSize16(context, weight: FontWeight.w400),
              decoration: InputDecoration(
                hintText: "Special instructions (e.g., 'ripe avocado')",
                hintStyle: AppTextStyles.textSize16(context, color: AppColors.hintColor(context), weight: FontWeight.w400),
                border: const OutlineInputBorder(borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    itemNameController.dispose();
    itemWeightController.dispose();
    super.dispose();
  }
}

// Reusable Delivery Time Card Widget
class DeliveryTimeCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const DeliveryTimeCard({Key? key, required this.icon, required this.iconColor, required this.label, required this.isSelected, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 80,
        width: 170,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.button(context).withOpacity(0.1) : AppColors.subtitle(context).withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(width: 1, color: isSelected ? AppColors.button(context) : Colors.transparent),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isSelected ? AppColors.button(context) : iconColor, size: 18),
            SizedboxSpaccing.height005(context),
            Text(
              label,
              style: AppTextStyles.textSize14(context, weight: isSelected ? FontWeight.w600 : FontWeight.w400, color: isSelected ? AppColors.button(context) : null),
            ),
          ],
        ),
      ),
    );
  }
}
