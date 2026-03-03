import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/sizedbox_spaccing.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:dinmajur_customer/configs/utils/utils.dart';
import 'package:dinmajur_customer/model/home_models/dropdown_categories_selection_models/premium_house_keeper_model/getall_premium_house_keeper_task_model.dart';
import 'package:dinmajur_customer/view/screens/home/helper_widgets/cart_coponents/cart_header_components.dart';
import 'package:dinmajur_customer/view/screens/home/helper_widgets/cart_coponents/cart_servicelist_component.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CartDialog extends StatefulWidget {
  final List<Datum> services;
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
  // Local copy to trigger UI updates
  late Map<String, int> _localServiceQuantities;

  @override
  void initState() {
    super.initState();
    _localServiceQuantities = Map.from(widget.serviceQuantities);
  }

  List<Map<String, dynamic>> _prepareCartItems() {
    List<Map<String, dynamic>> cartItems = [];

    for (var service in widget.services) {
      int qty = _localServiceQuantities[service.id ?? ''] ?? 0;
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

  int _getTotalItems() {
    return _localServiceQuantities.entries.where((entry) => entry.value > 0).length;
  }

  void _handleQuantityChanged(String serviceId, int newQuantity) {
    setState(() {
      _localServiceQuantities[serviceId] = newQuantity;
    });
    widget.onQuantityChanged(serviceId, newQuantity);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final cartItems = _prepareCartItems();

    double subtotal = _calculateSubtotal();
    double transport =widget.transportFee;
    double total = subtotal + transport;
    double originalTotal = _calculateOriginalTotal();
    double saved = originalTotal - subtotal;

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
            _buildHeader(context, cartItems, subtotal, originalTotal, saved, screenWidth),
            _buildCartItemsList(context, cartItems, screenWidth),
            _buildPriceBreakdown(context, subtotal, transport, total, saved, originalTotal, screenWidth),
            _buildProceedButton(context, subtotal),
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
    return DynamicCartServicesList(
      cartItems: cartItems,
      serviceQuantities: _localServiceQuantities,
      onQuantityChanged: _handleQuantityChanged,
      enableQuantityLimit: widget.restrictQuantityForNoRoomNoHourServices,
      autoCloseOnEmpty: true,
    );
  }

  Widget _buildPriceBreakdown(BuildContext context, double subtotal, double transport,
      double total, double saved, double originalTotal,
      double screenWidth
      ) {

    String timePeriod = '';
    String timeRange = '';

    if (widget.selectedTime.isNotEmpty) {
      // Split by opening parenthesis
      final parts = widget.selectedTime.split('(');
      if (parts.length == 2) {
        timePeriod = parts[0].trim(); // e.g., "MORNING"
        timeRange = parts[1].replaceAll(')', '').trim(); // e.g., "8am-11am"
      }
    }
    return Container(
      width: screenWidth * 0.87,
      padding: EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.border(context), width: 1)),
      ),
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
                  'You Saved BDT ${saved.toStringAsFixed(2)} in This Order!',
                  style: AppTextStyles.textSize12(
                    context,
                    color: Colors.red,
                    weight: FontWeight.w400,
                  ).copyWith(
                    decoration: TextDecoration.underline,
                    decorationColor: Colors.red,
                  ),
                ),
                Text(
                  '৳${originalTotal.toStringAsFixed(2)}',
                  style: AppTextStyles.textSize12(context, color: Colors.red)
                      .copyWith(decoration: TextDecoration.lineThrough, decorationColor: Colors.red),
                ),
              ],
            ),
          ],
          SizedBox(height: 10),
          Divider(color: AppColors.border(context)),
          _buildDetailRow('Service Type', widget.selectedFrequency, context),
          SizedBox(height: 4),
          _buildDetailRow('Date', widget.selectedDate, context),
          SizedBox(height: 4),
          _buildDetailRow(timePeriod, timeRange, context),        ],
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
            weight: isBold ? FontWeight.w700 : FontWeight.w400,
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
            style: AppTextStyles.textSize14(context, weight: FontWeight.w400),
          ),
        ],
      ),
    );
  }

  Widget _buildProceedButton(BuildContext context, double subtotal) {
    final double minOrder = widget.minimumOrderAmount?.toDouble() ?? 300.0;

    return Container(
      padding: EdgeInsets.all(15),
      child: GestureDetector(
        onTap: () {
          print("-------------------------------$minOrder");
          if (subtotal < minOrder) {
            print(subtotal);
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
              Icon(FontAwesomeIcons.arrowRight, color: AppColors.whiteColor, size: 12,)
            ],
          ),
        ),
      ),
    );
  }
}
///House Keeper
// Widget _buildCartItemsList(BuildContext context, List<Map<String, dynamic>> cartItems, double screenWidth) {
//   return Flexible(
//     child: Container(
//       width: screenWidth*0.87,
//       child: ListView.separated(
//         shrinkWrap: true,
//         padding: EdgeInsets.symmetric(vertical: 10),
//         itemCount: cartItems.length,
//         separatorBuilder: (context, index) => SizedBox(height: 10),
//         itemBuilder: (context, index) {
//           final item = cartItems[index];
//           Datum service = item['service'];
//           int qty = widget.serviceQuantities[service.id ?? ''] ?? 0;
//
//           if (qty == 0) return SizedBox.shrink();
//
//           Set<String> selectedItems = item['selectedItems'];
//
//           // Calculate price for this service
//           double price = 0;
//           double originalPrice = 0;
//
//           for (var taskItem in service.houseKeeperTaskItems ?? []) {
//             if (selectedItems.contains(taskItem.id ?? '')) {
//               originalPrice += taskItem.price?.toDouble() ?? 0;
//             }
//           }
//
//           price = originalPrice;
//           if (service.discountType != null && service.discountValue != null && price > 0) {
//             if (service.discountType == 'PERCENTAGE') {
//               price = price - (price * service.discountValue! / 100);
//             } else if (service.discountType == 'FLAT') {
//               price = price - service.discountValue!.toDouble();
//             }
//           }
//
//           return Container(
//             padding: EdgeInsets.only(bottom: 10),
//             decoration: BoxDecoration(
//               border: Border(
//                 bottom: BorderSide(
//                   width: 1,
//                     color: AppColors.border(context)
//                 )
//               ),
//               // borderRadius: BorderRadius.circular(12),
//             ),
//             child: Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         service.name ?? '',
//                         style: AppTextStyles.textSize14(context, weight: FontWeight.w400),
//                       ),
//                       SizedBox(height: 4),
//                       Row(
//                         children: [
//                           Text(
//                             '৳${price.toStringAsFixed(2)}',
//                             style: AppTextStyles.textSize14(context, weight: FontWeight.w400),
//                           ),
//                           if (service.discountValue != null && originalPrice > 0) ...[
//                             SizedBox(width: 8),
//                             Text(
//                               '৳${originalPrice.toStringAsFixed(2)}',
//                               style: AppTextStyles.textSize12(
//                                 context,
//                                 color: AppColors.subtitle(context),
//                               ).copyWith(decoration: TextDecoration.lineThrough),
//                             ),
//                           ],
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//                 _buildQuantityControls(context, service, qty),
//               ],
//             ),
//           );
//         },
//       ),
//     ),
//   );
// }
//
// Widget _buildQuantityControls(BuildContext context, Datum service, int qty) {
//   return Container(
//     decoration: BoxDecoration(
//       borderRadius: BorderRadius.circular(6),
//       border: Border.all(width: 1,
//       color: AppColors.border(context))
//     ),
//     child: Row(
//       children: [
//         GestureDetector(
//           onTap: () {
//             if (qty > 1) {
//               widget.onQuantityChanged(service.id ?? '', qty - 1);
//             } else {
//               widget.onQuantityChanged(service.id ?? '', 0);
//             }
//
//             setState(() {});
//
//             if (_getTotalItems() == 0) {
//               Navigator.pop(context);
//             }
//           },
//           child: Container(
//             width: 25,
//             height: 25,
//             // decoration: BoxDecoration(
//             //   border: Border.all(color: AppColors.border(context)),
//             //   borderRadius: BorderRadius.circular(4),
//             // ),
//             child: Icon(FontAwesomeIcons.minus, size: 14),
//           ),
//         ),
//         Container(
//           width: 30,
//           child: Center(
//             child: Text(
//               qty.toString(),
//               style: AppTextStyles.textSize14(context, weight: FontWeight.w500),
//             ),
//           ),
//         ),
//         GestureDetector(
//           onTap: () {
//             if (service.hasRoom == false) {
//               Utils.flushBarExclamatoryMessage(
//                 title: "Can't Add More",
//                 subtitle: "Additional quantity isn't available for this service.",
//                 context: context,
//               );
//             } else {
//               widget.onQuantityChanged(service.id ?? '', qty + 1);
//               setState(() {});
//             }
//           },
//           child: Container(
//             width: 25,
//             height: 25,
//             // decoration: BoxDecoration(
//             //   border: Border.all(color: AppColors.border(context)),
//             //   borderRadius: BorderRadius.circular(4),
//             // ),
//             child: Icon(FontAwesomeIcons.plus, size: 14),
//           ),
//         ),
//       ],
//     ),
//   );
// }
