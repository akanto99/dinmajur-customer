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

  const ManualEntryTab({
    Key? key,
    required this.orderItems,
    required this.onAddItem,
    required this.onRemoveItem,
    required this.notesController,
  }) : super(key: key);

  @override
  State<ManualEntryTab> createState() => _ManualEntryTabState();
}

class _ManualEntryTabState extends State<ManualEntryTab> {
  final TextEditingController itemNameController = TextEditingController();
  final TextEditingController itemWeightController = TextEditingController();
  final TextEditingController quantityController = TextEditingController(text: '1');

  // Weight types mapping with display names
  final Map<String, String> weightTypes = {
    'gm': 'Grams',
    'kg': 'Kilograms',
    'lr': 'Liters',
    'pics': 'Pieces',
  };
  String? selectedWeightType = 'gm'; // Default selection

  void _addItem() {
    if (itemNameController.text.trim().isNotEmpty &&
        itemWeightController.text.trim().isNotEmpty) {

      // Generate estimated price based on weight/quantity and type
      double estimatedPrice = _calculateEstimatedPrice(
        itemNameController.text.trim(),
        itemWeightController.text.trim(),
        selectedWeightType ?? 'gm',
      );

      final newItem = {
        'name': itemNameController.text.trim(),
        'quantity': itemWeightController.text.trim(),
        'quantityType': selectedWeightType ?? 'gm',
        'weightType': weightTypes[selectedWeightType ?? 'gm'] ?? 'Grams',
        'estimatedPrice': estimatedPrice.toString(),
      };

      widget.onAddItem(newItem);

      // Clear the form
      itemNameController.clear();
      itemWeightController.clear();
      setState(() {
        selectedWeightType = 'gm'; // Reset to default
      });
    }
  }

  double _calculateEstimatedPrice(String itemName, String quantity, String quantityType) {
    // Base prices for common items (per unit/kg)
    Map<String, double> basePrices = {
      'tomato': 2.50,
      'tomatoes': 2.50,
      'rice': 3.00,
      'basmati rice': 4.50,
      'chicken': 6.00,
      'beef': 8.00,
      'milk': 3.50,
      'bread': 2.00,
      'onion': 1.50,
      'onions': 1.50,
      'potato': 1.80,
      'potatoes': 1.80,
      'apple': 3.20,
      'apples': 3.20,
      'banana': 2.10,
      'bananas': 2.10,
    };

    // Get base price
    String itemKey = itemName.toLowerCase();
    double basePrice = basePrices[itemKey] ?? 4.50; // Default price if item not found

    // Parse quantity
    double qty = double.tryParse(quantity) ?? 1.0;

    // Calculate total based on quantity type
    switch (quantityType) {
      case 'kg':
        return basePrice * qty;
      case 'gm':
        return basePrice * (qty / 1000); // Convert grams to kg
      case 'lr':
        return basePrice * qty; // Price per liter
      case 'pics':
        return basePrice * qty; // Price per piece
      default:
        return basePrice * qty;
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
            border: Border(
              top: BorderSide.none,
              right: BorderSide(width: 1, color: AppColors.border(context)),
              left: BorderSide(width: 1, color: AppColors.border(context)),
              bottom: BorderSide(width: 1, color: AppColors.border(context)),
            ),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(24),
              bottomRight: Radius.circular(24),
            ),
          ),
          padding: EdgeInsets.symmetric(horizontal: screenHeight * 0.02),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedboxSpaccing.height02(context),
              CustomTextFormField(
                titleText: "Item Name",
                placeholder: "e.g., Tomatoes, Basmati Rice...",
                controller: itemNameController,
              ),
              SizedboxSpaccing.height02(context),
              _buildQuantityTypeSelector(),
              SizedboxSpaccing.height02(context),
              _buildAddItemButton(),
              SizedboxSpaccing.height02(context),
            ],
          ),
        ),
        SizedboxSpaccing.height02(context),
        if (widget.orderItems.isNotEmpty) ...[_buildOrderItemsList(),        SizedboxSpaccing.height02(context),],

        _buildNotesSection(),
      ],
    );
  }

  Widget _buildOrderItemsList() {
    final screenHeight = MediaQuery.of(context).size.height;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Order Items (${widget.orderItems.length})",
          style: AppTextStyles.textSize18(context, weight: FontWeight.w500),
        ),
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
                          Text(
                            item['name'],
                            style: AppTextStyles.textSize14(context, weight: FontWeight.w500),
                          ),
                          Row(
                            children: [
                              Text(
                                "${item['quantity']} ${item['quantityType']}",
                                style: AppTextStyles.textSize12(context, color: Colors.grey),
                              ),
                              const SizedBox(width: 8),
                              // if (item['estimatedPrice'] != null)
                              //   Text(
                              //     "৳${double.parse(item['estimatedPrice']).toStringAsFixed(2)}",
                              //     style: AppTextStyles.textSize12(
                              //       context,
                              //       color: AppColors.button(context),
                              //       weight: FontWeight.w500,
                              //     ),
                              //   ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => widget.onRemoveItem(index),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
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
          child: Text(
            "Weight/Quantity",
            style: AppTextStyles.textSize18(context, weight: FontWeight.w500),
          ),
        ),
        SizedBox(height: screenHeight * 0.012),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Quantity/Weight Input Field
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
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                style: AppTextStyles.textSize16(context, weight: FontWeight.w400),
                decoration: InputDecoration(
                  hintText: selectedWeightType == 'pics' ? "5" : "500",
                  hintStyle: AppTextStyles.textSize16(
                    context,
                    color: AppColors.hintColor(context),
                    weight: FontWeight.w400,
                  ),
                  border: const OutlineInputBorder(borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10.0),
                ),
              ),
            ),
            // Weight Type Dropdown
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
                    style: AppTextStyles.textSize16(
                      context,
                      color: AppColors.hintColor(context),
                      weight: FontWeight.w400,
                    ),
                  ),
                  iconStyleData: IconStyleData(
                    icon: Icon(
                      Icons.keyboard_arrow_down,
                      size: 25,
                      color: AppColors.form_hover(context),
                    ),
                  ),
                  buttonStyleData: ButtonStyleData(
                    width: screenWidth * 0.38,
                    height: 42,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                  ),
                  dropdownStyleData: DropdownStyleData(
                    maxHeight: 200,
                    width: screenWidth * 0.38,
                    decoration: BoxDecoration(
                      color: AppColors.textFieldFill(context),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: weightTypes.entries.map((entry) {
                    return DropdownMenuItem<String>(
                      value: entry.key,
                      child: Text(
                        entry.value,
                        style: AppTextStyles.textSize16(context, weight: FontWeight.w400),
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedWeightType = newValue;
                      // Update hint text based on selection
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
        decoration: BoxDecoration(
          color: AppColors.button(context),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add, color: Colors.white, size: 20),
            SizedboxSpaccing.width01(context),
            Text(
              "Add Item",
              style: AppTextStyles.textSize16(
                context,
                color: Colors.white,
                weight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesSection() {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      color: AppColors.containerBackground(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Notes",
            style: AppTextStyles.textSize18(context, weight: FontWeight.w500),
          ),
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
                hintStyle: AppTextStyles.textSize16(
                  context,
                  color: AppColors.hintColor(context),
                  weight: FontWeight.w400,
                ),
                border: const OutlineInputBorder(borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 10.0,vertical: 10),
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
    quantityController.dispose();
    super.dispose();
  }
}