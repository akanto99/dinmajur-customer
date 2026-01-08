import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/sizedbox_spaccing.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:dinmajur_customer/configs/utils/utils.dart';
import 'package:dinmajur_customer/configs/widgets/datepicker_with_formfield.dart';
import 'package:dinmajur_customer/model/home_models/dropdown_categories_selection_models/family_event_cooking_model/getall_family_event_cooking_model.dart';
import 'package:dinmajur_customer/view/screens/home/dorpdown_categories_selections_and_views/family_event_cooking/notifier/cooking_checkout_notifier.dart';
import 'package:dinmajur_customer/view/screens/home/helper_widgets/cart_coponents/cart_header_components.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

class FamilyEventCookingCartDialog extends StatefulWidget {
  final List<Datum> categories;
  final Map<String, String?> selectedPackages; // Changed to match main screen
  final Map<String, Set<String>> selectedManualItems; // Added for MANUAL items
  final String? activeCategoryId;
  final int selectedGuestRangeIndex;
  final DateTime? selectedDate;
  final String? selectedServiceTime;
  final Function(DateTime) onDateSelected;
  final Function(String) onTimeSelected;
  final TextEditingController dateController;
  final VoidCallback onProceedToCheckout;

  const FamilyEventCookingCartDialog({
    Key? key,
    required this.categories,
    required this.selectedPackages,
    required this.selectedManualItems, // Added parameter
    required this.activeCategoryId,
    required this.selectedGuestRangeIndex,
    required this.selectedDate,
    required this.selectedServiceTime,
    required this.onDateSelected,
    required this.onTimeSelected,
    required this.dateController,
    required this.onProceedToCheckout,
  }) : super(key: key);

  @override
  State<FamilyEventCookingCartDialog> createState() => _FamilyEventCookingCartDialogState();
}

class _FamilyEventCookingCartDialogState extends State<FamilyEventCookingCartDialog> {
  List<Map<String, dynamic>> _getCartItems() {
    List<Map<String, dynamic>> cartItems = [];

    if (widget.activeCategoryId == null) return cartItems;

    for (var category in widget.categories) {
      if (category.id == widget.activeCategoryId) {
        if (category.type == 'REGULAR') {
          // Handle REGULAR packages
          final selectedPackageId = widget.selectedPackages[category.id];
          if (selectedPackageId != null) {
            for (var package in category.packages ?? []) {
              if (package.id == selectedPackageId) {
                double salePrice = 0;
                double originalPrice = 0;

                if (widget.selectedGuestRangeIndex < (package.prices?.length ?? 0)) {
                  salePrice = package.prices![widget.selectedGuestRangeIndex].salePrice?.toDouble() ?? 0;
                  originalPrice = package.prices![widget.selectedGuestRangeIndex].originalPrice?.toDouble() ?? 0;
                }

                cartItems.add({
                  'package': package,
                  'category': category,
                  'item': null,
                  'salePrice': salePrice,
                  'originalPrice': originalPrice,
                  'type': 'REGULAR',
                });
                break;
              }
            }
          }
        } else if (category.type == 'MANUAL') {
          // Handle MANUAL items
          for (var package in category.packages ?? []) {
            for (var item in package.items ?? []) {
              final key = '${package.id}_${item.id}';
              if (widget.selectedManualItems[category.id]?.contains(key) ?? false) {
                double salePrice = 0;
                double originalPrice = 0;

                if (widget.selectedGuestRangeIndex < (item.prices?.length ?? 0)) {
                  salePrice = item.prices![widget.selectedGuestRangeIndex].salePrice?.toDouble() ?? 0;
                  originalPrice = item.prices![widget.selectedGuestRangeIndex].originalPrice?.toDouble() ?? 0;
                }

                cartItems.add({
                  'package': package,
                  'category': category,
                  'item': item,
                  'salePrice': salePrice,
                  'originalPrice': originalPrice,
                  'type': 'MANUAL',
                });
              }
            }
          }
        }
        break;
      }
    }

    return cartItems;
  }

  double _calculateSubtotal() {
    double subtotal = 0;
    final cartItems = _getCartItems();
    for (var item in cartItems) {
      subtotal += item['salePrice'] as double;
    }
    return subtotal;
  }

  double _calculateOriginalTotal() {
    double total = 0;
    final cartItems = _getCartItems();
    for (var item in cartItems) {
      total += item['originalPrice'] as double;
    }
    return total;
  }

  double _calculateSaved() {
    return _calculateOriginalTotal() - _calculateSubtotal();
  }

  String _getGuestRangeText() {
    final ranges = ['25-30', '30-35', '40-50'];
    if (widget.selectedGuestRangeIndex < ranges.length) {
      return ranges[widget.selectedGuestRangeIndex];
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final cartItems = _getCartItems();

    double subtotal = _calculateSubtotal();
    double originalTotal = _calculateOriginalTotal();
    double saved = _calculateSaved();
    double transport = 80.0;
    double total = subtotal + transport;

    return Dialog(
      backgroundColor: AppColors.containerBackground(context),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      insetPadding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.02,
        vertical: screenHeight * 0.01,
      ),
      child: Container(
        width: screenWidth,
        constraints: BoxConstraints(maxHeight: screenHeight * 0.85),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(context, cartItems, subtotal, originalTotal, saved, screenWidth),
            _buildCartItemsList(context, cartItems, screenWidth),
            _buildPriceSummary(context, subtotal, transport, total, screenWidth),
            _buildDateTimeSelection(context, screenWidth),
            _buildCheckoutButton(context, total, screenWidth),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, List<Map<String, dynamic>> cartItems,
      double subtotal, double originalTotal, double saved, double screenWidth) {
    return DynamicCartHeader(
      itemCount: cartItems.length,
      totalPrice: subtotal,
      originalPrice: originalTotal,
      savedAmount: saved,
      onClose: () => Navigator.pop(context),
    );
  }

  Widget _buildCartItemsList(BuildContext context, List<Map<String, dynamic>> cartItems, double screenWidth) {
    return Expanded(
      child: SingleChildScrollView(
        child: Container(
          width: screenWidth * 0.87,
          padding: EdgeInsets.symmetric(vertical: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Selected Items',
                    style: AppTextStyles.textSize16(context, weight: FontWeight.w600),
                  ),
                  SizedBox(width: 8),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.button(context).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.button(context)),
                    ),
                    child: Text(
                      'Guests: ${_getGuestRangeText()}',
                      style: AppTextStyles.textSize12(
                        context,
                        weight: FontWeight.w600,
                        color: AppColors.button(context),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              if (cartItems.isEmpty)
                Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Text(
                      'No items selected',
                      style: AppTextStyles.textSize14(
                        context,
                        color: AppColors.subtitle(context),
                      ),
                    ),
                  ),
                )
              else
                ...cartItems.map((item) => _buildCartItem(context, item, screenWidth)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCartItem(BuildContext context, Map<String, dynamic> item, double screenWidth) {
    final package = item['package'] as Datum;
    final itemData = item['item'] as Datum?;
    final salePrice = item['salePrice'] as double;
    final originalPrice = item['originalPrice'] as double;
    final type = item['type'] as String;
    final hasDiscount = originalPrice > salePrice;

    // For MANUAL type, show the individual item; for REGULAR, show the package
    final displayName = type == 'MANUAL' ? (itemData?.name ?? '') : (package.name ?? '');
    final displayImage = type == 'MANUAL' ? (itemData?.image ?? package.image) : package.image;
    final displayDescription = type == 'MANUAL' ? (itemData?.description) : null;

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.textFieldFill(context),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Item/Package Image
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CachedNetworkImage(
              imageUrl: displayImage ?? '',
              width: 70,
              height: 70,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                width: 70,
                height: 70,
                color: AppColors.border(context),
                child: Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.button(context),
                  ),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                width: 70,
                height: 70,
                color: AppColors.border(context),
                child: Icon(Icons.restaurant, color: AppColors.subtitle(context)),
              ),
            ),
          ),
          SizedBox(width: 12),
          // Item/Package Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  style: AppTextStyles.textSize14(context, weight: FontWeight.w600),
                ),
                if (type == 'REGULAR' && package.items != null && package.items!.isNotEmpty) ...[
                  SizedBox(height: 4),
                  ...package.items!.take(3).map((subItem) => Padding(
                    padding: EdgeInsets.only(bottom: 2),
                    child: Text(
                      '• ${subItem.name ?? ''}',
                      style: AppTextStyles.textSize12(
                        context,
                        color: AppColors.subtitle(context),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  )),
                  if (package.items!.length > 3)
                    Text(
                      '+${package.items!.length - 3} more items',
                      style: AppTextStyles.textSize12(
                        context,
                        color: AppColors.button(context),
                      ),
                    ),
                ],
                if (type == 'MANUAL' && displayDescription != null && displayDescription.isNotEmpty) ...[
                  SizedBox(height: 4),
                  Text(
                    displayDescription,
                    style: AppTextStyles.textSize12(
                      context,
                      color: AppColors.subtitle(context),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      '৳${salePrice.toStringAsFixed(0)}',
                      style: AppTextStyles.textSize14(
                        context,
                        weight: FontWeight.w600,
                        color: AppColors.button(context),
                      ),
                    ),
                    if (hasDiscount) ...[
                      SizedBox(width: 8),
                      Text(
                        '৳${originalPrice.toStringAsFixed(0)}',
                        style: AppTextStyles.textSize12(
                          context,
                          color: AppColors.subtitle(context),
                        ).copyWith(decoration: TextDecoration.lineThrough),
                      ),
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

  Widget _buildPriceSummary(BuildContext context, double subtotal,
      double transport, double total, double screenWidth) {
    return Container(
      width: screenWidth * 0.87,
      padding: EdgeInsets.symmetric(vertical: 15),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: AppColors.border(context), width: 1),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Subtotal', style: AppTextStyles.textSize14(context)),
              Text(
                '৳${subtotal.toStringAsFixed(0)}',
                style: AppTextStyles.textSize14(context, weight: FontWeight.w600),
              ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Transport', style: AppTextStyles.textSize14(context)),
              Text(
                '৳${transport.toStringAsFixed(0)}',
                style: AppTextStyles.textSize14(context, weight: FontWeight.w600),
              ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: AppTextStyles.textSize16(context, weight: FontWeight.w600),
              ),
              Text(
                '৳${total.toStringAsFixed(0)}',
                style: AppTextStyles.textSize16(
                  context,
                  weight: FontWeight.w700,
                  color: AppColors.button(context),
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Divider(color: AppColors.border(context)),
        ],
      ),
    );
  }

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
            hintTextStyle: AppTextStyles.textSize14(
              context,
              weight: FontWeight.w400,
              color: AppColors.subtitle(context),
            ),
          ),
          SizedboxSpaccing.height015(context),
          Text(
            'Select Time Slot',
            style: AppTextStyles.textSize16(context, weight: FontWeight.w600),
          ),
          SizedboxSpaccing.height012(context),
          Row(
            children: serviceTimeSlots
                .map((time) => Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: time == serviceTimeSlots.first ? 5 : 0,
                  left: time == serviceTimeSlots.last ? 5 : 0,
                ),
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
          color: isSelected ? AppColors.button(context) : AppColors.containerBackground(context),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.button(context) : AppColors.border(context),
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            time,
            style: AppTextStyles.textSize16(
              context,
              weight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected ? AppColors.whiteColor : AppColors.subtitle(context),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCheckoutButton(BuildContext context, double total, double screenWidth) {
    return Padding(
      padding: EdgeInsets.all(15),
      child: GestureDetector(
        onTap: () {
          if (total < 1) {
            Utils.flushBarExclamatoryMessage(
              title: "Warning",
              subtitle: "Minimum order amount is BDT 600 to proceed!",
              context: context,
            );
            return;
          }

          final checkoutVM = Provider.of<CookingCheckoutViewModel>(context, listen: false);

          String? validationError = checkoutVM.validateCartForm(
            selectedDate: widget.selectedDate,
            serviceTime: widget.selectedServiceTime,
          );

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
          decoration: BoxDecoration(
            color: AppColors.button(context),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Proceed to Checkout',
                style: AppTextStyles.textSize16(
                  context,
                  weight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              SizedboxSpaccing.width02(context),
              Icon(
                FontAwesomeIcons.arrowRight,
                color: AppColors.whiteColor,
                size: 12,
              )
            ],
          ),
        ),
      ),
    );
  }
}