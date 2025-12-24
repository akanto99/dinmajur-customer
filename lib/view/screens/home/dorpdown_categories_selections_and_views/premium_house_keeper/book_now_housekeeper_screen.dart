import 'dart:async';
import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/components/exception_errorstate/exception_errorstate.dart';
import 'package:dinmajur_customer/configs/res/components/header_appbar.dart';
import 'package:dinmajur_customer/configs/res/sizedbox_spaccing.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:dinmajur_customer/configs/responsive/responsive_ui.dart';
import 'package:dinmajur_customer/configs/utils/utils.dart';
import 'package:dinmajur_customer/configs/widgets/datepicker_with_formfield.dart';
import 'package:dinmajur_customer/data/response/status.dart';
import 'package:dinmajur_customer/model/home_models/dropdown_categories_selection_models/premium_house_keeper_model/getall_premium_house_keeper_task_model.dart';
import 'package:dinmajur_customer/view/screens/home/dorpdown_categories_selections_and_views/premium_house_keeper/checkout_screen.dart';
import 'package:dinmajur_customer/view/screens/home/dorpdown_categories_selections_and_views/premium_house_keeper/helper_widget/cart_dialouge.dart';
import 'package:dinmajur_customer/view/screens/home/dorpdown_categories_selections_and_views/premium_house_keeper/helper_widget/taskdetails_showdialouge.dart';
import 'package:dinmajur_customer/view/screens/home/helper_widgets/dynamic_bottom_cart_widget.dart';
import 'package:dinmajur_customer/view/screens/home/helper_widgets/dynamic_categorytab.dart';
import 'package:dinmajur_customer/view/screens/home/helper_widgets/dynamic_serviclist_card_widget.dart';
import 'package:dinmajur_customer/view_model/homeview_model/dropdown_categories_selection_view_models/premium_house_keeper_view_model/getall_premium_house_keeper_task_view_model.dart';
import 'package:dinmajur_customer/view_model/homeview_model/dropdown_categories_selection_view_models/premium_house_keeper_view_model/getall_shifttime_view_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import 'helper_widget/checkout_dialouge.dart';

class BookNowHousekeeperScreen extends StatefulWidget {
  final String customerName;
  final String customerPhone;
  final String customerAddress;
  const BookNowHousekeeperScreen({Key? key, required this.customerName, required this.customerPhone, required this.customerAddress}) : super(key: key);

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

  // ADD THESE NEW VARIABLES:
  final ScrollController _mainScrollController = ScrollController();
  final Map<int, GlobalKey> _serviceKeys = {};

  @override
  void initState() {
    super.initState();
    _dateController.text = DateFormat('MMMM dd, yyyy').format(DateTime.now());
    _pageController = PageController(viewportFraction: 0.3);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = Provider.of<GetallPremiumHouseKeeperTaskViewModel>(context, listen: false);
      viewModel.fetchGetAllPermiumHouseKeeperTaskGetDataApi();

      // Fetch shift times for today's date
      final getShiftTimeviewModel = Provider.of<GetallShifttimeViewModel>(context, listen: false);
      String todayDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
      getShiftTimeviewModel.fetchGetAllsetgetAllShiftTimeGetDataApi(todayDate);

      _startAutoScroll();
    });
  }

  // ADD THIS NEW METHOD:
  void _initializeServiceKeys(List<Datum> data) {
    if (_serviceKeys.isEmpty && data.isNotEmpty) {
      for (int i = 0; i < data.length; i++) {
        _serviceKeys[i] = GlobalKey();
      }
    }
  }

  // UPDATE THIS METHOD:
  void _scrollToCategory(int index) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_serviceKeys.containsKey(index)) {
        final keyContext = _serviceKeys[index]?.currentContext;
        if (keyContext != null) {
          Scrollable.ensureVisible(keyContext, duration: Duration(milliseconds: 500), curve: Curves.easeInOut, alignment: 0.1);
        }
      }
    });
  }

  void _onDateChanged(String newDate) {
    // Convert from "MMMM dd, yyyy" to "yyyy-MM-dd" format
    try {
      DateTime parsedDate = DateFormat('MMMM dd, yyyy').parse(newDate);
      String formattedDate = DateFormat('yyyy-MM-dd').format(parsedDate);

      // Fetch shift times for the new date WITHOUT listen: false to prevent full rebuild
      final getShiftTimeviewModel = Provider.of<GetallShifttimeViewModel>(context, listen: false);
      getShiftTimeviewModel.fetchGetAllsetgetAllShiftTimeGetDataApi(formattedDate);

      // Reset selected time since shifts changed
      setState(() {
        _selectedTime = null;
      });
    } catch (e) {
      print('Error parsing date: $e');
    }
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

  @override
  void dispose() {
    _dateController.dispose();
    _pageController.dispose();
    _autoScrollTimer?.cancel();
    _mainScrollController.dispose();
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
        Set<String> selectedItems = _selectedTaskItems[service.id ?? ''] ?? service.houseKeeperTaskItems!.map((item) => item.id ?? '').toSet();

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

  double _calculateSaved() {
    final viewModel = Provider.of<GetallPremiumHouseKeeperTaskViewModel>(context, listen: false);
    final data = viewModel.getAllPremiumHouseKeeperTaskData.data?.data ?? [];

    double saved = 0;
    data.forEach((service) {
      int qty = _serviceQuantities[service.id ?? ''] ?? 0;
      if (qty > 0 && service.houseKeeperTaskItems?.isNotEmpty == true && service.discountValue != null) {
        // Get selected items
        Set<String> selectedItems = _selectedTaskItems[service.id ?? ''] ?? service.houseKeeperTaskItems!.map((item) => item.id ?? '').toSet();

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.containerBackground(context),
      body: SafeArea(child: ResPonsiveUi(mobile: _body(), desktop: _body(), tablet: _body())),
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
          // CHANGED: Only consume GetallPremiumHouseKeeperTaskViewModel here
          // Remove GetallShifttimeViewModel from Consumer2
          child: Consumer<GetallPremiumHouseKeeperTaskViewModel>(
            builder: (context, housekeeperViewModel, _) {
              final data = housekeeperViewModel.getAllPremiumHouseKeeperTaskData.data?.data ?? [];

              // Initialize service keys when data is available
              if (data.isNotEmpty) {
                _initializeServiceKeys(data);
              }

              final isHousekeeperLoading = housekeeperViewModel.getAllPremiumHouseKeeperTaskData.status == Status.LOADING;
              final hasHousekeeperError = housekeeperViewModel.getAllPremiumHouseKeeperTaskData.status == Status.ERROR;

              // Show loading indicator only for housekeeper data
              if (isHousekeeperLoading) {
                return Center(child: LoadingAnimationWidget.progressiveDots(color: AppColors.button(context), size: 50));
              }

              // Show error only for housekeeper data
              if (hasHousekeeperError) {
                return ErrorStateWidget(
                  errorMessage: housekeeperViewModel.getAllPremiumHouseKeeperTaskData.message.toString(),
                  onRetry: () {
                    housekeeperViewModel.fetchGetAllPermiumHouseKeeperTaskGetDataApi();
                    String currentDate = DateFormat('yyyy-MM-dd').format(_dateController.text.isNotEmpty ? DateFormat('MMMM dd, yyyy').parse(_dateController.text) : DateTime.now());
                    final shiftTimeViewModel = Provider.of<GetallShifttimeViewModel>(context, listen: false);
                    shiftTimeViewModel.fetchGetAllsetgetAllShiftTimeGetDataApi(currentDate);
                  },
                );
              }

              return SingleChildScrollView(
                controller: _mainScrollController,
                child: Column(
                  children: [
                    SizedboxSpaccing.height015(context),
                    Container(
                      width: screenWidth * 0.9,
                      child: Text(
                        "Two highly-trained housekeepers will work together",
                        style: AppTextStyles.textSize16(context, weight: FontWeight.w500, color: AppColors.subtitle(context)),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedboxSpaccing.height02(context),

                    // Frequency Selection
                    Container(
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
                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: AppColors.border(context).withOpacity(0.5)),
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
                    ),

                    SizedboxSpaccing.height02(context),

                    // Date Selection
                    Container(
                      width: screenWidth * 0.9,
                      child: CustomDatePickerFormField(
                        title: 'Choose Date',
                        controller: _dateController,
                        onDateSelected: (DateTime selectedDate) {
                          // Format and set the date
                          String formattedDate = DateFormat('MMMM dd, yyyy').format(selectedDate);
                          _dateController.text = formattedDate;

                          // Fetch shifts for the new date
                          _onDateChanged(formattedDate);
                        },
                      ),
                    ),

                    SizedboxSpaccing.height02(context),

                    _buildTimeSelection(screenWidth),

                    SizedboxSpaccing.height02(context),

                    // Category Tabs
                    DynamicCategoryTabs(
                      categories: data,
                      selectedIndex: _selectedTabIndex,
                      onCategoryTap: (index) {
                        setState(() => _selectedTabIndex = index);
                        _scrollToCategory(index);
                      },
                      getName: (service) => service.name ?? '',
                      getImageUrl: (service) => service.icon?.url,
                      getButtonColor: (context) => AppColors.button(context),
                      getBackgroundColor: (context) => AppColors.containerBackground(context),
                      getBorderColor: (context) => AppColors.border(context),
                      getTextColor: (context) => AppColors.textPrimary(context),
                      getTextStyle: (context, isSelected) =>
                          AppTextStyles.textSize12(context, weight: isSelected ? FontWeight.w600 : FontWeight.w400, color: isSelected ? AppColors.button(context) : AppColors.textPrimary(context)),
                      defaultIcon: Icons.cleaning_services,
                      supportSvg: true,
                    ),

                    SizedboxSpaccing.height02(context),

                    // Services List
                    DynamicServiceList<Datum, Datum>(
                      categories: data,
                      categoryKeys: _serviceKeys,
                      screenWidth: screenWidth,
                      screenHeight: screenHeight,
                      isSimpleList: true, // House Keeper uses simple list
                      categoryHeaderStyle: (context) => AppTextStyles.textSize18(context, weight: FontWeight.w600),
                      emptyStateStyle: (context) => AppTextStyles.textSize16(context),
                      emptyStateSpacing: (context) => SizedboxSpaccing.height02(context),
                      buildServiceCard: (service, width, height) {
                        int quantity = _serviceQuantities[service.id ?? ''] ?? 0;

                        // Calculate prices
                        double originalPrice = 0;
                        if (service.houseKeeperTaskItems?.isNotEmpty == true) {
                          for (var item in service.houseKeeperTaskItems!) {
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

                        return DynamicServiceCard(
                          imageUrl: service.image?.url,
                          defaultIcon: Icons.cleaning_services,
                          serviceName: service.name ?? '',
                          viewDetailsText: 'View Task Details',
                          onViewDetails: () => _showTaskDetailsDialog(service),
                          discountedPrice: discountedPrice,
                          originalPrice: originalPrice,
                          showDiscount: service.discountValue != null && originalPrice > 0,
                          quantity: quantity,
                          onAdd: () => _updateQuantity(service.id ?? '', 1),
                          onRemove: () => _updateQuantity(service.id ?? '', -1),
                          onIncrease: () {
                            if (service.hasRoom == false) {
                              Utils.flushBarExclamatoryMessage(title: "Can't Add More", subtitle: "Additional quantity isn't available for this service.", context: context);
                            } else {
                              _updateQuantity(service.id ?? '', 1);
                            }
                          },
                          showRoomNumber: quantity > 0,
                          roomNumberLabel: 'Room Number',
                          getButtonColor: (context) => AppColors.button(context),
                          getBackgroundColor: (context) => AppColors.containerBackground(context),
                          getBorderColor: (context) => AppColors.border(context),
                          getSubtitleColor: (context) => AppColors.subtitle(context),
                          getTextColor: (context) => AppColors.textPrimary(context),
                          getTextStyle: (context, {weight, color}) => AppTextStyles.textSize16(context, weight: weight ?? FontWeight.normal, color: color ?? AppColors.textPrimary(context)),
                          getSpacing: (context) => SizedboxSpaccing.width03(context),
                        );
                      },
                    ),

                    SizedboxSpaccing.height045(context),
                  ],
                ),
              );
            },
          ),
        ),

        // Bottom Cart Bar
        Builder(
          builder: (context) {
            // Calculate values here
            int totalServices = _serviceQuantities.totalServices;
            double totalPrice = _calculateTotal();
            double savedAmount = _calculateSaved();

            return DynamicBottomCartBar(
              totalServices: totalServices,
              totalPrice: totalPrice,
              savedAmount: savedAmount,
              onCartTap: _proceedToCart,
              screenWidth: screenWidth,
              screenHeight: screenHeight,
              getButtonColor: (context) => AppColors.button(context),
              getBlackColor: (context) => AppColors.blackColor,
              getWhiteColor: (context) => AppColors.whiteColor,
              getTextStyle: (context, {weight, color}) {
                if (weight == FontWeight.w700) {
                  return AppTextStyles.textSize20(context, weight: weight, color: color ?? Colors.white);
                }
                return AppTextStyles.textSize14(context, color: color ?? AppColors.whiteColor);
              },
            );
          },
        ),
      ],
    );
  }

  Widget _frequencyButton(String frequency, double screenWidth) {
    bool isSelected = _selectedFrequency == frequency;
    return GestureDetector(
      onTap: () {
        // Check if Monthly is clicked
        if (frequency == 'Monthly') {
          // Show error message
          Utils.flushBarErrorMessage("Sorry! This service is currently unavailable", context);
          return; // Don't update the selected frequency
        }

        // Only update if it's not Monthly
        setState(() => _selectedFrequency = frequency);
      },
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

  Widget _buildTimeSelection(double screenWidth) {
    return Consumer<GetallShifttimeViewModel>(
      builder: (context, shiftTimeViewModel, child) {
        // Get all shift times from the view model
        final allShiftTimes = shiftTimeViewModel.getAllShiftTimeData.data?.data ?? [];

        // Filter available shifts for default selection
        final availableShiftTimes = allShiftTimes.where((shift) => shift.isBooked == false).toList();

        // Check if we're still loading
        final isLoading = shiftTimeViewModel.getAllShiftTimeData.status == Status.LOADING;

        // Set default selected time if not already set and available data exists
        if (availableShiftTimes.isNotEmpty && _selectedTime == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && _selectedTime == null) {
              setState(() {
                final firstShift = availableShiftTimes.first;
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
              Text('Choose Time', style: AppTextStyles.textSize18(context, weight: FontWeight.w500)),
              SizedboxSpaccing.height01(context),

              // Show loading indicator while fetching
              if (isLoading)
                Container(
                  height: 42,
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: AppColors.textFieldFill(context),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border(context)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Updating...', style: AppTextStyles.textSize16(context, weight: FontWeight.w500)),
                      Icon(Icons.keyboard_arrow_down, color: AppColors.textPrimary(context)),
                    ],
                  ),
                )
              // Show dropdown with all shifts (both available and booked)
              else if (allShiftTimes.isNotEmpty)
                Container(
                  height: 42,
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: AppColors.textFieldFill(context),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border(context)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedTime,
                      isExpanded: true,
                      icon: Icon(Icons.keyboard_arrow_down, color: AppColors.textPrimary(context)),
                      dropdownColor: AppColors.containerBackground(context),
                      menuMaxHeight: 300,
                      borderRadius: BorderRadius.circular(8),
                      hint: availableShiftTimes.isEmpty
                          ? Row(
                              children: [
                                Icon(Icons.warning_amber_rounded, size: 18, color: Colors.red),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'All time slots are booked',
                                    style: AppTextStyles.textSize14(context, color: Colors.red, weight: FontWeight.w500),
                                  ),
                                ),
                              ],
                            )
                          : null,
                      items: allShiftTimes.map((shift) {
                        String displayText = '${shift.type ?? ''} (${shift.startTime ?? ''}-${shift.endTime ?? ''})';
                        bool isBooked = shift.isBooked ?? false;

                        return DropdownMenuItem<String>(
                          value: displayText,
                          enabled: !isBooked,
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              border: Border(bottom: BorderSide(color: AppColors.border(context).withOpacity(0.3), width: 0.5)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    displayText,
                                    style: AppTextStyles.textSize16(context, weight: FontWeight.w500, color: isBooked ? AppColors.subtitle(context).withOpacity(0.5) : AppColors.textPrimary(context)),
                                  ),
                                ),
                                if (isBooked)
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.red.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(color: Colors.red.withOpacity(0.3)),
                                    ),
                                    child: Text(
                                      'Booked',
                                      style: AppTextStyles.textSize10(context, color: Colors.red, weight: FontWeight.w600),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          final selectedShift = allShiftTimes.firstWhere((shift) => '${shift.type ?? ''} (${shift.startTime ?? ''}-${shift.endTime ?? ''})' == newValue);

                          if (selectedShift.isBooked != true) {
                            setState(() => _selectedTime = newValue);
                          }
                        }
                      },
                    ),
                  ),
                )
              else
                Container(
                  height: 42,
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: AppColors.textFieldFill(context),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border(context)),
                  ),
                  child: Center(
                    child: Text('No shift times available', style: AppTextStyles.textSize14(context, color: AppColors.subtitle(context))),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  void _proceedToCart() {
    // Check if time slot is available
    final shiftTimeViewModel = Provider.of<GetallShifttimeViewModel>(context, listen: false);
    final availableShifts = shiftTimeViewModel.getAllShiftTimeData.data?.data?.where((shift) => shift.isBooked == false).toList() ?? [];

    if (availableShifts.isEmpty) {
      Utils.flushBarErrorMessage("No time slots available for the selected date. Please choose another date.", context);
      return;
    }

    if (_selectedTime == null) {
      Utils.flushBarErrorMessage("Please select a time slot", context);
      return;
    }

    _showCartDialog();
  }

  ///1
  void _showTaskDetailsDialog(Datum service) {
    showDialog(
      context: context,
      barrierColor: AppColors.showDialougeBackground(context),
      builder: (context) => TaskDetailsDialog(
        service: service,
        serviceQuantities: _serviceQuantities,
        selectedTaskItems: _selectedTaskItems,
        onUpdate: (String serviceId, int quantity, Set<String> selectedItems) {
          setState(() {
            if (quantity == 0) {
              // Remove service completely if no items selected
              _serviceQuantities[serviceId] = 0;
              _selectedTaskItems.remove(serviceId);
            } else {
              // Update with new values
              _serviceQuantities[serviceId] = quantity;
              _selectedTaskItems[serviceId] = selectedItems;
            }
          });
        },
      ),
    );
  }

  ///2
  void _showCartDialog() {
    // Check if time slot is available
    final shiftTimeViewModel = Provider.of<GetallShifttimeViewModel>(context, listen: false);
    final availableShifts = shiftTimeViewModel.getAllShiftTimeData.data?.data?.where((shift) => shift.isBooked == false).toList() ?? [];

    if (availableShifts.isEmpty) {
      Utils.flushBarErrorMessage("No time slots available for the selected date. Please choose another date.", context);
      return;
    }

    if (_selectedTime == null) {
      Utils.flushBarErrorMessage("Please select a time slot", context);
      return;
    }

    // Get services data
    final viewModel = Provider.of<GetallPremiumHouseKeeperTaskViewModel>(context, listen: false);
    final data = viewModel.getAllPremiumHouseKeeperTaskData.data?.data ?? [];

    // Filter services with quantity > 0
    final servicesWithQuantity = data.where((service) {
      int qty = _serviceQuantities[service.id ?? ''] ?? 0;
      return qty > 0;
    }).toList();

    showDialog(
      context: context,
      barrierColor: AppColors.showDialougeBackground(context),
      builder: (context) => CartDialog(
        services: servicesWithQuantity,
        serviceQuantities: _serviceQuantities,
        selectedTaskItems: _selectedTaskItems,
        selectedFrequency: _selectedFrequency,
        selectedDate: _dateController.text,
        selectedTime: _selectedTime!,
        onQuantityChanged: (String serviceId, int newQuantity) {
          setState(() {
            if (newQuantity == 0) {
              _serviceQuantities.remove(serviceId);
              _selectedTaskItems.remove(serviceId);
            } else {
              _serviceQuantities[serviceId] = newQuantity;
            }
          });
        },
        onProceedToCheckout: () {
          _showCheckoutScreen();
        },
      ),
    );
  }

  ///3
  // void _showCheckoutDialog() {
  //   showDialog(
  //     context: context,
  //     barrierColor: AppColors.showDialougeBackground(context),
  //     builder: (context) => CheckoutDialog(
  //       serviceQuantities: _serviceQuantities,
  //       selectedTaskItems: _selectedTaskItems,
  //       selectedFrequency: _selectedFrequency,
  //       selectedDate: _dateController.text,
  //       selectedTime: _selectedTime!,
  //       customerName: widget.customerName,
  //       customerPhone: widget.customerPhone,
  //       customerAddress: widget.customerAddress,
  //       onSuccess: () {
  //         setState(() {
  //           _serviceQuantities.clear();
  //           _selectedTaskItems.clear();
  //         });
  //       },
  //     ),
  //   );
  // }
  void _showCheckoutScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CheckoutScreen(
          serviceQuantities: _serviceQuantities,
          selectedTaskItems: _selectedTaskItems,
          selectedFrequency: _selectedFrequency,
          selectedDate: _dateController.text,
          selectedTime: _selectedTime!,
          customerName: widget.customerName,
          customerPhone: widget.customerPhone,
          customerAddress: widget.customerAddress,
          onSuccess: () {
            setState(() {
              _serviceQuantities.clear();
              _selectedTaskItems.clear();
            });
          },
        ),
      ),
    );
  }
}
