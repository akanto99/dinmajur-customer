import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/sizedbox_spaccing.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:dinmajur_customer/configs/utils/utils.dart';
import 'package:dinmajur_customer/configs/widgets/datepicker_with_formfield.dart';
import 'package:dinmajur_customer/model/home_models/dropdown_categories_selection_models/beauty_and_salon_model/getall_premium_home_beauty_salon_model.dart';
import 'package:dinmajur_customer/view/screens/home/dorpdown_categories_selections_and_views/beauty_and_salon/notifier/checkout_notifier.dart';
import 'package:dinmajur_customer/view/screens/home/helper_widgets/cart_coponents/cart_header_components.dart';
import 'package:dinmajur_customer/view/screens/home/helper_widgets/cart_coponents/cart_servicelist_component.dart';
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
  }) : super(key: key);

  @override
  State<CartDialogWidget> createState() => _CartDialogWidgetState();
}

class _CartDialogWidgetState extends State<CartDialogWidget> {
  late Map<String, int> _localServiceQuantities;

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
    double transport = 80.0;
    double total = subtotal + transport;
    double originalTotal = _calculateOriginalTotal();
    double saved = originalTotal - subtotal; // Fixed: Don't include transport in savings

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
            _buildPriceSummary(context, subtotal, transport, saved, total, originalTotal, screenWidth),
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
    return DynamicCartServicesList(
      cartItems: cartItems,
      serviceQuantities: _localServiceQuantities,
      onQuantityChanged: _handleQuantityUpdate,
    );
  }

  Widget _buildPriceSummary(BuildContext context, double subtotal,
      double transport, double saved, double total,
      double originalTotal,
      double screenWidth
      ) {
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
                  Text(
                    '৳${subtotal.toStringAsFixed(2)}',
                    style: AppTextStyles.textSize14(context, weight: FontWeight.w600),
                  ),
                  if (saved > 0) ...[
                    SizedBox(width: 8),
                    Text(
                      '৳${originalTotal.toStringAsFixed(2)}',
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
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Transport', style: AppTextStyles.textSize14(context)),
              Text(
                '৳${transport.toStringAsFixed(2)}',
                style: AppTextStyles.textSize14(context, weight: FontWeight.w600),
              ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total', style: AppTextStyles.textSize14(context, weight: FontWeight.w600)),
              Text(
                '৳${total.toStringAsFixed(2)}',
                style: AppTextStyles.textSize14(context, weight: FontWeight.w700),
              ),
            ],
          ),
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
        ],
      ),
    );
  }

  Widget _buildDateTimeSelection(BuildContext context, double screenWidth) {
    final serviceTimeSlots = ['09:00 am', '12:00 pm', '03:00 pm', '06:00 pm'];

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
            hintTextStyle: AppTextStyles.textSize14(
              context,
              weight: FontWeight.w400,
              color: AppColors.subtitle(context),
            ),
          ),
          SizedboxSpaccing.height015(context),
          Text('Select Time Slot',
              style: AppTextStyles.textSize16(context, weight: FontWeight.w600)),
          SizedboxSpaccing.height012(context),
          Column(
            children: [
              for (int i = 0; i < serviceTimeSlots.length; i += 2)
                Padding(
                  padding: EdgeInsets.only(bottom: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _serviceTimeButton(context, serviceTimeSlots[i]),
                      if (i + 1 < serviceTimeSlots.length) ...[
                        _serviceTimeButton(context, serviceTimeSlots[i + 1]),
                      ] else
                        Expanded(child: SizedBox()),
                    ],
                  ),
                ),
            ],
          )
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
        width: 140,
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
              color: isSelected
                  ? AppColors.whiteColor
                  : AppColors.subtitle(context),
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
          if (total < 600) {
            Utils.flushBarExclamatoryMessage(
              title: "Warning",
              subtitle: " Minimum order amount is BDT 600 to proceed!",
              context: context,
            );
            return;
          }
          final checkoutVM = Provider.of<CheckoutBeautySalonViewModel>(context, listen: false);

          String? validationError = checkoutVM.validateCartForm(
            selectedDate: checkoutVM.selectedDate,
            serviceTime: checkoutVM.selectedServiceTime,
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
              Icon(FontAwesomeIcons.arrowRight, color: AppColors.whiteColor, size: 12,)
            ],
          ),
        ),
      ),
    );
  }
}

///Beauty Salon
// Widget _buildCartItemsList(BuildContext context, List<Map<String, dynamic>> cartItems,  double screenWidth) {
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
//           Item service = item['service'];
//           int qty = serviceQuantities[service.id ?? ''] ?? 0;
//
//           if (qty == 0) return SizedBox.shrink();
//
//           double price = service.salePrice?.toDouble() ?? service.originalPrice?.toDouble() ?? 0;
//           double originalPrice = service.originalPrice?.toDouble() ?? 0;
//
//           return Container(
//             padding: EdgeInsets.only(bottom: 10),
//             decoration: BoxDecoration(
//               border: Border(
//                   bottom: BorderSide(
//                       width: 1,
//                       color: AppColors.border(context)
//                   )
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
//                           if (service.discountValue != null && originalPrice > price) ...[
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
// Widget _buildQuantityControls(BuildContext context, Item service, int qty) {
//   return Container(
//     decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(6),
//         border: Border.all(width: 1,
//             color: AppColors.border(context))
//     ),
//     child: Row(
//       children: [
//         GestureDetector(
//           onTap: () {
//             if (qty > 1) {
//               onQuantityUpdate(service.id ?? '', qty - 1);
//             } else {
//               onQuantityUpdate(service.id ?? '', 0);
//             }
//           },
//           child: Container(
//             width: 25,
//             height: 25,
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
//           onTap: () => onQuantityUpdate(service.id ?? '', qty + 1),
//           child: Container(
//             width: 25,
//             height: 25,
//                       child: Icon(FontAwesomeIcons.plus, size: 14),
//           ),
//         ),
//       ],
//     ),
//   );
// }