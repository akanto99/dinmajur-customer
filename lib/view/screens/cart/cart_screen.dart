import 'package:cached_network_image/cached_network_image.dart';
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
        automaticallyImplyLeading: false,
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

          return Column(
            children: [
              // ── Service header ──
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                color: AppColors.containerBackground(context),
                child: Row(
                  children: [
                    Icon(Icons.home_repair_service_outlined, size: 18, color: AppColors.button(context)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        cart.serviceName,
                        style: AppTextStyles.textSize14(context, weight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${cart.itemCount} item${cart.itemCount > 1 ? 's' : ''}',
                      style: AppTextStyles.textSize12(context, color: AppColors.subtitle(context)),
                    ),
                  ],
                ),
              ),
              Divider(height: 1, color: AppColors.border(context)),

              // ── Items list ──
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: cart.items.length,
                  separatorBuilder: (_, __) => Divider(height: 1, color: AppColors.border(context)),
                  itemBuilder: (context, index) {
                    final item = cart.items[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Thumbnail
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: item.imageUrl != null
                                ? CachedNetworkImage(
                                    imageUrl: item.imageUrl!,
                                    width: 56,
                                    height: 56,
                                    fit: BoxFit.cover,
                                    errorWidget: (_, __, ___) => _iconBox(context),
                                  )
                                : _iconBox(context),
                          ),
                          const SizedBox(width: 12),
                          // Name + unit price
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.name,
                                  style: AppTextStyles.textSize14(context, weight: FontWeight.w500),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '৳${item.unitPrice.toStringAsFixed(0)}  ×  ${item.quantity}',
                                  style: AppTextStyles.textSize12(context, color: AppColors.subtitle(context)),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Subtotal
                          Text(
                            '৳${item.subtotal.toStringAsFixed(0)}',
                            style: AppTextStyles.textSize14(context, weight: FontWeight.w700),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // ── Total + Checkout ──
              Container(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                decoration: BoxDecoration(
                  color: AppColors.containerBackground(context),
                  border: Border(top: BorderSide(color: AppColors.border(context))),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, -3))],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total', style: AppTextStyles.textSize16(context, weight: FontWeight.w600)),
                        Text(
                          '৳${cart.totalPrice.toStringAsFixed(0)}',
                          style: AppTextStyles.textSize20(context, weight: FontWeight.w700, color: AppColors.button(context)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
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
            ],
          );
        },
      ),
    );
  }

  Widget _iconBox(BuildContext context) => Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: AppColors.border(context),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(Icons.home_repair_service_outlined, size: 24, color: AppColors.subtitle(context)),
      );
}
