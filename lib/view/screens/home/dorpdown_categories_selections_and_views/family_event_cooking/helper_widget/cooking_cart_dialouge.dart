import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/sizedbox_spaccing.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:dinmajur_customer/configs/utils/amount_formatter/amount_formatter.dart';
import 'package:dinmajur_customer/configs/utils/utils.dart';
import 'package:dinmajur_customer/configs/widgets/datepicker_with_formfield.dart';
import 'package:dinmajur_customer/model/home_models/dropdown_categories_selection_models/family_event_cooking_model/getall_family_event_cooking_model.dart';
import 'package:dinmajur_customer/view/screens/home/dorpdown_categories_selections_and_views/family_event_cooking/notifier/cooking_checkout_notifier.dart';
import 'package:dinmajur_customer/view/screens/home/helper_widgets/cart_coponents/cart_header_components.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class FamilyEventCookingCartDialog extends StatefulWidget {
  final List<Datum> categories;
  final Map<String, String?> selectedPackages;
  final Map<String, Set<String>> selectedManualItems;
  final String? activeCategoryId;
  final int selectedGuestRangeIndex;
  final DateTime? selectedDate;
  final String? selectedServiceTime;
  final double transportFee;
  final Function(DateTime) onDateSelected;
  final Function(String) onTimeSelected;
  final TextEditingController dateController;
  final VoidCallback onProceedToCheckout;
  final Function(String categoryId, String key)? onManualItemAdded;

  const FamilyEventCookingCartDialog({
    Key? key,
    required this.categories,
    required this.selectedPackages,
    required this.selectedManualItems,
    required this.activeCategoryId,
    required this.selectedGuestRangeIndex,
    required this.selectedDate,
    required this.selectedServiceTime,
    required this.transportFee,
    required this.onDateSelected,
    required this.onTimeSelected,
    required this.dateController,
    required this.onProceedToCheckout,
    this.onManualItemAdded,
  }) : super(key: key);

  @override
  State<FamilyEventCookingCartDialog> createState() => _FamilyEventCookingCartDialogState();
}

class _FamilyEventCookingCartDialogState extends State<FamilyEventCookingCartDialog> {
  List<Map<String, dynamic>> _addOnItems = [];
  final Set<String> _addedAddOnKeys = {};

  @override
  void initState() {
    super.initState();
    _initAddOns();
  }

  void _initAddOns() {
    final List<Map<String, dynamic>> available = [];

    for (var cat in widget.categories) {
      if (cat.type != 'MANUAL') continue;
      final catId = cat.id ?? '';
      for (var package in (cat.packages ?? [])) {
        for (var item in (package.items ?? [])) {
          final key = '${package.id}_${item.id}';
          if (widget.selectedManualItems[catId]?.contains(key) ?? false) continue;

          double salePrice = 0;
          double origPrice = 0;
          if (widget.selectedGuestRangeIndex < (item.prices?.length ?? 0)) {
            salePrice = item.prices![widget.selectedGuestRangeIndex].salePrice?.toDouble() ?? 0;
            origPrice = item.prices![widget.selectedGuestRangeIndex].originalPrice?.toDouble() ?? 0;
          }
          if (salePrice == 0 && origPrice == 0) continue;

          available.add({
            'key': key,
            'categoryId': catId,
            'name': item.name ?? '',
            'salePrice': salePrice,
            'origPrice': origPrice,
          });
        }
      }
    }

    available.shuffle();
    _addOnItems = available.take(3).toList();
  }

  List<Map<String, dynamic>> _getCartItems() {
    List<Map<String, dynamic>> cartItems = [];
    if (widget.activeCategoryId == null) return cartItems;

    for (var category in widget.categories) {
      if (category.id == widget.activeCategoryId) {
        if (category.type == 'REGULAR') {
          final selectedPackageId = widget.selectedPackages[category.id];
          if (selectedPackageId != null) {
            for (var package in category.packages ?? []) {
              if (package.id == selectedPackageId) {
                double salePrice = 0, originalPrice = 0;
                if (widget.selectedGuestRangeIndex < (package.prices?.length ?? 0)) {
                  salePrice = package.prices![widget.selectedGuestRangeIndex].salePrice?.toDouble() ?? 0;
                  originalPrice = package.prices![widget.selectedGuestRangeIndex].originalPrice?.toDouble() ?? 0;
                }
                cartItems.add({'package': package, 'category': category, 'item': null, 'salePrice': salePrice, 'originalPrice': originalPrice, 'type': 'REGULAR'});
                break;
              }
            }
          }
        } else if (category.type == 'MANUAL') {
          for (var package in category.packages ?? []) {
            for (var item in package.items ?? []) {
              final key = '${package.id}_${item.id}';
              if (widget.selectedManualItems[category.id]?.contains(key) ?? false) {
                double salePrice = 0, originalPrice = 0;
                if (widget.selectedGuestRangeIndex < (item.prices?.length ?? 0)) {
                  salePrice = item.prices![widget.selectedGuestRangeIndex].salePrice?.toDouble() ?? 0;
                  originalPrice = item.prices![widget.selectedGuestRangeIndex].originalPrice?.toDouble() ?? 0;
                }
                cartItems.add({'package': package, 'category': category, 'item': item, 'salePrice': salePrice, 'originalPrice': originalPrice, 'type': 'MANUAL'});
              }
            }
          }
        } else if (category.type == 'CUSTOM') {
          final selectedPackageId = widget.selectedPackages[category.id];
          if (selectedPackageId != null) {
            for (var package in category.packages ?? []) {
              if (package.id == selectedPackageId) {
                final salePrice = package.customPrice?.salePrice?.toDouble() ?? 0;
                final originalPrice = package.customPrice?.originalPrice?.toDouble() ?? 0;
                cartItems.add({'package': package, 'category': category, 'item': null, 'salePrice': salePrice, 'originalPrice': originalPrice, 'type': 'CUSTOM'});
                break;
              }
            }
          }
        }
        break;
      }
    }

    // Also include add-on MANUAL items from other categories that were added via add-ons
    for (var key in _addedAddOnKeys) {
      // Find which category & item this key belongs to
      for (var cat in widget.categories) {
        if (cat.type != 'MANUAL') continue;
        if (cat.id == widget.activeCategoryId) continue;
        for (var package in (cat.packages ?? [])) {
          for (var item in (package.items ?? [])) {
            if ('${package.id}_${item.id}' == key) {
              double salePrice = 0, originalPrice = 0;
              if (widget.selectedGuestRangeIndex < (item.prices?.length ?? 0)) {
                salePrice = item.prices![widget.selectedGuestRangeIndex].salePrice?.toDouble() ?? 0;
                originalPrice = item.prices![widget.selectedGuestRangeIndex].originalPrice?.toDouble() ?? 0;
              }
              cartItems.add({'package': package, 'category': cat, 'item': item, 'salePrice': salePrice, 'originalPrice': originalPrice, 'type': 'MANUAL'});
            }
          }
        }
      }
    }

    return cartItems;
  }

  double _calculateSubtotal() {
    return _getCartItems().fold(0, (sum, item) => sum + (item['salePrice'] as double));
  }

  double _calculateOriginalTotal() {
    return _getCartItems().fold(0, (sum, item) => sum + (item['originalPrice'] as double));
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final cartItems = _getCartItems();

    double subtotal = _calculateSubtotal();
    double originalTotal = _calculateOriginalTotal();
    double saved = originalTotal - subtotal;
    double transport = widget.transportFee;
    double total = subtotal + transport;

    return Dialog(
      backgroundColor: AppColors.containerBackground(context),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      insetPadding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02, vertical: screenHeight * 0.01),
      child: Container(
        width: screenWidth,
        constraints: BoxConstraints(maxHeight: screenHeight * 0.85),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(context, cartItems, subtotal, originalTotal, saved),
            Flexible(
              fit: FlexFit.loose,
              child: SingleChildScrollView(
                child: Container(
                  width: screenWidth * 0.87,
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (cartItems.isEmpty)
                        Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: Text('No items selected', style: AppTextStyles.textSize14(context, color: AppColors.subtitle(context))),
                          ),
                        )
                      else
                        ...cartItems.map((item) => _buildCartItem(context, item, screenWidth)),
                      if (_addOnItems.isNotEmpty) _buildAddOns(context, screenWidth),
                    ],
                  ),
                ),
              ),
            ),
            _buildPriceSummary(context, subtotal, transport, total, screenWidth, saved, originalTotal),
            _buildDateTimeSelection(context, screenWidth),
            _buildCheckoutButton(context, total, screenWidth),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, List<Map<String, dynamic>> cartItems, double subtotal, double originalTotal, double saved) {
    return DynamicCartHeader(itemCount: cartItems.length, totalPrice: subtotal, originalPrice: originalTotal, savedAmount: saved, onClose: () => Navigator.pop(context));
  }

  Widget _buildCartItem(BuildContext context, Map<String, dynamic> item, double screenWidth) {
    final package = item['package'] as Package;
    final itemData = item['item'] as Item?;
    final salePrice = item['salePrice'] as double;
    final originalPrice = item['originalPrice'] as double;
    final type = item['type'] as String;
    final hasDiscount = originalPrice > salePrice;
    final displayName = type == 'MANUAL' ? (itemData?.name ?? '') : (package.name ?? '');

    return Container(
      padding: EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.containerBackground(context),
        border: Border(bottom: BorderSide(width: 1, color: AppColors.border(context))),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(displayName, style: AppTextStyles.textSize14(context, weight: FontWeight.w600), maxLines: 2, overflow: TextOverflow.ellipsis),
                ),
                SizedBox(width: 8),
                Row(
                  children: [
                    Text('৳${AmountFormatter.format(salePrice)}',
                        style: AppTextStyles.textSize14(context, weight: FontWeight.w600, color: AppColors.button(context))),
                    if (hasDiscount) ...[
                      SizedBox(width: 8),
                      Text('৳${AmountFormatter.format(originalPrice)}',
                          style: AppTextStyles.textSize12(context, color: AppColors.subtitle(context)).copyWith(decoration: TextDecoration.lineThrough)),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Add-ons ───────────────────────────────────────────────────────────────

  Widget _buildAddOns(BuildContext context, double screenWidth) {
    final visibleAddOns = _addOnItems.where((a) => !_addedAddOnKeys.contains(a['key'])).toList();
    if (visibleAddOns.isEmpty) return SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 4),
        Text('Add-ons', style: AppTextStyles.textSize16(context, weight: FontWeight.w600)),
        const SizedBox(height: 8),
        ...visibleAddOns.map((addOn) {
          final key = addOn['key'] as String;
          final categoryId = addOn['categoryId'] as String;
          final name = addOn['name'] as String;
          final salePrice = addOn['salePrice'] as double;
          final origPrice = addOn['origPrice'] as double;
          final hasDiscount = origPrice > salePrice && salePrice > 0;

          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: AppTextStyles.textSize14(context, weight: FontWeight.w500)),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text('৳${salePrice.toStringAsFixed(0)}',
                              style: AppTextStyles.textSize12(context, weight: FontWeight.w600, color: AppColors.button(context))),
                          if (hasDiscount) ...[
                            const SizedBox(width: 6),
                            Text('৳${origPrice.toStringAsFixed(0)}',
                                style: AppTextStyles.textSize12(context, color: AppColors.subtitle(context)).copyWith(decoration: TextDecoration.lineThrough)),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() => _addedAddOnKeys.add(key));
                    widget.onManualItemAdded?.call(categoryId, key);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                    decoration: BoxDecoration(color: AppColors.button(context), borderRadius: BorderRadius.circular(100)),
                    child: Text('+ Add', style: AppTextStyles.textSize12(context, weight: FontWeight.w600, color: AppColors.whiteColor)),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
        Divider(height: 1, color: AppColors.border(context)),
        const SizedBox(height: 8),
      ],
    );
  }

  // ─── Price Summary ──────────────────────────────────────────────────────────

  Widget _buildPriceSummary(BuildContext context, double subtotal, double transport, double total, double screenWidth, double saved, double originalTotal) {
    return Container(
      width: screenWidth * 0.87,
      padding: EdgeInsets.symmetric(vertical: 15),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Subtotal', style: AppTextStyles.textSize14(context)),
              Text('৳${AmountFormatter.format(subtotal)}', style: AppTextStyles.textSize14(context, weight: FontWeight.w600)),
            ],
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Transport', style: AppTextStyles.textSize14(context)),
              Text('৳${AmountFormatter.format(transport)}', style: AppTextStyles.textSize14(context, weight: FontWeight.w600)),
            ],
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total', style: AppTextStyles.textSize16(context, weight: FontWeight.w600)),
              Text('৳${AmountFormatter.format(total)}', style: AppTextStyles.textSize16(context, weight: FontWeight.w700, color: AppColors.button(context))),
            ],
          ),
          if (saved > 0) ...[
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'You Saved BDT ${AmountFormatter.format(saved)} in This Order!',
                  style: AppTextStyles.textSize12(context, color: Colors.red, weight: FontWeight.w400).copyWith(decoration: TextDecoration.underline, decorationColor: Colors.red),
                ),
                Text('৳${AmountFormatter.format(originalTotal)}',
                    style: AppTextStyles.textSize12(context, color: Colors.red).copyWith(decoration: TextDecoration.lineThrough, decorationColor: Colors.red)),
              ],
            ),
          ],
          SizedBox(height: 10),
          Divider(color: AppColors.border(context)),
        ],
      ),
    );
  }

  // ─── Date & Time Selection ──────────────────────────────────────────────────

  Widget _buildDateTimeSelection(BuildContext context, double screenWidth) {
    final serviceTimeSlots = ['Day', 'Night'];
    return Container(
      width: screenWidth * 0.87,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomDatePickerFormField(
            title: 'Booking Date',
            controller: widget.dateController,
            onDateSelected: widget.onDateSelected,
            hintText: "mm/dd/yyyy",
            titleTextStyle: AppTextStyles.textSize16(context, weight: FontWeight.w600),
            inputTextStyle: AppTextStyles.textSize14(context, weight: FontWeight.w400),
            hintTextStyle: AppTextStyles.textSize14(context, weight: FontWeight.w400, color: AppColors.subtitle(context)),
          ),
          SizedboxSpaccing.height015(context),
          Text('Select Time Slot', style: AppTextStyles.textSize16(context, weight: FontWeight.w600)),
          SizedboxSpaccing.height012(context),
          Row(
            children: serviceTimeSlots
                .map((time) => Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(right: time == serviceTimeSlots.first ? 5 : 0, left: time == serviceTimeSlots.last ? 5 : 0),
                        child: _serviceTimeButton(context, time),
                      ),
                    ))
                .toList(),
          ),
          SizedboxSpaccing.height015(context),
        ],
      ),
    );
  }

  Widget _serviceTimeButton(BuildContext context, String time) {
    bool isSelected = widget.selectedServiceTime == time;
    return GestureDetector(
      onTap: () => widget.onTimeSelected(time),
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.button(context) : AppColors.fieldColor(context),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isSelected ? AppColors.button(context) : AppColors.border(context), width: 1),
        ),
        child: Center(
          child: Text(time,
              style: AppTextStyles.textSize16(context, weight: isSelected ? FontWeight.w600 : FontWeight.w500, color: isSelected ? AppColors.whiteColor : AppColors.subtitle(context))),
        ),
      ),
    );
  }

  // ─── Checkout Button ────────────────────────────────────────────────────────

  Widget _buildCheckoutButton(BuildContext context, double total, double screenWidth) {
    return Padding(
      padding: EdgeInsets.all(15),
      child: GestureDetector(
        onTap: () {
          if (total < 299) {
            Utils.flushBarExclamatoryMessage(title: "Warning", subtitle: "Minimum order amount is BDT 299 to proceed!", context: context);
            return;
          }

          final checkoutVM = Provider.of<CookingCheckoutViewModel>(context, listen: false);
          String? validationError = checkoutVM.validateCartForm(selectedDate: widget.selectedDate, serviceTime: widget.selectedServiceTime);

          if (validationError != null) {
            Utils.flushBarErrorMessage(validationError, context);
            return;
          }

          Navigator.pop(context);
          widget.onProceedToCheckout();
        },
        child: Container(
          width: screenWidth,
          height: 50,
          decoration: BoxDecoration(color: AppColors.button(context), borderRadius: BorderRadius.circular(8)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Proceed to Checkout', style: AppTextStyles.textSize16(context, weight: FontWeight.w600, color: Colors.white)),
              SizedboxSpaccing.width02(context),
              Icon(FontAwesomeIcons.arrowRight, color: AppColors.whiteColor, size: 12),
            ],
          ),
        ),
      ),
    );
  }
}
