import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/sizedbox_spaccing.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:dinmajur_customer/configs/utils/utils.dart';
import 'package:dinmajur_customer/model/home_models/dropdown_categories_selection_models/beauty_and_salon_model/getall_premium_home_beauty_salon_model.dart';
import 'package:flutter/material.dart';

class CartDialogWidget extends StatelessWidget {
  final List<Datum> categories;
  final Map<String, int> serviceQuantities;
  final Function(String serviceId, int newQuantity) onQuantityUpdate;
  final VoidCallback onProceedToCheckout;

  const CartDialogWidget({
    Key? key,
    required this.categories,
    required this.serviceQuantities,
    required this.onQuantityUpdate,
    required this.onProceedToCheckout,
  }) : super(key: key);

  List<Map<String, dynamic>> _getCartItems() {
    List<Map<String, dynamic>> cartItems = [];
    categories.forEach((category) {
      category.items?.forEach((service) {
        int qty = serviceQuantities[service.id ?? ''] ?? 0;
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
      int qty = serviceQuantities[service.id ?? ''] ?? 0;
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
      int qty = serviceQuantities[service.id ?? ''] ?? 0;
      if (qty > 0) {
        originalTotal += (service.originalPrice?.toDouble() ?? 0) * qty;
      }
    }
    return originalTotal;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final cartItems = _getCartItems();

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
            _buildPriceSummary(context, subtotal, transport, saved, total),
            _buildCheckoutButton(context, total, screenWidth),
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
                      style: AppTextStyles.textSize12(context, color: AppColors.textPrimary(context))
                          .copyWith(decoration: TextDecoration.lineThrough),
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
          Item service = item['service'];
          int qty = serviceQuantities[service.id ?? ''] ?? 0;

          if (qty == 0) return SizedBox.shrink();

          double price = service.salePrice?.toDouble() ?? service.originalPrice?.toDouble() ?? 0;
          double originalPrice = service.originalPrice?.toDouble() ?? 0;

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
                          if (service.discountValue != null && originalPrice > price) ...[
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

  Widget _buildQuantityControls(BuildContext context, Item service, int qty) {
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            if (qty > 1) {
              onQuantityUpdate(service.id ?? '', qty - 1);
            } else {
              onQuantityUpdate(service.id ?? '', 0);
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
          onTap: () => onQuantityUpdate(service.id ?? '', qty + 1),
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

  Widget _buildPriceSummary(BuildContext context, double subtotal,
      double transport, double saved, double total) {
    return Container(
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.border(context), width: 1)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Subtotal', style: AppTextStyles.textSize14(context)),
              Text(
                '৳${subtotal.toStringAsFixed(2)}',
                style: AppTextStyles.textSize14(context, weight: FontWeight.w600),
              ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Transport Fee', style: AppTextStyles.textSize14(context)),
              Text(
                '৳${transport.toStringAsFixed(2)}',
                style: AppTextStyles.textSize14(context, weight: FontWeight.w600),
              ),
            ],
          ),
          if (saved > 0) ...[
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Saved', style: AppTextStyles.textSize14(context, color: Colors.green)),
                Text(
                  '- ৳${saved.toStringAsFixed(2)}',
                  style: AppTextStyles.textSize14(
                    context,
                    weight: FontWeight.w600,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ],
          Divider(height: 20, thickness: 1),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Amount',
                style: AppTextStyles.textSize16(context, weight: FontWeight.w600),
              ),
              Text(
                '৳${total.toStringAsFixed(2)}',
                style: AppTextStyles.textSize18(
                  context,
                  weight: FontWeight.w700,
                  color: AppColors.button(context),
                ),
              ),
            ],
          ),
        ],
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
          Navigator.pop(context);
          onProceedToCheckout();
        },
        child: Container(
          width: screenWidth,
          height: 50,
          decoration: BoxDecoration(
            color: AppColors.button(context),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              'Proceed to Checkout',
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