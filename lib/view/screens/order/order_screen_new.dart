import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/components/header_appbar.dart';
import 'package:dinmajur_customer/configs/res/sizedbox_spaccing.dart';
import 'package:dinmajur_customer/configs/responsive/responsive_ui.dart';
import 'package:dinmajur_customer/configs/services/ssl_payment_service/ssl_payment.dart';
import 'package:dinmajur_customer/configs/utils/utils.dart';
import 'package:dinmajur_customer/model/order_models/get_all_order_model.dart';
import 'package:dinmajur_customer/view/navigation_bar.dart';
import 'package:dinmajur_customer/view/screens/order/tabs/order_list_tab.dart';
import 'package:dinmajur_customer/view/screens/order/widgets/order_tab_bar.dart';
import 'package:dinmajur_customer/view_model/order_view_models/running_orders_view_model.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  int _selectedTabIndex = 0;

  RunningOrdersViewModel get _orderViewModel =>
      Provider.of<RunningOrdersViewModel>(context, listen: false);

  @override
  void initState() {
    super.initState();
    _orderViewModel.clearAllDataSilent();
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchCurrentTab());
  }

  void _onTabChanged(int index) {
    setState(() => _selectedTabIndex = index);
    switch (index) {
      case 0:
        _orderViewModel.resetPendingOrders();
        _orderViewModel.fetchPendingOrdersGetDataApi();
        break;
      case 1:
        _orderViewModel.resetRunningOrders();
        _orderViewModel.fetchRunningOrdersGetDataApi();
        break;
      case 2:
        _orderViewModel.resetCompleteOrders();
        _orderViewModel.fetchCompleteOrdersGetDataApi();
        break;
    }
  }

  void _fetchCurrentTab() {
    switch (_selectedTabIndex) {
      case 0: _orderViewModel.fetchPendingOrdersGetDataApi(); break;
      case 1: _orderViewModel.fetchRunningOrdersGetDataApi(); break;
      case 2: _orderViewModel.fetchCompleteOrdersGetDataApi(); break;
    }
  }

  Future<void> _handleRefresh() async {
    try {
      switch (_selectedTabIndex) {
        case 0: await _orderViewModel.fetchPendingOrdersGetDataApi(isRefresh: true); break;
        case 1: await _orderViewModel.fetchRunningOrdersGetDataApi(isRefresh: true); break;
        case 2: await _orderViewModel.fetchCompleteOrdersGetDataApi(isRefresh: true); break;
      }
    } catch (_) {
      if (mounted) Utils.flushBarErrorMessage("Refresh failed", context);
    }
  }

  Future<void> _handlePayNow(BuildContext context, Datum datum) async {
    String trackingId = '';
    String productCategory = '';

    switch (datum.type) {
      case 'ORDER':
        trackingId = datum.orderId ?? '';
        productCategory = 'Grocery Order';
        break;
      case 'HOUSEKEEPER':
        trackingId = datum.houseKeeperBookingId ?? '';
        productCategory = 'House Keeper';
        break;
      case 'BEAUTY_SALON':
        trackingId = datum.beautySalonBookingId ?? '';
        productCategory = 'Beauty Salon';
        break;
      case 'EVENT_COOKING':
        trackingId = datum.eventCookingBookingId ?? '';
        productCategory = 'Event Cooking';
        break;
      case 'SERVICES':
        trackingId = datum.servicesBookingId ?? '';
        productCategory = datum.categoryType ?? '';
        break;
    }

    if (trackingId.isEmpty) {
      Utils.flushBarErrorMessage("Invalid order ID", context);
      return;
    }

    try {
      final result = await SSLCommerzPaymentService().initiatePayment(
        trackingId: trackingId,
        totalAmount: (datum.total ?? 0).toDouble(),
        productCategory: productCategory,
        customerName: datum.customer?.fullName,
        customerPhone: datum.customer?.phone,
        customerEmail: '',
        customerAddress: datum.fullAddress ?? '',
      );

      if (result.success) {
        Utils.flushBarSuccessMessage("Payment successful!", context);
        _orderViewModel.refreshSingleOrder(trackingId);

      } else if (result.status == 'CANCELLED') {
        Utils.flushBarErrorMessage("Payment cancelled", context);
      } else {
        Utils.flushBarErrorMessage(result.errorMessage ?? "Payment failed", context);
      }
    } catch (e) {
      Utils.flushBarErrorMessage("Payment error: $e", context);
    }
  }

  // ─── Build ──────────────────────────────────────────────────────────────────
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

    return Column(
      children: [
        GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => NavigationScreen(initialIndex: 0)),
          ),
          child: AppBarHeader("Orders"),
        ),
        OrderTabBar(
          selectedIndex: _selectedTabIndex,
          onTabChanged: _onTabChanged,
        ),
        SizedboxSpaccing.height015(context),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _handleRefresh,
            color: AppColors.textPrimary(context),
            backgroundColor: AppColors.containerBackground(context),
            displacement: 40,
            strokeWidth: 2.0,
            child: Container(
              width: screenWidth * 0.9,
              child: _buildCurrentTab(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCurrentTab() {
    return Consumer<RunningOrdersViewModel>(
      builder: (context, orderViewModel, _) {
        switch (_selectedTabIndex) {
          case 0:
            return OrderListTab(
              apiResponse: orderViewModel.pendingOrdersData,
              orders: orderViewModel.pendingAllOrders,
              currentPage: orderViewModel.pendingCurrentPage,
              hasMore: orderViewModel.pendingHasMore,
              loadingMore: orderViewModel.pendingLoadingMore,
              isPendingTab: true,
              emptyTitle: 'No Pending Orders',
              emptySubtitle: 'You don\'t have any pending orders at the moment',
              emptyIcon: FontAwesomeIcons.boxOpen,
              onRetry: () {
                orderViewModel.resetPendingOrders();
                orderViewModel.fetchPendingOrdersGetDataApi();
              },
              onLoadMore: orderViewModel.loadMorePendingOrders,
              onPayNow: _handlePayNow,
            );
          case 1:
            return OrderListTab(
              apiResponse: orderViewModel.runningOrdersData,
              orders: orderViewModel.runningAllOrders,
              currentPage: orderViewModel.runningCurrentPage,
              hasMore: orderViewModel.runningHasMore,
              loadingMore: orderViewModel.runningLoadingMore,
              isRunningTab: true,
              emptyTitle: 'No Running Orders',
              emptySubtitle: 'You don\'t have any running orders at the moment',
              emptyIcon: FontAwesomeIcons.boxOpen,
              onRetry: () {
                orderViewModel.resetRunningOrders();
                orderViewModel.fetchRunningOrdersGetDataApi();
              },
              onLoadMore: orderViewModel.loadMoreRunningOrders,
              onPayNow: _handlePayNow,
            );
          case 2:
            return OrderListTab(
              apiResponse: orderViewModel.completeOrdersData,
              orders: orderViewModel.completeAllOrders,
              currentPage: orderViewModel.completeCurrentPage,
              hasMore: orderViewModel.completeHasMore,
              loadingMore: orderViewModel.completeLoadingMore,
              isCompletedTab: true,
              emptyTitle: 'No Completed Orders',
              emptySubtitle: 'You don\'t have any completed orders yet',
              emptyIcon: FontAwesomeIcons.checkCircle,
              onRetry: () {
                orderViewModel.resetCompleteOrders();
                orderViewModel.fetchCompleteOrdersGetDataApi();
              },
              onLoadMore: orderViewModel.loadMoreCompleteOrders,
              onPayNow: _handlePayNow,
            );
          default:
            return const SizedBox.shrink();
        }
      },
    );
  }
}