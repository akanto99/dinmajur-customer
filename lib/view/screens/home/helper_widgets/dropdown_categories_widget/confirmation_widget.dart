import 'package:dinmajur_customer/configs/res/components/support_cards/customercare_support_card.dart';
import 'package:flutter/material.dart';
import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/sizedbox_spaccing.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

/// Model class to hold all dynamic data for the confirmation screen
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
  });

  bool get shouldShowPayNow {
    if (fromCheckout) return false;
    if (onPayNow == null) return false;

    final order = (orderStatus ?? '').toUpperCase();
    final status = (paymentStatus ?? '').toUpperCase();

    // Never show if order is completed
    if (order == 'COMPLETED' || order == 'PENDING'|| order == 'CANCELLED'|| order == 'CONFIRMED') return false;

    // Never show if already paid
    if (status == 'PAID') return false;

    // Show for any unpaid order (cash OR online) that is not completed
    return true;
  }
}

/// Service item model
class ServiceItem {
  final String name;
  final String? additionalInfo;

  ServiceItem({required this.name, this.additionalInfo});
}

/// Reusable Booking Confirmation UI Component
class BookingConfirmationUI extends StatelessWidget {
  final BookingConfirmationData data;
  final VoidCallback onBackToHome;

  const BookingConfirmationUI({Key? key, required this.data, required this.onBackToHome}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return SingleChildScrollView(
      child: Column(
        children: [
          SizedboxSpaccing.height02(context),
          _buildSuccessHeader(context, screenWidth, screenHeight),
          SizedboxSpaccing.height03(context),
          _buildSectionTitle(context, screenWidth, 'Booking Details'),
          SizedboxSpaccing.height01(context),
          _buildBookingDetailsCard(context, screenWidth, screenHeight),
          SizedboxSpaccing.height03(context),
          _buildDownloadButton(context, screenWidth),
          if (data.shouldShowPayNow) ...[SizedboxSpaccing.height02(context), _buildPayNowButton(context, screenWidth)],
          SizedboxSpaccing.height04(context),
          _buildWhatsNextSection(context, screenWidth, screenHeight),
          SizedboxSpaccing.height03(context),
          CustomerCareSupportCard(),
          SizedboxSpaccing.height03(context),
          _buildTrackOrderButton(context, screenWidth),
          SizedboxSpaccing.height02(context),
          _buildBackToHomeButton(context, screenWidth, onBackToHome),
          SizedboxSpaccing.height04(context),
        ],
      ),
    );
  }

  Widget _buildSuccessHeader(BuildContext context, double screenWidth, double screenHeight) {
    return Container(
      width: screenWidth * 0.9,
      padding: EdgeInsets.all(screenHeight * 0.02),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(width: 1, color: AppColors.border(context)),
      ),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(color: AppColors.border(context), shape: BoxShape.circle),
            child: Center(
              child: Container(
                width: 25,
                height: 25,
                decoration: BoxDecoration(color: AppColors.button(context), shape: BoxShape.circle),
                child: Icon(Icons.check, color: Colors.white, size: 16),
              ),
            ),
          ),
          SizedboxSpaccing.height01(context),
          Text(
            'Booking Confirmed!',
            style: AppTextStyles.textSize18(context, weight: FontWeight.w500),
            textAlign: TextAlign.center,
          ),
          SizedboxSpaccing.height01(context),
          Container(
            width: screenWidth * 0.85,
            child: Text(
              data.thankYouMessage,
              style: AppTextStyles.textSize14(context, color: AppColors.subtitle(context)),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, double screenWidth, String title) {
    return Container(
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
          SizedBox(height: 16),
          _buildServicesSection(context),
          SizedBox(height: 16),
          _buildDetailColumn('Date & Time', _formatDateTime(data.dateTime), context),
          SizedBox(height: 16),
          _buildDetailColumn('Service Address', data.serviceAddress, context),
          SizedBox(height: 16),
          _buildDetailRow('Total Payment', '৳ ${data.grandTotal}', context),
          SizedBox(height: 16),
          _buildDetailRow('Payment Method', data.paymentMethod, context),
          SizedBox(height: 16),
          _buildDetailRow('Payment Status', data.paymentStatus?? 'N/A', context),
          SizedBox(height: 16),
          _buildDetailRow('Status', data.orderStatus?? 'N/A', context),
        ],
      ),
    );
  }

  Widget _buildServicesSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Service",
          style: AppTextStyles.textSize14(context, color: AppColors.textPrimary(context), weight: FontWeight.w600),
        ),
        SizedboxSpaccing.height005(context),
        ...data.services.map((service) {
          return Padding(
            padding: EdgeInsets.only(bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    service.additionalInfo != null ? '${service.name} ${service.additionalInfo}' : service.name,
                    style: AppTextStyles.textSize14(context, weight: FontWeight.w400),
                    softWrap: true,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildDownloadButton(BuildContext context, double screenWidth) {
    return GestureDetector(
      onTap: data.isDownloading
          ? null
          : () async {
              await data.onDownloadReceipt();
            },
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
                  SizedBox(width: 12),
                  Text('Download Receipt', style: AppTextStyles.textSize16(context, weight: FontWeight.w600)),
                ],
              ),
      ),
    );
  }

  // ✅ INSIDE the class — data is accessible here
  Widget _buildPayNowButton(BuildContext context, double screenWidth) {
    return GestureDetector(
      onTap: () async {
        await data.onPayNow?.call();
      },
      child: Container(
        width: screenWidth * 0.9,
        height: 50,
        decoration: BoxDecoration(color: AppColors.textPrimary(context), borderRadius: BorderRadius.circular(8)),
        child: Center(
          child: Text(
            'Pay Now',
            style: AppTextStyles.textSize16(context, weight: FontWeight.w600, color: AppColors.containerBackground(context)),
          ),
        ),
      ),
    );
  }

  Widget _buildWhatsNextSection(BuildContext context, double screenWidth, double screenHeight) {
    return Container(
      width: screenWidth * 0.9,
      padding: EdgeInsets.all(screenHeight * .02),
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
          Row(
            children: [
              Icon(Icons.circle, color: AppColors.textPrimary(context), size: 10),
              SizedboxSpaccing.width02(context),
              Expanded(
                child: Text(
                  "Customer Care will reach out within 30 minutes to provide verbal confirmation.",
                  style: AppTextStyles.textSize14(context, weight: FontWeight.w400, color: AppColors.subtitle(context)),
                ),
              ),
            ],
          ),
          SizedboxSpaccing.height01(context),
          Row(
            children: [
              Icon(Icons.circle, color: AppColors.textPrimary(context), size: 10),
              SizedboxSpaccing.width02(context),
              Expanded(
                child: Text(
                  "Track your service status in the 'Order' section",
                  style: AppTextStyles.textSize14(context, weight: FontWeight.w400, color: AppColors.subtitle(context)),
                ),
              ),
            ],
          ),
        ],
      ),
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

  Widget _buildBackToHomeButton(BuildContext context, double screenWidth, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
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
            SizedBox(width: 12),
            Text('Back to Home', style: AppTextStyles.textSize16(context, weight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailColumn(String label, String value, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
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
} // ← class closes here

// ── Top-level helper (outside class is fine) ──────────────────────────────────
String _formatDateTime(String dateTime) {
  try {
    final parts = dateTime.split(', ');
    if (parts.length != 2) return dateTime;

    final datePart = parts[0];
    final timePart = parts[1];

    final timeComponents = timePart.split(':');
    if (timeComponents.length != 2) return dateTime;

    int hour = int.parse(timeComponents[0]);
    final minute = timeComponents[1];

    String period = 'AM';
    if (hour >= 12) {
      period = 'PM';
      if (hour > 12) hour = hour - 12;
    }
    if (hour == 0) hour = 12;

    return '$datePart, $hour:$minute $period';
  } catch (e) {
    return dateTime;
  }
}
