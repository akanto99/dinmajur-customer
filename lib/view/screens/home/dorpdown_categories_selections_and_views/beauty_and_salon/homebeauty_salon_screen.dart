import 'dart:convert';

import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/components/header_appbar.dart';
import 'package:dinmajur_customer/configs/res/sizedbox_spaccing.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:dinmajur_customer/configs/responsive/responsive_ui.dart';
import 'package:dinmajur_customer/configs/utils/routes/routes_name.dart';
import 'package:dinmajur_customer/configs/utils/utils.dart';
import 'package:dinmajur_customer/configs/widgets/customtext_with_formfield.dart';
import 'package:dinmajur_customer/configs/widgets/datepicker_with_formfield.dart';
import 'package:dinmajur_customer/data/response/status.dart';
import 'package:dinmajur_customer/model/home_models/dropdown_categories_selection_models/beauty_and_salon_model/getall_premium_home_beauty_salon_model.dart' hide Image;
import 'package:dinmajur_customer/view/screens/home/dorpdown_categories_selections_and_views/beauty_and_salon/helper_widget/checkout_dialouge_widget.dart';
import 'package:dinmajur_customer/view/screens/home/dorpdown_categories_selections_and_views/beauty_and_salon/helper_widget/servicedetails_dialouge_widget.dart';
import 'package:dinmajur_customer/view/screens/home/helper_widgets/dynamic_bottom_cart_widget.dart';
import 'package:dinmajur_customer/view/screens/home/helper_widgets/dynamic_categorytab.dart';
import 'package:dinmajur_customer/view/screens/home/helper_widgets/dynamic_serviclist_card_widget.dart';
import 'package:dinmajur_customer/view_model/homeview_model/dropdown_categories_selection_view_models/beauty_and_salon_view_model/book_premium_home_beauty_salon_view_model.dart';
import 'package:dinmajur_customer/view_model/homeview_model/dropdown_categories_selection_view_models/beauty_and_salon_view_model/getall_premium_home_beauty_salon_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BookNowHomeBeautySalonScreen extends StatefulWidget {
  final String customerName;
  final String customerPhone;
  final String customerAddress;
  const BookNowHomeBeautySalonScreen({Key? key, required this.customerName, required this.customerPhone, required this.customerAddress}) : super(key: key);

  @override
  State<BookNowHomeBeautySalonScreen> createState() => _BookNowHomeBeautySalonScreenState();
}

class _BookNowHomeBeautySalonScreenState extends State<BookNowHomeBeautySalonScreen> {
  final ScrollController _mainScrollController = ScrollController();
  int _selectedTabIndex = 0;
  final Map<int, GlobalKey> _categoryKeys = {};

  // Map to store quantities for each service
  Map<String, int> _serviceQuantities = {};

  // Checkout form controllers
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _specialRequestController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  String? _selectedServiceTime;
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = Provider.of<GetallPremiumHomeBeautySalonViewModel>(context, listen: false);
      viewModel.fetchGetAllPermiumHomeBeautySalonGetDataApi();
    });
  }

  @override
  void dispose() {
    _mainScrollController.dispose();
    _fullNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _specialRequestController.dispose();
    super.dispose();
  }

  void _initializeCategoryKeys(List<Datum> data) {
    if (_categoryKeys.isEmpty && data.isNotEmpty) {
      for (int i = 0; i < data.length; i++) {
        _categoryKeys[i] = GlobalKey();
      }
    }
  }

  void _scrollToCategory(int index) {
    // Add a post-frame callback to ensure the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_categoryKeys.containsKey(index)) {
        final keyContext = _categoryKeys[index]?.currentContext;
        if (keyContext != null) {
          Scrollable.ensureVisible(keyContext, duration: Duration(milliseconds: 500), curve: Curves.easeInOut, alignment: 0.1);
        }
      }
    });
  }

  void _updateQuantity(String serviceId, int change) {
    setState(() {
      int currentQty = _serviceQuantities[serviceId] ?? 0;
      int newQty = currentQty + change;
      if (newQty >= 0) {
        _serviceQuantities[serviceId] = newQty;
      }
    });
  }

  double _calculateTotal() {
    final viewModel = Provider.of<GetallPremiumHomeBeautySalonViewModel>(context, listen: false);
    final data = viewModel.getAllPremiumHomeBeautySalonData.data?.data ?? [];

    double total = 0;
    data.forEach((category) {
      category.items?.forEach((service) {
        int qty = _serviceQuantities[service.id ?? ''] ?? 0;
        if (qty > 0) {
          double price = service.salePrice?.toDouble() ?? service.originalPrice?.toDouble() ?? 0;
          total += price * qty;
        }
      });
    });
    return total;
  }

  double _calculateSaved() {
    final viewModel = Provider.of<GetallPremiumHomeBeautySalonViewModel>(context, listen: false);
    final data = viewModel.getAllPremiumHomeBeautySalonData.data?.data ?? [];

    double saved = 0;
    data.forEach((category) {
      category.items?.forEach((service) {
        int qty = _serviceQuantities[service.id ?? ''] ?? 0;
        if (qty > 0 && service.discountValue != null) {
          double originalPrice = service.originalPrice?.toDouble() ?? 0;
          double salePrice = service.salePrice?.toDouble() ?? originalPrice;
          double discount = originalPrice - salePrice;
          saved += discount * qty;
        }
      });
    });
    return saved;
  }

  int _getTotalItems() {
    return _serviceQuantities.entries.where((entry) => entry.value > 0).length;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.containerBackground(context),
        body: ResPonsiveUi(mobile: _body(), desktop: _body(), tablet: _body()),
      ),
    );
  }

  Widget _body() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Column(
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(height: 60, child: AppBarHeader("Beauty & Salon")),
        ),
        Expanded(
          child: Consumer<GetallPremiumHomeBeautySalonViewModel>(
            builder: (context, viewModel, _) {
              final data = viewModel.getAllPremiumHomeBeautySalonData.data?.data ?? [];
              final isLoading = viewModel.getAllPremiumHomeBeautySalonData.status == Status.LOADING;
              final hasError = viewModel.getAllPremiumHomeBeautySalonData.status == Status.ERROR;

              // Initialize category keys when data is available
              if (data.isNotEmpty) {
                _initializeCategoryKeys(data);
              }

              if (isLoading) {
                return Center(child: LoadingAnimationWidget.progressiveDots(color: AppColors.button(context), size: 50));
              }

              if (hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 48, color: Colors.red),
                      SizedBox(height: 16),
                      Text('Failed to load services', style: AppTextStyles.textSize16(context, color: Colors.red)),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          viewModel.fetchGetAllPermiumHomeBeautySalonGetDataApi();
                        },
                        child: Text('Retry'),
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.button(context)),
                      ),
                    ],
                  ),
                );
              }

              return SingleChildScrollView(
                controller: _mainScrollController,
                child: Column(
                  children: [
                    SizedboxSpaccing.height015(context),
                    Container(
                      width: screenWidth * 0.9,
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Premium Home",
                                style: AppTextStyles.textSize20(context, weight: FontWeight.w400),
                                textAlign: TextAlign.center,
                              ),
                              Text(
                                " Beauty & Salon",
                                style: AppTextStyles.textSize20(context, weight: FontWeight.w600),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                          SizedboxSpaccing.height01(context),
                          Text(
                            "Trained Beauticians • Premium Products • Salon Experience at Home",
                            style: AppTextStyles.textSize14(context, weight: FontWeight.w400, color: AppColors.subtitle(context)),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    SizedboxSpaccing.height02(context),

                    /// Category tabs - Dynamic Widget
                    DynamicCategoryTabs(
                      categories: data,
                      selectedIndex: _selectedTabIndex,
                      onCategoryTap: (index) {
                        setState(() => _selectedTabIndex = index);
                        _scrollToCategory(index);
                      },
                      getName: (category) => category.name ?? '',
                      getImageUrl: (category) => category.image?.url,
                      getButtonColor: (context) => AppColors.button(context),
                      getBackgroundColor: (context) => AppColors.containerBackground(context),
                      getBorderColor: (context) => AppColors.border(context),
                      getTextColor: (context) => AppColors.textPrimary(context),
                      getTextStyle: (context, isSelected) =>
                          AppTextStyles.textSize12(context, weight: isSelected ? FontWeight.w600 : FontWeight.w400, color: isSelected ? AppColors.button(context) : AppColors.textPrimary(context)),
                      defaultIcon: Icons.spa,
                      supportSvg: false,
                    ),

                    SizedboxSpaccing.height02(context),

                    // All Categories subcategory section here
                    DynamicServiceList<Datum, Item>(
                      categories: data,
                      categoryKeys: _categoryKeys,
                      screenWidth: screenWidth,
                      screenHeight: screenHeight,
                      isSimpleList: false,
                      getItems: (category) => category.items,
                      getCategoryName: (category) => category.name ?? '',
                      categoryHeaderStyle: (context) => AppTextStyles.textSize18(context, weight: FontWeight.w600),
                      emptyStateStyle: (context) => AppTextStyles.textSize16(context),
                      emptyStateSpacing: (context) => SizedboxSpaccing.height02(context),
                      buildServiceCard: (service, width, height) {
                        int quantity = _serviceQuantities[service.id ?? ''] ?? 0;
                        double originalPrice = service.originalPrice?.toDouble() ?? 0;
                        double discountedPrice = service.salePrice?.toDouble() ?? originalPrice;

                        return DynamicServiceCard(
                          imageUrl: service.image?.url,
                          defaultIcon: Icons.spa,
                          serviceName: service.name ?? '',
                          viewDetailsText: 'View Task Details',
                          onViewDetails: () => _showTaskDetailsDialog(service),
                          discountedPrice: discountedPrice,
                          originalPrice: originalPrice,
                          showDiscount: service.discountValue != null && originalPrice > discountedPrice,
                          quantity: quantity,
                          onAdd: () => _updateQuantity(service.id ?? '', 1),
                          onRemove: () => _updateQuantity(service.id ?? '', -1),
                          onIncrease: () => _updateQuantity(service.id ?? '', 1),
                          showRoomNumber: false,
                          getButtonColor: (context) => AppColors.button(context),
                          getBackgroundColor: (context) => AppColors.containerBackground(context),
                          getBorderColor: (context) => AppColors.border(context),
                          getSubtitleColor: (context) => AppColors.subtitle(context),
                          getTextColor: (context) => AppColors.textPrimary(context),
                          getTextStyle: (context, {weight, color}) => AppTextStyles.textSize16(context, weight: weight ?? FontWeight.normal, color: color ?? AppColors.textPrimary(context)),
                          getSpacing: (context) => SizedboxSpaccing.width03(context),
                        );
                      },
                    ),

                    SizedboxSpaccing.height045(context),
                  ],
                ),
              );
            },
          ),
        ),

        // Bottom Cart Bar
        if (_getTotalItems() > 0)
          DynamicBottomCartBar(
            totalServices: _getTotalItems(),
            totalPrice: _calculateTotal(),
            savedAmount: _calculateSaved(),
            onCartTap: _proceedToCart,
            screenWidth: screenWidth,
            screenHeight: screenHeight,
            getButtonColor: (context) => AppColors.button(context),
            getBlackColor: (context) => AppColors.blackColor,
            getWhiteColor: (context) => AppColors.whiteColor,
            getTextStyle: (context, {weight, color}) {
              if (weight == FontWeight.w700) {
                return AppTextStyles.textSize20(context, weight: weight, color: color ?? Colors.white);
              }
              return AppTextStyles.textSize14(context, color: color ?? AppColors.whiteColor);
            },
          ),
      ],
    );
  }

  void _proceedToCart() {
    _showCartDialog();
  }

  void _showCartDialog() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Prepare cart data
    List<Map<String, dynamic>> cartItems = [];
    final viewModel = Provider.of<GetallPremiumHomeBeautySalonViewModel>(context, listen: false);
    final data = viewModel.getAllPremiumHomeBeautySalonData.data?.data ?? [];

    data.forEach((category) {
      category.items?.forEach((service) {
        int qty = _serviceQuantities[service.id ?? ''] ?? 0;
        if (qty > 0) {
          cartItems.add({'service': service, 'quantity': qty});
        }
      });
    });

    double calculateSubtotal(Map<String, int> quantities) {
      double subtotal = 0;
      for (var item in cartItems) {
        Item service = item['service'];
        int qty = quantities[service.id ?? ''] ?? 0;
        if (qty > 0) {
          double price = service.salePrice?.toDouble() ?? service.originalPrice?.toDouble() ?? 0;
          subtotal += price * qty;
        }
      }
      return subtotal;
    }

    double calculateOriginalTotal(Map<String, int> quantities) {
      double originalTotal = 0;
      for (var item in cartItems) {
        Item service = item['service'];
        int qty = quantities[service.id ?? ''] ?? 0;
        if (qty > 0) {
          double price = service.originalPrice?.toDouble() ?? 0;
          originalTotal += price * qty;
        }
      }
      return originalTotal;
    }

    showDialog(
      context: context,
      barrierColor: AppColors.showDialougeBackground(context),
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          double subtotal = calculateSubtotal(_serviceQuantities);
          double transport = 80.0;
          double total = subtotal + transport;
          double originalTotal = calculateOriginalTotal(_serviceQuantities) + transport;
          double saved = originalTotal - total;

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
                  // Header
                  Container(
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
                            Text('${cartItems.length} service${cartItems.length > 1 ? 's' : ''}', style: AppTextStyles.textSize14(context, color: AppColors.subtitle(context))),
                          ],
                        ),
                        Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('Total ৳${total.toStringAsFixed(2)}', style: AppTextStyles.textSize18(context, weight: FontWeight.w600)),
                                SizedboxSpaccing.height005(context),
                                if (saved > 0)
                                  Text(
                                    '৳${originalTotal.toStringAsFixed(2)}',
                                    style: AppTextStyles.textSize12(context, color: AppColors.textPrimary(context)).copyWith(decoration: TextDecoration.lineThrough),
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
                                decoration: BoxDecoration(color: AppColors.button(context).withOpacity(0.2), shape: BoxShape.circle),
                                child: Icon(Icons.close, size: 20, color: AppColors.textPrimary(context)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Cart Items List
                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                      itemCount: cartItems.length,
                      separatorBuilder: (context, index) => SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final item = cartItems[index];
                        Item service = item['service'];
                        int qty = _serviceQuantities[service.id ?? ''] ?? 0;

                        if (qty == 0) return SizedBox.shrink();

                        double price = service.salePrice?.toDouble() ?? service.originalPrice?.toDouble() ?? 0;
                        double originalPrice = service.originalPrice?.toDouble() ?? 0;

                        return Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.border(context)),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(service.name ?? '', style: AppTextStyles.textSize14(context, weight: FontWeight.w500)),
                                        SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Text('৳${price.toStringAsFixed(2)}', style: AppTextStyles.textSize14(context, weight: FontWeight.w600)),
                                            if (service.discountValue != null && originalPrice > price) ...[
                                              SizedBox(width: 8),
                                              Text(
                                                '৳${originalPrice.toStringAsFixed(2)}',
                                                style: AppTextStyles.textSize12(context, color: AppColors.subtitle(context)).copyWith(decoration: TextDecoration.lineThrough),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            if (qty > 1) {
                                              _serviceQuantities[service.id ?? ''] = qty - 1;
                                            } else {
                                              _serviceQuantities[service.id ?? ''] = 0;
                                            }
                                          });
                                          setDialogState(() {});

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
                                          child: Text(qty.toString(), style: AppTextStyles.textSize16(context, weight: FontWeight.w600)),
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _serviceQuantities[service.id ?? ''] = qty + 1;
                                          });
                                          setDialogState(() {});
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
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                  // Price Summary
                  Container(
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
                            Text('৳${subtotal.toStringAsFixed(2)}', style: AppTextStyles.textSize14(context, weight: FontWeight.w600)),
                          ],
                        ),
                        SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Transport Fee', style: AppTextStyles.textSize14(context)),
                            Text('৳${transport.toStringAsFixed(2)}', style: AppTextStyles.textSize14(context, weight: FontWeight.w600)),
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
                                style: AppTextStyles.textSize14(context, weight: FontWeight.w600, color: Colors.green),
                              ),
                            ],
                          ),
                        ],
                        Divider(height: 20, thickness: 1),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Total Amount', style: AppTextStyles.textSize16(context, weight: FontWeight.w600)),
                            Text(
                              '৳${total.toStringAsFixed(2)}',
                              style: AppTextStyles.textSize18(context, weight: FontWeight.w700, color: AppColors.button(context)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Checkout Button
                  Padding(
                    padding: EdgeInsets.all(15),
                    child: GestureDetector(
                      onTap: () {
                        if (total < 600) {
                          Utils.flushBarExclamatoryMessage(title: "Warning", subtitle: " Minimum order amount is BDT 600 to proceed!", context: context);
                          return; // Don't proceed to checkout
                        }
                        Navigator.pop(context);
                        _showCheckoutDialog();
                      },
                      child: Container(
                        width: screenWidth,
                        height: 50,
                        decoration: BoxDecoration(color: AppColors.button(context), borderRadius: BorderRadius.circular(8)),
                        child: Center(
                          child: Text(
                            'Proceed to Checkout',
                            style: AppTextStyles.textSize16(context, weight: FontWeight.w600, color: Colors.white),
                          ),
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

  void _showTaskDetailsDialog(Item service) {
    showDialog(
      context: context,
      barrierColor: AppColors.showDialougeBackground(context),
      builder: (context) => ServiceDetailsDialog(
        imageUrl: service.image?.url,
        serviceName: service.name ?? 'Service Details',
        discountedPrice: service.salePrice?.toDouble() ?? service.originalPrice?.toDouble() ?? 0,
        originalPrice: service.originalPrice?.toDouble() ?? 0,
        showDiscount: service.discountValue != null && (service.originalPrice?.toDouble() ?? 0) > (service.salePrice?.toDouble() ?? 0),
        details: service.details,
        onClose: () => Navigator.pop(context),
        getButtonColor: (context) => AppColors.button(context),
        getBackgroundColor: (context) => AppColors.containerBackground(context),
        getBorderColor: (context) => AppColors.border(context),
        getTextColor: (context) => AppColors.textPrimary(context),
      ),
    );
  }

  void _showCheckoutDialog() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId') ?? '';

    if (userId.isEmpty) {
      Utils.flushBarErrorMessage('User ID not found. Please login again.',context);
      return;
    }

    showDialog(
      context: context,
      barrierColor: AppColors.showDialougeBackground(context),
      builder: (context) => Consumer<PostBookPremiumHomeBeautySalonViewModel>(
        builder: (context, bookingViewModel, _) {
          return CheckoutDialog(
            customerName: widget.customerName,
            customerPhone: widget.customerPhone,
            customerAddress: widget.customerAddress,
            userId: userId,
            categories: Provider.of<GetallPremiumHomeBeautySalonViewModel>(context, listen: false).getAllPremiumHomeBeautySalonData.data?.data ?? [],
            serviceQuantities: _serviceQuantities,
            totalPrice: _calculateTotal(),
            transportFee: 80.0,
            isLoading: bookingViewModel.createBookPremiumHomeBeautySalonLoading,
            onConfirmBooking: (bookingData) async {
              // Print data for debugging
              print('Booking Data: ${json.encode(bookingData)}');

              // Call API with success callback
              await bookingViewModel.bookPremiumHomeBeautySalonPostApi(context, bookingData, (String trackingId) {
                // This runs ONLY on success
                print('Success! TrackingId: $trackingId');

                // Close checkout dialog
                Navigator.pop(context);

                // Clear all cart data
                setState(() {
                  _serviceQuantities.clear();
                  _fullNameController.clear();
                  _phoneController.clear();
                  _addressController.clear();
                  _specialRequestController.clear();
                  _dateController.clear();
                  _selectedServiceTime = null;
                });

                // Navigate to confirmed screen with trackingId
                Navigator.pushNamed(context, RoutesName.beautyConfirmedScreen, arguments: {'trackingId': trackingId});
              });
            },
          );
        },
      ),
    );
  }

  void _sendBookingToApi(Map<String, dynamic> bookingData) {
    // Print the data to console (for testing)
    print('Booking Data: ${json.encode(bookingData)}');

    // TODO: Call your API here
    // Example:
    // viewModel.bookBeautySalonService(bookingData);

    // Show success dialog after API call
  }
}
