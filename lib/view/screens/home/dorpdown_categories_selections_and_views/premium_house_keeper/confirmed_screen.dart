// import 'dart:io';
// import 'package:device_info_plus/device_info_plus.dart';
// import 'package:dinmajur_customer/configs/res/color.dart';
// import 'package:dinmajur_customer/configs/res/components/header_appbar.dart';
// import 'package:dinmajur_customer/configs/res/components/pdf_reciept_generator_auto_open_download/get_booking_confirmation_pdf_generator.dart';
// import 'package:dinmajur_customer/configs/res/sizedbox_spaccing.dart';
// import 'package:dinmajur_customer/configs/res/text_styles.dart';
// import 'package:dinmajur_customer/configs/responsive/responsive_ui.dart';
// import 'package:dinmajur_customer/configs/utils/utils.dart';
// import 'package:dinmajur_customer/data/response/status.dart';
// import 'package:dinmajur_customer/view/navigation_bar.dart';
// import 'package:dinmajur_customer/view_model/homeview_model/dropdown_categories_selection_view_models/premium_house_keeper_view_model/get_confirmedbooking_view_model.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:loading_animation_widget/loading_animation_widget.dart';
// import 'package:open_file/open_file.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:provider/provider.dart';
//
// class ConfirmedScreen extends StatefulWidget {
//   final String trackingId;
//   final String valId;
//   const ConfirmedScreen({Key? key,
//     required this.trackingId,
//     required this.valId,
//   }) : super(key: key);
//
//   @override
//   State<ConfirmedScreen> createState() => _ConfirmedScreenState();
// }
//
// class _ConfirmedScreenState extends State<ConfirmedScreen> {
//   bool _isDownloading = false;
//
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       final getConfirmedbookingViewModel = Provider.of<GetConfirmedbookingViewModel>(context, listen: false);
//       getConfirmedbookingViewModel.fetchGetConfirmBookingDataApi(widget.trackingId);
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.containerBackground(context),
//       body: SafeArea(child: ResPonsiveUi(mobile: _body(), desktop: _body(), tablet: _body())),
//     );
//   }
//
//   Widget _body() {
//     final screenWidth = MediaQuery.of(context).size.width;
//     final screenHeight = MediaQuery.of(context).size.height;
//
//     return Column(
//       children: [
//         GestureDetector(
//           onTap: () {
//             Navigator.pop(context);
//
//             // Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => NavigationScreen(initialIndex: 0)), (route) => false);
//           },
//           child: Container(height: 60, child: AppBarHeader("Booking Confirmation")),
//         ),
//         Expanded(
//           child: Consumer<GetConfirmedbookingViewModel>(
//             builder: (context, viewModel, _) {
//               final status = viewModel.getConfirmBookingData.status;
//
//               // Loading State
//               if (status == Status.LOADING) {
//                 return Center(child: LoadingAnimationWidget.progressiveDots(color: AppColors.button(context), size: 50));
//               }
//
//               // Error State
//               if (status == Status.ERROR) {
//                 return Center(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Icon(Icons.error_outline, size: 48, color: Colors.red),
//                       SizedBox(height: 16),
//                       Text('Failed to load booking details', style: AppTextStyles.textSize16(context, color: Colors.red)),
//                       SizedBox(height: 16),
//                       ElevatedButton(
//                         onPressed: () {
//                           viewModel.fetchGetConfirmBookingDataApi(widget.trackingId);
//                         },
//                         child: Text('Retry'),
//                         style: ElevatedButton.styleFrom(backgroundColor: AppColors.button(context)),
//                       ),
//                     ],
//                   ),
//                 );
//               }
//
//               // Success State
//               final bookingData = viewModel.getConfirmBookingData.data?.data;
//               if (bookingData == null) {
//                 return Center(child: Text('No booking data available', style: AppTextStyles.textSize16(context)));
//               }
//
//               return SingleChildScrollView(
//                 child: Column(
//                   children: [
//                     SizedboxSpaccing.height02(context),
//
//                     Container(
//                       width: screenWidth * 0.9,
//                       padding: EdgeInsets.all(screenHeight * 0.02),
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(24),
//                         border: Border.all(width: 1, color: AppColors.border(context)),
//                       ),
//                       child: Column(
//                         children: [
//                           // Success Icon
//                           Container(
//                             width: 40,
//                             height: 40,
//                             decoration: BoxDecoration(color: AppColors.button(context).withOpacity(0.2), shape: BoxShape.circle),
//                             child: Center(
//                               child: Container(
//                                 width: 25,
//                                 height: 25,
//                                 decoration: BoxDecoration(color: AppColors.button(context), shape: BoxShape.circle),
//                                 child: Icon(Icons.check, color: Colors.white, size: 16),
//                               ),
//                             ),
//                           ),
//
//                           SizedboxSpaccing.height01(context),
//
//                           // Title
//                           Text(
//                             'Your Booking is Confirmed!',
//                             style: AppTextStyles.textSize20(context, weight: FontWeight.w700),
//                             textAlign: TextAlign.center,
//                           ),
//
//                           SizedboxSpaccing.height01(context),
//
//                           // Subtitle
//                           Container(
//                             width: screenWidth * 0.85,
//                             child: Text(
//                               "Thank you for choosing our premium house keeping service. We've received your order.",
//                               style: AppTextStyles.textSize14(context, color: AppColors.subtitle(context)),
//                               textAlign: TextAlign.center,
//                             ),
//                           ),
//
//                           // SizedboxSpaccing.height015(context),
//                           //
//                           // // Order ID
//                           // Text(
//                           //   'Order ID: ${bookingData.trackingId ?? 'N/A'}',
//                           //   style: AppTextStyles.textSize14(context, weight: FontWeight.w500),
//                           // ),
//                         ],
//                       ),
//                     ),
//
//                     SizedboxSpaccing.height03(context),
//                     Container(
//                       width: screenWidth * 0.9,
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text('Booking Details', style: AppTextStyles.textSize18(context, weight: FontWeight.w500)),
//                           SizedboxSpaccing.height01(context),
//                           Divider(height: 1, color: AppColors.border(context)),
//                         ],
//                       ),
//                     ),
//                     SizedboxSpaccing.height02(context),
//                     // Booking Details Card
//                     Container(
//                       width: screenWidth * 0.9,
//                       padding: EdgeInsets.all(screenHeight * 0.02),
//                       decoration: BoxDecoration(
//                         color: AppColors.containerBackground(context),
//                         borderRadius: BorderRadius.circular(16),
//                         border: Border.all(color: AppColors.border(context)),
//                       ),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           _buildDetailRow('Customer Name', bookingData.fullName ?? 'N/A', context),
//                           SizedboxSpaccing.height01(context),
//                           _buildDetailRow('Plan Type', bookingData.serviceType ?? 'Premium Cleaning', context),
//                           SizedboxSpaccing.height01(context),
//                           _buildDetailRow('Subtotal Amount', 'BDT ${(bookingData.subTotal ?? 0).toStringAsFixed(2)}', context),
//                           SizedboxSpaccing.height01(context),
//                           _buildDetailRow('Transportation Fee', 'BDT ${(bookingData.fare ?? 0).toStringAsFixed(2)}', context),
//                           SizedboxSpaccing.height01(context),
//                           _buildDetailRow('Total', 'BDT ${(bookingData.grandTotal ?? 0).toStringAsFixed(2)}', context),
//                           SizedboxSpaccing.height01(context),
//                           _buildDetailRow('Phone Number', bookingData.phone ?? 'N/A', context),
//                           SizedboxSpaccing.height01(context),
//                           _buildDetailRow('Service Address', bookingData.fullAddress ?? 'N/A', context, isLongText: true),
//                           SizedboxSpaccing.height01(context),
//
//                           _buildDetailRow('House Size', bookingData.houseSize ?? 'N/A', context),
//                         ],
//                       ),
//                     ),
//
//                     SizedboxSpaccing.height02(context),
//                     Container(
//                       width: screenWidth * 0.9,
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text('Your Order Schedule', style: AppTextStyles.textSize18(context, weight: FontWeight.w500)),
//                           SizedboxSpaccing.height01(context),
//                           Divider(height: 1, color: AppColors.border(context)),
//                           SizedboxSpaccing.height02(context),
//                           Row(
//                             children: [
//                               Icon(Icons.calendar_today, size: 16, color: AppColors.subtitle(context)),
//                               SizedBox(width: 8),
//                               Text(_formatDate(bookingData.createdAt), style: AppTextStyles.textSize14(context, weight: FontWeight.w500)),
//                             ],
//                           ),
//                           SizedboxSpaccing.height01(context),
//
//                           // Time
//                           if (bookingData.shiftId != null)
//                             Row(
//                               children: [
//                                 Icon(Icons.access_time, size: 16, color: AppColors.subtitle(context)),
//                                 SizedBox(width: 8),
//                                 Text(
//                                   '${bookingData.shiftId!.type ?? ''} (${bookingData.shiftId!.startTime ?? ''} - ${bookingData.shiftId!.endTime ?? ''})',
//                                   style: AppTextStyles.textSize14(context, weight: FontWeight.w500),
//                                 ),
//                               ],
//                             ),
//                         ],
//                       ),
//                     ),
//
//                     SizedboxSpaccing.height02(context),
//
//                     // Your Order Schedule Card
//                     Container(
//                       width: screenWidth * 0.9,
//                       padding: EdgeInsets.all(screenHeight * 0.02),
//                       decoration: BoxDecoration(
//                         color: AppColors.containerBackground(context),
//                         borderRadius: BorderRadius.circular(16),
//                         border: Border.all(color: AppColors.border(context)),
//                       ),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           // Booking Items
//                           if (bookingData.houseKeeperBookingItems != null && bookingData.houseKeeperBookingItems!.isNotEmpty)
//                             ...bookingData.houseKeeperBookingItems!.map((item) {
//                               return Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Row(
//                                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                     children: [
//                                       Expanded(
//                                         child: Text(item.houseKeeperTaskId?.name ?? 'Service', style: AppTextStyles.textSize16(context, weight: FontWeight.w600)),
//                                       ),
//                                       if (item.totalRooms != null && item.totalRooms! > 0)
//                                         Text(
//                                           'Rooms: ${item.totalRooms}',
//                                           style: AppTextStyles.textSize14(context, weight: FontWeight.w500, color: AppColors.button(context)),
//                                         ),
//                                     ],
//                                   ),
//
//                                   if (item.houseKeeperTaskItemIds != null && item.houseKeeperTaskItemIds!.isNotEmpty) ...[
//                                     SizedboxSpaccing.height01(context),
//                                     ...item.houseKeeperTaskItemIds!.map((taskItem) {
//                                       return Padding(
//                                         padding: EdgeInsets.only(bottom: 4, left: 8),
//                                         child: Row(
//                                           crossAxisAlignment: CrossAxisAlignment.start,
//                                           children: [
//                                             Text('• ', style: AppTextStyles.textSize14(context)),
//                                             Expanded(
//                                               child: Text(taskItem.name ?? '', style: AppTextStyles.textSize12(context, color: AppColors.textPrimary(context))),
//                                             ),
//                                           ],
//                                         ),
//                                       );
//                                     }).toList(),
//                                   ],
//                                 ],
//                               );
//                             }).toList(),
//                         ],
//                       ),
//                     ),
//
//                     SizedboxSpaccing.height03(context),
//
//                     // Back to Home Button
//                     GestureDetector(
//                       onTap: () {
//                         Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => NavigationScreen(initialIndex: 0)), (route) => false);
//                       },
//                       child: Container(
//                         width: screenWidth * 0.9,
//                         height: 50,
//                         decoration: BoxDecoration(color: AppColors.button(context), borderRadius: BorderRadius.circular(12)),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Icon(Icons.home, color: Colors.white, size: 20),
//                             SizedBox(width: 8),
//                             Text(
//                               'Back to Home',
//                               style: AppTextStyles.textSize16(context, weight: FontWeight.w600, color: Colors.white),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//
//                     SizedboxSpaccing.height02(context),
//
//                     // GestureDetector(
//                     //   onTap: () async {
//                     //     final bookingData = Provider.of<GetConfirmedbookingViewModel>(context, listen: false)
//                     //         .getConfirmBookingData.data?.data;
//                     //
//                     //     if (bookingData == null) {
//                     //       Utils.flushBarErrorMessage("No booking data available to download", context);
//                     //       return;
//                     //     }
//                     //
//                     //     setState(() {
//                     //       _isDownloading = true;
//                     //     });
//                     //
//                     //     try {
//                     //       // Request storage permission for Android
//                     //       if (Platform.isAndroid) {
//                     //         // For Android 13+ (API 33+), no storage permission needed for Downloads
//                     //         // For Android 11-12 (API 30-32), use manageExternalStorage
//                     //         // For Android 10 and below, use storage permission
//                     //
//                     //         bool hasPermission = false;
//                     //
//                     //         // Try to check Android version
//                     //         try {
//                     //           final androidInfo = await DeviceInfoPlugin().androidInfo;
//                     //           final sdkInt = androidInfo.version.sdkInt;
//                     //
//                     //           if (sdkInt >= 33) {
//                     //             // Android 13+: No permission needed
//                     //             hasPermission = true;
//                     //           } else if (sdkInt >= 30) {
//                     //             // Android 11-12: Request MANAGE_EXTERNAL_STORAGE
//                     //             final status = await Permission.manageExternalStorage.request();
//                     //             hasPermission = status.isGranted;
//                     //
//                     //             if (!status.isGranted) {
//                     //               // Show settings dialog
//                     //               showDialog(
//                     //                 context: context,
//                     //                             barrierColor: AppColors.showDialougeBackground(context),
//                     //                 builder: (context) => AlertDialog(
//                     //                            backgroundColor: AppColors.containerBackground(context),
//                     //                   title: Text('Storage Permission Required'),
//                     //                   content: Text('Please grant storage permission in settings to save receipts.'),
//                     //                   actions: [
//                     //                     TextButton(
//                     //                       onPressed: () => Navigator.pop(context),
//                     //                       child: Text('Cancel'),
//                     //                     ),
//                     //                     ElevatedButton(
//                     //                       onPressed: () async {
//                     //                         Navigator.pop(context);
//                     //                         await openAppSettings();
//                     //                       },
//                     //                       child: Text('Open Settings'),
//                     //                     ),
//                     //                   ],
//                     //                 ),
//                     //               );
//                     //             }
//                     //           } else {
//                     //             // Android 10 and below: Use regular storage permission
//                     //             final status = await Permission.storage.request();
//                     //             hasPermission = status.isGranted;
//                     //           }
//                     //         } catch (e) {
//                     //           // Fallback: just try storage permission
//                     //           final status = await Permission.storage.request();
//                     //           hasPermission = status.isGranted;
//                     //         }
//                     //
//                     //         if (!hasPermission) {
//                     //           Utils.flushBarErrorMessage("Storage permission is required to download receipt", context);
//                     //           setState(() {
//                     //             _isDownloading = false;
//                     //           });
//                     //           return;
//                     //         }
//                     //       }
//                     //
//                     //       // Generate and save PDF
//                     //       final file = await BookingReceiptPdfGenerator.generateAndDownloadReceipt(bookingData);
//                     //
//                     //       setState(() {
//                     //         _isDownloading = false;
//                     //       });
//                     //
//                     //       if (file != null) {
//                     //         // Extract filename
//                     //         final fileName = file.path.split('/').last;
//                     //
//                     //         // Show success message
//                     //         Utils.flushBarSuccessMessage("Receipt saved successfully!", context);
//                     //
//                     //         // Show dialog with option to open
//                     //         showDialog(
//                     //           context: context,
//                     //           barrierColor: AppColors.showDialougeBackground(context),
//                     //           builder: (BuildContext context) {
//                     //             return AlertDialog(
//                     //               backgroundColor: AppColors.containerBackground(context),
//                     //               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                     //               title: Text(
//                     //                 'Download Complete',
//                     //                 style: AppTextStyles.textSize18(context, weight: FontWeight.w600),
//                     //               ),
//                     //               content: Column(
//                     //                 mainAxisSize: MainAxisSize.min,
//                     //                 crossAxisAlignment: CrossAxisAlignment.start,
//                     //                 children: [
//                     //                   Text(
//                     //                     'Receipt saved successfully!',
//                     //                     style: AppTextStyles.textSize14(context),
//                     //                   ),
//                     //                   SizedBox(height: 12),
//                     //                   Container(
//                     //                     width: screenWidth,
//                     //                     padding: EdgeInsets.all(8),
//                     //                     decoration: BoxDecoration(
//                     //                       color: AppColors.button(context).withOpacity(0.1),
//                     //                       borderRadius: BorderRadius.circular(8),
//                     //                     ),
//                     //                     child: Column(
//                     //                       crossAxisAlignment: CrossAxisAlignment.start,
//                     //                       children: [
//                     //                         Text(
//                     //                           '📁 Location:',
//                     //                           style: AppTextStyles.textSize12(
//                     //                             context,
//                     //                             weight: FontWeight.w600,
//                     //                             color: AppColors.button(context),
//                     //                           ),
//                     //                         ),
//                     //                         SizedBox(height: 4),
//                     //                         Text(
//                     //                           'Downloads/Dinmajur_Bookings',
//                     //                           style: AppTextStyles.textSize12(context),
//                     //                         ),
//                     //                       ],
//                     //                     ),
//                     //                   ),
//                     //                   SizedBox(height: 12),
//                     //                   Text(
//                     //                     'Would you like to open it now?',
//                     //                     style: AppTextStyles.textSize14(context),
//                     //                   ),
//                     //                 ],
//                     //               ),
//                     //               actions: [
//                     //                 TextButton(
//                     //                   onPressed: () => Navigator.of(context).pop(),
//                     //                   child: Text(
//                     //                     'Later',
//                     //                     style: TextStyle(color: Colors.grey[600]),
//                     //                   ),
//                     //                 ),
//                     //                 ElevatedButton(
//                     //                   onPressed: () async {
//                     //                     Navigator.of(context).pop();
//                     //                     await OpenFile.open(file.path);
//                     //                   },
//                     //                   style: ElevatedButton.styleFrom(
//                     //                     backgroundColor: AppColors.button(context),
//                     //                   ),
//                     //                   child: Text(
//                     //                     'Open Now',
//                     //                     style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
//                     //                   ),
//                     //                 ),
//                     //               ],
//                     //             );
//                     //           },
//                     //         );
//                     //       } else {
//                     //         Utils.flushBarErrorMessage("Failed to generate receipt", context);
//                     //       }
//                     //     } catch (e) {
//                     //       setState(() {
//                     //         _isDownloading = false;
//                     //       });
//                     //
//                     //       print('❌ PDF Generation Error: $e');
//                     //
//                     //       Utils.flushBarErrorMessage("Error: ${e.toString()}", context);
//                     //     }
//                     //   },
//                     //   child: Container(
//                     //     width: screenWidth * 0.9,
//                     //     height: 50,
//                     //     decoration: BoxDecoration(
//                     //       color: Colors.transparent,
//                     //       borderRadius: BorderRadius.circular(12),
//                     //       border: Border.all(color: AppColors.button(context), width: 1),
//                     //     ),
//                     //     child: _isDownloading
//                     //         ? Center(child: LoadingAnimationWidget.progressiveDots(
//                     //         color: AppColors.button(context),
//                     //         size: 50
//                     //     ))
//                     //         : Row(
//                     //       mainAxisAlignment: MainAxisAlignment.center,
//                     //       children: [
//                     //         Icon(Icons.download, color: AppColors.button(context), size: 20),
//                     //         SizedBox(width: 8),
//                     //         Text(
//                     //           'Download Receipt',
//                     //           style: AppTextStyles.textSize16(
//                     //             context,
//                     //             weight: FontWeight.w600,
//                     //             color: AppColors.button(context),
//                     //           ),
//                     //         ),
//                     //       ],
//                     //     ),
//                     //   ),
//                     // ),
//                     GestureDetector(
//                       onTap: () async {
//                         final bookingData = Provider.of<GetConfirmedbookingViewModel>(context, listen: false)
//                             .getConfirmBookingData.data?.data;
//
//                         if (bookingData == null) {
//                           Utils.flushBarErrorMessage("No booking data available to download", context);
//                           return;
//                         }
//
//                         setState(() {
//                           _isDownloading = true;
//                         });
//
//                         try {
//                           // Handle permissions based on Android version
//                           if (Platform.isAndroid) {
//                             try {
//                               final androidInfo = await DeviceInfoPlugin().androidInfo;
//                               final sdkInt = androidInfo.version.sdkInt;
//
//                               // Only request permission for Android 12 and below (API ≤ 32)
//                               if (sdkInt <= 32) {
//                                 final status = await Permission.storage.request();
//
//                                 if (!status.isGranted) {
//                                   Utils.flushBarErrorMessage("Storage permission is required to download receipt", context);
//                                   setState(() {
//                                     _isDownloading = false;
//                                   });
//                                   return;
//                                 }
//                               }
//                               // Android 13+ (API 33+): No permission needed
//                             } catch (e) {
//                               print('❌ Permission check error: $e');
//                               // Try to proceed anyway
//                             }
//                           }
//
//                           // Generate and save PDF
//                           final file = await BookingReceiptPdfGenerator.generateAndDownloadReceipt(bookingData);
//
//                           setState(() {
//                             _isDownloading = false;
//                           });
//
//                           if (file != null) {
//                             // Show success message
//                             Utils.flushBarSuccessMessage("Receipt saved successfully!", context);
//
//                             // Show dialog with option to open
//                             showDialog(
//                               context: context,
//                               barrierColor: AppColors.showDialougeBackground(context),
//                               builder: (BuildContext context) {
//                                 return AlertDialog(
//                                   backgroundColor: AppColors.containerBackground(context),
//                                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                                   title: Text(
//                                     'Download Complete',
//                                     style: AppTextStyles.textSize18(context, weight: FontWeight.w600),
//                                   ),
//                                   content: Column(
//                                     mainAxisSize: MainAxisSize.min,
//                                     crossAxisAlignment: CrossAxisAlignment.start,
//                                     children: [
//                                       Text(
//                                         'Receipt saved successfully!',
//                                         style: AppTextStyles.textSize14(context),
//                                       ),
//                                       SizedBox(height: 12),
//                                       Container(
//                                         width: screenWidth,
//                                         padding: EdgeInsets.all(8),
//                                         decoration: BoxDecoration(
//                                           color: AppColors.button(context).withOpacity(0.1),
//                                           borderRadius: BorderRadius.circular(8),
//                                         ),
//                                         child: Column(
//                                           crossAxisAlignment: CrossAxisAlignment.start,
//                                           children: [
//                                             Text(
//                                               '📁 Location:',
//                                               style: AppTextStyles.textSize12(
//                                                 context,
//                                                 weight: FontWeight.w600,
//                                                 color: AppColors.button(context),
//                                               ),
//                                             ),
//                                             SizedBox(height: 4),
//                                             Text(
//                                               'Downloads/Dinmajur_Bookings',
//                                               style: AppTextStyles.textSize12(context),
//                                             ),
//                                           ],
//                                         ),
//                                       ),
//                                       SizedBox(height: 12),
//                                       Text(
//                                         'Would you like to open it now?',
//                                         style: AppTextStyles.textSize14(context),
//                                       ),
//                                     ],
//                                   ),
//                                   actions: [
//                                     TextButton(
//                                       onPressed: () => Navigator.of(context).pop(),
//                                       child: Text(
//                                         'Later',
//                                         style: TextStyle(color: Colors.grey[600]),
//                                       ),
//                                     ),
//                                     ElevatedButton(
//                                       onPressed: () async {
//                                         Navigator.of(context).pop();
//                                         await OpenFile.open(file.path);
//                                       },
//                                       style: ElevatedButton.styleFrom(
//                                         backgroundColor: AppColors.button(context),
//                                       ),
//                                       child: Text(
//                                         'Open Now',
//                                         style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
//                                       ),
//                                     ),
//                                   ],
//                                 );
//                               },
//                             );
//                           } else {
//                             Utils.flushBarErrorMessage("Failed to generate receipt", context);
//                           }
//                         } catch (e) {
//                           setState(() {
//                             _isDownloading = false;
//                           });
//
//                           print('❌ PDF Generation Error: $e');
//                           Utils.flushBarErrorMessage("Error: ${e.toString()}", context);
//                         }
//                       },
//                       child: Container(
//                         width: screenWidth * 0.9,
//                         height: 50,
//                         decoration: BoxDecoration(
//                           color: Colors.transparent,
//                           borderRadius: BorderRadius.circular(12),
//                           border: Border.all(color: AppColors.button(context), width: 1),
//                         ),
//                         child: _isDownloading
//                             ? Center(child: LoadingAnimationWidget.progressiveDots(
//                             color: AppColors.button(context),
//                             size: 50
//                         ))
//                             : Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Icon(Icons.download, color: AppColors.button(context), size: 20),
//                             SizedBox(width: 8),
//                             Text(
//                               'Download Receipt',
//                               style: AppTextStyles.textSize16(
//                                 context,
//                                 weight: FontWeight.w600,
//                                 color: AppColors.button(context),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                     SizedboxSpaccing.height02(context),
//
//                     // Customer Care Section
//                     Container(
//                       width: screenWidth * 0.9,
//                       padding: EdgeInsets.all(screenHeight*.02),
//                       decoration: BoxDecoration(
//                         color: AppColors.containerBackground(context),
//                         borderRadius: BorderRadius.circular(12),
//                         border: Border.all(width: 1,color: AppColors.border(context)),
//                       ),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Container(
//                             height: 48,
//                             width: 48,
//                             decoration: BoxDecoration(color: AppColors.textPrimary(context), shape: BoxShape.circle),
//                             child: Icon(Icons.headset_mic, color: Colors.white, size: 24),
//                           ),
//                           SizedboxSpaccing.width03(context),
//                           SizedboxSpaccing.width01(context),
//                           Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text('Customer Care Hotline', style: AppTextStyles.textSize18(context, weight: FontWeight.w500)),
//                               SizedboxSpaccing.height005(context),
//                               Text('Available 24/7 for your assistance', style: AppTextStyles.textSize14(context, color: AppColors.subtitle(context))),
//                               SizedboxSpaccing.height005(context),
//                               Text('01929600600', style: AppTextStyles.textSize24(context, weight: FontWeight.w600, color: AppColors.button(context)),),
//                             ],
//                           ),
//
//                         ],
//                       ),
//                     ),
//
//                     SizedboxSpaccing.height03(context),
//                   ],
//                 ),
//               );
//             },
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildDetailRow(String label, String value, BuildContext context, {bool isLongText = false}) {
//     return isLongText
//         ? Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(label, style: AppTextStyles.textSize14(context, color: AppColors.textPrimary(context), weight: FontWeight.w500)),
//         SizedboxSpaccing.height01(context),
//         Text(value, style: AppTextStyles.textSize12(context, weight: FontWeight.w400)),
//       ],
//     )
//         : Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(label, style: AppTextStyles.textSize14(context, color: AppColors.textPrimary(context), weight: FontWeight.w500)),
//         SizedBox(width: 8),
//         Expanded(
//           child: Text(
//             value,
//             style: AppTextStyles.textSize12(context, weight: FontWeight.w400),
//             textAlign: TextAlign.right,
//           ),
//         ),
//       ],
//     );
//   }
//
//   String _formatDate(DateTime? date) {
//     if (date == null) return 'N/A';
//     return DateFormat('dd-MM-yyyy').format(date);
//   }
// }
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/components/header_appbar.dart';
import 'package:dinmajur_customer/configs/res/components/pdf_reciept_generator_auto_open_download/get_booking_confirmation_pdf_generator.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:dinmajur_customer/configs/responsive/responsive_ui.dart';
import 'package:dinmajur_customer/configs/utils/utils.dart';
import 'package:dinmajur_customer/data/response/status.dart';
import 'package:dinmajur_customer/view/navigation_bar.dart';
import 'package:dinmajur_customer/view/screens/home/helper_widgets/dropdown_categories_widget/confirmation_widget.dart';
import 'package:dinmajur_customer/view_model/homeview_model/dropdown_categories_selection_view_models/premium_house_keeper_view_model/get_confirmedbooking_view_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class ConfirmedScreen extends StatefulWidget {
  final String trackingId;
  final String valId;
  const ConfirmedScreen({
    Key? key,
    required this.trackingId,
    required this.valId,
  }) : super(key: key);

  @override
  State<ConfirmedScreen> createState() => _ConfirmedScreenState();
}

class _ConfirmedScreenState extends State<ConfirmedScreen> {
  bool _isDownloading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = Provider.of<GetConfirmedbookingViewModel>(context, listen: false);
      viewModel.fetchGetConfirmBookingDataApi(widget.trackingId);
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
            child: AppBarHeader("Booking Confirmation"),
          ),
        ),
        Expanded(
          child: Consumer<GetConfirmedbookingViewModel>(
            builder: (context, viewModel, _) {
              final status = viewModel.getConfirmBookingData.status;

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
                          viewModel.fetchGetConfirmBookingDataApi(widget.trackingId);
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

              final bookingData = viewModel.getConfirmBookingData.data?.data;
              if (bookingData == null) {
                return Center(
                  child: Text(
                    'No booking data available',
                    style: AppTextStyles.textSize16(context),
                  ),
                );
              }

              // Prepare service items for housekeeping
              List<ServiceItem> services = [];
              if (bookingData.houseKeeperBookingItems != null &&
                  bookingData.houseKeeperBookingItems!.isNotEmpty) {
                services = bookingData.houseKeeperBookingItems!.map((item) {
                  String additionalInfo = '';
                  if (item.totalRooms != null && item.totalRooms! > 0) {
                    additionalInfo = '(${item.totalRooms})';
                  }
                  return ServiceItem(
                    name: item.houseKeeperTaskId?.name ?? 'Service',
                    additionalInfo: additionalInfo.isEmpty ? null : additionalInfo,
                  );
                }).toList();
              }

              // Create confirmation data
              final confirmationData = BookingConfirmationData(
                thankYouMessage:
                "Thank you for choosing our premium house keeping service. We've received your order.",
                orderId: bookingData.id ?? 'N/A',
                services: services,
                dateTime:
                '${_formatDate(bookingData.createdAt)},(${bookingData.shiftId?.startTime ?? ''} - ${bookingData.shiftId?.endTime ?? ''})',
                serviceAddress: bookingData.fullAddress ?? 'N/A',
                grandTotal: (bookingData.grandTotal ?? 0).toStringAsFixed(2),
                paymentMethod: bookingData.paymentType ?? 'N/A',
                onDownloadReceipt: () => _handleDownloadReceipt(),
                onTrackOrder: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>NavigationScreen(initialIndex: 2,)));
                },
                isDownloading: _isDownloading,
              );

              return BookingConfirmationUI(
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

  // KEY FIX: Fetch bookingData directly from Provider inside the function
  Future<void> _handleDownloadReceipt() async {
    // Get bookingData from Provider with correct type
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
      if (Platform.isAndroid) {
        try {
          final androidInfo = await DeviceInfoPlugin().androidInfo;
          final sdkInt = androidInfo.version.sdkInt;

          if (sdkInt <= 32) {
            final status = await Permission.storage.request();
            if (!status.isGranted) {
              Utils.flushBarErrorMessage(
                "Storage permission is required to download receipt",
                context,
              );
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

      // For housekeeping - pass bookingData directly
      final file = await BookingReceiptPdfGenerator.generateAndDownloadReceipt(
        bookingData,
      );

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
          title: Text(
            'Download Complete',
            style: AppTextStyles.textSize18(context, weight: FontWeight.w600),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Receipt saved successfully!',
                style: AppTextStyles.textSize14(context),
              ),
              SizedBox(height: 12),
              Container(
                width: screenWidth,
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.button(context).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '📁 Location:',
                      style: AppTextStyles.textSize12(
                        context,
                        weight: FontWeight.w600,
                        color: AppColors.button(context),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Downloads/Dinmajur_Bookings',
                      style: AppTextStyles.textSize12(context),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 12),
              Text(
                'Would you like to open it now?',
                style: AppTextStyles.textSize14(context),
              ),
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
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.button(context),
              ),
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
    return DateFormat('dd-MM-yyyy').format(date);
  }
}

