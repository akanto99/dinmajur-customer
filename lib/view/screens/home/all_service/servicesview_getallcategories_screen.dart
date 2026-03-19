import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/components/header_appbar.dart';
import 'package:dinmajur_customer/configs/res/sizedbox_spaccing.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:dinmajur_customer/configs/responsive/responsive_ui.dart';
import 'package:dinmajur_customer/data/response/status.dart';
import 'package:dinmajur_customer/model/home_models/all_service_models/services_view_getallcategories_model.dart' hide Image;
import 'package:dinmajur_customer/view/screens/home/helper_widgets/dynamic_serviclist_card_widget.dart';
import 'package:dinmajur_customer/view/screens/home/helper_widgets/dynamic_scroll_categorytab/dynamic_scrollable_categorytab.dart';
import 'package:dinmajur_customer/view_model/homeview_model/all_service_view_models/services_view_getallcategories_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';

class ServicesViewScreen extends StatefulWidget {
  final String serviceId;

  const ServicesViewScreen({Key? key, required this.serviceId}) : super(key: key);

  @override
  State<ServicesViewScreen> createState() => _ServicesViewScreenState();
}

class _ServicesViewScreenState extends State<ServicesViewScreen> {
  final ScrollController _mainScrollController = ScrollController();
  int _selectedTabIndex = 0;
  final Map<int, GlobalKey> _categoryKeys = {};
  bool _isScrolling = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ServicesViewGetAllCategoriesViewModel>(context, listen: false)
          .fetchServicesViewGetAllCategoriesGetApi(widget.serviceId);
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
      }
    }
  }

  bool _isScrollingFlag = false;

  void _scrollToCategory(int index) {
    if (_categoryKeys[index]?.currentContext == null) return;

    setState(() {
      _isScrollingFlag = true;
      _selectedTabIndex = index;
    });

    Future.delayed(Duration(milliseconds: 100), () {
      final RenderBox? renderBox =
      _categoryKeys[index]?.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox == null) {
        setState(() => _isScrollingFlag = false);
        return;
      }

      final position = renderBox.localToGlobal(
        Offset.zero,
        ancestor: context.findRenderObject(),
      );
      final offset =
          _mainScrollController.offset + (position.dy - 60) - 20;

      _mainScrollController
          .animateTo(
        offset,
        duration: Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      )
          .then((_) {
        setState(() => _isScrollingFlag = false);
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
          child: ResPonsiveUi(
            mobile: _body(),
            desktop: _body(),
            tablet: _body(),
          ),
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
          child: Container(height: 60, child: AppBarHeader("Services")),
        ),
        Expanded(
          child: Consumer<ServicesViewGetAllCategoriesViewModel>(
            builder: (context, viewModel, _) {
              final status = viewModel.servicesViewGetAllCategoryData.status;
              final categories =
                  viewModel.servicesViewGetAllCategoryData.data?.data?.categories ?? [];

              if (status == Status.LOADING) {
                return Center(
                  child: LoadingAnimationWidget.progressiveDots(
                    color: AppColors.button(context),
                    size: 50,
                  ),
                );
              }

              if (status == Status.ERROR) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 48, color: Colors.red),
                      SizedBox(height: 16),
                      Text(
                        'Failed to load services',
                        style: AppTextStyles.textSize16(context, color: Colors.red),
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => viewModel
                            .fetchServicesViewGetAllCategoriesGetApi(widget.serviceId),
                        child: Text('Retry'),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.button(context)),
                      ),
                    ],
                  ),
                );
              }

              if (categories.isEmpty) {
                return Center(
                  child: Text(
                    'No categories found',
                    style: AppTextStyles.textSize14(
                        context, color: AppColors.subtitle(context)),
                  ),
                );
              }

              _initializeCategoryKeys(categories);

              return CustomScrollView(
                controller: _mainScrollController,
                slivers: [
                  // ── Category Tabs (sticky top) ──
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
                                      text: "Dinmajur",
                                      style: AppTextStyles.textSize20(context, weight: FontWeight.w600),
                                    ),
                                    TextSpan(
                                      text: " ${viewModel.servicesViewGetAllCategoryData.data?.data?.categories?.first.name ?? 'Services'}",
                                      style: AppTextStyles.textSize20(
                                        context,
                                        weight: FontWeight.w600,
                                        color: Color(0xffD78503),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedboxSpaccing.height01(context),
                              Text(
                                "Professional services at your doorstep",
                                style: AppTextStyles.textSize14(context, weight: FontWeight.w400),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                        SizedboxSpaccing.height03(context),
                        CategoryTabs(
                          categories: categories,
                          iconSize: 60,
                          selectedIndex: _selectedTabIndex,
                          onCategoryTap: _scrollToCategory,
                          getName: (category) => category.name ?? '',
                          getImageUrl: (category) => category.image,
                          getButtonColor: (ctx) => AppColors.button(ctx),
                          getBackgroundColor: (ctx) => AppColors.border(ctx),
                          getBorderColor: (ctx) => AppColors.border(ctx),
                          getSelectedIconColor: (ctx) => AppColors.whiteColor,
                          getSelectedImageColor: (ctx) => AppColors.whiteColor,
                          getTextColor: (ctx) => AppColors.textPrimary(ctx),
                          getTextStyle: (ctx, isSelected) =>
                              AppTextStyles.textSize12(
                                ctx,
                                weight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                                color: isSelected
                                    ? AppColors.button(ctx)
                                    : AppColors.textPrimary(ctx),
                              ),
                          defaultIcon: Icons.design_services_outlined,
                          supportSvg: false,
                        ),
                        SizedBox(height: 20),
                      ],
                    ),
                  ),

                  // ── Category Sections ──
                  ...categories.asMap().entries.map((entry) {
                    final index = entry.key;
                    final category = entry.value;
                    final tasks = category.tasks ?? [];

                    return _buildCategorySection(
                      index: index,
                      category: category,
                      tasks: tasks,
                      screenWidth: screenWidth,
                      screenHeight: screenHeight,
                    );
                  }).toList(),

                  SliverToBoxAdapter(
                    child: SizedBox(height: screenHeight / 1.5),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCategorySection({
    required int index,
    required Category category,
    required List<Task> tasks,
    required double screenWidth,
    required double screenHeight,
  }) {
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
              border: Border(
                bottom: BorderSide(
                  width: 1,
                  color: AppColors.border(context),
                ),
              ),
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
        delegate: SliverChildBuilderDelegate(
              (context, taskIndex) {
            if (taskIndex >= tasks.length) return null;

            final task = tasks[taskIndex];
            final bool isLastItem = taskIndex == tasks.length - 1;

            final imageUrl = task.images != null && task.images!.isNotEmpty
                ? task.images!.first.url
                : null;

            final double originalPrice =
                task.price?.basePrice?.toDouble() ?? 0;
            final double salePrice =
                task.price?.salePrice?.toDouble() ?? originalPrice;
            final bool showDiscount =
                task.price?.discountType != DiscountType.NONE &&
                    originalPrice > salePrice;

            return Container(
              width: screenWidth,
              child: Center(
                child: Container(
                  width: screenWidth * 0.9,
                  child: DynamicServiceCard(
                    imageUrl: imageUrl,
                    defaultIcon: Icons.design_services_outlined,
                    serviceName: task.name ?? '',
                    viewDetailsText: 'View Task Details',
                    onViewDetails: () => _showTaskDetailsDialog(task),
                    discountedPrice: salePrice,
                    originalPrice: originalPrice,
                    showDiscount: showDiscount,
                    quantity: 0, // no cart needed for now
                    onAdd: () {},
                    onRemove: () {},
                    onIncrease: () {},
                    showRoomNumber: false,
                    isLastItem: isLastItem,
                    getButtonColor: (ctx) => AppColors.button(ctx),
                    getBackgroundColor: (ctx) =>
                        AppColors.containerBackground(ctx),
                    getBorderColor: (ctx) => AppColors.border(ctx),
                    getSubtitleColor: (ctx) => AppColors.subtitle(ctx),
                    getTextColor: (ctx) => AppColors.textPrimary(ctx),
                    getTextStyle: (ctx, {weight, color}) =>
                        AppTextStyles.textSize16(
                          ctx,
                          weight: weight ?? FontWeight.normal,
                          color: color ?? AppColors.textPrimary(ctx),
                        ),
                    getSpacing: (ctx) => SizedboxSpaccing.width02(ctx),
                  ),
                ),
              ),
            );
          },
          childCount: tasks.length,
        ),
      ),
    );
  }

  void _showTaskDetailsDialog(Task task) {
    final imageUrl = task.images != null && task.images!.isNotEmpty
        ? task.images!.first.url
        : null;
    final double originalPrice = task.price?.basePrice?.toDouble() ?? 0;
    final double salePrice =
        task.price?.salePrice?.toDouble() ?? originalPrice;

    showDialog(
      context: context,
      barrierColor: AppColors.showDialougeBackground(context),
      builder: (context) => Dialog(
        backgroundColor: AppColors.containerBackground(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Image
              if (imageUrl != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    imageUrl,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 200,
                      color: AppColors.border(context),
                      child: Icon(Icons.design_services_outlined,
                          size: 60, color: AppColors.subtitle(context)),
                    ),
                  ),
                ),
              SizedBox(height: 12),

              // Name
              Text(
                task.name ?? '',
                style: AppTextStyles.textSize18(context, weight: FontWeight.w600),
              ),
              SizedBox(height: 8),

              // Price
              Row(
                children: [
                  Text(
                    '৳${salePrice.toStringAsFixed(2)}',
                    style: AppTextStyles.textSize16(
                        context, weight: FontWeight.w600),
                  ),
                  if (originalPrice > salePrice) ...[
                    SizedBox(width: 8),
                    Text(
                      '৳${originalPrice.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.subtitle(context),
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  ],
                ],
              ),
              SizedBox(height: 12),

              // Description
              if (task.description != null && task.description!.isNotEmpty) ...[
                Text('Description',
                    style: AppTextStyles.textSize14(context,
                        weight: FontWeight.w600)),
                SizedBox(height: 4),
                Text(task.description!,
                    style: AppTextStyles.textSize12(context)),
                SizedBox(height: 12),
              ],

              // Details
              if (task.details != null && task.details!.isNotEmpty) ...[
                Text('Details',
                    style: AppTextStyles.textSize14(context,
                        weight: FontWeight.w600)),
                SizedBox(height: 4),
                Text(task.details!,
                    style: AppTextStyles.textSize12(context)),
                SizedBox(height: 12),
              ],

              // Close button
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.button(context),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Center(
                    child: Text(
                      'Close',
                      style: AppTextStyles.textSize14(context,
                          color: AppColors.whiteColor),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}