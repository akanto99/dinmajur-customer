import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/sizedbox_spaccing.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:dinmajur_customer/configs/utils/utils.dart';
import 'package:dinmajur_customer/configs/widgets/datepicker_with_formfield.dart';
import 'package:dinmajur_customer/data/response/status.dart';
import 'package:dinmajur_customer/model/home_models/all_service_models/services_view_getallcategories_model.dart';
import 'package:dinmajur_customer/view/screens/home/all_service/widget/dynamic_cart_servicelist_widget.dart';
import 'package:dinmajur_customer/view/screens/home/helper_widgets/cart_coponents/cart_header_components.dart';
import 'package:dinmajur_customer/view_model/homeview_model/all_service_view_models/get_slot_view_model.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../../model/home_models/all_service_models/get_timeslot_model.dart';

class ServicesCartDialogWidget extends StatefulWidget {
  final String? serviceId;
  final List<Category> categories;
  final Map<String, int> serviceQuantities;
  final Function(String taskId, int newQuantity) onQuantityUpdate;
  final VoidCallback onProceedToCheckout;
  final DateTime? selectedDate;
  final String? selectedServiceTime;
  final Function(String time, String slotId) onTimeSelected;
  final Function(DateTime) onDateSelected;
  final TextEditingController dateController;
  final double transportFee;
  final GetSlotViewModel slotViewModel;
    final int? minimumOrderAmount;


  const ServicesCartDialogWidget({
    Key? key,
    required this.serviceId,
    required this.categories,
    required this.serviceQuantities,
    required this.onQuantityUpdate,
    required this.onProceedToCheckout,
    required this.selectedDate,
    required this.selectedServiceTime,
    required this.onTimeSelected,
    required this.onDateSelected,
    required this.dateController,
    required this.transportFee,
    required this.slotViewModel,
            required this.minimumOrderAmount,

  }) : super(key: key);

  @override
  State<ServicesCartDialogWidget> createState() => _ServicesCartDialogWidgetState();
}

class _ServicesCartDialogWidgetState extends State<ServicesCartDialogWidget> {
  late Map<String, int> _localServiceQuantities;
  List<TimeSlot> _cachedSlots = [];

  @override
  void initState() {
    super.initState();
    _localServiceQuantities = Map.from(widget.serviceQuantities);
  }

  // ── Cart helpers ─────────────────────────────────────────────────────────

  List<Map<String, dynamic>> _getCartItems() {
    final List<Map<String, dynamic>> cartItems = [];
    for (final category in widget.categories) {
      for (final task in (category.tasks ?? [])) {
        final int qty = _localServiceQuantities[task.id ?? ''] ?? 0;
        if (qty > 0) cartItems.add({'task': task, 'quantity': qty});
      }
    }
    return cartItems;
  }

  double _calculateSubtotal() {
    double subtotal = 0;
    for (final item in _getCartItems()) {
      final Task task = item['task'];
      final int qty = _localServiceQuantities[task.id ?? ''] ?? 0;
      final double price = task.price?.salePrice?.toDouble() ?? task.price?.basePrice?.toDouble() ?? 0;
      subtotal += price * qty;
    }
    return subtotal;
  }

  double _calculateOriginalTotal() {
    double originalTotal = 0;
    for (final item in _getCartItems()) {
      final Task task = item['task'];
      final int qty = _localServiceQuantities[task.id ?? ''] ?? 0;
      originalTotal += (task.price?.basePrice?.toDouble() ?? 0) * qty;
    }
    return originalTotal;
  }

  void _handleQuantityUpdate(String taskId, int newQuantity) {
    setState(() => _localServiceQuantities[taskId] = newQuantity);
    widget.onQuantityUpdate(taskId, newQuantity);
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final cartItems = _getCartItems();

    final double subtotal = _calculateSubtotal();
    final double transport = widget.transportFee;
    final double total = subtotal + transport;
    final double originalTotal = _calculateOriginalTotal();
    final double saved = originalTotal - subtotal;

    return Dialog(
      backgroundColor: AppColors.containerBackground(context),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      insetPadding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02, vertical: screenHeight * 0.01),
      child: Container(
        width: screenWidth,
        constraints: BoxConstraints(maxHeight: screenHeight * 0.85),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildHeader(context, cartItems, subtotal, originalTotal, saved),
                    _buildCartItemsList(context, cartItems),
                    _buildPriceSummary(context, subtotal, transport, saved, total, originalTotal),
                    _buildDateTimeSelection(context, screenWidth),
                    SizedBox(height: 15),
                  ],
                ),
              ),
            ),

            _buildCheckoutButton(context, subtotal, screenWidth),
          ],
        ),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context, List<Map<String, dynamic>> cartItems, double subtotal, double originalTotal, double saved) {
    return DynamicCartHeader(itemCount: cartItems.length, totalPrice: subtotal, originalPrice: originalTotal, savedAmount: saved, onClose: () => Navigator.pop(context));
  }

  // ── Cart items ────────────────────────────────────────────────────────────

  Widget _buildCartItemsList(BuildContext context, List<Map<String, dynamic>> cartItems) {
    final adaptedItems = cartItems.map((item) {
      final Task task = item['task'];
      return {'service': _TaskAsItem(task), 'quantity': item['quantity']};
    }).toList();

    return DynamicCartServicelistWidget(cartItems: adaptedItems, serviceQuantities: _localServiceQuantities, onQuantityChanged: _handleQuantityUpdate);
  }

  // ── Price summary ─────────────────────────────────────────────────────────

  Widget _buildPriceSummary(BuildContext context, double subtotal, double transport, double saved, double total, double originalTotal) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.87,
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.border(context), width: 1)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Subtotal', style: AppTextStyles.textSize14(context)),
              Row(
                children: [
                  Text('৳${subtotal.toStringAsFixed(2)}', style: AppTextStyles.textSize14(context, weight: FontWeight.w600)),
                  if (saved > 0) ...[
                    const SizedBox(width: 8),
                    Text(
                      '৳${originalTotal.toStringAsFixed(2)}',
                      style: AppTextStyles.textSize12(context, color: AppColors.subtitle(context)).copyWith(decoration: TextDecoration.lineThrough),
                    ),
                  ],
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Transport', style: AppTextStyles.textSize14(context)),
              Text('৳${transport.toStringAsFixed(2)}', style: AppTextStyles.textSize14(context, weight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total', style: AppTextStyles.textSize14(context, weight: FontWeight.w600)),
              Text('৳${total.toStringAsFixed(2)}', style: AppTextStyles.textSize14(context, weight: FontWeight.w700)),
            ],
          ),
          if (saved > 0) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    'You Saved BDT ${saved.toStringAsFixed(2)} in This Order!',
                    style: AppTextStyles.textSize12(context, color: Colors.red, weight: FontWeight.w400).copyWith(decoration: TextDecoration.underline, decorationColor: Colors.red),
                  ),
                ),
                Text(
                  '৳${originalTotal.toStringAsFixed(2)}',
                  style: AppTextStyles.textSize12(context, color: Colors.red).copyWith(decoration: TextDecoration.lineThrough, decorationColor: Colors.red),
                ),
              ],
            ),
          ],
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  // ── Date & time selection ─────────────────────────────────────────────────

  Widget _buildDateTimeSelection(BuildContext context, double screenWidth) {
    return SizedBox(
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

  // ── Time slots ────────────────────────────────────────────────────────────

  Widget _buildTimeSlots(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.slotViewModel,
      builder: (context, _) {
        // ✅ Correct: read from GetTimeSlotModel -> timeSlots (List<TimeSlot>)
        final List<TimeSlot> slots = widget.slotViewModel.getSlotData.data?.timeSlots ?? [];

        if (slots.isNotEmpty) _cachedSlots = slots;
        final displaySlots = slots.isEmpty ? _cachedSlots : slots;

        if (displaySlots.isEmpty && widget.slotViewModel.getSlotData.status == Status.COMPLETED) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text('No time slots available', style: AppTextStyles.textSize14(context, color: AppColors.subtitle(context))),
          );
        }

        if (displaySlots.isEmpty) return const SizedBox.shrink();

        return Column(
          children: [
            for (int i = 0; i < displaySlots.length; i += 2)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _slotButton(context, displaySlots[i]),
                    if (i + 1 < displaySlots.length) _slotButton(context, displaySlots[i + 1]) else const Expanded(child: SizedBox()),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _slotButton(BuildContext context, TimeSlot slot) {
    // ✅ Correct fields: timeLabel for display, id for API, availability.isBooked for status
    final String time = slot.timeLabel ?? '';
    final String slotId = slot.id ?? '';
    final bool isBooked = slot.availability?.isBooked ?? false;
    final bool isSelected = widget.selectedServiceTime == time;

    return GestureDetector(
      onTap: isBooked ? null : () => widget.onTimeSelected(time, slotId),
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
                const SizedBox(width: 10),
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

  // ── Checkout button ───────────────────────────────────────────────────────
  Widget _buildCheckoutButton(BuildContext context, double subtotal, double screenWidth) {
    final double minOrder = widget.minimumOrderAmount?.toDouble() ?? 300.0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 15, left: 15, right: 15),
      child: GestureDetector(
        onTap: () {
          if (subtotal < minOrder) {
            Utils.flushBarExclamatoryMessage(title: "Warning", subtitle: "Minimum order amount is BDT ${minOrder.toStringAsFixed(0)} to proceed!", context: context);
            return;
          }

          if (widget.selectedDate == null) {
            Utils.flushBarErrorMessage("Please select a booking date", context);
            return;
          }

          if (widget.selectedServiceTime == null || widget.selectedServiceTime!.isEmpty) {
            Utils.flushBarErrorMessage("Please select a time slot", context);
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

// ── Helpers ───────────────────────────────────────────────────────────────────

String _formatTo12Hour(String time) {
  if (time.isEmpty) return time;
  try {
    final parts = time.split(':');
    int hour = int.parse(parts[0]);
    final String minute = parts.length > 1 ? parts[1] : '00';
    final String period = hour >= 12 ? 'PM' : 'AM';
    if (hour == 0)
      hour = 12;
    else if (hour > 12)
      hour -= 12;
    return '$hour:$minute $period';
  } catch (_) {
    return time;
  }
}

/// Adapter so DynamicCartServicesList can consume Task as if it were Item
class _TaskAsItem {
  final Task _task;
  _TaskAsItem(this._task);
  String? get id => _task.id;
  String? get name => _task.name;
  num? get salePrice => _task.price?.salePrice;
  num? get originalPrice => _task.price?.basePrice;
  dynamic get image => null;
}
