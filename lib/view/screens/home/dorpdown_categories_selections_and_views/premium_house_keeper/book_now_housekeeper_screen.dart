import 'dart:async';
import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/components/exception_errorstate/exception_errorstate.dart';
import 'package:dinmajur_customer/configs/res/components/header_appbar.dart';
import 'package:dinmajur_customer/configs/res/components/section_header/section_header.dart';
import 'package:dinmajur_customer/configs/res/sizedbox_spaccing.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:dinmajur_customer/configs/responsive/responsive_ui.dart';
import 'package:dinmajur_customer/configs/utils/routes/routes_name.dart';
import 'package:dinmajur_customer/configs/utils/utils.dart';
import 'package:dinmajur_customer/configs/widgets/datepicker_with_formfield.dart';
import 'package:dinmajur_customer/data/response/status.dart';
import 'package:dinmajur_customer/model/home_models/dropdown_categories_selection_models/premium_house_keeper_model/getall_premium_house_keeper_task_model.dart';
import 'package:dinmajur_customer/view/screens/home/dorpdown_categories_selections_and_views/premium_house_keeper/helper_widget/cart_dialouge.dart';
import 'package:dinmajur_customer/view/screens/home/dorpdown_categories_selections_and_views/premium_house_keeper/helper_widget/select_time_widget.dart';
import 'package:dinmajur_customer/view/screens/home/dorpdown_categories_selections_and_views/premium_house_keeper/helper_widget/taskdetails_showdialouge.dart';
import 'package:dinmajur_customer/view/screens/home/helper_widgets/add_location_screen_widget/add_location_screen_widget.dart';
import 'package:dinmajur_customer/view/screens/home/helper_widgets/dynamic_bottom_cart_widget.dart';
import 'package:dinmajur_customer/view/screens/home/helper_widgets/dynamic_serviclist_card_widget.dart';
import 'package:dinmajur_customer/view_model/homeview_model/dropdown_categories_selection_view_models/premium_house_keeper_view_model/getall_premium_house_keeper_task_view_model.dart';
import 'package:dinmajur_customer/view_model/homeview_model/dropdown_categories_selection_view_models/premium_house_keeper_view_model/getall_shifttime_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:dinmajur_customer/view_model/homeview_model/dropdown_categories_selection_view_models/premium_house_keeper_view_model/getall_housekeeper_category_view_model.dart';


class BookNowHousekeeperScreen extends StatefulWidget {
  final String customerName;
  final String customerPhone;
  final String serviceName;
  final String description;
  final String customerAddress;
  final bool isFromHome;
    final Map<String, dynamic>? customerLocation;

  const BookNowHousekeeperScreen({
    Key? key,
    required this.customerName,
    required this.customerPhone,
    required this.serviceName,
    required this.description,
    required this.customerAddress,
    this.isFromHome = false, this.customerLocation
  }) : super(key: key);

  @override
  State<BookNowHousekeeperScreen> createState() => _BookNowHousekeeperScreenState();
}

class _BookNowHousekeeperScreenState extends State<BookNowHousekeeperScreen> {
  String _selectedFrequency = 'Daily';
  final TextEditingController _dateController = TextEditingController();
  String? _selectedTime;
  int _selectedTabIndex = 0;
  late String _currentCustomerAddress;
  String? _selectedCategoryId;

  // Map to store quantities for each service
  Map<String, int> _serviceQuantities = {};
  Map<String, Set<String>> _selectedTaskItems = {};

  // ✅ NEW: Store all services data across categories
  Map<String, Datum> _allServicesMap = {};

  // Carousel controller and timer
  late PageController _pageController;
  Timer? _autoScrollTimer;
  int _currentPage = 0;

  final ScrollController _mainScrollController = ScrollController();
  Map<String, dynamic>? _customerLocation;

  @override
  void initState() {
    super.initState();
    if (widget.isFromHome) {
      CheckoutSessionLocationService.clear();
    }
    _currentCustomerAddress = widget.customerAddress;
    _customerLocation = widget.customerLocation;

    _dateController.text = DateFormat('MMMM dd, yyyy').format(DateTime.now());
    _pageController = PageController(viewportFraction: 0.3);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // First fetch categories
      final categoryViewModel = Provider.of<GetallHousekeeperCategoryViewModel>(context, listen: false);
      categoryViewModel.fetchGetAllHouseKeeperCategoryGetApi();

      // Fetch shift times for today's date
      final getShiftTimeviewModel = Provider.of<GetallShifttimeViewModel>(context, listen: false);
      String todayDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
      getShiftTimeviewModel.fetchGetAllsetgetAllShiftTimeGetDataApi(todayDate);

      _startAutoScroll();
    });
  }

  void _fetchTasksForCategory(String categoryId) {
    final viewModel = Provider.of<GetallPremiumHouseKeeperTaskViewModel>(context, listen: false);
    viewModel.fetchGetAllPermiumHouseKeeperTaskGetDataApi(categoryId,);
  }

  void _onDateChanged(String newDate) {
    try {
      DateTime parsedDate = DateFormat('MMMM dd, yyyy').parse(newDate);
      String formattedDate = DateFormat('yyyy-MM-dd').format(parsedDate);

      final getShiftTimeviewModel = Provider.of<GetallShifttimeViewModel>(context, listen: false);
      getShiftTimeviewModel.fetchGetAllsetgetAllShiftTimeGetDataApi(formattedDate);

      setState(() {
        _selectedTime = null;
      });
    } catch (e) {
    }
  }

  void _startAutoScroll() {
    _autoScrollTimer = Timer.periodic(Duration(seconds: 3), (timer) {
      if (_pageController.hasClients) {
        final categoryViewModel = Provider.of<GetallHousekeeperCategoryViewModel>(context, listen: false);
        final dataLength = categoryViewModel.getAllHouseKeeperCategoryData.data?.data?.length ?? 0;

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
    // ✅ UPDATED: Use _allServicesMap instead of current category data
    double total = 0;
    _serviceQuantities.forEach((serviceId, qty) {
      if (qty > 0 && _allServicesMap.containsKey(serviceId)) {
        final service = _allServicesMap[serviceId]!;

        if (service.houseKeeperTaskItems?.isNotEmpty == true) {
          Set<String> selectedItems = _selectedTaskItems[serviceId] ??
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
            } else if (service.discountType == 'FLAT') {
              price = price - service.discountValue!.toDouble();
            }
          }

          total += price * qty;
        }
      }
    });
    return total;
  }

  double _calculateSaved() {
    // ✅ UPDATED: Use _allServicesMap instead of current category data
    double saved = 0;
    _serviceQuantities.forEach((serviceId, qty) {
      if (qty > 0 && _allServicesMap.containsKey(serviceId)) {
        final service = _allServicesMap[serviceId]!;

        if (service.houseKeeperTaskItems?.isNotEmpty == true && service.discountValue != null) {
          Set<String> selectedItems = _selectedTaskItems[serviceId] ??
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
          } else if (service.discountType == 'FLAT') {
            discount = service.discountValue!.toDouble();
          }

          saved += discount * qty;
        }
      }
    });
    return saved;
  }


  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, null);
        return false;
      },
      child: Scaffold(
        backgroundColor: AppColors.containerBackground(context),
        body: SafeArea(child: ResPonsiveUi(mobile: _body(), desktop: _body(), tablet: _body())),
      ),
    );
  }

  Widget _body() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Column(
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context, null),
          child: Container(height: 60, child: AppBarHeader(widget.serviceName)),
        ),
        Expanded(
          child: Consumer2<GetallHousekeeperCategoryViewModel, GetallPremiumHouseKeeperTaskViewModel>(
            builder: (context, categoryViewModel, housekeeperViewModel, _) {
              final categories = categoryViewModel.getAllHouseKeeperCategoryData.data?.data ?? [];
              final tasks = housekeeperViewModel.getAllPremiumHouseKeeperTaskData.data?.data ?? [];

              final isCategoryLoading = categoryViewModel.getAllHouseKeeperCategoryData.status == Status.LOADING;
              final isTaskLoading = housekeeperViewModel.getAllPremiumHouseKeeperTaskData.status == Status.LOADING;
              final hasCategoryError = categoryViewModel.getAllHouseKeeperCategoryData.status == Status.ERROR;
              final hasTaskError = housekeeperViewModel.getAllPremiumHouseKeeperTaskData.status == Status.ERROR;

              // ✅ NEW: Auto-select first category when categories load
              if (categories.isNotEmpty && _selectedCategoryId == null) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted && _selectedCategoryId == null) {
                    setState(() {
                      _selectedCategoryId = categories.first.id;
                    });
                    _fetchTasksForCategory(_selectedCategoryId!);
                  }
                });
              }

              // Show loading indicator for initial category load
              if (isCategoryLoading) {
                return Center(child: LoadingAnimationWidget.progressiveDots(color: AppColors.button(context), size: 50));
              }

              // Show error for category load
              if (hasCategoryError) {
                return ErrorStateWidget(
                  errorMessage: categoryViewModel.getAllHouseKeeperCategoryData.message.toString(),
                  onRetry: () {
                    categoryViewModel.fetchGetAllHouseKeeperCategoryGetApi();
                  },
                );
              }

              return SingleChildScrollView(
                controller: _mainScrollController,
                child: Column(
                  children: [
                    SizedboxSpaccing.height03(context),
                    Container(
                      width: screenWidth * 0.9,
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: AppColors.freequencyColor(context)),
                      child: Row(
                        children: [
                          Expanded(child: _frequencyButton('Daily', screenWidth)),
                          Expanded(child: _frequencyButton('Monthly', screenWidth)),
                        ],
                      ),
                    ),
                    if (widget.description != null && widget.description!.isNotEmpty) ...[
                      SizedboxSpaccing.height03(context),
                      Container(
                        width: screenWidth * 0.9,
                        child: Text(
                          widget.description!,
                          style: AppTextStyles.textSize14(context, weight: FontWeight.w400),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                    SizedboxSpaccing.height03(context),

                    SectionHeader(title: 'Choose Date & Time', titleWidth: screenWidth * 0.9, showSeeAll: false),
                    SizedboxSpaccing.height02(context),
                    CustomDatePickerFormField(
                      controller: _dateController,
                      borderRadius: 6,
                      inputTextStyle: AppTextStyles.textSize14(context, weight: FontWeight.w400),
                      hintTextStyle: AppTextStyles.textSize14(context, color: AppColors.hintColor(context), weight: FontWeight.w400),
                      onDateSelected: (DateTime selectedDate) {
                        String formattedDate = DateFormat('MMMM dd, yyyy').format(selectedDate);
                        _dateController.text = formattedDate;
                        _onDateChanged(formattedDate);
                      },
                    ),

                    SizedboxSpaccing.height02(context),

                    _buildTimeSelection(screenWidth),

                    SizedboxSpaccing.height03(context),

                    // Category Tabs (NEW - Replacing DynamicCategoryTabs)
                    if (categories.isNotEmpty) _buildCategoryTabs(categories, screenWidth),

                    SizedboxSpaccing.height03(context),

                    Container(
                      width: screenWidth * 0.9,
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                  width: screenWidth*0.4,
                                  color: Colors.transparent,
                                  child: Text("Select Task", style: AppTextStyles.textSize18(context, weight: FontWeight.w500))),
                              GestureDetector(
                                onTap:(){
                                  setState(() {
                                    _serviceQuantities.clear();
                                    _selectedTaskItems.clear();
                                  });
                                },
                                child: Container(
                                    width: screenWidth*0.2,
                                    alignment: Alignment.centerRight,
                                    color: Colors.transparent,
                                    child: Text('Clear All', style: AppTextStyles.textSize12(context, weight: FontWeight.w500, color: AppColors.buttonTextColor(context),))),
                              ),
                            ],
                          ),
                          SizedboxSpaccing.height005(context),
                          Divider(height: 1, color: AppColors.border(context)),
                        ],
                      ),
                    ),
                    SizedboxSpaccing.height01(context),
                    // Show loading indicator for tasks
                    if (isTaskLoading)
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 50),
                        child: LoadingAnimationWidget.progressiveDots(color: AppColors.button(context), size: 50),
                      )
                    else if (hasTaskError)
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 50),
                        child: ErrorStateWidget(
                          errorMessage: housekeeperViewModel.getAllPremiumHouseKeeperTaskData.message.toString(),
                          onRetry: () {
                            if (_selectedCategoryId != null) {
                              _fetchTasksForCategory(_selectedCategoryId!);
                            }
                          },
                        ),
                      )
                    else
                    // Services List
                      _buildServicesList(isTaskLoading,tasks, screenWidth, screenHeight),

                    SizedboxSpaccing.height02(context),
                    if (isTaskLoading)SizedBox(height: screenHeight,),
                    _buildImportantNotes(context, screenWidth),
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
  Widget _buildCategoryTabs(List<dynamic> categories, double screenWidth) {
    return Container(
      width: screenWidth * 0.9,
      height: 112,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = _selectedTabIndex == index;
          final imageUrl = category.icon?.url;
          final name = category.name ?? '';

          final isSvg = imageUrl?.toLowerCase().endsWith('.svg') ?? false;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedTabIndex = index;
                _selectedCategoryId = category.id;
              });
              if (_selectedCategoryId != null) {
                _fetchTasksForCategory(_selectedCategoryId!);
              }
            },
            child: Container(
              height: 112,
              width: 106,
              margin: EdgeInsets.only(
                right: index == categories.length - 1 ? 0 : 12,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: isSelected ? AppColors.blackColor : AppColors.border(context).withOpacity(0.5),
                border: Border.all(
                  width: 1,
                  color: AppColors.border(context),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? AppColors.border(context)
                          : AppColors.containerBackground(context),
                      shape: BoxShape.circle,
                    ),
                    child: _buildCategoryIcon(context, imageUrl, isSvg, isSelected),
                  ),
                  SizedBox(height: 8),
                  SizedBox(
                    width: 80,
                    child: Text(
                      name,
                      style: AppTextStyles.textSize12(
                        context,
                        weight: FontWeight.w400,
                        color: isSelected ? AppColors.whiteColor : AppColors.textPrimary(context),
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

  Widget _buildCategoryIcon(BuildContext context, String? imageUrl, bool isSvg, bool isSelected) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return Icon(
        Icons.cleaning_services,
        color: isSelected ? AppColors.blackColor :  AppColors.textPrimary(context),
      );
    }

    return ClipOval(
      child: isSvg
          ? Padding(
        padding: EdgeInsets.all(12),
        child: SvgPicture.network(
          imageUrl,
          colorFilter: ColorFilter.mode(
            isSelected ? AppColors.whiteColor : AppColors.textPrimary(context),
            BlendMode.srcIn,
          ),
        ),
      )
          : Image.network(
        imageUrl,
       height: 20,
        color: AppColors.buttonTextColor(context),
        errorBuilder: (context, error, stackTrace) => Icon(
          Icons.cleaning_services,
          color: isSelected ? AppColors.blackColor : AppColors.textPrimary(context),
        ),
      ),
    );
  }

  Widget _buildServicesList(bool isTaskLoading,List<Datum> tasks, double screenWidth, double screenHeight) {
    if (!isTaskLoading && tasks.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 50),
        child: Text(
          'No services available',
          style: AppTextStyles.textSize16(context),
        ),
      );
    }

    // ✅ NEW: Store current category tasks in the map
    for (var task in tasks) {
      if (task.id != null) {
        _allServicesMap[task.id!] = task;
      }
    }

    return Column(
      children: tasks.asMap().entries.map((entry) {
        int index = entry.key;
        Datum service = entry.value;
        bool isLastItem = index == tasks.length - 1;

        int quantity = _serviceQuantities[service.id ?? ''] ?? 0;

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

        return Container(
          width: screenWidth * 0.9,
          child: DynamicServiceCard(
            imageUrl: service.image?.url,
            defaultIcon: Icons.cleaning_services,
            serviceName: service.name ?? '',
            hasRoom: service.hasRoom,
            hasHour: service.hasHour,
            viewDetailsText: 'View Task Details',
            onViewDetails: () => _showTaskDetailsDialog(service),
            discountedPrice: discountedPrice,
            originalPrice: originalPrice,
            showDiscount: service.discountValue != null && originalPrice > 0,
            quantity: quantity,
            onAdd: () => _updateQuantity(service.id ?? '', 1),
            onRemove: () => _updateQuantity(service.id ?? '', -1),
            onIncrease: () {
              final canIncrement = service.hasRoom == true || service.hasHour == true;
              if (!canIncrement) {
                Utils.flushBarExclamatoryMessage(
                  title: "Can't Add More",
                  subtitle: "Additional quantity isn't available for this service.",
                  context: context,
                );
              } else {
                _updateQuantity(service.id ?? '', 1);
              }
            },
            showRoomNumber: quantity > 0,
            roomNumberLabel: 'Room Number',
            isLastItem: isLastItem,
            getButtonColor: (context) => AppColors.button(context),
            getBackgroundColor: (context) => AppColors.containerBackground(context),
            getBorderColor: (context) => AppColors.border(context),
            getSubtitleColor: (context) => AppColors.subtitle(context),
            getTextColor: (context) => AppColors.textPrimary(context),
            getTextStyle: (context, {weight, color}) => AppTextStyles.textSize16(
              context,
              weight: weight ?? FontWeight.normal,
              color: color ?? AppColors.textPrimary(context),
            ),
            getSpacing: (context) => SizedboxSpaccing.width03(context),
          ),
        );
      }).toList(),
    );
  }

  Widget _frequencyButton(String frequency, double screenWidth) {
    bool isSelected = _selectedFrequency == frequency;
    return GestureDetector(
      onTap: () {
        if (frequency == 'Monthly') {
          Utils.flushBarErrorMessage("Sorry! This service is currently unavailable", context);
          return;
        }
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
            style: AppTextStyles.textSize16(
              context,
              weight: FontWeight.w600,
              color: isSelected ? Colors.white : AppColors.textPrimary(context),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimeSelection(double screenWidth) {
    return Consumer<GetallShifttimeViewModel>(
      builder: (context, shiftTimeViewModel, child) {
        final allShiftTimes = shiftTimeViewModel.getAllShiftTimeData.data?.data ?? [];
        final availableShiftTimes = allShiftTimes.where((shift) => shift.isBooked == false).toList();
        final isLoading = shiftTimeViewModel.getAllShiftTimeData.status == Status.LOADING;

        if (_selectedTime != null && !isLoading) {
          final isSelectedTimeAvailable = availableShiftTimes.any((shift) {
            final displayText = '${shift.type ?? ''} (${shift.startTime ?? ''}-${shift.endTime ?? ''})';
            return displayText == _selectedTime;
          });

          if (!isSelectedTimeAvailable) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                setState(() {
                  _selectedTime = null;
                });
              }
            });
          }
        }

        if (availableShiftTimes.isNotEmpty && _selectedTime == null && !isLoading) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && _selectedTime == null) {
              setState(() {
                final firstShift = availableShiftTimes.first;
                _selectedTime = '${firstShift.type ?? ''} (${firstShift.startTime ?? ''}-${firstShift.endTime ?? ''})';
              });
            }
          });
        }

        return DynamicTimeSelectionWidget(
          context: context,
          items: allShiftTimes,
          selectedValue: _selectedTime,
          isLoading: isLoading,
          getDisplayText: (shift) => '${shift.type ?? ''} (${shift.startTime ?? ''}-${shift.endTime ?? ''})',
          isItemBooked: (shift) => shift.isBooked ?? false,
          titleSpacing: (ctx) => SizedboxSpaccing.height01(ctx),
          showPrefixIcon: true,
          prefixIcon: Icons.access_time,
          iconSize: 20,
          itemTextStyle: AppTextStyles.textSize14(context, weight: FontWeight.w400),
          onChanged: (String? newValue) {
            if (newValue != null) {
              final selectedShift = allShiftTimes.firstWhere(
                    (shift) => '${shift.type ?? ''} (${shift.startTime ?? ''}-${shift.endTime ?? ''})' == newValue,
              );
              if (selectedShift.isBooked != true) {
                setState(() => _selectedTime = newValue);
              }
            }
          },
        );
      },
    );
  }

  void _proceedToCart() {
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
              _serviceQuantities[serviceId] = 0;
              _selectedTaskItems.remove(serviceId);
            } else {
              _serviceQuantities[serviceId] = quantity;
              _selectedTaskItems[serviceId] = selectedItems;
            }
          });
        },
      ),
    );
  }

  void _showCartDialog() {
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

    // ✅ UPDATED: Get services from _allServicesMap instead of current category only
    final servicesWithQuantity = _allServicesMap.values.where((service) {
      int qty = _serviceQuantities[service.id ?? ''] ?? 0;
      return qty > 0;
    }).toList();

    // Get transport fee from current view model (it should be same across categories)
    final viewModel = Provider.of<GetallPremiumHouseKeeperTaskViewModel>(context, listen: false);
    final transportFeeValue = viewModel.getAllPremiumHouseKeeperTaskData.data?.meta?.transportFee?.value?.toDouble() ?? 0.0;
    final minimumOrderAmount = viewModel.getAllPremiumHouseKeeperTaskData.data?.meta?.minimumOrderAmount;

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
        transportFee: transportFeeValue,
        minimumOrderAmount: minimumOrderAmount,
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
        restrictQuantityForNoRoomNoHourServices: true,
      ),
    );
  }

  void _showCheckoutScreen() async {
    // ✅ CRITICAL FIX: Get ALL services with quantities from _allServicesMap
    final allServicesWithQuantity = _allServicesMap.values.where((service) {
      int qty = _serviceQuantities[service.id ?? ''] ?? 0;
      return qty > 0;
    }).toList();

    // Get transport fee from any available category (should be same)
    final viewModel = Provider.of<GetallPremiumHouseKeeperTaskViewModel>(context, listen: false);
    final transportFeeValue = viewModel.getAllPremiumHouseKeeperTaskData.data?.meta?.transportFee?.value?.toDouble() ?? 0.0;
        final sessionData = await CheckoutSessionLocationService.getAll();
    if (sessionData.location != null && sessionData.address != null) {
      setState(() {
        _customerLocation = sessionData.location;
        _currentCustomerAddress = sessionData.address!;
      });
    }

    final result = await Navigator.pushNamed(
      context,
      RoutesName.checkoutHouseKeeperScreen,
      arguments: {
        'serviceQuantities': _serviceQuantities,
        'selectedTaskItems': _selectedTaskItems,
        'selectedFrequency': _selectedFrequency,
        'selectedDate': _dateController.text,
        'selectedTime': _selectedTime!,
        'customerName': widget.customerName,
        'customerPhone': widget.customerPhone,
        'customerAddress': _currentCustomerAddress,
          'customerLocation': _customerLocation,
        'transportFee': transportFeeValue,
        // ✅ NEW: Pass the complete services list from all categories
        'allServices': allServicesWithQuantity,
        'onAddressUpdate': (String newAddress) {
          setState(() {
            _currentCustomerAddress = newAddress;
          });
        },
      },
    );

    if (result == true) {
      setState(() {
        _serviceQuantities.clear();
        _selectedTaskItems.clear();
        _allServicesMap.clear(); // ✅ Also clear the services map
      });
    }
  }

  Widget _buildImportantNotes(BuildContext context, double screenWidth) {
    return Container(
      width: screenWidth * 0.9,
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.containerBackground(context),
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
              Text('Important Notes', style: AppTextStyles.textSize16(context, weight: FontWeight.w700)),
            ],
          ),
          SizedBox(height: 8),
          Text(
            'আমরা হাউসকিপিং এর প্রয়োজনীয় উপকরণ সরবরাহ করব। তবে, কিছু বিষয় আমাদের কাস্টম সেবা দ্বারা পরিচালিত হবে:',
            style: AppTextStyles.textSize14(context, color: AppColors.textPrimary(context)),
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
          Text('• ', style: AppTextStyles.textSize14(context)),
          Expanded(
            child: Text(text, style: AppTextStyles.textSize14(context, color: AppColors.textPrimary(context))),
          ),
        ],
      ),
    );
  }
}

