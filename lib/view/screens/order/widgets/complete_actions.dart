import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:dinmajur_customer/model/order_models/get_all_order_model.dart';
import 'package:dinmajur_customer/view/screens/order/widgets/write_review_sheet.dart';
import 'package:flutter/material.dart';

class CompletedActions extends StatelessWidget {
  final Datum datum;
  final Future<void> Function(BuildContext context, Datum datum) onPayNow;

  const CompletedActions({
    super.key,
    required this.datum,
    required this.onPayNow,
  });

  String get _bookingId {
    switch (datum.type) {
      case 'ORDER':         return datum.orderId ?? '';
      case 'HOUSEKEEPER':   return datum.houseKeeperBookingId ?? '';
      case 'BEAUTY_SALON':  return datum.beautySalonBookingId ?? '';
      case 'EVENT_COOKING': return datum.eventCookingBookingId ?? '';
      default:              return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool showPayNow = datum.paymentStatus == null;
    final bool isReview = datum.isReview == false;

    return Row(
      children: [
        if (showPayNow) ...[
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
          const SizedBox(width: 15),
        ],

               if (isReview) ...[ // Write Review
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
        ), ],
      ],
    );
  }
}