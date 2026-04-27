import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/components/exception_errorstate/exception_errorstate.dart';
import 'package:dinmajur_customer/configs/res/components/header_appbar.dart';
import 'package:dinmajur_customer/configs/res/components/pdf_reciept_generator_auto_open_download/pdf_generator.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:dinmajur_customer/configs/responsive/responsive_ui.dart';
import 'package:dinmajur_customer/configs/utils/amount_formatter/amount_formatter.dart';
import 'package:dinmajur_customer/configs/utils/date_formater/date_formater.dart';
import 'package:dinmajur_customer/configs/utils/utils.dart';
import 'package:dinmajur_customer/data/response/status.dart';
import 'package:dinmajur_customer/view/navigation_bar.dart';
import 'package:dinmajur_customer/view/screens/home/helper_widgets/dropdown_categories_widget/confirmation_widget.dart';
import 'package:dinmajur_customer/view_model/homeview_model/all_service_view_models/getservice_confirmationdetails_view_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class ServiceConfirmedScreen extends StatefulWidget {
  final String? trackingId;
  final String? valId;
  const ServiceConfirmedScreen({Key? key, this.trackingId, this.valId}) : super(key: key);

  @override
  State<ServiceConfirmedScreen> createState() => _ServiceConfirmedScreenState();
}

class _ServiceConfirmedScreenState extends State<ServiceConfirmedScreen> {
  bool _isDownloading = false;

  @override
  void initState() {
    super.initState();
    print("--------------------------------------${widget.valId}");
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = Provider.of<GetServiceConfirmationDetailsViewModel>(context, listen: false);
      viewModel.fetchGetServiceDataApi(widget.trackingId!);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.containerBackground(context),
      body: SafeArea(
        child: ResPonsiveUi(mobile: _body(), desktop: _body(), tablet: _body()),
      ),
    );
  }

  Widget _body() {
    return Column(
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(height: 60, child: AppBarHeader("Booking Confirmation")),
        ),
        Expanded(
          child: Consumer<GetServiceConfirmationDetailsViewModel>(
            builder: (context, viewModel, _) {
              final status = viewModel.getServiceData.status;

              if (status == Status.LOADING) {
                return Center(child: LoadingAnimationWidget.progressiveDots(color: AppColors.button(context), size: 50));
              }

              if (status == Status.ERROR) {
                return ErrorStateWidget(
                  // errorMessage: viewModel.getServiceData.message.toString(),
                  errorMessage: 'Failed to load booking details',
                  onRetry: () {
                    viewModel.fetchGetServiceDataApi(widget.trackingId!);
                  },
                );
              }

              final bookingData = viewModel.getServiceData.data?.data;
              if (bookingData == null) {
                return Center(child: Text('No booking data available', style: AppTextStyles.textSize16(context)));
              }

              // Prepare service items
              List<ServiceItem> services = [];
              if (bookingData.bookingItems != null && bookingData.bookingItems!.isNotEmpty) {
                for (var item in bookingData.bookingItems!) {
                  if (item.task?.name != null) {
                    String additionalInfo = '';
                    additionalInfo = '(${item.quantity})';
                    services.add(ServiceItem(name: item.task!.name!, additionalInfo: additionalInfo.isEmpty ? null : additionalInfo));
                  }
                }
              }

              // Create confirmation data
              final confirmationData = BookingConfirmationData(
                thankYouMessage: "Thank you for choosing our beauty and salon service. We've received your order.",
                orderId: bookingData.trackingId ?? 'N/A',
                services: services,
                dateTime: '${DateFormatter.formatDate(bookingData.date)}, ${bookingData.timeSlotSnapshot?.timeLabel ?? bookingData.time ?? 'N/A'}',
                serviceAddress: bookingData.fullAddress ?? 'N/A',
                grandTotal: AmountFormatter.formatDynamic(bookingData.grandTotal),
                paymentMethod: bookingData.paymentType ?? 'N/A',
                onDownloadReceipt: () => _handleDownloadReceipt(),
                onTrackOrder: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => NavigationScreen(initialIndex: 2)));
                },
                isDownloading: _isDownloading,
              );

              return BookingConfirmationUI(
                data: confirmationData,
                onBackToHome: () {
                  Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => NavigationScreen(initialIndex: 0)), (route) => false);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  // KEY FIX: Fetch bookingData directly from Provider inside the function
  Future<void> _handleDownloadReceipt() async {
    // Get bookingData from Provider with correct type - THIS IS THE KEY!
    final bookingData = Provider.of<GetServiceConfirmationDetailsViewModel>(context, listen: false).getServiceData.data?.data;

    if (bookingData == null) {
      Utils.flushBarErrorMessage("No booking data available to download", context);
      return;
    }

    setState(() {
      _isDownloading = true;
    });

    try {
      if (Platform.isAndroid) {
        try {
          final androidInfo = await DeviceInfoPlugin().androidInfo;
          final sdkInt = androidInfo.version.sdkInt;

          if (sdkInt <= 32) {
            final status = await Permission.storage.request();
            if (!status.isGranted) {
              Utils.flushBarErrorMessage("Storage permission is required to download receipt", context);
              setState(() {
                _isDownloading = false;
              });
              return;
            }
          }
        } catch (e) {
          print('❌ Permission check error: $e');
        }
      }

      // For beauty salon - call toReceiptData() on the correctly typed bookingData
      final file = await PDFReceiptGenerator.generateAndDownloadPDFReceipt(bookingData!.toReceiptData());

      setState(() {
        _isDownloading = false;
      });

      if (file != null) {
        Utils.flushBarSuccessMessage("Receipt saved successfully!", context);
        _showDownloadSuccessDialog(file.path);
      } else {
        Utils.flushBarErrorMessage("Failed to generate receipt", context);
      }
    } catch (e) {
      setState(() {
        _isDownloading = false;
      });
      print('❌ PDF Generation Error: $e');
      Utils.flushBarErrorMessage("Error: ${e.toString()}", context);
    }
  }

  void _handleTrackOrder() {
    print('Navigate to track order screen');
  }

  void _showDownloadSuccessDialog(String filePath) {
    final screenWidth = MediaQuery.of(context).size.width;

    showDialog(
      context: context,
      barrierColor: AppColors.showDialougeBackground(context),
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.containerBackground(context),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Text('Download Complete', style: AppTextStyles.textSize18(context, weight: FontWeight.w600)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Receipt saved successfully!', style: AppTextStyles.textSize14(context)),
              SizedBox(height: 12),
              Container(
                width: screenWidth,
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(color: AppColors.button(context).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '📁 Location:',
                      style: AppTextStyles.textSize12(context, weight: FontWeight.w600, color: AppColors.button(context)),
                    ),
                    SizedBox(height: 4),
                    Text('Downloads/Dinmajur Booking', style: AppTextStyles.textSize12(context)),
                  ],
                ),
              ),
              SizedBox(height: 12),
              Text('Would you like to open it now?', style: AppTextStyles.textSize14(context)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Later', style: TextStyle(color: Colors.grey[600])),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await OpenFile.open(filePath);
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.button(context)),
              child: Text(
                'Open Now',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return DateFormat('dd MMM yyyy').format(date);
  }

  String _formatTo12Hour(String time) {
    if (time.isEmpty) return time;
    try {
      final parts = time.split(':');
      int hour = int.parse(parts[0]);
      final String minute = parts.length > 1 ? parts[1] : '00';
      final String period = hour >= 12 ? 'PM' : 'AM';
      if (hour == 0)
        hour = 12;
      else if (hour > 12)
        hour -= 12;
      return '$hour:$minute $period';
    } catch (_) {
      return time;
    }
  }
}
