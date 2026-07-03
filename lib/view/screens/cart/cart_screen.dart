import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:dinmajur_customer/provider/cart/global_cart_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBackground(context),
      appBar: AppBar(
        backgroundColor: AppColors.appBackground(context),
        elevation: 0,
        centerTitle: true,
        title: Text('My Cart', style: AppTextStyles.textSize18(context, weight: FontWeight.w600)),
      ),
      body: Consumer<GlobalCartProvider>(
        builder: (context, cart, _) {
          if (!cart.hasItems) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 80,
                    color: AppColors.subtitle(context).withOpacity(0.35),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Your cart is empty',
                    style: AppTextStyles.textSize18(context, weight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Browse services and add items\nto see them here',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.textSize14(context, color: AppColors.subtitle(context)),
                  ),
                ],
              ),
            );
          }

          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.containerBackground(context),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border(context)),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.shopping_cart, size: 40, color: AppColors.button(context)),
                        const SizedBox(height: 12),
                        Text(
                          cart.serviceName,
                          style: AppTextStyles.textSize16(context, weight: FontWeight.w600),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${cart.itemCount} item${cart.itemCount > 1 ? 's' : ''}',
                              style: AppTextStyles.textSize14(context, color: AppColors.subtitle(context)),
                            ),
                            Text(
                              '৳${cart.totalPrice.toStringAsFixed(0)}',
                              style: AppTextStyles.textSize20(context, weight: FontWeight.w700, color: AppColors.button(context)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  GestureDetector(
                    onTap: cart.onViewCart,
                    child: Container(
                      width: double.infinity,
                      height: 52,
                      decoration: BoxDecoration(
                        color: AppColors.button(context),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          'Proceed to Checkout',
                          style: AppTextStyles.textSize16(context, weight: FontWeight.w700, color: AppColors.whiteColor),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
