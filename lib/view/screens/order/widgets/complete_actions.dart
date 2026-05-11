import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:dinmajur_customer/model/order_models/get_all_order_model.dart';
import 'package:dinmajur_customer/view/screens/order/widgets/write_review_sheet.dart';
import 'package:flutter/material.dart';

class CompletedActions extends StatelessWidget {
  final Datum datum;
  final Future<void> Function(BuildContext context, Datum datum) onPayNow;
  final bool isRunningTab;


  const CompletedActions({
    super.key,
    required this.datum,
    required this.onPayNow,
    this.isRunningTab = false,
  });

  String get _bookingId {
    switch (datum.type) {
      case 'ORDER':         return datum.freelancerId ?? '';
      case 'HOUSEKEEPER':   return datum.houseKeeperBookingId ?? '';
      case 'BEAUTY_SALON':  return datum.beautySalonBookingId ?? '';
      case 'EVENT_COOKING': return datum.eventCookingBookingId ?? '';
      case 'SERVICES':       return datum.servicesBookingId ?? '';
      default:              return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool showPayNow = datum.paymentStatus == null || datum.paymentStatus!.isEmpty || datum.paymentStatus!="PAID";
    final bool showReview = datum.isReview == false ;


    final bool shouldShowPayNow = isRunningTab && showPayNow;
    final bool shouldShowReview = !isRunningTab && showReview;


    return Row(
      children: [
        if (shouldShowPayNow)
          Expanded(
            child: GestureDetector(
              onTap: () => onPayNow(context, datum),
              child: Container(
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.textPrimary(context),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    "Pay Now",
                    style: AppTextStyles.textSize14(
                      context,
                      weight: FontWeight.w600,
                      color: AppColors.textSecondary(context),
                    ),
                  ),
                ),
              ),
            ),
          ),

        if (shouldShowReview)
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
                  child: Text(
                    "Write Review",
                    style: AppTextStyles.textSize14(context, weight: FontWeight.w500),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}