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
  final TextEditingController quantityController = TextEditingController(text: '1');
  String quantityType = 'Quantity'; // 'Quantity' or 'Weight'

// Update the _addItem method in your ManualEntryTab class

  void _addItem() {
    if (itemNameController.text.trim().isNotEmpty && quantityController.text.trim().isNotEmpty) {
      // Generate estimated price based on quantity and type
      double estimatedPrice = _calculateEstimatedPrice(
        itemNameController.text.trim(),
        quantityController.text.trim(),
        quantityType,
      );

      final newItem = {
        'name': itemNameController.text.trim(),
        'quantity': quantityController.text.trim(),
        'quantityType': quantityType,
        'estimatedPrice': estimatedPrice.toString(),
      };

      widget.onAddItem(newItem);

      // Clear the form
      itemNameController.clear();
      quantityController.text = '1';
    }
  }

// Add this method to calculate estimated price
  double _calculateEstimatedPrice(String itemName, String quantity, String quantityType) {
    // Base prices for common items (you can expand this)
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

    // Calculate total based on quantity and type
    int qty = int.tryParse(quantity) ?? 1;

    if (quantityType == 'Weight') {
      // For weight-based items, multiply base price per kg
      return basePrice * qty;
    } else {
      // For quantity-based items, price per piece
      return basePrice * qty;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Column(
      children: [
        Container(
          color: AppColors.containerBackground(context),
          padding: EdgeInsets.symmetric(horizontal: screenHeight * 0.02),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order Items List (if any exist)
              if (widget.orderItems.isNotEmpty) ...[
                _buildOrderItemsList(),
                SizedboxSpaccing.height02(context),
              ],

              CustomTextFormField(
                titleText: "Item Name",
                placeholder: "e.g., Tomatoes, Basmati Rice...",
                controller: itemNameController,
              ),

              SizedboxSpaccing.height02(context),

              _buildQuantityTypeSelector(),

              SizedboxSpaccing.height02(context),

              _buildQuantityCounter(),

              SizedboxSpaccing.height02(context),

              _buildAddItemButton(),

              SizedboxSpaccing.height02(context),
            ],
          ),
        ),
        SizedboxSpaccing.height02(context),
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
          style: AppTextStyles.textSize16(context, weight: FontWeight.w600),
        ),
        SizedboxSpaccing.height01(context),
        Container(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.orderItems.length,
            separatorBuilder: (context, index) => SizedBox(height: screenHeight * 0.01),
// Replace the item display part in your _buildOrderItemsList method

            itemBuilder: (context, index) {
              final item = widget.orderItems[index];
              // double price = double.tryParse(item['estimatedPrice']?.toString() ?? '0') ?? 4.50;

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
                                "${item['quantity']} ${item['quantityType'] == 'Weight' ? 'kg' : 'pcs'}",
                                style: AppTextStyles.textSize12(context, color: Colors.grey),
                              ),
                              const SizedBox(width: 8),
                              // Text(
                              //   "• \$${price.toStringAsFixed(2)}",
                              //   style: AppTextStyles.textSize12(
                              //     context,
                              //     color: AppColors.textPrimary(context),
                              //     weight: FontWeight.w500,
                              //   ),
                              // ),
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

    return Row(
      children: [
        Text(
          "Quantity Type:",
          style: AppTextStyles.textSize14(context, weight: FontWeight.w500),
        ),
        SizedboxSpaccing.width02(context),
        Expanded(
          child: Container(
            padding: EdgeInsets.all(screenHeight * 0.01),
            decoration: BoxDecoration(
              color: AppColors.appBackground(context),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildQuantityTypeOption('Quantity', Icons.numbers),
                  _buildQuantityTypeOption('Weight', FontAwesomeIcons.scaleBalanced),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuantityTypeOption(String type, IconData icon) {
    final isSelected = quantityType == type;

    return GestureDetector(
      onTap: () => setState(() => quantityType = type),
      child: Container(
        height: 25,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.whiteColor : AppColors.appBackground(context),
          borderRadius: BorderRadius.circular(type == 'Weight' ? 8 : 4),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: type == 'Weight' ? 14 : 16,
              color: isSelected ? AppColors.blackColor : AppColors.form_hover(context),
            ),
            SizedboxSpaccing.width01(context),
            if (type == 'Weight') SizedboxSpaccing.width01(context),
            Text(
              type,
              style: AppTextStyles.textSize14(
                context,
                color: isSelected ? AppColors.blackColor : AppColors.form_hover(context),
                weight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantityCounter() {
    return Row(
      children: [
        _buildCounterButton(
          icon: Icons.remove,
          onTap: () {
            int currentValue = int.tryParse(quantityController.text) ?? 1;
            if (currentValue > 1) {
              quantityController.text = (currentValue - 1).toString();
            }
          },
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(5),
            bottomLeft: Radius.circular(5),
          ),
        ),
        Container(
          width: 55,
          height: 35,
          decoration: BoxDecoration(
            color: AppColors.containerBackground(context),
            border: Border(
              top: BorderSide(width: 1, color: AppColors.border(context)),
              bottom: BorderSide(width: 1, color: AppColors.border(context)),
            ),
          ),
          child: TextFormField(
            controller: quantityController,
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            style: AppTextStyles.textSize14(context, weight: FontWeight.w400),
            decoration: const InputDecoration(
              border: OutlineInputBorder(borderSide: BorderSide.none),
              contentPadding: EdgeInsets.symmetric(horizontal: 10.0),
            ),
          ),
        ),
        _buildCounterButton(
          icon: Icons.add,
          onTap: () {
            int currentValue = int.tryParse(quantityController.text) ?? 1;
            quantityController.text = (currentValue + 1).toString();
          },
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(5),
            bottomRight: Radius.circular(5),
          ),
        ),
      ],
    );
  }

  Widget _buildCounterButton({
    required IconData icon,
    required VoidCallback onTap,
    required BorderRadius borderRadius,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 25,
        height: 35,
        decoration: BoxDecoration(
          color: AppColors.appBackground(context),
          border: Border.all(color: AppColors.border(context)),
          borderRadius: borderRadius,
        ),
        child: Icon(icon, size: 16),
      ),
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
              style: AppTextStyles.textSize14(
                context,
                color: Colors.white,
                weight: FontWeight.w500,
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
      padding: EdgeInsets.all(screenHeight * 0.02),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Notes",
            style: AppTextStyles.textSize14(context, weight: FontWeight.w500),
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
              maxLines: 6,
              style: AppTextStyles.textSize14(context, weight: FontWeight.w400),
              decoration: InputDecoration(
                hintText: "Special instructions (e.g., 'ripe avocado')",
                hintStyle: AppTextStyles.textSize12(
                  context,
                  color: AppColors.hintColor(context),
                  weight: FontWeight.w400,
                ),
                border: const OutlineInputBorder(borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 10.0),
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
    quantityController.dispose();
    super.dispose();
  }
}