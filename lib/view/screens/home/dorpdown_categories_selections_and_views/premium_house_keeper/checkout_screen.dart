/// For Web View SSl Implementation using payment url
import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/components/header_appbar.dart';
import 'package:dinmajur_customer/configs/res/components/iagree_terms&condition/iagree_terms&condition.dart';
import 'package:dinmajur_customer/configs/res/components/payment_method/payment_method_component.dart';
import 'package:dinmajur_customer/configs/res/components/section_header/section_header.dart';
import 'package:dinmajur_customer/configs/res/sizedbox_spaccing.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:dinmajur_customer/configs/responsive/responsive_ui.dart';
import 'package:dinmajur_customer/configs/utils/routes/routes_name.dart';
import 'package:dinmajur_customer/configs/utils/utils.dart';
import 'package:dinmajur_customer/view/screens/home/dorpdown_categories_selections_and_views/premium_house_keeper/notifier/checkout_notifier.dart';
import 'package:dinmajur_customer/view/screens/home/payment_webview_helper_class/payment_webview.dart';
import 'package:dinmajur_customer/view_model/homeview_model/dropdown_categories_selection_view_models/premium_house_keeper_view_model/book_premium_house_keeper_view_model.dart';
import 'package:dinmajur_customer/view_model/homeview_model/dropdown_categories_selection_view_models/premium_house_keeper_view_model/getall_premium_house_keeper_task_view_model.dart';
import 'package:dinmajur_customer/view_model/homeview_model/dropdown_categories_selection_view_models/premium_house_keeper_view_model/getall_shifttime_view_model.dart';
import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    _fullNameController.text = widget.customerName;
    _phoneController.text = widget.customerPhone;
    _addressController.text = widget.customerAddress;
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _specialRequestController.dispose();
    super.dispose();
  }

  Future<void> _handleConfirm() async {
    final checkoutViewModel = Provider.of<CheckoutViewModel>(context, listen: false);
    final taskViewModel = Provider.of<GetallPremiumHouseKeeperTaskViewModel>(context, listen: false);
    final shiftTimeViewModel = Provider.of<GetallShifttimeViewModel>(context, listen: false);
    final bookingViewModel = Provider.of<PostBookPremiumHouseKeeperViewModel>(context, listen: false);

    // ✅ Check if already processing using ViewModel state
    if (bookingViewModel.createBookPremiumHouseKeeperLoading) {
      print('⚠️ Already processing payment, ignoring duplicate tap');
      return;
    }

    // Validate form
    String? validationError = checkoutViewModel.validateCheckoutForm(
      phone: _phoneController.text,
      address: _addressController.text,
      paymentMethod: checkoutViewModel.selectedPaymentMethod,
    );

    if (validationError != null) {
      Utils.flushBarErrorMessage(validationError, context);
      return;
    }

    if (!_isTermsAccepted) {
      Utils.flushBarErrorMessage("Please accept the Terms & Conditions to proceed", context);
      return;
    }

    try {
      // Get services data
      final services = taskViewModel.getAllPremiumHouseKeeperTaskData.data?.data ?? [];
      final shiftTimes = shiftTimeViewModel.getAllShiftTimeData.data?.data ?? [];

      // Prepare tasks
      List<Map<String, dynamic>> tasks = checkoutViewModel.prepareTasksData(
        serviceQuantities: widget.serviceQuantities,
        selectedTaskItems: widget.selectedTaskItems,
        services: services,
      );

      // Get shift ID
      String? shiftId = checkoutViewModel.getShiftId(
        selectedTime: widget.selectedTime,
        shiftTimes: shiftTimes,
      );

      if (shiftId == null) {
        Utils.flushBarErrorMessage("Invalid time selection", context);
        return;
      }

      // Prepare booking data
      Map<String, dynamic> bookingData = await checkoutViewModel.prepareBookingData(
        fullName: _fullNameController.text,
        phone: _phoneController.text,
        address: _addressController.text,
        houseSize: checkoutViewModel.selectedHouseSize,
        specialRequest: _specialRequestController.text,
        selectedFrequency: widget.selectedFrequency,
        selectedDate: widget.selectedDate,
        shiftId: shiftId,
        tasks: tasks,
        paymentMethod: checkoutViewModel.selectedPaymentMethod,
        source: "android",
      );

      print('Booking Data: $bookingData');

      // Call booking API with paymentUrl and trackingId callback
      await bookingViewModel.bookPremiumHouseKeeperPostApi(
        context,
        bookingData,
            (String? paymentUrl, String? trackingId) async {
          print('Success! Payment URL: $paymentUrl, TrackingId: $trackingId');

          // ✅ Check if trackingId is null (API failed)
          if (trackingId == null || trackingId.isEmpty) {
            print('⚠️ Booking failed - no tracking ID received');

            // Navigate to failed screen
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                Navigator.pushReplacementNamed(
                  context,
                  RoutesName.failedOrderScreenWidget,
                  arguments: {
                    'trackingId': 'N/A',
                    'valId': 'N/A',
                    'reason': 'Booking creation failed',
                    'errorMessage': 'Unable to create booking. Please try again.',
                  },
                );
              }
            });
            return;
          }

          if (checkoutViewModel.selectedPaymentMethod == 'online' &&
              paymentUrl != null &&
              paymentUrl.isNotEmpty) {
            print('---------------Opening WebView for payment----------------');

            // Navigate to payment WebView
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PaymentWebViewScreen(
                  paymentUrl: paymentUrl,
                  trackingId: trackingId,
                ),
              ),
            );

            // Handle payment result from WebView
            if (result != null && result is Map<String, dynamic>) {
              String status = result['status'] ?? '';

              if (status == 'success') {
                // Payment successful
                _clearAllData();
                Navigator.pop(context);
                widget.onSuccess();

                Navigator.pushNamed(
                  context,
                  RoutesName.confirmedScreen,
                  arguments: {
                    'trackingId': trackingId,
                    'valId': 'ONLINE_PAYMENT'
                  },
                );
              } else if (status == 'failed') {
                // Payment failed
                print("---------------------Payment FAILED -----------");
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    Navigator.pushReplacementNamed(
                      context,
                      RoutesName.failedCancelledPaymentScreen,
                      arguments: {
                        'trackingId': trackingId,
                        'valId': 'N/A',
                        'reason': 'Payment transaction failed',
                        'errorMessage': 'The payment could not be completed. Please try again.',
                        'isCancelled': false,
                      },
                    );
                  }
                });
              } else if (status == 'cancelled') {
                // Payment cancelled
                print("---------------------Payment CANCELLED -----------");
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    Navigator.pushReplacementNamed(
                      context,
                      RoutesName.failedCancelledPaymentScreen,
                      arguments: {
                        'trackingId': trackingId,
                        'valId': 'N/A',
                        'reason': 'Payment cancelled by user',
                        'errorMessage': 'You cancelled the payment. You can retry whenever you\'re ready.',
                        'isCancelled': true,
                      },
                    );
                  }
                });
              }
            }
          } else if (checkoutViewModel.selectedPaymentMethod == 'cash') {
            // Cash on delivery flow
            _clearAllData();

            Navigator.pop(context);
            widget.onSuccess();

            Navigator.pushNamed(
              context,
              RoutesName.confirmedScreen,
              arguments: {'trackingId': trackingId, 'valId': "COD"},
            );
          } else {
            // No payment URL received for online payment
            Utils.flushBarErrorMessage("Payment gateway URL not available", context);

            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                Navigator.pushReplacementNamed(
                  context,
                  RoutesName.failedOrderScreenWidget,
                  arguments: {
                    'trackingId': trackingId,
                    'valId': 'N/A',
                    'reason': 'Invalid payment method',
                    'errorMessage': 'The selected payment method is not available.',
                  },
                );
              }
            });
          }
        },
      );
    } catch (e) {
      print('Error in _handleConfirm: $e');

      // ✅ Show error to user
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.pushReplacementNamed(
            context,
            RoutesName.failedOrderScreenWidget,
            arguments: {
              'trackingId': 'N/A',
              'valId': 'N/A',
              'reason': 'Booking failed',
              'errorMessage': 'An error occurred while processing your booking. Please try again.',
            },
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

  @override
  Widget build(BuildContext context) {
    return Consumer3<CheckoutViewModel, GetallPremiumHouseKeeperTaskViewModel, PostBookPremiumHouseKeeperViewModel>(
      builder: (context, checkoutVM, taskVM, bookingVM, _) {
        final services = taskVM.getAllPremiumHouseKeeperTaskData.data?.data ?? [];

        double subtotal = checkoutVM.calculateTotal(
          serviceQuantities: widget.serviceQuantities,
          selectedTaskItems: widget.selectedTaskItems,
          services: services,
        );
        double transport = widget.transportFee;
        double total = subtotal + transport;
        double saved = checkoutVM.calculateSaved(
          serviceQuantities: widget.serviceQuantities,
          selectedTaskItems: widget.selectedTaskItems,
          services: services,
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
        // Header
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(height: 60, child: AppBarHeader("Checkout")),
        ),

        // Form Content
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(screenHeight * 0.02),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCustomerDetailsCard(),
                SizedboxSpaccing.height02(context),
                _buildSelectedServicesList(subtotal, saved),
                SizedboxSpaccing.height02(context),
                _buildPaymentMethodSection(viewModel),
                SizedboxSpaccing.height01(context),
                DynamicTermsCheckbox(
                  isAccepted: _isTermsAccepted,
                  onChanged: (value) {
                    setState(() {
                      _isTermsAccepted = value;
                    });
                  },
                  context: context,
                  onTermsTap: () => Navigator.pushNamed(context, RoutesName.termsAndCondition),
                  onPrivacyTap: () => Navigator.pushNamed(context, RoutesName.privacyPolicy),
                  onRefundTap: () => Navigator.pushNamed(context, RoutesName.refundPolicyScreen),
                  getButtonColor: (context) => AppColors.button(context),
                  getBorderColor: (context) => AppColors.border(context),
                  getWhiteColor: (context) => AppColors.whiteColor,
                  getTextStyle: (context, {weight}) => AppTextStyles.textSize12(context, weight: weight ?? FontWeight.w400),
                ),
                SizedboxSpaccing.height03(context)
              ],
            ),
          ),
        ),

        // Bottom Confirm Button
        _buildBottomConfirmButton(context, bookingVM, total, saved, viewModel),
      ],
    );
  }

  Future<void> _handleEditAddress() async {
    final result = await Navigator.pushNamed(context, RoutesName.addLocationScreenWidget);

    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        String newAddress = '';

        if (result['addressType'] == 'saved') {
          newAddress = result['fullAddress'] ?? '';
          print('✅ Updated with saved address: $newAddress');
        } else if (result['addressType'] == 'new') {
          newAddress = result['fullAddress'] ?? '';
          print('✅ Updated with new address: $newAddress');
        }

        _addressController.text = newAddress;

        if (widget.onAddressUpdate != null && newAddress.isNotEmpty) {
          widget.onAddressUpdate!(newAddress);
        }
      });
    }
  }

  Widget _buildCustomerDetailsCard() {
    final screenHeight = MediaQuery.of(context).size.height * 1;
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
              Text('Customer Details', style: AppTextStyles.textSize16(context, weight: FontWeight.w600)),
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
      children: [
        SectionHeader(title: 'Payment Method', titleWidth: screenWidth * 0.6, showSeeAll: false),
        SizedboxSpaccing.height02(context),
        PaymentMethodWidget(
          selectedPaymentMethod: viewModel.selectedPaymentMethod,
          paymentMethods: viewModel.paymentMethods,
          onPaymentMethodChanged: (method) => viewModel.setPaymentMethod(method),
        ),
      ],
    );
  }

  Widget _buildSelectedServicesList(double subtotal, double saved) {
    final taskViewModel = Provider.of<GetallPremiumHouseKeeperTaskViewModel>(context, listen: false);
    final services = taskViewModel.getAllPremiumHouseKeeperTaskData.data?.data ?? [];

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
                  } else if (service.discountType == 'FIXED') {
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
                                    Text('৳${totalDiscountedPrice.toStringAsFixed(2)}', style: AppTextStyles.textSize14(context, weight: FontWeight.w400)),
                                    if (service.discountValue != null && totalOriginalPrice > 0) ...[
                                      SizedboxSpaccing.width01(context),
                                      Text(
                                        '৳${totalOriginalPrice.toStringAsFixed(2)}',
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
              _buildDetailRow1('Date', widget.selectedDate),
              SizedboxSpaccing.height02(context),
              _buildDetailRow1('Slot', widget.selectedTime),
              SizedboxSpaccing.height02(context),
              _buildPriceRow('Transport', transport),
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

  Widget _buildBottomConfirmButton(BuildContext context, PostBookPremiumHouseKeeperViewModel bookingVM, double total, double saved, CheckoutViewModel checkoutVM) {
    int totalItems = checkoutVM.getTotalItems(widget.serviceQuantities);

    // ✅ Only use ViewModel loading state
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
                      '৳${total.toStringAsFixed(2)}',
                      style: AppTextStyles.textSize18(context, weight: FontWeight.w600, color: AppColors.whiteColor),
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Saved ৳${saved.toStringAsFixed(2)}',
                      style: AppTextStyles.textSize12(context, color: Colors.green, weight: FontWeight.w500),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // ✅ Wrap with AbsorbPointer to prevent taps when disabled
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
  }}





///For Ssl Integration using store id and Password

// import 'package:dinmajur_customer/configs/res/color.dart';
// import 'package:dinmajur_customer/configs/res/components/header_appbar.dart';
// import 'package:dinmajur_customer/configs/res/components/iagree_terms&condition/iagree_terms&condition.dart';
// import 'package:dinmajur_customer/configs/res/components/payment_method/payment_method_component.dart';
// import 'package:dinmajur_customer/configs/res/components/section_header/section_header.dart';
// import 'package:dinmajur_customer/configs/res/sizedbox_spaccing.dart';
// import 'package:dinmajur_customer/configs/res/text_styles.dart';
// import 'package:dinmajur_customer/configs/responsive/responsive_ui.dart';
// import 'package:dinmajur_customer/configs/services/ssl_payment_service/ssl_payment.dart';
// import 'package:dinmajur_customer/configs/utils/routes/routes_name.dart';
// import 'package:dinmajur_customer/configs/utils/utils.dart';
// import 'package:dinmajur_customer/view/screens/home/dorpdown_categories_selections_and_views/premium_house_keeper/notifier/checkout_notifier.dart';
// import 'package:dinmajur_customer/view_model/homeview_model/dropdown_categories_selection_view_models/premium_house_keeper_view_model/book_premium_house_keeper_view_model.dart';
// import 'package:dinmajur_customer/view_model/homeview_model/dropdown_categories_selection_view_models/premium_house_keeper_view_model/getall_premium_house_keeper_task_view_model.dart';
// import 'package:dinmajur_customer/view_model/homeview_model/dropdown_categories_selection_view_models/premium_house_keeper_view_model/getall_shifttime_view_model.dart';
// import 'package:flutter/material.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:loading_animation_widget/loading_animation_widget.dart';
// import 'package:provider/provider.dart';
//
// class CheckoutHouseKeeperScreen extends StatefulWidget {
//   final Map<String, int> serviceQuantities;
//   final Map<String, Set<String>> selectedTaskItems;
//   final String selectedFrequency;
//   final String selectedDate;
//   final String selectedTime;
//   final String customerName;
//   final String customerPhone;
//   final String customerAddress;
//   final VoidCallback onSuccess;
//   final Function(String)? onAddressUpdate;
//     final double transportFee;
//   const CheckoutHouseKeeperScreen({
//     Key? key,
//     required this.serviceQuantities,
//     required this.selectedTaskItems,
//     required this.selectedFrequency,
//     required this.selectedDate,
//     required this.selectedTime,
//     required this.customerName,
//     required this.customerPhone,
//     required this.customerAddress,
//     required this.onSuccess,
//     this.onAddressUpdate,
//         required this.transportFee,
//   }) : super(key: key);
//
//   @override
//   State<CheckoutHouseKeeperScreen> createState() => _CheckoutHouseKeeperScreenState();
// }
//
// class _CheckoutHouseKeeperScreenState extends State<CheckoutHouseKeeperScreen> {
//   final TextEditingController _fullNameController = TextEditingController();
//   final TextEditingController _phoneController = TextEditingController();
//   final TextEditingController _addressController = TextEditingController();
//   final TextEditingController _specialRequestController = TextEditingController();
//   bool _isTermsAccepted = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _fullNameController.text = widget.customerName;
//     _phoneController.text = widget.customerPhone;
//     _addressController.text = widget.customerAddress;
//   }
//
//   @override
//   void dispose() {
//     _fullNameController.dispose();
//     _phoneController.dispose();
//     _addressController.dispose();
//     _specialRequestController.dispose();
//     super.dispose();
//   }
//
//   // Future<void> _handlePaymentResult({required CheckoutViewModel viewModel, required SSLPaymentResult paymentResult, required String trackingId}) async {
//   //   if (!mounted) return;
//   //
//   //   if (paymentResult.success) {
//   //     _clearAllData();
//   //     // Navigator.pop(context);
//   //     Navigator.pushReplacementNamed(context, RoutesName.confirmedScreen, arguments: {'trackingId': trackingId, 'valId': paymentResult.validationId ?? 'N/A'});
//   //   } else if (paymentResult.status == 'FAILED') {
//   //     print("---------------------Handle Payment result -----------");
//   //     WidgetsBinding.instance.addPostFrameCallback((_) {
//   //       if (mounted) {
//   //         Navigator.pushReplacementNamed(
//   //           context,
//   //           RoutesName.failedOrderScreenWidget,
//   //           arguments: {
//   //             'trackingId': trackingId,
//   //             'valId': paymentResult.validationId ?? 'N/A',
//   //             'reason': 'Payment transaction failed',
//   //             'errorMessage': paymentResult.errorMessage ?? 'The payment could not be completed. Please try again.',
//   //           },
//   //         );
//   //       }
//   //     });
//   //   } else if (paymentResult.status == 'CANCELLED') {
//   //     WidgetsBinding.instance.addPostFrameCallback((_) {
//   //       if (mounted) {
//   //         Utils.flushBarErrorMessage("Payment was cancelled", context);
//   //       }
//   //     });
//   //   } else {
//   //     WidgetsBinding.instance.addPostFrameCallback((_) {
//   //       if (mounted) {
//   //         Utils.flushBarErrorMessage(paymentResult.errorMessage ?? "Payment status unclear", context);
//   //       }
//   //     });
//   //   }
//   // }
//
// // Add this to your checkout_housekeeper_screen.dart
//
// // Update the _handlePaymentResult method:
//
//   Future<void> _handlePaymentResult({
//     required CheckoutViewModel viewModel,
//     required SSLPaymentResult paymentResult,
//     required String trackingId
//   }) async {
//     if (!mounted) return;
//
//     if (paymentResult.success) {
//       _clearAllData();
//       Navigator.pushReplacementNamed(
//         context,
//         RoutesName.confirmedScreen,
//         arguments: {
//           'trackingId': trackingId,
//           'valId': paymentResult.validationId ?? 'N/A'
//         },
//       );
//     } else if (paymentResult.status == 'FAILED') {
//       print("---------------------Handle Payment result - FAILED -----------");
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         if (mounted) {
//           Navigator.pushReplacementNamed(
//             context,
//             RoutesName.failedCancelledPaymentScreen,
//             arguments: {
//               'trackingId': trackingId,
//               'valId': paymentResult.validationId ?? 'N/A',
//               'reason': 'Payment transaction failed',
//               'errorMessage': paymentResult.errorMessage ?? 'The payment could not be completed. Please try again.',
//               'isCancelled': false, // Payment failed
//             },
//           );
//         }
//       });
//     } else if (paymentResult.status == 'CLOSED') {
//       print("---------------------Handle Payment result - CLOSED -----------");
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         if (mounted) {
//           Navigator.pushReplacementNamed(
//             context,
//             RoutesName.failedCancelledPaymentScreen,
//             arguments: {
//               'trackingId': trackingId,
//               'valId': paymentResult.validationId ?? 'N/A',
//               'reason': 'Payment cancelled by user',
//               'errorMessage': 'You cancelled the payment. You can retry whenever you\'re ready.',
//               'isCancelled': true, // Payment cancelled
//             },
//           );
//         }
//       });
//     } else {
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         if (mounted) {
//           Utils.flushBarErrorMessage(
//             paymentResult.errorMessage ?? "Payment status unclear",
//             context,
//           );
//         }
//       });
//     }
//   }
//   Future<void> _handleConfirm() async {
//     final checkoutViewModel = Provider.of<CheckoutViewModel>(context, listen: false);
//     final taskViewModel = Provider.of<GetallPremiumHouseKeeperTaskViewModel>(context, listen: false);
//     final shiftTimeViewModel = Provider.of<GetallShifttimeViewModel>(context, listen: false);
//     final bookingViewModel = Provider.of<PostBookPremiumHouseKeeperViewModel>(context, listen: false);
//
//     // Validate form
//     String? validationError = checkoutViewModel.validateCheckoutForm(
//       phone: _phoneController.text,
//       address: _addressController.text,
//       paymentMethod: checkoutViewModel.selectedPaymentMethod,
//     );
//
//     if (validationError != null) {
//       Utils.flushBarErrorMessage(validationError, context);
//       return;
//     }
//     if (!_isTermsAccepted) {
//       Utils.flushBarErrorMessage("Please accept the Terms & Conditions to proceed", context);
//       return;
//     }
//     // Get services data
//     final services = taskViewModel.getAllPremiumHouseKeeperTaskData.data?.data ?? [];
//     final shiftTimes = shiftTimeViewModel.getAllShiftTimeData.data?.data ?? [];
//
//     // Prepare tasks
//     List<Map<String, dynamic>> tasks = checkoutViewModel.prepareTasksData(
//         serviceQuantities: widget.serviceQuantities,
//         selectedTaskItems: widget.selectedTaskItems,
//         services: services
//     );
//
//     // Get shift ID
//     String? shiftId = checkoutViewModel.getShiftId(
//         selectedTime: widget.selectedTime,
//         shiftTimes: shiftTimes
//     );
//
//     if (shiftId == null) {
//       Utils.flushBarErrorMessage("Invalid time selection", context);
//       return;
//     }
//
//     // Calculate total
//     double subtotal = checkoutViewModel.calculateTotal(
//         serviceQuantities: widget.serviceQuantities,
//         selectedTaskItems: widget.selectedTaskItems,
//         services: services
//     );
//     double transport = widget.transportFee;
//     double totalAmount = subtotal + transport;
//
//     // Prepare booking data
//     Map<String, dynamic> bookingData = await checkoutViewModel.prepareBookingData(
//       fullName: _fullNameController.text,
//       phone: _phoneController.text,
//       address: _addressController.text,
//       houseSize: checkoutViewModel.selectedHouseSize,
//       specialRequest: _specialRequestController.text,
//       selectedFrequency: widget.selectedFrequency,
//       selectedDate: widget.selectedDate,
//       shiftId: shiftId,
//       tasks: tasks,
//       paymentMethod: checkoutViewModel.selectedPaymentMethod,
//     );
//
//     print('Booking Data: $bookingData');
//
//     // ✅ UPDATED: Call booking API with simplified callback
//     await bookingViewModel.bookPremiumHouseKeeperPostApi(
//         context,
//         bookingData,
//             (String? trackingId) async {
//           print('Success! TrackingId: $trackingId');
//
//           if (checkoutViewModel.selectedPaymentMethod == 'online' && trackingId != null) {
//             print('---------------A----------------');
//
//             // ✅ Initiate SSL Commerz payment client-side
//             final paymentResult = await checkoutViewModel.initiatePayment(
//                 trackingId: trackingId,
//                 totalAmount: totalAmount,
//               customerName: _fullNameController.text.trim(),
//               customerPhone: _phoneController.text.trim(),
//               customerEmail: null,
//               customerAddress: _addressController.text.trim(),
//             );
//
//             print('Payment Result: ${paymentResult.toString()}');
//
//             await _handlePaymentResult(
//                 viewModel: checkoutViewModel,
//                 paymentResult: paymentResult,
//                 trackingId: trackingId
//             );
//
//           } else if (checkoutViewModel.selectedPaymentMethod == 'cash') {
//             // Cash on delivery flow
//             _clearAllData();
//             Navigator.pop(context);
//             widget.onSuccess();
//
//             Navigator.pushNamed(
//                 context,
//                 RoutesName.confirmedScreen,
//                 arguments: {'trackingId': trackingId ?? '', 'valId': "COD"}
//             );
//           } else {
//             Navigator.pushReplacementNamed(
//               context,
//               RoutesName.failedOrderScreenWidget,
//               arguments: {
//                 'trackingId': trackingId,
//                 'valId': 'N/A',
//                 'reason': 'Invalid payment method',
//                 'errorMessage': 'The selected payment method is not available.'
//               },
//             );
//           }
//         }
//     );
//   }
//
//   void _clearAllData() {
//     final checkoutViewModel = Provider.of<CheckoutViewModel>(context, listen: false);
//     checkoutViewModel.reset();
//
//     _fullNameController.clear();
//     _phoneController.clear();
//     _addressController.clear();
//     _specialRequestController.clear();
//     setState(() {
//       _isTermsAccepted = false;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Consumer3<CheckoutViewModel, GetallPremiumHouseKeeperTaskViewModel, PostBookPremiumHouseKeeperViewModel>(
//       builder: (context, checkoutVM, taskVM, bookingVM, _) {
//         final services = taskVM.getAllPremiumHouseKeeperTaskData.data?.data ?? [];
//
//         double subtotal = checkoutVM.calculateTotal(serviceQuantities: widget.serviceQuantities, selectedTaskItems: widget.selectedTaskItems, services: services);
//         double transport = widget.transportFee;
//         double total = subtotal + transport;
//         double saved = checkoutVM.calculateSaved(serviceQuantities: widget.serviceQuantities, selectedTaskItems: widget.selectedTaskItems, services: services);
//
//         return SafeArea(
//           child: Scaffold(
//             backgroundColor: AppColors.containerBackground(context),
//             body: ResPonsiveUi(
//               mobile: _buildBody(context, checkoutVM, bookingVM,total ,subtotal, saved),
//               desktop: _buildBody(context, checkoutVM, bookingVM, total,subtotal, saved),
//               tablet: _buildBody(context, checkoutVM, bookingVM, total,subtotal, saved),
//             ),
//           ),
//         );
//       },
//     );
//   }
//
//   Widget _buildBody(BuildContext context, CheckoutViewModel viewModel, PostBookPremiumHouseKeeperViewModel bookingVM, double total,double subtotal, double saved) {
//     final screenWidth = MediaQuery.of(context).size.width * 1;
//     final screenHeight = MediaQuery.of(context).size.height * 1;
//     return Column(
//       children: [
//         // Header
//         GestureDetector(
//           onTap: () => Navigator.pop(context),
//           child: Container(height: 60, child: AppBarHeader("Checkout")),
//         ),
//
//         // Form Content
//         Expanded(
//           child: SingleChildScrollView(
//             padding: EdgeInsets.all(screenHeight * 0.02),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 _buildCustomerDetailsCard(),
//                 SizedboxSpaccing.height02(context),
//
//                 _buildSelectedServicesList(subtotal, saved),
//                 SizedboxSpaccing.height02(context),
//
//                 _buildPaymentMethodSection(viewModel),
//                 SizedboxSpaccing.height01(context),
//                 DynamicTermsCheckbox(
//                   isAccepted: _isTermsAccepted,
//                   onChanged: (value) {
//                     setState(() {
//                       _isTermsAccepted = value;
//                     });
//                   },
//                   context: context,
//                   onTermsTap: () => Navigator.pushNamed(context, RoutesName.termsAndCondition),
//                   onPrivacyTap: () => Navigator.pushNamed(context, RoutesName.privacyPolicy),
//                   onRefundTap: () => Navigator.pushNamed(context, RoutesName.refundPolicyScreen),
//                   getButtonColor: (context) => AppColors.button(context),
//                   getBorderColor: (context) => AppColors.border(context),
//                   getWhiteColor: (context) => AppColors.whiteColor,
//                   getTextStyle: (context, {weight}) => AppTextStyles.textSize12(context, weight: weight ?? FontWeight.w400),
//                 ),
//                 SizedboxSpaccing.height03(context)
//
//               ],
//             ),
//           ),
//         ),
//
//         // Bottom Confirm Button
//         _buildBottomConfirmButton(context, bookingVM, total, saved, viewModel),
//       ],
//     );
//   }
//
//
//
//   // ✅ Handle Edit Address Navigation
//   Future<void> _handleEditAddress() async {
//     final result = await Navigator.pushNamed(context, RoutesName.addLocationScreenWidget);
//
//     if (result != null && result is Map<String, dynamic>) {
//       setState(() {
//         String newAddress = '';
//
//         if (result['addressType'] == 'saved') {
//           newAddress = result['fullAddress'] ?? '';
//           print('✅ Updated with saved address: $newAddress');
//         } else if (result['addressType'] == 'new') {
//           newAddress = result['fullAddress'] ?? '';
//           print('✅ Updated with new address: $newAddress');
//         }
//
//         _addressController.text = newAddress;
//
//         // ✅ Notify parent (BookNowScreen) about address update
//         if (widget.onAddressUpdate != null && newAddress.isNotEmpty) {
//           widget.onAddressUpdate!(newAddress);
//         }
//       });
//     }
//   }
//
//   Widget _buildCustomerDetailsCard() {
//     final screenHeight = MediaQuery.of(context).size.height * 1;
//     return Container(
//       padding: EdgeInsets.all(screenHeight * 0.015),
//       decoration: BoxDecoration(
//         color: AppColors.containerBackground(context),
//         borderRadius: BorderRadius.circular(8),
//         border: Border.all(color: AppColors.border(context)),
//       ),
//       child: Column(
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text('Customer Details', style: AppTextStyles.textSize16(context, weight: FontWeight.w600)),
//               GestureDetector(
//                 onTap: _handleEditAddress,
//                 child: Container(
//                   width: 80,
//                   color: Colors.transparent,
//                   alignment: Alignment.centerRight,
//                   child: Text('Edit', style: AppTextStyles.textSize14(context, weight: FontWeight.w500)),
//                 ),
//               ),
//             ],
//           ),
//           SizedboxSpaccing.height02(context),
//           _buildDetailRow('Name', widget.customerName),
//           SizedboxSpaccing.height02(context),
//           _buildDetailRow('Phone', widget.customerPhone),
//           SizedboxSpaccing.height02(context),
//           _buildDetailRow('Address', _addressController.text.isEmpty ? widget.customerAddress : _addressController.text, isMultiline: true), // ✅ Use controller text if available
//         ],
//       ),
//     );
//   }
//
//   Widget _buildDetailRow(String label, String value, {bool isMultiline = false}) {
//     if (isMultiline) {
//       return Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text('$label :  ', style: AppTextStyles.textSize14(context, weight: FontWeight.w400)),
//           Expanded(
//             child: Text(
//               value,
//               style: AppTextStyles.textSize14(context, weight: FontWeight.w500, color: AppColors.subtitle(context)),
//               maxLines: null,
//               softWrap: true,
//             ),
//           ),
//         ],
//       );
//     }
//
//     return Row(
//       children: [
//         Text('$label :  ', style: AppTextStyles.textSize14(context, weight: FontWeight.w400)),
//         Text(
//           value,
//           style: AppTextStyles.textSize14(context, weight: FontWeight.w500, color: AppColors.subtitle(context)),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildDetailRow1(String label, String value) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Text('$label', style: AppTextStyles.textSize14(context, weight: FontWeight.w400)),
//         Text(value, style: AppTextStyles.textSize14(context, weight: FontWeight.w400), maxLines: null, softWrap: true),
//       ],
//     );
//   }
//
//   Widget _buildPaymentMethodSection(CheckoutViewModel viewModel) {
//     final screenWidth = MediaQuery.of(context).size.width;
//
//     return Column(
//       children: [
//         SectionHeader(title: 'Payment Method', titleWidth: screenWidth * 0.6, showSeeAll: false),
//         SizedboxSpaccing.height02(context),
//         PaymentMethodWidget(
//           selectedPaymentMethod: viewModel.selectedPaymentMethod,
//           paymentMethods: viewModel.paymentMethods,
//           onPaymentMethodChanged: (method) => viewModel.setPaymentMethod(method),
//         ),
//       ],
//     );
//   }
//   Widget _buildSelectedServicesList(double subtotal, double saved) {
//     final taskViewModel = Provider.of<GetallPremiumHouseKeeperTaskViewModel>(context, listen: false);
//     final services = taskViewModel.getAllPremiumHouseKeeperTaskData.data?.data ?? [];
//
//     // Filter services with quantity > 0
//     final selectedServices = services.where((service) {
//       int qty = widget.serviceQuantities[service.id ?? ''] ?? 0;
//       return qty > 0;
//     }).toList();
//
//     if (selectedServices.isEmpty) {
//       return SizedBox.shrink();
//     }
//     double transport = widget.transportFee;
//     double total = subtotal + transport;
//     final screenWidth = MediaQuery.of(context).size.width * 1;
//     final screenHeight = MediaQuery.of(context).size.height * 1;
//     return Column(
//       children: [
//         SectionHeader(title: 'Booking Summary', titleWidth: screenWidth * 0.6, showSeeAll: false),
//         SizedboxSpaccing.height02(context),
//         Container(
//           padding: EdgeInsets.all(screenHeight * 0.015),
//           decoration: BoxDecoration(
//             color: AppColors.containerBackground(context),
//             borderRadius: BorderRadius.circular(16),
//             border: Border.all(color: AppColors.border(context)),
//           ),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               ...selectedServices.map((service) {
//                 int quantity = widget.serviceQuantities[service.id ?? ''] ?? 0;
//
//                 // Get selected items
//                 Set<String> selectedItems = widget.selectedTaskItems[service.id ?? ''] ?? service.houseKeeperTaskItems!.map((item) => item.id ?? '').toSet();
//
//                 // Calculate prices
//                 double originalPrice = 0;
//                 for (var item in service.houseKeeperTaskItems ?? []) {
//                   if (selectedItems.contains(item.id ?? '')) {
//                     originalPrice += item.price?.toDouble() ?? 0;
//                   }
//                 }
//
//                 double discountedPrice = originalPrice;
//                 if (service.discountType != null && service.discountValue != null && originalPrice > 0) {
//                   if (service.discountType == 'PERCENTAGE') {
//                     discountedPrice = originalPrice - (originalPrice * service.discountValue! / 100);
//                   } else if (service.discountType == 'FIXED') {
//                     discountedPrice = originalPrice - service.discountValue!.toDouble();
//                   }
//                 }
//
//                 // Total prices (multiplied by quantity)
//                 double totalOriginalPrice = originalPrice * quantity;
//                 double totalDiscountedPrice = discountedPrice * quantity;
//
//                 return Container(
//                   padding: EdgeInsets.only(bottom: screenHeight*0.02),
//                   child: Row(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Row(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Expanded(
//                                   child: Text("${service.name ?? ''}($quantity)", style: AppTextStyles.textSize14(context, weight: FontWeight.w400), maxLines: null, softWrap: true),
//                                 ),
//                                 SizedBox(width: 8),
//                                 Row(
//                                   children: [
//                                     Text('৳${totalDiscountedPrice.toStringAsFixed(2)}', style: AppTextStyles.textSize14(context, weight: FontWeight.w400)),
//                                     if (service.discountValue != null && totalOriginalPrice > 0) ...[
//                                       SizedboxSpaccing.width01(context),
//                                       Text(
//                                         '৳${totalOriginalPrice.toStringAsFixed(2)}',
//                                         style: AppTextStyles.textSize12(context, color: AppColors.subtitle(context)).copyWith(decoration: TextDecoration.lineThrough),
//                                       ),
//                                     ],
//                                   ],
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 );
//               }).toList(),
//
//               _buildDetailRow1('Date', widget.selectedDate),
//               SizedboxSpaccing.height02(context),
//               _buildDetailRow1('Slot', widget.selectedTime),
//               SizedboxSpaccing.height02(context),
//               _buildPriceRow('Transport', transport),
//               SizedboxSpaccing.height02(context),
//               _buildPriceRow('Subtotal', subtotal),
//               // SizedboxSpaccing.height02(context),
//               // if (saved > 0) ...[SizedboxSpaccing.height005(context), _buildPriceRow('Saved', saved, isGreen: true)],
//               // Divider(height: 20, color: AppColors.border(context)),
//               // Row(
//               //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               //   children: [
//               //     Text('Total', style: AppTextStyles.textSize16(context, weight: FontWeight.w600)),
//               //     Text(
//               //       '৳${total.toStringAsFixed(2)}',
//               //       style: AppTextStyles.textSize18(context, weight: FontWeight.w700, color: AppColors.button(context)),
//               //     ),
//               //   ],
//               // ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildPriceRow(String label, double amount, {bool isGreen = false}) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Text(label, style: AppTextStyles.textSize14(context, weight: FontWeight.w400)),
//         Text(
//           '৳${amount.toStringAsFixed(2)}',
//           style: AppTextStyles.textSize14(context, weight: FontWeight.w400, color: isGreen ? Colors.green : AppColors.textPrimary(context)),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildBottomConfirmButton(BuildContext context, PostBookPremiumHouseKeeperViewModel bookingVM, double total, double saved, CheckoutViewModel checkoutVM) {
//     int totalItems = checkoutVM.getTotalItems(widget.serviceQuantities);
//
//     return Container(
//       padding: EdgeInsets.all(15),
//       decoration: BoxDecoration(
//         color: AppColors.button(context),
//         border: Border(top: BorderSide(color: AppColors.border(context), width: 1)),
//       ),
//       child: Row(
//         children: [
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Text('Total Services ($totalItems item${totalItems > 1 ? 's' : ''})', style: AppTextStyles.textSize12(context, color: AppColors.whiteColor)),
//                 SizedBox(height: 4),
//                 Row(
//                   children: [
//                     Text(
//                       '৳${total.toStringAsFixed(2)}',
//                       style: AppTextStyles.textSize18(context, weight: FontWeight.w600, color: AppColors.whiteColor),
//                     ),
//                     SizedBox(width: 8),
//                     Text(
//                       'Saved ৳${saved.toStringAsFixed(2)}',
//                       style: AppTextStyles.textSize12(context, color: Colors.green, weight: FontWeight.w500),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//           GestureDetector(
//             onTap: _handleConfirm,
//             child: Container(
//               height: 40,
//               width: 140,
//               decoration: BoxDecoration(
//                 color: AppColors.blackColor,
//                 borderRadius: BorderRadius.circular(8),
//                 border: Border.all(width: 1, color: AppColors.whiteColor),
//               ),
//               child: bookingVM.createBookPremiumHouseKeeperLoading
//                   ? Center(child: LoadingAnimationWidget.progressiveDots(color: AppColors.whiteColor, size: 50))
//                   : Center(
//                       child: Row(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           Text(
//                             'Pay Now',
//                             style: AppTextStyles.textSize16(context, weight: FontWeight.w600, color: Colors.white),
//                           ),
//                           SizedBox(width: 8),
//                           Icon(Icons.arrow_forward, color: Colors.white, size: 18),
//                         ],
//                       ),
//                     ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
