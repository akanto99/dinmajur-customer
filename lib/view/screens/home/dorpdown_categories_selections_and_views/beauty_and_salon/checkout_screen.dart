import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/components/header_appbar.dart';
import 'package:dinmajur_customer/configs/res/sizedbox_spaccing.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:dinmajur_customer/configs/services/ssl_payment_service/ssl_payment.dart';
import 'package:dinmajur_customer/configs/utils/routes/routes_name.dart';
import 'package:dinmajur_customer/configs/utils/utils.dart';
import 'package:dinmajur_customer/configs/widgets/datepicker_with_formfield.dart';
import 'package:dinmajur_customer/model/home_models/dropdown_categories_selection_models/beauty_and_salon_model/getall_premium_home_beauty_salon_model.dart';
import 'package:dinmajur_customer/view/screens/home/dorpdown_categories_selections_and_views/beauty_and_salon/notifier/checkout_notifier.dart';
import 'package:dinmajur_customer/view_model/homeview_model/dropdown_categories_selection_view_models/beauty_and_salon_view_model/book_premium_home_beauty_salon_view_model.dart';
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

  @override
  void initState() {
    super.initState();
    _fullNameController.text = widget.customerName;
    _phoneController.text = widget.customerPhone;
    _addressController.text = widget.customerAddress;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final checkoutVM = Provider.of<CheckoutBeautySalonViewModel>(context, listen: false);
      if (checkoutVM.selectedDate != null) {
        _dateController.text = DateFormat('MMMM dd, yyyy').format(checkoutVM.selectedDate!);
      }
    });
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

  Future<void> _handlePaymentResult({
    required CheckoutBeautySalonViewModel viewModel,
    required SSLPaymentResult paymentResult,
    required String trackingId,
  }) async {
    if (!mounted) return;

    if (paymentResult.success) {
      _clearAllData();
      Navigator.pushReplacementNamed(
        context,
        RoutesName.beautyConfirmedScreen,
        arguments: {'trackingId': trackingId,
          'valId': paymentResult.validationId ?? 'N/A',
        },
      );
    } else if (paymentResult.status == 'FAILED') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.pushReplacementNamed(
            context,
            RoutesName.failedOrderScreenWidget,
            arguments: {
              'trackingId': trackingId,
              'valId': paymentResult.validationId ?? 'N/A',
              'reason': 'Payment transaction failed',
              'errorMessage': paymentResult.errorMessage ?? 'The payment could not be completed. Please try again.',
            },
          );
        }
      });
    } else if (paymentResult.status == 'CANCELLED') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Utils.flushBarErrorMessage("Payment was cancelled", context);
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
  void _clearAllData() {
    final checkoutVM = Provider.of<CheckoutBeautySalonViewModel>(context, listen: false);
    checkoutVM.reset();

    _fullNameController.clear();
    _phoneController.clear();
    _addressController.clear();
    _specialRequestController.clear();
    _dateController.clear();
  }
  Future<void> _handleConfirmBooking() async {
    final checkoutVM = Provider.of<CheckoutBeautySalonViewModel>(context, listen: false);
    final bookingViewModel = Provider.of<PostBookPremiumHomeBeautySalonViewModel>(context, listen: false);

    // Calculate total amount
    double subtotal = checkoutVM.calculateTotal(
      serviceQuantities: widget.serviceQuantities,
      categories: widget.categories,
    );
    double totalAmount = subtotal + widget.transportFee;

    // Validate form
    String? validationError = checkoutVM.validateCheckoutForm(
      fullName: _fullNameController.text,
      phone: _phoneController.text,
      address: _addressController.text,
      selectedDate: checkoutVM.selectedDate,
      serviceTime: checkoutVM.selectedServiceTime,
      paymentMethod: checkoutVM.selectedPaymentMethod,
    );

    if (validationError != null) {
      Utils.flushBarErrorMessage(validationError, context);
      return;
    }

    // Prepare tasks data
    List<Map<String, dynamic>> tasks = checkoutVM.prepareTasksData(
      serviceQuantities: widget.serviceQuantities,
      categories: widget.categories,
    );

    // Prepare booking data
    Map<String, dynamic> bookingData = checkoutVM.prepareBookingData(
      userId: widget.userId,
      fullName: _fullNameController.text,
      phone: _phoneController.text,
      address: _addressController.text,
      specialRequest: _specialRequestController.text,
      selectedDate: checkoutVM.selectedDate!,
      serviceTime: checkoutVM.selectedServiceTime!,
      tasks: tasks,
      paymentMethod: checkoutVM.selectedPaymentMethod,
    );

    print('Booking Data: $bookingData');

    try {
      // Call booking API
      await bookingViewModel.bookPremiumHomeBeautySalonPostApi(
        context,
        bookingData,
            (String? paymentUrl, String? trackingId) async {
          print('Success! TrackingId: $trackingId');

          // If trackingId is null or empty, something went wrong
          if (trackingId == null || trackingId.isEmpty) {
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
            return;
          }

          if (checkoutVM.selectedPaymentMethod == 'online') {
            // Initiate SSL Commerz payment
            final paymentResult = await checkoutVM.initiatePayment(
              trackingId: trackingId,
              totalAmount: totalAmount,
            );
            await _handlePaymentResult(
              viewModel: checkoutVM,
              paymentResult: paymentResult,
              trackingId: trackingId,
            );
          } else if (checkoutVM.selectedPaymentMethod == 'cash') {
            _clearAllData();
            Navigator.pop(context);
            Navigator.pushNamed(
              context,
              RoutesName.beautyConfirmedScreen,
              arguments: {
                'trackingId': trackingId,
                'valId': "COD",
              },
            );
          } else {
            // Unknown payment method
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
        },
      );
    } catch (e) {
      // Handle any exceptions during booking
      print('Booking error: $e');

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

  @override
  Widget build(BuildContext context) {
    return Consumer2<CheckoutBeautySalonViewModel, PostBookPremiumHomeBeautySalonViewModel>(
      builder: (context, checkoutVM, bookingVM, _) {
        double subtotal = checkoutVM.calculateTotal(
          serviceQuantities: widget.serviceQuantities,
          categories: widget.categories,
        );
        double total = subtotal + widget.transportFee;
        double saved = checkoutVM.calculateSaved(
          serviceQuantities: widget.serviceQuantities,
          categories: widget.categories,
        );

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
                  // Header
                  GestureDetector(
                    onTap: () => Navigator.pop(context, false),
                    child: Container(
                      height: 60,
                      child: AppBarHeader("Checkout"),
                    ),
                  ),

                  // Form Content
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildCustomerDetailsCard(),
                          SizedboxSpaccing.height015(context),
                          _buildDateSelection(checkoutVM),
                          SizedboxSpaccing.height015(context),
                          _buildTimeSelection(checkoutVM),
                          SizedboxSpaccing.height02(context),
                          _buildPaymentMethodSection(checkoutVM),
                        ],
                      ),
                    ),
                  ),

                  // Bottom Confirm Button
                  _buildConfirmButton(
                    context,
                    checkoutVM,
                    bookingVM,
                    total,
                    saved,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

// Add this method inside _CheckoutScreenState class

// ✅ Handle Edit Address Navigation
  Future<void> _handleEditAddress() async {
    final result = await Navigator.pushNamed(
      context,
      RoutesName.addLocationScreenWidget,
    );

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

        // ✅ Notify parent (BookNowScreen) about address update
        if (widget.onAddressUpdate != null && newAddress.isNotEmpty) {
          widget.onAddressUpdate!(newAddress);
        }
      });
    }
  }

// ✅ Update the Edit button in _buildCustomerDetailsCard method
  Widget _buildCustomerDetailsCard() {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.textFieldFill(context).withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Customer Details',
                  style: AppTextStyles.textSize14(context, weight: FontWeight.w500)),
              GestureDetector(
                onTap: _handleEditAddress, // ✅ Updated
                child: Container(
                  width: 80,
                  color: Colors.transparent,
                  alignment: Alignment.centerRight,
                  child: Text('Edit',
                      style: AppTextStyles.textSize14(context, weight: FontWeight.w500)),
                ),
              ),
            ],
          ),
          SizedboxSpaccing.height01(context),
          _buildDetailRow('Name', widget.customerName),
          SizedboxSpaccing.height01(context),
          _buildDetailRow('Phone', widget.customerPhone),
          SizedboxSpaccing.height01(context),
          _buildDetailRow('Address', _addressController.text.isEmpty ? widget.customerAddress : _addressController.text, isMultiline: true), // ✅ Use controller text if available
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isMultiline = false}) {
    if (isMultiline) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label :  ',
              style: AppTextStyles.textSize14(context, weight: FontWeight.w400)),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.textSize14(
                context,
                weight: FontWeight.w500,
                color: AppColors.subtitle(context),
              ),
              maxLines: null,
              softWrap: true,
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        Text('$label :  ',
            style: AppTextStyles.textSize14(context, weight: FontWeight.w400)),
        Text(value,
            style: AppTextStyles.textSize14(
                context,
                weight: FontWeight.w500,
                color: AppColors.subtitle(context))),
      ],
    );
  }

  Widget _buildDateSelection(CheckoutBeautySalonViewModel viewModel) {
    return CustomDatePickerFormField(
      title: 'Choose Date',
      controller: _dateController,
      onDateSelected: (DateTime selectedDate) {
        viewModel.setSelectedDate(selectedDate);
      },
      titleTextStyle: AppTextStyles.textSize16(context, weight: FontWeight.w500),
      inputTextStyle: AppTextStyles.textSize14(context, weight: FontWeight.w400),
      hintTextStyle: AppTextStyles.textSize14(
        context,
        weight: FontWeight.w400,
        color: AppColors.subtitle(context),
      ),
    );
  }

  Widget _buildTimeSelection(CheckoutBeautySalonViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Select Service Time',
            style: AppTextStyles.textSize16(context, weight: FontWeight.w500)),
        SizedBox(height: 4),
        Text('Select 1 out of ${viewModel.serviceTimeSlots.length} options',
            style: AppTextStyles.textSize12(context, color: AppColors.subtitle(context))),
        SizedboxSpaccing.height01(context),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: viewModel.serviceTimeSlots
              .map((time) => _serviceTimeButton(viewModel, time))
              .toList(),
        ),
      ],
    );
  }

  Widget _serviceTimeButton(CheckoutBeautySalonViewModel viewModel, String time) {
    bool isSelected = viewModel.selectedServiceTime == time;
    return GestureDetector(
      onTap: () => viewModel.setServiceTime(time),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.containerBackground(context),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected ? AppColors.button(context) : AppColors.border(context),
            width: 1,
          ),
        ),
        child: Text(
          time,
          style: AppTextStyles.textSize14(
            context,
            weight: isSelected ? FontWeight.w600 : FontWeight.w400,
            color: isSelected
                ? AppColors.button(context)
                : AppColors.textPrimary(context),
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentMethodSection(CheckoutBeautySalonViewModel viewModel) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.containerBackground(context),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(width: 1, color: AppColors.border(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(screenHeight * 0.02),
            child: Text('Payment Method',
                style: AppTextStyles.textSize18(context, weight: FontWeight.w500)),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: screenHeight * 0.02),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.border(context), width: 1)),
            ),
            child: Column(
              children: viewModel.paymentMethods.asMap().entries.map((entry) {
                final index = entry.key;
                final methodData = entry.value;
                return _buildPaymentMethodItem(
                  viewModel,
                  methodData,
                  index,
                  viewModel.paymentMethods.length,
                  screenHeight,
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodItem(
      CheckoutBeautySalonViewModel viewModel,
      Map<String, dynamic> methodData,
      int index,
      int totalCount,
      double screenHeight,
      ) {
    final method = methodData['method'];
    final title = methodData['title'];
    final iconName = methodData['icon'];
    final iconColor = Color(methodData['color']);
    final isSelected = viewModel.selectedPaymentMethod == method;

    // Map icon names to FontAwesome icons
    final icon = iconName == 'wallet'
        ? FontAwesomeIcons.wallet
        : FontAwesomeIcons.sackDollar;

    return Padding(
      padding: EdgeInsets.only(
        top: screenHeight * 0.015,
        bottom: index == totalCount - 1 ? screenHeight * 0.015 : screenHeight * 0.01,
      ),
      child: GestureDetector(
        onTap: () => viewModel.setPaymentMethod(method),
        child: Container(
          padding: EdgeInsets.all(screenHeight * 0.015),
          decoration: BoxDecoration(
            color: AppColors.textFieldFill(context),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    height: 32,
                    width: 32,
                    decoration: BoxDecoration(
                      color: iconColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, size: 16, color: AppColors.whiteColor),
                  ),
                  SizedboxSpaccing.width03(context),
                  Text(title,
                      style: AppTextStyles.textSize16(context, weight: FontWeight.w400)),
                ],
              ),
              Container(
                height: 24,
                width: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? AppColors.button(context)
                        : AppColors.border(context),
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? Center(
                  child: Container(
                    height: 12,
                    width: 12,
                    decoration: BoxDecoration(
                      color: AppColors.button(context),
                      shape: BoxShape.circle,
                    ),
                  ),
                )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConfirmButton(
      BuildContext context,
      CheckoutBeautySalonViewModel checkoutVM,
      PostBookPremiumHomeBeautySalonViewModel bookingVM,
      double total,
      double saved,
      ) {
    int totalItems = checkoutVM.getTotalItems(widget.serviceQuantities);
    bool isLoading = bookingVM.createBookPremiumHomeBeautySalonLoading;

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
                Text(
                  'Total Services ($totalItems item${totalItems > 1 ? 's' : ''})',
                  style: AppTextStyles.textSize12(context, color: AppColors.whiteColor),
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '৳${total.toStringAsFixed(2)}',
                      style: AppTextStyles.textSize18(
                        context,
                        weight: FontWeight.w600,
                        color: AppColors.whiteColor,
                      ),
                    ),
                    if (saved > 0) ...[
                      SizedBox(width: 8),
                      Text(
                        'Saved ৳${saved.toStringAsFixed(2)}',
                        style: AppTextStyles.textSize12(
                          context,
                          color: Colors.green,
                          weight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: isLoading ? null : _handleConfirmBooking,
            child: Container(
              height: 40,
              width: 120,
              decoration: BoxDecoration(
                color: isLoading
                    ? AppColors.blackColor.withOpacity(0.6)
                    : AppColors.blackColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(width: 1, color: AppColors.whiteColor),
              ),
              child: isLoading
                  ? Center(
                child: LoadingAnimationWidget.progressiveDots(
                  color: AppColors.whiteColor,
                  size: 30,
                ),
              )
                  : Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Confirm',
                      style: AppTextStyles.textSize16(
                        context,
                        weight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward, color: Colors.white, size: 18),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}