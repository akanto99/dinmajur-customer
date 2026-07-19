import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:dinmajur_customer/configs/utils/amount_formatter/amount_formatter.dart';
import 'package:dinmajur_customer/configs/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// UNIVERSAL DYNAMIC CART SERVICES LIST

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

  Map<String, dynamic> _getServiceData(dynamic service) {
    String name = 'Unknown';
    double price = 0.0;
    double originalPrice = 0.0;
    bool hasQuantityLimit = true;
    bool canHaveMultiple = false;

    if (service == null) {
      // fallback - safe default
      return {
        'name': name,
        'price': price,
        'originalPrice': originalPrice,
        'hasQuantityLimit': hasQuantityLimit,
        'hasDiscount': false,
        'canHaveMultiple': canHaveMultiple,
      };
    }

    // Beauty salon / generic Item branch
    if (service.runtimeType.toString().contains('Item')) {
      name = service.name ?? 'Unnamed Service';
      price = service.salePrice?.toDouble() ?? service.originalPrice?.toDouble() ?? 0.0;
      originalPrice = service.originalPrice?.toDouble() ?? price;
      canHaveMultiple = true;           // usually no limit for salon/products
      hasQuantityLimit = false;
    }
    // Housekeeper / Datum branch
    else {
      name = service.name ?? 'Unnamed Task';

      // Find matching cart item to get selected sub-items
      final cartItem = widget.cartItems.firstWhere(
            (item) => item['service']?.id == service.id,
        orElse: () => <String, dynamic>{'selectedItems': <String>{}},
      );

      final selectedItems = (cartItem['selectedItems'] as Set<String>?) ?? <String>{};

      originalPrice = 0.0;
      for (final taskItem in service.houseKeeperTaskItems ?? <dynamic>[]) {
        if (selectedItems.contains(taskItem.id ?? '')) {
          originalPrice += (taskItem.price as num?)?.toDouble() ?? 0.0;
        }
      }

      price = originalPrice;

      if (service.discountType != null &&
          service.discountValue != null &&
          price > 0) {
        if (service.discountType == 'PERCENTAGE') {
          price -= (price * (service.discountValue as num) / 100);
        } else if (service.discountType == 'FLAT') {
          price -= (service.discountValue as num).toDouble();
        }
      }

      canHaveMultiple = (service.hasRoom == true) || (service.hasHour == true);
      hasQuantityLimit = !canHaveMultiple;
    }

    return {
      'name': name,
      'price': price,
      'originalPrice': originalPrice,
      'hasQuantityLimit': hasQuantityLimit,
      'hasDiscount': originalPrice > price,
      'canHaveMultiple': canHaveMultiple,
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
                              '৳${AmountFormatter.format(serviceData['price'])}',
                              style: widget.priceStyle ??
                                  AppTextStyles.textSize14(context, weight: FontWeight.w400),
                            ),
                            if (serviceData['hasDiscount']) ...[
                              SizedBox(width: 8),
                              Text(
                                '৳${AmountFormatter.format(serviceData['originalPrice'])}',
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
                    serviceData['canHaveMultiple'] as bool? ?? false,
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
      bool canHaveMultiple,          // ← add this parameter
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
          // Minus button (unchanged)
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

          // Quantity display (unchanged)
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

          // Plus button – now uses the passed value
          GestureDetector(
            onTap: () {
              if (widget.enableQuantityLimit && !canHaveMultiple) {
                Utils.flushBarExclamatoryMessage(
                  title: widget.cannotAddMoreTitle ?? "Can't Add More",
                  subtitle: widget.cannotAddMoreMessage ??
                      "Additional quantity is not available for this service.",
                  context: context,
                );
                return;
              }

              widget.onQuantityChanged(serviceId, qty + 1);
              setState(() {});
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