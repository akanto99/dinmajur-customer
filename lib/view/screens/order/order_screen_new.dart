import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/components/header_appbar.dart';
import 'package:dinmajur_customer/configs/res/sizedbox_spaccing.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:dinmajur_customer/configs/responsive/responsive_ui.dart';
import 'package:dinmajur_customer/configs/utils/routes/routes_name.dart';
import 'package:dinmajur_customer/configs/utils/utils.dart';
import 'package:dinmajur_customer/data/response/status.dart';
import 'package:dinmajur_customer/model/order_models/get_all_order_model.dart';
import 'package:dinmajur_customer/view/navigation_bar.dart';
import 'package:dinmajur_customer/view_model/order_view_models/complete_orders_view_model.dart';
import 'package:dinmajur_customer/view_model/order_view_models/running_orders_view_model.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    // Fetch running orders data when widget initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final runningOrderViewModel = Provider.of<RunningOrdersViewModel>(context, listen: false);
      runningOrderViewModel.fetchRunningOrdersGetDataApi();
      runningOrderViewModel.fetchPendingOrdersGetDataApi();
    });
  }
  Future<void> _handleRefresh() async {
    try {
      debugPrint('🔄 OrderScreen: Pull to refresh triggered');

      // 2. Refresh orders based on selected tab
      if (_selectedTabIndex == 0) {
        // Running orders tab
        final pendingOrderViewModel = Provider.of<RunningOrdersViewModel>(context, listen: false);
        await pendingOrderViewModel.fetchPendingOrdersGetDataApi();
        debugPrint('🔄 OrderScreen: Running orders refreshed');
      }
      if (_selectedTabIndex == 1) {
        // Running orders tab
        final runningOrderViewModel = Provider.of<RunningOrdersViewModel>(context, listen: false);
        await runningOrderViewModel.fetchRunningOrdersGetDataApi();
        debugPrint('🔄 OrderScreen: Running orders refreshed');
      }
      else if (_selectedTabIndex == 2) {
        // Completed orders tab
        final completeOrderViewModel = Provider.of<CompleteOrdersViewModel>(context, listen: false);
        await completeOrderViewModel.fetchCompleteOrdersGetDataApi();
        debugPrint('🔄 OrderScreen: Completed orders refreshed');
      }

      debugPrint('🔄 OrderScreen: Refresh completed successfully');


    } catch (e) {
      debugPrint('🔄 OrderScreen: Refresh failed - $e');
      if (mounted) {
        Utils.flushBarErrorMessage("Refresh failed", context);
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.containerBackground(context),
        body: ResPonsiveUi(mobile: body(), desktop: body(), tablet: body()),
      ),
    );
  }

  Widget body() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Column(
      children: [
        // Header AppBar
        GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => NavigationScreen(initialIndex: 0))),
            child: AppBarHeader("Orders")),

        /// Tabs
        Container(
          width: screenWidth,
          height: 50,
          color: AppColors.containerBackground(context),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildTab("Pending", 0),
              _buildTab("Running", 1),
              _buildTab("Completed", 2)
            ],
          ),
        ),
        SizedboxSpaccing.height015(context),

        // Content
        Expanded(
          child: RefreshIndicator(
            onRefresh: _handleRefresh,
            color: AppColors.textPrimary(context),
            backgroundColor: AppColors.containerBackground(context),
            displacement: 40,
            strokeWidth: 2.0,
            child: Container(
              width: screenWidth * 0.9,
              child: _getSelectedWidget(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTab(String title, int index) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSelected = _selectedTabIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTabIndex = index;
        });

        // Fetch orders data when any tab is clicked
        if (index == 0) {
          // Running tab clicked - reload running orders
          final pendingOrderViewModel = Provider.of<RunningOrdersViewModel>(context, listen: false);
          pendingOrderViewModel.fetchPendingOrdersGetDataApi();
        }
        if (index == 1) {
          // Running tab clicked - reload running orders
          final runningOrderViewModel = Provider.of<RunningOrdersViewModel>(context, listen: false);
          runningOrderViewModel.fetchRunningOrdersGetDataApi();
        }
        else if (index == 2) {
          // Complete tab clicked - reload completed orders
          final completeOrderViewModel = Provider.of<CompleteOrdersViewModel>(context, listen: false);
          completeOrderViewModel.fetchCompleteOrdersGetDataApi();
        }
      },
      child: Container(
        width: screenWidth * 0.3,
        decoration: BoxDecoration(
          color: Colors.transparent,
          border: Border(
            bottom: BorderSide(
              color: AppColors.border(context),
              width: 1.0,
            ),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(height: 2),
            Text(
              title,
              style: AppTextStyles.textSize16(
                context,
                color: isSelected
                    ? AppColors.button(context)
                    : AppColors.form_hover(context),
                weight: FontWeight.w500,
              ),
            ),
            Container(
              width: screenWidth * 0.4,
              height: 2,
              color: isSelected
                  ? AppColors.button(context)
                  : AppColors.containerBackground(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _getSelectedWidget() {
    switch (_selectedTabIndex) {
      case 0:
        return WidgetPendingOrder();
      case 1:
        return WidgetRunningOrder();
      case 2:
        return WidgetCompletedOrder();
      default:
        return Container();
    }
  }

  Widget WidgetPendingOrder() {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Consumer<RunningOrdersViewModel>(
      builder: (context, viewModel, child) {
        switch (viewModel.pendingOrdersData.status) {
          case Status.LOADING:
            return  Container(height: screenHeight,
                color: AppColors.containerBackground(context),
                child: Center(child: Container(height: 15, width: 50, child: LoadingAnimationWidget.progressiveDots(color: AppColors.button(context), size: 45))));
          case Status.ERROR:
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 60,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Error loading orders',
                    style: AppTextStyles.textSize16(context),
                  ),
                  SizedBox(height: 8),
                  Text(
                    viewModel.pendingOrdersData.message.toString(),
                    style: AppTextStyles.textSize12(
                      context,
                      color: AppColors.subtitle(context),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      viewModel.fetchPendingOrdersGetDataApi();
                    },
                    child: Text('Retry'),
                  ),
                ],
              ),
            );

          case Status.COMPLETED:
            final orderData = viewModel.pendingOrdersData.data;

            if (orderData == null ||
                orderData.data == null ||
                orderData.data!.data == null ||
                orderData.data!.data!.isEmpty) {
              // ✅ IMPORTANT: Wrap empty state with ListView to enable pull-to-refresh
              return ListView(
                physics: AlwaysScrollableScrollPhysics(),
                children: [
                  Container(
                    height: MediaQuery.of(context).size.height * 0.6,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            FontAwesomeIcons.boxOpen,
                            color: AppColors.subtitle(context),
                            size: 50,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No Pending Orders',
                            style: AppTextStyles.textSize16(context),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'You don\'t have any pending orders at the moment',
                            style: AppTextStyles.textSize12(
                              context,
                              color: AppColors.subtitle(context),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                await viewModel.fetchPendingOrdersGetDataApi();
              },
              child: ListView.builder(
                itemCount: orderData.data!.data!.length,
                itemBuilder: (context, index) {
                  final datum = orderData.data!.data![index];
                  return _buildOrderCard(datum, screenWidth, screenHeight, isPendingTab: true);
                },
              ),
            );

          default:
            return Container();
        }
      },
    );
  }
  Widget WidgetRunningOrder() {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Consumer<RunningOrdersViewModel>(
      builder: (context, viewModel, child) {
        switch (viewModel.runningOrdersData.status) {
          case Status.LOADING:
            return  Container(height: screenHeight,
                color: AppColors.containerBackground(context),
                child: Center(child: Container(height: 15, width: 50, child: LoadingAnimationWidget.progressiveDots(color: AppColors.button(context), size: 45))));
          case Status.ERROR:
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 60,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Error loading orders',
                    style: AppTextStyles.textSize16(context),
                  ),
                  SizedBox(height: 8),
                  Text(
                    viewModel.runningOrdersData.message.toString(),
                    style: AppTextStyles.textSize12(
                      context,
                      color: AppColors.subtitle(context),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      viewModel.fetchRunningOrdersGetDataApi();
                    },
                    child: Text('Retry'),
                  ),
                ],
              ),
            );

          case Status.COMPLETED:
            final orderData = viewModel.runningOrdersData.data;

            if (orderData == null ||
                orderData.data == null ||
                orderData.data!.data == null ||
                orderData.data!.data!.isEmpty) {
              // ✅ IMPORTANT: Wrap empty state with ListView to enable pull-to-refresh
              return ListView(
                physics: AlwaysScrollableScrollPhysics(),
                children: [
                  Container(
                    height: MediaQuery.of(context).size.height * 0.6,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            FontAwesomeIcons.boxOpen,
                            color: AppColors.subtitle(context),
                            size: 50,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No Running Orders',
                            style: AppTextStyles.textSize16(context),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'You don\'t have any running orders at the moment',
                            style: AppTextStyles.textSize12(
                              context,
                              color: AppColors.subtitle(context),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                await viewModel.fetchRunningOrdersGetDataApi();
              },
              child: ListView.builder(
                itemCount: orderData.data!.data!.length,
                itemBuilder: (context, index) {
                  final datum = orderData.data!.data![index];
                  return _buildOrderCard(datum, screenWidth, screenHeight, isRunningTab: true);
                },
              ),
            );

          default:
            return Container();
        }
      },
    );
  }

  Widget WidgetCompletedOrder() {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Consumer<CompleteOrdersViewModel>(
      builder: (context, viewModel, child) {
        switch (viewModel.completeOrdersData.status) {
          case Status.LOADING:
            return  Container(height: screenHeight,
                color: AppColors.containerBackground(context),
                child: Center(child: Container(height: 15, width: 50, child: LoadingAnimationWidget.progressiveDots(color: AppColors.button(context), size: 45))));


          case Status.ERROR:
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 60,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Error loading orders',
                    style: AppTextStyles.textSize16(context),
                  ),
                  SizedBox(height: 8),
                  Text(
                    viewModel.completeOrdersData.message.toString(),
                    style: AppTextStyles.textSize12(
                      context,
                      color: AppColors.subtitle(context),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      viewModel.fetchCompleteOrdersGetDataApi();
                    },
                    child: Text('Retry'),
                  ),
                ],
              ),
            );

          case Status.COMPLETED:
            final orderData = viewModel.completeOrdersData.data;

            if (orderData == null ||
                orderData.data == null ||
                orderData.data!.data == null ||
                orderData.data!.data!.isEmpty) {
              // ✅ IMPORTANT: Wrap empty state with ListView to enable pull-to-refresh
              return ListView(
                physics: AlwaysScrollableScrollPhysics(),
                children: [
                  Container(
                    height: MediaQuery.of(context).size.height * 0.6,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            FontAwesomeIcons.checkCircle,
                            color: AppColors.subtitle(context),
                            size: 50,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No Completed Orders',
                            style: AppTextStyles.textSize16(context),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'You don\'t have any completed orders yet',
                            style: AppTextStyles.textSize12(
                              context,
                              color: AppColors.subtitle(context),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                await viewModel.fetchCompleteOrdersGetDataApi();
              },
              child: ListView.builder(
                itemCount: orderData.data!.data!.length,
                itemBuilder: (context, index) {
                  final datum = orderData.data!.data![index];
                  return _buildOrderCard(datum, screenWidth, screenHeight);
                },
              ),
            );

          default:
            return Container();
        }
      },
    );
  }

  Widget _buildOrderCard(
      Datum datum,
      double screenWidth,
      double screenHeight, {
        bool isPendingTab = false,
        bool isRunningTab = false,
      }) {

    final order = datum.order;
    final retailer = datum.retailer;

    return Container(
      margin: EdgeInsets.only(bottom: screenHeight * 0.02),
      decoration: BoxDecoration(
        color: AppColors.containerBackground(context),
        borderRadius: BorderRadius.circular(8),
      ),
      child: GestureDetector(
        onTap: () {
          if (isPendingTab) {
            Navigator.pushNamed(
              context,
              RoutesName.pendingOrdersViewDetailsSocketscreen,
              arguments: {'orderId': order?.id ?? ''},
            );
          } else if (isRunningTab) {
            Navigator.pushNamed(
              context,
              RoutesName.runningOrdersViewDetailsSocketscreen,
              arguments: {'orderId': order?.id ?? ''},
            );
          } else {
            Navigator.pushNamed(
              context,
              RoutesName.completeOrdersDetailsScreen,
              arguments: {'orderId': order?.id ?? ''},
            );
          }
        },
        child: Container(
          padding: EdgeInsets.all(screenHeight * 0.02),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(width: 1, color: AppColors.border(context)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.textPrimary(context),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      FontAwesomeIcons.store,
                      color: AppColors.containerBackground(context),
                      size: 16,
                    ),
                  ),
                  SizedboxSpaccing.width03(context),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Order #${order?.id?.substring(order!.id!.length - 6) ?? 'N/A'}",
                        style: AppTextStyles.textSize14(
                          context,
                          weight: FontWeight.w400,
                          color: AppColors.textPrimary(context),
                        ),
                      ),
                      Text(
                        retailer?.businessName ?? 'Unknown Store',
                        style: AppTextStyles.textSize12(
                          context,
                          color: AppColors.subtitle(context),
                          weight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "৳${order?.budget ?? 0}",
                    style: AppTextStyles.textSize14(
                      context,
                      weight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    order?.status ?? 'Unknown',
                    style: AppTextStyles.textSize10(
                      context,
                      color: AppColors.textPrimary(context),
                      weight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return AppColors.darkRedColor; // Yellow
      case 'RUNNING':
        return AppColors.button(context); // Blue
      case 'COMPLETED':
        return AppColors.oceanGreenColor; // Green
      case 'CANCELLED':
        return Color(0xFFDC2626); // Red
      default:
        return Color(0xFF6B7280); // Gray
    }
  }
}