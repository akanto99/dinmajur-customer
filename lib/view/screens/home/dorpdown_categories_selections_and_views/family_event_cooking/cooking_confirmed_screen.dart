// import 'dart:io';
// import 'package:device_info_plus/device_info_plus.dart';
// import 'package:dinmajur_customer/configs/res/color.dart';
// import 'package:dinmajur_customer/configs/res/components/header_appbar.dart';
// import 'package:dinmajur_customer/configs/res/components/pdf_reciept_generator_auto_open_download/event_cooking_pdf_generator/event_cooking_generator.dart';
// import 'package:dinmajur_customer/configs/res/components/pdf_reciept_generator_auto_open_download/event_cooking_pdf_generator/event_cooking_receipt_adapter.dart';
// import 'package:dinmajur_customer/configs/res/components/pdf_reciept_generator_auto_open_download/pdf_generator.dart';
// import 'package:dinmajur_customer/configs/res/text_styles.dart';
// import 'package:dinmajur_customer/configs/responsive/responsive_ui.dart';
// import 'package:dinmajur_customer/configs/utils/utils.dart';
// import 'package:dinmajur_customer/data/response/status.dart';
// import 'package:dinmajur_customer/view/navigation_bar.dart';
// import 'package:dinmajur_customer/view/screens/home/helper_widgets/dropdown_categories_widget/confirmation_widget.dart';
// import 'package:dinmajur_customer/view_model/homeview_model/dropdown_categories_selection_view_models/family_event_cooking_view_model/getdetails_event_cooking_view_model.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:loading_animation_widget/loading_animation_widget.dart';
// import 'package:open_file/open_file.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:provider/provider.dart';
//
// class CookingConfirmedScreen extends StatefulWidget {
//   final String? trackingId;
//   final String? valId;
//
//   const CookingConfirmedScreen({
//     Key? key,
//     this.trackingId,
//     this.valId,
//   }) : super(key: key);
//
//   @override
//   State<CookingConfirmedScreen> createState() => _CookingConfirmedScreenState();
// }
//
// class _CookingConfirmedScreenState extends State<CookingConfirmedScreen> {
//   bool _isDownloading = false;
//
//   @override
//   void initState() {
//     super.initState();
//     print("--------------------------------------${widget.valId}");
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       final viewModel = Provider.of<GetDetailsEventCookingViewModel>(context, listen: false);
//       viewModel.fetchgetDetailsEventCookingDataApi(widget.trackingId!);
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.containerBackground(context),
//       body: SafeArea(
//         child: ResPonsiveUi(
//           mobile: _body(),
//           desktop: _body(),
//           tablet: _body(),
//         ),
//       ),
//     );
//   }
//
//   Widget _body() {
//     return Column(
//       children: [
//         GestureDetector(
//           onTap: () => Navigator.pop(context),
//           child: Container(
//             height: 60,
//             child: AppBarHeader("Booking Confirmation"),
//           ),
//         ),
//         Expanded(
//           child: Consumer<GetDetailsEventCookingViewModel>(
//             builder: (context, viewModel, _) {
//               final status = viewModel.getDetailsEventCookingData.status;
//
//               if (status == Status.LOADING) {
//                 return Center(
//                   child: LoadingAnimationWidget.progressiveDots(
//                     color: AppColors.button(context),
//                     size: 50,
//                   ),
//                 );
//               }
//
//               if (status == Status.ERROR) {
//                 return Center(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Icon(Icons.error_outline, size: 48, color: Colors.red),
//                       SizedBox(height: 16),
//                       Text(
//                         'Failed to load booking details',
//                         style: AppTextStyles.textSize16(context, color: Colors.red),
//                       ),
//                       SizedBox(height: 16),
//                       ElevatedButton(
//                         onPressed: () {
//                           viewModel.fetchgetDetailsEventCookingDataApi(widget.trackingId!);
//                         },
//                         child: Text('Retry'),
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: AppColors.button(context),
//                         ),
//                       ),
//                     ],
//                   ),
//                 );
//               }
//
//               final bookingData = viewModel.getDetailsEventCookingData.data?.data;
//               if (bookingData == null) {
//                 return Center(
//                   child: Text(
//                     'No booking data available',
//                     style: AppTextStyles.textSize16(context),
//                   ),
//                 );
//               }
//
//               // Prepare service items - handles both REGULAR and MANUAL
//               List<ServiceItem> services = [];
//               if (bookingData.items != null && bookingData.items!.isNotEmpty) {
//                 for (var item in bookingData.items!) {
//                   String serviceName = '';
//                   String? additionalInfo;
//
//                   if (item.isManual) {
//                     // MANUAL booking - get item name from nested structure
//                     serviceName = item.itemName ?? 'Item';
//
//                     // Add package name as additional info for manual items
//                     if (item.package?.name != null) {
//                       additionalInfo = 'Package: ${item.package!.name}';
//                     }
//                   } else {
//                     // REGULAR booking - get package name
//                     serviceName = item.package?.name ?? 'Package';
//                   }
//
//                   // Add price info if available
//                   final priceDetails = item.priceDetails;
//                   if (priceDetails?.salePrice != null) {
//                     String priceInfo = '৳${priceDetails!.salePrice!.toStringAsFixed(2)}';
//                     additionalInfo = additionalInfo == null
//                         ? priceInfo
//                         : '$additionalInfo - $priceInfo';
//                   }
//
//                   services.add(ServiceItem(
//                     name: serviceName,
//                     // additionalInfo: additionalInfo,
//                   ));
//                 }
//               }
//
//               // Create confirmation data
//               final confirmationData = BookingConfirmationData(
//                 thankYouMessage:
//                 "Thank you for choosing our event cooking service. We've received your order.",
//                 orderId: bookingData.trackingId ?? 'N/A',
//                 services: services,
//                 dateTime: _formatDate(bookingData.date),
//                 serviceAddress: bookingData.fullAddress ?? 'N/A',
//                 grandTotal: (bookingData.grandTotal ?? 0).toStringAsFixed(2),
//                 paymentMethod: bookingData.paymentType ?? 'N/A',
//                 onDownloadReceipt: () => _handleDownloadReceipt(),
//                 onTrackOrder: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => NavigationScreen(initialIndex: 2),
//                     ),
//                   );
//                 },
//                 isDownloading: _isDownloading,
//               );
//
//               return BookingConfirmationUI(
//                 data: confirmationData,
//                 onBackToHome: () {
//                   Navigator.pushAndRemoveUntil(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => NavigationScreen(initialIndex: 0),
//                     ),
//                         (route) => false,
//                   );
//                 },
//               );
//             },
//           ),
//         ),
//       ],
//     );
//   }
//   Future<void> _handleDownloadReceipt() async {
//     // Get bookingData from Provider
//     final bookingData = Provider.of<GetDetailsEventCookingViewModel>(context, listen: false)
//         .getDetailsEventCookingData
//         .data
//         ?.data;
//
//     if (bookingData == null) {
//       Utils.flushBarErrorMessage("No booking data available to download", context);
//       return;
//     }
//
//     setState(() {
//       _isDownloading = true;
//     });
//
//     try {
//       // Check permissions for Android
//       if (Platform.isAndroid) {
//         try {
//           final androidInfo = await DeviceInfoPlugin().androidInfo;
//           final sdkInt = androidInfo.version.sdkInt;
//
//           if (sdkInt <= 32) {
//             final status = await Permission.storage.request();
//             if (!status.isGranted) {
//               Utils.flushBarErrorMessage(
//                 "Storage permission is required to download receipt",
//                 context,
//               );
//               setState(() {
//                 _isDownloading = false;
//               });
//               return;
//             }
//           }
//         } catch (e) {
//           print('❌ Permission check error: $e');
//         }
//       }
//
//       // ✅ USE THE ADAPTER EXTENSION TO CONVERT TO UNIVERSAL FORMAT
//       final receiptData = bookingData.toUniversalReceiptData();
//
//       // ✅ GENERATE PDF USING UNIVERSAL GENERATOR
//       final file = await UniversalPDFReceiptGenerator.generateAndDownloadPDFReceipt(receiptData);
//
//       setState(() {
//         _isDownloading = false;
//       });
//
//       if (file != null) {
//         Utils.flushBarSuccessMessage("Receipt saved successfully!", context);
//         _showDownloadSuccessDialog(file.path);
//       } else {
//         Utils.flushBarErrorMessage("Failed to generate receipt", context);
//       }
//     } catch (e) {
//       setState(() {
//         _isDownloading = false;
//       });
//       print('❌ PDF Generation Error: $e');
//       Utils.flushBarErrorMessage("Error: ${e.toString()}", context);
//     }
//   }
//
//   void _showDownloadSuccessDialog(String filePath) {
//     final screenWidth = MediaQuery.of(context).size.width;
//
//     showDialog(
//       context: context,
//       barrierColor: AppColors.showDialougeBackground(context),
//       builder: (BuildContext context) {
//         return AlertDialog(
//           backgroundColor: AppColors.containerBackground(context),
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//           title: Text(
//             'Download Complete',
//             style: AppTextStyles.textSize18(context, weight: FontWeight.w600),
//           ),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 'Receipt saved successfully!',
//                 style: AppTextStyles.textSize14(context),
//               ),
//               SizedBox(height: 12),
//               Container(
//                 width: screenWidth,
//                 padding: EdgeInsets.all(8),
//                 decoration: BoxDecoration(
//                   color: AppColors.button(context).withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       '📁 Location:',
//                       style: AppTextStyles.textSize12(
//                         context,
//                         weight: FontWeight.w600,
//                         color: AppColors.button(context),
//                       ),
//                     ),
//                     SizedBox(height: 4),
//                     Text(
//                       'Downloads/Dinmajur_Bookings',
//                       style: AppTextStyles.textSize12(context),
//                     ),
//                   ],
//                 ),
//               ),
//               SizedBox(height: 12),
//               Text(
//                 'Would you like to open it now?',
//                 style: AppTextStyles.textSize14(context),
//               ),
//             ],
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.of(context).pop(),
//               child: Text('Later', style: TextStyle(color: Colors.grey[600])),
//             ),
//             ElevatedButton(
//               onPressed: () async {
//                 Navigator.of(context).pop();
//                 await OpenFile.open(filePath);
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: AppColors.button(context),
//               ),
//               child: Text(
//                 'Open Now',
//                 style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
//               ),
//             ),
//           ],
//         );
//       },
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
import 'package:dinmajur_customer/configs/res/components/exception_errorstate/exception_errorstate.dart';
import 'package:dinmajur_customer/configs/res/components/header_appbar.dart';
import 'package:dinmajur_customer/configs/res/components/pdf_reciept_generator_auto_open_download/event_cooking_pdf_generator/event_cooking_generator.dart';
import 'package:dinmajur_customer/configs/res/components/pdf_reciept_generator_auto_open_download/event_cooking_pdf_generator/event_cooking_receipt_adapter.dart';
import 'package:dinmajur_customer/configs/res/components/pdf_reciept_generator_auto_open_download/pdf_generator.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:dinmajur_customer/configs/responsive/responsive_ui.dart';
import 'package:dinmajur_customer/configs/utils/amount_formatter/amount_formatter.dart';
import 'package:dinmajur_customer/configs/utils/date_formater/date_formater.dart';
import 'package:dinmajur_customer/configs/utils/utils.dart';
import 'package:dinmajur_customer/data/response/status.dart';
import 'package:dinmajur_customer/view/navigation_bar.dart';
import 'package:dinmajur_customer/view/screens/home/helper_widgets/dropdown_categories_widget/confirmation_widget.dart';
import 'package:dinmajur_customer/view_model/homeview_model/dropdown_categories_selection_view_models/family_event_cooking_view_model/getdetails_event_cooking_view_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class CookingConfirmedScreen extends StatefulWidget {
  final String? trackingId;
  final String? valId;
  final bool fromCheckout;

  const CookingConfirmedScreen({Key? key, this.trackingId, this.valId,
    this.fromCheckout = false,
  }) : super(key: key);

  @override
  State<CookingConfirmedScreen> createState() => _CookingConfirmedScreenState();
}

class _CookingConfirmedScreenState extends State<CookingConfirmedScreen> {
  bool _isDownloading = false;

  @override
  void initState() {
    super.initState();
    print("--------------------------------------${widget.valId}");
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = Provider.of<GetDetailsEventCookingViewModel>(context, listen: false);
      viewModel.fetchgetDetailsEventCookingDataApi(widget.trackingId!);
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !widget.fromCheckout,
      onPopInvoked: (didPop) {
        if (didPop) return;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => NavigationScreen(initialIndex: 0)),
              (route) => false,
        );
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
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => NavigationScreen(initialIndex: 0)),
                    (route) => false,
              );
            } else {
              Navigator.pop(context);
            }
          },
          child: Container(height: 60, child: AppBarHeader("Booking Confirmation")),
        ),
        Expanded(
          child: Consumer<GetDetailsEventCookingViewModel>(
            builder: (context, viewModel, _) {
              final status = viewModel.getDetailsEventCookingData.status;

              if (status == Status.LOADING) {
                return Center(child: LoadingAnimationWidget.progressiveDots(color: AppColors.button(context), size: 50));
              }

              if (status == Status.ERROR) {
                return ErrorStateWidget(
                  // errorMessage: viewModel.getConfirmBookingData.message.toString(),
                  errorMessage: "Failed to load booking details",
                  onRetry: () {
                    viewModel.fetchgetDetailsEventCookingDataApi(widget.trackingId!);
                  },
                );
              }

              final bookingData = viewModel.getDetailsEventCookingData.data?.data;
              if (bookingData == null) {
                return Center(child: Text('No booking data available', style: AppTextStyles.textSize16(context)));
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
                        String? additionalInfo;

                        // Add package name as additional info
                        additionalInfo = 'Package: $packageName';

                        // Add price info if available
                        if (itemWrapper.price?.salePrice != null) {
                          String priceInfo = '৳${itemWrapper.price!.salePrice!.toStringAsFixed(2)}';
                          additionalInfo = '$additionalInfo - $priceInfo';
                        }

                        services.add(
                          ServiceItem(
                            name: serviceName,
                            // additionalInfo: additionalInfo,
                          ),
                        );
                      }
                    }
                  } else {
                    // REGULAR booking - single package with price
                    String serviceName = bookingItem.package?.name ?? 'Package';
                    String? additionalInfo;

                    // Add price info if available
                    if (bookingItem.price?.salePrice != null) {
                      additionalInfo = '৳${bookingItem.price!.salePrice!.toStringAsFixed(2)}';
                    }

                    services.add(
                      ServiceItem(
                        name: serviceName,
                        // additionalInfo: additionalInfo,
                      ),
                    );
                  }
                }
              }

              // Create confirmation data
              final confirmationData = BookingConfirmationData(
                thankYouMessage: "Thank you for choosing our event cooking service. We've received your order.",
                orderId: bookingData.trackingId ?? 'N/A',
                services: services,
                dateTime: "${DateFormatter.formatDate(bookingData.date)}, ${bookingData.slot}",
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

  Future<void> _handleDownloadReceipt() async {
    // Get bookingData from Provider
    final bookingData = Provider.of<GetDetailsEventCookingViewModel>(context, listen: false).getDetailsEventCookingData.data?.data;

    if (bookingData == null) {
      Utils.flushBarErrorMessage("No booking data available to download", context);
      return;
    }

    setState(() {
      _isDownloading = true;
    });

    try {
      // Check permissions for Android
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

      // ✅ USE THE ADAPTER EXTENSION TO CONVERT TO UNIVERSAL FORMAT
      final receiptData = bookingData.toUniversalReceiptData();

      // ✅ GENERATE PDF USING UNIVERSAL GENERATOR
      final file = await UniversalPDFReceiptGenerator.generateAndDownloadPDFReceipt(receiptData);

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
}
