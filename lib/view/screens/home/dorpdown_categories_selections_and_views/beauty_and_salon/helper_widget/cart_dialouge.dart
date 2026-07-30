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
  List<Item> _addOnItems = [];

  @override
  void initState() {
    super.initState();
    _localServiceQuantities = Map.from(widget.serviceQuantities);
    _initAddOns();
  }

  void _initAddOns() {
    final allAvailable = <Item>[];
    for (final cat in widget.categories) {
      for (final item in (cat.items ?? [])) {
        if ((_localServiceQuantities[item.id ?? ''] ?? 0) == 0) {
          allAvailable.add(item);
        }
      }
    }
    allAvailable.shuffle();
    _addOnItems = allAvailable.take(3).toList();
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
    for (final cat in widget.categories) {
      for (final item in (cat.items ?? [])) {
        int qty = _localServiceQuantities[item.id ?? ''] ?? 0;
        if (qty > 0) {
          double price = item.salePrice?.toDouble() ?? item.originalPrice?.toDouble() ?? 0;
          subtotal += price * qty;
        }
      }
    }
    return subtotal;
  }

  double _calculateOriginalTotal() {
    double originalTotal = 0;
    for (final cat in widget.categories) {
      for (final item in (cat.items ?? [])) {
        int qty = _localServiceQuantities[item.id ?? ''] ?? 0;
        if (qty > 0) {
          originalTotal += (item.originalPrice?.toDouble() ?? 0) * qty;
        }
      }
    }
    return originalTotal;
  }

  void _handleQuantityUpdate(String serviceId, int newQuantity) {
    setState(() {
      _localServiceQuantities[serviceId] = newQuantity;
      if (newQuantity > 0) {
        _addOnItems.removeWhere((item) => item.id == serviceId);
      }
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
            Flexible(
              fit: FlexFit.loose,
              child: SingleChildScrollView(
                child: Container(
                  width: screenWidth * 0.87,
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ...cartItems.map((item) => _buildCartItem(context, item)).toList(),
                      if (_addOnItems.isNotEmpty) _buildAddOns(context, screenWidth),
                    ],
                  ),
                ),
              ),
            ),
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

  // ─── Cart Item (inline) ─────────────────────────────────────────────────────

  Widget _buildCartItem(BuildContext context, Map<String, dynamic> item) {
    Item service = item['service'];
    final serviceId = service.id ?? '';
    int qty = _localServiceQuantities[serviceId] ?? 0;
    if (qty == 0) return SizedBox.shrink();

    double salePrice = service.salePrice?.toDouble() ?? service.originalPrice?.toDouble() ?? 0;
    double origPrice = service.originalPrice?.toDouble() ?? salePrice;
    bool hasDiscount = origPrice > salePrice && salePrice > 0;

    return Container(
      padding: EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(width: 1, color: AppColors.border(context))),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(service.name ?? '', style: AppTextStyles.textSize14(context, weight: FontWeight.w400)),
                SizedBox(height: 4),
                Row(
                  children: [
                    Text('৳${AmountFormatter.format(salePrice)}', style: AppTextStyles.textSize14(context, weight: FontWeight.w400)),
                    if (hasDiscount) ...[
                      SizedBox(width: 8),
                      Text('৳${AmountFormatter.format(origPrice)}',
                          style: AppTextStyles.textSize12(context, color: AppColors.subtitle(context)).copyWith(decoration: TextDecoration.lineThrough)),
                    ],
                  ],
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.border(context)),
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => _handleQuantityUpdate(serviceId, qty - 1),
                  child: Container(width: 25, height: 25, color: Colors.transparent, child: Icon(FontAwesomeIcons.minus, size: 14)),
                ),
                Container(width: 30, child: Center(child: Text('$qty', style: AppTextStyles.textSize14(context, weight: FontWeight.w500)))),
                GestureDetector(
                  onTap: () => _handleQuantityUpdate(serviceId, qty + 1),
                  child: Container(width: 25, height: 25, color: Colors.transparent, child: Icon(FontAwesomeIcons.plus, size: 14)),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 4),
        Text('Add-ons', style: AppTextStyles.textSize16(context, weight: FontWeight.w600)),
        const SizedBox(height: 8),
        ..._addOnItems.map((item) {
          final itemId = item.id ?? '';
          final qty = _localServiceQuantities[itemId] ?? 0;
          final salePrice = item.salePrice?.toDouble() ?? item.originalPrice?.toDouble() ?? 0;
          final basePrice = item.originalPrice?.toDouble() ?? 0;
          final hasDiscount = basePrice > salePrice && salePrice > 0;

          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.name ?? '', style: AppTextStyles.textSize14(context, weight: FontWeight.w500)),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text('৳${salePrice.toStringAsFixed(0)}',
                              style: AppTextStyles.textSize12(context, weight: FontWeight.w600, color: AppColors.button(context))),
                          if (hasDiscount) ...[
                            const SizedBox(width: 6),
                            Text('৳${basePrice.toStringAsFixed(0)}',
                                style: AppTextStyles.textSize12(context, color: AppColors.subtitle(context)).copyWith(decoration: TextDecoration.lineThrough)),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                if (qty == 0)
                  GestureDetector(
                    onTap: () => _handleQuantityUpdate(itemId, 1),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                      decoration: BoxDecoration(color: AppColors.button(context), borderRadius: BorderRadius.circular(100)),
                      child: Text('+ Add', style: AppTextStyles.textSize12(context, weight: FontWeight.w600, color: AppColors.whiteColor)),
                    ),
                  )
                else
                  Row(
                    children: [
                      _addOnQtyBtn(context, Icons.remove, () => _handleQuantityUpdate(itemId, qty - 1)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text('$qty', style: AppTextStyles.textSize14(context, weight: FontWeight.w700)),
                      ),
                      _addOnQtyBtn(context, Icons.add, () => _handleQuantityUpdate(itemId, qty + 1)),
                    ],
                  ),
              ],
            ),
          );
        }).toList(),
        Divider(height: 1, color: AppColors.border(context)),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _addOnQtyBtn(BuildContext context, IconData icon, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppColors.border(context))),
          child: Icon(icon, size: 14),
        ),
      );

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Subtotal', style: AppTextStyles.textSize14(context)),
              Row(
                children: [
                  Text('৳${AmountFormatter.format(subtotal)}', style: AppTextStyles.textSize14(context, weight: FontWeight.w600)),
                  if (saved > 0) ...[
                    SizedBox(width: 8),
                    Text('৳${AmountFormatter.format(originalTotal)}',
                        style: AppTextStyles.textSize12(context, color: AppColors.subtitle(context)).copyWith(decoration: TextDecoration.lineThrough)),
                  ],
                ],
              ),
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
              Text('Total', style: AppTextStyles.textSize14(context, weight: FontWeight.w600)),
              Text('৳${AmountFormatter.format(total)}', style: AppTextStyles.textSize14(context, weight: FontWeight.w700)),
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

  Widget _buildTimeSlots(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.bookedSlotViewModel,
      builder: (context, _) {
        final List<BookedSlotDatum> slots = widget.bookedSlotViewModel.getBookedSlotData.data?.data ?? [];

        if (slots.isNotEmpty) {
          _cachedSlots = slots;
        }

        final displaySlots = slots.isEmpty ? _cachedSlots : slots;

        if (displaySlots.isEmpty && widget.bookedSlotViewModel.getBookedSlotData.status == Status.COMPLETED) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text('No time slots available', style: AppTextStyles.textSize14(context, color: AppColors.subtitle(context))),
          );
        }

        if (displaySlots.isEmpty) {
          return SizedBox.shrink();
        }

        return Column(
          children: [
            for (int i = 0; i < displaySlots.length; i += 2)
              Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Expanded(child: _serviceTimeButton(context, displaySlots[i])),
                    SizedBox(width: 10),
                    Expanded(child: i + 1 < displaySlots.length ? _serviceTimeButton(context, displaySlots[i + 1]) : SizedBox()),
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
    final bool isBooked = slot.isBookedSlot ?? false;
    final bool isSelected = widget.selectedServiceTime == time;

    return GestureDetector(
      onTap: isBooked ? null : () => widget.onTimeSelected(time),
      child: Container(
        constraints: const BoxConstraints(minHeight: 40),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isBooked ? AppColors.darkRedColor.withOpacity(0.1) : isSelected ? AppColors.button(context) : AppColors.fieldColor(context),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isBooked ? AppColors.darkRedColor.withOpacity(0.2) : isSelected ? AppColors.button(context) : AppColors.border(context),
            width: 1,
          ),
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _formatTo12Hour(time),
                style: AppTextStyles.textSize13(
                  context,
                  weight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isBooked ? AppColors.subtitle(context) : isSelected ? AppColors.whiteColor : AppColors.subtitle(context),
                ),
              ),
              if (isBooked) ...[
                SizedBox(width: 4),
                Text('Booked', style: AppTextStyles.textSize10(context, weight: FontWeight.w600, color: AppColors.darkRedColor)),
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
          if (subtotal < 600) {
            Utils.flushBarExclamatoryMessage(title: "Warning", subtitle: " Minimum order amount is BDT 600 to proceed!", context: context);
            return;
          }

          final checkoutVM = Provider.of<CheckoutBeautySalonViewModel>(context, listen: false);

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

/// Converts "15:00", "9:30", "13:45" → "3:00 PM", "9:30 AM", "1:45 PM"
String _formatTo12Hour(String time) {
  if (time.isEmpty) return time;
  try {
    final parts = time.split(':');
    int hour = int.parse(parts[0]);
    final String minute = parts.length > 1 ? parts[1] : '00';
    final String period = hour >= 12 ? 'PM' : 'AM';
    if (hour == 0)
      hour = 12;
    else if (hour > 12) hour -= 12;
    return '$hour:$minute $period';
  } catch (_) {
    return time;
  }
}
