import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/sizedbox_spaccing.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:dinmajur_customer/configs/utils/utils.dart';
import 'package:dinmajur_customer/configs/widgets/customtext_with_formfield.dart';
import 'package:dinmajur_customer/configs/widgets/datepicker_with_formfield.dart';
import 'package:dinmajur_customer/model/home_models/dropdown_categories_selection_models/beauty_and_salon_model/getall_premium_home_beauty_salon_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class CheckoutDialog extends StatefulWidget {
  final String customerName;
  final String customerPhone;
  final String customerAddress;
  final String userId;
  final List<Datum> categories;
  final Map<String, int> serviceQuantities;
  final double totalPrice;
  final double transportFee;
  final bool isLoading; // ADD THIS
  final Function(Map<String, dynamic>) onConfirmBooking;

  const CheckoutDialog({
    Key? key,
    required this.customerName,
    required this.customerPhone,
    required this.customerAddress,
    required this.userId,
    required this.categories,
    required this.serviceQuantities,
    required this.totalPrice,
    required this.transportFee,
    this.isLoading = false, // ADD THIS
    required this.onConfirmBooking,
  }) : super(key: key);

  @override
  State<CheckoutDialog> createState() => _CheckoutDialogState();
}

class _CheckoutDialogState extends State<CheckoutDialog> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _specialRequestController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  String? _selectedServiceTime;
  DateTime? _selectedDate;

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
    _dateController.dispose();
    super.dispose();
  }

  void _handleConfirmBooking() {
    // Validation
    if (_fullNameController.text.trim().isEmpty) {
      Utils.flushBarErrorMessage('Please enter your full name',context);
      return;
    }

    if (_phoneController.text.trim().isEmpty) {
      Utils.flushBarErrorMessage('Please enter your phone number',context);
      return;
    }

    if (_selectedDate == null || _dateController.text.trim().isEmpty) {
      Utils.flushBarErrorMessage('Please select a date',context);
      return;
    }

    if (_selectedServiceTime == null) {
      Utils.flushBarErrorMessage('Please select a service time',context);
      return;
    }

    if (_addressController.text.trim().isEmpty) {
      Utils.flushBarErrorMessage('Please enter your address',context);
      return;
    }

    // Prepare tasks array in the required format
    List<Map<String, dynamic>> tasks = [];

    widget.categories.forEach((category) {
      category.items?.forEach((service) {
        int qty = widget.serviceQuantities[service.id ?? ''] ?? 0;
        if (qty > 0) {
          tasks.add({
            'beautySalonTaskId': category.id, // Category ID as task ID
            'quantity': qty,
            'subTasks': [
              {
                'beautySalonTaskItemId': service.id, // Service ID as subtask ID
              },
            ],
          });
        }
      });
    });

    // Format date as YYYY-MM-DD
    String formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate!);

    // Prepare booking data in exact format
    Map<String, dynamic> bookingData = {
      'userId': widget.userId,
      'fullName': _fullNameController.text.trim(),
      'time': _selectedServiceTime,
      'phone': _phoneController.text.trim(),
      'fullAddress': _addressController.text.trim(),
      'notes': _specialRequestController.text.trim(),
      'date': formattedDate,
      'tasks': tasks,
    };

    // Call the callback with booking data
    widget.onConfirmBooking(bookingData);
  }
  int _getTotalItems() {
    return widget.serviceQuantities.entries.where((entry) => entry.value > 0).length;
  }
  // Calculate saved amount
  double _calculateSaved() {
    double saved = 0;
    widget.categories.forEach((category) {
      category.items?.forEach((service) {
        int qty = widget.serviceQuantities[service.id ?? ''] ?? 0;
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
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final double finalTotal = widget.totalPrice + widget.transportFee;

    return Dialog(
      backgroundColor: AppColors.containerBackground(context),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      insetPadding: EdgeInsets.symmetric(horizontal: screenHeight * 0.02, vertical: screenHeight * 0.02),
      child: Container(
        width: screenWidth,
        constraints: BoxConstraints(maxHeight: screenHeight * 0.85),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            _buildHeader(context),

            // Form Fields
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Customer Information', style: AppTextStyles.textSize16(context, weight: FontWeight.w600)),
                    SizedboxSpaccing.height02(context),

                    // Full Name
                    CustomTextFieldWithFormField(
                      titleText: "Full Name",
                      placeholder: 'Enter your name',
                      controller: _fullNameController,
                      keyboardType: TextInputType.name,
                      isReadOnly: true,
                      titleTextStyle: AppTextStyles.textSize16(context, weight: FontWeight.w500),
                      inputTextStyle: AppTextStyles.textSize14(context, weight: FontWeight.w400),
                      hintTextStyle: AppTextStyles.textSize14(context, weight: FontWeight.w400, color: AppColors.subtitle(context)),
                    ),
                    SizedBox(height: 4),
                    _buildInfoRow('Enter your full legal name', context),
                    SizedboxSpaccing.height015(context),

                    // Phone Number
                    CustomTextFieldWithFormField(
                      titleText: 'Phone Number',
                      placeholder: 'Enter your number',
                      controller: _phoneController,
                      keyboardType: TextInputType.number,
                      isReadOnly: true,
                      titleTextStyle: AppTextStyles.textSize16(context, weight: FontWeight.w500),
                      inputTextStyle: AppTextStyles.textSize14(context, weight: FontWeight.w400),
                      hintTextStyle: AppTextStyles.textSize14(context, weight: FontWeight.w400, color: AppColors.subtitle(context)),
                    ),
                    SizedBox(height: 4),
                    _buildInfoRow('We\'ll use this to confirm your appointment', context),

                    SizedboxSpaccing.height015(context),

                    // Date Selection
                    CustomDatePickerFormField(
                      title: 'Choose Date',
                      controller: _dateController,
                      onDateSelected: (DateTime selectedDate) {
                        setState(() {
                          _selectedDate = selectedDate;
                        });
                      },
                      titleTextStyle: AppTextStyles.textSize16(context, weight: FontWeight.w500),
                      inputTextStyle: AppTextStyles.textSize14(context, weight: FontWeight.w400),
                      hintTextStyle: AppTextStyles.textSize14(context, weight: FontWeight.w400, color: AppColors.subtitle(context)),
                    ),

                    SizedboxSpaccing.height015(context),

                    // Service Time Selection
                    Text('Select Service Time', style: AppTextStyles.textSize16(context, weight: FontWeight.w500)),
                    SizedBox(height: 4),
                    Text('Select 1 out of 8 options', style: AppTextStyles.textSize12(context, color: AppColors.subtitle(context))),
                    SizedboxSpaccing.height01(context),
                    _buildTimeSelection(),

                    SizedboxSpaccing.height015(context),

                    // Service Address
                    _buildAddressField(context),

                    SizedboxSpaccing.height015(context),

                    // Special Request
                    _buildSpecialRequestField(context),

                    SizedboxSpaccing.height015(context),


                  ],
                ),
              ),
            ),

            // Confirm Button
            _buildConfirmButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border(context), width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Checkout', style: AppTextStyles.textSize20(context, weight: FontWeight.w700)),
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
    );
  }

  Widget _buildInfoRow(String text, BuildContext context) {
    return Row(
      children: [
        Icon(Icons.info_outline, size: 14, color: AppColors.subtitle(context)),
        SizedBox(width: 4),
        Text(text, style: AppTextStyles.textSize12(context, color: AppColors.subtitle(context))),
      ],
    );
  }

  Widget _buildTimeSelection() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _serviceTimeButton('09:30 - 10:00 am'),
        _serviceTimeButton('10:30 - 11:00 am'),
        _serviceTimeButton('11:30 - 12:00 pm'),
        _serviceTimeButton('02:00 - 02:30 pm'),
        _serviceTimeButton('03:00 - 03:30 pm'),
        _serviceTimeButton('04:00 - 04:30 pm'),
        _serviceTimeButton('05:00 - 05:30 pm'),
        _serviceTimeButton('06:00 - 06:30 pm'),
      ],
    );
  }

  Widget _serviceTimeButton(String time) {
    bool isSelected = _selectedServiceTime == time;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedServiceTime = time;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        decoration: BoxDecoration(
          color:  AppColors.containerBackground(context),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: isSelected ? AppColors.button(context) : AppColors.border(context), width: 1),
        ),
        child: Text(
          time,
          style: AppTextStyles.textSize14(context, weight: isSelected ? FontWeight.w600 : FontWeight.w400, color: isSelected ? AppColors.button(context) : AppColors.textPrimary(context)),
        ),
      ),
    );
  }

  Widget _buildAddressField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Service Address', style: AppTextStyles.textSize16(context, weight: FontWeight.w500)),
            Text(
              ' *',
              style: AppTextStyles.textSize14(context, weight: FontWeight.w500, color: Colors.red),
            ),
          ],
        ),
        SizedboxSpaccing.height01(context),
        Container(
          decoration: BoxDecoration(
            color: AppColors.textFieldFill(context),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(width: 1, color: AppColors.border(context)),
          ),
          child: TextField(
            controller: _addressController,
            maxLines: 3,
            style: AppTextStyles.textSize14(context, weight: FontWeight.w400),
            decoration: InputDecoration(
              hintText: 'Enter your address',
              hintStyle: AppTextStyles.textSize14(context, weight: FontWeight.w400, color: AppColors.subtitle(context)),
              border: OutlineInputBorder(borderSide: BorderSide.none),
              contentPadding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSpecialRequestField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Special Requests or Instructions (Optional)', style: AppTextStyles.textSize16(context, weight: FontWeight.w500)),
        SizedboxSpaccing.height01(context),
        Container(
          decoration: BoxDecoration(
            color: AppColors.textFieldFill(context),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(width: 1, color: AppColors.border(context)),
          ),
          child: TextField(
            controller: _specialRequestController,
            maxLines: 3,
            style: AppTextStyles.textSize14(context, weight: FontWeight.w400),
            decoration: InputDecoration(
              hintText: 'Write any request or instruction or suggestion.',
              hintStyle: AppTextStyles.textSize14(context, weight: FontWeight.w400, color: AppColors.subtitle(context)),
              border: OutlineInputBorder(borderSide: BorderSide.none),
              contentPadding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPriceSummary(BuildContext context, double finalTotal) {
    return Container(
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.button(context).withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Services Total', style: AppTextStyles.textSize14(context)),
              Text('৳${widget.totalPrice.toStringAsFixed(2)}', style: AppTextStyles.textSize14(context, weight: FontWeight.w600)),
            ],
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Transport Fee', style: AppTextStyles.textSize14(context)),
              Text('৳${widget.transportFee.toStringAsFixed(2)}', style: AppTextStyles.textSize14(context, weight: FontWeight.w600)),
            ],
          ),
          Divider(height: 20, thickness: 1),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total Amount', style: AppTextStyles.textSize16(context, weight: FontWeight.w600)),
              Text(
                '৳${finalTotal.toStringAsFixed(2)}',
                style: AppTextStyles.textSize18(context, weight: FontWeight.w700, color: AppColors.button(context)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmButton(BuildContext context) {
    final double total = widget.totalPrice + widget.transportFee;
    final double saved = _calculateSaved();

    return Container(
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.button(context),
        border: Border(top: BorderSide(color: AppColors.border(context), width: 1)),
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(12), bottomRight: Radius.circular(12)),
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
                      style: AppTextStyles.textSize18(context, weight: FontWeight.w600, color: AppColors.whiteColor),
                    ),
                    if (saved > 0) ...[
                      SizedBox(width: 8),
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
          GestureDetector(
            onTap: widget.isLoading ? null : _handleConfirmBooking,
            child: Container(
              height: 40,
              width: 120,
              decoration: BoxDecoration(
                color: widget.isLoading ? AppColors.blackColor.withOpacity(0.6) : AppColors.blackColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(width: 1, color: AppColors.whiteColor),
              ),
              child: widget.isLoading
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
                      style: AppTextStyles.textSize16(context, weight: FontWeight.w600, color: Colors.white),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward, color: Colors.white, size: 18),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

// Widget _buildConfirmButton(BuildContext context, double screenWidth) {
  //   return Padding(
  //     padding: EdgeInsets.all(15),
  //     child: GestureDetector(
  //       onTap: widget.isLoading ? null : _handleConfirmBooking,
  //       child: Container(
  //         width: screenWidth,
  //         height: 50,
  //         decoration: BoxDecoration(color: widget.isLoading ? AppColors.button(context).withOpacity(0.6) : AppColors.button(context), borderRadius: BorderRadius.circular(8)),
  //         child: Center(
  //           child: widget.isLoading
  //               ? SizedBox(width: 24, height: 24, child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white), strokeWidth: 2))
  //               : Text(
  //                   'Confirm Booking',
  //                   style: AppTextStyles.textSize16(context, weight: FontWeight.w600, color: Colors.white),
  //                 ),
  //         ),
  //       ),
  //     ),
  //   );
  // }
// }
