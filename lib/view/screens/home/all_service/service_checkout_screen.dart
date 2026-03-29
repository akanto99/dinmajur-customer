import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/components/header_appbar.dart';
import 'package:dinmajur_customer/configs/res/components/iagree_terms&condition/iagree_terms&condition.dart';
import 'package:dinmajur_customer/configs/res/components/payment_method/payment_method_component.dart';
import 'package:dinmajur_customer/configs/res/components/section_header/section_header.dart';
import 'package:dinmajur_customer/configs/res/sizedbox_spaccing.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:dinmajur_customer/configs/services/ssl_payment_service/ssl_payment.dart';
import 'package:dinmajur_customer/configs/utils/routes/routes_name.dart';
import 'package:dinmajur_customer/configs/utils/utils.dart';
import 'package:dinmajur_customer/model/home_models/all_service_models/services_view_getallcategories_model.dart';
import 'package:dinmajur_customer/view/screens/home/helper_widgets/add_location_screen_widget/add_location_screen_widget.dart';
import 'package:dinmajur_customer/view_model/homeview_model/all_service_view_models/book_service_view_model.dart';
import 'package:dinmajur_customer/view_model/homeview_model/all_service_view_models/checkout_view_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';

class ServiceCheckoutScreen extends StatefulWidget {
  final String customerName;
  final String customerPhone;
  final String customerAddress;
  final String userId;
  final String serviceId;
  final List<Category> categories;
  final Map<String, int> serviceQuantities;
  final double totalPrice;
  final double transportFee;
  final Function(String)? onAddressUpdate;
  final Map<String, dynamic>? customerLocation;

  const ServiceCheckoutScreen({
    Key? key,
    required this.customerName,
    required this.customerPhone,
    required this.customerAddress,
    required this.userId,
    required this.serviceId,
    required this.categories,
    required this.serviceQuantities,
    required this.totalPrice,
    required this.transportFee,
    required this.onAddressUpdate,
    this.customerLocation,
  }) : super(key: key);

  @override
  State<ServiceCheckoutScreen> createState() => _ServiceCheckoutScreenState();
}

class _ServiceCheckoutScreenState extends State<ServiceCheckoutScreen> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _specialRequestController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  bool _isTermsAccepted = false;
  Map<String, dynamic>? _updatedLocation;
  late Map<String, int> _serviceQuantities;

  @override
  void initState() {
    super.initState();
    _serviceQuantities = Map<String, int>.from(widget.serviceQuantities);
    _fullNameController.text = widget.customerName;
    _phoneController.text = widget.customerPhone;
    _addressController.text = widget.customerAddress;
    _updatedLocation = widget.customerLocation;

    _restoreSessionLocation();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final checkoutVM = Provider.of<CheckoutAllServicesViewModel>(context, listen: false);
      if (checkoutVM.selectedDate != null) {
        _dateController.text = DateFormat('MMMM dd, yyyy').format(checkoutVM.selectedDate!);
      }
    });
  }

  Future<void> _restoreSessionLocation() async {
    final sessionData = await CheckoutSessionLocationService.getAll();
    if (sessionData.location != null && sessionData.address != null && mounted) {
      setState(() {
        _updatedLocation = sessionData.location;
        _addressController.text = sessionData.address!;
      });
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _specialRequestController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  // ── Payment result handler ──────────────────────────────────────────────

  Future<void> _handlePaymentResult({required CheckoutAllServicesViewModel viewModel, required SSLPaymentResult paymentResult, required String trackingId}) async {
    if (!mounted) return;

    if (paymentResult.success) {
      _clearAllData();
      Navigator.pushReplacementNamed(context, RoutesName.beautyConfirmedScreen, arguments: {'trackingId': trackingId, 'valId': paymentResult.validationId ?? 'N/A'});
    } else if (paymentResult.status == 'FAILED') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        Navigator.pushReplacementNamed(
          context,
          RoutesName.beautyFailedCancelledPaymentScreen,
          arguments: {
            'trackingId': trackingId,
            'valId': paymentResult.validationId ?? 'N/A',
            'reason': 'Payment transaction failed',
            'errorMessage': paymentResult.errorMessage ?? 'The payment could not be completed. Please try again.',
            'isCancelled': false,
          },
        );
      });
    } else if (paymentResult.status == 'CLOSED') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        Navigator.pushReplacementNamed(
          context,
          RoutesName.beautyFailedCancelledPaymentScreen,
          arguments: {
            'trackingId': trackingId,
            'valId': paymentResult.validationId ?? 'N/A',
            'reason': 'Payment cancelled by user',
            'errorMessage': "You cancelled the payment. You can retry whenever you're ready.",
            'isCancelled': true,
          },
        );
      });
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        Utils.flushBarErrorMessage(paymentResult.errorMessage ?? "Payment status unclear", context);
      });
    }
  }

  void _clearAllData() {
    final checkoutVM = Provider.of<CheckoutAllServicesViewModel>(context, listen: false);
    checkoutVM.reset();
    _fullNameController.clear();
    _phoneController.clear();
    _addressController.clear();
    _specialRequestController.clear();
    _dateController.clear();
    setState(() => _isTermsAccepted = false);
  }

  // ── Main booking handler ────────────────────────────────────────────────

  Future<void> _handleConfirmBooking() async {
    final checkoutVM = Provider.of<CheckoutAllServicesViewModel>(context, listen: false);
    final bookingViewModel = Provider.of<BookServiceViewModel>(context, listen: false);

    if (bookingViewModel.createBookServiceLoading) {
      debugPrint('⚠️ Already processing, ignoring duplicate tap');
      return;
    }

    // ── Validate checkout fields ──
    final String? validationError = checkoutVM.validateCheckoutDetails(
      fullName: _fullNameController.text,
      phone: _phoneController.text,
      address: _addressController.text,
      paymentMethod: checkoutVM.selectedPaymentMethod,
    );
    if (validationError != null) {
      Utils.flushBarErrorMessage(validationError, context);
      return;
    }

    if (!_isTermsAccepted) {
      Utils.flushBarErrorMessage("Please accept the Terms & Conditions to proceed", context);
      return;
    }

    // ── Validate date + slot ──
    final String? cartError = checkoutVM.validateCartForm(selectedDate: checkoutVM.selectedDate, serviceTime: checkoutVM.selectedServiceTime);
    if (cartError != null) {
      Utils.flushBarErrorMessage(cartError, context);
      return;
    }

    // ✅ Use the stored slot _id directly — no list lookup needed
    final String timeSlotId = checkoutVM.selectedTimeSlotId ?? '';
    if (timeSlotId.isEmpty) {
      Utils.flushBarErrorMessage("Please select a time slot", context);
      return;
    }

    // ── Amounts ──
    final double subtotal = checkoutVM.calculateTotal(serviceQuantities: _serviceQuantities, categories: widget.categories);
    final double totalAmount = subtotal + widget.transportFee;

    // ── Build payload ──
    final List<Map<String, dynamic>> tasks = checkoutVM.prepareTasksData(serviceQuantities: _serviceQuantities, categories: widget.categories);

    // ✅ Only timeSlotId goes to the API — no date/serviceTime strings
    final Map<String, dynamic> bookingData = checkoutVM.prepareBookingData(
      userId: widget.userId,
      fullName: _fullNameController.text,
      phone: _phoneController.text,
      customerLocation: _updatedLocation,
      address: _updatedLocation?['fullAddress'] ?? _addressController.text,
      specialRequest: _specialRequestController.text,
      timeSlotId: timeSlotId,
      tasks: tasks,
      paymentMethod: checkoutVM.selectedPaymentMethod,
    );

    debugPrint('📦 Booking Data: $bookingData');

    try {
      await bookingViewModel.bookServicePostApi(context, bookingData, (String? trackingId) async {
        debugPrint('✅ Booking Success! TrackingId: $trackingId');

        if (trackingId == null || trackingId.isEmpty) {
          if (!mounted) return;
          Navigator.pushReplacementNamed(
            context,
            RoutesName.failedOrderScreenWidget,
            arguments: {'trackingId': 'N/A', 'valId': 'N/A', 'reason': 'Booking creation failed', 'errorMessage': 'Unable to create booking. Please try again.'},
          );
          return;
        }

        if (checkoutVM.selectedPaymentMethod == 'online') {
          final SSLPaymentResult paymentResult = await checkoutVM.initiatePayment(
            trackingId: trackingId,
            totalAmount: totalAmount,
            customerName: _fullNameController.text.trim(),
            customerPhone: _phoneController.text.trim(),
            customerEmail: null,
            customerAddress: _addressController.text.trim(),
          );
          await _handlePaymentResult(viewModel: checkoutVM, paymentResult: paymentResult, trackingId: trackingId);
        } else if (checkoutVM.selectedPaymentMethod == 'cash') {
          if (!mounted) return;
          _clearAllData();
          Navigator.pop(context, {'cleared': true, 'updatedLocation': _updatedLocation});
          Navigator.pushNamed(context, RoutesName.beautyConfirmedScreen, arguments: {'trackingId': trackingId, 'valId': 'COD'});
        } else {
          if (!mounted) return;
          Navigator.pushReplacementNamed(
            context,
            RoutesName.failedOrderScreenWidget,
            arguments: {'trackingId': trackingId, 'valId': 'N/A', 'reason': 'Invalid payment method', 'errorMessage': 'The selected payment method is not available.'},
          );
        }
      });
    } catch (e) {
      debugPrint('❌ Booking error: $e');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        Navigator.pushReplacementNamed(
          context,
          RoutesName.failedOrderScreenWidget,
          arguments: {'trackingId': 'N/A', 'valId': 'N/A', 'reason': 'Booking failed', 'errorMessage': 'An error occurred while processing your booking. Please try again.'},
        );
      });
    }
  }

  // ── Edit address ──────────────────────────────────────────────────────────

  Future<void> _handleEditAddress() async {
    final result = await Navigator.pushNamed(context, RoutesName.addLocationScreenWidget);
    if (result != null && result is Map<String, dynamic>) {
      final String newAddress = result['fullAddress'] ?? '';
      if (newAddress.isNotEmpty) {
        setState(() {
          _addressController.text = newAddress;
          if (result['location'] != null) {
            _updatedLocation = result['location'] as Map<String, dynamic>;
          }
        });
        widget.onAddressUpdate?.call(newAddress);
      }
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Consumer2<CheckoutAllServicesViewModel, BookServiceViewModel>(
      builder: (context, checkoutVM, bookingVM, _) {
        final double subtotal = checkoutVM.calculateTotal(serviceQuantities: _serviceQuantities, categories: widget.categories);
        final double total = subtotal + widget.transportFee;
        final double saved = checkoutVM.calculateSaved(serviceQuantities: _serviceQuantities, categories: widget.categories);

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
                      padding: const EdgeInsets.all(15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildCustomerDetailsCard(),
                          SizedboxSpaccing.height02(context),
                          // ✅ passes checkoutVM so date+slot are read from it
                          _buildSelectedServicesList(checkoutVM, subtotal, saved),
                          SizedboxSpaccing.height02(context),
                          _buildPaymentMethodSection(checkoutVM),
                          SizedboxSpaccing.height01(context),
                          DynamicTermsCheckbox(
                            isAccepted: _isTermsAccepted,
                            onChanged: (value) => setState(() => _isTermsAccepted = value),
                            context: context,
                            onTermsTap: () => Navigator.pushNamed(context, RoutesName.termsAndCondition),
                            onPrivacyTap: () => Navigator.pushNamed(context, RoutesName.privacyPolicy),
                            onRefundTap: () => Navigator.pushNamed(context, RoutesName.refundPolicyScreen),
                            getButtonColor: (ctx) => AppColors.button(ctx),
                            getBorderColor: (ctx) => AppColors.border(ctx),
                            getWhiteColor: (ctx) => AppColors.whiteColor,
                            getTextStyle: (ctx, {weight}) => AppTextStyles.textSize14(ctx, weight: weight ?? FontWeight.w400),
                          ),
                          SizedboxSpaccing.height03(context),
                        ],
                      ),
                    ),
                  ),
                  _buildConfirmButton(context, checkoutVM, bookingVM, total, saved),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ── Customer details card ─────────────────────────────────────────────────

  Widget _buildCustomerDetailsCard() {
    final screenHeight = MediaQuery.of(context).size.height;
    return Container(
      padding: EdgeInsets.all(screenHeight * 0.015),
      decoration: BoxDecoration(
        color: AppColors.containerBackground(context),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Customer Details', style: AppTextStyles.textSize14(context, weight: FontWeight.w500)),
              GestureDetector(
                onTap: _handleEditAddress,
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
        Flexible(
          child: Text(
            value,
            style: AppTextStyles.textSize14(context, weight: FontWeight.w500, color: AppColors.subtitle(context)),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow1(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.textSize14(context, weight: FontWeight.w400)),
        Expanded(
          child: Text(
            value,
            style: AppTextStyles.textSize14(context, weight: FontWeight.w400),
            textAlign: TextAlign.end,
            maxLines: null,
            softWrap: true,
          ),
        ),
      ],
    );
  }

  // ── Booking summary ───────────────────────────────────────────────────────

  Widget _buildSelectedServicesList(CheckoutAllServicesViewModel checkoutVM, double subtotal, double saved) {
    final List<Map<String, dynamic>> selectedTasks = [];
    for (final cat in widget.categories) {
      for (final task in (cat.tasks ?? [])) {
        final int qty = _serviceQuantities[task.id ?? ''] ?? 0;
        if (qty > 0) selectedTasks.add({'task': task, 'quantity': qty});
      }
    }

    if (selectedTasks.isEmpty) return const SizedBox.shrink();

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

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
              // ── Task rows ──
              ...selectedTasks.map((item) {
                final Task task = item['task'] as Task;
                final int quantity = item['quantity'] as int;

                final double basePrice = task.price?.basePrice?.toDouble() ?? 0;
                final double salePrice = task.price?.salePrice?.toDouble() ?? basePrice;
                final bool hasDiscount = task.price?.discountType != DiscountType.NONE && basePrice > salePrice;

                final double totalSale = salePrice * quantity;
                final double totalBase = basePrice * quantity;

                return Padding(
                  padding: EdgeInsets.only(bottom: screenHeight * 0.015),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text('${task.name ?? ''}  ×$quantity', style: AppTextStyles.textSize14(context, weight: FontWeight.w400), maxLines: null, softWrap: true),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('৳${totalSale.toStringAsFixed(2)}', style: AppTextStyles.textSize14(context, weight: FontWeight.w400)),
                          if (hasDiscount)
                            Text(
                              '৳${totalBase.toStringAsFixed(2)}',
                              style: AppTextStyles.textSize12(context, color: AppColors.subtitle(context)).copyWith(decoration: TextDecoration.lineThrough),
                            ),
                        ],
                      ),
                    ],
                  ),
                );
              }).toList(),

              // ✅ Date — from checkoutVM.selectedDate (set when user picked in dialog)
              _buildDetailRow1('Date', checkoutVM.selectedDate != null ? DateFormat('MMMM dd, yyyy').format(checkoutVM.selectedDate!) : '—'),
              SizedboxSpaccing.height02(context),

              // ✅ Slot — from checkoutVM.selectedServiceTime (the display "09:00")
              _buildDetailRow1('Slot', checkoutVM.selectedServiceTime != null && checkoutVM.selectedServiceTime!.isNotEmpty ? _formatTo12Hour(checkoutVM.selectedServiceTime!) : '—'),
              SizedboxSpaccing.height02(context),

              _buildPriceRow('Transport', widget.transportFee),
              SizedboxSpaccing.height02(context),
              _buildPriceRow('Subtotal', subtotal),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPriceRow(String label, double amount, {bool isGreen = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.textSize14(context, weight: FontWeight.w400)),
        Text(
          '৳${amount.toStringAsFixed(2)}',
          style: AppTextStyles.textSize14(context, weight: FontWeight.w400, color: isGreen ? Colors.green : AppColors.textPrimary(context)),
        ),
      ],
    );
  }

  // ── Payment method ────────────────────────────────────────────────────────

  Widget _buildPaymentMethodSection(CheckoutAllServicesViewModel viewModel) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Column(
      children: [
        SectionHeader(title: 'Payment Method', titleWidth: screenWidth * 0.6, showSeeAll: false),
        SizedboxSpaccing.height02(context),
        PaymentMethodWidget(selectedPaymentMethod: viewModel.selectedPaymentMethod, paymentMethods: viewModel.paymentMethods, onPaymentMethodChanged: (method) => viewModel.setPaymentMethod(method)),
      ],
    );
  }

  // ── Confirm / Pay button ──────────────────────────────────────────────────

  Widget _buildConfirmButton(BuildContext context, CheckoutAllServicesViewModel checkoutVM, BookServiceViewModel bookingVM, double total, double saved) {
    final int totalItems = checkoutVM.getTotalItems(_serviceQuantities);
    final bool isButtonDisabled = bookingVM.createBookServiceLoading;

    return Container(
      padding: const EdgeInsets.all(15),
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
                Text('Total Services ($totalItems item${totalItems > 1 ? 's' : ''})', style: AppTextStyles.textSize12(context, color: AppColors.whiteColor)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '৳${total.toStringAsFixed(2)}',
                      style: AppTextStyles.textSize18(context, weight: FontWeight.w600, color: AppColors.whiteColor),
                    ),
                    if (saved > 0) ...[
                      const SizedBox(width: 8),
                      Text(
                        'Saved ৳${saved.toStringAsFixed(2)}',
                        style: AppTextStyles.textSize12(context, color: Colors.green, weight: FontWeight.w500),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          AbsorbPointer(
            absorbing: isButtonDisabled,
            child: GestureDetector(
              onTap: _handleConfirmBooking,
              child: Container(
                height: 40,
                width: 140,
                decoration: BoxDecoration(
                  color: isButtonDisabled ? AppColors.blackColor.withOpacity(0.5) : AppColors.blackColor,
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
                            const SizedBox(width: 8),
                            const Icon(Icons.arrow_forward, color: Colors.white, size: 18),
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

// ── Helper ────────────────────────────────────────────────────────────────────

String _formatTo12Hour(String time) {
  if (time.isEmpty) return time;
  try {
    final parts = time.split(':');
    int hour = int.parse(parts[0]);
    final String minute = parts.length > 1 ? parts[1] : '00';
    final String period = hour >= 12 ? 'PM' : 'AM';
    if (hour == 0)
      hour = 12;
    else if (hour > 12)
      hour -= 12;
    return '$hour:$minute $period';
  } catch (_) {
    return time;
  }
}
