import 'package:dinmajur_customer/configs/res/components/support_cards/customercare_support_card.dart';
import 'package:dinmajur_customer/configs/utils/amount_formatter/amount_formatter.dart';
// import 'package:dinmajur_customer/model/home_models/dropdown_categories_selection_models/premium_house_keeper_model/get_confirmedbooking_model.dart';
import 'package:flutter/material.dart';
import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/sizedbox_spaccing.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class ServiceItem {
  final String name;
  final String? additionalInfo;
  ServiceItem({required this.name, this.additionalInfo});
}

// ADD THIS
class ExtraItem {
  final String? id;
  final String? name;
  final num? price;
  final int? quantity;
  final num? total;
  final String? status;

  ExtraItem({this.id, this.name, this.price, this.quantity, this.total, this.status});
}

class BookingConfirmationData {
  final String thankYouMessage;
  final String orderId;
  final List<ServiceItem> services;
  final String dateTime;
  final String serviceAddress;
  final String grandTotal;
  final String paymentMethod;
  final Future<void> Function() onDownloadReceipt;
  final VoidCallback onTrackOrder;
  final bool isDownloading;

  final bool fromCheckout;
  final String? paymentStatus;
  final String? orderStatus;
  final Future<void> Function()? onPayNow;

  final List<ExtraItem> extraItems;
  final String? extraItemsStatus;
  final String? extraItemsPaymentStatus;
  final num? totalExtraAmount;
  final String? extraItemsTrackingId;

  final bool isApproveLoading;
  final bool isRejectLoading;
  final Future<void> Function()? onApprove;
  final Future<void> Function()? onReject;

  BookingConfirmationData({
    required this.thankYouMessage,
    required this.orderId,
    required this.services,
    required this.dateTime,
    required this.serviceAddress,
    required this.grandTotal,
    required this.paymentMethod,
    required this.onDownloadReceipt,
    required this.onTrackOrder,
    this.isDownloading = false,
    this.fromCheckout = false,
    this.paymentStatus,
    this.orderStatus,
    this.onPayNow,
    this.extraItems = const [],
    this.extraItemsStatus,
    this.extraItemsPaymentStatus,
    this.totalExtraAmount,
    this.extraItemsTrackingId,
    this.isApproveLoading = false,
    this.isRejectLoading = false,
    this.onApprove,
    this.onReject,
  });

  // ── Status getters ────────────────────────────────────────────────────────────
  bool get isApproved => extraItemsStatus?.toUpperCase() == 'APPROVED';
  bool get isRejected => extraItemsStatus?.toUpperCase() == 'REJECTED';
  bool get isPending => extraItemsStatus?.toUpperCase() == 'PENDING';

  bool get _mainPaid => paymentStatus?.toUpperCase() == 'PAID';
  bool get _mainUnpaid => !_mainPaid;
  bool get _extraPaid => extraItemsPaymentStatus?.toUpperCase() == 'PAID';
  bool get _extraUnpaid => !_extraPaid;

  String get _orderUpper => (orderStatus ?? '').toUpperCase();

  bool get _orderBlocked => _orderUpper == 'COMPLETED' || _orderUpper == 'PENDING' || _orderUpper == 'CANCELLED' || _orderUpper == 'CONFIRMED';

  // ── Visibility getters ────────────────────────────────────────────────────────
  bool get shouldShowExtraItems => extraItems.isNotEmpty && !(_orderUpper == 'COMPLETED' && isRejected);
  bool get shouldShowApprove => onApprove != null && isPending;
  bool get shouldShowReject => onReject != null && isPending;
  bool get shouldShowApprovedDisabled => isApproved && extraItems.isNotEmpty && _orderUpper != 'COMPLETED';
  bool get shouldShowCancelledExtra => isRejected && extraItems.isNotEmpty && _orderUpper != 'COMPLETED';

  bool get shouldShowPayNow {
    if (fromCheckout) return false;
    if (onPayNow == null) return false;
    if (_orderBlocked) return false;
    if (_mainPaid && _extraPaid) return false;
    if (_mainUnpaid) return true;
    if (_mainPaid && isApproved && _extraUnpaid) return true;
    return false;
  }

  String get payNowLabel {
    if (_mainPaid && isApproved && _extraUnpaid) {
      return 'Pay Extra Items  ৳${AmountFormatter.formatDynamic(totalExtraAmount ?? 0)}';
    }
    return 'Pay Now';
  }

  // ── Dynamic Header ────────────────────────────────────────────────────────────
  String get headerTitle {
    if (_orderUpper == 'RUNNING') {
      if (isPending && extraItems.isNotEmpty) return 'Service Updated';
      if (isApproved && _extraUnpaid) return 'Payment Required';
      return 'Service In Progress';
    }
    if (_orderUpper == 'COMPLETED') return 'Service Completed';
    if (_orderUpper == 'CANCELLED') return 'Booking Cancelled';
    return 'Booking Confirmed!';
  }

  String get headerSubtitle {
    if (_orderUpper == 'RUNNING') {
      if (isPending && extraItems.isNotEmpty) {
        return 'Added extra tasks during your appointment. Please review the new total and approve.';
      }
      if (isApproved && _extraUnpaid) {
        return 'Extra items approved. Please complete the payment to proceed.';
      }
      return 'Your service is currently in progress.';
    }
    if (_orderUpper == 'COMPLETED') {
      return 'Your service has been completed successfully. Thank you for choosing us!';
    }
    if (_orderUpper == 'CANCELLED') {
      return 'Your booking has been cancelled. Please contact support if you have questions.';
    }
    return thankYouMessage;
  }

  IconData get headerIcon {
    if (_orderUpper == 'RUNNING') {
      if (isPending && extraItems.isNotEmpty) return Icons.notifications_outlined;
      if (isApproved && _extraUnpaid) return Icons.payment_outlined;
      return Icons.wifi_protected_setup_sharp;
    }
    if (_orderUpper == 'COMPLETED') return Icons.check;
    if (_orderUpper == 'CANCELLED') return FontAwesomeIcons.x;
    return Icons.check;
  }

  Color headerIconColor(BuildContext context) {
    return AppColors.buttonTextColor(context);
  }

  Color headerBgColor(BuildContext context) {
    if (isPending && extraItems.isNotEmpty) return const Color(0xFFFFF1DC).withOpacity(0.25);
    return Colors.transparent;
  }
}

class BookingConfirmationUI extends StatelessWidget {
  final BookingConfirmationData data;
  final VoidCallback onBackToHome;

  const BookingConfirmationUI({Key? key, required this.data, required this.onBackToHome}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return SingleChildScrollView(
      child: Column(
        children: [
          SizedboxSpaccing.height02(context),

          // ── Dynamic Header ──────────────────────────────────────────────────
          _buildHeader(context, screenWidth, screenHeight),
          SizedboxSpaccing.height03(context),

          // ── Booking Details ─────────────────────────────────────────────────
          _buildSectionTitle(context, screenWidth, 'Booking Details'),
          SizedboxSpaccing.height01(context),
          _buildBookingDetailsCard(context, screenWidth, screenHeight),

          // ── Extra Items ─────────────────────────────────────────────────────
          if (data.shouldShowExtraItems) ...[
            SizedboxSpaccing.height03(context),
            _buildSectionTitle(context, screenWidth, 'Extra Items'),
            SizedboxSpaccing.height01(context),
            _buildExtraItemsCard(context, screenWidth, screenHeight),
          ],

          SizedboxSpaccing.height03(context),

          // ── Approve / Reject Row ────────────────────────────────────────────
          if (data.shouldShowApprove || data.shouldShowReject) ...[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
              child: Row(
                children: [
                  if (data.shouldShowApprove) Expanded(child: _buildApproveButton(context)),
                  if (data.shouldShowApprove && data.shouldShowReject) const SizedBox(width: 12),
                  if (data.shouldShowReject) Expanded(child: _buildRejectButton(context)),
                ],
              ),
            ),
            SizedboxSpaccing.height02(context),
          ],

          // ── Approved Disabled ───────────────────────────────────────────────
          if (data.shouldShowApprovedDisabled) ...[_buildApprovedDisabledButton(context, screenWidth), SizedboxSpaccing.height02(context)],

          // ── Cancelled Extra ─────────────────────────────────────────────────
          if (data.shouldShowCancelledExtra) ...[_buildCancelledExtraLabel(context, screenWidth), SizedboxSpaccing.height02(context)],

          // ── Pay Now ─────────────────────────────────────────────────────────
          if (data.shouldShowPayNow) ...[_buildPayNowButton(context, screenWidth), SizedboxSpaccing.height02(context)],

          _buildDownloadButton(context, screenWidth),
          SizedboxSpaccing.height03(context),

          // ── What's Next ─────────────────────────────────────────────────────
          _buildWhatsNextSection(context, screenWidth, screenHeight),
          SizedboxSpaccing.height03(context),

          CustomerCareSupportCard(),
          SizedboxSpaccing.height03(context),

          // ── Track Order ─────────────────────────────────────────────────────
          _buildTrackOrderButton(context, screenWidth),
          SizedboxSpaccing.height02(context),

          // ── Back to Home ────────────────────────────────────────────────────
          _buildBackToHomeButton(context, screenWidth),
          SizedboxSpaccing.height04(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, double screenWidth, double screenHeight) {
    final iconColor = data.headerIconColor(context);
    final bgColor = data.headerBgColor(context);

    return Container(
      width: screenWidth * 0.9,
      padding: EdgeInsets.all(screenHeight * 0.02),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(width: 1, color: AppColors.border(context)),
      ),
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(color: iconColor.withOpacity(0.15), shape: BoxShape.circle),
            child: Center(child: Icon(data.headerIcon, color: iconColor, size: 26)),
          ),
          SizedboxSpaccing.height01(context),
          Text(
            data.headerTitle,
            style: AppTextStyles.textSize18(context, weight: FontWeight.w600),
            textAlign: TextAlign.center,
          ),
          SizedboxSpaccing.height01(context),
          SizedBox(
            width: screenWidth * 0.85,
            child: Text(
              data.headerSubtitle,
              style: AppTextStyles.textSize14(context, color: AppColors.subtitle(context)),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, double screenWidth, String title) {
    return SizedBox(
      width: screenWidth * 0.9,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.textSize18(context, weight: FontWeight.w500)),
          SizedboxSpaccing.height01(context),
          Divider(height: 1, color: AppColors.border(context)),
        ],
      ),
    );
  }

  Widget _buildBookingDetailsCard(BuildContext context, double screenWidth, double screenHeight) {
    return Container(
      width: screenWidth * 0.9,
      padding: EdgeInsets.all(screenHeight * 0.02),
      decoration: BoxDecoration(
        color: AppColors.containerBackground(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailColumn('Order Number', '#${data.orderId.length > 6 ? data.orderId.substring(data.orderId.length - 6) : data.orderId}', context),
          const SizedBox(height: 16),
          _buildServicesSection(context),
          const SizedBox(height: 16),
          _buildDetailColumn('Date & Time', data.dateTime, context),
          const SizedBox(height: 16),
          _buildDetailColumn('Service Address', data.serviceAddress, context),
          const SizedBox(height: 16),
          _buildDetailRow('Total Payment', '৳ ${data.grandTotal}', context),
          const SizedBox(height: 16),
          _buildDetailRow('Payment Method', data.paymentMethod, context),
          const SizedBox(height: 16),
          _buildDetailRow('Payment Status', data.paymentStatus ?? '-', context),
          const SizedBox(height: 16),
          _buildDetailRow('Status', data.orderStatus ?? 'N/A', context),
          // if ((data.extraItemsPaymentStatus?.toUpperCase() == 'PAID') && (data.totalExtraAmount != null) && (data.totalExtraAmount! > 0)) ...[
          //   const SizedBox(height: 16),
          //   _buildDetailRow('Extra Amount', '৳ ${AmountFormatter.formatDynamic(data.totalExtraAmount!)}', context),
          // ],
        ],
      ),
    );
  }

  Widget _buildServicesSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Service',
          style: AppTextStyles.textSize14(context, color: AppColors.textPrimary(context), weight: FontWeight.w600),
        ),
        SizedboxSpaccing.height005(context),
        ...data.services.map(
          (s) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(s.additionalInfo != null ? '${s.name} ${s.additionalInfo}' : s.name, style: AppTextStyles.textSize14(context, weight: FontWeight.w400), softWrap: true),
          ),
        ),
      ],
    );
  }

  Widget _buildExtraItemsCard(BuildContext context, double screenWidth, double screenHeight) {
    return Container(
      width: screenWidth * 0.9,
      padding: EdgeInsets.all(screenHeight * 0.02),
      decoration: BoxDecoration(
        color: AppColors.containerBackground(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...data.extraItems.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(item.name ?? 'Extra', style: AppTextStyles.textSize14(context, weight: FontWeight.w400)),
                  ),
                  Text(
                    '৳ ${AmountFormatter.formatDynamic(item.price ?? 0)}',
                    style: AppTextStyles.textSize14(context, weight: FontWeight.w500, color: AppColors.textPrimary(context)),
                  ),
                ],
              ),
            ),
          ),
          Divider(height: 1, color: AppColors.border(context)),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total Extra', style: AppTextStyles.textSize14(context, weight: FontWeight.w600)),
              Text(
                '৳ ${_calcExtraTotal()}',
                style: AppTextStyles.textSize14(context, weight: FontWeight.w600, color: AppColors.textPrimary(context)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildApproveButton(BuildContext context) {
    return GestureDetector(
      onTap: data.isApproveLoading ? null : () async => await data.onApprove?.call(),
      child: Container(
        height: 50,
        decoration: BoxDecoration(color: AppColors.button(context), borderRadius: BorderRadius.circular(8)),
        child: data.isApproveLoading
            ? Center(child: LoadingAnimationWidget.progressiveDots(color: Colors.white, size: 40))
            : Center(
                child: Text(
                  'Approve',
                  style: AppTextStyles.textSize16(context, weight: FontWeight.w600, color: Colors.white),
                ),
              ),
      ),
    );
  }

  Widget _buildRejectButton(BuildContext context) {
    return GestureDetector(
      onTap: data.isRejectLoading ? null : () async => await data.onReject?.call(),
      child: Container(
        height: 50,
        decoration: BoxDecoration(color: Colors.red.shade600, borderRadius: BorderRadius.circular(8)),
        child: data.isRejectLoading
            ? Center(child: LoadingAnimationWidget.progressiveDots(color: Colors.white, size: 40))
            : Center(
                child: Text(
                  'Reject',
                  style: AppTextStyles.textSize16(context, weight: FontWeight.w600, color: Colors.white),
                ),
              ),
      ),
    );
  }

  Widget _buildApprovedDisabledButton(BuildContext context, double screenWidth) {
    return Container(
      width: screenWidth * 0.9,
      height: 50,
      decoration: BoxDecoration(color: AppColors.button(context).withOpacity(0.4), borderRadius: BorderRadius.circular(8)),
      child: Center(
        child: Text(
          'Approved ✓',
          style: AppTextStyles.textSize16(context, weight: FontWeight.w600, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildCancelledExtraLabel(BuildContext context, double screenWidth) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: screenWidth * 0.9,
      height: 50,
      decoration: BoxDecoration(
        color: AppColors.containerBackground(context),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.shade300),
      ),
      child: Center(
        child: Text(
          'Extra Items Cancelled',
          style: AppTextStyles.textSize16(context, weight: FontWeight.w600, color: AppColors.darkRedColor),
        ),
      ),
    );
  }

  Widget _buildPayNowButton(BuildContext context, double screenWidth) {
    return GestureDetector(
      onTap: () async => await data.onPayNow?.call(),
      child: Container(
        width: screenWidth * 0.9,
        height: 50,
        decoration: BoxDecoration(color: AppColors.textPrimary(context), borderRadius: BorderRadius.circular(8)),
        child: Center(
          child: Text(
            data.payNowLabel,
            style: AppTextStyles.textSize16(context, weight: FontWeight.w600, color: AppColors.containerBackground(context)),
          ),
        ),
      ),
    );
  }

  Widget _buildDownloadButton(BuildContext context, double screenWidth) {
    return GestureDetector(
      onTap: data.isDownloading ? null : () async => await data.onDownloadReceipt(),
      child: Container(
        width: screenWidth * 0.9,
        height: 50,
        decoration: BoxDecoration(
          color: AppColors.containerBackground(context),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border(context), width: 1),
        ),
        child: data.isDownloading
            ? Center(child: LoadingAnimationWidget.progressiveDots(color: AppColors.button(context), size: 50))
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(FontAwesomeIcons.print, color: AppColors.textPrimary(context), size: 18),
                  const SizedBox(width: 12),
                  Text('Download Receipt', style: AppTextStyles.textSize16(context, weight: FontWeight.w600)),
                ],
              ),
      ),
    );
  }

  Widget _buildWhatsNextSection(BuildContext context, double screenWidth, double screenHeight) {
    return Container(
      width: screenWidth * 0.9,
      padding: EdgeInsets.all(screenHeight * 0.02),
      decoration: BoxDecoration(
        color: AppColors.textFieldFill(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(width: 1, color: AppColors.border(context)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.access_time_filled, color: AppColors.textPrimary(context), size: 20),
              SizedboxSpaccing.width02(context),
              Text("What's Next?", style: AppTextStyles.textSize16(context, weight: FontWeight.w600)),
            ],
          ),
          SizedboxSpaccing.height01(context),
          _buildBulletRow(context, "Customer Care will reach out within 30 minutes to provide verbal confirmation."),
          SizedboxSpaccing.height01(context),
          _buildBulletRow(context, "Track your service status in the 'Order' section"),
        ],
      ),
    );
  }

  Widget _buildBulletRow(BuildContext context, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.circle, color: AppColors.textPrimary(context), size: 10),
        SizedboxSpaccing.width02(context),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.textSize14(context, weight: FontWeight.w400, color: AppColors.subtitle(context)),
          ),
        ),
      ],
    );
  }

  Widget _buildTrackOrderButton(BuildContext context, double screenWidth) {
    return GestureDetector(
      onTap: data.onTrackOrder,
      child: Container(
        width: screenWidth * 0.9,
        height: 50,
        decoration: BoxDecoration(color: AppColors.button(context), borderRadius: BorderRadius.circular(8)),
        child: Center(
          child: Text(
            'Track My Order',
            style: AppTextStyles.textSize16(context, weight: FontWeight.w600, color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _buildBackToHomeButton(BuildContext context, double screenWidth) {
    return GestureDetector(
      onTap: onBackToHome,
      child: Container(
        width: screenWidth * 0.9,
        height: 50,
        decoration: BoxDecoration(
          color: AppColors.textFieldFill(context),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(width: 1, color: AppColors.border(context)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(FontAwesomeIcons.home, color: AppColors.textPrimary(context), size: 16),
            const SizedBox(width: 12),
            Text('Back to Home', style: AppTextStyles.textSize16(context, weight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailColumn(String label, String value, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.textSize14(context, color: AppColors.textPrimary(context), weight: FontWeight.w600),
        ),
        SizedboxSpaccing.height005(context),
        Text(value, style: AppTextStyles.textSize14(context, weight: FontWeight.w400)),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.textSize14(context, color: AppColors.textPrimary(context), weight: FontWeight.w600),
        ),
        Text(
          value,
          style: AppTextStyles.textSize14(context, weight: FontWeight.w400, color: AppColors.textPrimary(context)),
        ),
      ],
    );
  }

  String _calcExtraTotal() {
    final total = data.extraItems.fold<num>(0, (sum, i) => sum + (i.price ?? 0));
    return AmountFormatter.formatDynamic(total);
  }
}
