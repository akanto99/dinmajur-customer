import 'package:cached_network_image/cached_network_image.dart';
import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/components/header_appbar.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:dinmajur_customer/configs/utils/routes/routes_name.dart';
import 'package:dinmajur_customer/model/home_models/all_service_models/services_view_getallcategories_model.dart';
import 'package:dinmajur_customer/model/home_models/dropdown_categories_selection_models/beauty_and_salon_model/getall_premium_home_beauty_salon_model.dart' as beauty_model;
import 'package:dinmajur_customer/model/home_models/dropdown_categories_selection_models/family_event_cooking_model/getall_family_event_cooking_model.dart' as cooking_model;
import 'package:dinmajur_customer/model/home_models/dropdown_categories_selection_models/premium_house_keeper_model/getall_premium_house_keeper_task_model.dart' as hk_model;
import 'package:dinmajur_customer/provider/cart/global_cart_provider.dart';
import 'package:dinmajur_customer/view/screens/home/all_service/widget/services_cartdialouge_widget.dart';
import 'package:dinmajur_customer/view/screens/home/dorpdown_categories_selections_and_views/beauty_and_salon/helper_widget/cart_dialouge.dart' as beauty_cart;
import 'package:dinmajur_customer/view/screens/home/dorpdown_categories_selections_and_views/beauty_and_salon/notifier/checkout_notifier.dart';
import 'package:dinmajur_customer/view/screens/home/dorpdown_categories_selections_and_views/family_event_cooking/helper_widget/cooking_cart_dialouge.dart';
import 'package:dinmajur_customer/view/screens/home/dorpdown_categories_selections_and_views/family_event_cooking/notifier/cooking_checkout_notifier.dart';
import 'package:dinmajur_customer/view/screens/home/dorpdown_categories_selections_and_views/premium_house_keeper/helper_widget/cart_dialouge.dart' as hk_cart;
import 'package:dinmajur_customer/view_model/homeview_model/all_service_view_models/checkout_view_model.dart';
import 'package:dinmajur_customer/view_model/homeview_model/all_service_view_models/get_slot_view_model.dart';
import 'package:dinmajur_customer/view_model/homeview_model/dropdown_categories_selection_view_models/beauty_and_salon_view_model/get_bookedslot_view_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartScreen extends StatefulWidget {
  /// Called when the user taps the back arrow. CartScreen is presented as a
  /// permanent bottom-nav tab (not pushed via Navigator), so there is no
  /// route to pop back to — the parent must switch tabs instead.
  final VoidCallback? onBack;

  const CartScreen({Key? key, this.onBack}) : super(key: key);

  @override
  State<CartScreen> createState() => _CartScreenState();
}

/// Reconstructs a typed model list from checkout args that may either hold
/// the original in-memory objects (fresh session) or plain JSON maps
/// (restored from the persisted cart after an app restart).
List<T> _asTypedList<T>(dynamic raw, T Function(Map<String, dynamic>) fromJson) {
  return (raw as List? ?? [])
      .map((e) => e is T ? e : fromJson(Map<String, dynamic>.from(e as Map)))
      .toList();
}

/// Reconstructs a `Map<String, Set<String>>` from checkout args, tolerating
/// values stored as `Set` (fresh session) or `List` (restored from disk,
/// since JSON has no Set type).
Map<String, Set<String>> _asStringSetMap(dynamic raw) {
  final result = <String, Set<String>>{};
  if (raw is Map) {
    raw.forEach((k, v) {
      if (v is Iterable) result[k.toString()] = Set<String>.from(v.map((e) => e.toString()));
    });
  }
  return result;
}

class _CartScreenState extends State<CartScreen> {

  // ── Specialized checkout navigation (called from dialogs' onProceedToCheckout) ──

  void _navigateSpecialCheckout(String serviceId, Map<String, dynamic> args) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId') ?? '';
    if (!mounted) return;
    final cart = context.read<GlobalCartProvider>();
    final route = args['checkoutRoute'] as String;
    final result = await Navigator.pushNamed(context, route, arguments: {
      ...args,
      'userId': userId,
    });
    if (!mounted) return;
    final shouldClear = result == true || (result is Map<String, dynamic> && result['cleared'] == true);
    if (shouldClear) cart.clearService(serviceId);
  }

  // ── Beauty Salon cart dialog ──

  void _showBeautyCartDialog(String serviceId, Map<String, dynamic> args) {
    final cart = context.read<GlobalCartProvider>();
    final checkoutVM = Provider.of<CheckoutBeautySalonViewModel>(context, listen: false);
    final bookedSlotVM = Provider.of<GetBookedSlotViewModel>(context, listen: false);

    final categories = _asTypedList<beauty_model.Datum>(args['categories'], beauty_model.Datum.fromJson);
    var serviceQuantities = Map<String, int>.from(args['serviceQuantities'] as Map? ?? {});
    final transportFee = (args['transportFee'] as num?)?.toDouble() ?? 0.0;
    // Re-typed values must replace the raw (possibly JSON-shaped, if restored
    // from disk) ones so every downstream `...args` spread below stays typed.
    args = {...args, 'categories': categories};
    final svcName = cart.serviceCarts[serviceId]?.serviceName ?? '';

    showDialog(
      context: context,
      barrierColor: AppColors.showDialougeBackground(context),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          return beauty_cart.CartDialogWidget(
            categories: categories,
            serviceQuantities: serviceQuantities,
            onQuantityUpdate: (id, qty) {
              serviceQuantities[id] = qty;
              final updatedItems = <CartItem>[];
              for (final cat in categories) {
                for (final service in cat.items ?? []) {
                  final q = serviceQuantities[service.id ?? ''] ?? 0;
                  if (q > 0) {
                    final price = service.salePrice?.toDouble() ?? service.originalPrice?.toDouble() ?? 0;
                    updatedItems.add(CartItem(
                      id: service.id ?? '',
                      name: service.name ?? '',
                      quantity: q,
                      unitPrice: price,
                      imageUrl: service.image?.url,
                    ));
                  }
                }
              }
              if (updatedItems.isEmpty) {
                cart.clearService(serviceId);
                Navigator.pop(ctx);
              } else {
                cart.updateService(serviceId, serviceName: svcName, items: updatedItems, checkoutArgs: {
                  ...args,
                  'serviceQuantities': Map.of(serviceQuantities),
                });
                setDialogState(() {});
              }
            },
            onProceedToCheckout: () {
              _navigateSpecialCheckout(serviceId, {...args, 'serviceQuantities': Map.of(serviceQuantities)});
            },
            selectedDate: checkoutVM.selectedDate,
            selectedServiceTime: checkoutVM.selectedServiceTime,
            transportFee: transportFee,
            bookedSlotViewModel: bookedSlotVM,
            onDateSelected: (date) {
              checkoutVM.setSelectedDate(date);
              bookedSlotVM.fetchGetBookedSlotDataApi(date);
              setDialogState(() {});
            },
            onTimeSelected: (time) {
              checkoutVM.setServiceTime(time);
              setDialogState(() {});
            },
            dateController: TextEditingController(
              text: checkoutVM.selectedDate != null
                  ? DateFormat('MMMM dd, yyyy').format(checkoutVM.selectedDate!)
                  : '',
            ),
          );
        },
      ),
    );
  }

  // ── House Keeper cart dialog ──

  void _showHousekeeperCartDialog(String serviceId, Map<String, dynamic> args) {
    final cart = context.read<GlobalCartProvider>();

    final allServices = _asTypedList<hk_model.Datum>(args['allServices'], hk_model.Datum.fromJson);
    var serviceQuantities = Map<String, int>.from(args['serviceQuantities'] as Map? ?? {});

    final selectedTaskItems = _asStringSetMap(args['selectedTaskItems']);
    // Re-typed values must replace the raw (possibly JSON-shaped, if restored
    // from disk) ones so every downstream `...args` spread below stays typed.
    args = {...args, 'allServices': allServices, 'selectedTaskItems': selectedTaskItems};

    final selectedFrequency = (args['selectedFrequency'] as String?) ?? 'Daily';
    final selectedDate = (args['selectedDate'] as String?) ?? '';
    final selectedTime = (args['selectedTime'] as String?) ?? '';
    final transportFee = (args['transportFee'] as num?)?.toDouble() ?? 0.0;
    final svcName = cart.serviceCarts[serviceId]?.serviceName ?? '';

    showDialog(
      context: context,
      barrierColor: AppColors.showDialougeBackground(context),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          return hk_cart.CartDialog(
            services: allServices,
            serviceQuantities: serviceQuantities,
            selectedTaskItems: selectedTaskItems,
            selectedFrequency: selectedFrequency,
            selectedDate: selectedDate,
            selectedTime: selectedTime,
            transportFee: transportFee,
            minimumOrderAmount: null,
            restrictQuantityForNoRoomNoHourServices: true,
            onQuantityChanged: (id, qty) {
              if (qty == 0) {
                serviceQuantities.remove(id);
              } else {
                serviceQuantities[id] = qty;
              }
              final updatedItems = allServices
                  .where((s) => (serviceQuantities[s.id ?? ''] ?? 0) > 0)
                  .map((s) {
                final q = serviceQuantities[s.id ?? ''] ?? 0;
                final si = selectedTaskItems[s.id ?? ''] ??
                    s.houseKeeperTaskItems?.map((i) => i.id ?? '').toSet() ?? {};
                double price = 0;
                for (var ti in s.houseKeeperTaskItems ?? []) {
                  if (si.contains(ti.id ?? '')) price += ti.price?.toDouble() ?? 0;
                }
                if (s.discountType != null && s.discountValue != null && price > 0) {
                  if (s.discountType == 'PERCENTAGE') {
                    price -= price * s.discountValue! / 100;
                  } else if (s.discountType == 'FLAT') {
                    price -= s.discountValue!.toDouble();
                  }
                }
                return CartItem(id: s.id ?? '', name: s.name ?? '', quantity: q, unitPrice: price, imageUrl: s.image?.url);
              }).toList();
              if (updatedItems.isEmpty) {
                cart.clearService(serviceId);
                Navigator.pop(ctx);
              } else {
                cart.updateService(serviceId, serviceName: svcName, items: updatedItems, checkoutArgs: {
                  ...args,
                  'serviceQuantities': Map.of(serviceQuantities),
                });
                setDialogState(() {});
              }
            },
            onProceedToCheckout: () {
              _navigateSpecialCheckout(serviceId, {...args, 'serviceQuantities': Map.of(serviceQuantities)});
            },
          );
        },
      ),
    );
  }

  // ── Family Event Cooking cart dialog ──

  void _showCookingCartDialog(String serviceId, Map<String, dynamic> args) {
    final checkoutVM = Provider.of<CookingCheckoutViewModel>(context, listen: false);

    final categories = _asTypedList<cooking_model.Datum>(args['categories'], cooking_model.Datum.fromJson);
    final selectedPackages = Map<String, String?>.from(args['selectedPackages'] as Map? ?? {});

    final selectedManualItems = _asStringSetMap(args['selectedManualItems']);
    // Re-typed values must replace the raw (possibly JSON-shaped, if restored
    // from disk) ones so every downstream `...args` spread below stays typed.
    args = {...args, 'categories': categories, 'selectedManualItems': selectedManualItems};

    final activeCategoryId = args['activeCategoryId'] as String?;
    final selectedGuestRangeIndex = (args['selectedGuestRangeIndex'] as int?) ?? 0;
    final transportFee = (args['transportFee'] as num?)?.toDouble() ?? 0.0;

    showDialog(
      context: context,
      barrierColor: AppColors.showDialougeBackground(context),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          return FamilyEventCookingCartDialog(
            categories: categories,
            selectedPackages: selectedPackages,
            selectedManualItems: selectedManualItems,
            activeCategoryId: activeCategoryId,
            selectedGuestRangeIndex: selectedGuestRangeIndex,
            selectedDate: checkoutVM.selectedDate,
            selectedServiceTime: checkoutVM.selectedServiceTime,
            transportFee: transportFee,
            onDateSelected: (date) {
              checkoutVM.setSelectedDate(date);
              setDialogState(() {});
            },
            onTimeSelected: (time) {
              checkoutVM.setServiceTime(time);
              setDialogState(() {});
            },
            dateController: TextEditingController(
              text: checkoutVM.selectedDate != null
                  ? DateFormat('MMMM dd, yyyy').format(checkoutVM.selectedDate!)
                  : '',
            ),
            onProceedToCheckout: () {
              _navigateSpecialCheckout(serviceId, args);
            },
          );
        },
      ),
    );
  }

  // ── Main checkout dispatcher ──

  void _showCheckoutDialog(String serviceId) {
    final cart = context.read<GlobalCartProvider>();
    final rawArgs = cart.getCheckoutArgsForService(serviceId);
    if (rawArgs == null) return;
    var args = rawArgs;

    if (args.containsKey('checkoutRoute')) {
      final route = args['checkoutRoute'] as String?;
      if (route == RoutesName.beautyCheckoutScreen) {
        _showBeautyCartDialog(serviceId, args);
      } else if (route == RoutesName.checkoutHouseKeeperScreen) {
        _showHousekeeperCartDialog(serviceId, args);
      } else if (route == RoutesName.cookingCheckoutScreen) {
        _showCookingCartDialog(serviceId, args);
      } else {
        _navigateSpecialCheckout(serviceId, args);
      }
      return;
    }

    final categories = _asTypedList<Category>(args['categories'], Category.fromJson);
    // Re-typed value must replace the raw (possibly JSON-shaped, if restored
    // from disk) one so every downstream `...args` spread below stays typed.
    args = {...args, 'categories': categories};
    final serviceQuantities = Map<String, int>.from(args['serviceQuantities'] as Map? ?? {});
    final transportFee = (args['transportFee'] as num?)?.toDouble() ?? 0.0;
    final String svcId = (args['serviceId'] as String?) ?? serviceId;
    final String svcName = cart.serviceCarts[serviceId]?.serviceName ?? '';

    final checkoutVM = Provider.of<CheckoutAllServicesViewModel>(context, listen: false);
    final slotVM = Provider.of<GetSlotViewModel>(context, listen: false);

    // Reset stale date/time from any previous service dialog
    checkoutVM.reset();

    showDialog(
      context: context,
      barrierColor: AppColors.showDialougeBackground(context),
      builder: (dialogCtx) => StatefulBuilder(
        builder: (dialogCtx, setDialogState) {
          return ServicesCartDialogWidget(
            serviceId: svcId,
            categories: categories,
            serviceQuantities: serviceQuantities,
            transportFee: transportFee,
            slotViewModel: slotVM,
            minimumOrderAmount: null,
            selectedDate: checkoutVM.selectedDate,
            selectedServiceTime: checkoutVM.selectedServiceTime,
            dateController: TextEditingController(
              text: checkoutVM.selectedDate != null
                  ? DateFormat('MMMM dd, yyyy').format(checkoutVM.selectedDate!)
                  : '',
            ),
            onQuantityUpdate: (taskId, newQuantity) {
              if (newQuantity <= 0) {
                serviceQuantities.remove(taskId);
              } else {
                serviceQuantities[taskId] = newQuantity;
              }

              final updatedItems = <CartItem>[];
              double newTotal = 0;
              for (final cat in categories) {
                for (final task in (cat.tasks ?? [])) {
                  final qty = serviceQuantities[task.id ?? ''] ?? 0;
                  if (qty > 0) {
                    final price = task.price?.salePrice?.toDouble() ?? task.price?.basePrice?.toDouble() ?? 0;
                    final imageUrl = task.images != null && task.images!.isNotEmpty ? task.images!.first.url : null;
                    updatedItems.add(CartItem(id: task.id ?? '', name: task.name ?? '', quantity: qty, unitPrice: price, imageUrl: imageUrl));
                    newTotal += price * qty;
                  }
                }
              }

              if (updatedItems.isEmpty) {
                cart.clearService(serviceId);
                Navigator.pop(dialogCtx);
              } else {
                cart.updateService(
                  serviceId,
                  serviceName: svcName,
                  items: updatedItems,
                  checkoutArgs: {
                    ...args,
                    'serviceQuantities': Map.of(serviceQuantities),
                    'totalPrice': newTotal,
                  },
                );
                setDialogState(() {});
              }
            },
            onDateSelected: (DateTime date) {
              checkoutVM.setSelectedDate(date);
              slotVM.fetchGetSlotDataApi(date, svcId);
              setDialogState(() {});
            },
            onTimeSelected: (String time, String slotId) {
              checkoutVM.setServiceTime(time, slotId);
              setDialogState(() {});
            },
            onProceedToCheckout: () async {
              if (!mounted) return;
              final prefs = await SharedPreferences.getInstance();
              final userId = prefs.getString('userId') ?? '';
              if (!mounted) return;
              final result = await Navigator.pushNamed(
                context,
                RoutesName.serviceCheckoutScreen,
                arguments: {
                  ...args,
                  'serviceQuantities': Map.of(serviceQuantities),
                  'userId': userId,
                  'onAddressUpdate': (String _) {},
                },
              );
              if (result is Map<String, dynamic> && result['cleared'] == true) {
                if (mounted) cart.clearService(serviceId);
              }
            },
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.containerBackground(context),
      body: SafeArea(
        child: Column(
          children: [
            GestureDetector(
              onTap: () => widget.onBack != null ? widget.onBack!() : Navigator.maybePop(context),
              child: AppBarHeader('My Cart'),
            ),

            // ── Body ──
            Expanded(
              child: Consumer<GlobalCartProvider>(
                builder: (context, cart, _) {
                  if (!cart.hasItems) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.shopping_cart_outlined,
                            size: 80,
                            color: AppColors.subtitle(context).withOpacity(0.3),
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

                  final serviceCarts = cart.serviceCarts;

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    itemCount: serviceCarts.length,
                    itemBuilder: (context, index) {
                      final serviceId = serviceCarts.keys.elementAt(index);
                      final entry = serviceCarts.values.elementAt(index);
                      return _ServiceSection(
                        serviceId: serviceId,
                        entry: entry,
                        onCheckout: () => _showCheckoutDialog(serviceId),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ServiceSection extends StatelessWidget {
  final String serviceId;
  final ServiceCartEntry entry;
  final VoidCallback onCheckout;

  const _ServiceSection({
    required this.serviceId,
    required this.entry,
    required this.onCheckout,
  });

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Service name header ──
        Center(
          child: SizedBox(
            width: sw * 0.9,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Icon(Icons.home_repair_service_outlined, size: 17, color: AppColors.button(context)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      entry.serviceName,
                      style: AppTextStyles.textSize16(context, weight: FontWeight.w600),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    '${entry.itemCount} item${entry.itemCount > 1 ? 's' : ''}',
                    style: AppTextStyles.textSize12(context, color: AppColors.subtitle(context)),
                  ),
                ],
              ),
            ),
          ),
        ),

        // ── Items ──
        Consumer<GlobalCartProvider>(
          builder: (context, cart, _) {
            return Column(
              children: entry.items.map((item) {
                return Column(
                  children: [
                    Divider(height: 1, color: AppColors.border(context)),
                    Center(
                      child: SizedBox(
                        width: sw * 0.9,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Thumbnail
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: item.imageUrl != null
                                    ? CachedNetworkImage(
                                        imageUrl: item.imageUrl!,
                                        width: 58,
                                        height: 58,
                                        fit: BoxFit.cover,
                                        errorWidget: (_, __, ___) => _iconBox(context),
                                      )
                                    : _iconBox(context),
                              ),
                              const SizedBox(width: 14),
                              // Name + controls
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            item.name,
                                            style: AppTextStyles.textSize14(context, weight: FontWeight.w500),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        // Delete
                                        GestureDetector(
                                          onTap: () => cart.removeItem(serviceId, item.id),
                                          child: Icon(Icons.delete_outline_rounded, size: 19, color: Colors.red.shade400),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        // − qty +
                                        _QtyButton(
                                          icon: Icons.remove,
                                          onTap: () => cart.updateItemQuantity(serviceId, item.id, -1),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 12),
                                          child: Text(
                                            '${item.quantity}',
                                            style: AppTextStyles.textSize14(context, weight: FontWeight.w600),
                                          ),
                                        ),
                                        _QtyButton(
                                          icon: Icons.add,
                                          onTap: () => cart.updateItemQuantity(serviceId, item.id, 1),
                                        ),
                                        const Spacer(),
                                        Text(
                                          '৳${item.subtotal.toStringAsFixed(0)}',
                                          style: AppTextStyles.textSize16(context, weight: FontWeight.w700),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
            );
          },
        ),

        // ── Subtotal + Checkout ──
        Divider(height: 1, color: AppColors.border(context)),
        Center(
          child: SizedBox(
            width: sw * 0.9,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Subtotal', style: AppTextStyles.textSize14(context, weight: FontWeight.w500, color: AppColors.subtitle(context))),
                      Text(
                        '৳${entry.subtotal.toStringAsFixed(0)}',
                        style: AppTextStyles.textSize16(context, weight: FontWeight.w700, color: AppColors.button(context)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: onCheckout,
                    child: Container(
                      width: double.infinity,
                      height: 50,
                      decoration: BoxDecoration(
                        color: AppColors.button(context),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Center(
                        child: Text(
                          'Proceed to Checkout',
                          style: AppTextStyles.textSize16(context, weight: FontWeight.w600, color: AppColors.whiteColor),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 8),
        Divider(height: 1, color: AppColors.border(context)),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _iconBox(BuildContext context) => Container(
        width: 58,
        height: 58,
        decoration: BoxDecoration(
          color: AppColors.border(context),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(Icons.home_repair_service_outlined, size: 24, color: AppColors.subtitle(context)),
      );
}

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _QtyButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border(context), width: 1.2),
          borderRadius: BorderRadius.circular(8),
          color: AppColors.containerBackground(context),
        ),
        child: Icon(icon, size: 16, color: AppColors.textPrimary(context)),
      ),
    );
  }
}
