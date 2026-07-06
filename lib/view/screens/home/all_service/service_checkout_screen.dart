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
import 'package:dinmajur_customer/model/home_models/all_service_models/services_view_getallcategories_model.dart';
import 'package:dinmajur_customer/provider/cart/global_cart_provider.dart';
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
  //for dynamic STores
  final String? retailerId;

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
    //for dynamic Stores
    this.retailerId,
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

  // Red border validation
  bool _customerError = false;
  bool _paymentError = false;
  bool _termsError = false;
  final GlobalKey _customerKey = GlobalKey();
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
    _serviceQuantities = Map<String, int>.from(widget.serviceQuantities);
    _fullNameController.text = widget.customerName;
    _phoneController.text = widget.customerPhone;
    _addressController.text = widget.customerAddress;
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
    _scrollController.dispose();
    super.dispose();
  }

  // ── Payment result handler ──────────────────────────────────────────────

  Future<void> _handlePaymentResult({required CheckoutAllServicesViewModel viewModel, required SSLPaymentResult paymentResult, required String trackingId}) async {
    if (!mounted) return;

    if (paymentResult.success) {
      _clearAllData();
      _clearGlobalCart();
      Navigator.pushReplacementNamed(context, RoutesName.serviceConfirmedScreen, arguments: {'trackingId': trackingId, 'valId': paymentResult.validationId ?? 'N/A', 'fromCheckout': true});
    } else if (paymentResult.status == 'FAILED') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        Navigator.pushReplacementNamed(
          context,
          RoutesName.serviceFailedScreen,
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
          RoutesName.serviceFailedScreen,
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

  // Cleared directly here (rather than relying on the landing screen's
  // pop-result handling) because a successful online payment replaces this
  // route with the confirmation screen instead of popping back, so the
  // landing screen never gets a chance to clear its cart entry.
  void _clearGlobalCart() {
    Provider.of<GlobalCartProvider>(context, listen: false).clearService(widget.serviceId);
  }

  // ── Main booking handler ────────────────────────────────────────────────

  Future<void> _handleConfirmBooking() async {
    final checkoutVM = Provider.of<CheckoutAllServicesViewModel>(context, listen: false);
    final bookingViewModel = Provider.of<BookServiceViewModel>(context, listen: false);

    if (bookingViewModel.createBookServiceLoading) {
      return;
    }

    // ── Validate checkout fields ──
    final String currentAddress = _addressController.text.isEmpty ? widget.customerAddress : _addressController.text;
    final bool newCustomerError = widget.customerName.isEmpty || widget.customerPhone.isEmpty || currentAddress.isEmpty;
    final bool newPaymentError = (checkoutVM.selectedPaymentMethod ?? '').isEmpty;
    final bool newTermsError = !_isTermsAccepted;

    if (newCustomerError || newPaymentError || newTermsError) {
      setState(() {
        _customerError = newCustomerError;
        _paymentError = newPaymentError;
        _termsError = newTermsError;
      });
      if (newCustomerError) _scrollToKey(_customerKey);
      else if (newPaymentError) _scrollToKey(_paymentKey);
      else _scrollToKey(_termsKey);
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

    // ── Amounts ──
    final double subtotal = checkoutVM.calculateTotal(serviceQuantities: _serviceQuantities, categories: widget.categories);
    final double totalAmount = subtotal + widget.transportFee;

    // ── Build payload ──
    final List<Map<String, dynamic>> tasks = checkoutVM.prepareTasksData(serviceQuantities: _serviceQuantities, categories: widget.categories);

    final Map<String, dynamic> bookingData = checkoutVM.prepareBookingData(
      retailerId: (widget.retailerId?.isNotEmpty == true) ? widget.retailerId : null,
      serviceId: widget.serviceId,
      customerId: widget.userId,
      paymentMethod: checkoutVM.selectedPaymentMethod,
      address: _updatedLocation?['fullAddress'] ?? _addressController.text,
      fullName: _fullNameController.text,
      phone: _phoneController.text,
      email: "",
      specialRequest: _specialRequestController.text,
      selectedDate: checkoutVM.selectedDate.toString(),
      timeSlotId: timeSlotId,
      platform: "app",

      customerLocation: _updatedLocation,
      tasks: tasks,
    );


    try {
      await bookingViewModel.bookServicePostApi(context, bookingData, (String? trackingId) async {

        if (trackingId == null || trackingId.isEmpty) {
          bookingViewModel.setBookServiceLoading(false);
          if (!mounted) return;
          Navigator.pushReplacementNamed(
            context,
            RoutesName.serviceFailedScreen,
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
          bookingViewModel.setBookServiceLoading(false);
        } else if (checkoutVM.selectedPaymentMethod == 'cash') {
          if (!mounted) return;
          _clearAllData();
          _clearGlobalCart();
          Navigator.pop(context, {'cleared': true, 'updatedLocation': _updatedLocation});
          Navigator.pushNamed(context, RoutesName.serviceConfirmedScreen, arguments: {'trackingId': trackingId, 'valId': 'COD', 'fromCheckout': true});
          bookingViewModel.setBookServiceLoading(false);
        } else {
          bookingViewModel.setBookServiceLoading(false);
          if (!mounted) return;
          Navigator.pushReplacementNamed(
            context,
            RoutesName.serviceFailedScreen,
            arguments: {'trackingId': trackingId, 'valId': 'N/A', 'reason': 'Invalid payment method', 'errorMessage': 'The selected payment method is not available.'},
          );
        }
      });
    } catch (e) {
      bookingViewModel.setBookServiceLoading(false);
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
                  // Text(widget.serviceId),
                  // Text(widget.retailerId??""),
                  GestureDetector(
                    onTap: () => Navigator.pop(context, false),
                    child: Container(height: 60, child: AppBarHeader("Checkout")),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildCustomerDetailsCard(),
                          SizedboxSpaccing.height02(context),
                          _buildSelectedServicesList(checkoutVM, subtotal, saved),
                          SizedboxSpaccing.height02(context),
                          _buildAddOnsSection(),
                          SizedboxSpaccing.height02(context),
                          _buildPaymentMethodSection(checkoutVM),

                          AnimatedContainer(
                            key: _termsKey,
                            duration: const Duration(milliseconds: 300),
                            decoration: _termsError
                                ? BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.red, width: 1.5),
                                  )
                                : const BoxDecoration(),
                            child: DynamicTermsCheckbox(
                              isAccepted: _isTermsAccepted,
                              onChanged: (value) => setState(() {
                                _isTermsAccepted = value;
                                if (value) _termsError = false;
                              }),
                              context: context,
                              onTermsTap: () => Navigator.pushNamed(context, RoutesName.termsAndCondition),
                              onPrivacyTap: () => Navigator.pushNamed(context, RoutesName.privacyPolicy),
                              onRefundTap: () => Navigator.pushNamed(context, RoutesName.refundPolicyScreen),
                              getButtonColor: (ctx) => AppColors.button(ctx),
                              getBorderColor: (ctx) => _termsError ? Colors.red : AppColors.border(ctx),
                              getWhiteColor: (ctx) => AppColors.whiteColor,
                              getTextStyle: (ctx, {weight}) => AppTextStyles.textSize14(ctx, weight: weight ?? FontWeight.w400),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedContainer(
          key: _customerKey,
          duration: const Duration(milliseconds: 300),
          padding: EdgeInsets.all(screenHeight * 0.015),
          decoration: BoxDecoration(
            color: AppColors.containerBackground(context),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _customerError ? Colors.red : AppColors.border(context), width: _customerError ? 1.5 : 1.0),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Customer Details', style: AppTextStyles.textSize14(context, weight: FontWeight.w500, color: _customerError ? Colors.red : null)),
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
        ),
        if (_customerError)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 4),
            child: Text('Please fill in all customer details', style: AppTextStyles.textSize12(context, color: Colors.red)),
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
                          Text('৳${AmountFormatter.format(totalSale)}', style: AppTextStyles.textSize14(context, weight: FontWeight.w400)),
                          if (hasDiscount)
                            Text(
                              '৳${AmountFormatter.format(totalBase)}',
                              style: AppTextStyles.textSize12(context, color: AppColors.subtitle(context)).copyWith(decoration: TextDecoration.lineThrough),
                            ),
                        ],
                      ),
                    ],
                  ),
                );
              }).toList(),

              _buildPriceRow('Subtotal', subtotal),
              if (widget.transportFee > 0) ...[
                SizedboxSpaccing.height02(context),
                _buildPriceRow('Transport', widget.transportFee),
              ],
              SizedboxSpaccing.height02(context),
              Divider(height: 1, color: AppColors.border(context)),
              SizedboxSpaccing.height02(context),
              _buildPriceRow('Total', subtotal + widget.transportFee, isBold: true),
              SizedboxSpaccing.height02(context),
              Divider(height: 1, color: AppColors.border(context)),
              SizedboxSpaccing.height02(context),

              // ✅ Date — from checkoutVM.selectedDate (set when user picked in dialog)
              _buildDetailRow1('Date', checkoutVM.selectedDate != null ? DateFormat('MMMM dd, yyyy').format(checkoutVM.selectedDate!) : '—'),
              SizedboxSpaccing.height02(context),

              // ✅ Slot — from checkoutVM.selectedServiceTime (the display "09:00")
              _buildDetailRow1('Slot', checkoutVM.selectedServiceTime != null && checkoutVM.selectedServiceTime!.isNotEmpty ? _formatTo12Hour(checkoutVM.selectedServiceTime!) : '—'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPriceRow(String label, double amount, {bool isGreen = false, bool isBold = false}) {
    final weight = isBold ? FontWeight.w700 : FontWeight.w400;
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

  // ── Add-ons ───────────────────────────────────────────────────────────────

  List<Task> _getAddOnTasks() {
    final addOns = <Task>[];
    for (final cat in widget.categories) {
      for (final task in (cat.tasks ?? [])) {
        if ((_serviceQuantities[task.id ?? ''] ?? 0) == 0) {
          addOns.add(task);
        }
      }
    }
    return addOns;
  }

  Widget _buildAddOnsSection() {
    final allTasks = <Task>[];
    for (final cat in widget.categories) {
      allTasks.addAll(cat.tasks ?? []);
    }
    if (allTasks.isEmpty) return const SizedBox.shrink();

    final addedCount = _serviceQuantities.values.where((q) => q > 0).length;
    final available = _getAddOnTasks().length;

    return GestureDetector(
      onTap: _showAddOnsSheet,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: AppColors.containerBackground(context),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border(context)),
        ),
        child: Row(
          children: [
            Icon(Icons.add_circle_outline, size: 20, color: AppColors.button(context)),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Add-ons', style: AppTextStyles.textSize14(context, weight: FontWeight.w600)),
                  Text(
                    available > 0
                        ? '$available task${available > 1 ? 's' : ''} available'
                        : 'All tasks added',
                    style: AppTextStyles.textSize12(context, color: AppColors.subtitle(context)),
                  ),
                ],
              ),
            ),
            if (addedCount > 0)
              Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.button(context),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  '+$addedCount added',
                  style: AppTextStyles.textSize11(context, color: AppColors.whiteColor, weight: FontWeight.w600),
                ),
              ),
            Icon(Icons.chevron_right, size: 20, color: AppColors.subtitle(context)),
          ],
        ),
      ),
    );
  }

  void _showAddOnsSheet() {
    final allTasks = <Task>[];
    for (final cat in widget.categories) {
      allTasks.addAll(cat.tasks ?? []);
    }
    if (allTasks.isEmpty) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          return Container(
            constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.75),
            decoration: BoxDecoration(
              color: AppColors.containerBackground(context),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border(context),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: Row(
                    children: [
                      Expanded(child: Text('Add-ons', style: AppTextStyles.textSize18(context, weight: FontWeight.w600))),
                      GestureDetector(
                        onTap: () => Navigator.pop(ctx),
                        child: Icon(Icons.close, size: 22, color: AppColors.subtitle(context)),
                      ),
                    ],
                  ),
                ),
                Divider(height: 1, color: AppColors.border(context)),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: allTasks.length,
                    separatorBuilder: (_, __) => Divider(height: 1, color: AppColors.border(context)),
                    itemBuilder: (_, i) {
                      final task = allTasks[i];
                      final taskId = task.id ?? '';
                      final qty = _serviceQuantities[taskId] ?? 0;
                      final salePrice = task.price?.salePrice?.toDouble() ?? task.price?.basePrice?.toDouble() ?? 0;
                      final basePrice = task.price?.basePrice?.toDouble() ?? 0;
                      final hasDiscount = basePrice > salePrice && salePrice > 0;

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    task.name ?? '',
                                    style: AppTextStyles.textSize14(context, weight: FontWeight.w500),
                                  ),
                                  const SizedBox(height: 3),
                                  Row(
                                    children: [
                                      Text(
                                        '৳${salePrice.toStringAsFixed(0)}',
                                        style: AppTextStyles.textSize13(context, weight: FontWeight.w600, color: AppColors.button(context)),
                                      ),
                                      if (hasDiscount) ...[
                                        const SizedBox(width: 6),
                                        Text(
                                          '৳${basePrice.toStringAsFixed(0)}',
                                          style: AppTextStyles.textSize12(context, color: AppColors.subtitle(context))
                                              .copyWith(decoration: TextDecoration.lineThrough),
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            if (qty == 0)
                              GestureDetector(
                                onTap: () {
                                  setState(() => _serviceQuantities[taskId] = 1);
                                  setSheetState(() {});
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                                  decoration: BoxDecoration(
                                    color: AppColors.button(context),
                                    borderRadius: BorderRadius.circular(100),
                                  ),
                                  child: Text('+ Add', style: AppTextStyles.textSize12(context, weight: FontWeight.w600, color: AppColors.whiteColor)),
                                ),
                              )
                            else
                              Row(
                                children: [
                                  _sheetQtyBtn(ctx, Icons.remove, () {
                                    setState(() {
                                      final next = (_serviceQuantities[taskId] ?? 1) - 1;
                                      if (next <= 0) {
                                        _serviceQuantities.remove(taskId);
                                      } else {
                                        _serviceQuantities[taskId] = next;
                                      }
                                    });
                                    setSheetState(() {});
                                  }),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 12),
                                    child: Text('$qty', style: AppTextStyles.textSize14(context, weight: FontWeight.w700)),
                                  ),
                                  _sheetQtyBtn(ctx, Icons.add, () {
                                    setState(() => _serviceQuantities[taskId] = ((_serviceQuantities[taskId] ?? 0) + 1));
                                    setSheetState(() {});
                                  }),
                                ],
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(16, 8, 16, MediaQuery.of(context).viewInsets.bottom + 16),
                  child: GestureDetector(
                    onTap: () => Navigator.pop(ctx),
                    child: Container(
                      width: double.infinity,
                      height: 50,
                      decoration: BoxDecoration(color: AppColors.button(context), borderRadius: BorderRadius.circular(100)),
                      child: Center(child: Text('Done', style: AppTextStyles.textSize16(context, weight: FontWeight.w600, color: AppColors.whiteColor))),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _sheetQtyBtn(BuildContext context, IconData icon, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border(context)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: AppColors.textPrimary(context)),
        ),
      );

  // ── Payment method ────────────────────────────────────────────────────────

  Widget _buildPaymentMethodSection(CheckoutAllServicesViewModel viewModel) {
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
              ? BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.red, width: 1.5),
                )
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
                      '৳${AmountFormatter.format(total)}',
                      style: AppTextStyles.textSize18(context, weight: FontWeight.w600, color: AppColors.whiteColor),
                    ),
                    if (saved > 0) ...[
                      const SizedBox(width: 8),
                      Text(
                        'Saved ৳${AmountFormatter.format(saved)}',
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
