import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/sizedbox_spaccing.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:dinmajur_customer/configs/utils/amount_formatter/amount_formatter.dart';
import 'package:dinmajur_customer/configs/utils/utils.dart';
import 'package:dinmajur_customer/configs/widgets/datepicker_with_formfield.dart';
import 'package:dinmajur_customer/data/response/status.dart';
import 'package:dinmajur_customer/model/home_models/dropdown_categories_selection_models/beauty_and_salon_model/get_bookedslot_model.dart';
import 'package:dinmajur_customer/model/home_models/dropdown_categories_selection_models/beauty_and_salon_model/getall_premium_home_beauty_salon_model.dart';
import 'package:dinmajur_customer/view/screens/home/dorpdown_categories_selections_and_views/beauty_and_salon/notifier/checkout_notifier.dart';
import 'package:dinmajur_customer/view/screens/home/helper_widgets/cart_coponents/cart_header_components.dart';
import 'package:dinmajur_customer/view/screens/home/helper_widgets/cart_coponents/cart_servicelist_component.dart';
import 'package:dinmajur_customer/view_model/homeview_model/dropdown_categories_selection_view_models/beauty_and_salon_view_model/get_bookedslot_view_model.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class CartDialogWidget extends StatefulWidget {
  final List<Datum> categories;
  final Map<String, int> serviceQuantities;
  final Function(String serviceId, int newQuantity) onQuantityUpdate;
  final VoidCallback onProceedToCheckout;
  final DateTime? selectedDate;
  final String? selectedServiceTime;
  final Function(DateTime) onDateSelected;
  final Function(String) onTimeSelected;
  final TextEditingController dateController;
  final double transportFee;
  final GetBookedSlotViewModel bookedSlotViewModel;

  const CartDialogWidget({
    Key? key,
    required this.categories,
    required this.serviceQuantities,
    required this.onQuantityUpdate,
    required this.onProceedToCheckout,
    required this.selectedDate,
    required this.selectedServiceTime,
    required this.onDateSelected,
    required this.onTimeSelected,
    required this.dateController,
    required this.transportFee,
    required this.bookedSlotViewModel,
  }) : super(key: key);

  @override
  State<CartDialogWidget> createState() => _CartDialogWidgetState();
}

class _CartDialogWidgetState extends State<CartDialogWidget> {
  late Map<String, int> _localServiceQuantities;
  List<BookedSlotDatum> _cachedSlots = [];

  @override
  void initState() {
    super.initState();
    _localServiceQuantities = Map.from(widget.serviceQuantities);
  }

  List<Map<String, dynamic>> _getCartItems() {
    List<Map<String, dynamic>> cartItems = [];
    widget.categories.forEach((category) {
      category.items?.forEach((service) {
        int qty = _localServiceQuantities[service.id ?? ''] ?? 0;
        if (qty > 0) {
          cartItems.add({'service': service, 'quantity': qty});
        }
      });
    });
    return cartItems;
  }

  double _calculateSubtotal() {
    double subtotal = 0;
    final cartItems = _getCartItems();
    for (var item in cartItems) {
      Item service = item['service'];
      int qty = _localServiceQuantities[service.id ?? ''] ?? 0;
      if (qty > 0) {
        double price = service.salePrice?.toDouble() ?? service.originalPrice?.toDouble() ?? 0;
        subtotal += price * qty;
      }
    }
    return subtotal;
  }

  double _calculateOriginalTotal() {
    double originalTotal = 0;
    final cartItems = _getCartItems();
    for (var item in cartItems) {
      Item service = item['service'];
      int qty = _localServiceQuantities[service.id ?? ''] ?? 0;
      if (qty > 0) {
        originalTotal += (service.originalPrice?.toDouble() ?? 0) * qty;
      }
    }
    return originalTotal;
  }

  void _handleQuantityUpdate(String serviceId, int newQuantity) {
    setState(() {
      _localServiceQuantities[serviceId] = newQuantity;
    });
    widget.onQuantityUpdate(serviceId, newQuantity);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final cartItems = _getCartItems();

    double subtotal = _calculateSubtotal();
    double transport = widget.transportFee;
    double total = subtotal + transport;
    double originalTotal = _calculateOriginalTotal();
    double saved = originalTotal - subtotal;

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
            _buildHeader(context, cartItems, subtotal, originalTotal, saved, screenWidth),
            _buildCartItemsList(context, cartItems, screenWidth),
            _buildPriceSummary(context, subtotal, transport, saved, total, originalTotal, screenWidth),
            _buildDateTimeSelection(context, screenWidth),
            _buildCheckoutButton(context, subtotal, screenWidth),
          ],
        ),
      ),
    );
  }

  // ─── Header ────────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context, List<Map<String, dynamic>> cartItems, double subtotal, double originalTotal, double saved, double screenWidth) {
    return DynamicCartHeader(itemCount: cartItems.length, totalPrice: subtotal, originalPrice: originalTotal, savedAmount: saved, onClose: () => Navigator.pop(context));
  }

  // ─── Cart Items List ────────────────────────────────────────────────────────

  Widget _buildCartItemsList(BuildContext context, List<Map<String, dynamic>> cartItems, double screenWidth) {
    return DynamicCartServicesList(cartItems: cartItems, serviceQuantities: _localServiceQuantities, onQuantityChanged: _handleQuantityUpdate);
  }

  // ─── Price Summary ──────────────────────────────────────────────────────────

  Widget _buildPriceSummary(BuildContext context, double subtotal, double transport, double saved, double total, double originalTotal, double screenWidth) {
    return Container(
      width: screenWidth * 0.87,
      padding: EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.border(context), width: 1)),
      ),
      child: Column(
        children: [
          // Subtotal row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Subtotal', style: AppTextStyles.textSize14(context)),
              Row(
                children: [
                  Text('৳${AmountFormatter.format(subtotal)}',style: AppTextStyles.textSize14(context, weight: FontWeight.w600)),
                  if (saved > 0) ...[
                    SizedBox(width: 8),
                    Text(
                      '৳${AmountFormatter.format(originalTotal)}',
                      style: AppTextStyles.textSize12(context, color: AppColors.subtitle(context)).copyWith(decoration: TextDecoration.lineThrough),
                    ),
                  ],
                ],
              ),
            ],
          ),
          SizedBox(height: 8),

          // Transport row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Transport', style: AppTextStyles.textSize14(context)),
              Text('৳${AmountFormatter.format(transport)}', style: AppTextStyles.textSize14(context, weight: FontWeight.w600)),
            ],
          ),
          SizedBox(height: 8),

          // Total row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total', style: AppTextStyles.textSize14(context, weight: FontWeight.w600)),
              Text('৳${AmountFormatter.format(total)}', style: AppTextStyles.textSize14(context, weight: FontWeight.w700)),
            ],
          ),

          // Savings row
          if (saved > 0) ...[
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'You Saved BDT ${AmountFormatter.format(saved)} in This Order!',
                  style: AppTextStyles.textSize12(context, color: Colors.red, weight: FontWeight.w400).copyWith(decoration: TextDecoration.underline, decorationColor: Colors.red),
                ),
                Text(
                  '৳${AmountFormatter.format(originalTotal)}',
                  style: AppTextStyles.textSize12(context, color: Colors.red).copyWith(decoration: TextDecoration.lineThrough, decorationColor: Colors.red),
                ),
              ],
            ),
          ],

          SizedBox(height: 10),
          // Divider(color: AppColors.border(context)),
        ],
      ),
    );
  }

  // ─── Date & Time Selection ──────────────────────────────────────────────────

  Widget _buildDateTimeSelection(BuildContext context, double screenWidth) {
    return Container(
      width: screenWidth * 0.87,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomDatePickerFormField(
            title: 'Booking Date',
            controller: widget.dateController,
            onDateSelected: widget.onDateSelected,
            titleTextStyle: AppTextStyles.textSize16(context, weight: FontWeight.w600),
            inputTextStyle: AppTextStyles.textSize14(context, weight: FontWeight.w400),
            hintTextStyle: AppTextStyles.textSize14(context, weight: FontWeight.w400, color: AppColors.subtitle(context)),
          ),
          SizedboxSpaccing.height015(context),
          Text('Select Time Slot', style: AppTextStyles.textSize16(context, weight: FontWeight.w600)),
          SizedboxSpaccing.height012(context),
          _buildTimeSlots(context),
        ],
      ),
    );
  }

  // Widget _buildTimeSlots(BuildContext context) {
  //   return AnimatedBuilder(
  //     animation: widget.bookedSlotViewModel,
  //     builder: (context, _) {
  //       final List<BookedSlotDatum> slots = widget.bookedSlotViewModel.getBookedSlotData.data?.data ?? [];
  //
  //       if (slots.isEmpty) {
  //         return Padding(
  //           padding: EdgeInsets.symmetric(vertical: 8),
  //           child: Text('No time slots available', style: AppTextStyles.textSize14(context, color: AppColors.subtitle(context))),
  //         );
  //       }
  //
  //       // Build rows of 2 buttons
  //       return Column(
  //         children: [
  //           for (int i = 0; i < slots.length; i += 2)
  //             Padding(
  //               padding: EdgeInsets.only(bottom: 10),
  //               child: Row(
  //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                 children: [
  //                   _serviceTimeButton(context, slots[i]),
  //                   if (i + 1 < slots.length) _serviceTimeButton(context, slots[i + 1]) else Expanded(child: SizedBox()),
  //                 ],
  //               ),
  //             ),
  //         ],
  //       );
  //     },
  //   );
  // }
  Widget _buildTimeSlots(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.bookedSlotViewModel,
      builder: (context, _) {
        final List<BookedSlotDatum> slots = widget.bookedSlotViewModel.getBookedSlotData.data?.data ?? [];

        // Update cache only when we have new data
        if (slots.isNotEmpty) {
          _cachedSlots = slots;
        }

        // Use cached slots if current is empty (during loading)
        final displaySlots = slots.isEmpty ? _cachedSlots : slots;

        // Only show "No time slots available" if we have no cached data and API completed with empty
        if (displaySlots.isEmpty && widget.bookedSlotViewModel.getBookedSlotData.status == Status.COMPLETED) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'No time slots available',
              style: AppTextStyles.textSize14(context, color: AppColors.subtitle(context)),
            ),
          );
        }

        // If still no slots at all (initial state), show nothing
        if (displaySlots.isEmpty) {
          return SizedBox.shrink();
        }

        // Build rows of 2 buttons
        return Column(
          children: [
            for (int i = 0; i < displaySlots.length; i += 2)
              Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _serviceTimeButton(context, displaySlots[i]),
                    if (i + 1 < displaySlots.length)
                      _serviceTimeButton(context, displaySlots[i + 1])
                    else
                      Expanded(child: SizedBox()),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
  Widget _serviceTimeButton(BuildContext context, BookedSlotDatum slot) {
    final String time = slot.time ?? '';
    final bool isBooked = slot.isBooked ?? false;
    final bool isSelected = widget.selectedServiceTime == time;

    return GestureDetector(
      onTap: isBooked ? null : () => widget.onTimeSelected(time),
      child: Container(
        height: 40,
        width: 150,
        decoration: BoxDecoration(
          color: isBooked
              ? AppColors.darkRedColor.withOpacity(0.05)
              : isSelected
              ? AppColors.button(context)
              : AppColors.containerBackground(context),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isBooked
                ? AppColors.darkRedColor.withOpacity(0.2)
                : isSelected
                ? AppColors.button(context)
                : AppColors.border(context),
            width: 1,
          ),
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                _formatTo12Hour(time),
                style: AppTextStyles.textSize16(
                  context,
                  weight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isBooked
                      ? AppColors.subtitle(context)
                      : isSelected
                      ? AppColors.whiteColor
                      : AppColors.subtitle(context),
                ),
              ),
              if (isBooked) ...[
                SizedBox(width: 10),
                Text(
                  'Booked',
                  style: AppTextStyles.textSize10(context, weight: FontWeight.w600, color: AppColors.darkRedColor),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
  // ─── Checkout Button ────────────────────────────────────────────────────────

  Widget _buildCheckoutButton(BuildContext context, double subtotal, double screenWidth) {
    return Padding(
      padding: EdgeInsets.all(15),
      child: GestureDetector(
        onTap: () {
          // Minimum order guard
          if (subtotal < 600) {
            Utils.flushBarExclamatoryMessage(title: "Warning", subtitle: " Minimum order amount is BDT 600 to proceed!", context: context);
            return;
          }

          final checkoutVM = Provider.of<CheckoutBeautySalonViewModel>(context, listen: false);

          // Date & time validation
          String? validationError = checkoutVM.validateCartForm(selectedDate: checkoutVM.selectedDate, serviceTime: checkoutVM.selectedServiceTime);

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
              Text(
                'Proceed to Checkout',
                style: AppTextStyles.textSize16(context, weight: FontWeight.w600, color: Colors.white),
              ),
              SizedboxSpaccing.width02(context),
              Icon(FontAwesomeIcons.arrowRight, color: AppColors.whiteColor, size: 12),
            ],
          ),
        ),
      ),
    );
  }
}

/// Converts "15:00", "9:30", "13:45" → "3:00 PM", "9:30 AM", "1:45 PM"
String _formatTo12Hour(String time) {
  if (time.isEmpty) return time;
  try {
    final parts = time.split(':');
    int hour = int.parse(parts[0]);
    final String minute = parts.length > 1 ? parts[1] : '00';
    final String period = hour >= 12 ? 'PM' : 'AM';
    if (hour == 0)
      hour = 12; // midnight → 12 AM
    else if (hour > 12)
      hour -= 12; // 13–23  → 1–11 PM
    return '$hour:$minute $period';
  } catch (_) {
    return time; // fallback: show original if parsing fails
  }
}
