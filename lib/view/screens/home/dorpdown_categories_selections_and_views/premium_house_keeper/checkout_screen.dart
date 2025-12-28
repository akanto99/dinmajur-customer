import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/components/header_appbar.dart';
import 'package:dinmajur_customer/configs/res/sizedbox_spaccing.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:dinmajur_customer/configs/responsive/responsive_ui.dart';
import 'package:dinmajur_customer/configs/services/ssl_payment_service/ssl_payment.dart';
import 'package:dinmajur_customer/configs/utils/routes/routes_name.dart';
import 'package:dinmajur_customer/configs/utils/utils.dart';
import 'package:dinmajur_customer/view/screens/home/dorpdown_categories_selections_and_views/premium_house_keeper/notifier/checkout_notifier.dart';
import 'package:dinmajur_customer/view_model/homeview_model/dropdown_categories_selection_view_models/premium_house_keeper_view_model/book_premium_house_keeper_view_model.dart';
import 'package:dinmajur_customer/view_model/homeview_model/dropdown_categories_selection_view_models/premium_house_keeper_view_model/getall_premium_house_keeper_task_view_model.dart';
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
  }) : super(key: key);

  @override
  State<CheckoutHouseKeeperScreen> createState() => _CheckoutHouseKeeperScreenState();
}

class _CheckoutHouseKeeperScreenState extends State<CheckoutHouseKeeperScreen> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _specialRequestController = TextEditingController();

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

  Future<void> _handlePaymentResult({
    required CheckoutViewModel viewModel,
    required SSLPaymentResult paymentResult,
    required String trackingId,
  }) async {
    if (!mounted) return;

    if (paymentResult.success) {
      _clearAllData();
      // Navigator.pop(context);
      Navigator.pushReplacementNamed(
        context,
        RoutesName.confirmedScreen,
        arguments: {
          'trackingId': trackingId,
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

  Future<void> _handleConfirm() async {
    final checkoutViewModel = Provider.of<CheckoutViewModel>(context, listen: false);
    final taskViewModel = Provider.of<GetallPremiumHouseKeeperTaskViewModel>(context, listen: false);
    final shiftTimeViewModel = Provider.of<GetallShifttimeViewModel>(context, listen: false);
    final bookingViewModel = Provider.of<PostBookPremiumHouseKeeperViewModel>(context, listen: false);

    // Validate form
    String? validationError = checkoutViewModel.validateCheckoutForm(
      phone: _phoneController.text,
      address: _addressController.text,
      houseSize: checkoutViewModel.selectedHouseSize,
      paymentMethod: checkoutViewModel.selectedPaymentMethod,
    );

    if (validationError != null) {
      Utils.flushBarErrorMessage(validationError, context);
      return;
    }

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

    // Calculate total
    double subtotal = checkoutViewModel.calculateTotal(
      serviceQuantities: widget.serviceQuantities,
      selectedTaskItems: widget.selectedTaskItems,
      services: services,
    );
    double transport = 80.0;
    double totalAmount = subtotal + transport;

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
    );

    print('Booking Data: $bookingData');

    // Call booking API
    await bookingViewModel.bookPremiumHouseKeeperPostApi(
      context,
      bookingData,
          (String? paymentUrl, String? trackingId) async {
        print('Success! TrackingId: $trackingId');

        if (checkoutViewModel.selectedPaymentMethod == 'online' && trackingId != null) {
          // Initiate SSL Commerz payment
          final paymentResult = await checkoutViewModel.initiatePayment(
            trackingId: trackingId,
            totalAmount: totalAmount,
          );


          await _handlePaymentResult(
            viewModel: checkoutViewModel,
            paymentResult: paymentResult,
            trackingId: trackingId,
          );
        } else if (checkoutViewModel.selectedPaymentMethod == 'cash') {
          _clearAllData();
          Navigator.pop(context);
          widget.onSuccess();

          Navigator.pushNamed(
            context,
            RoutesName.confirmedScreen,
            arguments: {
              'trackingId': trackingId ?? '',
              'valId': "COD",
            },
          );
        } else {
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
  }
  void _clearAllData() {
    final checkoutViewModel = Provider.of<CheckoutViewModel>(context, listen: false);
    checkoutViewModel.reset();

    _fullNameController.clear();
    _phoneController.clear();
    _addressController.clear();
    _specialRequestController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer3<
        CheckoutViewModel,
        GetallPremiumHouseKeeperTaskViewModel,
        PostBookPremiumHouseKeeperViewModel>(
      builder: (context, checkoutVM, taskVM, bookingVM, _) {
        final services = taskVM.getAllPremiumHouseKeeperTaskData.data?.data ?? [];

        double subtotal = checkoutVM.calculateTotal(
          serviceQuantities: widget.serviceQuantities,
          selectedTaskItems: widget.selectedTaskItems,
          services: services,
        );
        double transport = 80.0;
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
              mobile: _buildBody(context, checkoutVM, bookingVM, total, saved),
              desktop: _buildBody(context, checkoutVM, bookingVM, total, saved),
              tablet: _buildBody(context, checkoutVM, bookingVM, total, saved),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBody(
      BuildContext context,
      CheckoutViewModel viewModel,
      PostBookPremiumHouseKeeperViewModel bookingVM,
      double total,
      double saved,
      ) {
    return Column(
      children: [
        // Header
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            height: 60,
            child: AppBarHeader("Checkout"),
          ),
        ),

        // Form Content
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCustomerDetailsCard(),
                SizedboxSpaccing.height02(context),
                _buildHouseSizeSection(viewModel),
                SizedboxSpaccing.height02(context),
                _buildPaymentMethodSection(viewModel),
              ],
            ),
          ),
        ),

        // Bottom Confirm Button
        _buildBottomConfirmButton(context, bookingVM, total, saved, viewModel),
      ],
    );
  }

// Add this method inside _CheckoutHouseKeeperScreenState class

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

  Widget _buildHouseSizeSection(CheckoutViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Select house size',
            style: AppTextStyles.textSize16(context, weight: FontWeight.w500)),
        SizedBox(height: 4),
        Text('Select 1 out of 4 options',
            style: AppTextStyles.textSize12(context, color: AppColors.subtitle(context))),
        SizedboxSpaccing.height01(context),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _houseSizeButton(viewModel, '500-1000 sq ft'),
            _houseSizeButton(viewModel, '1000-1700 sq ft'),
            _houseSizeButton(viewModel, '1700-3000 sq ft'),
            _houseSizeButton(viewModel, 'Above 3000 sq ft'),
          ],
        ),
      ],
    );
  }

  Widget _houseSizeButton(CheckoutViewModel viewModel, String size) {
    bool isSelected = viewModel.selectedHouseSize == size;
    return GestureDetector(
      onTap: () => viewModel.setHouseSize(size),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.containerBackground(context),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.button(context) : AppColors.border(context),
            width: 1,
          ),
        ),
        child: Text(
          size,
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

  Widget _buildPaymentMethodSection(CheckoutViewModel viewModel) {
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
      CheckoutViewModel viewModel,
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

  Widget _buildBottomConfirmButton(
      BuildContext context,
      PostBookPremiumHouseKeeperViewModel bookingVM,
      double total,
      double saved,
      CheckoutViewModel checkoutVM,
      ) {
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
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: _handleConfirm,
            child: Container(
              height: 40,
              width: 120,
              decoration: BoxDecoration(
                color: AppColors.blackColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(width: 1, color: AppColors.whiteColor),
              ),
              child: bookingVM.createBookPremiumHouseKeeperLoading
                  ? Center(
                child: LoadingAnimationWidget.progressiveDots(
                  color: AppColors.whiteColor,
                  size: 50,
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