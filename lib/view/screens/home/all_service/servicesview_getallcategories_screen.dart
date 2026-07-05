import 'package:carousel_slider/carousel_slider.dart';
import 'package:dinmajur_customer/configs/buttons/round_button.dart';
import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/provider/cart/global_cart_provider.dart';
import 'package:dinmajur_customer/configs/res/components/exception_errorstate/exception_errorstate.dart';
import 'package:dinmajur_customer/configs/res/components/header_appbar.dart';
import 'package:dinmajur_customer/configs/res/sizedbox_spaccing.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:dinmajur_customer/configs/responsive/responsive_ui.dart';
import 'package:dinmajur_customer/configs/utils/routes/routes_name.dart';
import 'package:dinmajur_customer/configs/utils/utils.dart';
import 'package:dinmajur_customer/data/response/status.dart';
import 'package:dinmajur_customer/model/home_models/all_service_models/services_view_getallcategories_model.dart' hide Image;
import 'package:dinmajur_customer/provider/DarkAndLightTheme/theme_provider.dart';
import 'package:dinmajur_customer/view/screens/home/all_service/widget/services_cartdialouge_widget.dart';
import 'package:dinmajur_customer/view/screens/home/all_service/widget/services_viewdetails_dialouge.dart';
import 'package:dinmajur_customer/view/screens/home/helper_widgets/add_location_screen_widget/add_location_screen_widget.dart';
import 'package:dinmajur_customer/view/screens/home/helper_widgets/dynamic_bottom_cart_widget.dart';
import 'package:dinmajur_customer/view/screens/home/helper_widgets/dynamic_scroll_categorytab/dynamic_scrollable_categorytab.dart';
import 'package:dinmajur_customer/view/screens/home/helper_widgets/dynamic_serviclist_card_widget.dart';
import 'package:dinmajur_customer/view_model/homeview_model/all_service_view_models/checkout_view_model.dart';
import 'package:dinmajur_customer/view_model/homeview_model/all_service_view_models/services_view_getallcategories_view_model.dart';
import 'package:dinmajur_customer/view_model/homeview_model/all_service_view_models/get_slot_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ServicesViewScreen extends StatefulWidget {
  final String serviceId;
  final String customerName;
  final String customerPhone;
  final String customerAddress;
  final String serviceName;
  final String description;
  final bool isFromHome;
  final Map<String, dynamic>? customerLocation;
  ///for dynamic stores
  final String? retailerId;


  const ServicesViewScreen({
    Key? key,
    required this.serviceId,
    required this.customerName,
    required this.customerPhone,
    required this.customerAddress,
    required this.serviceName,
    required this.description,
    this.isFromHome = false,
    this.customerLocation,
    ///for dynamic stores
    this.retailerId,
  }) : super(key: key);

  @override
  State<ServicesViewScreen> createState() => _ServicesViewScreenState();
}

class _ServicesViewScreenState extends State<ServicesViewScreen> {
  ///for Dynamic Stores
  String? _retailerId;


  final ScrollController _mainScrollController = ScrollController();
  int _selectedTabIndex = 0;
  final Map<int, GlobalKey> _categoryKeys = {};
  bool _isScrollingFlag = false;
  final Map<String, CarouselSliderController> _carouselControllers = {};
  final Map<String, int> _carouselCurrentPage = {};

  Map<String, int> _serviceQuantities = {};
  late String _currentCustomerAddress;
  Map<String, dynamic>? _customerLocation;

  @override
  void initState() {
    super.initState();
    ///for Dynamic Stores
    _retailerId = widget.retailerId;

    if (widget.isFromHome) CheckoutSessionLocationService.clear();

    _currentCustomerAddress = widget.customerAddress;
    _customerLocation = widget.customerLocation;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Restore quantities saved in global cart for this service
      final cart = Provider.of<GlobalCartProvider>(context, listen: false);
      final saved = cart.getQuantitiesForService(widget.serviceId);
      if (saved.isNotEmpty) setState(() => _serviceQuantities = Map.of(saved));

      Provider.of<ServicesViewGetAllCategoriesViewModel>(context, listen: false).fetchServicesViewGetAllCategoriesGetApi(widget.serviceId, widget.retailerId?? "");
      Provider.of<GetSlotViewModel>(context, listen: false).fetchGetSlotDataApi(DateTime.now(), widget.serviceId);
    });
  }

  @override
  void dispose() {
    _mainScrollController.dispose();
    super.dispose();
  }

  void _initializeCategoryKeys(List<Category> categories) {
    if (_categoryKeys.isEmpty && categories.isNotEmpty) {
      for (int i = 0; i < categories.length; i++) {
        _categoryKeys[i] = GlobalKey();
        // Initialize carousel controllers for carousel-mode categories
        if (categories[i].viewInPopup == false) {
          _carouselControllers[categories[i].id ?? i.toString()] = CarouselSliderController();
          _carouselCurrentPage[categories[i].id ?? i.toString()] = 0;
        }
      }
    }
  }

  void _scrollToCategory(int index) {
    if (_categoryKeys[index]?.currentContext == null) return;

    setState(() {
      _isScrollingFlag = true;
      _selectedTabIndex = index;
    });

    Future.delayed(const Duration(milliseconds: 100), () {
      final RenderBox? renderBox = _categoryKeys[index]?.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox == null) {
        setState(() => _isScrollingFlag = false);
        return;
      }

      final position = renderBox.localToGlobal(Offset.zero, ancestor: context.findRenderObject());
      final offset = _mainScrollController.offset + (position.dy - 60) - 20;

      _mainScrollController.animateTo(offset, duration: const Duration(milliseconds: 400), curve: Curves.easeInOut).then((_) => setState(() => _isScrollingFlag = false));
    });
  }

  void _updateQuantity(String taskId, int change) {
    setState(() {
      int next = (_serviceQuantities[taskId] ?? 0) + change;
      if (next >= 0) _serviceQuantities[taskId] = next;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncGlobalCart());
  }

  void _syncGlobalCart() {
    if (!mounted) return;
    final cart = Provider.of<GlobalCartProvider>(context, listen: false);
    final count = _getTotalItems();
    if (count > 0) {
      final cartItems = <CartItem>[];
      final categories = _getCategories();
      for (final cat in categories) {
        for (final task in (cat.tasks ?? [])) {
          final qty = _serviceQuantities[task.id ?? ''] ?? 0;
          if (qty > 0) {
            final price = task.price?.salePrice?.toDouble() ?? task.price?.basePrice?.toDouble() ?? 0;
            final imageUrl = task.images != null && task.images!.isNotEmpty ? task.images!.first.url : null;
            cartItems.add(CartItem(id: task.id ?? '', name: task.name ?? '', quantity: qty, unitPrice: price, imageUrl: imageUrl));
          }
        }
      }
      final transportFee = Provider.of<ServicesViewGetAllCategoriesViewModel>(context, listen: false)
          .servicesViewGetAllCategoryData.data?.data?.transportFee?.toDouble() ?? 0.0;
      final checkoutVM = Provider.of<CheckoutAllServicesViewModel>(context, listen: false);
      cart.updateService(
        widget.serviceId,
        serviceName: widget.serviceName,
        items: cartItems,
        checkoutArgs: {
          'customerName': widget.customerName,
          'customerPhone': widget.customerPhone,
          'customerAddress': _currentCustomerAddress,
          'customerLocation': _customerLocation,
          'serviceId': widget.serviceId,
          'categories': categories,
          'serviceQuantities': Map.of(_serviceQuantities),
          'totalPrice': _calculateTotal(),
          'transportFee': transportFee,
          'selectedDate': checkoutVM.selectedDate,
          'selectedServiceTime': checkoutVM.selectedServiceTime,
          'retailerId': widget.retailerId ?? '',
        },
      );
    } else {
      cart.clearService(widget.serviceId);
    }
  }

  int _getTotalItems() => _serviceQuantities.entries.where((e) => e.value > 0).length;

  double _calculateTotal() {
    final categories = _getCategories();
    double total = 0;
    for (final cat in categories) {
      for (final task in (cat.tasks ?? [])) {
        final qty = _serviceQuantities[task.id ?? ''] ?? 0;
        if (qty > 0) {
          final price = task.price?.salePrice?.toDouble() ?? task.price?.basePrice?.toDouble() ?? 0;
          total += price * qty;
        }
      }
    }
    return total;
  }

  double _calculateSaved() {
    final categories = _getCategories();
    double saved = 0;
    for (final cat in categories) {
      for (final task in (cat.tasks ?? [])) {
        final qty = _serviceQuantities[task.id ?? ''] ?? 0;
        if (qty > 0) {
          final base = task.price?.basePrice?.toDouble() ?? 0;
          final sale = task.price?.salePrice?.toDouble() ?? base;
          if (base > sale) saved += (base - sale) * qty;
        }
      }
    }
    return saved;
  }

  List<Category> _getCategories() {
    final viewModel = Provider.of<ServicesViewGetAllCategoriesViewModel>(context, listen: false);
    return viewModel.servicesViewGetAllCategoryData.data?.data?.categories ?? [];
  }

  // ── Build ──
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, null);
        return false;
      },
      child: Scaffold(
        backgroundColor: AppColors.containerBackground(context),
        body: SafeArea(
          child: ResPonsiveUi(mobile: _body(screenWidth, screenHeight), desktop: _body(screenWidth, screenHeight), tablet: _body(screenWidth, screenHeight)),
        ),
      ),
    );
  }

  Widget _body(double screenWidth, double screenHeight) {
    return Column(
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context, null),
          child: Container(height: 60, child: AppBarHeader(widget.serviceName)),
        ),
        Expanded(
          child: Consumer<ServicesViewGetAllCategoriesViewModel>(
            builder: (context, viewModel, _) {
              final status = viewModel.servicesViewGetAllCategoryData.status;
              final categories = viewModel.servicesViewGetAllCategoryData.data?.data?.categories ?? [];

              if (status == Status.LOADING) {
                return Center(child: LoadingAnimationWidget.progressiveDots(color: AppColors.button(context), size: 50));
              }

              if (status == Status.ERROR) {
                return ErrorStateWidget(
                  // errorMessage: viewModel.servicesViewGetAllCategoryData.message.toString(),
                  errorMessage: 'Failed to load services',
                  onRetry: () {
                    viewModel.fetchServicesViewGetAllCategoriesGetApi(widget.serviceId,widget.retailerId?? "");
                  },
                );
              }
              if (categories.isEmpty) {
                return Center(
                  child: Text('No categories found', style: AppTextStyles.textSize14(context, color: AppColors.subtitle(context))),
                );
              }

              _initializeCategoryKeys(categories);

              return CustomScrollView(
                controller: _mainScrollController,
                slivers: [
                  SliverToBoxAdapter(
                    child: Column(
                      children: [
                        SizedboxSpaccing.height03(context),
                        SizedBox(
                          width: screenWidth * 0.9,
                          child: Column(
                            children: [
                              RichText(
                                textAlign: TextAlign.center,
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: "Dinmajur",
                                      style: AppTextStyles.textSize20(context, weight: FontWeight.w600),
                                    ),
                                    TextSpan(
                                      text: " ${widget.serviceName}",
                                      style: AppTextStyles.textSize20(context, weight: FontWeight.w600, color: const Color(0xffD78503)),
                                    ),
                                  ],
                                ),
                              ),
                              if (widget.description.isNotEmpty) ...[
                                SizedboxSpaccing.height01(context),
                                Text(
                                  widget.description,
                                  style: AppTextStyles.textSize14(context, weight: FontWeight.w400),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ],
                          ),
                        ),
                        SizedboxSpaccing.height03(context),
                        CategoryTabs(
                          categories: categories,
                          iconSize: 60,
                          selectedIndex: _selectedTabIndex,
                          onCategoryTap: _scrollToCategory,
                          getName: (c) => c.name ?? '',
                          getImageUrl: (c) => c.image?.url,
                          getButtonColor: (ctx) => AppColors.button(ctx),
                          getBackgroundColor: (ctx) => AppColors.border(ctx),
                          getBorderColor: (ctx) => AppColors.border(ctx),
                          getSelectedIconColor: (ctx) => AppColors.whiteColor,
                          getSelectedImageColor: (ctx) => AppColors.whiteColor,
                          getTextColor: (ctx) => AppColors.textPrimary(ctx),
                          getTextStyle: (context, isSelected) {
                            final isDarkMode = Provider.of<ThemeProvider>(context, listen: false).isDarkMode;
                            return AppTextStyles.textSize12(
                              context,
                              weight: isSelected ? FontWeight.w600 : FontWeight.w400,
                              color: isSelected
                                  ? (isDarkMode ? Color(0xffD78503) : AppColors.button(context))
                                  : AppColors.textPrimary(context),
                            );
                          },
                          defaultIcon: Icons.home_repair_service_outlined,
                          supportSvg: false,
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),

                  // ── Category sections ──
                  ...categories.asMap().entries.map((entry) {
                    final category = entry.value;
                    final tasks = category.tasks ?? [];
                    final isRegular = category.viewInPopup ?? true;
                    return isRegular
                        ? _buildCategorySection(index: entry.key, category: category, tasks: tasks, screenWidth: screenWidth, screenHeight: screenHeight)
                        : _buildCarouselCategorySection(index: entry.key, category: category, tasks: tasks, screenWidth: screenWidth, screenHeight: screenHeight);
                  }),

                  // SliverToBoxAdapter(child: SizedBox(height: screenHeight / 1.5)),
                ],
              );
            },
          ),
        ),

        // ── Bottom cart bar ──
        if (_getTotalItems() > 0)
          DynamicBottomCartBar(
            totalServices: _getTotalItems(),
            totalPrice: _calculateTotal(),
            savedAmount: _calculateSaved(),
            onCartTap: _showCartDialog,
            screenWidth: MediaQuery.of(context).size.width,
            screenHeight: MediaQuery.of(context).size.height,
            getButtonColor: (ctx) => AppColors.button(ctx),
            getBlackColor: (ctx) => AppColors.blackColor,
            getWhiteColor: (ctx) => AppColors.whiteColor,
            getTextStyle: (ctx, {weight, color}) {
              if (weight == FontWeight.w700) {
                return AppTextStyles.textSize20(ctx, weight: weight, color: color ?? Colors.white);
              }
              return AppTextStyles.textSize14(ctx, color: color ?? AppColors.whiteColor);
            },
          ),
      ],
    );
  }

  // ── Category section ──
  Widget _buildCategorySection({required int index, required Category category, required List<Task> tasks, required double screenWidth, required double screenHeight}) {
    return SliverStickyHeader(
      header: Container(
        key: _categoryKeys[index],
        width: screenWidth,
        color: AppColors.containerBackground(context),
        child: Center(
          child: Container(
            width: screenWidth * 0.9,
            padding: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: AppColors.containerBackground(context),
              border: Border(bottom: BorderSide(width: 1, color: AppColors.border(context))),
            ),
            child: Text(
              category.name ?? '',
              style: AppTextStyles.textSize18(context, weight: FontWeight.w600),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, taskIndex) {
          if (taskIndex >= tasks.length) return null;

          final task = tasks[taskIndex];
          final bool isLastItem = taskIndex == tasks.length - 1;
          final imageUrl = task.images != null && task.images!.isNotEmpty ? task.images!.first.url : null;
          final double originalPrice = task.price?.basePrice?.toDouble() ?? 0;
          final double salePrice = task.price?.salePrice?.toDouble() ?? originalPrice;
          final bool showDiscount = task.price?.discountType != DiscountType.NONE && originalPrice > salePrice;
          final int quantity = _serviceQuantities[task.id ?? ''] ?? 0;

          return Center(
            child: SizedBox(
              width: screenWidth * 0.9,
              child: DynamicServiceCard(
                imageUrl: imageUrl,
                defaultIcon: Icons.home_repair_service_outlined,
                serviceName: task.name ?? 'test',
                viewDetailsText: 'View Task Details',
                onViewDetails: () => _showTaskDetailsDialog(task),
                discountedPrice: salePrice,
                originalPrice: originalPrice,
                showDiscount: showDiscount,
                quantity: quantity,
                onAdd: () => _updateQuantity(task.id ?? '', 1),
                onRemove: () => _updateQuantity(task.id ?? '', -1),
                onIncrease: () => _updateQuantity(task.id ?? '', 1),
                showRoomNumber: quantity > 0,
                isLastItem: isLastItem,
                getButtonColor: (ctx) => AppColors.button(ctx),
                getBackgroundColor: (ctx) => AppColors.containerBackground(ctx),
                getBorderColor: (ctx) => AppColors.border(ctx),
                getSubtitleColor: (ctx) => AppColors.subtitle(ctx),
                getTextColor: (ctx) => AppColors.textPrimary(ctx),
                getTextStyle: (ctx, {weight, color}) => AppTextStyles.textSize16(ctx, weight: weight ?? FontWeight.normal, color: color ?? AppColors.textPrimary(ctx)),
                getSpacing: (ctx) => SizedboxSpaccing.width02(ctx),
              ),
            ),
          );
        }, childCount: tasks.length),
      ),
    );
  }

  // ── Carousel category section (viewInPopup: false) ──
  Widget _buildCarouselCategorySection({required int index, required Category category, required List<Task> tasks, required double screenWidth, required double screenHeight}) {
    final categoryId = category.id ?? index.toString();

    return SliverStickyHeader(
      header: Container(
        key: _categoryKeys[index],
        width: screenWidth,
        color: AppColors.containerBackground(context),
        child: Center(
          child: Container(
            width: screenWidth * 0.9,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.containerBackground(context),
              border: Border(bottom: BorderSide(width: 1, color: AppColors.border(context))),
            ),
            child: Text(
              category.name ?? '',
              style: AppTextStyles.textSize18(context, weight: FontWeight.w600),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
      sliver: SliverToBoxAdapter(
        child: Column(
          children: [
            const SizedBox(height: 16),
            if (tasks.isNotEmpty)
              CarouselSlider.builder(
                carouselController: _carouselControllers[categoryId],
                itemCount: tasks.length,
                itemBuilder: (context, taskIndex, realIndex) {
                  final task = tasks[taskIndex];
                  final quantity = _serviceQuantities[task.id ?? ''] ?? 0;
                  final double originalPrice = task.price?.basePrice?.toDouble() ?? 0;
                  final double salePrice = task.price?.salePrice?.toDouble() ?? originalPrice;
                  return _buildCarouselCard(task: task, quantity: quantity, originalPrice: originalPrice, discountedPrice: salePrice, screenWidth: screenWidth);
                },
                options: CarouselOptions(
                  height: 420,
                  viewportFraction: 0.85,
                  enableInfiniteScroll: tasks.length > 1,
                  enlargeCenterPage: true,
                  enlargeFactor: 0.2,
                  onPageChanged: (pageIndex, reason) {
                    setState(() {
                      _carouselCurrentPage[categoryId] = pageIndex;
                    });
                  },
                ),
              ),
            if (tasks.length > 1) ...[const SizedBox(height: 16), _buildDotIndicators(tasks.length, categoryId)],
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildCarouselCard({required Task task, required int quantity, required double originalPrice, required double discountedPrice, required double screenWidth}) {
    String? discountBadge;
    final discountType = task.price?.discountType;
    final discountValue = task.price?.discountValue;

    if (discountType != null && discountType != DiscountType.NONE && discountValue != null && discountValue > 0) {
      if (discountType == DiscountType.PERCENTAGE) {
        discountBadge = '${discountValue.toInt()}% OFF';
      } else if (discountType == DiscountType.FLAT) {
        discountBadge = 'Flat ${discountValue.toInt()} Taka OFF';
      }
    }

    final imageUrl = task.images != null && task.images!.isNotEmpty ? task.images!.first.url : null;

    return Container(
      width: screenWidth * 0.9,
      padding: const EdgeInsets.all(12),
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
              child: imageUrl != null
                  ? Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Center(child: Icon(Icons.home_repair_service_outlined, size: 60, color: AppColors.border(context))),
                    )
                  : Center(child: Icon(Icons.home_repair_service_outlined, size: 60, color: AppColors.border(context))),
            ),
          ),
          const SizedBox(height: 16),
          // Content Section
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        task.name ?? '',
                        style: AppTextStyles.textSize16(context, weight: FontWeight.w600),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedboxSpaccing.width02(context),
                    Row(
                      children: [
                        Text('৳${discountedPrice.toStringAsFixed(2)}', style: AppTextStyles.textSize16(context, weight: FontWeight.w600)),
                        if (originalPrice > discountedPrice) ...[
                          const SizedBox(width: 8),
                          Text(
                            '৳${originalPrice.toStringAsFixed(2)}',
                            style: AppTextStyles.textSize10(context, color: AppColors.subtitle(context)).copyWith(decoration: TextDecoration.lineThrough),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () => _showTaskDetailsDialog(task),
                  child: Row(
                    children: [
                      Text(
                        'View Task Details',
                        style: AppTextStyles.textSize12(context, weight: FontWeight.w500, color: AppColors.buttonTextColor(context)),
                      ),
                      Icon(Icons.chevron_right, size: 16, color: AppColors.button(context)),
                    ],
                  ),
                ),
                const Spacer(),
                if (discountBadge != null) ...[
                  Center(
                    child: Text(
                      discountBadge,
                      style: AppTextStyles.textSize12(context, weight: FontWeight.w400, color: AppColors.buttonTextColor(context)),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                // Add to Cart Button
                if (quantity == 0)
                  RoundButtonFlexible(
                    height: 42,
                    showRightIcon: false,
                    backgroundColor: AppColors.textPrimary(context),
                    title: 'Add to Cart',
                    textColor: AppColors.textSecondary(context),
                    onPress: () => _updateQuantity(task.id ?? '', 1),
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
                          onPressed: () => _updateQuantity(task.id ?? '', -1),
                          icon: Icon(Icons.remove, color: AppColors.textPrimary(context)),
                        ),
                        Text(
                          '$quantity',
                          style: AppTextStyles.textSize18(context, weight: FontWeight.w600, color: AppColors.buttonTextColor(context)),
                        ),
                        IconButton(
                          onPressed: () => _updateQuantity(task.id ?? '', 1),
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
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(color: currentPage == index ? AppColors.button(context) : AppColors.border(context), borderRadius: BorderRadius.circular(4)),
        );
      }),
    );
  }

  // ── Cart dialog ──
  void _showCartDialog() {
    final viewModel = Provider.of<ServicesViewGetAllCategoriesViewModel>(context, listen: false);
    final checkoutVM = Provider.of<CheckoutAllServicesViewModel>(context, listen: false);
    final slotVM = Provider.of<GetSlotViewModel>(context, listen: false);

    final categories = viewModel.servicesViewGetAllCategoryData.data?.data?.categories ?? [];
    final double transportFeeValue = viewModel.servicesViewGetAllCategoryData.data?.data?.transportFee?.toDouble() ?? 0.0;
    final minimumOrderAmount = viewModel.servicesViewGetAllCategoryData.data?.data?.minimumOrderAmount;

    showDialog(
      context: context,
      barrierColor: AppColors.showDialougeBackground(context),
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return ServicesCartDialogWidget(
            categories: categories,
            serviceQuantities: _serviceQuantities,
            onQuantityUpdate: (taskId, newQuantity) {
              setState(() {
                if (newQuantity <= 0) {
                  _serviceQuantities.remove(taskId);
                } else {
                  _serviceQuantities[taskId] = newQuantity;
                }
              });
              WidgetsBinding.instance.addPostFrameCallback((_) => _syncGlobalCart());
              setDialogState(() {});
              if (_getTotalItems() == 0) Navigator.pop(context);
            },
            onProceedToCheckout: _navigateCheckOutScreen,
            selectedDate: checkoutVM.selectedDate,
            selectedServiceTime: checkoutVM.selectedServiceTime,
            transportFee: transportFeeValue,
            slotViewModel: slotVM,
            serviceId: widget.serviceId,
            onDateSelected: (DateTime selectedDate) {
              checkoutVM.setSelectedDate(selectedDate);
              slotVM.fetchGetSlotDataApi(selectedDate, widget.serviceId);
              setDialogState(() {});
            },
            onTimeSelected: (String time, String slotId) {
              checkoutVM.setServiceTime(time, slotId);
              setDialogState(() {});
            },
            dateController: TextEditingController(text: checkoutVM.selectedDate != null ? DateFormat('MMMM dd, yyyy').format(checkoutVM.selectedDate!) : ''),
            minimumOrderAmount: minimumOrderAmount,
          );
        },
      ),
    );
  }

  // ── Task details dialog ──
  // ── Task details dialog ── (replace the existing _showTaskDetailsDialog method)
  void _showTaskDetailsDialog(Task task) {
    final imageUrl = task.images != null && task.images!.isNotEmpty ? task.images!.first.url : null;
    final double originalPrice = task.price?.basePrice?.toDouble() ?? 0;
    final double salePrice = task.price?.salePrice?.toDouble() ?? originalPrice;
    final bool showDiscount = task.price?.discountType != DiscountType.NONE && originalPrice > salePrice;

    showDialog(
      context: context,
      barrierColor: AppColors.showDialougeBackground(context),
      builder: (context) => ServicesViewDetailsDialouge(
        imageUrl: imageUrl,
        serviceName: task.name ?? '',
        discountedPrice: salePrice,
        originalPrice: originalPrice,
        showDiscount: showDiscount,

        // ── HTML content fields ──────────────────────────────────────
        description: task.description,
        overview: task.overview,
        steps: task.steps,
        products: task.products,
        benefits: task.benefits,
        instructions: task.instructions,
        details: task.details,

        // ── Structured fields ────────────────────────────────────────
        durationInMin: task.durationInMin,
        faqs: task.faqs,

        onClose: () => Navigator.pop(context),
        getButtonColor: (ctx) => AppColors.button(ctx),
        getBackgroundColor: (ctx) => AppColors.containerBackground(ctx),
        getBorderColor: (ctx) => AppColors.border(ctx),
        getTextColor: (ctx) => AppColors.textPrimary(ctx),
      ),
    );
  }

  // ── Navigate to checkout ──
  void _navigateCheckOutScreen() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId') ?? '';

    if (userId.isEmpty) {
      Utils.flushBarErrorMessage('User ID not found. Please login again.', context);
      return;
    }

    final categories = _getCategories();

    // ── Session location override ──
    final sessionData = await CheckoutSessionLocationService.getAll();
    if (sessionData.location != null && sessionData.address != null) {
      setState(() {
        _customerLocation = sessionData.location;
        _currentCustomerAddress = sessionData.address!;
      });
    }

    final checkoutVM = Provider.of<CheckoutAllServicesViewModel>(context, listen: false);

    final double transportFee = Provider.of<ServicesViewGetAllCategoriesViewModel>(context, listen: false).servicesViewGetAllCategoryData.data?.data?.transportFee?.toDouble() ?? 0.0;

    final result = await Navigator.pushNamed(
      context,
      RoutesName.serviceCheckoutScreen,
      arguments: {
        'customerName': widget.customerName,
        'customerPhone': widget.customerPhone,
        'customerAddress': _currentCustomerAddress,
        'customerLocation': _customerLocation,
        'userId': userId,
        'serviceId': widget.serviceId,
        'categories': categories,
        'serviceQuantities': _serviceQuantities,
        'totalPrice': _calculateTotal(),
        'transportFee': transportFee,
        'selectedDate': checkoutVM.selectedDate,
        'selectedServiceTime': checkoutVM.selectedServiceTime,
        'onAddressUpdate': (String newAddress) {
          setState(() => _currentCustomerAddress = newAddress);
        },


        ///for dynamic stores
        'retailerId': _retailerId ?? '',
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
        setState(() => _serviceQuantities.clear());
        _syncGlobalCart();
      }
    }
  }
}
