///New design for the combo
import 'dart:convert';

import 'package:dinmajur_customer/configs/buttons/round_button.dart';
import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/components/exception_errorstate/exception_errorstate.dart';
import 'package:dinmajur_customer/configs/res/components/header_appbar.dart';
import 'package:dinmajur_customer/configs/res/sizedbox_spaccing.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:dinmajur_customer/configs/responsive/responsive_ui.dart';
import 'package:dinmajur_customer/configs/utils/routes/routes_name.dart';
import 'package:dinmajur_customer/configs/utils/utils.dart';
import 'package:dinmajur_customer/data/response/status.dart';
import 'package:dinmajur_customer/model/home_models/dropdown_categories_selection_models/beauty_and_salon_model/getall_premium_home_beauty_salon_model.dart' hide Image;
import 'package:dinmajur_customer/view/screens/home/dorpdown_categories_selections_and_views/beauty_and_salon/helper_widget/cart_dialouge.dart';
import 'package:dinmajur_customer/view/screens/home/dorpdown_categories_selections_and_views/beauty_and_salon/helper_widget/servicedetails_dialouge_widget.dart';
import 'package:dinmajur_customer/view/screens/home/dorpdown_categories_selections_and_views/beauty_and_salon/notifier/checkout_notifier.dart';
import 'package:dinmajur_customer/view/screens/home/helper_widgets/add_location_screen_widget/add_location_screen_widget.dart';
import 'package:dinmajur_customer/view/screens/home/helper_widgets/dynamic_bottom_cart_widget.dart';
import 'package:dinmajur_customer/view/screens/home/helper_widgets/dynamic_scroll_categorytab/dynamic_scrollable_categorytab.dart';
import 'package:dinmajur_customer/view/screens/home/helper_widgets/dynamic_serviclist_card_widget.dart';
import 'package:dinmajur_customer/view_model/homeview_model/dropdown_categories_selection_view_models/beauty_and_salon_view_model/get_bookedslot_view_model.dart';
import 'package:dinmajur_customer/view_model/homeview_model/dropdown_categories_selection_view_models/beauty_and_salon_view_model/getall_premium_home_beauty_salon_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:carousel_slider/carousel_slider.dart';

class BookNowHomeBeautySalonScreen extends StatefulWidget {
  final String customerName;
  final String customerPhone;
  final String customerAddress;
  final String serviceName;
  final String description;
  final bool isFromHome;
  final Map<String, dynamic>? customerLocation;

  const BookNowHomeBeautySalonScreen({
    Key? key,
    required this.customerName,
    required this.customerPhone,
    required this.customerAddress,
    required this.serviceName,
    required this.description,
    this.isFromHome = false,
    this.customerLocation,
  }) : super(key: key);

  @override
  State<BookNowHomeBeautySalonScreen> createState() => _BookNowHomeBeautySalonScreenState();
}

class _BookNowHomeBeautySalonScreenState extends State<BookNowHomeBeautySalonScreen> {
  final ScrollController _mainScrollController = ScrollController();
  int _selectedTabIndex = 0;
  final Map<int, GlobalKey> _categoryKeys = {};
  Map<String, int> _serviceQuantities = {};
  late String _currentCustomerAddress;
  Map<String, dynamic>? _customerLocation;

  // Carousel state management
  final Map<String, int> _carouselCurrentPage = {};
  final Map<String, CarouselSliderController> _carouselControllers = {};

  @override
  void initState() {
    super.initState();

    if (widget.isFromHome) {
      CheckoutSessionLocationService.clear();
    }
    _currentCustomerAddress = widget.customerAddress;
    _customerLocation = widget.customerLocation;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<GetallPremiumHomeBeautySalonViewModel>(context, listen: false).fetchGetAllPermiumHomeBeautySalonGetDataApi();

      Provider.of<GetBookedSlotViewModel>(context, listen: false).fetchGetBookedSlotDataApi(DateTime.now());
    });
  }

  @override
  void dispose() {
    _mainScrollController.dispose();
    super.dispose();
  }

  void _initializeCategoryKeys(List<Datum> data) {
    if (_categoryKeys.isEmpty && data.isNotEmpty) {
      for (int i = 0; i < data.length; i++) {
        _categoryKeys[i] = GlobalKey();
        // Initialize carousel controllers for popup categories
        if (data[i].viewInPopup == false) {
          _carouselControllers[data[i].id ?? i.toString()] = CarouselSliderController();
          _carouselCurrentPage[data[i].id ?? i.toString()] = 0;
        }
      }
    }
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
    final viewModel = Provider.of<GetallPremiumHomeBeautySalonViewModel>(context, listen: false);
    final data = viewModel.getAllPremiumHomeBeautySalonData.data?.data ?? [];

    double total = 0;
    data.forEach((category) {
      category.items?.forEach((service) {
        int qty = _serviceQuantities[service.id ?? ''] ?? 0;
        if (qty > 0) {
          double price = service.salePrice?.toDouble() ?? service.originalPrice?.toDouble() ?? 0;
          total += price * qty;
        }
      });
    });
    return total;
  }

  double _calculateSaved() {
    final viewModel = Provider.of<GetallPremiumHomeBeautySalonViewModel>(context, listen: false);
    final data = viewModel.getAllPremiumHomeBeautySalonData.data?.data ?? [];

    double saved = 0;
    data.forEach((category) {
      category.items?.forEach((service) {
        int qty = _serviceQuantities[service.id ?? ''] ?? 0;
        if (qty > 0 && service.discountValue != null) {
          double originalPrice = service.originalPrice?.toDouble() ?? 0;
          double salePrice = service.salePrice?.toDouble() ?? originalPrice;
          saved += (originalPrice - salePrice) * qty;
        }
      });
    });
    return saved;
  }

  int _getTotalItems() {
    return _serviceQuantities.entries.where((entry) => entry.value > 0).length;
  }

  bool _isScrolling = false;

  void _scrollToCategory(int index) {
    if (_categoryKeys[index]?.currentContext == null) return;

    setState(() {
      _isScrolling = true;
      _selectedTabIndex = index;
    });

    Future.delayed(Duration(milliseconds: 100), () {
      final RenderBox? renderBox = _categoryKeys[index]?.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox == null) {
        setState(() => _isScrolling = false);
        return;
      }

      final position = renderBox.localToGlobal(Offset.zero, ancestor: context.findRenderObject());
      final offset = _mainScrollController.offset + (position.dy - 60) - 20;

      _mainScrollController.animateTo(offset, duration: Duration(milliseconds: 400), curve: Curves.easeInOut).then((_) {
        setState(() => _isScrolling = false);
      });
    });
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
        body: SafeArea(
          child: ResPonsiveUi(mobile: _body(), desktop: _body(), tablet: _body()),
        ),
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
          child: Consumer<GetallPremiumHomeBeautySalonViewModel>(
            builder: (context, viewModel, _) {
              final data = viewModel.getAllPremiumHomeBeautySalonData.data?.data ?? [];
              final isLoading = viewModel.getAllPremiumHomeBeautySalonData.status == Status.LOADING;
              final hasError = viewModel.getAllPremiumHomeBeautySalonData.status == Status.ERROR;

              if (data.isNotEmpty) {
                _initializeCategoryKeys(data);
              }

              if (isLoading) {
                return Center(child: LoadingAnimationWidget.progressiveDots(color: AppColors.button(context), size: 50));
              }

              if (hasError) {
                return ErrorStateWidget(
                  // errorMessage: viewModel.getAllPremiumHomeBeautySalonData.message.toString(),
                  errorMessage: 'Failed to load services',
                  onRetry: () {
                    viewModel.fetchGetAllPermiumHomeBeautySalonGetDataApi();
                  },
                );
              }
              return CustomScrollView(
                controller: _mainScrollController,
                slivers: [
                  SliverToBoxAdapter(
                    child: Column(
                      children: [
                        SizedboxSpaccing.height03(context),
                        Container(
                          width: screenWidth * 0.9,
                          child: Column(
                            children: [
                              RichText(
                                textAlign: TextAlign.center,
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: "Premium",
                                      style: AppTextStyles.textSize20(context, weight: FontWeight.w600),
                                    ),
                                    TextSpan(
                                      text: " Home ${widget.serviceName}",
                                      style: AppTextStyles.textSize20(context, weight: FontWeight.w600, color: Color(0xffD78503)),
                                    ),
                                  ],
                                ),
                              ),
                              SizedboxSpaccing.height01(context),
                              Text(
                                // "Trained Beauticians • Premium Products Salon \n•  Experience at Home",
                                widget.description,
                                style: AppTextStyles.textSize14(context, weight: FontWeight.w400),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                        SizedboxSpaccing.height03(context),
                        CategoryTabs(
                          categories: data,
                          iconSize: 60,
                          selectedIndex: _selectedTabIndex,
                          onCategoryTap: (index) {
                            _scrollToCategory(index);
                          },
                          getName: (category) => category.name ?? '',
                          getImageUrl: (category) => category.image?.url,
                          getButtonColor: (context) => AppColors.button(context),
                          getBackgroundColor: (context) => AppColors.border(context),
                          getBorderColor: (context) => AppColors.border(context),
                          getSelectedIconColor: (context) => AppColors.whiteColor,
                          getSelectedImageColor: (context) => AppColors.whiteColor,
                          getTextColor: (context) => AppColors.textPrimary(context),
                          getTextStyle: (context, isSelected) =>
                              AppTextStyles.textSize12(context, weight: isSelected ? FontWeight.w600 : FontWeight.w400, color: isSelected ? AppColors.button(context) : AppColors.textPrimary(context)),
                          defaultIcon: Icons.spa,
                          supportSvg: false,
                        ),
                        SizedBox(height: 20),
                      ],
                    ),
                  ),
                  ...data.asMap().entries.map((entry) {
                    int index = entry.key;
                    Datum category = entry.value;
                    final items = category.items ?? [];
                    final isPopup = category.viewInPopup ?? true;

                    if (isPopup) {
                      // Regular list view for viewInPopup: true
                      return _buildRegularCategorySection(index, category, items, screenWidth, screenHeight);
                    } else {
                      // Carousel view for viewInPopup: false
                      return _buildCarouselCategorySection(index, category, items, screenWidth, screenHeight);
                    }
                  }).toList(),
                  SliverToBoxAdapter(child: SizedBox(height: screenHeight / 1.5)),
                ],
              );
            },
          ),
        ),
        if (_getTotalItems() > 0)
          DynamicBottomCartBar(
            totalServices: _getTotalItems(),
            totalPrice: _calculateTotal(),
            savedAmount: _calculateSaved(),
            onCartTap: _showCartDialog,
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
          ),
      ],
    );
  }

  // Regular category section (viewInPopup: true)
  Widget _buildRegularCategorySection(int index, Datum category, List<Item> items, double screenWidth, double screenHeight) {
    return SliverStickyHeader(
      header: Container(
        key: _categoryKeys[index],
        width: screenWidth,
        color: AppColors.containerBackground(context),
        child: Center(
          child: Container(
            width: screenWidth * 0.9,
            padding: EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.containerBackground(context),
              border: Border(bottom: BorderSide(width: 1, color: AppColors.border(context))),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  category.name ?? '',
                  style: AppTextStyles.textSize18(context, weight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, itemIndex) {
          if (itemIndex >= items.length) return null;

          final service = items[itemIndex];
          bool isLastItem = itemIndex == items.length - 1;
          int quantity = _serviceQuantities[service.id ?? ''] ?? 0;
          double originalPrice = service.originalPrice?.toDouble() ?? 0;
          double discountedPrice = service.salePrice?.toDouble() ?? originalPrice;

          return Container(
            width: screenWidth,
            child: Center(
              child: Container(
                width: screenWidth * 0.9,
                child: DynamicServiceCard(
                  imageUrl: service.image?.url,
                  defaultIcon: Icons.spa,
                  serviceName: service.name ?? '',
                  viewDetailsText: 'View Task Details',
                  onViewDetails: () => _showTaskDetailsDialog(service),
                  discountedPrice: discountedPrice,
                  originalPrice: originalPrice,
                  showDiscount: service.discountValue != null && originalPrice > discountedPrice,
                  quantity: quantity,
                  onAdd: () => _updateQuantity(service.id ?? '', 1),
                  onRemove: () => _updateQuantity(service.id ?? '', -1),
                  onIncrease: () => _updateQuantity(service.id ?? '', 1),
                  showRoomNumber: quantity > 0,
                  isLastItem: isLastItem,
                  getButtonColor: (context) => AppColors.button(context),
                  getBackgroundColor: (context) => AppColors.containerBackground(context),
                  getBorderColor: (context) => AppColors.border(context),
                  getSubtitleColor: (context) => AppColors.subtitle(context),
                  getTextColor: (context) => AppColors.textPrimary(context),
                  getTextStyle: (context, {weight, color}) => AppTextStyles.textSize16(context, weight: weight ?? FontWeight.normal, color: color ?? AppColors.textPrimary(context)),
                  getSpacing: (context) => SizedboxSpaccing.width02(context),
                ),
              ),
            ),
          );
        }, childCount: items.length),
      ),
    );
  }

  // Carousel category section (viewInPopup: false)
  Widget _buildCarouselCategorySection(int index, Datum category, List<Item> items, double screenWidth, double screenHeight) {
    final categoryId = category.id ?? index.toString();

    return SliverStickyHeader(
      header: Container(
        key: _categoryKeys[index],
        width: screenWidth,
        color: AppColors.containerBackground(context),
        child: Center(
          child: Container(
            width: screenWidth * 0.9,
            padding: EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.containerBackground(context),
              border: Border(bottom: BorderSide(width: 1, color: AppColors.border(context))),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  category.name ?? '',
                  style: AppTextStyles.textSize18(context, weight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
      sliver: SliverToBoxAdapter(
        child: Column(
          children: [
            SizedBox(height: 16),

            // Carousel Slider
            if (items.isNotEmpty)
              CarouselSlider.builder(
                carouselController: _carouselControllers[categoryId],
                itemCount: items.length,
                itemBuilder: (context, itemIndex, realIndex) {
                  final service = items[itemIndex];
                  int quantity = _serviceQuantities[service.id ?? ''] ?? 0;
                  double originalPrice = service.originalPrice?.toDouble() ?? 0;
                  double discountedPrice = service.salePrice?.toDouble() ?? originalPrice;

                  return _buildCarouselCard(service: service, quantity: quantity, originalPrice: originalPrice, discountedPrice: discountedPrice, screenWidth: screenWidth);
                },
                options: CarouselOptions(
                  height: 420,
                  viewportFraction: 0.85,
                  enableInfiniteScroll: items.length > 1,
                  enlargeCenterPage: true,
                  enlargeFactor: 0.2,
                  onPageChanged: (index, reason) {
                    setState(() {
                      _carouselCurrentPage[categoryId] = index;
                    });
                  },
                ),
              ),

            // Dot Indicators
            if (items.length > 1) ...[SizedBox(height: 16), _buildDotIndicators(items.length, categoryId)],

            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildCarouselCard({required Item service, required int quantity, required double originalPrice, required double discountedPrice, required double screenWidth}) {
    String? discountBadge;

    // Debug print to see what values we're getting
    print('Service: ${service.name}');
    print('DiscountType: ${service.discountType}');
    print('DiscountValue: ${service.discountValue}');

    if (service.discountType != null && service.discountValue != null) {
      final discountVal = service.discountValue!;

      if (discountVal > 0) {
        if (service.discountType == DiscountType.PERCENTAGE) {
          discountBadge = '${discountVal.toInt()}% OFF';
        } else if (service.discountType == DiscountType.FLAT) {
          discountBadge = 'Flat ${discountVal.toInt()} Taka OFF';
        }
      }
    }

    // Debug print to see final badge
    print('Discount Badge: $discountBadge');
    return Container(
      width: screenWidth * 0.9,
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.containerBackground(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border(context), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Section
          Container(
            height: 195,
            width: double.infinity,
            decoration: BoxDecoration(color: AppColors.border(context).withOpacity(0.3), borderRadius: BorderRadius.circular(8)),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: service.image?.url != null
                  ? Image.network(
                      service.image!.url!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Center(child: Icon(Icons.spa, size: 60, color: AppColors.border(context))),
                    )
                  : Center(child: Icon(Icons.spa, size: 60, color: AppColors.border(context))),
            ),
          ),
          SizedBox(height: 16),
          // Content Section
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Service Name
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        service.name ?? '',
                        style: AppTextStyles.textSize16(context, weight: FontWeight.w600),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedboxSpaccing.width02(context),
                    Row(
                      children: [
                        Text('৳${discountedPrice.toStringAsFixed(2)}', style: AppTextStyles.textSize16(context, weight: FontWeight.w600)),
                        if (service.discountValue != null && originalPrice > discountedPrice) ...[
                          SizedBox(width: 8),
                          Text(
                            '৳${originalPrice.toStringAsFixed(2)}',
                            style: TextStyle(fontSize: 10, color: AppColors.subtitle(context), decoration: TextDecoration.lineThrough),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 10),
                GestureDetector(
                  onTap: () => _showTaskDetailsDialog(service),
                  child: Row(
                    children: [
                      Text(
                        'View Task Details',
                        style: AppTextStyles.textSize12(context, weight: FontWeight.w500, color: AppColors.button(context)),
                      ),
                      Icon(Icons.chevron_right, size: 16, color: AppColors.button(context)),
                    ],
                  ),
                ),

                Spacer(),

                if (discountBadge != null) ...[
                  Container(
                    // width: screenWidth * 0.9,
                    child: Center(
                      child: Text(
                        discountBadge,
                        style: AppTextStyles.textSize12(context, weight: FontWeight.w400, color: AppColors.buttonTextColor(context)),
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                ],
                // Add to Cart Button
                if (quantity == 0)
                  RoundButtonFlexible(
                    height: 42,
                    showRightIcon: false,
                    backgroundColor: AppColors.textPrimary(context),
                    title: 'Add to Cart',
                    textColor: AppColors.textSecondary(context),
                    onPress: () => _updateQuantity(service.id ?? '', 1),
                  )
                else
                  Container(
                    height: 42,
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.textPrimary(context), width: 1.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: () => _updateQuantity(service.id ?? '', -1),
                          icon: Icon(Icons.remove, color: AppColors.textPrimary(context)),
                        ),
                        Text(
                          '$quantity',
                          style: AppTextStyles.textSize18(context, weight: FontWeight.w600, color: AppColors.buttonTextColor(context)),
                        ),
                        IconButton(
                          onPressed: () => _updateQuantity(service.id ?? '', 1),
                          icon: Icon(Icons.add, color: AppColors.textPrimary(context)),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDotIndicators(int count, String categoryId) {
    final currentPage = _carouselCurrentPage[categoryId] ?? 0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        return Container(
          width: currentPage == index ? 24 : 8,
          height: 8,
          margin: EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(color: currentPage == index ? AppColors.button(context) : AppColors.border(context), borderRadius: BorderRadius.circular(4)),
        );
      }),
    );
  }

  void _showCartDialog() {
    final viewModel = Provider.of<GetallPremiumHomeBeautySalonViewModel>(context, listen: false);
    final checkoutVM = Provider.of<CheckoutBeautySalonViewModel>(context, listen: false);
    final bookedSlotVM = Provider.of<GetBookedSlotViewModel>(context, listen: false); // ADD THIS
    final data = viewModel.getAllPremiumHomeBeautySalonData.data?.data ?? [];
    final transportFeeValue = viewModel.getAllPremiumHomeBeautySalonData.data?.meta?.transportFee?.value?.toDouble() ?? 0.0;

    showDialog(
      context: context,
      barrierColor: AppColors.showDialougeBackground(context),
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return CartDialogWidget(
            categories: data,
            serviceQuantities: _serviceQuantities,
            onQuantityUpdate: (serviceId, newQuantity) {
              setState(() {
                _serviceQuantities[serviceId] = newQuantity;
              });
              setDialogState(() {});

              if (_getTotalItems() == 0) {
                Navigator.pop(context);
              }
            },
            onProceedToCheckout: _navigateCheckOutScreen,
            selectedDate: checkoutVM.selectedDate,
            selectedServiceTime: checkoutVM.selectedServiceTime,
            transportFee: transportFeeValue,
            bookedSlotViewModel: bookedSlotVM, // ADD THIS
            onDateSelected: (DateTime selectedDate) {
              checkoutVM.setSelectedDate(selectedDate);
              // Refresh booked slots silently on date change
              bookedSlotVM.fetchGetBookedSlotDataApi(selectedDate); // ADD THIS
              setDialogState(() {});
            },
            onTimeSelected: (String time) {
              checkoutVM.setServiceTime(time);
              setDialogState(() {});
            },
            dateController: TextEditingController(text: checkoutVM.selectedDate != null ? DateFormat('MMMM dd, yyyy').format(checkoutVM.selectedDate!) : ''),
          );
        },
      ),
    );
  }

  void _showTaskDetailsDialog(Item service) {
    showDialog(
      context: context,
      barrierColor: AppColors.showDialougeBackground(context),
      builder: (context) => ServiceDetailsDialog(
        imageUrl: service.image?.url,
        serviceName: service.name ?? 'Service Details',
        discountedPrice: service.salePrice?.toDouble() ?? service.originalPrice?.toDouble() ?? 0,
        originalPrice: service.originalPrice?.toDouble() ?? 0,
        showDiscount: service.discountValue != null && (service.originalPrice?.toDouble() ?? 0) > (service.salePrice?.toDouble() ?? 0),
        details: service.details,
        onClose: () => Navigator.pop(context),
        getButtonColor: (context) => AppColors.button(context),
        getBackgroundColor: (context) => AppColors.containerBackground(context),
        getBorderColor: (context) => AppColors.border(context),
        getTextColor: (context) => AppColors.textPrimary(context),
      ),
    );
  }

  void _navigateCheckOutScreen() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId') ?? '';

    if (userId.isEmpty) {
      Utils.flushBarErrorMessage('User ID not found. Please auth_login again.', context);
      return;
    }

    final viewModel = Provider.of<GetallPremiumHomeBeautySalonViewModel>(context, listen: false);
    final categories = viewModel.getAllPremiumHomeBeautySalonData.data?.data ?? [];
    final transportFeeValue = viewModel.getAllPremiumHomeBeautySalonData.data?.meta?.transportFee?.value?.toDouble() ?? 0.0;

    // ✅ Always check session prefs first — overrides original only if user edited
    final sessionData = await CheckoutSessionLocationService.getAll();
    if (sessionData.location != null && sessionData.address != null) {
      setState(() {
        _customerLocation = sessionData.location;
        _currentCustomerAddress = sessionData.address!;
      });
    }

    final result = await Navigator.pushNamed(
      context,
      RoutesName.beautyCheckoutScreen,
      arguments: {
        'customerName': widget.customerName,
        'customerPhone': widget.customerPhone,
        'customerAddress': _currentCustomerAddress,
        'customerLocation': _customerLocation, // ✅ now session location if edited
        'userId': userId,
        'categories': categories,
        'serviceQuantities': _serviceQuantities,
        'totalPrice': _calculateTotal(),
        'transportFee': transportFeeValue,
        'onAddressUpdate': (String newAddress) {
          setState(() {
            _currentCustomerAddress = newAddress;
          });
        },
      },
    );

    if (result is Map<String, dynamic>) {
      if (result['updatedLocation'] != null) {
        setState(() {
          _customerLocation = result['updatedLocation'] as Map<String, dynamic>;
          _currentCustomerAddress = (_customerLocation?['fullAddress'] as String?) ?? _currentCustomerAddress;
        });
      }
      if (result['cleared'] == true) {
        setState(() {
          _serviceQuantities.clear();
        });
      }
    }
  }
}
