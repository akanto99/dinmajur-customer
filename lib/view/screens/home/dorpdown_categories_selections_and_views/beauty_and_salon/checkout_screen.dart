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
import 'package:dinmajur_customer/model/home_models/dropdown_categories_selection_models/beauty_and_salon_model/get_bookedslot_model.dart';
import 'package:dinmajur_customer/model/home_models/dropdown_categories_selection_models/beauty_and_salon_model/getall_premium_home_beauty_salon_model.dart';
import 'package:dinmajur_customer/view/screens/home/dorpdown_categories_selections_and_views/beauty_and_salon/notifier/checkout_notifier.dart';
import 'package:dinmajur_customer/view/screens/home/helper_widgets/add_location_screen_widget/add_location_screen_widget.dart';
import 'package:dinmajur_customer/view_model/homeview_model/dropdown_categories_selection_view_models/beauty_and_salon_view_model/book_premium_home_beauty_salon_view_model.dart';
import 'package:dinmajur_customer/view_model/homeview_model/dropdown_categories_selection_view_models/beauty_and_salon_view_model/get_bookedslot_view_model.dart';
import 'package:dinmajur_customer/view_model/homeview_model/dropdown_categories_selection_view_models/beauty_and_salon_view_model/getall_premium_home_beauty_salon_view_model.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';

class CheckoutScreen extends StatefulWidget {
  final String customerName;
  final String customerPhone;
  final String customerAddress;
  final String userId;
  final List<Datum> categories;
  final Map<String, int> serviceQuantities;
  final double totalPrice;
  final double transportFee;
  final Function(String)? onAddressUpdate;
  final Map<String, dynamic>? customerLocation;

  const CheckoutScreen({
    Key? key,
    required this.customerName,
    required this.customerPhone,
    required this.customerAddress,
    required this.userId,
    required this.categories,
    required this.serviceQuantities,
    required this.totalPrice,
    required this.transportFee,
    required this.onAddressUpdate,
    this.customerLocation,
  }) : super(key: key);

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _specialRequestController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  bool _isTermsAccepted = false;
  Map<String, dynamic>? _updatedLocation;

  /// online payment lock
  final ValueNotifier<bool> _paymentLock = ValueNotifier(false);

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
    _fullNameController.text = widget.customerName;
    _phoneController.text = widget.customerPhone;
    _addressController.text = widget.customerAddress;
    _updatedLocation = widget.customerLocation;
    _restoreSessionLocation();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final checkoutVM = Provider.of<CheckoutBeautySalonViewModel>(context, listen: false);
      if (checkoutVM.selectedDate != null) {
        _dateController.text = DateFormat('MMMM dd, yyyy').format(checkoutVM.selectedDate!);
      }
    });
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
    _fullNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _specialRequestController.dispose();
    _dateController.dispose();
    _paymentLock.dispose();
    _scrollController.dispose();

    super.dispose();
  }

  Future<void> _handlePaymentResult({required CheckoutBeautySalonViewModel viewModel, required SSLPaymentResult paymentResult, required String trackingId}) async {
    if (!mounted) return;

    if (paymentResult.success) {
      _clearAllData();
      Navigator.pushReplacementNamed(context, RoutesName.beautyConfirmedScreen, arguments: {'trackingId': trackingId, 'valId': paymentResult.validationId ?? 'N/A', 'fromCheckout': true});
    } else if (paymentResult.status == 'FAILED') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
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
        }
      });
    } else if (paymentResult.status == 'CLOSED') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.pushReplacementNamed(
            context,
            RoutesName.beautyFailedCancelledPaymentScreen,
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
    final checkoutVM = Provider.of<CheckoutBeautySalonViewModel>(context, listen: false);
    checkoutVM.reset();

    _fullNameController.clear();
    _phoneController.clear();
    _addressController.clear();
    _specialRequestController.clear();
    _dateController.clear();
    setState(() {
      _isTermsAccepted = false;
    });
  }

  Future<void> _handleConfirmBooking() async {
    final checkoutVM = Provider.of<CheckoutBeautySalonViewModel>(context, listen: false);
    final bookingViewModel = Provider.of<PostBookPremiumHomeBeautySalonViewModel>(context, listen: false);

    final bookedSlotVM = Provider.of<GetBookedSlotViewModel>(context, listen: false);
    final List<BookedSlotDatum> slots = bookedSlotVM.getBookedSlotData.data?.data ?? [];
    final selectedSlot = slots.firstWhere((slot) => slot.time == checkoutVM.selectedServiceTime, orElse: () => BookedSlotDatum());
    final String timeSlotId = selectedSlot.id ?? '';

    if (bookingViewModel.createBookPremiumHomeBeautySalonLoading) return;

    double subtotal = checkoutVM.calculateTotal(serviceQuantities: widget.serviceQuantities, categories: widget.categories);
    double totalAmount = subtotal + widget.transportFee;

    // Validate form
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
    // Prepare tasks data
    List<Map<String, dynamic>> tasks = checkoutVM.prepareTasksData(serviceQuantities: widget.serviceQuantities, categories: widget.categories);

    // Prepare booking data
    Map<String, dynamic> bookingData = checkoutVM.prepareBookingData(
      userId: widget.userId,
      fullName: _fullNameController.text,
      customerLocation: _updatedLocation,
      phone: _phoneController.text,
      address: _updatedLocation?['fullAddress'] ?? _addressController.text,
      specialRequest: _specialRequestController.text,
      selectedDate: checkoutVM.selectedDate!,
      serviceTime: checkoutVM.selectedServiceTime!,
      timeSlot: timeSlotId,
      tasks: tasks,
      paymentMethod: checkoutVM.selectedPaymentMethod,
    );

    // print('Booking Data: $bookingData');

    try {
      // Call booking API
      await bookingViewModel.bookPremiumHomeBeautySalonPostApi(context, bookingData, (String? trackingId) async {
        // print('Success! TrackingId: $trackingId');

        if (trackingId == null || trackingId.isEmpty) {
          bookingViewModel.setBookPremiumHomeBeautySalonLoading(false);
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
            customerName: _fullNameController.text.trim(),
            customerPhone: _phoneController.text.trim(),
            customerEmail: null,
            customerAddress: _addressController.text.trim(),
          );
          await _handlePaymentResult(viewModel: checkoutVM, paymentResult: paymentResult, trackingId: trackingId);
          bookingViewModel.setBookPremiumHomeBeautySalonLoading(false);
        } else if (checkoutVM.selectedPaymentMethod == 'cash') {
          _clearAllData();
          Navigator.pop(context, {
            'cleared': true, // ✅ signal cart should clear
            'updatedLocation': _updatedLocation,
          });
          Navigator.pushNamed(context, RoutesName.beautyConfirmedScreen, arguments: {'trackingId': trackingId, 'valId': "COD", 'fromCheckout': true});
          bookingViewModel.setBookPremiumHomeBeautySalonLoading(false);
        } else {
          Navigator.pushReplacementNamed(
            context,
            RoutesName.failedOrderScreenWidget,
            arguments: {'trackingId': trackingId, 'valId': 'N/A', 'reason': 'Invalid payment method', 'errorMessage': 'The selected payment method is not available.'},
          );
        }
      });
    } catch (e) {
      bookingViewModel.setBookPremiumHomeBeautySalonLoading(false);
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

  @override
  Widget build(BuildContext context) {
    return Consumer2<CheckoutBeautySalonViewModel, PostBookPremiumHomeBeautySalonViewModel>(
      builder: (context, checkoutVM, bookingVM, _) {
        double subtotal = checkoutVM.calculateTotal(serviceQuantities: widget.serviceQuantities, categories: widget.categories);
        double total = subtotal + widget.transportFee;
        double saved = checkoutVM.calculateSaved(serviceQuantities: widget.serviceQuantities, categories: widget.categories);

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
                          _buildSelectedServicesList(checkoutVM, subtotal, saved),
                          SizedboxSpaccing.height02(context),
                          _buildPaymentMethodSection(checkoutVM),
                          SizedboxSpaccing.height01(context),
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
                  _buildConfirmButton(context, checkoutVM, bookingVM, total, saved),
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
        Text(
          value,
          style: AppTextStyles.textSize14(context, weight: FontWeight.w500, color: AppColors.subtitle(context)),
        ),
      ],
    );
  }

  Widget _buildDetailRow1(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('$label', style: AppTextStyles.textSize14(context, weight: FontWeight.w400)),
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

  Widget _buildPaymentMethodSection(CheckoutBeautySalonViewModel viewModel) {
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

  Widget _buildSelectedServicesList(CheckoutBeautySalonViewModel checkoutVM, double subtotal, double saved) {
    // Get all selected services from all categories
    List<Map<String, dynamic>> selectedServices = [];

    for (var category in widget.categories) {
      if (category.items != null) {
        for (var service in category.items!) {
          int qty = widget.serviceQuantities[service.id ?? ''] ?? 0;
          if (qty > 0) {
            selectedServices.add({'service': service, 'quantity': qty});
          }
        }
      }
    }

    if (selectedServices.isEmpty) {
      return SizedBox.shrink();
    }

    double total = subtotal + widget.transportFee;
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
              ...selectedServices.map((item) {
                Item service = item['service'];
                int quantity = item['quantity'];

                // Get prices from the service
                double originalPrice = service.originalPrice?.toDouble() ?? 0;
                double discountedPrice = service.salePrice?.toDouble() ?? originalPrice;

                // Total prices (multiplied by quantity)
                double totalOriginalPrice = originalPrice * quantity;
                double totalDiscountedPrice = discountedPrice * quantity;

                // Check if there's an actual discount
                bool hasDiscount = service.discountValue != null && originalPrice > discountedPrice && originalPrice > 0;

                return Container(
                  padding: EdgeInsets.only(bottom: screenHeight * 0.02),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text("${service.name ?? ''}($quantity)", style: AppTextStyles.textSize14(context, weight: FontWeight.w400), maxLines: null, softWrap: true),
                            ),
                            SizedBox(width: 8),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('৳${AmountFormatter.format(totalDiscountedPrice)}', style: AppTextStyles.textSize14(context, weight: FontWeight.w400)),
                                if (hasDiscount) ...[
                                  SizedboxSpaccing.width01(context),
                                  Text(
                                    '৳${AmountFormatter.format(totalOriginalPrice)}',
                                    style: AppTextStyles.textSize12(context, color: AppColors.subtitle(context)).copyWith(decoration: TextDecoration.lineThrough),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              _buildPriceRow('Subtotal', subtotal),
              SizedboxSpaccing.height02(context),
              _buildPriceRow('Transport', widget.transportFee),
              SizedboxSpaccing.height02(context),
              Divider(height: 1, color: AppColors.border(context)),
              SizedboxSpaccing.height02(context),
              _buildPriceRow('Total', total, isBold: true),
              SizedboxSpaccing.height02(context),
              Divider(height: 1, color: AppColors.border(context)),
              SizedboxSpaccing.height02(context),
              _buildDetailRow1('Date', DateFormat('MMMM dd, yyyy').format(checkoutVM.selectedDate ?? DateTime.now())),
              SizedboxSpaccing.height02(context),
              _buildDetailRow1('Slot', _formatTo12Hour(checkoutVM.selectedServiceTime ?? '')),
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

  Widget _buildConfirmButton(BuildContext context, CheckoutBeautySalonViewModel checkoutVM, PostBookPremiumHomeBeautySalonViewModel bookingVM, double total, double saved) {
    int totalItems = checkoutVM.getTotalItems(widget.serviceQuantities);

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
                Text('Total Services ($totalItems item${totalItems > 1 ? 's' : ''})', style: AppTextStyles.textSize12(context, color: AppColors.whiteColor)),
                SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '৳${AmountFormatter.format(total)}',
                      style: AppTextStyles.textSize18(context, weight: FontWeight.w600, color: AppColors.whiteColor),
                    ),
                    if (saved > 0) ...[
                      SizedBox(width: 8),
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
          ValueListenableBuilder<bool>(
            valueListenable: _paymentLock,
            builder: (context, isLocked, _) {
              final isButtonDisabled = bookingVM.createBookPremiumHomeBeautySalonLoading || isLocked;
              return AbsorbPointer(
                absorbing: isButtonDisabled,
                child: GestureDetector(
                  onTap: () {
                    if (_paymentLock.value) return;
                    _paymentLock.value = true;
                    _handleConfirmBooking().whenComplete(() {
                      _paymentLock.value = false;
                    });
                  },
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
                                SizedBox(width: 8),
                                Icon(Icons.arrow_forward, color: Colors.white, size: 18),
                              ],
                            ),
                          ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

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
