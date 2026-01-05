// import 'dart:io';
// import 'package:device_info_plus/device_info_plus.dart';
// import 'package:dinmajur_customer/configs/res/color.dart';
// import 'package:dinmajur_customer/configs/res/components/header_appbar.dart';
// import 'package:dinmajur_customer/configs/res/components/pdf_reciept_generator_auto_open_download/pdf_generator.dart';
// import 'package:dinmajur_customer/configs/res/sizedbox_spaccing.dart';
// import 'package:dinmajur_customer/configs/res/text_styles.dart';
// import 'package:dinmajur_customer/configs/responsive/responsive_ui.dart';
// import 'package:dinmajur_customer/configs/utils/utils.dart';
// import 'package:dinmajur_customer/data/response/status.dart';
// import 'package:dinmajur_customer/view/navigation_bar.dart';
// import 'package:dinmajur_customer/view_model/homeview_model/dropdown_categories_selection_view_models/beauty_and_salon_view_model/get_beautysalon_view_model.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:loading_animation_widget/loading_animation_widget.dart';
// import 'package:open_file/open_file.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:provider/provider.dart';
//
// class BeautyConfirmedScreen extends StatefulWidget {
//   final String trackingId;
//   final String valId;
//   const BeautyConfirmedScreen({Key? key, required this.trackingId,required this.valId}) : super(key: key);
//
//   @override
//   State<BeautyConfirmedScreen> createState() => _BeautyConfirmedScreenState();
// }
//
// class _BeautyConfirmedScreenState extends State<BeautyConfirmedScreen> {
//   bool _isDownloading = false;
//
//   @override
//   void initState() {
//     super.initState();
//     print("--------------------------------------${widget.valId}");
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       final getBeautySalonViewModel = Provider.of<GetBeautySalonViewModel>(context, listen: false);
//       getBeautySalonViewModel.fetchGetBeautySalonDataApi(widget.trackingId);
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.containerBackground(context),
//       body: SafeArea(child: ResPonsiveUi(mobile: _body(),  desktop: _body(), tablet: _body())),
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
//             // Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => NavigationScreen(initialIndex: 0)), (route) => false);
//         Navigator.pop(context);
//           },
//           child: Container(height: 60, child: AppBarHeader("Booking Confirmation")),
//         ),
//         Expanded(
//           child: Consumer<GetBeautySalonViewModel>(
//             builder: (context, viewModel, _) {
//               final status = viewModel.getBeautySalonData.status;
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
//                           viewModel.fetchGetBeautySalonDataApi(widget.trackingId);
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
//               final bookingData = viewModel.getBeautySalonData.data?.data;
//               if (bookingData == null) {
//                 return Center(child: Text('No booking data available', style: AppTextStyles.textSize16(context)));
//               }
//
//               return SingleChildScrollView(
//                 child: Column(
//                   children: [
//                     SizedboxSpaccing.height02(context),
//
//                     // Success Header Card
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
//                             'Booking Confirmed!',
//                             style: AppTextStyles.textSize20(context, weight: FontWeight.w700),
//                             textAlign: TextAlign.center,
//                           ),
//
//                           SizedboxSpaccing.height01(context),
//
//                           // Order ID
//                           Text('Order ID: ${bookingData.trackingId ?? 'N/A'}', style: AppTextStyles.textSize12(context, color: AppColors.subtitle(context))),
//
//                           SizedboxSpaccing.height005(context),
//
//                           // Status
//                           Text('Status: ${bookingData.status?.toUpperCase() ?? 'PENDING'}', style: AppTextStyles.textSize12(context, color: AppColors.subtitle(context))),
//                         ],
//                       ),
//                     ),
//
//                     SizedboxSpaccing.height03(context),
//
//                     // Booking Details Section
//                     Container(
//                       width: screenWidth * 0.9,
//                       child: Text('Booking Details', style: AppTextStyles.textSize18(context, weight: FontWeight.w600)),
//                     ),
//
//                     SizedboxSpaccing.height01(context),
//
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
//                           _buildDetailRow('Phone', bookingData.phone ?? 'N/A', context),
//                           SizedboxSpaccing.height01(context),
//                           _buildDetailRow('Email', (bookingData.email != null && bookingData.email!.isNotEmpty) ? bookingData.email! : 'N/A', context),
//                           SizedboxSpaccing.height01(context),
//                           _buildDetailRow('Service Address', bookingData.fullAddress ?? 'N/A', context, isLongText: true),
//                           if (bookingData.notes != null && bookingData.notes!.isNotEmpty) ...[
//                             SizedboxSpaccing.height01(context),
//                             _buildDetailRow('Notes', bookingData.notes ?? '', context, isLongText: true),
//                           ],
//                         ],
//                       ),
//                     ),
//
//                     SizedboxSpaccing.height03(context),
//
//                     // Order Schedule Section
//                     Container(
//                       width: screenWidth * 0.9,
//                       child: Text('Order Schedule', style: AppTextStyles.textSize18(context, weight: FontWeight.w600)),
//                     ),
//
//                     SizedboxSpaccing.height01(context),
//
//                     Container(
//                       width: screenWidth * 0.9,
//                       padding: EdgeInsets.all(screenHeight * 0.012),
//                       decoration: BoxDecoration(
//                         color: AppColors.containerBackground(context),
//                         borderRadius: BorderRadius.circular(12),
//                         border: Border.all(color: AppColors.border(context)),
//                       ),
//                       child: Row(
//                         children: [
//                           Icon(Icons.calendar_today, size: 18, color: AppColors.subtitle(context)),
//                           SizedBox(width: 8),
//                           Text(_formatDate(bookingData.date), style: AppTextStyles.textSize14(context, weight: FontWeight.w500)),
//                           SizedBox(width: 24),
//                           Icon(Icons.access_time, size: 18, color: AppColors.subtitle(context)),
//                           SizedBox(width: 8),
//                           Text(bookingData.time ?? 'N/A', style: AppTextStyles.textSize14(context, weight: FontWeight.w500)),
//                         ],
//                       ),
//                     ),
//
//                     SizedboxSpaccing.height02(context),
//
//                     // Service Items
//                     if (bookingData.beautySalonBookingItems != null && bookingData.beautySalonBookingItems!.isNotEmpty)
//                       ...bookingData.beautySalonBookingItems!.map((item) {
//                         return Column(
//                           children: [
//                             Container(
//                               width: screenWidth * 0.9,
//                               padding: EdgeInsets.all(screenHeight * 0.012),
//                               decoration: BoxDecoration(
//                                 color: AppColors.containerBackground(context),
//                                 borderRadius: BorderRadius.circular(12),
//                                 border: Border.all(color: AppColors.border(context)),
//                               ),
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(item.beautySalonTaskId?.name ?? 'Service', style: AppTextStyles.textSize16(context, weight: FontWeight.w500)),
//
//                                   if (item.beautySalonTaskItemIds != null && item.beautySalonTaskItemIds!.isNotEmpty) ...[
//                                     SizedboxSpaccing.height01(context),
//                                     ...item.beautySalonTaskItemIds!.map((taskItem) {
//                                       final int itemTotal = (taskItem.salePrice ?? 0) * (item.quantity ?? 1);
//                                       return Padding(
//                                         padding: EdgeInsets.only(bottom: 8, left: 4),
//                                         child: Column(
//                                           crossAxisAlignment: CrossAxisAlignment.start,
//                                           children: [
//                                             Row(
//                                               crossAxisAlignment: CrossAxisAlignment.start,
//                                               children: [
//                                                 Text('• ', style: AppTextStyles.textSize14(context)),
//                                                 Expanded(child: Text(taskItem.name ?? '', style: AppTextStyles.textSize14(context, color: AppColors.subtitle(context)))),
//                                               ],
//                                             ),
//                                             Row(
//                                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                               children: [
//                                                 SizedBox(),
//                                                 Text(
//                                                   'Quantity: ${item.quantity ?? 1} | Total: BDT $itemTotal',
//                                                   style: AppTextStyles.textSize14(context, color: AppColors.textPrimary(context), weight: FontWeight.w500),
//                                                 ),
//                                               ],
//                                             ),
//                                           ],
//                                         ),
//                                       );
//                                     }).toList(),
//                                   ],
//                                 ],
//                               ),
//                             ),
//                             SizedboxSpaccing.height02(context),
//                           ],
//                         );
//                       }).toList(),
//
//                     // Payment Summary Section
//                     Container(
//                       width: screenWidth * 0.9,
//                       child: Text('Payment Summary', style: AppTextStyles.textSize18(context, weight: FontWeight.w600)),
//                     ),
//
//                     SizedboxSpaccing.height01(context),
//
//                     Container(
//                       width: screenWidth * 0.9,
//                       padding: EdgeInsets.all(screenHeight * 0.012),
//                       decoration: BoxDecoration(
//                         color: AppColors.containerBackground(context),
//                         borderRadius: BorderRadius.circular(12),
//                         border: Border.all(color: AppColors.border(context)),
//                       ),
//                       child: Column(
//                         children: [
//                           _buildPaymentRow('Subtotal', 'BDT ${bookingData.subTotal ?? 0}', context),
//                           SizedboxSpaccing.height01(context),
//                           _buildPaymentRow('VAT', 'BDT ${bookingData.vat ?? 0}', context),
//                           SizedboxSpaccing.height01(context),
//                           _buildPaymentRow('Transportation', 'BDT ${bookingData.fare ?? 0}', context),
//                           SizedboxSpaccing.height01(context),
//                           if (bookingData.discountValue != null && bookingData.discountValue! > 0) ...[
//                             _buildPaymentRow('Discount', '- BDT ${bookingData.discountValue}', context, isDiscount: true),
//                             SizedboxSpaccing.height01(context),
//                           ],
//                           _buildPaymentRow('Total', 'BDT ${bookingData.total ?? 0}', context),
//                           SizedboxSpaccing.height01(context),
//                           Divider(height: 1, color: AppColors.border(context)),
//                           SizedboxSpaccing.height01(context),
//                           _buildPaymentRow('Grand Total', 'BDT ${bookingData.grandTotal ?? 0}', context, isTotal: true),
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
//                         child: Center(
//                           child: Text(
//                             'Back to Home',
//                             style: AppTextStyles.textSize16(context, weight: FontWeight.w600, color: Colors.white),
//                           ),
//                         ),
//                       ),
//                     ),
//
//                     SizedboxSpaccing.height02(context),
//
//                     // Download Receipt Button
//                     // GestureDetector(
//                     //   onTap: () async {
//                     //     final bookingData = Provider.of<GetBeautySalonViewModel>(context, listen: false).getBeautySalonData.data?.data;
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
//                     //       if (Platform.isAndroid) {
//                     //         bool hasPermission = false;
//                     //
//                     //         try {
//                     //           final androidInfo = await DeviceInfoPlugin().androidInfo;
//                     //           final sdkInt = androidInfo.version.sdkInt;
//                     //
//                     //           if (sdkInt >= 33) {
//                     //             hasPermission = true;
//                     //           } else if (sdkInt >= 30) {
//                     //             final status = await Permission.manageExternalStorage.request();
//                     //             hasPermission = status.isGranted;
//                     //
//                     //             if (!status.isGranted) {
//                     //               showDialog(
//                     //                 context: context,
//                     //                 builder: (context) => AlertDialog(
//                     //                   title: Text('Storage Permission Required'),
//                     //                   content: Text('Please grant storage permission in settings to save receipts.'),
//                     //                   actions: [
//                     //                     TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
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
//                     //             final status = await Permission.storage.request();
//                     //             hasPermission = status.isGranted;
//                     //           }
//                     //         } catch (e) {
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
//                     //       final file = await PDFReceiptGenerator.generateAndDownloadPDFReceipt(
//                     //           bookingData.toReceiptData()
//                     //       );
//                     //       setState(() {
//                     //         _isDownloading = false;
//                     //       });
//                     //
//                     //       if (file != null) {
//                     //         Utils.flushBarSuccessMessage("Receipt saved successfully!", context);
//                     //
//                     //         showDialog(
//                     //           context: context,
//                     //           barrierColor: AppColors.showDialougeBackground(context),
//                     //           builder: (BuildContext context) {
//                     //             return AlertDialog(
//                     //               backgroundColor: AppColors.containerBackground(context),
//                     //               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                     //               title: Text('Download Complete', style: AppTextStyles.textSize18(context, weight: FontWeight.w600)),
//                     //               content: Column(
//                     //                 mainAxisSize: MainAxisSize.min,
//                     //                 crossAxisAlignment: CrossAxisAlignment.start,
//                     //                 children: [
//                     //                   Text('Receipt saved successfully!', style: AppTextStyles.textSize14(context)),
//                     //                   SizedBox(height: 12),
//                     //                   Container(
//                     //                     width: screenWidth,
//                     //                     padding: EdgeInsets.all(8),
//                     //                     decoration: BoxDecoration(color: AppColors.button(context).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
//                     //                     child: Column(
//                     //                       crossAxisAlignment: CrossAxisAlignment.start,
//                     //                       children: [
//                     //                         Text(
//                     //                           '📁 Location:',
//                     //                           style: AppTextStyles.textSize12(context, weight: FontWeight.w600, color: AppColors.button(context)),
//                     //                         ),
//                     //                         SizedBox(height: 4),
//                     //                         Text('Downloads/Dinmajur_Bookings', style: AppTextStyles.textSize12(context)),
//                     //                       ],
//                     //                     ),
//                     //                   ),
//                     //                   SizedBox(height: 12),
//                     //                   Text('Would you like to open it now?', style: AppTextStyles.textSize14(context)),
//                     //                 ],
//                     //               ),
//                     //               actions: [
//                     //                 TextButton(
//                     //                   onPressed: () => Navigator.of(context).pop(),
//                     //                   child: Text('Later', style: TextStyle(color: Colors.grey[600])),
//                     //                 ),
//                     //                 ElevatedButton(
//                     //                   onPressed: () async {
//                     //                     Navigator.of(context).pop();
//                     //                     await OpenFile.open(file.path);
//                     //                   },
//                     //                   style: ElevatedButton.styleFrom(backgroundColor: AppColors.button(context)),
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
//                     //         ? Center(child: LoadingAnimationWidget.progressiveDots(color: AppColors.button(context), size: 50))
//                     //         : Row(
//                     //             mainAxisAlignment: MainAxisAlignment.center,
//                     //             children: [
//                     //               Icon(Icons.download, color: AppColors.button(context), size: 20),
//                     //               SizedBox(width: 8),
//                     //               Text(
//                     //                 'Download Receipt',
//                     //                 style: AppTextStyles.textSize16(context, weight: FontWeight.w600, color: AppColors.button(context)),
//                     //               ),
//                     //             ],
//                     //           ),
//                     //   ),
//                     // ),
//                     GestureDetector(
//                       onTap: () async {
//                         final bookingData = Provider.of<GetBeautySalonViewModel>(context, listen: false).getBeautySalonData.data?.data;
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
//
//
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
//                           final file = await PDFReceiptGenerator.generateAndDownloadPDFReceipt(
//                               bookingData.toReceiptData()
//                           );
//                           setState(() {
//                             _isDownloading = false;
//                           });
//
//                           if (file != null) {
//                             Utils.flushBarSuccessMessage("Receipt saved successfully!", context);
//
//                             showDialog(
//                               context: context,
//                               barrierColor: AppColors.showDialougeBackground(context),
//                               builder: (BuildContext context) {
//                                 return AlertDialog(
//                                   backgroundColor: AppColors.containerBackground(context),
//                                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                                   title: Text('Download Complete', style: AppTextStyles.textSize18(context, weight: FontWeight.w600)),
//                                   content: Column(
//                                     mainAxisSize: MainAxisSize.min,
//                                     crossAxisAlignment: CrossAxisAlignment.start,
//                                     children: [
//                                       Text('Receipt saved successfully!', style: AppTextStyles.textSize14(context)),
//                                       SizedBox(height: 12),
//                                       Container(
//                                         width: screenWidth,
//                                         padding: EdgeInsets.all(8),
//                                         decoration: BoxDecoration(color: AppColors.button(context).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
//                                         child: Column(
//                                           crossAxisAlignment: CrossAxisAlignment.start,
//                                           children: [
//                                             Text(
//                                               '📁 Location:',
//                                               style: AppTextStyles.textSize12(context, weight: FontWeight.w600, color: AppColors.button(context)),
//                                             ),
//                                             SizedBox(height: 4),
//                                             Text('Downloads/Dinmajur_Bookings', style: AppTextStyles.textSize12(context)),
//                                           ],
//                                         ),
//                                       ),
//                                       SizedBox(height: 12),
//                                       Text('Would you like to open it now?', style: AppTextStyles.textSize14(context)),
//                                     ],
//                                   ),
//                                   actions: [
//                                     TextButton(
//                                       onPressed: () => Navigator.of(context).pop(),
//                                       child: Text('Later', style: TextStyle(color: Colors.grey[600])),
//                                     ),
//                                     ElevatedButton(
//                                       onPressed: () async {
//                                         Navigator.of(context).pop();
//                                         await OpenFile.open(file.path);
//                                       },
//                                       style: ElevatedButton.styleFrom(backgroundColor: AppColors.button(context)),
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
//
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
//                             ? Center(child: LoadingAnimationWidget.progressiveDots(color: AppColors.button(context), size: 50))
//                             : Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Icon(Icons.download, color: AppColors.button(context), size: 20),
//                             SizedBox(width: 8),
//                             Text(
//                               'Download Receipt',
//                               style: AppTextStyles.textSize16(context, weight: FontWeight.w600, color: AppColors.button(context)),
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
//                       padding: EdgeInsets.all(screenHeight * .02),
//                       decoration: BoxDecoration(
//                         color: AppColors.button(context).withOpacity(0.1),
//                         borderRadius: BorderRadius.circular(12),
//                         border: Border.all(width: 1, color: AppColors.button(context)),
//                       ),
//                       child: Row(
//                         children: [
//                           Container(
//                             height: 48,
//                             width: 48,
//                             decoration: BoxDecoration(color: AppColors.button(context), shape: BoxShape.circle),
//                             child: Icon(Icons.headset_mic, color: Colors.white, size: 24),
//                           ),
//                           SizedBox(width: 16),
//                           Expanded(
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text('Customer Care', style: AppTextStyles.textSize16(context, weight: FontWeight.w600)),
//                                 Text('Available 24/7', style: AppTextStyles.textSize12(context, color: AppColors.subtitle(context))),
//                               ],
//                             ),
//                           ),
//                           Text(
//                             '01929600600',
//                             style: AppTextStyles.textSize16(context, weight: FontWeight.w700, color: AppColors.button(context)),
//                           ),
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
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(label, style: AppTextStyles.textSize12(context, color: AppColors.subtitle(context))),
//         SizedBox(height: 4),
//         Text(value, style: AppTextStyles.textSize14(context, weight: FontWeight.w500)),
//       ],
//     );
//   }
//
//   Widget _buildPaymentRow(String label, String value, BuildContext context, {bool isTotal = false, bool isDiscount = false}) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Text(
//           label,
//           style: AppTextStyles.textSize14(context,weight: isTotal ? FontWeight.w500 : FontWeight.w400, color: AppColors.subtitle(context)),
//         ),
//         Text(
//           value,
//           style: AppTextStyles.textSize14(context, weight: isTotal ? FontWeight.w600 : FontWeight.w500, color: isDiscount ? Colors.green : (isTotal ? AppColors.button(context) : null)),
//         ),
//       ],
//     );
//   }
//
//   String _formatDate(DateTime? date) {
//     if (date == null) return 'N/A';
//     return DateFormat('dd MMM yyyy').format(date);
//   }
// }
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/components/header_appbar.dart';
import 'package:dinmajur_customer/configs/res/components/pdf_reciept_generator_auto_open_download/pdf_generator.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:dinmajur_customer/configs/responsive/responsive_ui.dart';
import 'package:dinmajur_customer/configs/utils/utils.dart';
import 'package:dinmajur_customer/data/response/status.dart';
import 'package:dinmajur_customer/view/navigation_bar.dart';
import 'package:dinmajur_customer/view/screens/home/helper_widgets/dropdown_categories_widget/confirmation_widget.dart';
import 'package:dinmajur_customer/view_model/homeview_model/dropdown_categories_selection_view_models/beauty_and_salon_view_model/get_beautysalon_view_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class BeautyConfirmedScreen extends StatefulWidget {
  final String trackingId;
  final String valId;
  const BeautyConfirmedScreen({
    Key? key,
    required this.trackingId,
    required this.valId,
  }) : super(key: key);

  @override
  State<BeautyConfirmedScreen> createState() => _BeautyConfirmedScreenState();
}

class _BeautyConfirmedScreenState extends State<BeautyConfirmedScreen> {
  bool _isDownloading = false;

  @override
  void initState() {
    super.initState();
    print("--------------------------------------${widget.valId}");
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = Provider.of<GetBeautySalonViewModel>(context, listen: false);
      viewModel.fetchGetBeautySalonDataApi(widget.trackingId);
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
          child: Consumer<GetBeautySalonViewModel>(
            builder: (context, viewModel, _) {
              final status = viewModel.getBeautySalonData.status;

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
                          viewModel.fetchGetBeautySalonDataApi(widget.trackingId);
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

              final bookingData = viewModel.getBeautySalonData.data?.data;
              if (bookingData == null) {
                return Center(
                  child: Text(
                    'No booking data available',
                    style: AppTextStyles.textSize16(context),
                  ),
                );
              }

              // Prepare service items for beauty salon
              List<ServiceItem> services = [];
              if (bookingData.beautySalonBookingItems != null &&
                  bookingData.beautySalonBookingItems!.isNotEmpty) {
                for (var item in bookingData.beautySalonBookingItems!) {
                  if (item.beautySalonTaskItemIds != null &&
                      item.beautySalonTaskItemIds!.isNotEmpty) {
                    for (var taskItem in item.beautySalonTaskItemIds!) {
                      String additionalInfo = '';
                      if (item.quantity != null && item.quantity! > 0) {
                        additionalInfo = '(${item.quantity})';
                      }
                      services.add(ServiceItem(
                        name: taskItem.name ?? 'Service',
                        additionalInfo:
                        additionalInfo.isEmpty ? null : additionalInfo,
                      ));
                    }
                  }
                }
              }

              // Create confirmation data
              final confirmationData = BookingConfirmationData(
                thankYouMessage:
                "Thank you for choosing our beauty and salon service. We've received your order.",
                orderId: bookingData.trackingId ?? 'N/A',
                services: services,
                dateTime:
                '${_formatDate(bookingData.date)}, ${bookingData.time ?? 'N/A'}',
                serviceAddress: bookingData.fullAddress ?? 'N/A',
                grandTotal: (bookingData.grandTotal ?? 0).toStringAsFixed(2),
                paymentMethod: '',
                onDownloadReceipt: () => _handleDownloadReceipt(),
                onTrackOrder: () => _handleTrackOrder(),
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
    // Get bookingData from Provider with correct type - THIS IS THE KEY!
    final bookingData = Provider.of<GetBeautySalonViewModel>(context, listen: false)
        .getBeautySalonData.data?.data;

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

      // For beauty salon - call toReceiptData() on the correctly typed bookingData
      final file = await PDFReceiptGenerator.generateAndDownloadPDFReceipt(
          bookingData!.toReceiptData()
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
    return DateFormat('dd MMM yyyy').format(date);
  }
}