import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/components/exception_errorstate/exception_errorstate.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:dinmajur_customer/data/response/api_response.dart';
import 'package:dinmajur_customer/data/response/status.dart';
import 'package:dinmajur_customer/model/order_models/get_all_order_model.dart';
import 'package:dinmajur_customer/view/screens/order/widgets/order_card.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class OrderListTab extends StatelessWidget {
  final ApiResponse<GetAllOrderModel> apiResponse;
  final List<Datum> orders;
  final int currentPage;
  final bool hasMore;
  final bool loadingMore;
  final bool isPendingTab;
  final bool isRunningTab;
  final bool isCompletedTab;
  final String emptyTitle;
  final String emptySubtitle;
  final IconData emptyIcon;
  final VoidCallback onRetry;
  final VoidCallback onLoadMore;
  final Future<void> Function(BuildContext context, Datum datum) onPayNow;

  const OrderListTab({
    super.key,
    required this.apiResponse,
    required this.orders,
    required this.currentPage,
    required this.hasMore,
    required this.loadingMore,
    required this.emptyTitle,
    required this.emptySubtitle,
    required this.emptyIcon,
    required this.onRetry,
    required this.onLoadMore,
    required this.onPayNow,
    this.isPendingTab = false,
    this.isRunningTab = false,
    this.isCompletedTab = false,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    // Full screen loading — only on first page
    if (apiResponse.status == Status.LOADING && currentPage == 1) {
      return _buildFullLoader(context, screenHeight);
    }

    // Error state
    if (apiResponse.status == Status.ERROR) {
      return Container(
        height: screenHeight,
        child: ErrorStateWidget(errorMessage: apiResponse.message.toString(), onRetry: onRetry),
      );
    }

    // Empty state
    if (orders.isEmpty) {
      return _buildEmptyState(context);
    }

    // Orders list
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: orders.length + (hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index < orders.length) {
          return OrderCard(datum: orders[index], onPayNow: onPayNow, isPendingTab: isPendingTab, isRunningTab: isRunningTab, isCompletedTab: isCompletedTab);
        }
        // Load more button
        return _buildLoadMoreButton(context);
      },
    );
  }

  Widget _buildFullLoader(BuildContext context, double screenHeight) {
    return Container(
      height: screenHeight,
      color: AppColors.containerBackground(context),
      child: Center(child: LoadingAnimationWidget.progressiveDots(color: AppColors.button(context), size: 45)),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        Container(
          height: MediaQuery.of(context).size.height * 0.6,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(emptyIcon, color: AppColors.subtitle(context), size: 50),
                const SizedBox(height: 16),
                Text(emptyTitle, style: AppTextStyles.textSize16(context)),
                const SizedBox(height: 8),
                Text(
                  emptySubtitle,
                  style: AppTextStyles.textSize12(context, color: AppColors.subtitle(context)),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadMoreButton(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: GestureDetector(
          onTap: loadingMore ? null : onLoadMore,
          child: Container(
            height: 50,
            width: screenWidth * 0.8,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(width: 1, color: AppColors.border(context)),
              color: AppColors.containerBackground(context),
            ),
            child: Center(
              child: loadingMore
                  ? LoadingAnimationWidget.progressiveDots(color: AppColors.button(context), size: 40)
                  : Text("Load More", style: AppTextStyles.textSize16(context, weight: FontWeight.w500)),
            ),
          ),
        ),
      ),
    );
  }
}
