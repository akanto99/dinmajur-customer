import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/components/confirm_cancel_failed_component/cancel_failed_component.dart';
import 'package:dinmajur_customer/configs/res/components/header_appbar.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:dinmajur_customer/configs/responsive/responsive_ui.dart';
import 'package:dinmajur_customer/configs/utils/date_formater/date_formater.dart';
import 'package:dinmajur_customer/data/response/status.dart';
import 'package:dinmajur_customer/view/navigation_bar.dart';
import 'package:dinmajur_customer/view_model/homeview_model/dropdown_categories_selection_view_models/family_event_cooking_view_model/getdetails_event_cooking_view_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';

class CookingFailedCancelledPaymentScreen extends StatefulWidget {
  final String? trackingId;
  final String? valId;
  final String? reason;
  final String? errorMessage;
  final bool isCancelled; // true = cancelled, false = failed

  const CookingFailedCancelledPaymentScreen({
    Key? key,
    this.trackingId,
    this.valId,
    this.reason,
    this.errorMessage,
    this.isCancelled = false,
  }) : super(key: key);

  @override
  State<CookingFailedCancelledPaymentScreen> createState() => _CookingFailedCancelledPaymentScreenState();
}

class _CookingFailedCancelledPaymentScreenState extends State<CookingFailedCancelledPaymentScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.trackingId != null) {
        final viewModel = Provider.of<GetDetailsEventCookingViewModel>(context, listen: false);
        viewModel.fetchgetDetailsEventCookingDataApi(widget.trackingId!);
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
          child: Consumer<GetDetailsEventCookingViewModel>(
            builder: (context, viewModel, _) {
              final status = viewModel.getDetailsEventCookingData.status;

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
                            viewModel.fetchgetDetailsEventCookingDataApi(widget.trackingId!);
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

              final bookingData = viewModel.getDetailsEventCookingData.data?.data;
              if (bookingData == null) {
                return Center(
                  child: Text(
                    'No booking data available',
                    style: AppTextStyles.textSize16(context),
                  ),
                );
              }

              // Prepare service items - handles both REGULAR and MANUAL
              List<ServiceItem> services = [];
              if (bookingData.items != null && bookingData.items!.isNotEmpty) {
                for (var bookingItem in bookingData.items!) {
                  if (bookingItem.isManual) {
                    // MANUAL booking - multiple items per package
                    final packageName = bookingItem.package?.name ?? 'Package';

                    if (bookingItem.items != null && bookingItem.items!.isNotEmpty) {
                      for (var itemWrapper in bookingItem.items!) {
                        String serviceName = itemWrapper.item?.name ?? 'Item';

                        services.add(ServiceItem(
                          name: serviceName,
                          additionalInfo: null,
                        ));
                      }
                    }
                  } else {
                    // REGULAR booking - single package with price
                    String serviceName = bookingItem.package?.name ?? 'Package';

                    services.add(ServiceItem(
                      name: serviceName,
                      additionalInfo: null,
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
                dateTime:"${DateFormatter.formatDate(bookingData.date)}, ${bookingData.slot}",
                serviceAddress: bookingData.fullAddress ?? 'N/A',
                grandTotal: (bookingData.grandTotal ?? 0).toStringAsFixed(2),
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

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return DateFormat('dd MMM yyyy').format(date);
  }
}