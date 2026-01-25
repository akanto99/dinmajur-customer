import 'package:dinmajur_customer/configs/res/components/support_cards/customercare_support_card.dart';
import 'package:flutter/material.dart';
import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/sizedbox_spaccing.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Model class for failed/cancelled payment confirmation
class FailedCancelledConfirmationData {
  final bool isCancelled; // true = cancelled, false = failed
  final String message;
  final String orderId;
  final List<ServiceItem> services;
  final String dateTime;
  final String serviceAddress;
  final String grandTotal;
  final String paymentMethod;
  final String reason;
  final String? errorMessage;
  final VoidCallback onRetryPayment;

  FailedCancelledConfirmationData({
    required this.isCancelled,
    required this.message,
    required this.orderId,
    required this.services,
    required this.dateTime,
    required this.serviceAddress,
    required this.grandTotal,
    required this.paymentMethod,
    required this.reason,
    this.errorMessage,
    required this.onRetryPayment,
  });
}

/// Service item model
class ServiceItem {
  final String name;
  final String? additionalInfo;

  ServiceItem({required this.name, this.additionalInfo});
}

/// Reusable Failed/Cancelled Payment Confirmation UI Component
class FailedCancelledConfirmationUI extends StatelessWidget {
  final FailedCancelledConfirmationData data;
  final VoidCallback onBackToHome;

  const FailedCancelledConfirmationUI({Key? key, required this.data, required this.onBackToHome}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return SingleChildScrollView(
      child: Column(
        children: [
          SizedboxSpaccing.height02(context),

          // Failed/Cancelled Header Card
          _buildFailedCancelledHeader(context, screenWidth, screenHeight),

          SizedboxSpaccing.height03(context),

          // Booking Details Section
          _buildSectionTitle(context, screenWidth, 'Booking Details'),

          SizedboxSpaccing.height01(context),

          // Booking Details Card
          _buildBookingDetailsCard(context, screenWidth, screenHeight),

          SizedboxSpaccing.height03(context),

          // What to Do Next Section
          _buildWhatToDoNextSection(context, screenWidth, screenHeight),

          SizedboxSpaccing.height045(context),

          // Action Buttons
          _buildActionButtons(context, screenWidth),

          SizedboxSpaccing.height02(context),


          CustomerCareSupportCard(),


          SizedboxSpaccing.height045(context),
        ],
      ),
    );
  }

  // Failed/Cancelled Header with Icon and Message
  Widget _buildFailedCancelledHeader(BuildContext context, double screenWidth, double screenHeight) {
    return Container(
      width: screenWidth * 0.9,
      padding: EdgeInsets.all(screenHeight * 0.02),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(width: 1, color: AppColors.border(context)),
      ),
      child: Column(
        children: [
          // Failed/Cancelled Icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(color: data.isCancelled ? Colors.orange.withOpacity(0.2) : Colors.red.withOpacity(0.2), shape: BoxShape.circle),
            child: Center(child: Icon(data.isCancelled ? FontAwesomeIcons.xmark : FontAwesomeIcons.triangleExclamation, color: data.isCancelled ? Colors.orange : Colors.red, size: 22)),
          ),

          SizedboxSpaccing.height01(context),

          // Title
          Text(
            data.isCancelled ? 'Payment Cancelled' : 'Payment Failed',
            style: AppTextStyles.textSize18(context, weight: FontWeight.w500),
            textAlign: TextAlign.center,
          ),

          SizedboxSpaccing.height01(context),

          // Message
          Container(
            width: screenWidth * 0.85,
            child: Text(
              data.message,
              style: AppTextStyles.textSize14(context, color: AppColors.subtitle(context), weight: FontWeight.w400),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  // Section Title Widget
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

  // Booking Details Card
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
          // Order Number
          _buildDetailColumn('Order Number', '#${data.orderId.length > 6 ? data.orderId.substring(data.orderId.length - 6) : data.orderId}', context),
          SizedBox(height: 16),

          // Services
          _buildServicesSection(context),

          SizedBox(height: 16),

          // Date & Time
          _buildDetailColumn('Date & Time', data.dateTime, context),

          SizedBox(height: 16),

          // Service Address
          _buildDetailColumn('Service Address', data.serviceAddress, context),

          SizedBox(height: 16),

          // Total Payment
          _buildDetailRow('Total Payment', '৳ ${data.grandTotal}', context),

          SizedBox(height: 16),

          // Payment Method
          _buildDetailRow('Payment Method', data.paymentMethod, context),

          // SizedboxSpaccing.height01(context),

          // Payment Status
          // _buildDetailRow(
          //   'Payment Status',
          //   data.isCancelled ? 'Cancelled' : 'Failed',
          //   context,
          //   valueColor: data.isCancelled ? Colors.orange : Colors.red,
          // ),

          // if (data.errorMessage != null) ...[
          //   SizedboxSpaccing.height01(context),
          //   _buildDetailColumn('Error Details', data.errorMessage!, context),
          // ],
        ],
      ),
    );
  }

  // Services Section with Dynamic Items
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
              children: [
                Text(service.name, style: AppTextStyles.textSize14(context, weight: FontWeight.w400)),
                if (service.additionalInfo != null) Text(' ${service.additionalInfo}', style: AppTextStyles.textSize14(context, weight: FontWeight.w400)),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  // What to Do Next Section
  Widget _buildWhatToDoNextSection(BuildContext context, double screenWidth, double screenHeight) {
    return Container(
      width: screenWidth * 0.9,
      padding: EdgeInsets.all(screenHeight * .02),
      decoration: BoxDecoration(
        color: AppColors.containerBackground(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(width: 1, color: AppColors.border(context)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(width: 20, child: Icon(Icons.headset_mic, color: AppColors.textPrimary(context), size: 20)),
              SizedboxSpaccing.width02(context),
              Text("Need Help?", style: AppTextStyles.textSize16(context, weight: FontWeight.w600)),
            ],
          ),
          SizedboxSpaccing.height01(context),
          Row(
            children: [
              SizedBox(width: 20),
              SizedboxSpaccing.width02(context),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Contact our support team for assistance with payment issues.",
                      style: AppTextStyles.textSize14(context, weight: FontWeight.w400, color: AppColors.subtitle(context)),
                    ),
                    SizedboxSpaccing.height005(context),
                    Text(
                      "Contact Support",
                      style: AppTextStyles.textSize14(context, weight: FontWeight.w500, color: AppColors.textPrimary(context)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Action Buttons
  Widget _buildActionButtons(BuildContext context, double screenWidth) {
    return Column(
      children: [
        // Retry Payment Button
        GestureDetector(
          onTap: data.onRetryPayment,
          child: Container(
            width: screenWidth * 0.9,
            height: 50,
            decoration: BoxDecoration(color: AppColors.button(context), borderRadius: BorderRadius.circular(8)),
            child: Center(
              child: Text(
                'Retry Payment',
                style: AppTextStyles.textSize16(context, weight: FontWeight.w600, color: Colors.white),
              ),
            ),
          ),
        ),

        SizedboxSpaccing.height015(context),

        // Go to Home Button
        GestureDetector(
          onTap: onBackToHome,
          child: Container(
            width: screenWidth * 0.9,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border(context), width: 1),
            ),
            child: Center(
              child: Text(
                'Go to Home',
                style: AppTextStyles.textSize16(context, weight: FontWeight.w600, color: AppColors.textPrimary(context)),
              ),
            ),
          ),
        ),
      ],
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

  // Helper: Detail Row
  Widget _buildDetailRow(String label, String value, BuildContext context, {Color? valueColor}) {
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
          style: AppTextStyles.textSize14(context, weight: FontWeight.w400, color: valueColor ?? AppColors.textPrimary(context)),
        ),
      ],
    );
  }
}
