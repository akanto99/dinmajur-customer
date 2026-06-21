import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/sizedbox_spaccing.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:dinmajur_customer/configs/utils/routes/routes_name.dart';
import 'package:dinmajur_customer/configs/widgets/datetime_formatter.dart';
import 'package:dinmajur_customer/model/order_models/get_all_order_model.dart';
import 'package:dinmajur_customer/view/screens/order/widgets/assigned_freelancer_section.dart';
import 'package:dinmajur_customer/view/screens/order/widgets/complete_actions.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class OrderCard extends StatelessWidget {
  final Datum datum;
  final bool isPendingTab;
  final bool isRunningTab;
  final bool isCompletedTab;
  final Future<void> Function(BuildContext context, Datum datum) onPayNow;

  const OrderCard({super.key, required this.datum, required this.onPayNow, this.isPendingTab = false, this.isRunningTab = false, this.isCompletedTab = false});

  // ─── Order type helpers ─────────────────────────────────────────────────────
  String get _orderType {
    switch (datum.type) {
      case 'BEAUTY_SALON':
        return 'Premium Beauty Salon';
      case 'HOUSEKEEPER':
        return 'Premium House Keeper';
      case 'ORDER':
        return 'Grocery Order';
      case 'EVENT_COOKING':
        return 'Family Event Cooking';
      case 'SERVICES':
        return datum.categoryType ?? 'N/A';
      default:
        return '';
    }
  }

  String get _displayOrderId {
    switch (datum.type) {
      case 'BEAUTY_SALON':
        return datum.beautySalonBookingId ?? 'N/A';
      case 'HOUSEKEEPER':
        return datum.houseKeeperBookingId ?? 'N/A';
      case 'ORDER':
        return datum.orderId ?? 'N/A';
      case 'EVENT_COOKING':
        return datum.eventCookingBookingId ?? 'N/A';
      case 'SERVICES':
        return datum.servicesBookingId ?? 'N/A';
      default:
        return 'N/A';
    }
  }

  String get _orderIdForNavigation {
    switch (datum.type) {
      case 'BEAUTY_SALON':
        return datum.beautySalonBookingId ?? '';
      case 'HOUSEKEEPER':
        return datum.houseKeeperBookingId ?? '';
      case 'ORDER':
        return datum.orderId ?? '';
      case 'EVENT_COOKING':
        return datum.eventCookingBookingId ?? '';
      case 'SERVICES':
        return datum.servicesBookingId ?? '';
      default:
        return '';
    }
  }

  String get _shortOrderId {
    final id = _displayOrderId;
    return id.length > 6 ? id.substring(id.length - 6) : id;
  }

  String _formatTotal(num? total) {
    if (total == null) return '0';
    return total % 1 == 0 ? total.toInt().toString() : total.toStringAsFixed(2);
  }

  IconData _iconForType(String? type) {
    switch (type) {
      case 'BEAUTY_SALON':
        return FontAwesomeIcons.scissors;
      case 'HOUSEKEEPER':
        return FontAwesomeIcons.broom;
      case 'EVENT_COOKING':
        return FontAwesomeIcons.bowlRice;
      case 'ORDER':
        return FontAwesomeIcons.store;
      case 'SERVICES':
        return FontAwesomeIcons.clipboardList;
      default:
        return FontAwesomeIcons.fileInvoice;
    }
  }

  Color _statusColor(BuildContext context, String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return AppColors.darkRedColor;
      case 'RUNNING':
        return AppColors.button(context);
      case 'COMPLETED':
        return AppColors.oceanGreenColor;
      case 'CANCELLED':
        return const Color(0xFFDC2626);
      default:
        return const Color(0xFF6B7280);
    }
  }

  void _onTap(BuildContext context) {
    if (datum.type == 'ORDER') {
      if (isPendingTab || isRunningTab) {
        Navigator.pushNamed(context, RoutesName.trackOrderViewdetailsSocketScreen, arguments: {'orderId': _orderIdForNavigation, 'fromCheckout': false});
      } else {
        Navigator.pushNamed(context, RoutesName.completeOrdersDetailsScreen, arguments: {'orderId': _orderIdForNavigation});
      }
    } else if (datum.type == 'HOUSEKEEPER') {
      Navigator.pushNamed(context, RoutesName.confirmedScreen, arguments: {'trackingId': _orderIdForNavigation});
    } else if (datum.type == 'BEAUTY_SALON') {
      Navigator.pushNamed(context, RoutesName.beautyConfirmedScreen, arguments: {'trackingId': _orderIdForNavigation});
    } else if (datum.type == 'EVENT_COOKING') {
      Navigator.pushNamed(context, RoutesName.cookingConfirmedScreen, arguments: {'trackingId': _orderIdForNavigation});
    } else if (datum.type == 'SERVICES') {
      Navigator.pushNamed(context, RoutesName.serviceConfirmedScreen, arguments: {'trackingId': _orderIdForNavigation});
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final bool hasFreelancer = datum.freelancer != null;
    final bool showFreelancer = hasFreelancer && (isRunningTab || isCompletedTab);

    // Payment status badge
    final String? payStatus = datum.paymentStatus;

    return Container(
      margin: EdgeInsets.only(bottom: screenHeight * 0.02),
      decoration: BoxDecoration(
        color: AppColors.containerBackground(context),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(width: 1, color: AppColors.border(context)),
      ),
      child: GestureDetector(
        onTap: () => _onTap(context),
        child: Container(
          padding: EdgeInsets.all(screenHeight * 0.02),
          color: Colors.transparent,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ────────────────────────────────────────────────────
              _buildHeader(context),

              // ── Freelancer ────────────────────────────────────────────────
              if (showFreelancer) ...[SizedboxSpaccing.height015(context), AssignedFreelancerSection(datum: datum, showActions: !isCompletedTab)],

              SizedboxSpaccing.height015(context),
              Divider(height: 1, color: AppColors.border(context)),
              // Text(
              //   "$payStatus   ${datum.type}   ${datum.subTotalAmount},",
              //   style: AppTextStyles.textSize10(context, weight: FontWeight.w600),
              // ),
              // Text(
              //   "isReview: ${datum.isReview} | type: ${datum.isReview.runtimeType}",
              //   style: AppTextStyles.textSize10(context, weight: FontWeight.w600),
              // ),

              // ── Footer ────────────────────────────────────────────────────
              _buildFooter(context, screenHeight),

              /// ── Completed actions ─────────────────────────────────────────
              // if (isRunningTab &&
              //     (datum.paymentStatus == null
              //         || datum.paymentStatus!.isEmpty|| datum.paymentStatus!="PAID") &&
              //     (datum.type != 'ORDER' || (datum.subTotalAmount ?? 0) > 0)) ...[
              //   SizedboxSpaccing.height015(context),
              //   Divider(height: 1, color: AppColors.border(context)),
              //   SizedboxSpaccing.height02(context),
              //   CompletedActions(datum: datum, onPayNow: onPayNow, isRunningTab: true),
              // ] else
              ///Completed action as Play store
              //   if (isCompletedTab && datum.isReview == false) ...[
              //   SizedboxSpaccing.height015(context),
              //   Divider(height: 1, color: AppColors.border(context)),
              //   SizedboxSpaccing.height02(context),
              //   CompletedActions(datum: datum, onPayNow: onPayNow, isRunningTab: false),
              // ],
              // ── Completed actions ─────────────────────────────────────────────
              if (isRunningTab &&
                  datum.isApproved == false &&
                  (datum.approvedExtraItemsCount ?? 0) > 0) ...[
                SizedboxSpaccing.height015(context),
                Divider(height: 1, color: AppColors.border(context)),
                SizedboxSpaccing.height02(context),
                CompletedActions(
                  datum: datum,
                  onPayNow: onPayNow,
                  isRunningTab: true,
                  onReviewAndApprove: (ctx) => _onTap(ctx), // ← navigates to view details
                ),
              ] else if (isCompletedTab && datum.isReview == false) ...[
                SizedboxSpaccing.height015(context),
                Divider(height: 1, color: AppColors.border(context)),
                SizedboxSpaccing.height02(context),
                CompletedActions(datum: datum, onPayNow: onPayNow, isRunningTab: false),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(color: AppColors.hintColor(context).withOpacity(0.5), borderRadius: BorderRadius.circular(8)),
                child: Icon(_iconForType(datum.type), color: AppColors.textPrimary(context), size: 16),
              ),
              SizedboxSpaccing.width03(context),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _orderType,
                      style: AppTextStyles.textSize16(context, weight: FontWeight.w500, color: AppColors.textPrimary(context)),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      "Order #$_shortOrderId",
                      style: AppTextStyles.textSize12(context, weight: FontWeight.w400, color: AppColors.subtitle(context)),
                    ),
                    if (datum.createdAt != null)
                      Text(
                        DateTimeFormatter.formatRelativeDateTime(datum.createdAt!),
                        style: AppTextStyles.textSize12(context, color: AppColors.subtitle(context), weight: FontWeight.w400),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark ? Colors.white.withOpacity(0.9) : _statusColor(context, datum.status ?? '').withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            datum.status ?? 'Unknown',
            style: AppTextStyles.textSize10(context, color: _statusColor(context, datum.status ?? ''), weight: FontWeight.w500),
          ),
        ),
      ],
    );
  }

  Widget _buildFooter(BuildContext context, double screenHeight) {
    // For ORDER: show subtotal only if > 0; for all others: always show total
    final bool isOrder = datum.type == 'ORDER';
    final bool orderHasSubtotal = isOrder && (datum.subTotalAmount != null && datum.subTotalAmount! > 0);
    final bool showAmount = !isOrder || orderHasSubtotal;
    final String amountText = isOrder ? "৳ ${_formatTotal(datum.totalAmount)}" : "৳ ${_formatTotal(datum.total)}";

    return Container(
      height: screenHeight * 0.04,
      color: Colors.transparent,
      alignment: Alignment.bottomCenter,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (showAmount)
            Text(
              amountText,
              style: AppTextStyles.textSize14(context, weight: FontWeight.w500, color: AppColors.textPrimary(context)),
            )
          else
            const SizedBox.shrink(),

          Row(
            children: [
              Text(
                "View Details ",
                style: AppTextStyles.textSize14(context, weight: FontWeight.w400, color: AppColors.textPrimary(context)),
              ),
              SizedboxSpaccing.width01(context),
              const Icon(FontAwesomeIcons.arrowRight, size: 15),
            ],
          ),
        ],
      ),
    );
  }
}
