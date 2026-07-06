import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/components/exception_errorstate/exception_errorstate.dart';
import 'package:dinmajur_customer/configs/res/components/header_appbar.dart';
import 'package:dinmajur_customer/configs/res/components/pdf_reciept_generator_auto_open_download/get_booking_confirmation_pdf_generator.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:dinmajur_customer/configs/responsive/responsive_ui.dart';
import 'package:dinmajur_customer/configs/services/ssl_payment_service/ssl_payment.dart';
import 'package:dinmajur_customer/configs/utils/amount_formatter/amount_formatter.dart';
import 'package:dinmajur_customer/configs/utils/date_formater/date_formater.dart';
import 'package:dinmajur_customer/configs/utils/utils.dart';
import 'package:dinmajur_customer/data/response/status.dart';
import 'package:dinmajur_customer/model/home_models/dropdown_categories_selection_models/premium_house_keeper_model/get_confirmedbooking_model.dart' hide ExtraItem;
import 'package:dinmajur_customer/view/navigation_bar.dart';
import 'package:dinmajur_customer/view/screens/home/helper_widgets/dropdown_categories_widget/confirmation_widget.dart';
import 'package:dinmajur_customer/view_model/homeview_model/dropdown_categories_selection_view_models/approve_booking_view_model.dart';
import 'package:dinmajur_customer/view_model/homeview_model/dropdown_categories_selection_view_models/premium_house_keeper_view_model/get_confirmedbooking_view_model.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class ConfirmedScreen extends StatefulWidget {
  final String? trackingId;
  final String? valId;
  final bool fromCheckout;

  const ConfirmedScreen({Key? key, this.trackingId, this.valId, this.fromCheckout = false}) : super(key: key);

  @override
  State<ConfirmedScreen> createState() => _ConfirmedScreenState();
}

class _ConfirmedScreenState extends State<ConfirmedScreen> {
  bool _isDownloading = false;

  // ── Pay Now (smart: picks tracking ID and amount based on payment state) ────
  Future<void> _handlePayNow() async {
    final bookingData = Provider.of<GetConfirmedbookingViewModel>(context, listen: false).getConfirmBookingData.data?.data;

    if (bookingData == null) return;

    final bool mainPaid = bookingData.paymentStatus?.toUpperCase() == 'PAID';

    final String trackingId;
    final double amount;

    if (mainPaid) {
      // Main already paid → pay only the extra items
      final extraId = bookingData.extraItemsTrackingId;
      if (extraId == null || extraId.isEmpty) {
        Utils.flushBarErrorMessage("Extra items tracking ID not found", context);
        return;
      }
      trackingId = extraId;
      amount = (bookingData.totalExtraAmount ?? 0).toDouble();
    } else {
      // Main unpaid → pay everything via the main tracking ID
      final mainId = bookingData.trackingId;
      if (mainId == null || mainId.isEmpty) {
        Utils.flushBarErrorMessage("Booking tracking ID not found", context);
        return;
      }
      trackingId = mainId;
      amount = (bookingData.grandTotal ?? 0).toDouble();
    }

    final result = await SSLCommerzPaymentService().initiatePayment(
      trackingId: trackingId,
      totalAmount: amount,
      productCategory: 'BEAUTY_SALON',
      customerName: bookingData.fullName ?? '',
      customerPhone: bookingData.phone ?? '',
      customerEmail: bookingData.email ?? '',
      customerAddress: bookingData.fullAddress ?? '',
    );

    if (!mounted) return;

    if (result.success) {
      final viewModel = Provider.of<GetConfirmedbookingViewModel>(context, listen: false);
      viewModel.fetchGetConfirmBookingDataApi(widget.trackingId!);
      Utils.flushBarSuccessMessage("Payment successful!", context);
    } else {
      Utils.flushBarErrorMessage(result.errorMessage ?? "Payment cancelled", context);
    }
  }

  Future<void> _handleRefresh() async {
    final viewModel = Provider.of<GetConfirmedbookingViewModel>(context, listen: false);
    await viewModel.fetchGetConfirmBookingDataApi(widget.trackingId!);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.trackingId != null) {
        final viewModel = Provider.of<GetConfirmedbookingViewModel>(context, listen: false);
        viewModel.fetchGetConfirmBookingDataApi(widget.trackingId!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !widget.fromCheckout,
      onPopInvoked: (didPop) {
        if (didPop) return;
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => NavigationScreen(initialIndex: 0)), (route) => false);
      },
      child: Scaffold(
        backgroundColor: AppColors.containerBackground(context),
        body: SafeArea(
          child: ResPonsiveUi(mobile: _body(), desktop: _body(), tablet: _body()),
        ),
      ),
    );
  }

  Widget _body() {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            if (widget.fromCheckout) {
              Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => NavigationScreen(initialIndex: 0)), (route) => false);
            } else {
              Navigator.pop(context);
            }
          },
          child: SizedBox(height: 60, child: AppBarHeader("Booking Confirmation")),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _handleRefresh,
            color: AppColors.textPrimary(context),
            backgroundColor: AppColors.containerBackground(context),
            displacement: 40,
            strokeWidth: 2.0,
            child: Consumer2<GetConfirmedbookingViewModel, ApproveBookingViewModel>(
              builder: (context, viewModel, approveVm, _) {
                final status = viewModel.getConfirmBookingData.status;
                final bookingData = viewModel.getConfirmBookingData.data?.data;

                // Sync extraItemsStatus into ViewModel on every rebuild
                if (bookingData != null) {
                  final apiStatus = bookingData.extraItemsStatus;
                  if (approveVm.extraItemsStatus != apiStatus && !approveVm.isApproveLoading && !approveVm.isRejectLoading) {
                    approveVm.setStatusFromApi(apiStatus);
                  }
                }

                if (status == Status.LOADING) {
                  return Center(child: LoadingAnimationWidget.progressiveDots(color: AppColors.button(context), size: 50));
                }

                if (status == Status.ERROR) {
                  return Center(
                    child: ErrorStateWidget(errorMessage: "Failed to load booking details", onRetry: () => viewModel.fetchGetConfirmBookingDataApi(widget.trackingId!)),
                  );
                }

                if (bookingData == null) {
                  return Center(child: Text('No booking data available', style: AppTextStyles.textSize16(context)));
                }

                // Build service items
                final services = (bookingData.houseKeeperBookingItems ?? []).map((item) {
                  final rooms = item.totalRooms ?? 0;
                  return ServiceItem(name: item.houseKeeperTaskId?.name ?? 'Service', additionalInfo: rooms > 0 ? '($rooms)' : null);
                }).toList();

                // Build extra items
                final extraItems = (bookingData.extraItems ?? []).map((e) => ExtraItem(name: e.name ?? 'Extra', price: e.price ?? 0)).toList();

                final orderStatus = (bookingData.status ?? '').toUpperCase();

                // Show approve/reject only when order is RUNNING,
                // extra items exist, and not from checkout
                final bool showExtraActions = orderStatus == 'RUNNING' && extraItems.isNotEmpty && !widget.fromCheckout;

                final confirmationData = BookingConfirmationData(
                  thankYouMessage: "Thank you for choosing our premium house keeping service. We've received your order.",
                  orderId: bookingData.id ?? 'N/A',
                  services: services,
                  dateTime: '${DateFormatter.formatDate(bookingData.date)},(${bookingData.shiftId?.startTime ?? ''} - ${bookingData.shiftId?.endTime ?? ''})',
                  serviceAddress: bookingData.fullAddress ?? 'N/A',
                  grandTotal: AmountFormatter.formatDynamic(bookingData.grandTotal),
                  paymentMethod: bookingData.paymentType ?? 'N/A',
                  onDownloadReceipt: _handleDownloadReceipt,
                  onTrackOrder: () => Navigator.push(context, MaterialPageRoute(builder: (_) => NavigationScreen(initialIndex: 2))),
                  isDownloading: _isDownloading,
                  fromCheckout: widget.fromCheckout,
                  paymentStatus: bookingData.paymentStatus,
                  orderStatus: bookingData.status,
                  extraItemsPaymentStatus: bookingData.extraItemsPaymentStatus,
                  totalExtraAmount: bookingData.totalExtraAmount,
                  extraItemsTrackingId: bookingData.extraItemsTrackingId,
                  // Single Pay Now handler — smart routing inside
                  onPayNow: widget.fromCheckout ? null : _handlePayNow,
                  extraItems: extraItems,
                  extraItemsStatus: approveVm.extraItemsStatus,
                  isApproveLoading: approveVm.isApproveLoading,
                  isRejectLoading: approveVm.isRejectLoading,
                  onApprove: showExtraActions
                      ? () => approveVm.approveBooking(context: context, bookingId: bookingData.id!,freelancerId:bookingData.freelancerId!, onSuccess: () => viewModel
                      .fetchGetConfirmBookingDataApi(widget
                    .trackingId!))
                      : null,
                  onReject: showExtraActions
                      ? () => approveVm.rejectBooking(context: context, bookingId: bookingData.id!,freelancerId:bookingData.freelancerId!, onSuccess: () => viewModel.fetchGetConfirmBookingDataApi(widget.trackingId!))
                      : null,
                );

                return BookingConfirmationUI(
                  data: confirmationData,
                  onBackToHome: () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => NavigationScreen(initialIndex: 0)), (route) => false),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _handleDownloadReceipt() async {
    final bookingData = Provider.of<GetConfirmedbookingViewModel>(context, listen: false).getConfirmBookingData.data?.data;

    if (bookingData == null) {
      Utils.flushBarErrorMessage("No booking data available to download", context);
      return;
    }

    setState(() => _isDownloading = true);

    try {
      if (Platform.isAndroid) {
        try {
          final sdkInt = (await DeviceInfoPlugin().androidInfo).version.sdkInt;
          if (sdkInt <= 32) {
            final status = await Permission.storage.request();
            if (!status.isGranted) {
              Utils.flushBarErrorMessage("Storage permission is required to download receipt", context);
              setState(() => _isDownloading = false);
              return;
            }
          }
        } catch (e) {
        }
      }

      final file = await BookingReceiptPdfGenerator.generateAndDownloadReceipt(bookingData);

      setState(() => _isDownloading = false);

      if (file != null) {
        Utils.flushBarSuccessMessage("Receipt saved successfully!", context);
        _showDownloadSuccessDialog(file.path);
      } else {
        Utils.flushBarErrorMessage("Failed to generate receipt", context);
      }
    } catch (e) {
      setState(() => _isDownloading = false);
      Utils.flushBarErrorMessage("Error: ${e.toString()}", context);
    }
  }

  void _showDownloadSuccessDialog(String filePath) {
    final screenWidth = MediaQuery.of(context).size.width;
    showDialog(
      context: context,
      barrierColor: AppColors.showDialougeBackground(context),
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.containerBackground(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text('Download Complete', style: AppTextStyles.textSize18(context, weight: FontWeight.w600)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Receipt saved successfully!', style: AppTextStyles.textSize14(context)),
            const SizedBox(height: 12),
            Container(
              width: screenWidth,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: AppColors.button(context).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '📁 Location:',
                    style: AppTextStyles.textSize12(context, weight: FontWeight.w600, color: AppColors.button(context)),
                  ),
                  const SizedBox(height: 4),
                  Text('Downloads/Dinmajur Booking', style: AppTextStyles.textSize12(context)),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text('Would you like to open it now?', style: AppTextStyles.textSize14(context)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Later', style: TextStyle(color: Colors.grey[600])),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await OpenFile.open(filePath);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.button(context)),
            child: const Text(
              'Open Now',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
