import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/components/header_appbar.dart';
import 'package:dinmajur_customer/configs/res/sizedbox_spaccing.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:dinmajur_customer/configs/responsive/responsive_ui.dart';
import 'package:dinmajur_customer/configs/utils/amount_formatter/amount_formatter.dart';
import 'package:dinmajur_customer/configs/utils/routes/routes_name.dart';
import 'package:dinmajur_customer/configs/utils/utils.dart';
import 'package:dinmajur_customer/data/response/status.dart';
import 'package:dinmajur_customer/model/home_models/dropdown_categories_selection_models/family_event_cooking_model/getall_family_event_cooking_model.dart';
import 'package:dinmajur_customer/view/screens/home/dorpdown_categories_selections_and_views/family_event_cooking/helper_widget/cooking_cart_dialouge.dart';
import 'package:dinmajur_customer/view/screens/home/dorpdown_categories_selections_and_views/family_event_cooking/helper_widget/familyevent_cooking_packageimage.dart';
import 'package:dinmajur_customer/view/screens/home/dorpdown_categories_selections_and_views/family_event_cooking/notifier/cooking_checkout_notifier.dart';
import 'package:dinmajur_customer/view/screens/home/helper_widgets/add_location_screen_widget/add_location_screen_widget.dart';
import 'package:dinmajur_customer/view/screens/home/helper_widgets/dynamic_bottom_cart_widget.dart';
import 'package:dinmajur_customer/view/screens/home/helper_widgets/dynamic_scroll_categorytab/dynamic_categorytab.dart';
import 'package:dinmajur_customer/view/screens/home/helper_widgets/dynamic_scroll_categorytab/dynamic_scrollable_categorytab.dart';
import 'package:dinmajur_customer/view_model/homeview_model/dropdown_categories_selection_view_models/family_event_cooking_view_model/getall_family_event_cooking_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FamilyEventCookingScreen extends StatefulWidget {
  final String customerName;
  final String customerPhone;
  final String customerAddress;
  final String serviceName;
  final String description;
  final bool isFromHome;
    final Map<String, dynamic>? customerLocation;

  const FamilyEventCookingScreen({Key? key, required this.customerName, required this.customerPhone, required this.customerAddress,required this.serviceName,required this.description, this.isFromHome = false, this.customerLocation}) : super(key: key);

  @override
  State<FamilyEventCookingScreen> createState() => _FamilyEventCookingScreenState();
}

class _FamilyEventCookingScreenState extends State<FamilyEventCookingScreen> {
  final ScrollController _mainScrollController = ScrollController();
  int _selectedTabIndex = 0;
  int _selectedGuestRangeIndex = 0; // Default to 25-30
  // final Map<int, GlobalKey> _categoryKeys = {};
  Map<String, dynamic>? _customerLocation;
  // Track selected packages per category for REGULAR type (only one category can have selections)
  Map<String, String?> _selectedPackages = {}; // categoryId -> packageId

  // Track selected items for MANUAL type (only one category can have selections)
  Map<String, Set<String>> _selectedManualItems = {}; // categoryId -> Set of itemIds

  String? _activeCategoryId; // Track which category has active selections

  late String _currentCustomerAddress;


  bool _isCurrentTabCustom(List<Datum> data) {
    final safeIndex = _selectedTabIndex.clamp(0, data.length - 1);
    return data[safeIndex].type == 'CUSTOM';
  }

  int _getSelectedManualItemCount() {
    if (_activeCategoryId == null) return 0;
    return _selectedManualItems[_activeCategoryId]?.length ?? 0;
  }

  bool _isRamadanIftarCategory() {
    if (_activeCategoryId == null) return false;

    final viewModel = Provider.of<GetAllFamilyEventCookingViewModel>(context, listen: false);
    final data = viewModel.getAllFamilyEventCookingData.data?.data ?? [];

    for (var category in data) {
      if (category.id == _activeCategoryId) {
        final isRamadanById = category.id == '699aa34437f030dbaca2c078';
        final isRamadanByName = (category.name ?? '').toLowerCase().contains('ramadan iftar');
        return isRamadanById || isRamadanByName;
      }
    }
    return false;
  }

  @override
  void initState() {
    super.initState();

    if (widget.isFromHome) {
      CheckoutSessionLocationService.clear();
    }
    _currentCustomerAddress = widget.customerAddress;
    _customerLocation = widget.customerLocation;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<GetAllFamilyEventCookingViewModel>(context, listen: false).fetchGetAllFamilyEventCookingGetDataApi();
    });
  }

  @override
  void dispose() {
    _mainScrollController.dispose();
    super.dispose();
  }
  // For REGULAR type packages
  void _togglePackageSelection(String categoryId, String packageId) {
    setState(() {
      if (_activeCategoryId != null && _activeCategoryId != categoryId) {
        _selectedPackages.clear();
        _selectedManualItems.clear();
      }

      _activeCategoryId = categoryId;

      if (_selectedPackages[categoryId] == packageId) {
        _selectedPackages[categoryId] = null;
        _activeCategoryId = null;
      } else {
        _selectedPackages[categoryId] = packageId;
      }
    });
  }

  // For MANUAL type items
  void _toggleManualItemSelection(String categoryId, String packageId, String itemId) {
    setState(() {
      if (_activeCategoryId != null && _activeCategoryId != categoryId) {
        _selectedPackages.clear();
        _selectedManualItems.clear();
      }

      _activeCategoryId = categoryId;

      final key = '${packageId}_${itemId}';
      if (!_selectedManualItems.containsKey(categoryId)) {
        _selectedManualItems[categoryId] = {};
      }

      if (_selectedManualItems[categoryId]!.contains(key)) {
        _selectedManualItems[categoryId]!.remove(key);
        if (_selectedManualItems[categoryId]!.isEmpty) {
          _activeCategoryId = null;
        }
      } else {
        _selectedManualItems[categoryId]!.add(key);
      }
    });
  }

  bool _isPackageSelected(String categoryId, String packageId) {
    return _selectedPackages[categoryId] == packageId;
  }

  bool _isManualItemSelected(String categoryId, String packageId, String itemId) {
    final key = '${packageId}_${itemId}';
    return _selectedManualItems[categoryId]?.contains(key) ?? false;
  }

  bool _canSelectFromCategory(String categoryId) {
    return _activeCategoryId == null || _activeCategoryId == categoryId;
  }

  double _calculateTotal() {
    if (_activeCategoryId == null) return 0.0;
    final viewModel = Provider.of<GetAllFamilyEventCookingViewModel>(context, listen: false);
    final data = viewModel.getAllFamilyEventCookingData.data?.data ?? [];
    double total = 0;

    for (var category in data) {
      if (category.id != _activeCategoryId) continue;

      if (category.type == 'REGULAR') {
        final selectedPackageId = _selectedPackages[category.id];
        if (selectedPackageId != null) {
          for (var package in category.packages ?? []) {
            if (package.id == selectedPackageId && _selectedGuestRangeIndex < (package.prices?.length ?? 0)) {
              total += package.prices![_selectedGuestRangeIndex].salePrice?.toDouble() ?? 0;
              break;
            }
          }
        }
      } else if (category.type == 'MANUAL') {
        for (var package in category.packages ?? []) {
          for (var item in package.items ?? []) {
            if (_isManualItemSelected(category.id ?? '', package.id ?? '', item.id ?? '') && _selectedGuestRangeIndex < (item.prices?.length ?? 0)) {
              total += item.prices![_selectedGuestRangeIndex].salePrice?.toDouble() ?? 0;
            }
          }
        }
      } else if (category.type == 'CUSTOM') {
        final selectedPackageId = _selectedPackages[category.id];
        if (selectedPackageId != null) {
          for (var package in category.packages ?? []) {
            if (package.id == selectedPackageId) {
              total += package.customPrice?.salePrice?.toDouble() ?? 0;
              break;
            }
          }
        }
      }
      break;
    }
    return total;
  }

  double _calculateSaved() {
    if (_activeCategoryId == null) return 0.0;

    final viewModel = Provider.of<GetAllFamilyEventCookingViewModel>(context, listen: false);
    final data = viewModel.getAllFamilyEventCookingData.data?.data ?? [];

    double totalSaved = 0;

    for (var category in data) {
      if (category.id != _activeCategoryId) continue;

      if (category.type == 'REGULAR') {
        final selectedPackageId = _selectedPackages[category.id];
        if (selectedPackageId != null) {
          for (var package in category.packages ?? []) {
            if (package.id == selectedPackageId && _selectedGuestRangeIndex < (package.prices?.length ?? 0)) {
              final p = package.prices![_selectedGuestRangeIndex];
              totalSaved += ((p.originalPrice?.toDouble() ?? 0) - (p.salePrice?.toDouble() ?? 0));
              break;
            }
          }
        }
      } else if (category.type == 'MANUAL') {
        for (var package in category.packages ?? []) {
          for (var item in package.items ?? []) {
            if (_isManualItemSelected(category.id ?? '', package.id ?? '', item.id ?? '') && _selectedGuestRangeIndex < (item.prices?.length ?? 0)) {
              final p = item.prices![_selectedGuestRangeIndex];
              totalSaved += ((p.originalPrice?.toDouble() ?? 0) - (p.salePrice?.toDouble() ?? 0));
            }
          }
        }
      } else if (category.type == 'CUSTOM') {
        final selectedPackageId = _selectedPackages[category.id];
        if (selectedPackageId != null) {
          for (var package in category.packages ?? []) {
            if (package.id == selectedPackageId && package.customPrice != null) {
              totalSaved += ((package.customPrice!.originalPrice?.toDouble() ?? 0) - (package.customPrice!.salePrice?.toDouble() ?? 0));
              break;
            }
          }
        }
      }
      break;
    }
    return totalSaved;
  }

  int _getTotalItems() {
    if (_activeCategoryId == null) return 0;

    final viewModel = Provider.of<GetAllFamilyEventCookingViewModel>(context, listen: false);
    final data = viewModel.getAllFamilyEventCookingData.data?.data ?? [];

    for (var category in data) {
      if (category.id != _activeCategoryId) continue;
      if (category.type == 'REGULAR') {
        return _selectedPackages[_activeCategoryId] != null ? 1 : 0;
      } else if (category.type == 'MANUAL') {
        return _selectedManualItems[_activeCategoryId]?.length ?? 0;
      } else if (category.type == 'CUSTOM') {
        return _selectedPackages[_activeCategoryId] != null ? 1 : 0;
      }
    }

    return 0;
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
          child: Consumer<GetAllFamilyEventCookingViewModel>(
            builder: (context, viewModel, _) {
              final data = viewModel.getAllFamilyEventCookingData.data?.data ?? [];
              final isLoading = viewModel.getAllFamilyEventCookingData.status == Status.LOADING;
              final hasError = viewModel.getAllFamilyEventCookingData.status == Status.ERROR;

              // if (data.isNotEmpty) {
              //   _initializeCategoryKeys(data);
              // }

              if (isLoading) {
                return Center(child: LoadingAnimationWidget.progressiveDots(color: AppColors.button(context), size: 50));
              }

              if (hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 48, color: Colors.red),
                      SizedBox(height: 16),
                      Text('Failed to load services', style: AppTextStyles.textSize16(context, color: Colors.red)),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => viewModel.fetchGetAllFamilyEventCookingGetDataApi(),
                        child: Text('Retry'),
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.button(context)),
                      ),
                    ],
                  ),
                );
              }

              if (data.isEmpty) return _buildEmptyState();

              final isCustomTab = _isCurrentTabCustom(data);

              return CustomScrollView(
                controller: _mainScrollController,
                slivers: [
                  // Header Section
                  SliverToBoxAdapter(
                    child: Column(
                      children: [
                        SizedboxSpaccing.height03(context),
                        Container(
                          width: screenWidth * 0.9,
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Text("Family", style: AppTextStyles.textSize20(context, weight: FontWeight.w600)),
                                  Text(
                                    " ${widget.serviceName}",
                                    style: AppTextStyles.textSize20(context, weight: FontWeight.w600, color: Color(0xffD78503)),
                                  ),
                                  Text(" Service", style: AppTextStyles.textSize20(context, weight: FontWeight.w600)),
                                ],
                              ),
                              SizedboxSpaccing.height01(context),
                              Text(
                                // "Female Chef • Two Female Assistants • Home Event Experts",
                                widget.description,
                                style: AppTextStyles.textSize14(context, weight: FontWeight.w400),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                        SizedboxSpaccing.height03(context),

                        // Category Tabs
                        CategoryTabs(
                          categories: data,
                          iconSize: 68,
                          height: 130,
                          selectedIndex: _selectedTabIndex,
                          // onCategoryTap: (index) {
                          //   final selectedCategory = data[index];
                          //   print('Category ID: ${selectedCategory.id ?? ''}');
                          //   setState(() => _selectedTabIndex = index);
                          //   _mainScrollController.animateTo(
                          //     0,
                          //     duration: Duration(milliseconds: 300),
                          //     curve: Curves.easeInOut,
                          //   );
                          // },
                          onCategoryTap: (index) {
                            final selectedCategory = data[index];
                            print('Category ID: ${selectedCategory.id ?? ''}');
                            setState(() {
                              _selectedTabIndex = index;
                              // Clear all selections when switching category tab
                              _selectedPackages.clear();
                              _selectedManualItems.clear();
                              _activeCategoryId = null;
                            });
                            _mainScrollController.animateTo(
                              0,
                              duration: Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          },
                          getName: (category) => category.name ?? '',
                          getImageUrl: (category) => category.image?.url ?? null,
                          getButtonColor: (context) => AppColors.button(context),
                          getBackgroundColor: (context) => AppColors.border(context),
                          getBorderColor: (context) => AppColors.border(context),
                          getSelectedIconColor: (context) => AppColors.whiteColor,
                          getSelectedImageColor: (context) => AppColors.whiteColor,
                          getTextColor: (context) => AppColors.textPrimary(context),
                          getTextStyle: (context, isSelected) =>
                              AppTextStyles.textSize12(context, weight: isSelected ? FontWeight.w600 : FontWeight.w400, color: isSelected ? AppColors.button(context) : AppColors.textPrimary(context)),
                          defaultIcon: Icons.restaurant,
                          supportSvg: false,
                        ),
                        // Guest range hidden for CUSTOM
                        if (!isCustomTab)
                          ...[
                            _buildGuestRangeSelector(screenWidth, data),

                            SizedboxSpaccing.height02(context),
                          ],

                        // Info Banner
                        Container(
                          width: screenWidth * 0.9,
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.textFieldFill(context),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.border(context)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                height: 34,
                                width: 34,
                                decoration: BoxDecoration(color: AppColors.containerBackground(context), borderRadius: BorderRadius.circular(8)),
                                child: Icon(Icons.info, size: 20, color: AppColors.textPrimary(context)),
                              ),
                              SizedboxSpaccing.width01(context),
                              Expanded(child: Text("Grocery/Bazar Not Included. We Do Cooking Only.", style: AppTextStyles.textSize12(context))),
                            ],
                          ),
                        ),
                        SizedBox(height: 15),
                      ],
                    ),
                  ),

                  // Sticky Headers with Package Lists
                  // ...data.asMap().entries.map((entry) {
                  //   int index = entry.key;
                  //   Datum category = entry.value;
                  //
                  //   return SliverStickyHeader(
                  //     header: Container(
                  //       key: _categoryKeys[index],
                  //       width: screenWidth,
                  //       color: AppColors.containerBackground(context),
                  //       child: Center(
                  //         child: Container(
                  //           width: screenWidth * 0.9,
                  //           padding: EdgeInsets.symmetric(vertical: 12),
                  //           decoration: BoxDecoration(
                  //             color: AppColors.containerBackground(context),
                  //             border: Border(
                  //               bottom: BorderSide(width: 1, color: AppColors.border(context)),
                  //             ),
                  //           ),
                  //           child: Text(
                  //             category.name ?? '',
                  //             style: AppTextStyles.textSize18(context, weight: FontWeight.w600),
                  //           ),
                  //         ),
                  //       ),
                  //     ),
                  //     sliver: SliverToBoxAdapter(
                  //       child: Center(
                  //         child: Container(
                  //           width: screenWidth * 0.9,
                  //           child: Column(
                  //             children: [
                  //               // Show packages based on category type
                  //               if (category.type == 'REGULAR')
                  //                 ...((category.packages ?? []).asMap().entries.map((pkgEntry) {
                  //                   final package = pkgEntry.value;
                  //                   final isLast = pkgEntry.key == (category.packages?.length ?? 0) - 1;
                  //                   return _buildRegularPackageCard(category, package, screenWidth, isLast);
                  //                 }))
                  //               else if (category.type == 'MANUAL')
                  //                 ...((category.packages ?? []).asMap().entries.map((pkgEntry) {
                  //                   final package = pkgEntry.value;
                  //                   final isLast = pkgEntry.key == (category.packages?.length ?? 0) - 1;
                  //                   return _buildManualPackageSection(category, package, screenWidth, isLast);
                  //                 })),
                  //               SizedboxSpaccing.height04(context),
                  //             ],
                  //           ),
                  //         ),
                  //       ),
                  //     ),
                  //   );
                  // }).toList(),
                  _buildSelectedCategorySliver(data, screenWidth),

                  // Bottom Padding
                  SliverToBoxAdapter(
                    child: SizedBox(height: screenHeight * .5),
                  ),
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

  Widget _buildGuestRangeSelector(double screenWidth, List<Datum> data) {
    // Collect all unique guest ranges from the data (preserving order)
    final List<GuestRange> guestRanges = [];
    final Set<String> seenIds = {};

    for (var category in data) {
      for (var package in category.packages ?? []) {
        // Check prices on packages (REGULAR type)
        for (var price in package.prices ?? []) {
          if (price.guestRange != null && !seenIds.contains(price.guestRange!.id)) {
            seenIds.add(price.guestRange!.id!);
            guestRanges.add(price.guestRange!);
          }
        }
        // Check prices on items (MANUAL type)
        for (var item in package.items ?? []) {
          for (var price in item.prices ?? []) {
            if (price.guestRange != null && !seenIds.contains(price.guestRange!.id)) {
              seenIds.add(price.guestRange!.id!);
              guestRanges.add(price.guestRange!);
            }
          }
        }
      }
    }

    if (guestRanges.isEmpty) return SizedBox.shrink();

    const int visibleCount = 3;
    final ScrollController _rangeScrollController = ScrollController();
    final double itemWidth = (screenWidth * 0.9) / visibleCount;

    return Container(
      width: screenWidth * 0.9,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Number of Guests', style: AppTextStyles.textSize14(context, weight: FontWeight.w600)),
          SizedBox(height: 12),
          Container(
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.button(context),
              borderRadius: BorderRadius.circular(25),
            ),
            child: guestRanges.length <= visibleCount
            // No scrolling needed
                ? Padding(
              padding: EdgeInsets.all(4),
              child: Row(
                children: List.generate(guestRanges.length, (index) {
                  final isSelected = _selectedGuestRangeIndex == index;
                  return Expanded(
                    child: _buildRangeTab(index, guestRanges[index].label ?? '', isSelected),
                  );
                }),
              ),
            )
            // Scrollable
                : NotificationListener<ScrollNotification>(
              onNotification: (_) => false,
              child: ListView.builder(
                controller: _rangeScrollController,
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.all(4),
                itemCount: guestRanges.length,
                itemBuilder: (context, index) {
                  final isSelected = _selectedGuestRangeIndex == index;
                  return SizedBox(
                    width: itemWidth - (8 / visibleCount), // account for padding
                    child: _buildRangeTab(index, guestRanges[index].label ?? '', isSelected),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildRangeTab(int index, String label, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() => _selectedGuestRangeIndex = index);
        // Auto-scroll so selected is visible (center it)
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.whiteColor : Colors.transparent,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Center(
          child: Text(
            label,
            style: AppTextStyles.textSize14(
              context,
              weight: FontWeight.w600,
              color: isSelected ? AppColors.blackColor : AppColors.whiteColor,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedCategorySliver(List<Datum> data, double screenWidth) {
    if (data.isEmpty) return SliverToBoxAdapter(child: SizedBox.shrink());

    final safeIndex = _selectedTabIndex.clamp(0, data.length - 1);
    final Datum category = data[safeIndex];

    return SliverStickyHeader(
      header: Container(
        width: screenWidth,
        color: AppColors.containerBackground(context),
        child: Center(
          child: Container(
            width: screenWidth * 0.9,
            padding: EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.containerBackground(context),
              border: Border(
                bottom: BorderSide(width: 1, color: AppColors.border(context)),
              ),
            ),
            child: Text(
              category.name ?? '',
              style: AppTextStyles.textSize18(context, weight: FontWeight.w600),
            ),
          ),
        ),
      ),
      sliver: SliverToBoxAdapter(
        child: Center(
          child: Container(
            width: screenWidth * 0.9,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (category.type == 'REGULAR')
                  ...((category.packages ?? []).asMap().entries.map((e) {
                    final isLast = e.key == (category.packages?.length ?? 0) - 1;
                    return _buildRegularPackageCard(category, e.value, screenWidth, isLast);
                  }))
                else if (category.type == 'MANUAL')
                  ...((category.packages ?? []).asMap().entries.map((e) {
                    final isLast = e.key == (category.packages?.length ?? 0) - 1;
                    return _buildManualPackageSection(category, e.value, screenWidth, isLast);
                  }))
                else if (category.type == 'CUSTOM')
                  ...((category.packages ?? []).asMap().entries.map((e) {
                    final isLast = e.key == (category.packages?.length ?? 0) - 1;
                    return _buildCustomPackageCard(category, e.value, screenWidth, isLast);
                  })),
                SizedboxSpaccing.height04(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Build card for REGULAR type packages
  Widget _buildRegularPackageCard(Datum category, Package package, double screenWidth, bool isLast) {
    final isSelected = _isPackageSelected(category.id ?? '', package.id ?? '');
    final currentPrice = _selectedGuestRangeIndex < (package.prices?.length ?? 0) ? package.prices![_selectedGuestRangeIndex].salePrice?.toDouble() ?? 0 : 0.0;
    final originalPrice = _selectedGuestRangeIndex < (package.prices?.length ?? 0) ? package.prices![_selectedGuestRangeIndex].originalPrice?.toDouble() ?? 0 : 0.0;
    final hasDiscount = originalPrice > currentPrice;
    final canSelect = _canSelectFromCategory(category.id ?? '');

    return Container(
      padding: EdgeInsets.only(top: 16, bottom: isLast ? 0 : 8),
      decoration: BoxDecoration(
        border: isLast ? null : Border(bottom: BorderSide(color: AppColors.border(context), width: 1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(package.name ?? '', style: AppTextStyles.textSize16(context, weight: FontWeight.w500)),
                SizedBox(height: 4),
                Row(
                  children: [
                    Text('Price - ৳${AmountFormatter.format(currentPrice)} টাকা', style: AppTextStyles.textSize14(context, weight: FontWeight.w500)),
                    if (hasDiscount) ...[
                      SizedBox(width: 8),
                      Text(
                        '৳${AmountFormatter.format(originalPrice)}',
                        style: AppTextStyles.textSize12(context, color: AppColors.textPrimary(context).withOpacity(0.5)).copyWith(decoration: TextDecoration.lineThrough),
                      ),
                    ],
                  ],
                ),
                if (package.items != null && package.items!.isNotEmpty) ...[
                  SizedBox(height: 8),
                  ...package.items!.map(
                        (item) => Padding(
                      padding: EdgeInsets.only(bottom: 4),
                      child: Text(
                        // '${package.items!.indexOf(item) + 1}. '
                          '${item.name ?? ''}', style: AppTextStyles.textSize14(context)),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Package Selection Image - Pass Package instead of Datum
          FamilyEventCookingPackageImage(
            imageUrl:package.image?.url,
            isSelected: isSelected,
            canSelect: canSelect,
            onToggle: () => _togglePackageSelection(category.id ?? '', package.id ?? ''),
            getButtonColor: (context) => AppColors.button(context),
            getBorderColor: (context) => AppColors.border(context),
          ),
        ],
      ),
    );
  }

  // Build section for MANUAL type packages with checkable items
  Widget _buildManualPackageSection(Datum category, Package package, double screenWidth, bool isLast) {
    return Container(
      padding: EdgeInsets.only(top: 16, bottom: isLast ? 0 : 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(package.name ?? '', style: AppTextStyles.textSize16(context, weight: FontWeight.w500)),
          SizedBox(height: 8),

          // List all items as checkable
          ...((package.items ?? []).asMap().entries.map((entry) {
            final item = entry.value;
            final isLastItem = entry.key == (package.items?.length ?? 0) - 1;
            return _buildManualItemCard(category, package, item, screenWidth, isLastItem);
          })),
        ],
      ),
    );
  }

  // Build card for individual MANUAL items
  Widget _buildManualItemCard(Datum category, Package package, Item item, double screenWidth, bool isLast) {
    final isSelected = _isManualItemSelected(category.id ?? '', package.id ?? '', item.id ?? '');
    final canSelect = _canSelectFromCategory(category.id ?? '');

    final currentPriceInfo = _selectedGuestRangeIndex < (item.prices?.length ?? 0) ? item.prices![_selectedGuestRangeIndex] : null;

    final salePrice = currentPriceInfo?.salePrice?.toDouble() ?? 0;
    final originalPrice = currentPriceInfo?.originalPrice?.toDouble() ?? 0;
    final hasDiscount = originalPrice > salePrice;

    return GestureDetector(
      onTap: () => _toggleManualItemSelection(category.id ?? '', package.id ?? '', item.id ?? ''),
      child: Container(
        margin: EdgeInsets.only(bottom: isLast ? 0 : 12),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.containerBackground(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? AppColors.buttonTextColor(context) : AppColors.border(context), width: 1),
        ),
        child: Row(
          children: [
            // Checkbox
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.button(context) : Colors.transparent,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: isSelected ? AppColors.button(context) : AppColors.border(context), width: 2),
              ),
              child: isSelected ? Icon(Icons.check, size: 14, color: AppColors.whiteColor) : null,
            ),

            SizedboxSpaccing.width03(context),

            // Item details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.name ?? '', style: AppTextStyles.textSize14(context, weight: FontWeight.w500)),
                  if (item.description != null && item.description!.isNotEmpty) ...[
                    SizedBox(height: 4),
                    Text(item.description!, style: AppTextStyles.textSize12(context, color: AppColors.subtitle(context))),
                  ],
                ],
              ),
            ),
            Row(
              children: [
                Text(
                  '৳${AmountFormatter.format(salePrice)}',
                  style: AppTextStyles.textSize14(context, weight: FontWeight.w600, color: AppColors.buttonTextColor(context)),
                ),
                if (hasDiscount) ...[
                  SizedBox(width: 8),
                  Text(
                    '৳${AmountFormatter.format(originalPrice)}',
                    style: AppTextStyles.textSize12(context, color: AppColors.subtitle(context)).copyWith(decoration: TextDecoration.lineThrough),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomPackageCard(Datum category, Package package, double screenWidth, bool isLast) {
    final isSelected = _isPackageSelected(category.id ?? '', package.id ?? '');
    final salePrice = package.customPrice?.salePrice?.toDouble() ?? 0;
    final originalPrice = package.customPrice?.originalPrice?.toDouble() ?? 0;
    final hasDiscount = originalPrice > salePrice;
    final canSelect = _canSelectFromCategory(category.id ?? '');

    return Container(
      padding: EdgeInsets.only(top: 16, bottom: isLast ? 0 : 8),
      decoration: BoxDecoration(
        border: isLast ? null : Border(bottom: BorderSide(color: AppColors.border(context), width: 1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(package.name ?? '', style: AppTextStyles.textSize16(context, weight: FontWeight.w500)),
                SizedBox(height: 4),
                Row(
                  children: [
                    Text('Price - ৳${AmountFormatter.format(salePrice)} টাকা', style: AppTextStyles.textSize14(context, weight: FontWeight.w500)),
                    if (hasDiscount) ...[
                      SizedBox(width: 8),
                      Text(
                        '৳${AmountFormatter.format(originalPrice)}',
                        style: AppTextStyles.textSize12(context, color: AppColors.textPrimary(context).withOpacity(0.5)).copyWith(decoration: TextDecoration.lineThrough),
                      ),
                    ],
                  ],
                ),
                if (package.items != null && package.items!.isNotEmpty) ...[
                  SizedBox(height: 8),
                  ...package.items!.map(
                        (item) => Padding(
                      padding: EdgeInsets.only(bottom: 4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.name ?? '', style: AppTextStyles.textSize14(context)),
                          SizedBox(height: 4),
                          if (item.description != null && item.description!.isNotEmpty)
                            Html(
                              data: item.description!,
                              style: {
                                "body": Style(
                                  margin: Margins.zero,
                                  padding: HtmlPaddings.zero,
                                ),
                                "h1,h2,h3,h4,h5,h6": Style(
                                  margin: Margins.zero,
                                ),
                                "p": Style(
                                  margin: Margins.zero,
                                  padding: HtmlPaddings.zero,
                                ),
                                "ul": Style(
                                  margin: Margins.zero,
                                  padding: HtmlPaddings.only(left: 15), // control list indent
                                ),
                                "ol": Style(
                                  margin: Margins.zero,
                                  padding: HtmlPaddings.only(left: 15), // control numbering alignment
                                ),
                                "li": Style(
                                  margin: Margins.zero,
                                  padding: HtmlPaddings.zero,
                                ),
                              },
                            )
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          FamilyEventCookingPackageImage(
            imageUrl: package.image?.url,
            isSelected: isSelected,
            canSelect: canSelect,
            onToggle: () => _togglePackageSelection(category.id ?? '', package.id ?? ''),
            getButtonColor: (context) => AppColors.button(context),
            getBorderColor: (context) => AppColors.border(context),
          ),
        ],
      ),
    );
  }

  // ─── Cart & checkout ──────────────────────────────────────────────────────

  void _showCartDialog() {
    final viewModel = Provider.of<GetAllFamilyEventCookingViewModel>(context, listen: false);
    final checkoutVM = Provider.of<CookingCheckoutViewModel>(context, listen: false);
    final data = viewModel.getAllFamilyEventCookingData.data?.data ?? [];
    final transportFeeValue = viewModel.getAllFamilyEventCookingData.data?.meta?.transportFee?.value?.toDouble() ?? 0.0;
    if (_isRamadanIftarCategory()) {
      final selectedCount = _getSelectedManualItemCount();
      if (selectedCount < 8) {
        Utils.flushBarErrorMessage(
          'Ramadan Iftar items should be at least 8 items (currently $selectedCount selected)',
          context,
        );
        return;
      }
    }
    showDialog(
      context: context,
      barrierColor: AppColors.showDialougeBackground(context),
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return FamilyEventCookingCartDialog(
            categories: data,
            selectedPackages: _selectedPackages,
            selectedManualItems: _selectedManualItems,
            activeCategoryId: _activeCategoryId,
            selectedGuestRangeIndex: _selectedGuestRangeIndex,
            selectedDate: checkoutVM.selectedDate,
            selectedServiceTime: checkoutVM.selectedServiceTime,
            transportFee: transportFeeValue,
            onDateSelected: (DateTime selectedDate) {
              checkoutVM.setSelectedDate(selectedDate);
              setDialogState(() {});
            },
            onTimeSelected: (String time) {
              checkoutVM.setServiceTime(time);
              setDialogState(() {});
            },
            dateController: TextEditingController(text: checkoutVM.selectedDate != null ? DateFormat('MMMM dd, yyyy').format(checkoutVM.selectedDate!) : ''),
            onProceedToCheckout: _navigateCheckOutScreen,
          );
        },
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

    // Get checkout view model data
    final checkoutVM = Provider.of<CookingCheckoutViewModel>(context, listen: false);

    // Get the data before navigation
    final viewModel = Provider.of<GetAllFamilyEventCookingViewModel>(context, listen: false);
    final categories = viewModel.getAllFamilyEventCookingData.data?.data ?? [];
    final transportFeeValue = viewModel.getAllFamilyEventCookingData.data?.meta?.transportFee?.value?.toDouble() ?? 0.0;

        final sessionData = await CheckoutSessionLocationService.getAll();
    if (sessionData.location != null && sessionData.address != null) {
      setState(() {
        _customerLocation = sessionData.location;
        _currentCustomerAddress = sessionData.address!;
      });
    }

    // Navigate to CheckoutScreen using named route
    final result = await Navigator.pushNamed(
      context,
      RoutesName.cookingCheckoutScreen,
      arguments: {
        'customerName': widget.customerName,
        'customerPhone': widget.customerPhone,
        'customerAddress': _currentCustomerAddress,
        'customerLocation': _customerLocation,   // ✅ now session location if edited
        'userId': userId,
        'categories': categories,
        'selectedPackages': _selectedPackages,
        'selectedManualItems': _selectedManualItems,
        'activeCategoryId': _activeCategoryId,
        'selectedGuestRangeIndex': _selectedGuestRangeIndex,
        'totalPrice': _calculateTotal(),
        'savedAmount': _calculateSaved(),
        // 'transportFee': 80.0,
        'transportFee': transportFeeValue, // Use value from model
        'selectedDate': checkoutVM.selectedDate,
        'selectedServiceTime': checkoutVM.selectedServiceTime,
        'onAddressUpdate': (String newAddress) {
          setState(() {
            _currentCustomerAddress = newAddress;
          });
        },
      },
    );

    // If booking was successful, clear the selections
    if (result == true) {
      setState(() {
        _selectedPackages.clear();
        _selectedManualItems.clear();
        _activeCategoryId = null;
      });
    }
  }
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.restaurant_menu_outlined,
            size: 60,
            color: AppColors.textPrimary(context).withOpacity(0.3),
          ),
          SizedBox(height: 24),
          Text(
            'No Packages Available',
            style: AppTextStyles.textSize18(context,
                weight: FontWeight.w600,
                color: AppColors.textPrimary(context)
            ),
          ),
          SizedBox(height: 12),
          Text(
            'Please check back later for cooking packages',
            style: AppTextStyles.textSize14(context,
                color: AppColors.subtitle(context)
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
