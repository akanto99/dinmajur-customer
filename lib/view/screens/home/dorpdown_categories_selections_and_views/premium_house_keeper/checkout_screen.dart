import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/components/header_appbar.dart';
import 'package:dinmajur_customer/configs/res/components/iagree_terms&condition/iagree_terms&condition.dart';
import 'package:dinmajur_customer/configs/res/components/payment_method/payment_method_component.dart';
import 'package:dinmajur_customer/configs/res/components/section_header/section_header.dart';
import 'package:dinmajur_customer/configs/res/sizedbox_spaccing.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:dinmajur_customer/configs/responsive/responsive_ui.dart';
import 'package:dinmajur_customer/configs/services/ssl_payment_service/ssl_payment.dart';
import 'package:dinmajur_customer/configs/utils/amount_formatter/amount_formatter.dart';
import 'package:dinmajur_customer/configs/utils/routes/routes_name.dart';
import 'package:dinmajur_customer/configs/utils/utils.dart';
import 'package:dinmajur_customer/model/home_models/dropdown_categories_selection_models/premium_house_keeper_model/getall_premium_house_keeper_task_model.dart';
import 'package:dinmajur_customer/provider/cart/global_cart_provider.dart';
import 'package:dinmajur_customer/view/screens/home/dorpdown_categories_selections_and_views/premium_house_keeper/notifier/checkout_notifier.dart';
import 'package:dinmajur_customer/view/screens/home/helper_widgets/add_location_screen_widget/add_location_screen_widget.dart';
import 'package:dinmajur_customer/view_model/homeview_model/dropdown_categories_selection_view_models/premium_house_keeper_view_model/book_premium_house_keeper_view_model.dart';
import 'package:dinmajur_customer/view_model/homeview_model/dropdown_categories_selection_view_models/premium_house_keeper_view_model/getall_shifttime_view_model.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';

class CheckoutHouseKeeperScreen extends StatefulWidget {
  final Map<String, int> serviceQuantities;
  final Map<String, Set<String>> selectedTaskItems;
  final String selectedFrequency;
  final String selectedDate;
  final String selectedTime;
  final String customerName;
  final String customerPhone;
  final String customerAddress;
  final VoidCallback onSuccess;
  final Function(String)? onAddressUpdate;
  final double transportFee;
  final List<Datum> allServices;
    final Map<String, dynamic>? customerLocation;
  /// Global-cart key for this service — used to remove the cart entry once
  /// the booking is confirmed.
  final String serviceName;


  const CheckoutHouseKeeperScreen({
    Key? key,
    required this.serviceQuantities,
    required this.selectedTaskItems,
    required this.selectedFrequency,
    required this.selectedDate,
    required this.selectedTime,
    required this.customerName,
    required this.customerPhone,
    required this.customerAddress,
    required this.onSuccess,
    this.onAddressUpdate,
    required this.transportFee,
    required this.allServices,
        this.customerLocation,
    required this.serviceName,

  }) : super(key: key);

  @override
  State<CheckoutHouseKeeperScreen> createState() => _CheckoutHouseKeeperScreenState();
}

class _CheckoutHouseKeeperScreenState extends State<CheckoutHouseKeeperScreen> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _specialRequestController = TextEditingController();
  bool _isTermsAccepted = false;
  Map<String, dynamic>? _updatedLocation;

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
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _handlePaymentResult({
    required CheckoutViewModel viewModel,
    required SSLPaymentResult paymentResult,
    required String trackingId
  }) async {
    if (!mounted) return;

    if (paymentResult.success) {
      _clearAllData();
      _clearGlobalCart();
      Navigator.pushReplacementNamed(
        context,
        RoutesName.confirmedScreen,
        arguments: {
          'trackingId': trackingId,
          'valId': paymentResult.validationId ?? 'N/A',
          'fromCheckout': true,
        },
      );
    } else if (paymentResult.status == 'FAILED') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.pushReplacementNamed(
            context,
            RoutesName.failedCancelledPaymentScreen,
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
            RoutesName.failedCancelledPaymentScreen,
            arguments: {
              'trackingId': trackingId,
              'valId': paymentResult.validationId ?? 'N/A',
              'reason': 'Payment cancelled by user',
              'errorMessage': 'You cancelled the payment. You can retry whenever you\'re ready.',
              'isCancelled': true,
            },
          );
        }
      });
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Utils.flushBarErrorMessage(
            paymentResult.errorMessage ?? "Payment status unclear",
            context,
          );
        }
      });
    }
  }

  Future<void> _handleConfirm() async {
    final checkoutViewModel = Provider.of<CheckoutViewModel>(context, listen: false);
    final shiftTimeViewModel = Provider.of<GetallShifttimeViewModel>(context, listen: false);
    final bookingViewModel = Provider.of<PostBookPremiumHouseKeeperViewModel>(context, listen: false);

    if (bookingViewModel.createBookPremiumHouseKeeperLoading) {
      return;
    }

    // Validate form
    final String currentAddress = _addressController.text.isEmpty ? widget.customerAddress : _addressController.text;
    final bool newCustomerError = widget.customerName.isEmpty || widget.customerPhone.isEmpty || currentAddress.isEmpty;
    final bool newPaymentError = (checkoutViewModel.selectedPaymentMethod ?? '').isEmpty;
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

    // ✅ UPDATED: Use allServices from widget instead of ViewModel
    final services = widget.allServices;
    final shiftTimes = shiftTimeViewModel.getAllShiftTimeData.data?.data ?? [];

    // Prepare tasks
    List<Map<String, dynamic>> tasks = checkoutViewModel.prepareTasksData(
        serviceQuantities: widget.serviceQuantities,
        selectedTaskItems: widget.selectedTaskItems,
        services: services
    );

    // Get shift ID
    String? shiftId = checkoutViewModel.getShiftId(
        selectedTime: widget.selectedTime,
        shiftTimes: shiftTimes
    );

    if (shiftId == null) {
      Utils.flushBarErrorMessage("Invalid time selection", context);
      return;
    }

    // Calculate total
    double subtotal = checkoutViewModel.calculateTotal(
        serviceQuantities: widget.serviceQuantities,
        selectedTaskItems: widget.selectedTaskItems,
        services: services
    );
    double transport = widget.transportFee;
    double totalAmount = subtotal + transport;

    // Prepare booking data
    Map<String, dynamic> bookingData = await checkoutViewModel.prepareBookingData(
      fullName: _fullNameController.text,
      selectedDate: widget.selectedDate,
      phone: _phoneController.text,
      customerLocation: _updatedLocation,
      address: _updatedLocation?['fullAddress'] ?? _addressController.text,
      houseSize: checkoutViewModel.selectedHouseSize,
      specialRequest: _specialRequestController.text,
      selectedFrequency: widget.selectedFrequency,

      shiftId: shiftId,
      tasks: tasks,
      paymentMethod: checkoutViewModel.selectedPaymentMethod,
    );

    try {
      await bookingViewModel.bookPremiumHouseKeeperPostApi(
        context,
        bookingData,
            (String? trackingId) async {
          if (trackingId == null || trackingId.isEmpty) {
            bookingViewModel.setBookPremiumHouseKeeperLoading(false);
            Navigator.pushReplacementNamed(
              context,
              RoutesName.failedOrderScreenWidget,
              arguments: {'trackingId':  'N/A', 'valId': 'N/A', 'reason': 'Booking creation failed', 'errorMessage': 'Unable to create booking.'},
            );
            return;
          }

          if (checkoutViewModel.selectedPaymentMethod == 'online') {
            // SSL Payment চলাকালীন loading চলবে
            final paymentResult = await checkoutViewModel.initiatePayment(
              trackingId: trackingId,
              totalAmount: totalAmount,
              customerName: _fullNameController.text.trim(),
              customerPhone: _phoneController.text.trim(),
              customerEmail: null,
              customerAddress: _addressController.text.trim(),
            );

            await _handlePaymentResult(
              viewModel: checkoutViewModel,
              paymentResult: paymentResult,
              trackingId: trackingId,
            );

            // ✅ SSL পুরোপুরি শেষ হওয়ার পর loading বন্ধ
            bookingViewModel.setBookPremiumHouseKeeperLoading(false);
          }
          else if (checkoutViewModel.selectedPaymentMethod == 'cash') {
            _clearAllData();
            _clearGlobalCart();
            Navigator.pop(context, true);
            widget.onSuccess();

            Navigator.pushNamed(
              context,
              RoutesName.confirmedScreen,
              arguments: {
                'trackingId': trackingId ?? '',
                'valId': "COD",
                'fromCheckout': true,
              },
            );

            bookingViewModel.setBookPremiumHouseKeeperLoading(false);
          }
          else {
            bookingViewModel.setBookPremiumHouseKeeperLoading(false);
            Navigator.pushReplacementNamed(
              context,
              RoutesName.failedOrderScreenWidget,
              arguments: {
                'trackingId': trackingId,
                'valId': 'N/A',
                'reason': 'Invalid payment method',
                'errorMessage': 'The selected payment method is not available.'
              },
            );
          }
        },
      );
    } catch (e) {
      bookingViewModel.setBookPremiumHouseKeeperLoading(false);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.pushReplacementNamed(
            context,
            RoutesName.failedOrderScreenWidget,
            arguments: {'trackingId': 'N/A', 'valId': 'N/A', 'reason': 'Booking failed', 'errorMessage': 'An error occurred.'},
          );
        }
      });
    }
  }
  void _clearAllData() {
    final checkoutViewModel = Provider.of<CheckoutViewModel>(context, listen: false);
    checkoutViewModel.reset();

    _fullNameController.clear();
    _phoneController.clear();
    _addressController.clear();
    _specialRequestController.clear();
    setState(() {
      _isTermsAccepted = false;
    });
  }

  // Cleared directly here (rather than relying on the landing screen's
  // pop-result handling) because a successful online payment replaces this
  // route with the confirmation screen instead of popping back, so the
  // landing screen never gets a chance to clear its cart entry.
  void _clearGlobalCart() {
    Provider.of<GlobalCartProvider>(context, listen: false).clearService(widget.serviceName);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<CheckoutViewModel, PostBookPremiumHouseKeeperViewModel>(
      builder: (context, checkoutVM, bookingVM, _) {
        // ✅ UPDATED: Use allServices from widget
        final services = widget.allServices;

        double subtotal = checkoutVM.calculateTotal(
            serviceQuantities: widget.serviceQuantities,
            selectedTaskItems: widget.selectedTaskItems,
            services: services
        );
        double transport = widget.transportFee;
        double total = subtotal + transport;
        double saved = checkoutVM.calculateSaved(
            serviceQuantities: widget.serviceQuantities,
            selectedTaskItems: widget.selectedTaskItems,
            services: services
        );

        return SafeArea(
          child: Scaffold(
            backgroundColor: AppColors.containerBackground(context),
            body: ResPonsiveUi(
              mobile: _buildBody(context, checkoutVM, bookingVM, total, subtotal, saved),
              desktop: _buildBody(context, checkoutVM, bookingVM, total, subtotal, saved),
              tablet: _buildBody(context, checkoutVM, bookingVM, total, subtotal, saved),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, CheckoutViewModel viewModel, PostBookPremiumHouseKeeperViewModel bookingVM, double total, double subtotal, double saved) {
    final screenWidth = MediaQuery.of(context).size.width * 1;
    final screenHeight = MediaQuery.of(context).size.height * 1;
    return Column(
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(height: 60, child: AppBarHeader("Checkout")),
        ),

        Expanded(
          child: SingleChildScrollView(
            controller: _scrollController,
            padding: EdgeInsets.all(screenHeight * 0.02),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCustomerDetailsCard(),
                SizedboxSpaccing.height02(context),

                _buildSelectedServicesList(subtotal, saved),
                SizedboxSpaccing.height02(context),

                _buildPaymentMethodSection(viewModel),

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
                    getTextStyle: (context, {weight}) => AppTextStyles.textSize14(context, weight: weight ?? FontWeight.w400),
                  ),
                ),
                if (_termsError)
                  Padding(
                    padding: const EdgeInsets.only(top: 4, left: 4),
                    child: Text('Please accept the Terms & Conditions to proceed', style: AppTextStyles.textSize12(context, color: Colors.red)),
                  ),
                SizedboxSpaccing.height03(context)
              ],
            ),
          ),
        ),

        _buildBottomConfirmButton(context, bookingVM, total, saved, viewModel),
      ],
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
    final screenHeight = MediaQuery.of(context).size.height * 1;
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
                  Text('Customer Details', style: AppTextStyles.textSize16(context, weight: FontWeight.w600, color: _customerError ? Colors.red : null)),
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
              SizedboxSpaccing.height02(context),
              _buildDetailRow('Name', widget.customerName),
              SizedboxSpaccing.height02(context),
              _buildDetailRow('Phone', widget.customerPhone),
              SizedboxSpaccing.height02(context),
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
        Text(value, style: AppTextStyles.textSize14(context, weight: FontWeight.w400), maxLines: null, softWrap: true),
      ],
    );
  }

  Widget _buildPaymentMethodSection(CheckoutViewModel viewModel) {
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

  Widget _buildSelectedServicesList(double subtotal, double saved) {
    // ✅ UPDATED: Use allServices from widget
    final services = widget.allServices;

    // Filter services with quantity > 0
    final selectedServices = services.where((service) {
      int qty = widget.serviceQuantities[service.id ?? ''] ?? 0;
      return qty > 0;
    }).toList();

    if (selectedServices.isEmpty) {
      return SizedBox.shrink();
    }

    double transport = widget.transportFee;
    double total = subtotal + transport;
    final screenWidth = MediaQuery.of(context).size.width * 1;
    final screenHeight = MediaQuery.of(context).size.height * 1;

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
              ...selectedServices.map((service) {
                int quantity = widget.serviceQuantities[service.id ?? ''] ?? 0;

                Set<String> selectedItems = widget.selectedTaskItems[service.id ?? ''] ?? service.houseKeeperTaskItems!.map((item) => item.id ?? '').toSet();

                double originalPrice = 0;
                for (var item in service.houseKeeperTaskItems ?? []) {
                  if (selectedItems.contains(item.id ?? '')) {
                    originalPrice += item.price?.toDouble() ?? 0;
                  }
                }

                double discountedPrice = originalPrice;
                if (service.discountType != null && service.discountValue != null && originalPrice > 0) {
                  if (service.discountType == 'PERCENTAGE') {
                    discountedPrice = originalPrice - (originalPrice * service.discountValue! / 100);
                  } else if (service.discountType == 'FLAT') {
                    discountedPrice = originalPrice - service.discountValue!.toDouble();
                  }
                }

                double totalOriginalPrice = originalPrice * quantity;
                double totalDiscountedPrice = discountedPrice * quantity;

                return Container(
                  padding: EdgeInsets.only(bottom: screenHeight * 0.02),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text("${service.name ?? ''}($quantity)", style: AppTextStyles.textSize14(context, weight: FontWeight.w400), maxLines: null, softWrap: true),
                                ),
                                SizedBox(width: 8),
                                Row(
                                  children: [
                                    Text('৳${AmountFormatter.format(totalDiscountedPrice)}', style: AppTextStyles.textSize14(context, weight: FontWeight
                                        .w400)),
                                    if (service.discountValue != null && totalOriginalPrice > 0) ...[
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
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),

              _buildPriceRow('Subtotal', subtotal),
              SizedboxSpaccing.height02(context),
              _buildPriceRow('Transport', transport),
              SizedboxSpaccing.height02(context),
              Divider(height: 1, color: AppColors.border(context)),
              SizedboxSpaccing.height02(context),
              _buildPriceRow('Total', total, isBold: true),
              SizedboxSpaccing.height02(context),
              Divider(height: 1, color: AppColors.border(context)),
              SizedboxSpaccing.height02(context),
              _buildDetailRow1('Date', widget.selectedDate),
              SizedboxSpaccing.height02(context),
              _buildDetailRow1('Slot', widget.selectedTime),
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

  Widget _buildBottomConfirmButton(BuildContext context, PostBookPremiumHouseKeeperViewModel bookingVM, double total, double saved, CheckoutViewModel checkoutVM) {
    int totalItems = checkoutVM.getTotalItems(widget.serviceQuantities);

    bool isButtonDisabled = bookingVM.createBookPremiumHouseKeeperLoading;

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
                    SizedBox(width: 8),
                    Text(
                      'Saved ৳${AmountFormatter.format(saved)}',
                      style: AppTextStyles.textSize12(context, color: Colors.green, weight: FontWeight.w500),
                    ),
                  ],
                ),
              ],
            ),
          ),
          AbsorbPointer(
            absorbing: isButtonDisabled,
            child: GestureDetector(
              onTap: _handleConfirm,
              child: Container(
                height: 40,
                width: 140,
                decoration: BoxDecoration(
                  color: isButtonDisabled
                      ? AppColors.blackColor.withOpacity(0.5)
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