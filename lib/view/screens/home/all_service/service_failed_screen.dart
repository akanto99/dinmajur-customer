import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/components/confirm_cancel_failed_component/cancel_failed_component.dart';
import 'package:dinmajur_customer/configs/res/components/header_appbar.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:dinmajur_customer/configs/responsive/responsive_ui.dart';
import 'package:dinmajur_customer/configs/utils/amount_formatter/amount_formatter.dart';
import 'package:dinmajur_customer/configs/utils/date_formater/date_formater.dart';
import 'package:dinmajur_customer/data/response/status.dart';
import 'package:dinmajur_customer/view/navigation_bar.dart';
import 'package:dinmajur_customer/view_model/homeview_model/all_service_view_models/getservice_confirmationdetails_view_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';

class ServiceFailedScreen extends StatefulWidget {
  final String? trackingId;
  final String? valId;
  final String? reason;
  final String? errorMessage;
  final bool isCancelled; // true = cancelled, false = failed

  const ServiceFailedScreen({
    Key? key,
    this.trackingId,
    this.valId,
    this.reason,
    this.errorMessage,
    this.isCancelled = false,
  }) : super(key: key);

  @override
  State<ServiceFailedScreen> createState() => _ServiceFailedScreenState();
}

class _ServiceFailedScreenState extends State<ServiceFailedScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.trackingId != null) {
        final viewModel = Provider.of<GetServiceConfirmationDetailsViewModel>(context, listen: false);
        viewModel.fetchGetServiceDataApi(widget.trackingId!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.containerBackground(context),
      body: SafeArea(
        child: ResPonsiveUi(
          mobile: _body(),
          desktop: _body(),
          tablet: _body(),
        ),
      ),
    );
  }

  Widget _body() {
    return Column(
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            height: 60,
            child: AppBarHeader(widget.isCancelled ? "Payment Cancelled" : "Payment Failed"),
          ),
        ),
        Expanded(
          child: Consumer<GetServiceConfirmationDetailsViewModel>(
            builder: (context, viewModel, _) {
              final status = viewModel.getServiceData.status;

              if (status == Status.LOADING) {
                return Center(
                  child: LoadingAnimationWidget.progressiveDots(
                    color: AppColors.button(context),
                    size: 50,
                  ),
                );
              }

              if (status == Status.ERROR) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 48, color: Colors.red),
                      SizedBox(height: 16),
                      Text(
                        'Failed to load booking details',
                        style: AppTextStyles.textSize16(context, color: Colors.red),
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          if (widget.trackingId != null) {
                            viewModel.fetchGetServiceDataApi(widget.trackingId!);
                          }
                        },
                        child: Text('Retry'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.button(context),
                        ),
                      ),
                    ],
                  ),
                );
              }

              final bookingData = viewModel.getServiceData.data?.data;
              if (bookingData == null) {
                return Center(
                  child: Text(
                    'No booking data available',
                    style: AppTextStyles.textSize16(context),
                  ),
                );
              }

              // Prepare service items
              List<ServiceItem> services = [];
              if (bookingData.bookingItems != null &&
                  bookingData.bookingItems!.isNotEmpty) {
                for (var item in bookingData.bookingItems!) {
                  if (item.task?.name != null) {
                    String additionalInfo = '';
                      additionalInfo = '(${item.quantity})';
                    services.add(ServiceItem(
                      name: item.task!.name!,
                      additionalInfo: additionalInfo.isEmpty ? null : additionalInfo,
                    ));
                  }
                }
              }


              // Create failed/cancelled confirmation data
              final confirmationData = FailedCancelledConfirmationData(
                isCancelled: widget.isCancelled,
                message: widget.isCancelled
                    ? "Your payment was cancelled. Don't worry, you can retry the payment anytime."
                    : "We couldn't process your payment. Please try again or contact customer support.",
                orderId: bookingData.trackingId ?? 'N/A',
                services: services,
                dateTime: '${DateFormatter.formatDate(bookingData.date)}, ${bookingData.timeSlotSnapshot?.timeLabel ?? bookingData.time ?? 'N/A'}',
                serviceAddress: bookingData.fullAddress ?? 'N/A',
                grandTotal:AmountFormatter.formatDynamic(bookingData.grandTotal),
                paymentMethod: bookingData.paymentType ?? 'N/A',
                reason: widget.reason ?? (widget.isCancelled ? 'Payment cancelled by user' : 'Payment transaction failed'),
                errorMessage: widget.errorMessage,
                onRetryPayment: () {
                  Navigator.pop(context);
                },
              );

              return FailedCancelledConfirmationUI(
                data: confirmationData,
                onBackToHome: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NavigationScreen(initialIndex: 0),
                    ),
                        (route) => false,
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}