import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/sizedbox_spaccing.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:dinmajur_customer/configs/utils/routes/routes_name.dart';
import 'package:dinmajur_customer/socket_connection_model/screens_sockets/home_sceens_socket/get_all_orders_socket/socket_get_all_order_retailer.dart';
import 'package:dinmajur_customer/socket_connection_model/socket_provider_services/socket_provider.dart';
import 'package:dinmajur_customer/view/screens/home/socket_get_all_order_screen/socket_getall_order/order_widget.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';

import '../../../../../model/home_models/socket_home_model/socket_get_all_orders_model/socket_get_allorders_model.dart' as SocketOrder;



class SocketGetallOrderSection extends StatelessWidget {
  final VoidCallback? onSeeAll;

  const SocketGetallOrderSection({Key? key, this.onSeeAll}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Consumer<OrderSocketProvider>(
      builder: (context, orderGetAllSocket, _) {
        // Show loading state
        if (orderGetAllSocket.isLoadingOrders) {
          return _buildLoadingState(context, screenWidth);
        }

        // Show error state
        if (orderGetAllSocket.ordersError != null) {
          return _buildErrorState(context, screenWidth, orderGetAllSocket.ordersError!);
        }

        final orders = orderGetAllSocket.retailerOrders;
        final orderCount = orders.length;

        // Show empty state
        if (orderCount == 0) {
          return _buildEmptyState(context, screenWidth);
        }

        // Show tasks list
        final ordersToShow = orderGetAllSocket.getRecentOrders(count: 3);
        return _buildTasksList(context, ordersToShow, orderCount, screenHeight, screenWidth);
      },
    );
  }

  // ==================== LOADING STATE ====================
  Widget _buildLoadingState(BuildContext context, double screenWidth) {
    return Container(
      width: screenWidth * 0.9,
      child: Column(
        children: [
          _buildSectionHeader(context, 'Customer Order', '(0)', null),
          SizedboxSpaccing.height02(context),
          Container(
            width: double.infinity,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.textFieldFill(context),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(width: 1, color: AppColors.border(context)),
            ),
            child: Center(child: LoadingAnimationWidget.progressiveDots(color: AppColors.button(context), size: 45)),
          ),
        ],
      ),
    );
  }

  // ==================== ERROR STATE ====================
  Widget _buildErrorState(BuildContext context, double screenWidth, String error) {
    return Container(
      width: screenWidth * 0.9,
      child: Column(
        children: [
          _buildSectionHeader(context, 'Customer Order', '(0)', () => _retryOrderSocket(context)),
          SizedboxSpaccing.height02(context),
          Container(
            width: double.infinity,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.textFieldFill(context),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(width: 1, color: AppColors.border(context)),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    error,
                    style: AppTextStyles.textSize14(context, color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  TextButton(onPressed: () => _retryOrderSocket(context), child: Text('Retry')),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== EMPTY STATE ====================
  Widget _buildEmptyState(BuildContext context, double screenWidth) {
    return Container(
      width: screenWidth * 0.9,
      child: Column(
        children: [
          _buildSectionHeader(context, 'Customer Order', '(0)', null),
          SizedboxSpaccing.height02(context),
          Container(
            width: double.infinity,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.textFieldFill(context),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(width: 1, color: AppColors.border(context)),
            ),
            child: Center(
              child: Text(
                'No Oders Yet',
                style: AppTextStyles.textSize18(context, weight: FontWeight.w500, color: AppColors.form_hover(context)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== Order LIST ====================
  Widget _buildTasksList(BuildContext context, List<SocketOrder.Datum> orderToShow, int orderCount, double screenHeight, double screenWidth) {
    return Container(
      width: screenWidth * 0.9,
      child: Column(
        children: [
          _buildSectionHeader(context, 'Available Task', '($orderCount)', onSeeAll),
          SizedboxSpaccing.height02(context),
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: orderToShow.length,
            itemBuilder: (context, index) {
              final order = orderToShow[index];
              final isLastItem = index == orderToShow.length - 1;

              return Padding(
                padding: EdgeInsets.only(bottom: isLastItem ? 0 : screenHeight * 0.02),
                child: SocketOrderCard(
                  order: order,
                  onViewDetails: () {
                    // Print the order ID
                    print('Order ID being passed: ${order.order?.id}');

                    // Navigate with order ID
                    Navigator.pushNamed(
                      context,
                      RoutesName.orderDetailsSocketScreen,
                      arguments: {
                        'orderId': order.order?.id,
                      },
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ==================== SECTION HEADER ====================
  Widget _buildSectionHeader(BuildContext context, String title, String count, VoidCallback? onSeeAllTap) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('$title $count', style: AppTextStyles.textSize18(context, weight: FontWeight.w500)),
            if (onSeeAllTap != null)
              GestureDetector(
                onTap: onSeeAllTap,
                child: Text('See All', style: AppTextStyles.textSize12(context, weight: FontWeight.w500)),
              ),
          ],
        ),
        SizedboxSpaccing.height01(context),
        Divider(height: 1, color: AppColors.border(context)),
      ],
    );
  }

  // ==================== HELPER METHODS ====================
  void _retryOrderSocket(BuildContext context) {
    final socketProvider = Provider.of<SocketProvider>(context, listen: false);
    final orderGetAllSocket = Provider.of<OrderSocketProvider>(context, listen: false);

    // Reset retry count and error state
    orderGetAllSocket.resetRetryCount();

    // Reinitialize with retry logic
    orderGetAllSocket.initializeWithRetry(socketProvider);

    if (kDebugMode) {
      print('🔄 SocketAvailableTasksSection: Manual retry initiated');
    }
  }
}
