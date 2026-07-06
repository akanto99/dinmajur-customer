import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/sizedbox_spaccing.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:dinmajur_customer/configs/utils/amount_formatter/amount_formatter.dart';
import 'package:dinmajur_customer/configs/utils/utils.dart';
import 'package:dinmajur_customer/model/home_models/dropdown_categories_selection_models/premium_house_keeper_model/getall_premium_house_keeper_task_model.dart';
import 'package:dinmajur_customer/view/screens/home/helper_widgets/cart_coponents/cart_header_components.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CartDialog extends StatefulWidget {
  final List<Datum> services;
  final List<Datum> allServices;
  final Map<String, int> serviceQuantities;
  final Map<String, Set<String>> selectedTaskItems;
  final String selectedFrequency;
  final String selectedDate;
  final String selectedTime;
  final Function(String serviceId, int newQuantity) onQuantityChanged;
  final bool restrictQuantityForNoRoomNoHourServices;
  final VoidCallback onProceedToCheckout;
  final double transportFee;
  final int? minimumOrderAmount;

  const CartDialog({
    Key? key,
    required this.services,
    this.allServices = const [],
    required this.serviceQuantities,
    required this.selectedTaskItems,
    required this.selectedFrequency,
    required this.selectedDate,
    required this.selectedTime,
    required this.onQuantityChanged,
    this.restrictQuantityForNoRoomNoHourServices = true,
    required this.onProceedToCheckout,
    required this.transportFee,
    required this.minimumOrderAmount,
  }) : super(key: key);

  @override
  State<CartDialog> createState() => _CartDialogState();
}

class _CartDialogState extends State<CartDialog> {
  late Map<String, int> _localServiceQuantities;
  List<Datum> _addOnItems = [];

  @override
  void initState() {
    super.initState();
    _localServiceQuantities = Map.from(widget.serviceQuantities);
    _initAddOns();
  }

  void _initAddOns() {
    final source = widget.allServices.isNotEmpty ? widget.allServices : widget.services;
    final available = source.where((s) => (_localServiceQuantities[s.id ?? ''] ?? 0) == 0).toList();
    available.shuffle();
    _addOnItems = available.take(3).toList();
  }

  List<Map<String, dynamic>> _prepareCartItems() {
    final source = widget.allServices.isNotEmpty ? widget.allServices : widget.services;
    List<Map<String, dynamic>> cartItems = [];
    for (var service in source) {
      int qty = _localServiceQuantities[service.id ?? ''] ?? 0;
      if (qty > 0) {
        cartItems.add({
          'service': service,
          'quantity': qty,
          'selectedItems': widget.selectedTaskItems[service.id ?? ''] ?? service.houseKeeperTaskItems?.map((item) => item.id ?? '').toSet() ?? {}
        });
      }
    }
    return cartItems;
  }

  double _calculateSubtotal() {
    double subtotal = 0;
    final cartItems = _prepareCartItems();
    for (var item in cartItems) {
      Datum service = item['service'];
      int qty = _localServiceQuantities[service.id ?? ''] ?? 0;
      if (qty > 0) {
        Set<String> selectedItems = item['selectedItems'];
        double price = 0;
        for (var taskItem in service.houseKeeperTaskItems ?? []) {
          if (selectedItems.contains(taskItem.id ?? '')) {
            price += taskItem.price?.toDouble() ?? 0;
          }
        }
        if (service.discountType != null && service.discountValue != null && price > 0) {
          if (service.discountType == 'PERCENTAGE') {
            price = price - (price * service.discountValue! / 100);
          } else if (service.discountType == 'FLAT') {
            price = price - service.discountValue!.toDouble();
          }
        }
        subtotal += price * qty;
      }
    }
    return subtotal;
  }

  double _calculateOriginalTotal() {
    double originalTotal = 0;
    final cartItems = _prepareCartItems();
    for (var item in cartItems) {
      Datum service = item['service'];
      int qty = _localServiceQuantities[service.id ?? ''] ?? 0;
      if (qty > 0) {
        Set<String> selectedItems = item['selectedItems'];
        double price = 0;
        for (var taskItem in service.houseKeeperTaskItems ?? []) {
          if (selectedItems.contains(taskItem.id ?? '')) {
            price += taskItem.price?.toDouble() ?? 0;
          }
        }
        originalTotal += price * qty;
      }
    }
    return originalTotal;
  }

  double _getServicePrice(Datum service) {
    double total = 0;
    for (var taskItem in service.houseKeeperTaskItems ?? []) {
      total += taskItem.price?.toDouble() ?? 0;
    }
    return total;
  }

  void _handleQuantityChanged(String serviceId, int newQuantity) {
    setState(() {
      _localServiceQuantities[serviceId] = newQuantity;
      if (newQuantity > 0) {
        _addOnItems.removeWhere((s) => s.id == serviceId);
      }
    });
    widget.onQuantityChanged(serviceId, newQuantity);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final cartItems = _prepareCartItems();

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
        constraints: BoxConstraints(maxHeight: screenHeight * 0.8),
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
            _buildPriceBreakdown(context, subtotal, transport, total, saved, originalTotal, screenWidth),
            _buildProceedButton(context, subtotal),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, List<Map<String, dynamic>> cartItems, double subtotal, double originalTotal, double saved, double screenWidth) {
    return DynamicCartHeader(itemCount: cartItems.length, totalPrice: subtotal, originalPrice: originalTotal, savedAmount: saved, onClose: () => Navigator.pop(context));
  }

  // ─── Cart Item (inline) ─────────────────────────────────────────────────────

  Widget _buildCartItem(BuildContext context, Map<String, dynamic> item) {
    Datum service = item['service'];
    final serviceId = service.id ?? '';
    int qty = _localServiceQuantities[serviceId] ?? 0;
    if (qty == 0) return SizedBox.shrink();

    Set<String> selectedItems = item['selectedItems'];
    double origPrice = 0;
    for (var taskItem in service.houseKeeperTaskItems ?? []) {
      if (selectedItems.contains(taskItem.id ?? '')) {
        origPrice += taskItem.price?.toDouble() ?? 0;
      }
    }
    double salePrice = origPrice;
    if (service.discountType != null && service.discountValue != null && origPrice > 0) {
      if (service.discountType == 'PERCENTAGE') {
        salePrice = origPrice - (origPrice * service.discountValue! / 100);
      } else if (service.discountType == 'FLAT') {
        salePrice = origPrice - service.discountValue!.toDouble();
      }
    }
    bool hasDiscount = origPrice > salePrice && salePrice > 0;
    bool canHaveMultiple = (service.hasRoom == true) || (service.hasHour == true);

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
                  onTap: () => _handleQuantityChanged(serviceId, qty - 1),
                  child: Container(width: 25, height: 25, color: Colors.transparent, child: Icon(FontAwesomeIcons.minus, size: 14)),
                ),
                Container(width: 30, child: Center(child: Text('$qty', style: AppTextStyles.textSize14(context, weight: FontWeight.w500)))),
                GestureDetector(
                  onTap: () {
                    if (widget.restrictQuantityForNoRoomNoHourServices && !canHaveMultiple) {
                      Utils.flushBarExclamatoryMessage(title: "Can't Add More", subtitle: "Additional quantity is not available for this service.", context: context);
                      return;
                    }
                    _handleQuantityChanged(serviceId, qty + 1);
                  },
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
        ..._addOnItems.map((service) {
          final serviceId = service.id ?? '';
          final qty = _localServiceQuantities[serviceId] ?? 0;
          final price = _getServicePrice(service);

          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(service.name ?? '', style: AppTextStyles.textSize14(context, weight: FontWeight.w500)),
                      if (price > 0) ...[
                        const SizedBox(height: 2),
                        Text('৳${price.toStringAsFixed(0)}',
                            style: AppTextStyles.textSize12(context, weight: FontWeight.w600, color: AppColors.button(context))),
                      ],
                    ],
                  ),
                ),
                if (qty == 0)
                  GestureDetector(
                    onTap: () => _handleQuantityChanged(serviceId, 1),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                      decoration: BoxDecoration(color: AppColors.button(context), borderRadius: BorderRadius.circular(100)),
                      child: Text('+ Add', style: AppTextStyles.textSize12(context, weight: FontWeight.w600, color: AppColors.whiteColor)),
                    ),
                  )
                else
                  Row(
                    children: [
                      _addOnQtyBtn(context, Icons.remove, () => _handleQuantityChanged(serviceId, qty - 1)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text('$qty', style: AppTextStyles.textSize14(context, weight: FontWeight.w700)),
                      ),
                      _addOnQtyBtn(context, Icons.add, () => _handleQuantityChanged(serviceId, qty + 1)),
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

  // ─── Price Breakdown ────────────────────────────────────────────────────────

  Widget _buildPriceBreakdown(BuildContext context, double subtotal, double transport, double total, double saved, double originalTotal, double screenWidth) {
    String timePeriod = '';
    String timeRange = '';
    if (widget.selectedTime.isNotEmpty) {
      final parts = widget.selectedTime.split('(');
      if (parts.length == 2) {
        timePeriod = parts[0].trim();
        timeRange = parts[1].replaceAll(')', '').trim();
      }
    }
    return Container(
      width: screenWidth * 0.87,
      padding: EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(border: Border(top: BorderSide(color: AppColors.border(context), width: 1))),
      child: Column(
        children: [
          _buildPriceRow('Subtotal', subtotal, context),
          SizedBox(height: 8),
          _buildPriceRow('Transport', transport, context),
          SizedBox(height: 8),
          _buildPriceRow('Total', total, context, isBold: true),
          if (saved > 0) ...[
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'You Saved BDT ${AmountFormatter.format(saved)} in This Order!',
                  style: AppTextStyles.textSize12(context, color: Colors.red, weight: FontWeight.w400)
                      .copyWith(decoration: TextDecoration.underline, decorationColor: Colors.red),
                ),
                Text('৳${AmountFormatter.format(originalTotal)}',
                    style: AppTextStyles.textSize12(context, color: Colors.red).copyWith(decoration: TextDecoration.lineThrough, decorationColor: Colors.red)),
              ],
            ),
          ],
          SizedBox(height: 10),
          Divider(color: AppColors.border(context)),
          _buildDetailRow('Service Type', widget.selectedFrequency, context),
          SizedBox(height: 4),
          _buildDetailRow('Date', widget.selectedDate, context),
          SizedBox(height: 4),
          _buildDetailRow(timePeriod, timeRange, context),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, double amount, BuildContext context, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.textSize14(context, weight: isBold ? FontWeight.w600 : FontWeight.w400)),
        Text('৳${AmountFormatter.format(amount)}', style: AppTextStyles.textSize14(context, weight: isBold ? FontWeight.w700 : FontWeight.w400)),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.textSize14(context, color: AppColors.subtitle(context))),
        Text(value, style: AppTextStyles.textSize14(context, weight: FontWeight.w400)),
      ],
    );
  }

  // ─── Proceed Button ─────────────────────────────────────────────────────────

  Widget _buildProceedButton(BuildContext context, double subtotal) {
    final double minOrder = widget.minimumOrderAmount?.toDouble() ?? 300.0;
    return Container(
      padding: EdgeInsets.all(15),
      child: GestureDetector(
        onTap: () {
          if (subtotal < minOrder) {
            Utils.flushBarExclamatoryMessage(
              title: "Warning",
              subtitle: "Minimum order amount is BDT ${minOrder.toStringAsFixed(0)} to proceed!",
              context: context,
            );
            return;
          }
          Navigator.pop(context);
          widget.onProceedToCheckout();
        },
        child: Container(
          width: double.infinity,
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
