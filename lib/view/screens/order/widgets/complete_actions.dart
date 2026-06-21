import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:dinmajur_customer/model/order_models/get_all_order_model.dart';
import 'package:dinmajur_customer/view/screens/order/widgets/write_review_sheet.dart';
import 'package:flutter/material.dart';

class CompletedActions extends StatelessWidget {
  final Datum datum;
  final Future<void> Function(BuildContext context, Datum datum) onPayNow;
  final bool isRunningTab;
  final void Function(BuildContext context)? onReviewAndApprove; // ← new

  const CompletedActions({
    super.key,
    required this.datum,
    required this.onPayNow,
    this.isRunningTab = false,
    this.onReviewAndApprove, // ← new
  });

  String get _bookingId {
    switch (datum.type) {
      case 'ORDER':
        return datum.freelancerId ?? '';
      case 'HOUSEKEEPER':
        return datum.houseKeeperBookingId ?? '';
      case 'BEAUTY_SALON':
        return datum.beautySalonBookingId ?? '';
      case 'EVENT_COOKING':
        return datum.eventCookingBookingId ?? '';
      case 'SERVICES':
        return datum.servicesBookingId ?? '';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool shouldShowReviewAndApprove = isRunningTab && (datum.isApproved == false) && ((datum.approvedExtraItemsCount ?? 0) > 0);
    final bool shouldShowWriteReview = !isRunningTab && (datum.isReview == false);

    if (!shouldShowReviewAndApprove && !shouldShowWriteReview) return const SizedBox.shrink();

    return Row(
      children: [
        if (shouldShowReviewAndApprove)
          Expanded(
            child: GestureDetector(
              onTap: () => onReviewAndApprove?.call(context),
              child: Container(
                height: 42,
                decoration: BoxDecoration(color: AppColors.textPrimary(context), borderRadius: BorderRadius.circular(12)),
                child: Center(
                  child: Text(
                    "View & Approve",
                    style: AppTextStyles.textSize14(context, weight: FontWeight.w600, color: AppColors.textSecondary(context)),
                  ),
                ),
              ),
            ),
          ),
        if (shouldShowWriteReview)
          Expanded(
            child: GestureDetector(
              onTap: () => showWriteReviewSheet(context, datum, _bookingId),
              child: Container(
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.containerBackground(context),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border(context), width: 1),
                ),
                child: Center(
                  child: Text("Write Review", style: AppTextStyles.textSize14(context, weight: FontWeight.w500)),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
