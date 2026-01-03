import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:dinmajur_customer/configs/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// ==================== UNIVERSAL DYNAMIC CART SERVICES LIST ====================

class DynamicCartServicesList extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems;
  final Map<String, int> serviceQuantities;
  final Function(String serviceId, int quantity) onQuantityChanged;
  final VoidCallback? onCartEmpty;
  final double? width;
  final EdgeInsets? listPadding;
  final double? itemSpacing;
  final EdgeInsets? itemPadding;
  final TextStyle? serviceNameStyle;
  final TextStyle? priceStyle;
  final TextStyle? originalPriceStyle;
  final TextStyle? quantityStyle;
  final Color? borderColor;
  final double? borderWidth;
  final Color? quantityControlBorderColor;
  final double? quantityControlBorderRadius;
  final IconData? minusIcon;
  final IconData? plusIcon;
  final double? iconSize;
  final double? quantityControlWidth;
  final double? quantityControlHeight;
  final double? quantityDisplayWidth;
  final String? cannotAddMoreTitle;
  final String? cannotAddMoreMessage;
  final bool enableQuantityLimit; // For house keeper service check
  final bool autoCloseOnEmpty; // Auto close when cart becomes empty

  const DynamicCartServicesList({
    Key? key,
    required this.cartItems,
    required this.serviceQuantities,
    required this.onQuantityChanged,
    this.onCartEmpty,
    this.width,
    this.listPadding,
    this.itemSpacing,
    this.itemPadding,
    this.serviceNameStyle,
    this.priceStyle,
    this.originalPriceStyle,
    this.quantityStyle,
    this.borderColor,
    this.borderWidth,
    this.quantityControlBorderColor,
    this.quantityControlBorderRadius,
    this.minusIcon,
    this.plusIcon,
    this.iconSize,
    this.quantityControlWidth,
    this.quantityControlHeight,
    this.quantityDisplayWidth,
    this.cannotAddMoreTitle,
    this.cannotAddMoreMessage,
    this.enableQuantityLimit = false,
    this.autoCloseOnEmpty = false,
  }) : super(key: key);

  @override
  State<DynamicCartServicesList> createState() => _DynamicCartServicesListState();
}

class _DynamicCartServicesListState extends State<DynamicCartServicesList> {
  int _getTotalItems() {
    return widget.serviceQuantities.values.fold(0, (sum, qty) => sum + qty);
  }

  // Get service data dynamically (works for both Item and Datum types)
  Map<String, dynamic> _getServiceData(dynamic service) {
    String name = '';
    double price = 0;
    double originalPrice = 0;
    bool hasQuantityLimit = false;

    // Check if it's Beauty Salon service (Item type)
    if (service.runtimeType.toString().contains('Item')) {
      name = service.name ?? '';
      price = service.salePrice?.toDouble() ?? service.originalPrice?.toDouble() ?? 0;
      originalPrice = service.originalPrice?.toDouble() ?? 0;
      hasQuantityLimit = false;
    }
    // Check if it's House Keeper service (Datum type)
    else {
      name = service.name ?? '';
      originalPrice = 0;

      // Calculate price from selected items
      final cartItem = widget.cartItems.firstWhere(
            (item) => item['service'] == service,
        orElse: () => {'selectedItems': <String>{}},
      );

      Set<String> selectedItems = cartItem['selectedItems'] ?? <String>{};

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

      hasQuantityLimit = service.hasRoom == false;
    }

    return {
      'name': name,
      'price': price,
      'originalPrice': originalPrice,
      'hasQuantityLimit': hasQuantityLimit,
      'hasDiscount': originalPrice > price,
    };
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Flexible(
      child: Container(
        width: widget.width ?? screenWidth * 0.87,
        child: ListView.separated(
          shrinkWrap: true,
          padding: widget.listPadding ?? EdgeInsets.symmetric(vertical: 10),
          itemCount: widget.cartItems.length,
          separatorBuilder: (context, index) => SizedBox(height: widget.itemSpacing ?? 10),
          itemBuilder: (context, index) {
            final item = widget.cartItems[index];
            dynamic service = item['service'];
            String serviceId = service.id ?? '';
            int qty = widget.serviceQuantities[serviceId] ?? 0;

            if (qty == 0) return SizedBox.shrink();

            final serviceData = _getServiceData(service);

            return Container(
              padding: widget.itemPadding ?? EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    width: widget.borderWidth ?? 1,
                    color: widget.borderColor ?? AppColors.border(context),
                  ),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          serviceData['name'],
                          style: widget.serviceNameStyle ??
                              AppTextStyles.textSize14(context, weight: FontWeight.w400),
                        ),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              '৳${serviceData['price'].toStringAsFixed(2)}',
                              style: widget.priceStyle ??
                                  AppTextStyles.textSize14(context, weight: FontWeight.w400),
                            ),
                            if (serviceData['hasDiscount']) ...[
                              SizedBox(width: 8),
                              Text(
                                '৳${serviceData['originalPrice'].toStringAsFixed(2)}',
                                style: (widget.originalPriceStyle ??
                                    AppTextStyles.textSize12(
                                      context,
                                      color: AppColors.subtitle(context),
                                    ))
                                    .copyWith(decoration: TextDecoration.lineThrough),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  _buildQuantityControls(
                    context,
                    serviceId,
                    qty,
                    serviceData['hasQuantityLimit'],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildQuantityControls(
      BuildContext context,
      String serviceId,
      int qty,
      bool hasQuantityLimit,
      ) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(widget.quantityControlBorderRadius ?? 6),
        border: Border.all(
          width: widget.borderWidth ?? 1,
          color: widget.quantityControlBorderColor ?? AppColors.border(context),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              if (qty > 1) {
                widget.onQuantityChanged(serviceId, qty - 1);
              } else {
                widget.onQuantityChanged(serviceId, 0);
              }

              setState(() {});

              if (widget.autoCloseOnEmpty && _getTotalItems() == 0) {
                if (widget.onCartEmpty != null) {
                  widget.onCartEmpty!();
                } else {
                  Navigator.pop(context);
                }
              }
            },
            child: Container(
              width: widget.quantityControlWidth ?? 25,
              height: widget.quantityControlHeight ?? 25,
              color: Colors.transparent,
              child: Icon(
                widget.minusIcon ?? FontAwesomeIcons.minus,
                size: widget.iconSize ?? 14,
              ),
            ),
          ),
          Container(
            width: widget.quantityDisplayWidth ?? 30,
            child: Center(
              child: Text(
                qty.toString(),
                style: widget.quantityStyle ??
                    AppTextStyles.textSize14(context, weight: FontWeight.w500),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              if (widget.enableQuantityLimit && hasQuantityLimit) {
                Utils.flushBarExclamatoryMessage(
                  title: widget.cannotAddMoreTitle ?? "Can't Add More",
                  subtitle: widget.cannotAddMoreMessage ??
                      "Additional quantity isn't available for this service.",
                  context: context,
                );
              } else {
                widget.onQuantityChanged(serviceId, qty + 1);
                setState(() {});
              }
            },
            child: Container(
              width: widget.quantityControlWidth ?? 25,
              height: widget.quantityControlHeight ?? 25,
              color: Colors.transparent,
              child: Icon(
                widget.plusIcon ?? FontAwesomeIcons.plus,
                size: widget.iconSize ?? 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}