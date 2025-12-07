import 'dart:io';
import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/components/header_appbar.dart';
import 'package:dinmajur_customer/configs/res/components/pdf_reciept_generator_auto_open_download/get_booking_confirmation_pdf_generator.dart';
import 'package:dinmajur_customer/configs/res/sizedbox_spaccing.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:dinmajur_customer/configs/utils/utils.dart';
import 'package:dinmajur_customer/data/response/status.dart';
import 'package:dinmajur_customer/view/navigation_bar.dart';
import 'package:dinmajur_customer/view_model/homeview_model/dropdown_categories_selection_view_models/premium_house_keeper_view_model/get_confirmedbooking_view_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class ConfirmedScreen extends StatefulWidget {
  final String trackingId;
  const ConfirmedScreen({Key? key, required this.trackingId}) : super(key: key);

  @override
  State<ConfirmedScreen> createState() => _ConfirmedScreenState();
}

class _ConfirmedScreenState extends State<ConfirmedScreen> {
  bool _isDownloading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final getConfirmedbookingViewModel = Provider.of<GetConfirmedbookingViewModel>(context, listen: false);
      getConfirmedbookingViewModel.fetchGetConfirmBookingDataApi(widget.trackingId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => NavigationScreen(initialIndex: 0)), (route) => false);
        return false;
      },
      child: Scaffold(
        backgroundColor: AppColors.containerBackground(context),
        body: SafeArea(child: _body()),
      ),
    );
  }

  Widget _body() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Column(
      children: [
        GestureDetector(
          onTap: () {
            Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => NavigationScreen(initialIndex: 0)), (route) => false);
          },
          child: Container(height: 60, child: AppBarHeader("Booking Confirmation")),
        ),
        Expanded(
          child: Consumer<GetConfirmedbookingViewModel>(
            builder: (context, viewModel, _) {
              final status = viewModel.getConfirmBookingData.status;

              // Loading State
              if (status == Status.LOADING) {
                return Center(child: LoadingAnimationWidget.progressiveDots(color: AppColors.button(context), size: 50));
              }

              // Error State
              if (status == Status.ERROR) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 48, color: Colors.red),
                      SizedBox(height: 16),
                      Text('Failed to load booking details', style: AppTextStyles.textSize16(context, color: Colors.red)),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          viewModel.fetchGetConfirmBookingDataApi(widget.trackingId);
                        },
                        child: Text('Retry'),
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.button(context)),
                      ),
                    ],
                  ),
                );
              }

              // Success State
              final bookingData = viewModel.getConfirmBookingData.data?.data;
              if (bookingData == null) {
                return Center(child: Text('No booking data available', style: AppTextStyles.textSize16(context)));
              }

              return SingleChildScrollView(
                child: Column(
                  children: [
                    SizedboxSpaccing.height02(context),

                    Container(
                      width: screenWidth * 0.9,
                      padding: EdgeInsets.all(screenHeight * 0.02),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(width: 1, color: AppColors.border(context)),
                      ),
                      child: Column(
                        children: [
                          // Success Icon
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(color: AppColors.button(context).withOpacity(0.2), shape: BoxShape.circle),
                            child: Center(
                              child: Container(
                                width: 25,
                                height: 25,
                                decoration: BoxDecoration(color: AppColors.button(context), shape: BoxShape.circle),
                                child: Icon(Icons.check, color: Colors.white, size: 16),
                              ),
                            ),
                          ),

                          SizedboxSpaccing.height02(context),

                          // Title
                          Text(
                            'Your Booking is Confirmed!',
                            style: AppTextStyles.textSize20(context, weight: FontWeight.w700),
                            textAlign: TextAlign.center,
                          ),

                          SizedboxSpaccing.height01(context),

                          // Subtitle
                          Container(
                            width: screenWidth * 0.85,
                            child: Text(
                              "Thank you for choosing our premium house keeping service. We've received your order.",
                              style: AppTextStyles.textSize14(context, color: AppColors.subtitle(context)),
                              textAlign: TextAlign.center,
                            ),
                          ),

                          // SizedboxSpaccing.height015(context),
                          //
                          // // Order ID
                          // Text(
                          //   'Order ID: ${bookingData.trackingId ?? 'N/A'}',
                          //   style: AppTextStyles.textSize14(context, weight: FontWeight.w500),
                          // ),
                        ],
                      ),
                    ),

                    SizedboxSpaccing.height03(context),
                    Container(
                      width: screenWidth * 0.9,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Booking Details', style: AppTextStyles.textSize18(context, weight: FontWeight.w500)),
                          SizedboxSpaccing.height01(context),
                          Divider(height: 1, color: AppColors.border(context)),
                        ],
                      ),
                    ),
                    SizedboxSpaccing.height02(context),
                    // Booking Details Card
                    Container(
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
                          _buildDetailRow('Customer Name', bookingData.fullName ?? 'N/A', context),
                          SizedboxSpaccing.height01(context),
                          _buildDetailRow('Plan Type', bookingData.serviceType ?? 'Premium Cleaning', context),
                          SizedboxSpaccing.height01(context),
                          _buildDetailRow('Subtotal Amount', 'BDT ${(bookingData.subTotal ?? 0).toStringAsFixed(2)}', context),
                          SizedboxSpaccing.height01(context),
                          _buildDetailRow('Transportation Fee', 'BDT ${(bookingData.fare ?? 0).toStringAsFixed(2)}', context),
                          SizedboxSpaccing.height01(context),
                          _buildDetailRow('Total', 'BDT ${(bookingData.grandTotal ?? 0).toStringAsFixed(2)}', context),
                          SizedboxSpaccing.height01(context),
                          _buildDetailRow('Phone Number', bookingData.phone ?? 'N/A', context),
                          SizedboxSpaccing.height01(context),
                          _buildDetailRow('Service Address', bookingData.fullAddress ?? 'N/A', context, isLongText: true),
                          SizedboxSpaccing.height01(context),

                          _buildDetailRow('House Size', bookingData.houseSize ?? 'N/A', context),
                        ],
                      ),
                    ),

                    SizedboxSpaccing.height02(context),
                    Container(
                      width: screenWidth * 0.9,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Your Order Schedule', style: AppTextStyles.textSize18(context, weight: FontWeight.w500)),
                          SizedboxSpaccing.height01(context),
                          Divider(height: 1, color: AppColors.border(context)),
                          SizedboxSpaccing.height02(context),
                          Row(
                            children: [
                              Icon(Icons.calendar_today, size: 16, color: AppColors.subtitle(context)),
                              SizedBox(width: 8),
                              Text(_formatDate(bookingData.createdAt), style: AppTextStyles.textSize14(context, weight: FontWeight.w500)),
                            ],
                          ),
                          SizedboxSpaccing.height01(context),

                          // Time
                          if (bookingData.shiftId != null)
                            Row(
                              children: [
                                Icon(Icons.access_time, size: 16, color: AppColors.subtitle(context)),
                                SizedBox(width: 8),
                                Text(
                                  '${bookingData.shiftId!.type ?? ''} (${bookingData.shiftId!.startTime ?? ''} - ${bookingData.shiftId!.endTime ?? ''})',
                                  style: AppTextStyles.textSize14(context, weight: FontWeight.w500),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),

                    SizedboxSpaccing.height02(context),

                    // Your Order Schedule Card
                    Container(
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
                          // Booking Items
                          if (bookingData.houseKeeperBookingItems != null && bookingData.houseKeeperBookingItems!.isNotEmpty)
                            ...bookingData.houseKeeperBookingItems!.map((item) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(item.houseKeeperTaskId?.name ?? 'Service', style: AppTextStyles.textSize16(context, weight: FontWeight.w600)),
                                      ),
                                      if (item.totalRooms != null && item.totalRooms! > 0)
                                        Text(
                                          'Rooms: ${item.totalRooms}',
                                          style: AppTextStyles.textSize14(context, weight: FontWeight.w500, color: AppColors.button(context)),
                                        ),
                                    ],
                                  ),

                                  if (item.houseKeeperTaskItemIds != null && item.houseKeeperTaskItemIds!.isNotEmpty) ...[
                                    SizedboxSpaccing.height01(context),
                                    ...item.houseKeeperTaskItemIds!.map((taskItem) {
                                      return Padding(
                                        padding: EdgeInsets.only(bottom: 4, left: 8),
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text('• ', style: AppTextStyles.textSize14(context)),
                                            Expanded(
                                              child: Text(taskItem.name ?? '', style: AppTextStyles.textSize12(context, color: AppColors.textPrimary(context))),
                                            ),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                  ],
                                ],
                              );
                            }).toList(),
                        ],
                      ),
                    ),

                    SizedboxSpaccing.height03(context),

                    // Back to Home Button
                    GestureDetector(
                      onTap: () {
                        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => NavigationScreen(initialIndex: 0)), (route) => false);
                      },
                      child: Container(
                        width: screenWidth * 0.9,
                        height: 50,
                        decoration: BoxDecoration(color: AppColors.button(context), borderRadius: BorderRadius.circular(12)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.home, color: Colors.white, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Back to Home',
                              style: AppTextStyles.textSize16(context, weight: FontWeight.w600, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedboxSpaccing.height02(context),

                    // Download Receipt Button (Optional)
                    GestureDetector(
                      onTap: () async {
                        final bookingData = Provider.of<GetConfirmedbookingViewModel>(context, listen: false)
                            .getConfirmBookingData.data?.data;

                        if (bookingData == null) {
                       Utils.flushBarErrorMessage("No booking data available to download", context);
                          return;
                        }

                        setState(() {
                          _isDownloading = true;
                        });

                        try {
                          // Request storage permission
                          if (Platform.isAndroid) {
                            final status = await Permission.storage.request();
                            if (!status.isGranted) {
                              Utils.flushBarErrorMessage("Storage permission is required to download receipt", context);
                              setState(() {
                                _isDownloading = false;
                              });
                              return;
                            }
                          }

                          // Generate and download PDF
                          final file = await BookingReceiptPdfGenerator.generateAndDownloadReceipt(bookingData);

                          setState(() {
                            _isDownloading = false;
                          });

                          if (file != null) {
                            Utils.flushBarSuccessMessage("Receipt downloaded successfully!", context);
                            await OpenFile.open(file.path);
                          } else {
                            Utils.flushBarErrorMessage("Failed to generate receipt", context);
                          }
                        } catch (e) {
                          setState(() {
                            _isDownloading = false;
                          });

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error: ${e.toString()}'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      child: Container(
                        width: screenWidth * 0.9,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.button(context), width: 1),
                        ),
                        child: _isDownloading
                            ? Center(child: LoadingAnimationWidget.progressiveDots(color: AppColors.button(context), size: 50))
                            : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.download, color: AppColors.button(context), size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Download Receipt',
                              style: AppTextStyles.textSize16(
                                context,
                                weight: FontWeight.w600,
                                color: AppColors.button(context),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedboxSpaccing.height02(context),

                    // Customer Care Section
                    Container(
                      width: screenWidth * 0.9,
                      padding: EdgeInsets.all(screenHeight*.02),
                      decoration: BoxDecoration(
                        color: AppColors.containerBackground(context),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(width: 1,color: AppColors.border(context)),
                      ),
                      child: Row(
                 mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 48,
                            width: 48,
                            decoration: BoxDecoration(color: AppColors.textPrimary(context), shape: BoxShape.circle),
                            child: Icon(Icons.headset_mic, color: Colors.white, size: 24),
                          ),
                          SizedboxSpaccing.width03(context),
                          SizedboxSpaccing.width01(context),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Customer Care Hotline', style: AppTextStyles.textSize18(context, weight: FontWeight.w500)),
                              SizedboxSpaccing.height005(context),
                              Text('Available 24/7 for your assistance', style: AppTextStyles.textSize14(context, color: AppColors.subtitle(context))),
                              SizedboxSpaccing.height005(context),
                              Text('01929600600', style: AppTextStyles.textSize24(context, weight: FontWeight.w600, color: AppColors.button(context)),),
                            ],
                          ),

                        ],
                      ),
                    ),

                    SizedboxSpaccing.height03(context),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, BuildContext context, {bool isLongText = false}) {
    return isLongText
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTextStyles.textSize14(context, color: AppColors.textPrimary(context), weight: FontWeight.w500)),
              SizedboxSpaccing.height01(context),
              Text(value, style: AppTextStyles.textSize12(context, weight: FontWeight.w400)),
            ],
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTextStyles.textSize14(context, color: AppColors.textPrimary(context), weight: FontWeight.w500)),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  value,
                  style: AppTextStyles.textSize12(context, weight: FontWeight.w400),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return DateFormat('dd-MM-yyyy').format(date);
  }
}
