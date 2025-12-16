import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/sizedbox_spaccing.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:dinmajur_customer/configs/utils/routes/routes_name.dart';
import 'package:dinmajur_customer/configs/utils/utils.dart';
import 'package:dinmajur_customer/configs/widgets/customtext_with_formfield.dart';
import 'package:dinmajur_customer/view_model/homeview_model/dropdown_categories_selection_view_models/premium_house_keeper_view_model/book_premium_house_keeper_view_model.dart';
import 'package:dinmajur_customer/view_model/homeview_model/dropdown_categories_selection_view_models/premium_house_keeper_view_model/getall_premium_house_keeper_task_view_model.dart';
import 'package:dinmajur_customer/view_model/homeview_model/dropdown_categories_selection_view_models/premium_house_keeper_view_model/getall_shifttime_view_model.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CheckoutDialog extends StatefulWidget {
  final Map<String, int> serviceQuantities;
  final Map<String, Set<String>> selectedTaskItems;
  final String selectedFrequency;
  final String selectedDate;
  final String selectedTime;
  final String customerName;
  final String customerPhone;
  final String customerAddress;
  final VoidCallback onSuccess;

  const CheckoutDialog({
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
  State<CheckoutDialog> createState() => _CheckoutDialogState();
}

class _CheckoutDialogState extends State<CheckoutDialog> {
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
    };

    print('Booking Data: $bookingData');

    // Call the booking API with success callback
    final bookingViewModel = Provider.of<PostBookPremiumHouseKeeperViewModel>(context, listen: false);

    await bookingViewModel.bookPremiumHouseKeeperPostApi(context, bookingData, (String trackingId) {
      print('Success! TrackingId: $trackingId');

      // Close checkout dialog
      Navigator.pop(context);

      // Call parent success callback
      widget.onSuccess();

      // Navigate to confirmed screen
      Navigator.pushNamed(context, RoutesName.confirmedScreen, arguments: {'trackingId': trackingId});
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    double subtotal = _calculateTotal();
    double transport = 80.0;
    double total = subtotal + transport;
    double saved = _calculateSaved();

    return Dialog(
      backgroundColor: AppColors.containerBackground(context),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      insetPadding: EdgeInsets.all(15),
      child: Container(
        width: screenWidth,
        constraints: BoxConstraints(maxHeight: screenHeight * 0.7),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(context),
            _buildFormContent(context),
            _buildBottomConfirmButton(context, total, saved),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border(context), width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Checkout', style: AppTextStyles.textSize20(context, weight: FontWeight.w600)),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.button(context).withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.close, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormContent(BuildContext context) {
    return Flexible(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomTextFieldWithFormFieldPoppins(
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

            CustomTextFieldWithFormFieldPoppins(
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

            Row(
              children: [
                Text('Service Address', style: AppTextStyles.textSize16(context, weight: FontWeight.w500)),
                Text(' *', style: AppTextStyles.textSize14(context, weight: FontWeight.w500, color: Colors.red)),
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
            SizedBox(height: 4),
            _buildInfoRow('Include apartment/unit number', context),
            SizedboxSpaccing.height015(context),

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
            SizedboxSpaccing.height015(context),

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
            SizedboxSpaccing.height015(context),

            _buildImportantNotes(context),
          ],
        ),
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

  Widget _buildImportantNotes(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.textFieldFill(context).withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.description_outlined, size: 20, color: AppColors.textPrimary(context)),
              SizedBox(width: 8),
              Text('Important Notes', style: AppTextStyles.textSize16(context, weight: FontWeight.w500)),
            ],
          ),
          SizedBox(height: 8),
          Text(
            'আমরা হাউসকিপিং এর প্রয়োজনীয় উপকরণ সরবরাহ করব। তবে, কিছু বিষয় আমাদের কাস্টম সেবা দ্বারা পরিচালিত হবে:',
            style: AppTextStyles.textSize12(context, color: AppColors.textPrimary(context)),
          ),
          SizedBox(height: 8),
          _buildBulletPoint('ঝাড়ু এবং ফ্যান মুছার সিঁড়ি ব্যবস্থা ক্লায়েন্টদের নিজেই করতে হবে।'),
          _buildBulletPoint('আমরা ভারী জিনিসপত্র স্থানান্তর করতে পারব না এবং শোকেসের জিনিসপত্রও সরাতে পারব না।'),
          _buildBulletPoint('সকল প্রয়োজনীয় জিনিসপত্র ক্লায়েন্টদের নিজেরাই সরিয়ে রাখতে হবে।'),
          _buildBulletPoint('আমরা শুধুমাত্র ক্লায়েন্টদের নির্বাচিত আইটেম এবং কাজ অনুযায়ী সেবা প্রদান করব।'),
        ],
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4, left: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('• ', style: AppTextStyles.textSize12(context)),
          Expanded(
            child: Text(text, style: AppTextStyles.textSize12(context, color: AppColors.textPrimary(context))),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomConfirmButton(BuildContext context, double total, double saved) {
    return Container(
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.button(context),
        border: Border(top: BorderSide(color: AppColors.border(context), width: 1)),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
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