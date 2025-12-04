
import 'dart:async';

import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/components/header_appbar.dart';
import 'package:dinmajur_customer/configs/res/sizedbox_spaccing.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:dinmajur_customer/configs/responsive/responsive_ui.dart';
import 'package:dinmajur_customer/configs/utils/utils.dart';
import 'package:dinmajur_customer/configs/widgets/datepicker_with_formfield.dart';
import 'package:dinmajur_customer/data/response/status.dart';
import 'package:dinmajur_customer/model/home_models/dropdown_categories_selection_models/premium_house_keeper_model/getall_premium_house_keeper_task_model.dart';
import 'package:dinmajur_customer/view_model/homeview_model/dropdown_categories_selection_view_models/premium_house_keeper_view_model/getall_premium_house_keeper_task_view_model.dart';
import 'package:dinmajur_customer/view_model/homeview_model/dropdown_categories_selection_view_models/premium_house_keeper_view_model/getall_shifttime_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class BookNowHousekeeperScreen extends StatefulWidget {
  const BookNowHousekeeperScreen({super.key});

  @override
  State<BookNowHousekeeperScreen> createState() => _BookNowHousekeeperScreenState();
}

class _BookNowHousekeeperScreenState extends State<BookNowHousekeeperScreen> {
  String _selectedFrequency = 'Daily';
  final TextEditingController _dateController = TextEditingController();
  String? _selectedTime;
  int _selectedTabIndex = 0;

  // Map to store quantities for each service
  Map<String, int> _serviceQuantities = {};
  Map<String, Set<String>> _selectedTaskItems = {};

  // Carousel controller and timer
  late PageController _pageController;
  Timer? _autoScrollTimer;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _dateController.text = DateFormat('dd/MM/yyyy').format(DateTime.now());
    _pageController = PageController(viewportFraction: 0.3);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = Provider.of<GetallPremiumHouseKeeperTaskViewModel>(context, listen: false);
      viewModel.fetchGetAllPermiumHouseKeeperTaskGetDataApi();

      final getShiftTimeviewModel = Provider.of<GetallShifttimeViewModel>(context, listen: false);
      getShiftTimeviewModel.fetchGetAllsetgetAllShiftTimeGetDataApi();

      // Start auto-scroll after data is loaded
      _startAutoScroll();
    });
  }

  void _startAutoScroll() {
    _autoScrollTimer = Timer.periodic(Duration(seconds: 3), (timer) {
      if (_pageController.hasClients) {
        final viewModel = Provider.of<GetallPremiumHouseKeeperTaskViewModel>(context, listen: false);
        final dataLength = viewModel.getAllPremiumHouseKeeperTaskData.data?.data?.length ?? 0;

        if (dataLength > 0) {
          _currentPage = (_currentPage + 1) % dataLength;
          _pageController.animateToPage(_currentPage, duration: Duration(milliseconds: 500), curve: Curves.easeInOut);
        }
      }
    });
  }
  ///Checkout Info Data
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _specialRequestController = TextEditingController();
  String? _selectedHouseSize;

// Don't forget to dispose them
  @override
  void dispose() {
    _dateController.dispose();
    _pageController.dispose();
    _autoScrollTimer?.cancel();
    _fullNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _specialRequestController.dispose();
    super.dispose();
  }

  void _updateQuantity(String serviceId, int change) {
    setState(() {
      int currentQty = _serviceQuantities[serviceId] ?? 0;
      int newQty = currentQty + change;
      if (newQty >= 0) {
        _serviceQuantities[serviceId] = newQty;
      }
    });
  }
  double _calculateTotal() {
    final viewModel = Provider.of<GetallPremiumHouseKeeperTaskViewModel>(context, listen: false);
    final data = viewModel.getAllPremiumHouseKeeperTaskData.data?.data ?? [];

    double total = 0;
    data.forEach((service) {
      int qty = _serviceQuantities[service.id ?? ''] ?? 0;
      if (qty > 0 && service.houseKeeperTaskItems?.isNotEmpty == true) {
        // Get selected items
        Set<String> selectedItems = _selectedTaskItems[service.id ?? ''] ??
            service.houseKeeperTaskItems!.map((item) => item.id ?? '').toSet();

        // Calculate price from selected items only
        double price = 0;
        for (var item in service.houseKeeperTaskItems!) {
          if (selectedItems.contains(item.id ?? '')) {
            price += item.price?.toDouble() ?? 0;
          }
        }

        // Apply discount if available
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

// Updated _calculateSaved to use selected items
  double _calculateSaved() {
    final viewModel = Provider.of<GetallPremiumHouseKeeperTaskViewModel>(context, listen: false);
    final data = viewModel.getAllPremiumHouseKeeperTaskData.data?.data ?? [];

    double saved = 0;
    data.forEach((service) {
      int qty = _serviceQuantities[service.id ?? ''] ?? 0;
      if (qty > 0 && service.houseKeeperTaskItems?.isNotEmpty == true && service.discountValue != null) {
        // Get selected items
        Set<String> selectedItems = _selectedTaskItems[service.id ?? ''] ??
            service.houseKeeperTaskItems!.map((item) => item.id ?? '').toSet();

        // Calculate original price from selected items
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
    return _serviceQuantities.values.fold(0, (sum, qty) => sum + qty);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.containerBackground(context),
        body: ResPonsiveUi(mobile: _body(), desktop: _body(), tablet: _body()),
      ),
    );
  }

  Widget _body() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Column(
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(height: 60, child: AppBarHeader("Premium House Keeper")),
        ),
        Expanded(
          child: Consumer2<GetallPremiumHouseKeeperTaskViewModel, GetallShifttimeViewModel>(
            builder: (context, housekeeperViewModel, shiftTimeViewModel, _) {
              // Check loading states
              final isHousekeeperLoading = housekeeperViewModel.getAllPremiumHouseKeeperTaskData.status == Status.LOADING;
              final isShiftTimeLoading = shiftTimeViewModel.getAllShiftTimeData.status == Status.LOADING;

              // Check error states
              final hasHousekeeperError = housekeeperViewModel.getAllPremiumHouseKeeperTaskData.status == Status.ERROR;
              final hasShiftTimeError = shiftTimeViewModel.getAllShiftTimeData.status == Status.ERROR;

              // Show loading indicator if any data is loading
              if (isHousekeeperLoading || isShiftTimeLoading) {
                return Center(
                    child: LoadingAnimationWidget.progressiveDots(
                        color: AppColors.button(context),
                        size: 50
                    )
                );
              }

              // Show error if any data failed to load
              if (hasHousekeeperError || hasShiftTimeError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 48, color: Colors.red),
                      SizedBox(height: 16),
                      Text(
                          'Failed to load data',
                          style: AppTextStyles.textSize16(context, color: Colors.red)
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          housekeeperViewModel.fetchGetAllPermiumHouseKeeperTaskGetDataApi();
                          shiftTimeViewModel.fetchGetAllsetgetAllShiftTimeGetDataApi();
                        },
                        child: Text('Retry'),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.button(context)
                        ),
                      ),
                    ],
                  ),
                );
              }

              return SingleChildScrollView(
                child: Column(
                  children: [
                    SizedboxSpaccing.height015(context),
                    Container(
                      width: screenWidth * 0.9,
                      child: Text(
                        "Two highly-trained housekeepers will work together",
                        style: AppTextStyles.textSize16(
                            context,
                            weight: FontWeight.w500,
                            color: AppColors.subtitle(context)
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedboxSpaccing.height02(context),

                    // Frequency Selection
                    _buildFrequencySelection(screenWidth),

                    SizedboxSpaccing.height02(context),

                    // Date Selection
                    _buildDateSelection(screenWidth),

                    SizedboxSpaccing.height02(context),

                    // Time Selection - Now using shiftTimeViewModel data
                    _buildTimeSelection(screenWidth, shiftTimeViewModel),

                    SizedboxSpaccing.height02(context),

                    // Category Tabs - Pass housekeeperViewModel
                    _buildCategoryTabs(housekeeperViewModel),

                    SizedboxSpaccing.height02(context),

                    // Services List - Pass housekeeperViewModel
                    _buildServicesList(screenWidth, screenHeight, housekeeperViewModel),

                    SizedboxSpaccing.height01(context),
                  ],
                ),
              );
            },
          ),
        ),

        // Bottom Cart Bar
        _buildBottomCartBar(screenWidth),
      ],
    );
  }

  Widget _buildFrequencySelection(double screenWidth) {
    return Container(
      width: screenWidth * 0.9,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Frequency',
            style: AppTextStyles.textSize16(context, weight: FontWeight.w500, color: AppColors.textPrimary(context)),
          ),
          SizedboxSpaccing.height01(context),
          Container(
            width: screenWidth * 0.9,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: AppColors.textFieldFill(context)),
            padding: EdgeInsets.all(6),
            child: Row(
              children: [
                Expanded(child: _frequencyButton('Daily', screenWidth)),
                Expanded(child: _frequencyButton('Monthly', screenWidth)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _frequencyButton(String frequency, double screenWidth) {
    bool isSelected = _selectedFrequency == frequency;
    return GestureDetector(
      onTap: () => setState(() => _selectedFrequency = frequency),
      child: Container(
        height: 45,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.button(context) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isSelected ? AppColors.button(context) : Colors.transparent, width: 1),
        ),
        child: Center(
          child: Text(
            frequency,
            style: AppTextStyles.textSize16(context, weight: FontWeight.w600, color: isSelected ? Colors.white : AppColors.textPrimary(context)),
          ),
        ),
      ),
    );
  }

  Widget _buildDateSelection(double screenWidth) {
    return Container(
      width: screenWidth * 0.9,
      child: CustomDatePickerFormField(title: 'Choose Date', controller: _dateController),
    );
  }

  Widget _buildTimeSelection(double screenWidth, GetallShifttimeViewModel shiftTimeViewModel) {
    // Get shift times from the view model
    final shiftTimes = shiftTimeViewModel.getAllShiftTimeData.data?.data ?? [];

    // Set default selected time if not already set and data is available
    if (shiftTimes.isNotEmpty && _selectedTime == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _selectedTime == null) {
          setState(() {
            final firstShift = shiftTimes.first;
            _selectedTime = '${firstShift.type ?? ''} (${firstShift.startTime ?? ''}-${firstShift.endTime ?? ''})';
          });
        }
      });
    }

    return Container(
      width: screenWidth * 0.9,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
              'Choose Time',
              style: AppTextStyles.textSize18(context, weight: FontWeight.w500)
          ),
          SizedboxSpaccing.height01(context),
          Container(
            height: 42,
            padding: EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: AppColors.textFieldFill(context),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border(context)),
            ),
            child: shiftTimes.isEmpty
                ? Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'No shift times available',
                style: AppTextStyles.textSize14(context, color: AppColors.subtitle(context)),
              ),
            )
                : DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedTime,
                isExpanded: true,
                icon: Icon(Icons.keyboard_arrow_down, color: AppColors.textPrimary(context)),
                dropdownColor: AppColors.containerBackground(context),
                menuMaxHeight: 300,
                borderRadius: BorderRadius.circular(8),
                items: shiftTimes.map((shift) {
                  String displayText = '${shift.type ?? ''} (${shift.startTime ?? ''}-${shift.endTime ?? ''})';
                  return DropdownMenuItem<String>(
                    value: displayText,
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: AppColors.border(context).withOpacity(0.3),
                            width: 0.5,
                          ),
                        ),
                      ),
                      child: Text(
                        displayText,
                        style:  AppTextStyles.textSize16(context, weight: FontWeight.w500),
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() => _selectedTime = newValue);
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildCategoryTabs(GetallPremiumHouseKeeperTaskViewModel viewModel) {
    final data = viewModel.getAllPremiumHouseKeeperTaskData.data?.data ?? [];
    if (data.isEmpty) return SizedBox();

    return Container(
      height: 110,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.05),
        itemCount: data.length,
        itemBuilder: (context, index) {
          final service = data[index];
          bool isSelected = _selectedTabIndex == index;

          // Check if the icon URL is an SVG
          bool isSvg = service.icon?.url?.toLowerCase().endsWith('.svg') ?? false;

          return GestureDetector(
            onTap: () => setState(() => _selectedTabIndex = index),
            child: Container(
              margin: EdgeInsets.only(right: 16),
              child: Column(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.button(context).withOpacity(0.1) : AppColors.containerBackground(context),
                      shape: BoxShape.circle,
                      border: Border.all(color: isSelected ? AppColors.button(context) : AppColors.border(context), width: 2),
                    ),
                    child: service.icon?.url != null
                        ? ClipOval(
                      child: isSvg
                          ? Padding(
                        padding: EdgeInsets.all(12),
                        child: SvgPicture.network(
                          service.icon!.url!,
                          colorFilter: ColorFilter.mode(
                            isSelected ? AppColors.button(context) : AppColors.textPrimary(context),
                            BlendMode.srcIn,
                          ),
                          // placeholderBuilder: (context) => Center(
                          //   child: CircularProgressIndicator(
                          //     strokeWidth: 2,
                          //     color: AppColors.button(context),
                          //   ),
                          // ),
                        ),
                      )
                          : Image.network(
                        service.icon!.url!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            Icon(Icons.cleaning_services, color: AppColors.button(context)),
                      ),
                    )
                        : Icon(Icons.cleaning_services, color: AppColors.button(context)),
                  ),
                  SizedBox(height: 8),
                  SizedBox(
                    width: 80,
                    child: Text(
                      service.name ?? '',
                      style: AppTextStyles.textSize12(
                        context,
                        weight: isSelected ? FontWeight.w600 : FontWeight.w400,
                        color: isSelected ? AppColors.button(context) : AppColors.textPrimary(context),
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
  Widget _buildServicesList(double screenWidth, double screenHeight, GetallPremiumHouseKeeperTaskViewModel viewModel) {
    final data = viewModel.getAllPremiumHouseKeeperTaskData.data?.data ?? [];
    if (data.isEmpty) {
      return Center(child: Text('No services available', style: AppTextStyles.textSize16(context)));
    }

    return Container(
      width: screenWidth * 0.9,
      child: ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: data.length,
        itemBuilder: (context, index) {
          return _buildServiceCard(data[index], screenWidth, screenHeight);
        },
      ),
    );
  }

  Widget _buildServiceCard(Datum service, double screenWidth, double screenHeight) {

    ///Checked unchecked value will be reduce
    // int quantity = _serviceQuantities[service.id ?? ''] ?? 0;
    //
    // // Get all selected task items for this service (default to all if none selected)
    // Set<String> selectedItems = _selectedTaskItems[service.id ?? ''] ??
    //     (service.houseKeeperTaskItems?.map((item) => item.id ?? '').toSet() ?? {});
    //
    // // Calculate original price from selected task items only
    // double originalPrice = 0;
    // if (service.houseKeeperTaskItems?.isNotEmpty == true) {
    //   for (var item in service.houseKeeperTaskItems!) {
    //     if (selectedItems.contains(item.id ?? '')) {
    //       originalPrice += item.price?.toDouble() ?? 0;
    //     }
    //   }
    // }
    //
    // double discountedPrice = originalPrice;
    //
    // // Calculate discounted price
    // if (service.discountType != null && service.discountValue != null && originalPrice > 0) {
    //   if (service.discountType == 'PERCENTAGE') {
    //     discountedPrice = originalPrice - (originalPrice * service.discountValue! / 100);
    //   } else if (service.discountType == 'FIXED') {
    //     discountedPrice = originalPrice - service.discountValue!.toDouble();
    //   }
    // }

    int quantity = _serviceQuantities[service.id ?? ''] ?? 0;

    // Calculate original price from ALL task items (not just selected ones)
    double originalPrice = 0;
    if (service.houseKeeperTaskItems?.isNotEmpty == true) {
      for (var item in service.houseKeeperTaskItems!) {
        originalPrice += item.price?.toDouble() ?? 0;
      }
    }

    double discountedPrice = originalPrice;

    // Calculate discounted price based on ALL items
    if (service.discountType != null && service.discountValue != null && originalPrice > 0) {
      if (service.discountType == 'PERCENTAGE') {
        discountedPrice = originalPrice - (originalPrice * service.discountValue! / 100);
      } else if (service.discountType == 'FLAT') {
        discountedPrice = originalPrice - service.discountValue!.toDouble();
      }
    }

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.containerBackground(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: Colors.grey[200]),
            child: service.image?.url != null
                ? ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                service.image!.url!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Icon(Icons.image, size: 40, color: Colors.grey),
              ),
            )
                : Icon(Icons.cleaning_services, size: 40, color: Colors.grey),
          ),
          SizedboxSpaccing.width03(context),

          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service.name ?? '',
                  style: AppTextStyles.textSize16(context, weight: FontWeight.w600, color: AppColors.textPrimary(context)),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedboxSpaccing.height005(context),
                GestureDetector(
                  onTap: () {
                    _showTaskDetailsDialog(service);
                  },
                  child: Row(
                    children: [
                      Text('View Task Details', style: AppTextStyles.textSize12(context, weight: FontWeight.w500, color: AppColors.button(context))),
                      Icon(Icons.chevron_right, size: 16, color: AppColors.button(context)),
                    ],
                  ),
                ),
                SizedboxSpaccing.height01(context),
                Row(
                  children: [
                    Text(
                      '৳${discountedPrice.toStringAsFixed(2)}',
                      style: AppTextStyles.textSize16(context, weight: FontWeight.w700, color: AppColors.button(context)),
                    ),
                    if (service.discountValue != null && originalPrice > 0) ...[
                      SizedBox(width: 8),
                      Text(
                        '৳${originalPrice.toStringAsFixed(2)}',
                        style: AppTextStyles.textSize14(context, color: AppColors.subtitle(context)).copyWith(decoration: TextDecoration.lineThrough),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          // Quantity Controls or Add Button
          if (quantity == 0)
            GestureDetector(
              onTap: () => _updateQuantity(service.id ?? '', 1),
              child: Container(
                width: 70,
                height: 25,
                decoration: BoxDecoration(color: AppColors.button(context), borderRadius: BorderRadius.circular(8)),
                child: Center(
                  child: Text(
                    'ADD +',
                    style: AppTextStyles.textSize12(context, weight: FontWeight.w600, color: Colors.white),
                  ),
                ),
              ),
            )
          else
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('Room Number', style: AppTextStyles.textSize10(context, color: AppColors.button(context))),
                    SizedboxSpaccing.height005(context),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => _updateQuantity(service.id ?? '', -1),
                          child: Container(
                            width: 25,
                            height: 25,
                            decoration: BoxDecoration(
                              border: Border.all(color: AppColors.border(context)),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Icon(Icons.remove, size: 16),
                          ),
                        ),
                        Container(
                          width: 30,
                          child: Center(
                            child: Text(quantity.toString(), style: AppTextStyles.textSize16(context, weight: FontWeight.w600)),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => _updateQuantity(service.id ?? '', 1),
                          child: Container(
                            width: 25,
                            height: 25,
                            decoration: BoxDecoration(
                              border: Border.all(color: AppColors.border(context)),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Icon(Icons.add, size: 16),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
        ],
      ),
    );
  }


  Widget _buildBottomCartBar(double screenWidth) {
    // Get the count of unique services (not total quantities)
    int totalServices = _serviceQuantities.entries
        .where((entry) => entry.value > 0)
        .length;

    double totalPrice = _calculateTotal();
    double savedAmount = _calculateSaved();

    if (totalServices == 0) return SizedBox();

    return Container(
      width: screenWidth,
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.button(context),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: Offset(0, -5))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Total Services ($totalServices service${totalServices > 1 ? 's' : ''})',
                style: AppTextStyles.textSize14(context, color: AppColors.containerBackground(context)),
              ),
              SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    '৳${totalPrice.toStringAsFixed(2)}',
                    style: AppTextStyles.textSize20(context, weight: FontWeight.w700, color: Colors.white),
                  ),
                  if (savedAmount > 0) ...[
                    SizedBox(width: 8),
                    Text(
                      'Saved ৳${savedAmount.toStringAsFixed(2)}',
                      style: AppTextStyles.textSize12(context, color: AppColors.containerBackground(context), weight: FontWeight.w600),
                    ),
                  ],
                ],
              ),
            ],
          ),
          GestureDetector(
            onTap: () {
              _proceedToCart();
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
              child: Row(
                children: [
                  Text(
                    'Cart',
                    style: AppTextStyles.textSize16(context, weight: FontWeight.w600, color: AppColors.button(context)),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward, color: AppColors.button(context), size: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  // Widget _buildBottomCartBar(double screenWidth) {
  //   int totalItems = _getTotalItems();
  //   double totalPrice = _calculateTotal();
  //   double savedAmount = _calculateSaved();
  //
  //   if (totalItems == 0) return SizedBox();
  //
  //   return Container(
  //     width: screenWidth,
  //     padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05, vertical: 16),
  //     decoration: BoxDecoration(
  //       color: AppColors.button(context),
  //       boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: Offset(0, -5))],
  //     ),
  //     child: Row(
  //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //       children: [
  //         Column(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             Text('Total Services ($totalItems item${totalItems > 1 ? 's' : ''})', style: AppTextStyles.textSize12(context, color: Colors.white.withOpacity(0.9))),
  //             SizedBox(height: 4),
  //             Row(
  //               children: [
  //                 Text(
  //                   '৳${totalPrice.toStringAsFixed(2)}',
  //                   style: AppTextStyles.textSize20(context, weight: FontWeight.w700, color: Colors.white),
  //                 ),
  //                 if (savedAmount > 0) ...[SizedBox(width: 8), Text('Saved ৳${savedAmount.toStringAsFixed(2)}', style: AppTextStyles.textSize12(context, color: Colors.white.withOpacity(0.9)))],
  //               ],
  //             ),
  //           ],
  //         ),
  //         GestureDetector(
  //           onTap: () {
  //             // Navigate to cart or checkout
  //             _proceedToCart();
  //           },
  //           child: Container(
  //             padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
  //             decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
  //             child: Row(
  //               children: [
  //                 Text(
  //                   'Cart',
  //                   style: AppTextStyles.textSize16(context, weight: FontWeight.w600, color: AppColors.button(context)),
  //                 ),
  //                 SizedBox(width: 8),
  //                 Icon(Icons.arrow_forward, color: AppColors.button(context), size: 20),
  //               ],
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }


  void _showTaskDetailsDialog(Datum service) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    // Store original quantity
    int originalQuantity = _serviceQuantities[service.id ?? ''] ?? 0;

    // Get current selected items
    Set<String> currentSelectedItems = _selectedTaskItems[service.id ?? ''] ?? {};

    // If quantity is 0 OR no items are selected, reset to all items (default state)
    if (originalQuantity == 0 || currentSelectedItems.isEmpty) {
      _selectedTaskItems[service.id ?? ''] =
          service.houseKeeperTaskItems?.map((item) => item.id ?? '').toSet() ?? {};
    } else {
      // Initialize selected items if not exists (default to all items selected)
      if (!_selectedTaskItems.containsKey(service.id ?? '')) {
        _selectedTaskItems[service.id ?? ''] =
            service.houseKeeperTaskItems?.map((item) => item.id ?? '').toSet() ?? {};
      }
    }

    // Create a temporary copy of selected items for this dialog session
    Set<String> tempSelectedItems = Set<String>.from(_selectedTaskItems[service.id ?? ''] ?? {});

    // Create temporary quantity variable (only for dialog) - minimum 1
    int tempQuantity = originalQuantity > 0 ? originalQuantity : 1;

    // Calculate prices
    double calculateOriginalPrice(Set<String> items) {
      double price = 0;
      for (var item in service.houseKeeperTaskItems ?? []) {
        if (items.contains(item.id ?? '')) {
          price += item.price?.toDouble() ?? 0;
        }
      }
      return price;
    }

    double calculateDiscountedPrice(double original) {
      if (service.discountType != null && service.discountValue != null && original > 0) {
        if (service.discountType == 'PERCENTAGE') {
          return original - (original * service.discountValue! / 100);
        } else if (service.discountType == 'FLAT') {
          return original - service.discountValue!.toDouble();
        }
      }
      return original;
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          // Use tempQuantity instead of reading from global state
          double originalPricePerUnit = calculateOriginalPrice(tempSelectedItems);
          double discountedPricePerUnit = calculateDiscountedPrice(originalPricePerUnit);

          // Calculate total prices (multiplied by tempQuantity)
          double totalOriginalPrice = originalPricePerUnit * (tempQuantity > 0 ? tempQuantity : 1);
          double totalDiscountedPrice = discountedPricePerUnit * (tempQuantity > 0 ? tempQuantity : 1);

          bool allSelected = tempSelectedItems.length == (service.houseKeeperTaskItems?.length ?? 0);

          return WillPopScope(
            onWillPop: () async {
              // Revert changes if dialog is closed without clicking "Update Items"
              return true;
            },
            child: Dialog(
              backgroundColor: AppColors.containerBackground(context),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              insetPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Container(
                width: screenWidth,
                constraints: BoxConstraints(maxHeight: screenHeight * 0.8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header with close button
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: AppColors.border(context), width: 1),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  service.name ?? '',
                                  style: AppTextStyles.textSize18(context, weight: FontWeight.w600),
                                ),
                                SizedBox(height: 4),
                                Row(
                                  children: [
                                    Text(
                                      '৳${totalDiscountedPrice.toStringAsFixed(2)}',
                                      style: AppTextStyles.textSize16(context, weight: FontWeight.w700, color: AppColors.button(context)),
                                    ),
                                    if (service.discountValue != null && totalOriginalPrice > 0) ...[
                                      SizedBox(width: 8),
                                      Text(
                                        '৳${totalOriginalPrice.toStringAsFixed(2)}',
                                        style: AppTextStyles.textSize14(context, color: AppColors.subtitle(context))
                                            .copyWith(decoration: TextDecoration.lineThrough),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: Icon(Icons.close, color: AppColors.textPrimary(context)),
                            padding: EdgeInsets.zero,
                            constraints: BoxConstraints(),
                          ),
                        ],
                      ),
                    ),

                    // Room Number Section
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: AppColors.border(context), width: 1),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Room Number',
                              style: AppTextStyles.textSize16(context, weight: FontWeight.w500),
                            ),
                          ),
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  if (tempQuantity > 1) { // Changed from > 0 to > 1
                                    setDialogState(() {
                                      tempQuantity--;
                                    });
                                  }
                                },
                                child: Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: AppColors.border(context)),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Icon(Icons.remove, size: 18),
                                ),
                              ),
                              Container(
                                width: 40,
                                child: Center(
                                  child: Text(
                                    tempQuantity.toString(),
                                    style: AppTextStyles.textSize16(context, weight: FontWeight.w600),
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  setDialogState(() {
                                    tempQuantity++;
                                  });
                                },
                                child: Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: AppColors.border(context)),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Icon(Icons.add, size: 18),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Select All Checkbox
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.textFieldFill(context).withOpacity(0.3),
                      ),
                      child: Row(
                        children: [
                          Checkbox(
                            value: allSelected,
                            activeColor: AppColors.button(context),
                            onChanged: (bool? value) {
                              setDialogState(() {
                                if (value == true) {
                                  tempSelectedItems = service.houseKeeperTaskItems?.map((item) => item.id ?? '').toSet() ?? {};
                                } else {
                                  tempSelectedItems.clear();
                                }
                              });
                            },
                          ),
                          Text(
                            'Select All',
                            style: AppTextStyles.textSize16(context, weight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),

                    // Task Items List
                    Flexible(
                      child: service.houseKeeperTaskItems?.isEmpty == true
                          ? Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          'No task details available',
                          style: AppTextStyles.textSize14(context),
                        ),
                      )
                          : ListView.separated(
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        itemCount: service.houseKeeperTaskItems?.length ?? 0,
                        separatorBuilder: (context, index) => Divider(height: 1, color: AppColors.border(context)),
                        itemBuilder: (context, index) {
                          final task = service.houseKeeperTaskItems![index];
                          bool isSelected = tempSelectedItems.contains(task.id ?? '');

                          return Container(
                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: Row(
                              children: [
                                Checkbox(
                                  value: isSelected,
                                  activeColor: AppColors.button(context),
                                  onChanged: (bool? value) {
                                    setDialogState(() {
                                      if (value == true) {
                                        tempSelectedItems.add(task.id ?? '');
                                      } else {
                                        tempSelectedItems.remove(task.id ?? '');
                                      }
                                    });
                                  },
                                ),
                                Expanded(
                                  child: Text(
                                    task.name ?? '',
                                    style: AppTextStyles.textSize14(context, weight: FontWeight.w400),
                                  ),
                                ),
                                SizedBox(width: 8),
                                Text(
                                  '${task.price ?? 0} Taka',
                                  style: AppTextStyles.textSize14(context, weight: FontWeight.w500),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),

                    // Update Items Button
                    Container(
                      padding: EdgeInsets.all(16),
                      child: GestureDetector(
                        onTap: () {
                          // If no items are selected, remove the service completely
                          if (tempSelectedItems.isEmpty) {
                            setState(() {
                              // Set quantity to 0 (will show "ADD" button)
                              _serviceQuantities[service.id ?? ''] = 0;
                              // Clear selected items
                              _selectedTaskItems.remove(service.id ?? '');
                            });
                            Navigator.pop(context);
                            return;
                          }

                          // Only apply changes when "Update Items" is clicked AND items are selected
                          setState(() {
                            _selectedTaskItems[service.id ?? ''] = Set<String>.from(tempSelectedItems);
                            _serviceQuantities[service.id ?? ''] = tempQuantity;
                          });
                          Navigator.pop(context);
                        },
                        child: Container(
                          width: double.infinity,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.button(context),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              'Update Items',
                              style: AppTextStyles.textSize16(context, weight: FontWeight.w600, color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _proceedToCart() {
   _showCartDialog();

  }

  ///2
  void _showCartDialog() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Prepare cart data
    List<Map<String, dynamic>> cartItems = [];
    final viewModel = Provider.of<GetallPremiumHouseKeeperTaskViewModel>(context, listen: false);
    final data = viewModel.getAllPremiumHouseKeeperTaskData.data?.data ?? [];

    data.forEach((service) {
      int qty = _serviceQuantities[service.id ?? ''] ?? 0;
      if (qty > 0) {
        cartItems.add({
          'service': service,
          'quantity': qty,
          'selectedItems': _selectedTaskItems[service.id ?? ''] ??
              service.houseKeeperTaskItems?.map((item) => item.id ?? '').toSet() ?? {}
        });
      }
    });

    // Calculate functions
    double calculateSubtotal(Map<String, int> quantities) {
      double subtotal = 0;
      for (var item in cartItems) {
        Datum service = item['service'];
        int qty = quantities[service.id ?? ''] ?? 0;
        if (qty > 0) {
          Set<String> selectedItems = item['selectedItems'];
          double price = 0;
          for (var taskItem in service.houseKeeperTaskItems ?? []) {
            if (selectedItems.contains(taskItem.id ?? '')) {
              price += taskItem.price?.toDouble() ?? 0;
            }
          }
          if (service.discountType != null && service.discountValue != null && price > 0) {
            if (service.discountType == 'PERCENTAGE') {
              price = price - (price * service.discountValue! / 100);
            } else if (service.discountType == 'FLAT') {
              price = price - service.discountValue!.toDouble();
            }
          }
          subtotal += price * qty;
        }
      }
      return subtotal;
    }

    double calculateOriginalTotal(Map<String, int> quantities) {
      double originalTotal = 0;
      for (var item in cartItems) {
        Datum service = item['service'];
        int qty = quantities[service.id ?? ''] ?? 0;
        if (qty > 0) {
          Set<String> selectedItems = item['selectedItems'];
          double price = 0;
          for (var taskItem in service.houseKeeperTaskItems ?? []) {
            if (selectedItems.contains(taskItem.id ?? '')) {
              price += taskItem.price?.toDouble() ?? 0;
            }
          }
          originalTotal += price * qty;
        }
      }
      return originalTotal;
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          double subtotal = calculateSubtotal(_serviceQuantities);
          double transport = 80.0;
          double total = subtotal + transport;
          double originalTotal = calculateOriginalTotal(_serviceQuantities) + transport;
          double saved = originalTotal - total;

          return Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: EdgeInsets.all(16),
            child: Container(
              width: screenWidth,
              constraints: BoxConstraints(maxHeight: screenHeight * 0.85),
              decoration: BoxDecoration(
                color: AppColors.containerBackground(context),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: AppColors.border(context), width: 1),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'CART',
                              style: AppTextStyles.textSize20(context, weight: FontWeight.w700),
                            ),
                            SizedBox(height: 4),
                            Text(
                              '${cartItems.length} service${cartItems.length > 1 ? 's' : ''}',
                              style: AppTextStyles.textSize14(context, color: AppColors.subtitle(context)),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'Total ৳${total.toStringAsFixed(2)}',
                                  style: AppTextStyles.textSize16(context, weight: FontWeight.w700),
                                ),
                                if (saved > 0)
                                  Text(
                                    '৳${originalTotal.toStringAsFixed(2)}',
                                    style: AppTextStyles.textSize12(context, color: AppColors.subtitle(context))
                                        .copyWith(decoration: TextDecoration.lineThrough),
                                  ),
                              ],
                            ),
                            SizedBox(width: 12),
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: AppColors.textFieldFill(context),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(Icons.close, size: 20),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Cart Items List
                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      padding: EdgeInsets.all(16),
                      itemCount: cartItems.length,
                      separatorBuilder: (context, index) => SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final item = cartItems[index];
                        Datum service = item['service'];
                        int qty = _serviceQuantities[service.id ?? ''] ?? 0;

                        // If quantity is 0, skip this item
                        if (qty == 0) return SizedBox.shrink();

                        Set<String> selectedItems = item['selectedItems'];

                        // Calculate price for this service
                        double price = 0;
                        double originalPrice = 0;
                        for (var taskItem in service.houseKeeperTaskItems ?? []) {
                          if (selectedItems.contains(taskItem.id ?? '')) {
                            originalPrice += taskItem.price?.toDouble() ?? 0;
                          }
                        }
                        price = originalPrice;
                        if (service.discountType != null && service.discountValue != null && price > 0) {
                          if (service.discountType == 'PERCENTAGE') {
                            price = price - (price * service.discountValue! / 100);
                          } else if (service.discountType == 'FLAT') {
                            price = price - service.discountValue!.toDouble();
                          }
                        }

                        return Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.border(context)),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          service.name ?? '',
                                          style: AppTextStyles.textSize16(context, weight: FontWeight.w600),
                                        ),
                                        SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Text(
                                              '৳${price.toStringAsFixed(2)}',
                                              style: AppTextStyles.textSize14(context, weight: FontWeight.w600),
                                            ),
                                            if (service.discountValue != null && originalPrice > 0) ...[
                                              SizedBox(width: 8),
                                              Text(
                                                '৳${originalPrice.toStringAsFixed(2)}',
                                                style: AppTextStyles.textSize12(context, color: AppColors.subtitle(context))
                                                    .copyWith(decoration: TextDecoration.lineThrough),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            if (qty > 1) {
                                              _serviceQuantities[service.id ?? ''] = qty - 1;
                                            } else {
                                              // When quantity reaches 0, remove the item completely
                                              _serviceQuantities[service.id ?? ''] = 0;
                                              _selectedTaskItems.remove(service.id ?? '');
                                            }
                                          });
                                          setDialogState(() {}); // Refresh dialog

                                          // If all items are removed, close the dialog
                                          if (_getTotalItems() == 0) {
                                            Navigator.pop(context);
                                          }
                                        },
                                        child: Container(
                                          width: 28,
                                          height: 28,
                                          decoration: BoxDecoration(
                                            border: Border.all(color: AppColors.border(context)),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Icon(Icons.remove, size: 16),
                                        ),
                                      ),
                                      Container(
                                        width: 35,
                                        child: Center(
                                          child: Text(
                                            qty.toString(),
                                            style: AppTextStyles.textSize16(context, weight: FontWeight.w600),
                                          ),
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _serviceQuantities[service.id ?? ''] = qty + 1;
                                          });
                                          setDialogState(() {}); // Refresh dialog
                                        },
                                        child: Container(
                                          width: 28,
                                          height: 28,
                                          decoration: BoxDecoration(
                                            border: Border.all(color: AppColors.border(context)),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Icon(Icons.add, size: 16),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                  // Price Breakdown
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(color: AppColors.border(context), width: 1),
                      ),
                    ),
                    child: Column(
                      children: [
                        _buildPriceRow('Subtotal', subtotal, context),
                        SizedBox(height: 8),
                        _buildPriceRow('Transport', transport, context),
                        SizedBox(height: 8),
                        Divider(color: AppColors.border(context)),
                        SizedBox(height: 8),
                        _buildPriceRow('Sub Total', total, context, isBold: true),
                        if (saved > 0) ...[
                          SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'You Saved BDT ${saved.toStringAsFixed(2)} in This Order!',
                                style: AppTextStyles.textSize12(context, color: Colors.red, weight: FontWeight.w600),
                              ),
                              Text(
                                '৳${originalTotal.toStringAsFixed(2)}',
                                style: AppTextStyles.textSize12(context, color: Colors.red)
                                    .copyWith(decoration: TextDecoration.lineThrough),
                              ),
                            ],
                          ),
                        ],
                        SizedBox(height: 16),
                        Divider(color: AppColors.border(context)),
                        SizedBox(height: 12),

                        // Service Details
                        _buildDetailRow('Service Type', _selectedFrequency, context),
                        _buildDetailRow('Place', 'Chittagong', context),
                        _buildDetailRow('Area', 'Chandgaong Residential Area', context),
                        _buildDetailRow('Date', _dateController.text, context),
                        _buildDetailRow('Morning', _selectedTime!, context),
                      ],
                    ),
                  ),

                  // Proceed Button
                  Container(
                    padding: EdgeInsets.all(16),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        _showCheckoutDialog();
                      },
                      child: Container(
                        width: double.infinity,
                        height: 50,
                        decoration: BoxDecoration(
                          color: AppColors.button(context),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            'Proceed to Checkout →',
                            style: AppTextStyles.textSize16(context, weight: FontWeight.w600, color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
  Widget _buildPriceRow(String label, double amount, BuildContext context, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.textSize14(
            context,
            weight: isBold ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
        Text(
          '৳${amount.toStringAsFixed(2)}',
          style: AppTextStyles.textSize14(
            context,
            weight: isBold ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.textSize14(context, color: AppColors.subtitle(context)),
          ),
          Text(
            value,
            style: AppTextStyles.textSize14(context, weight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  ///Checkout Info SHowDialouge
  void _showCheckoutDialog() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Calculate totals
    double subtotal = _calculateTotal();
    double transport = 80.0;
    double total = subtotal + transport;
    double saved = _calculateSaved();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: EdgeInsets.all(16),
            child: Container(
              width: screenWidth,
              constraints: BoxConstraints(maxHeight: screenHeight * 0.9),
              decoration: BoxDecoration(
                color: AppColors.containerBackground(context),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header with close button
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: AppColors.border(context), width: 1),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Checkout',
                          style: AppTextStyles.textSize20(context, weight: FontWeight.w700),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: AppColors.textFieldFill(context),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.close, size: 20),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Scrollable Form Content
                  Flexible(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Full Name Field
                          Text(
                            'Full Name',
                            style: AppTextStyles.textSize14(context, weight: FontWeight.w500),
                          ),
                          SizedBox(height: 8),
                          TextField(
                            controller: _fullNameController,
                            decoration: InputDecoration(
                              hintText: 'Enter your name',
                              hintStyle: AppTextStyles.textSize14(context, color: AppColors.subtitle(context)),
                              filled: true,
                              fillColor: AppColors.textFieldFill(context),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: AppColors.border(context)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: AppColors.border(context)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: AppColors.button(context)),
                              ),
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            ),
                          ),
                          SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.info_outline, size: 14, color: AppColors.subtitle(context)),
                              SizedBox(width: 4),
                              Text(
                                'Enter your full legal name',
                                style: AppTextStyles.textSize12(context, color: AppColors.subtitle(context)),
                              ),
                            ],
                          ),
                          SizedBox(height: 16),

                          // Phone Number Field
                          Row(
                            children: [
                              Text(
                                'Phone Number',
                                style: AppTextStyles.textSize14(context, weight: FontWeight.w500),
                              ),
                              Text(
                                ' *',
                                style: AppTextStyles.textSize14(context, weight: FontWeight.w500, color: Colors.red),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          TextField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                              hintText: 'Enter your number',
                              hintStyle: AppTextStyles.textSize14(context, color: AppColors.subtitle(context)),
                              prefixIcon: Icon(Icons.phone_outlined, color: AppColors.subtitle(context), size: 20),
                              filled: true,
                              fillColor: AppColors.textFieldFill(context),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: AppColors.border(context)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: AppColors.border(context)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: AppColors.button(context)),
                              ),
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            ),
                          ),
                          SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.info_outline, size: 14, color: AppColors.subtitle(context)),
                              SizedBox(width: 4),
                              Text(
                                'We\'ll use this to confirm your appointment',
                                style: AppTextStyles.textSize12(context, color: AppColors.subtitle(context)),
                              ),
                            ],
                          ),
                          SizedBox(height: 16),

                          // Service Address Field
                          Row(
                            children: [
                              Text(
                                'Service Address',
                                style: AppTextStyles.textSize14(context, weight: FontWeight.w500),
                              ),
                              Text(
                                ' *',
                                style: AppTextStyles.textSize14(context, weight: FontWeight.w500, color: Colors.red),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          TextField(
                            controller: _addressController,
                            maxLines: 2,
                            decoration: InputDecoration(
                              hintText: 'Enter your address',
                              hintStyle: AppTextStyles.textSize14(context, color: AppColors.subtitle(context)),
                              prefixIcon: Padding(
                                padding: EdgeInsets.only(bottom: 24),
                                child: Icon(Icons.home_outlined, color: AppColors.subtitle(context), size: 20),
                              ),
                              filled: true,
                              fillColor: AppColors.textFieldFill(context),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: AppColors.border(context)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: AppColors.border(context)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: AppColors.button(context)),
                              ),
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            ),
                          ),
                          SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.info_outline, size: 14, color: AppColors.subtitle(context)),
                              SizedBox(width: 4),
                              Text(
                                'Include apartment/unit number',
                                style: AppTextStyles.textSize12(context, color: AppColors.subtitle(context)),
                              ),
                            ],
                          ),
                          SizedBox(height: 16),

                          // Select House Size
                          Text(
                            'Select house size',
                            style: AppTextStyles.textSize14(context, weight: FontWeight.w500),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Select 1 out of 5 options',
                            style: AppTextStyles.textSize12(context, color: AppColors.subtitle(context)),
                          ),
                          SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _houseSizeButton('500-1000 sq ft', setDialogState),
                              _houseSizeButton('1000-1700 sq ft', setDialogState),
                              _houseSizeButton('1700-3000 sq ft', setDialogState),
                              _houseSizeButton('Above 3000 sq ft', setDialogState),
                            ],
                          ),
                          SizedBox(height: 16),

                          // Special Requests Field
                          Text(
                            'Special Requests or Instructions (Optional)',
                            style: AppTextStyles.textSize14(context, weight: FontWeight.w500),
                          ),
                          SizedBox(height: 8),
                          TextField(
                            controller: _specialRequestController,
                            maxLines: 3,
                            decoration: InputDecoration(
                              hintText: 'Write any request or instruction or suggestion.',
                              hintStyle: AppTextStyles.textSize14(context, color: AppColors.subtitle(context)),
                              filled: true,
                              fillColor: AppColors.textFieldFill(context),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: AppColors.border(context)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: AppColors.border(context)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: AppColors.button(context)),
                              ),
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            ),
                          ),
                          SizedBox(height: 16),

                          // Important Notes Section
                          Container(
                            padding: EdgeInsets.all(12),
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
                                    Text(
                                      'Important Notes',
                                      style: AppTextStyles.textSize16(context, weight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'আমরা হাউসকিপিং এর প্রয়োজনীয় উপকরণ সরবরাহ করব। তবে, কিছু বিষয় আমাদের কাস্টম সেবা দ্বারা পরিচালিত হবে:',
                                  style: AppTextStyles.textSize12(context, color: AppColors.textPrimary(context)),
                                ),
                                SizedBox(height: 8),
                                _buildBulletPoint('ঝাড়ু এবং ফ্যান মুছার সিঁড়ি ব্যবস্থা ক্লায়েন্টদের নিজেই করতে হবে।'),
                                _buildBulletPoint('আমরা ভারী জিনিসপত্র স্থানান্তর করতে পারব না এবং শোকেসের জিনিসপত্রও সরাতে পারব না।'),
                                _buildBulletPoint('সকল প্রয়োজনীয় জিনিসপত্র ক্লায়েন্টদের নিজেরাই সরিয়ে রাখতে হবে।'),
                                _buildBulletPoint('আমরা শুধুমাত্র ক্লায়েন্টদের নির্বাচিত আইটেম এবং কাজ অনুযায়ী সেবা প্রদান করব।'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Bottom Confirm Button
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.containerBackground(context),
                      border: Border(
                        top: BorderSide(color: AppColors.border(context), width: 1),
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
                                style: AppTextStyles.textSize12(context, color: AppColors.subtitle(context)),
                              ),
                              SizedBox(height: 4),
                              Row(
                                children: [
                                  Text(
                                    '৳${total.toStringAsFixed(2)}',
                                    style: AppTextStyles.textSize18(context, weight: FontWeight.w700),
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
                        GestureDetector(
                          onTap: () {
                            // Validate required fields
                            if (_phoneController.text.isEmpty) {
                             Utils.flushBarErrorMessage("Phone number is required", context);
                              return;
                            }
                            if (_addressController.text.isEmpty) {
                              Utils.flushBarErrorMessage("Service address is required", context);
                              return;
                            }

                            // Process booking
                            Navigator.pop(context); // Close checkout dialog

                            // Show success message
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Booking confirmed successfully!'),
                                backgroundColor: Colors.green,
                              ),
                            );

                            // Clear cart and reset
                            setState(() {
                              _serviceQuantities.clear();
                              _selectedTaskItems.clear();
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            decoration: BoxDecoration(
                              color: AppColors.button(context),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
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
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

// Helper method for house size buttons
  Widget _houseSizeButton(String size, StateSetter setDialogState) {
    bool isSelected = _selectedHouseSize == size;
    return GestureDetector(
      onTap: () {
        setDialogState(() {
          _selectedHouseSize = size;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.button(context).withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.button(context) : AppColors.border(context),
            width: 1.5,
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

// Helper method for bullet points
  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4, left: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('• ', style: AppTextStyles.textSize12(context)),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.textSize12(context, color: AppColors.textPrimary(context)),
            ),
          ),
        ],
      ),
    );
  }

}