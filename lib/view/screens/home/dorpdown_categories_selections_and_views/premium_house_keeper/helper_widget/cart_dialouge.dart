import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/sizedbox_spaccing.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:dinmajur_customer/configs/utils/utils.dart';
import 'package:dinmajur_customer/model/home_models/dropdown_categories_selection_models/premium_house_keeper_model/getall_premium_house_keeper_task_model.dart';
import 'package:flutter/material.dart';

class CartDialog extends StatefulWidget {
  final List<Datum> services;
  final Map<String, int> serviceQuantities;
  final Map<String, Set<String>> selectedTaskItems;
  final String selectedFrequency;
  final String selectedDate;
  final String selectedTime;
  final Function(String serviceId, int newQuantity) onQuantityChanged;
  final VoidCallback onProceedToCheckout;

  const CartDialog({
    Key? key,
    required this.services,
    required this.serviceQuantities,
    required this.selectedTaskItems,
    required this.selectedFrequency,
    required this.selectedDate,
    required this.selectedTime,
    required this.onQuantityChanged,
    required this.onProceedToCheckout,
  }) : super(key: key);

  @override
  State<CartDialog> createState() => _CartDialogState();
}

class _CartDialogState extends State<CartDialog> {
  List<Map<String, dynamic>> _prepareCartItems() {
    List<Map<String, dynamic>> cartItems = [];

    for (var service in widget.services) {
      int qty = widget.serviceQuantities[service.id ?? ''] ?? 0;
      if (qty > 0) {
        cartItems.add({
          'service': service,
          'quantity': qty,
          'selectedItems': widget.selectedTaskItems[service.id ?? ''] ??
              service.houseKeeperTaskItems?.map((item) => item.id ?? '').toSet() ?? {}
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
      int qty = widget.serviceQuantities[service.id ?? ''] ?? 0;

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
      int qty = widget.serviceQuantities[service.id ?? ''] ?? 0;

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

  int _getTotalItems() {
    return widget.serviceQuantities.entries.where((entry) => entry.value > 0).length;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final cartItems = _prepareCartItems();

    double subtotal = _calculateSubtotal();
    double transport = 80.0;
    double total = subtotal + transport;
    double originalTotal = _calculateOriginalTotal() + transport;
    double saved = originalTotal - total;

    return Dialog(
      backgroundColor: AppColors.containerBackground(context),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      insetPadding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.02,
        vertical: screenHeight * 0.01,
      ),
      child: Container(
        width: screenWidth,
        constraints: BoxConstraints(maxHeight: screenHeight * 0.8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(context, cartItems, total, originalTotal, saved),
            _buildCartItemsList(context, cartItems),
            _buildPriceBreakdown(context, subtotal, transport, total, saved, originalTotal),
            _buildProceedButton(context, total),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, List<Map<String, dynamic>> cartItems,
      double total, double originalTotal, double saved) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border(context), width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('CART', style: AppTextStyles.textSize20(context, weight: FontWeight.w700)),
              SizedboxSpaccing.height005(context),
              Text(
                '${cartItems.length} service${cartItems.length > 1 ? 's' : ''}',
                style: AppTextStyles.textSize14(context, color: AppColors.subtitle(context)),
              ),
            ],
          ),
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Total ৳${total.toStringAsFixed(2)}',
                    style: AppTextStyles.textSize18(context, weight: FontWeight.w600),
                  ),
                  SizedboxSpaccing.height005(context),
                  if (saved > 0)
                    Text(
                      '৳${originalTotal.toStringAsFixed(2)}',
                      style: AppTextStyles.textSize12(
                        context,
                        color: AppColors.textPrimary(context),
                      ).copyWith(decoration: TextDecoration.lineThrough),
                    ),
                ],
              ),
              SizedboxSpaccing.width03(context),
              SizedboxSpaccing.width03(context),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.button(context).withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.close, size: 20, color: AppColors.textPrimary(context)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCartItemsList(BuildContext context, List<Map<String, dynamic>> cartItems) {
    return Flexible(
      child: ListView.separated(
        shrinkWrap: true,
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        itemCount: cartItems.length,
        separatorBuilder: (context, index) => SizedBox(height: 10),
        itemBuilder: (context, index) {
          final item = cartItems[index];
          Datum service = item['service'];
          int qty = widget.serviceQuantities[service.id ?? ''] ?? 0;

          if (qty == 0) return SizedBox.shrink();

          Set<String> selectedItems = item['selectedItems'];

          // Calculate price for this service
          double price = 0;
          double originalPrice = 0;

          for (var taskItem in service.houseKeeperTaskItems ?? []) {
            if (selectedItems.contains(taskItem.id ?? '')) {
              originalPrice += taskItem.price?.toDouble() ?? 0;
            }
          }

          price = originalPrice;
          if (service.discountType != null && service.discountValue != null && price > 0) {
            if (service.discountType == 'PERCENTAGE') {
              price = price - (price * service.discountValue! / 100);
            } else if (service.discountType == 'FLAT') {
              price = price - service.discountValue!.toDouble();
            }
          }

          return Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border(context)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        service.name ?? '',
                        style: AppTextStyles.textSize14(context, weight: FontWeight.w500),
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            '৳${price.toStringAsFixed(2)}',
                            style: AppTextStyles.textSize14(context, weight: FontWeight.w600),
                          ),
                          if (service.discountValue != null && originalPrice > 0) ...[
                            SizedBox(width: 8),
                            Text(
                              '৳${originalPrice.toStringAsFixed(2)}',
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
                _buildQuantityControls(context, service, qty),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildQuantityControls(BuildContext context, Datum service, int qty) {
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            if (qty > 1) {
              widget.onQuantityChanged(service.id ?? '', qty - 1);
            } else {
              widget.onQuantityChanged(service.id ?? '', 0);
            }

            setState(() {});

            if (_getTotalItems() == 0) {
              Navigator.pop(context);
            }
          },
          child: Container(
            width: 25,
            height: 25,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border(context)),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Icon(Icons.remove, size: 16),
          ),
        ),
        Container(
          width: 30,
          child: Center(
            child: Text(
              qty.toString(),
              style: AppTextStyles.textSize16(context, weight: FontWeight.w600),
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            if (service.hasRoom == false) {
              Utils.flushBarExclamatoryMessage(
                title: "Can't Add More",
                subtitle: "Additional quantity isn't available for this service.",
                context: context,
              );
            } else {
              widget.onQuantityChanged(service.id ?? '', qty + 1);
              setState(() {});
            }
          },
          child: Container(
            width: 25,
            height: 25,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border(context)),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Icon(Icons.add, size: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildPriceBreakdown(BuildContext context, double subtotal, double transport,
      double total, double saved, double originalTotal) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.border(context), width: 1)),
      ),
      child: Column(
        children: [
          _buildPriceRow('Subtotal', subtotal, context),
          SizedBox(height: 8),
          _buildPriceRow('Transport', transport, context),
          SizedBox(height: 8),
          Divider(color: AppColors.border(context)),
          _buildPriceRow('Sub Total', total, context, isBold: true),
          if (saved > 0) ...[
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'You Saved BDT ${saved.toStringAsFixed(2)} in This Order!',
                  style: AppTextStyles.textSize12(
                    context,
                    color: Colors.red,
                    weight: FontWeight.w500,
                  ),
                ),
                Text(
                  '৳${originalTotal.toStringAsFixed(2)}',
                  style: AppTextStyles.textSize12(context, color: Colors.red)
                      .copyWith(decoration: TextDecoration.lineThrough),
                ),
              ],
            ),
          ],
          SizedBox(height: 10),
          Divider(color: AppColors.border(context)),
          _buildDetailRow('Service Type', widget.selectedFrequency, context),
          _buildDetailRow('Date', widget.selectedDate, context),
          _buildDetailRow('Morning', widget.selectedTime, context),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, double amount, BuildContext context, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.textSize14(
            context,
            weight: isBold ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
        Text(
          '৳${amount.toStringAsFixed(2)}',
          style: AppTextStyles.textSize14(
            context,
            weight: isBold ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.textSize14(context, color: AppColors.subtitle(context)),
          ),
          Text(
            value,
            style: AppTextStyles.textSize12(context, weight: FontWeight.w400),
          ),
        ],
      ),
    );
  }

  Widget _buildProceedButton(BuildContext context, double total) {
    return Container(
      padding: EdgeInsets.all(15),
      child: GestureDetector(
        onTap: () {
          if (total < 600) {
            Utils.flushBarExclamatoryMessage(
              title: "Warning",
              subtitle: " Minimum order amount is BDT 600 to proceed!",
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
          decoration: BoxDecoration(
            color: AppColors.button(context),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              'Proceed to Checkout →',
              style: AppTextStyles.textSize16(
                context,
                weight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
