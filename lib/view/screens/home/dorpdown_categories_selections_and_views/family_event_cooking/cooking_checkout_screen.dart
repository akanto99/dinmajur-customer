
import 'dart:io';

import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/components/header_appbar.dart';
import 'package:dinmajur_customer/configs/res/components/iagree_terms&condition/iagree_terms&condition.dart';
import 'package:dinmajur_customer/configs/res/components/payment_method/payment_method_component.dart';
import 'package:dinmajur_customer/configs/res/components/section_header/section_header.dart';
import 'package:dinmajur_customer/configs/res/sizedbox_spaccing.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:dinmajur_customer/configs/services/ssl_payment_service/ssl_payment.dart';
import 'package:dinmajur_customer/configs/utils/amount_formatter/amount_formatter.dart';
import 'package:dinmajur_customer/configs/utils/routes/routes_name.dart';
import 'package:dinmajur_customer/configs/utils/utils.dart';
import 'package:dinmajur_customer/view/screens/home/dorpdown_categories_selections_and_views/family_event_cooking/notifier/cooking_checkout_notifier.dart';
import 'package:dinmajur_customer/view/screens/home/helper_widgets/add_location_screen_widget/add_location_screen_widget.dart';
import 'package:dinmajur_customer/view_model/homeview_model/dropdown_categories_selection_view_models/family_event_cooking_view_model/book_family_event_cooking_view_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';

import '../../../../../model/home_models/dropdown_categories_selection_models/family_event_cooking_model/getall_family_event_cooking_model.dart';

class CookingCheckoutScreen extends StatefulWidget {
  final String customerName;
  final String customerPhone;
  final String customerAddress;
  final String userId;
  final List<Datum> categories;
  final Map<String, String?> selectedPackages; // REGULAR packages
  final Map<String, Set<String>> selectedManualItems; // MANUAL items
  final String? activeCategoryId;
  final int selectedGuestRangeIndex;
  final double totalPrice;
  final double savedAmount;
  final double transportFee;
  final DateTime? selectedDate;
  final String? selectedServiceTime;
  final Function(String)? onAddressUpdate;
  final Map<String, dynamic>? customerLocation;

  const CookingCheckoutScreen({
    Key? key,
    required this.customerName,
    required this.customerPhone,
    required this.customerAddress,
    required this.userId,
    required this.categories,
    required this.selectedPackages,
    required this.selectedManualItems,
    required this.activeCategoryId,
    required this.selectedGuestRangeIndex,
    required this.totalPrice,
    required this.savedAmount,
    required this.transportFee,
    required this.selectedDate,
    required this.selectedServiceTime,
    this.onAddressUpdate,
    this.customerLocation,
  }) : super(key: key);

  @override
  State<CookingCheckoutScreen> createState() => _CookingCheckoutScreenState();
}

class _CookingCheckoutScreenState extends State<CookingCheckoutScreen> {
  final TextEditingController _addressController = TextEditingController();
  bool _isTermsAccepted = false;

  Map<String, dynamic>? _updatedLocation;

  // Red border validation
  bool _addressError = false;
  bool _paymentError = false;
  bool _termsError = false;
  final GlobalKey _addressKey = GlobalKey();
  final GlobalKey _paymentKey = GlobalKey();
  final GlobalKey _termsKey = GlobalKey();
  final ScrollController _scrollController = ScrollController();

  void _scrollToKey(GlobalKey key) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = key.currentContext;
      if (ctx != null) Scrollable.ensureVisible(ctx, duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
    });
  }
  @override
  void initState() {
    super.initState();
    _addressController.text = widget.customerAddress;
    _updatedLocation = widget.customerLocation;
    _restoreSessionLocation();
  }

  Future<void> _restoreSessionLocation() async {
    final sessionData = await CheckoutSessionLocationService.getAll();
    if (sessionData.location != null && sessionData.address != null) {
      if (mounted) {
        setState(() {
          _updatedLocation = sessionData.location;
          _addressController.text = sessionData.address!;
        });
      }
    }
  }

  @override
  void dispose() {
    _addressController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _handlePaymentResult({required CookingCheckoutViewModel viewModel, required SSLPaymentResult paymentResult, required String trackingId}) async {
    if (!mounted) return;

    if (paymentResult.success) {
      _clearAllData();
      Navigator.pushReplacementNamed(context, RoutesName.cookingConfirmedScreen, arguments: {
        'trackingId': trackingId,
        'valId': paymentResult.validationId ?? 'N/A',
        'fromCheckout': true,
      });
    } else if (paymentResult.status == 'FAILED') {

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.pushReplacementNamed(
            context,
            RoutesName.cookingFailedCancelledPaymentScreen,
            arguments: {
              'trackingId': trackingId,
              'valId': paymentResult.validationId ?? 'N/A',
              'reason': 'Payment transaction failed',
              'errorMessage': paymentResult.errorMessage ?? 'The payment could not be completed. Please try again.',
              'isCancelled': false, // Payment failed
            },
          );
        }
      });
    } else if (paymentResult.status == 'CLOSED') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.pushReplacementNamed(
            context,
            RoutesName.cookingFailedCancelledPaymentScreen,
            arguments: {
              'trackingId': trackingId,
              'valId': paymentResult.validationId ?? 'N/A',
              'reason': 'Payment cancelled by user',
              'errorMessage': 'You cancelled the payment. You can retry whenever you\'re ready.',
              'isCancelled': true, // Payment cancelled
            },
          );
        }
      });
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Utils.flushBarErrorMessage(paymentResult.errorMessage ?? "Payment status unclear", context);
        }
      });
    }
  }

  void _clearAllData() {
    final checkoutVM = Provider.of<CookingCheckoutViewModel>(context, listen: false);
    checkoutVM.reset();

    _addressController.clear();
    setState(() {
      _isTermsAccepted = false;
    });
  }

  Map<String, dynamic> _prepareBookingPayload() {
    if (widget.activeCategoryId == null) {
      throw Exception('No active category selected');
    }

    // Find the active category
    Datum? activeCategory;
    for (var category in widget.categories) {
      if (category.id == widget.activeCategoryId) {
        activeCategory = category;
        break;
      }
    }

    if (activeCategory == null) {
      throw Exception('Active category not found');
    }

    final checkoutVM = Provider.of<CookingCheckoutViewModel>(context, listen: false);

    // Base booking data
    Map<String, dynamic> bookingPayload = {
      "booking": {
        "paymentType": checkoutVM.getPaymentMethodData(checkoutVM.selectedPaymentMethod).toUpperCase(),
        "fullAddress": _updatedLocation?['fullAddress'] ?? _addressController.text,
        "location": _updatedLocation,
        "fullName": widget.customerName,
        "phone": widget.customerPhone,
        "date": widget.selectedDate?.toIso8601String() ?? DateTime.now().toIso8601String(),
        "slot": widget.selectedServiceTime?.toUpperCase() ?? 'DAY',
      },
      "eventCookingCategoryId": activeCategory.id,
      "source": Platform.isAndroid ? "android" : "ios",
    };

    if (activeCategory.type == 'REGULAR') {
      // REGULAR type: Single package selection
      final selectedPackageId = widget.selectedPackages[activeCategory.id];

      if (selectedPackageId == null) {
        throw Exception('No package selected');
      }

      // Find the selected package to get price ID
      String? priceId;
      for (var package in activeCategory.packages ?? []) {
        if (package.id == selectedPackageId) {
          if (widget.selectedGuestRangeIndex < (package.prices?.length ?? 0)) {
            priceId = package.prices![widget.selectedGuestRangeIndex].id;
          }
          break;
        }
      }

      bookingPayload["packages"] = [
        {"packageId": selectedPackageId, "priceId": priceId},
      ];
    } else if (activeCategory.type == 'CUSTOM') {
      // Same structure as REGULAR — single package, priceId from customPrice
      final selectedPackageId = widget.selectedPackages[activeCategory.id];
      if (selectedPackageId == null) throw Exception('No package selected');

      String? priceId;
      for (var package in activeCategory.packages ?? []) {
        if (package.id == selectedPackageId) {
          priceId = package.customPrice?.id;
          break;
        }
      }

      bookingPayload["packages"] = [
        {"packageId": selectedPackageId, "priceId": priceId},
      ];
    } else if (activeCategory.type == 'MANUAL') {
      // MANUAL type: Multiple items selection
      bookingPayload["eventCookingCategoryId"] = activeCategory.id;

      // Group items by package
      Map<String, List<Map<String, String>>> packageItemsMap = {};

      for (var package in activeCategory.packages ?? []) {
        for (var item in package.items ?? []) {
          final key = '${package.id}_${item.id}';

          if (widget.selectedManualItems[activeCategory.id]?.contains(key) ?? false) {
            // Get the price ID for this item
            String? priceId;
            if (widget.selectedGuestRangeIndex < (item.prices?.length ?? 0)) {
              priceId = item.prices![widget.selectedGuestRangeIndex].id;
            }

            if (!packageItemsMap.containsKey(package.id)) {
              packageItemsMap[package.id!] = [];
            }

            packageItemsMap[package.id]!.add({
              "itemId": item.id!,
              "priceId": priceId ?? item.id!, // Fallback to item.id if price not found
            });
          }
        }
      }

      // Convert map to packages array
      List<Map<String, dynamic>> packages = [];
      packageItemsMap.forEach((packageId, items) {
        packages.add({"packageId": packageId, "items": items});
      });

      bookingPayload["packages"] = packages;
    }

    return bookingPayload;
  }

  Future<void> _handleConfirmBooking() async {
    final checkoutVM = Provider.of<CookingCheckoutViewModel>(context, listen: false);
    final bookingViewModel = Provider.of<PostBookFamilyEventCookingViewModel>(context, listen: false);
    if (bookingViewModel.createBookFamilyEventCookingLoading) {
      return;
    }
    // Calculate total amount
    double totalAmount = widget.totalPrice + widget.transportFee;

    // Validate form
    final String currentAddress = _addressController.text.isEmpty ? widget.customerAddress : _addressController.text;
    final bool newAddressError = currentAddress.isEmpty;
    final bool newPaymentError = (checkoutVM.selectedPaymentMethod ?? '').isEmpty;
    final bool newTermsError = !_isTermsAccepted;

    if (newAddressError || newPaymentError || newTermsError) {
      setState(() {
        _addressError = newAddressError;
        _paymentError = newPaymentError;
        _termsError = newTermsError;
      });
      if (newAddressError) _scrollToKey(_addressKey);
      else if (newPaymentError) _scrollToKey(_paymentKey);
      else _scrollToKey(_termsKey);
      return;
    }

    try {
      // Prepare booking payload
      Map<String, dynamic> bookingPayload = _prepareBookingPayload();

      // print('Booking Payload: $bookingPayload');

      // Call booking API
      await bookingViewModel.bookFamilyEventCookingPostApi(context, bookingPayload, (String? trackingId) async {
        // print('Success! TrackingId: $trackingId');

        if (trackingId == null || trackingId.isEmpty) {
          bookingViewModel.setBookFamilyEventCookingLoading(false);
          Navigator.pushReplacementNamed(
            context,
            RoutesName.failedOrderScreenWidget,
            arguments: {'trackingId': 'N/A', 'valId': 'N/A', 'reason': 'Booking creation failed', 'errorMessage': 'Unable to create booking. Please try again.'},
          );
          return;
        }

        if (checkoutVM.selectedPaymentMethod == 'online') {
          final paymentResult = await checkoutVM.initiatePayment(
            trackingId: trackingId,
            totalAmount: totalAmount,
            customerName: widget.customerName,
            customerPhone: widget.customerPhone,
            customerEmail: null,
            customerAddress: _addressController.text.trim(),
          );
          await _handlePaymentResult(viewModel: checkoutVM, paymentResult: paymentResult, trackingId: trackingId);
          bookingViewModel.setBookFamilyEventCookingLoading(false);

        } else if (checkoutVM.selectedPaymentMethod == 'cash') {
          _clearAllData();
          Navigator.pop(context);
          Navigator.pushNamed(context, RoutesName.cookingConfirmedScreen, arguments: {
            'trackingId': trackingId,
            'valId': "COD",
            'fromCheckout': true,
          });
          bookingViewModel.setBookFamilyEventCookingLoading(false);
        } else {
          bookingViewModel.setBookFamilyEventCookingLoading(false);
          Navigator.pushReplacementNamed(
            context,
            RoutesName.failedOrderScreenWidget,
            arguments: {'trackingId': trackingId, 'valId': 'N/A', 'reason': 'Invalid payment method', 'errorMessage': 'The selected payment method is not available.'},
          );
        }
      });
    } catch (e) {
      bookingViewModel.setBookFamilyEventCookingLoading(false);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.pushReplacementNamed(
            context,
            RoutesName.failedOrderScreenWidget,
            arguments: {'trackingId': 'N/A', 'valId': 'N/A', 'reason': 'Booking failed', 'errorMessage': 'An error occurred while processing your booking. Please try again.'},
          );
        }
      });
    }
  }

  String _getGuestRangeText() {
    // Collect unique guest ranges in the same order as FamilyEventCookingScreen does
    final List<GuestRange> guestRanges = [];
    final Set<String> seenIds = {};

    for (var category in widget.categories) {
      for (var package in category.packages ?? []) {
        // REGULAR type — prices on the package
        for (var price in package.prices ?? []) {
          if (price.guestRange != null && !seenIds.contains(price.guestRange!.id)) {
            seenIds.add(price.guestRange!.id!);
            guestRanges.add(price.guestRange!);
          }
        }
        // MANUAL type — prices on the items
        for (var item in package.items ?? []) {
          for (var price in item.prices ?? []) {
            if (price.guestRange != null && !seenIds.contains(price.guestRange!.id)) {
              seenIds.add(price.guestRange!.id!);
              guestRanges.add(price.guestRange!);
            }
          }
        }
      }
    }

    if (widget.selectedGuestRangeIndex < guestRanges.length) {
      return guestRanges[widget.selectedGuestRangeIndex].label ?? '';
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<CookingCheckoutViewModel, PostBookFamilyEventCookingViewModel>(
      builder: (context, checkoutVM, bookingVM, _) {
        double total = widget.totalPrice + widget.transportFee;
        bool isLoading = bookingVM.createBookFamilyEventCookingLoading;

        return WillPopScope(
          onWillPop: () async {
            Navigator.pop(context, false);
            return false;
          },
          child: Scaffold(
            backgroundColor: AppColors.containerBackground(context),
            body: SafeArea(
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context, false),
                    child: Container(height: 60, child: AppBarHeader("Checkout")),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      padding: EdgeInsets.all(15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildCustomerDetailsCard(),
                          SizedboxSpaccing.height02(context),
                          _buildBookingSummary(),
                          SizedboxSpaccing.height02(context),
                          _buildPaymentMethodSection(checkoutVM),

                          AnimatedContainer(
                            key: _termsKey,
                            duration: const Duration(milliseconds: 300),
                            decoration: _termsError
                                ? BoxDecoration(borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.red, width: 1.5))
                                : const BoxDecoration(),
                            child: DynamicTermsCheckbox(
                              isAccepted: _isTermsAccepted,
                              onChanged: (value) {
                                setState(() {
                                  _isTermsAccepted = value;
                                  if (value) _termsError = false;
                                });
                              },
                              context: context,
                              onTermsTap: () => Navigator.pushNamed(context, RoutesName.termsAndCondition),
                              onPrivacyTap: () => Navigator.pushNamed(context, RoutesName.privacyPolicy),
                              onRefundTap: () => Navigator.pushNamed(context, RoutesName.refundPolicyScreen),
                              getButtonColor: (context) => AppColors.button(context),
                              getBorderColor: (context) => _termsError ? Colors.red : AppColors.border(context),
                              getWhiteColor: (context) => AppColors.whiteColor,
                              getTextStyle: (context, {weight}) => AppTextStyles.textSize16(context, weight: weight ?? FontWeight.w400),
                            ),
                          ),
                          if (_termsError)
                            Padding(
                              padding: const EdgeInsets.only(top: 4, left: 4),
                              child: Text('Please accept the Terms & Conditions to proceed', style: AppTextStyles.textSize12(context, color: Colors.red)),
                            ),
                          SizedboxSpaccing.height03(context),
                        ],
                      ),
                    ),
                  ),
                  _buildConfirmButton(context, checkoutVM, bookingVM, total, isLoading),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleEditAddress() async {
    final result = await Navigator.pushNamed(context, RoutesName.addLocationScreenWidget);

    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        final String newAddress = result['fullAddress'] ?? '';

        if (newAddress.isNotEmpty) {
          _addressController.text = newAddress;

          // ✅ Capture the full location data returned from AddLocationScreenWidget
          if (result['location'] != null) {
            _updatedLocation = result['location'] as Map<String, dynamic>;
          }

          if (widget.onAddressUpdate != null) {
            widget.onAddressUpdate!(newAddress);
          }
        }
      });
    }
  }

  Widget _buildCustomerDetailsCard() {
    final screenHeight = MediaQuery.of(context).size.height;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedContainer(
          key: _addressKey,
          duration: const Duration(milliseconds: 300),
          padding: EdgeInsets.all(screenHeight * 0.015),
          decoration: BoxDecoration(
            color: AppColors.containerBackground(context),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _addressError ? Colors.red : AppColors.border(context), width: _addressError ? 1.5 : 1.0),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Customer Details', style: AppTextStyles.textSize14(context, weight: FontWeight.w500, color: _addressError ? Colors.red : null)),
                  GestureDetector(
                    onTap: () async {
                      await _handleEditAddress();
                      if (_addressController.text.isNotEmpty) setState(() => _addressError = false);
                    },
                    child: Container(
                      width: 80,
                      color: Colors.transparent,
                      alignment: Alignment.centerRight,
                      child: Text('Edit', style: AppTextStyles.textSize14(context, weight: FontWeight.w500)),
                    ),
                  ),
                ],
              ),
              SizedboxSpaccing.height01(context),
              _buildDetailRow('Name', widget.customerName),
              SizedboxSpaccing.height01(context),
              _buildDetailRow('Phone', widget.customerPhone),
              SizedboxSpaccing.height01(context),
              _buildDetailRow('Address', _addressController.text.isEmpty ? widget.customerAddress : _addressController.text, isMultiline: true),
            ],
          ),
        ),
        if (_addressError)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 4),
            child: Text('Please set a delivery address', style: AppTextStyles.textSize12(context, color: Colors.red)),
          ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isMultiline = false}) {
    if (isMultiline) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label :  ', style: AppTextStyles.textSize14(context, weight: FontWeight.w400)),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.textSize14(context, weight: FontWeight.w500, color: AppColors.subtitle(context)),
              maxLines: null,
              softWrap: true,
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        Text('$label :  ', style: AppTextStyles.textSize14(context, weight: FontWeight.w400)),
        Text(
          value,
          style: AppTextStyles.textSize14(context, weight: FontWeight.w500, color: AppColors.subtitle(context)),
        ),
      ],
    );
  }

  Widget _buildBookingSummary() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Check if active category is CUSTOM
    bool isCustomCategory = false;
    for (var category in widget.categories) {
      if (category.id == widget.activeCategoryId) {
        isCustomCategory = category.type == 'CUSTOM';
        break;
      }
    }

    return Column(
      children: [
        SectionHeader(title: 'Booking Summary', titleWidth: screenWidth * 0.6, showSeeAll: false),
        SizedboxSpaccing.height02(context),
        Container(
          padding: EdgeInsets.all(screenHeight * 0.015),
          decoration: BoxDecoration(
            color: AppColors.containerBackground(context),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border(context)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Show selected package/items details
              _buildSelectedItemsSection(),
              SizedboxSpaccing.height015(context),
              _buildSummaryRow('Date', DateFormat('MMMM dd, yyyy').format(widget.selectedDate ?? DateTime.now())),
              if (!isCustomCategory) ...[SizedboxSpaccing.height015(context), _buildSummaryRow('Number of Guests', _getGuestRangeText())],
              SizedboxSpaccing.height015(context),
              _buildSummaryRow('Slot', widget.selectedServiceTime ?? 'Not selected'),
              SizedboxSpaccing.height015(context),
              _buildPriceRow('Subtotal', widget.totalPrice),
              SizedboxSpaccing.height015(context),
              _buildPriceRow('Transport', widget.transportFee),
              SizedboxSpaccing.height015(context),
              Divider(height: 1, color: AppColors.border(context)),
              SizedboxSpaccing.height015(context),
              _buildPriceRow('Total', widget.totalPrice + widget.transportFee, isBold: true),
            ],
          ),
        ),
      ],
    );
  }

  // Build selected items section
  Widget _buildSelectedItemsSection() {
    if (widget.activeCategoryId == null) return SizedBox.shrink();

    for (var category in widget.categories) {
      if (category.id == widget.activeCategoryId) {
        if (category.type == 'REGULAR') {
          return _buildRegularPackageDetails(category);
        } else if (category.type == 'MANUAL') {
          return _buildManualItemsDetails(category);
        } else if (category.type == 'CUSTOM') {
          return _buildCustomPackageDetails(category);
        }
      }
    }
    return SizedBox.shrink();
  }

  // Build REGULAR package details
  Widget _buildRegularPackageDetails(Datum category) {
    final selectedPackageId = widget.selectedPackages[category.id];
    if (selectedPackageId == null) return SizedBox.shrink();

    for (var package in category.packages ?? []) {
      if (package.id == selectedPackageId) {
        double salePrice = 0;
        double originalPrice = 0;

        if (widget.selectedGuestRangeIndex < (package.prices?.length ?? 0)) {
          salePrice = package.prices![widget.selectedGuestRangeIndex].salePrice?.toDouble() ?? 0;
          originalPrice = package.prices![widget.selectedGuestRangeIndex].originalPrice?.toDouble() ?? 0;
        }

        double savedAmount = originalPrice - salePrice;

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(package.name ?? '', style: AppTextStyles.textSize14(context, weight: FontWeight.w400)),
            Row(
              children: [
                Text('৳${AmountFormatter.format(salePrice)}', style: AppTextStyles.textSize14(context, weight: FontWeight.w600)),
                if (savedAmount > 0) ...[
                  SizedBox(width: 8),
                  Text(
                    '৳${AmountFormatter.format(originalPrice)}',
                    style: AppTextStyles.textSize12(context, color: AppColors.subtitle(context)).copyWith(decoration: TextDecoration.lineThrough),
                  ),
                ],
              ],
            ),
          ],
        );
      }
    }
    return SizedBox.shrink();
  }

  // Build MANUAL items details
  Widget _buildManualItemsDetails(Datum category) {
    List<Map<String, dynamic>> selectedItems = [];
    double totalSalePrice = 0;
    double totalOriginalPrice = 0;

    for (var package in category.packages ?? []) {
      for (var item in package.items ?? []) {
        final key = '${package.id}_${item.id}';
        if (widget.selectedManualItems[category.id]?.contains(key) ?? false) {
          double salePrice = 0;
          double originalPrice = 0;

          if (widget.selectedGuestRangeIndex < (item.prices?.length ?? 0)) {
            salePrice = item.prices![widget.selectedGuestRangeIndex].salePrice?.toDouble() ?? 0;
            originalPrice = item.prices![widget.selectedGuestRangeIndex].originalPrice?.toDouble() ?? 0;
          }

          totalSalePrice += salePrice;
          totalOriginalPrice += originalPrice;

          selectedItems.add({'name': item.name ?? '', 'salePrice': salePrice, 'originalPrice': originalPrice});
        }
      }
    }

    if (selectedItems.isEmpty) return SizedBox.shrink();

    double totalSaved = totalOriginalPrice - totalSalePrice;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('${category.name ?? ''}', style: AppTextStyles.textSize14(context, weight: FontWeight.w600)),
        SizedBox(height: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...selectedItems.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isLast = index == selectedItems.length - 1;

              return Padding(
                padding: EdgeInsets.only(bottom: isLast ? 0 : 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text('${item['name']}', style: AppTextStyles.textSize12(context, weight: FontWeight.w400)),
                    ),
                    Row(
                      children: [
                        Text('৳${AmountFormatter.format(item['salePrice'])}', style: AppTextStyles.textSize12(context, weight: FontWeight.w500)),
                        if (item['originalPrice'] > item['salePrice']) ...[
                          SizedBox(width: 6),
                          Text(
              "৳${AmountFormatter.format(item['originalPrice'])}",
                            style: AppTextStyles.textSize10(context, color: AppColors.subtitle(context)).copyWith(decoration: TextDecoration.lineThrough),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.textSize14(context, weight: FontWeight.w400)),
        Expanded(
          child: Text(
            value,
            style: AppTextStyles.textSize14(context, weight: FontWeight.w500),
            textAlign: TextAlign.end,
            maxLines: null,
            softWrap: true,
          ),
        ),
      ],
    );
  }

  Widget _buildPriceRow(String label, double amount, {bool isGreen = false, bool isBold = false}) {
    final weight = isBold ? FontWeight.w700 : (label == 'Subtotal' || label == 'Transport' ? FontWeight.w400 : FontWeight.w500);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.textSize14(context, weight: weight)),
        Text(
          '৳${AmountFormatter.format(amount)}',
          style: AppTextStyles.textSize14(context, weight: weight, color: isGreen ? Colors.green : AppColors.textPrimary(context)),
        ),
      ],
    );
  }

  Widget _buildPaymentMethodSection(CookingCheckoutViewModel viewModel) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Column(
      key: _paymentKey,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: 'Payment Method', titleWidth: screenWidth * 0.6, showSeeAll: false, titleStyle: _paymentError ? AppTextStyles.textSize18(context, weight: FontWeight.w500, color: Colors.red) : null),
        SizedboxSpaccing.height02(context),
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: _paymentError
              ? BoxDecoration(borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.red, width: 1.5))
              : const BoxDecoration(),
          child: PaymentMethodWidget(
            selectedPaymentMethod: viewModel.selectedPaymentMethod,
            paymentMethods: viewModel.paymentMethods,
            onPaymentMethodChanged: (method) {
              viewModel.setPaymentMethod(method);
              if (method.isNotEmpty) setState(() => _paymentError = false);
            },
          ),
        ),
        if (_paymentError)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 4),
            child: Text('Please select a payment method', style: AppTextStyles.textSize12(context, color: Colors.red)),
          ),
      ],
    );
  }

  Widget _buildCustomPackageDetails(Datum category) {
    final selectedPackageId = widget.selectedPackages[category.id];
    if (selectedPackageId == null) return SizedBox.shrink();

    for (var package in category.packages ?? []) {
      if (package.id == selectedPackageId) {
        final salePrice = package.customPrice?.salePrice?.toDouble() ?? 0;
        final originalPrice = package.customPrice?.originalPrice?.toDouble() ?? 0;
        final savedAmount = originalPrice - salePrice;

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(package.name ?? '', style: AppTextStyles.textSize14(context, weight: FontWeight.w400)),
            Row(
              children: [
                Text('৳${AmountFormatter.format(salePrice)}', style: AppTextStyles.textSize14(context, weight: FontWeight.w600)),
                if (savedAmount > 0) ...[
                  SizedBox(width: 8),
                  Text(
                    '৳${AmountFormatter.format(originalPrice)}',
                    style: AppTextStyles.textSize12(context, color: AppColors.subtitle(context)).copyWith(decoration: TextDecoration.lineThrough),
                  ),
                ],
              ],
            ),
          ],
        );
      }
    }
    return SizedBox.shrink();
  }

  Widget _buildConfirmButton(BuildContext context, CookingCheckoutViewModel checkoutVM, PostBookFamilyEventCookingViewModel bookingVM, double total, bool isLoading) {
    // ✅ Only use ViewModel loading state
    bool isButtonDisabled = bookingVM.createBookFamilyEventCookingLoading;

    return Container(
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.button(context),
        border: Border(top: BorderSide(color: AppColors.border(context), width: 1)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Total Amount', style: AppTextStyles.textSize14(context, color: AppColors.whiteColor)),
                SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      "৳${AmountFormatter.format(total)}",
                      style: AppTextStyles.textSize20(context, weight: FontWeight.w700, color: AppColors.whiteColor),
                    ),
                    if (widget.savedAmount > 0) ...[
                      SizedBox(width: 8),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: Colors.green.withOpacity(0.2), borderRadius: BorderRadius.circular(4)),
                        child: Text(
                          'Saved ৳${AmountFormatter.format(widget.savedAmount)}',
                          style: AppTextStyles.textSize12(context, color: Colors.greenAccent, weight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          // ✅ Wrap with AbsorbPointer to prevent taps when disabled
          AbsorbPointer(
            absorbing: isButtonDisabled,
            child: GestureDetector(
              onTap: _handleConfirmBooking,
              child: Container(
                height: 50,
                width: 140,
                decoration: BoxDecoration(
                  color: isButtonDisabled
                      ? AppColors.blackColor.withOpacity(0.5) // ✅ Visual feedback when disabled
                      : AppColors.blackColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(width: 1, color: AppColors.whiteColor),
                ),
                child: isButtonDisabled
                    ? Center(child: LoadingAnimationWidget.progressiveDots(color: AppColors.whiteColor, size: 30))
                    : Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Pay Now',
                              style: AppTextStyles.textSize16(context, weight: FontWeight.w600, color: Colors.white),
                            ),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward, color: Colors.white, size: 18),
                          ],
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
