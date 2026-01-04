import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/components/header_appbar.dart';
import 'package:dinmajur_customer/configs/res/sizedbox_spaccing.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:dinmajur_customer/configs/responsive/responsive_ui.dart';
import 'package:dinmajur_customer/configs/utils/routes/routes_name.dart';
import 'package:dinmajur_customer/configs/utils/utils.dart';
import 'package:dinmajur_customer/configs/widgets/customtext_with_formfield.dart';
import 'package:dinmajur_customer/view/screens/home/payment_webview_helper_class/payment_webview.dart';
import 'package:dinmajur_customer/view_model/homeview_model/dropdown_categories_selection_view_models/premium_house_keeper_view_model/book_premium_house_keeper_view_model.dart';
import 'package:dinmajur_customer/view_model/homeview_model/dropdown_categories_selection_view_models/premium_house_keeper_view_model/getall_premium_house_keeper_task_view_model.dart';
import 'package:dinmajur_customer/view_model/homeview_model/dropdown_categories_selection_view_models/premium_house_keeper_view_model/getall_shifttime_view_model.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CheckoutScreen extends StatefulWidget {
  final Map<String, int> serviceQuantities;
  final Map<String, Set<String>> selectedTaskItems;
  final String selectedFrequency;
  final String selectedDate;
  final String selectedTime;
  final String customerName;
  final String customerPhone;
  final String customerAddress;
  final VoidCallback onSuccess;

  const CheckoutScreen({
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
  }) : super(key: key);

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _specialRequestController = TextEditingController();
  String? _selectedHouseSize;

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

  double _calculateTotal() {
    final viewModel = Provider.of<GetallPremiumHouseKeeperTaskViewModel>(context, listen: false);
    final data = viewModel.getAllPremiumHouseKeeperTaskData.data?.data ?? [];

    double total = 0;
    data.forEach((service) {
      int qty = widget.serviceQuantities[service.id ?? ''] ?? 0;
      if (qty > 0 && service.houseKeeperTaskItems?.isNotEmpty == true) {
        Set<String> selectedItems = widget.selectedTaskItems[service.id ?? ''] ??
            service.houseKeeperTaskItems!.map((item) => item.id ?? '').toSet();

        double price = 0;
        for (var item in service.houseKeeperTaskItems!) {
          if (selectedItems.contains(item.id ?? '')) {
            price += item.price?.toDouble() ?? 0;
          }
        }

        if (service.discountType != null && service.discountValue != null && price > 0) {
          if (service.discountType == 'PERCENTAGE') {
            price = price - (price * service.discountValue! / 100);
          } else if (service.discountType == 'FIXED') {
            price = price - service.discountValue!.toDouble();
          }
        }

        total += price * qty;
      }
    });
    return total;
  }

  double _calculateSaved() {
    final viewModel = Provider.of<GetallPremiumHouseKeeperTaskViewModel>(context, listen: false);
    final data = viewModel.getAllPremiumHouseKeeperTaskData.data?.data ?? [];

    double saved = 0;
    data.forEach((service) {
      int qty = widget.serviceQuantities[service.id ?? ''] ?? 0;
      if (qty > 0 && service.houseKeeperTaskItems?.isNotEmpty == true && service.discountValue != null) {
        Set<String> selectedItems = widget.selectedTaskItems[service.id ?? ''] ??
            service.houseKeeperTaskItems!.map((item) => item.id ?? '').toSet();

        double originalPrice = 0;
        for (var item in service.houseKeeperTaskItems!) {
          if (selectedItems.contains(item.id ?? '')) {
            originalPrice += item.price?.toDouble() ?? 0;
          }
        }

        double discount = 0;
        if (service.discountType == 'PERCENTAGE') {
          discount = originalPrice * service.discountValue! / 100;
        } else if (service.discountType == 'FIXED') {
          discount = service.discountValue!.toDouble();
        }

        saved += discount * qty;
      }
    });
    return saved;
  }

  int _getTotalItems() {
    return widget.serviceQuantities.entries.where((entry) => entry.value > 0).length;
  }

  Future<void> _handleConfirm() async {
    // Validate required fields
    if (_phoneController.text.isEmpty) {
      Utils.flushBarErrorMessage("Phone number is required", context);
      return;
    }
    if (_addressController.text.isEmpty) {
      Utils.flushBarErrorMessage("Service address is required", context);
      return;
    }
    if (_selectedHouseSize == null) {
      Utils.flushBarErrorMessage("Please select house size", context);
      return;
    }
    if (selectedPaymentMethod == null) {
      Utils.flushBarErrorMessage("Please select a payment method", context);
      return;
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');

    // Prepare tasks data
    List<Map<String, dynamic>> tasks = [];
    final viewModel = Provider.of<GetallPremiumHouseKeeperTaskViewModel>(context, listen: false);
    final data = viewModel.getAllPremiumHouseKeeperTaskData.data?.data ?? [];

    data.forEach((service) {
      int qty = widget.serviceQuantities[service.id ?? ''] ?? 0;
      if (qty > 0) {
        Set<String> selectedItems = widget.selectedTaskItems[service.id ?? ''] ??
            service.houseKeeperTaskItems?.map((item) => item.id ?? '').toSet() ?? {};

        if (selectedItems.isNotEmpty) {
          tasks.add({
            "houseKeeperTaskId": service.id,
            "totalRooms": qty,
            "houseKeeperTaskItemIds": selectedItems.toList()
          });
        }
      }
    });

    // Get shift time ID from selected time
    final shiftTimeViewModel = Provider.of<GetallShifttimeViewModel>(context, listen: false);
    final shiftTimes = shiftTimeViewModel.getAllShiftTimeData.data?.data ?? [];
    String? shiftId;

    for (var shift in shiftTimes) {
      String displayText = '${shift.type ?? ''} (${shift.startTime ?? ''}-${shift.endTime ?? ''})';
      if (displayText == widget.selectedTime) {
        shiftId = shift.shiftId;
        break;
      }
    }

    if (shiftId == null) {
      Utils.flushBarErrorMessage("Invalid time selection", context);
      return;
    }

    // Get payment method data
    Map<String, dynamic> paymentData = _getPaymentMethodData(selectedPaymentMethod);

    Map<String, dynamic> bookingData = {
      "userId": userId.toString(),
      "district": "Chittagong",
      "area": "N/A",
      "planType": widget.selectedFrequency.toUpperCase(),
      "fullName": _fullNameController.text.trim(),
      "phone": _phoneController.text.trim(),
      "fullAddress": _addressController.text.trim(),
      "houseSize": _selectedHouseSize,
      "notes": _specialRequestController.text.trim().isEmpty
          ? null
          : _specialRequestController.text.trim(),
      "tasks": tasks,
      "couponCode": null,
      "shiftId": shiftId,
      "date": widget.selectedDate,
      "payment": paymentData, // Add payment method data
    };

    print('Booking Data: $bookingData');

    // Call the booking API with success callback
    final bookingViewModel = Provider.of<PostBookPremiumHouseKeeperViewModel>(context, listen: false);

    await bookingViewModel.bookPremiumHouseKeeperPostApi(
      context,
      bookingData,
          (String? paymentUrl, String? trackingId) async {
        print('Success! Payment URL: $paymentUrl, TrackingId: $trackingId');

        // Pop the checkout screen
        Navigator.pop(context);

        // Call parent success callback
        widget.onSuccess();

        // If payment URL is available, open WebView for payment
        if (paymentUrl != null && paymentUrl.isNotEmpty) {
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

          // Handle payment result
          if (result != null && result is Map<String, dynamic>) {
            String status = result['status'] ?? '';

            if (status == 'success') {
              // Payment successful - navigate to confirmed screen
              print('--------------------------x');
              Navigator.pushNamed(
                context,
                RoutesName.confirmedScreen,
                arguments: {'trackingId': trackingId ?? ''},
              );
            } else if (status == 'failed') {
              print('--------------------------y');
              // Payment failed
              Utils.flushBarErrorMessage("Payment failed. Please try again.", context);
            } else if (status == 'cancelled') {
              print('--------------------------Z');
              // Payment cancelled
              Utils.flushBarExclamatoryMessage(
                title: "Payment Cancelled",
                subtitle: "You cancelled the payment process.",
                context: context,
              );
            }
          }
        } else if (selectedPaymentMethod == 'cash') {
          // For cash on delivery, directly go to confirmed screen
          Navigator.pushNamed(
            context,
            RoutesName.confirmedScreen,
            arguments: {'trackingId': trackingId ?? ''},
          );
        } else {
          // No payment URL received
          Utils.flushBarErrorMessage("Payment gateway URL not available", context);
        }
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    double subtotal = _calculateTotal();
    double transport = 80.0;
    double total = subtotal + transport;
    double saved = _calculateSaved();

    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.containerBackground(context),
        body: ResPonsiveUi(
          mobile: _buildBody(context, screenWidth, total, saved),
          desktop: _buildBody(context, screenWidth, total, saved),
          tablet: _buildBody(context, screenWidth, total, saved),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, double screenWidth, double total, double saved) {
    return Column(
      children: [
        // Header AppBar
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
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.textFieldFill(context).withOpacity(0.5),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.border(context)),
                  ),
                  child:Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                              height: 24,
                              alignment: Alignment.centerLeft,
                              child: Text('Customer Details', style: AppTextStyles.textSize14(context, weight: FontWeight.w500))),
                          Container(
                              height: 24,
                              width: 50,
                              color: Colors.transparent,
                              alignment: Alignment.centerRight,
                              child: Text('Edit', style: AppTextStyles.textSize14(context, weight: FontWeight.w500))),
                        ],
                      ),
                      SizedboxSpaccing.height01(context),
                      Row(
                        children: [
                          Text('Name :  ', style: AppTextStyles.textSize14(context, weight: FontWeight.w400)),
                          Text('${widget.customerName}', style: AppTextStyles.textSize14(context, weight: FontWeight.w500,color: AppColors.subtitle(context))),
                        ],
                      ),
                      SizedboxSpaccing.height01(context),
                      Row(
                        children: [
                          Text('Phone :  ', style: AppTextStyles.textSize14(context, weight: FontWeight.w400)),
                          Text('${widget.customerPhone}', style: AppTextStyles.textSize14(context, weight: FontWeight.w500,color: AppColors.subtitle(context))),
                        ],
                      ),
                      SizedboxSpaccing.height01(context),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Address :  ', style: AppTextStyles.textSize14(context, weight: FontWeight.w400)),
                          Expanded(
                            child: Text(
                              '${widget.customerAddress}',
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
                      ),

                    ],
                  ) ,
                ),
                SizedboxSpaccing.height02(context),

                Text('Select house size', style: AppTextStyles.textSize16(context, weight: FontWeight.w500)),
                SizedBox(height: 4),
                Text('Select 1 out of 5 options', style: AppTextStyles.textSize12(context, color: AppColors.subtitle(context))),
                SizedboxSpaccing.height01(context),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _houseSizeButton('500-1000 sq ft'),
                    _houseSizeButton('1000-1700 sq ft'),
                    _houseSizeButton('1700-3000 sq ft'),
                    _houseSizeButton('Above 3000 sq ft'),
                  ],
                ),
                SizedboxSpaccing.height02(context),
                _buildPaymentMethodSection(),
              ],
            ),
          ),
        ),

        // Bottom Confirm Button
        _buildBottomConfirmButton(context, total, saved),
      ],
    );
  }
  // Payment method
  String? selectedPaymentMethod;

  // Payment methods data
  final List<Map<String, dynamic>> paymentMethods = [
    {'method': 'online', 'title': 'Online Payment', 'icon': FontAwesomeIcons.wallet, 'color': Color(0xFFEE4237)},
    {'method': 'bkash', 'title': 'bkash', 'icon': FontAwesomeIcons.wallet, 'color': Color(0xFFE2136E)},
    {'method': 'cash', 'title': 'Hand Cash', 'icon': FontAwesomeIcons.sackDollar, 'color': Color(0xFF45A986)},
  ];
  Map<String, dynamic> _getPaymentMethodData(String? method) {
    switch (method) {
      case 'online':
        return {
          "type": "WALLET",
          "provider": "online"
        };
      case 'bkash':
        return {
          "type": "WALLET",
          "provider": "bkash"
        };

      case 'cash':
        return {
          "type": "OTHER",
          "provider": "cash_on_delivery"
        };
      default:
        return {
          "type": "OTHER",
          "provider": "cash_on_delivery"
        };
    }
  }

  Widget _buildPaymentMethodSection() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      width: screenWidth * 0.9,
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
            child: Text('Payment Method', style: AppTextStyles.textSize18(context, weight: FontWeight.w500)),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: screenHeight * 0.02),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.border(context), width: 1)),
            ),
            child: Column(
              children: paymentMethods.asMap().entries.map((entry) {
                final index = entry.key;
                final methodData = entry.value;
                final method = methodData['method'];
                final title = methodData['title'];
                final icon = methodData['icon'];
                final iconColor = methodData['color'];
                final isSelected = selectedPaymentMethod == method;

                return Padding(
                  padding: EdgeInsets.only(top: screenHeight * 0.015, bottom: index == paymentMethods.length - 1 ? screenHeight * 0.015 : screenHeight * 0.01),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedPaymentMethod = method;
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.all(screenHeight * 0.015),
                      decoration: BoxDecoration(color: AppColors.textFieldFill(context), borderRadius: BorderRadius.circular(12)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                height: 32,
                                width: 32,
                                decoration: BoxDecoration(color: iconColor, borderRadius: BorderRadius.circular(8)),
                                child: Icon(icon, size: 16, color: AppColors.whiteColor),
                              ),
                              SizedboxSpaccing.width03(context),
                              Text(title, style: AppTextStyles.textSize16(context, weight: FontWeight.w400)),
                            ],
                          ),
                          Container(
                            height: 24,
                            width: 24,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: isSelected ? AppColors.button(context) : AppColors.border(context), width: 2),
                            ),
                            child: isSelected
                                ? Center(
                              child: Container(
                                height: 12,
                                width: 12,
                                decoration: BoxDecoration(color: AppColors.button(context), shape: BoxShape.circle),
                              ),
                            )
                                : null,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _houseSizeButton(String size) {
    bool isSelected = _selectedHouseSize == size;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedHouseSize = size;
        });
      },
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
            color: isSelected ? AppColors.button(context) : AppColors.textPrimary(context),
          ),
        ),
      ),
    );
  }





  Widget _buildBottomConfirmButton(BuildContext context, double total, double saved) {
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
                  'Total Services (${_getTotalItems()} item${_getTotalItems() > 1 ? 's' : ''})',
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
            child: Consumer<PostBookPremiumHouseKeeperViewModel>(
              builder: (context, bookingViewModel, _) {
                return Container(
                  height: 40,
                  width: 120,
                  decoration: BoxDecoration(
                    color: AppColors.blackColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(width: 1, color: AppColors.whiteColor),
                  ),
                  child: bookingViewModel.createBookPremiumHouseKeeperLoading
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
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}