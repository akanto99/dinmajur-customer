/// For Web View SSL Implementation using payment url
// import 'package:dinmajur_customer/configs/res/color.dart';
// import 'package:dinmajur_customer/configs/res/components/header_appbar.dart';
// import 'package:dinmajur_customer/configs/res/components/iagree_terms&condition/iagree_terms&condition.dart';
// import 'package:dinmajur_customer/configs/res/components/payment_method/payment_method_component.dart';
// import 'package:dinmajur_customer/configs/res/components/section_header/section_header.dart';
// import 'package:dinmajur_customer/configs/res/sizedbox_spaccing.dart';
// import 'package:dinmajur_customer/configs/res/text_styles.dart';
// import 'package:dinmajur_customer/configs/utils/routes/routes_name.dart';
// import 'package:dinmajur_customer/configs/utils/utils.dart';
// import 'package:dinmajur_customer/view/screens/home/dorpdown_categories_selections_and_views/family_event_cooking/notifier/cooking_checkout_notifier.dart';
// import 'package:dinmajur_customer/view/screens/home/payment_webview_helper_class/payment_webview.dart';
// import 'package:dinmajur_customer/view_model/homeview_model/dropdown_categories_selection_view_models/family_event_cooking_view_model/book_family_event_cooking_view_model.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:loading_animation_widget/loading_animation_widget.dart';
// import 'package:provider/provider.dart';
//
// import '../../../../../model/home_models/dropdown_categories_selection_models/family_event_cooking_model/getall_family_event_cooking_model.dart';
//
// class CookingCheckoutScreen extends StatefulWidget {
//   final String customerName;
//   final String customerPhone;
//   final String customerAddress;
//   final String userId;
//   final List<Datum> categories;
//   final Map<String, String?> selectedPackages;
//   final Map<String, Set<String>> selectedManualItems;
//   final String? activeCategoryId;
//   final int selectedGuestRangeIndex;
//   final double totalPrice;
//   final double savedAmount;
//   final double transportFee;
//   final DateTime? selectedDate;
//   final String? selectedServiceTime;
//   final Function(String)? onAddressUpdate;
//
//   const CookingCheckoutScreen({
//     Key? key,
//     required this.customerName,
//     required this.customerPhone,
//     required this.customerAddress,
//     required this.userId,
//     required this.categories,
//     required this.selectedPackages,
//     required this.selectedManualItems,
//     required this.activeCategoryId,
//     required this.selectedGuestRangeIndex,
//     required this.totalPrice,
//     required this.savedAmount,
//     required this.transportFee,
//     required this.selectedDate,
//     required this.selectedServiceTime,
//     this.onAddressUpdate,
//   }) : super(key: key);
//
//   @override
//   State<CookingCheckoutScreen> createState() => _CookingCheckoutScreenState();
// }
//
// class _CookingCheckoutScreenState extends State<CookingCheckoutScreen> {
//   final TextEditingController _addressController = TextEditingController();
//   bool _isTermsAccepted = false;
//   bool _isProcessing = false; // ✅ Add this flag to prevent multiple API calls
//
//   @override
//   void initState() {
//     super.initState();
//     _addressController.text = widget.customerAddress;
//   }
//
//   @override
//   void dispose() {
//     _addressController.dispose();
//     super.dispose();
//   }
//
//   void _clearAllData() {
//     final checkoutVM = Provider.of<CookingCheckoutViewModel>(context, listen: false);
//     checkoutVM.reset();
//
//     _addressController.clear();
//     setState(() {
//       _isTermsAccepted = false;
//       _isProcessing = false; // ✅ Reset processing flag
//     });
//   }
//
//   Map<String, dynamic> _prepareBookingPayload() {
//     if (widget.activeCategoryId == null) {
//       throw Exception('No active category selected');
//     }
//
//     // Find the active category
//     Datum? activeCategory;
//     for (var category in widget.categories) {
//       if (category.id == widget.activeCategoryId) {
//         activeCategory = category;
//         break;
//       }
//     }
//
//     if (activeCategory == null) {
//       throw Exception('Active category not found');
//     }
//
//     final checkoutVM = Provider.of<CookingCheckoutViewModel>(context, listen: false);
//
//     // Base booking data
//     Map<String, dynamic> bookingPayload = {
//       "booking": {
//         "paymentType": checkoutVM.getPaymentMethodData(checkoutVM.selectedPaymentMethod).toUpperCase(),
//         "fullAddress": _addressController.text,
//         "fullName": widget.customerName,
//         "phone": widget.customerPhone,
//         "date": widget.selectedDate?.toIso8601String() ?? DateTime.now().toIso8601String(),
//         "slot": widget.selectedServiceTime?.toUpperCase() ?? 'DAY',
//       },
//       "eventCookingCategoryId": activeCategory.id,
//       "source":"mobile",
//     };
//
//     if (activeCategory.type == 'REGULAR') {
//       // REGULAR type: Single package selection
//       final selectedPackageId = widget.selectedPackages[activeCategory.id];
//
//       if (selectedPackageId == null) {
//         throw Exception('No package selected');
//       }
//
//       // Find the selected package to get price ID
//       String? priceId;
//       for (var package in activeCategory.packages ?? []) {
//         if (package.id == selectedPackageId) {
//           if (widget.selectedGuestRangeIndex < (package.prices?.length ?? 0)) {
//             priceId = package.prices![widget.selectedGuestRangeIndex].id;
//           }
//           break;
//         }
//       }
//
//       bookingPayload["packages"] = [
//         {"packageId": selectedPackageId, "priceId": priceId},
//       ];
//     } else if (activeCategory.type == 'MANUAL') {
//       // MANUAL type: Multiple items selection
//       bookingPayload["eventCookingCategoryId"] = activeCategory.id;
//
//       // Group items by package
//       Map<String, List<Map<String, String>>> packageItemsMap = {};
//
//       for (var package in activeCategory.packages ?? []) {
//         for (var item in package.items ?? []) {
//           final key = '${package.id}_${item.id}';
//
//           if (widget.selectedManualItems[activeCategory.id]?.contains(key) ?? false) {
//             // Get the price ID for this item
//             String? priceId;
//             if (widget.selectedGuestRangeIndex < (item.prices?.length ?? 0)) {
//               priceId = item.prices![widget.selectedGuestRangeIndex].id;
//             }
//
//             if (!packageItemsMap.containsKey(package.id)) {
//               packageItemsMap[package.id!] = [];
//             }
//
//             packageItemsMap[package.id]!.add({"itemId": item.id!, "priceId": priceId ?? item.id!});
//           }
//         }
//       }
//
//       // Convert map to packages array
//       List<Map<String, dynamic>> packages = [];
//       packageItemsMap.forEach((packageId, items) {
//         packages.add({"packageId": packageId, "items": items});
//       });
//
//       bookingPayload["packages"] = packages;
//     }
//
//     return bookingPayload;
//   }
//
//   Future<void> _handleConfirmBooking() async {
//     // ✅ Prevent multiple simultaneous API calls
//     if (_isProcessing) {
//       print('⚠️ Already processing payment, ignoring duplicate tap');
//       return;
//     }
//
//     final checkoutVM = Provider.of<CookingCheckoutViewModel>(context, listen: false);
//     final bookingViewModel = Provider.of<PostBookFamilyEventCookingViewModel>(context, listen: false);
//
//     // Calculate total amount
//     double totalAmount = widget.totalPrice + widget.transportFee;
//
//     // Validate form
//     String? validationError = checkoutVM.validateCheckoutDetails(
//       fullName: widget.customerName,
//       phone: widget.customerPhone,
//       address: _addressController.text,
//       paymentMethod: checkoutVM.selectedPaymentMethod,
//     );
//
//     if (validationError != null) {
//       Utils.flushBarErrorMessage(validationError, context);
//       return;
//     }
//
//     if (!_isTermsAccepted) {
//       Utils.flushBarErrorMessage("Please accept the Terms & Conditions to proceed", context);
//       return;
//     }
//
//     // ✅ Set processing flag BEFORE API call
//     setState(() {
//       _isProcessing = true;
//     });
//
//     try {
//       // Prepare booking payload
//       Map<String, dynamic> bookingPayload = _prepareBookingPayload();
//
//       print('Booking Payload: $bookingPayload');
//
//       // Call booking API with paymentUrl and trackingId callback
//       await bookingViewModel.bookFamilyEventCookingPostApi(context, bookingPayload, (String? paymentUrl, String? trackingId) async {
//         print('Success! Payment URL: $paymentUrl, TrackingId: $trackingId');
//
//         if (trackingId == null || trackingId.isEmpty) {
//           Navigator.pushReplacementNamed(
//             context,
//             RoutesName.failedOrderScreenWidget,
//             arguments: {'trackingId': 'N/A', 'valId': 'N/A', 'reason': 'Booking creation failed', 'errorMessage': 'Unable to create booking. Please try again.'},
//           );
//
//           // ✅ Reset processing flag
//           if (mounted) {
//             setState(() {
//               _isProcessing = false;
//             });
//           }
//           return;
//         }
//
//         if (checkoutVM.selectedPaymentMethod == 'online' && paymentUrl != null && paymentUrl.isNotEmpty) {
//           print('---------------Opening WebView for payment----------------');
//
//           // Navigate to payment WebView
//           final result = await Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => PaymentWebViewScreen(paymentUrl: paymentUrl, trackingId: trackingId),
//             ),
//           );
//
//           // ✅ Reset processing flag after WebView closes
//           if (mounted) {
//             setState(() {
//               _isProcessing = false;
//             });
//           }
//
//           // Handle payment result from WebView
//           if (result != null && result is Map<String, dynamic>) {
//             String status = result['status'] ?? '';
//
//             if (status == 'success') {
//               // Payment successful
//               _clearAllData();
//               Navigator.pop(context);
//
//               Navigator.pushNamed(context, RoutesName.cookingConfirmedScreen, arguments: {'trackingId': trackingId, 'valId': 'ONLINE_PAYMENT'});
//             } else if (status == 'failed') {
//               // Payment failed
//               print("---------------------Payment FAILED -----------");
//               WidgetsBinding.instance.addPostFrameCallback((_) {
//                 if (mounted) {
//                   Navigator.pushReplacementNamed(
//                     context,
//                     RoutesName.cookingFailedCancelledPaymentScreen,
//                     arguments: {
//                       'trackingId': trackingId,
//                       'valId': 'N/A',
//                       'reason': 'Payment transaction failed',
//                       'errorMessage': 'The payment could not be completed. Please try again.',
//                       'isCancelled': false,
//                     },
//                   );
//                 }
//               });
//             } else if (status == 'cancelled') {
//               // Payment cancelled
//               print("---------------------Payment CANCELLED -----------");
//               WidgetsBinding.instance.addPostFrameCallback((_) {
//                 if (mounted) {
//                   Navigator.pushReplacementNamed(
//                     context,
//                     RoutesName.cookingFailedCancelledPaymentScreen,
//                     arguments: {
//                       'trackingId': trackingId,
//                       'valId': 'N/A',
//                       'reason': 'Payment cancelled by user',
//                       'errorMessage': 'You cancelled the payment. You can retry whenever you\'re ready.',
//                       'isCancelled': true,
//                     },
//                   );
//                 }
//               });
//             }
//           }
//         } else if (checkoutVM.selectedPaymentMethod == 'cash') {
//           // Cash on delivery flow
//           _clearAllData();
//
//           // ✅ Reset processing flag
//           if (mounted) {
//             setState(() {
//               _isProcessing = false;
//             });
//           }
//
//           Navigator.pop(context);
//           Navigator.pushNamed(context, RoutesName.cookingConfirmedScreen, arguments: {'trackingId': trackingId, 'valId': "COD"});
//         } else {
//           // No payment URL received for online payment
//           Utils.flushBarErrorMessage("Payment gateway URL not available", context);
//
//           // ✅ Reset processing flag
//           if (mounted) {
//             setState(() {
//               _isProcessing = false;
//             });
//           }
//
//           Navigator.pushReplacementNamed(
//             context,
//             RoutesName.failedOrderScreenWidget,
//             arguments: {'trackingId': trackingId, 'valId': 'N/A', 'reason': 'Invalid payment method', 'errorMessage': 'The selected payment method is not available.'},
//           );
//         }
//       });
//     } catch (e) {
//       print('Booking error: $e');
//
//       // ✅ Reset processing flag on error
//       if (mounted) {
//         setState(() {
//           _isProcessing = false;
//         });
//       }
//
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         if (mounted) {
//           Navigator.pushReplacementNamed(
//             context,
//             RoutesName.failedOrderScreenWidget,
//             arguments: {'trackingId': 'N/A', 'valId': 'N/A', 'reason': 'Booking failed', 'errorMessage': 'An error occurred while processing your booking. Please try again.'},
//           );
//         }
//       });
//     }
//   }
//
//   String _getGuestRangeText() {
//     final ranges = ['25-30', '30-35', '40-50'];
//     if (widget.selectedGuestRangeIndex < ranges.length) {
//       return ranges[widget.selectedGuestRangeIndex];
//     }
//     return '';
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Consumer2<CookingCheckoutViewModel, PostBookFamilyEventCookingViewModel>(
//       builder: (context, checkoutVM, bookingVM, _) {
//         double total = widget.totalPrice + widget.transportFee;
//
//         // ✅ Disable button when processing OR when loading
//         bool isButtonDisabled = _isProcessing || bookingVM.createBookFamilyEventCookingLoading;
//
//         return WillPopScope(
//           onWillPop: () async {
//             Navigator.pop(context, false);
//             return false;
//           },
//           child: Scaffold(
//             backgroundColor: AppColors.containerBackground(context),
//             body: SafeArea(
//               child: Column(
//                 children: [
//                   GestureDetector(
//                     onTap: () => Navigator.pop(context, false),
//                     child: Container(height: 60, child: AppBarHeader("Checkout")),
//                   ),
//                   Expanded(
//                     child: SingleChildScrollView(
//                       padding: EdgeInsets.all(15),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           _buildCustomerDetailsCard(),
//                           SizedboxSpaccing.height02(context),
//                           _buildBookingSummary(),
//                           SizedboxSpaccing.height02(context),
//                           _buildPaymentMethodSection(checkoutVM),
//                           SizedboxSpaccing.height01(context),
//                           DynamicTermsCheckbox(
//                             isAccepted: _isTermsAccepted,
//                             onChanged: (value) {
//                               setState(() {
//                                 _isTermsAccepted = value;
//                               });
//                             },
//                             context: context,
//                             onTermsTap: () => Navigator.pushNamed(context, RoutesName.termsAndCondition),
//                             onPrivacyTap: () => Navigator.pushNamed(context, RoutesName.privacyPolicy),
//                             onRefundTap: () => Navigator.pushNamed(context, RoutesName.refundPolicyScreen),
//                             getButtonColor: (context) => AppColors.button(context),
//                             getBorderColor: (context) => AppColors.border(context),
//                             getWhiteColor: (context) => AppColors.whiteColor,
//                             getTextStyle: (context, {weight}) => AppTextStyles.textSize12(context, weight: weight ?? FontWeight.w400),
//                           ),
//                           SizedboxSpaccing.height03(context),
//                         ],
//                       ),
//                     ),
//                   ),
//                   _buildConfirmButton(context, checkoutVM, bookingVM, total, isButtonDisabled),
//                 ],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
//
//   Future<void> _handleEditAddress() async {
//     final result = await Navigator.pushNamed(context, RoutesName.addLocationScreenWidget);
//
//     if (result != null && result is Map<String, dynamic>) {
//       setState(() {
//         String newAddress = '';
//
//         if (result['addressType'] == 'saved') {
//           newAddress = result['fullAddress'] ?? '';
//         } else if (result['addressType'] == 'new') {
//           newAddress = result['fullAddress'] ?? '';
//         }
//
//         _addressController.text = newAddress;
//
//         if (widget.onAddressUpdate != null && newAddress.isNotEmpty) {
//           widget.onAddressUpdate!(newAddress);
//         }
//       });
//     }
//   }
//
//   Widget _buildCustomerDetailsCard() {
//     final screenHeight = MediaQuery.of(context).size.height;
//     return Container(
//       padding: EdgeInsets.all(screenHeight * 0.015),
//       decoration: BoxDecoration(
//         color: AppColors.containerBackground(context),
//         borderRadius: BorderRadius.circular(8),
//         border: Border.all(color: AppColors.border(context)),
//       ),
//       child: Column(
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text('Customer Details', style: AppTextStyles.textSize14(context, weight: FontWeight.w500)),
//               GestureDetector(
//                 onTap: _handleEditAddress,
//                 child: Container(
//                   width: 80,
//                   color: Colors.transparent,
//                   alignment: Alignment.centerRight,
//                   child: Text('Edit', style: AppTextStyles.textSize14(context, weight: FontWeight.w500)),
//                 ),
//               ),
//             ],
//           ),
//           SizedboxSpaccing.height01(context),
//           _buildDetailRow('Name', widget.customerName),
//           SizedboxSpaccing.height01(context),
//           _buildDetailRow('Phone', widget.customerPhone),
//           SizedboxSpaccing.height01(context),
//           _buildDetailRow('Address', _addressController.text.isEmpty ? widget.customerAddress : _addressController.text, isMultiline: true),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildDetailRow(String label, String value, {bool isMultiline = false}) {
//     if (isMultiline) {
//       return Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text('$label :  ', style: AppTextStyles.textSize14(context, weight: FontWeight.w400)),
//           Expanded(
//             child: Text(
//               value,
//               style: AppTextStyles.textSize14(context, weight: FontWeight.w500, color: AppColors.subtitle(context)),
//               maxLines: null,
//               softWrap: true,
//             ),
//           ),
//         ],
//       );
//     }
//
//     return Row(
//       children: [
//         Text('$label :  ', style: AppTextStyles.textSize14(context, weight: FontWeight.w400)),
//         Text(
//           value,
//           style: AppTextStyles.textSize14(context, weight: FontWeight.w500, color: AppColors.subtitle(context)),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildBookingSummary() {
//     final screenWidth = MediaQuery.of(context).size.width;
//     final screenHeight = MediaQuery.of(context).size.height;
//
//     return Column(
//       children: [
//         SectionHeader(title: 'Booking Summary', titleWidth: screenWidth * 0.6, showSeeAll: false),
//         SizedboxSpaccing.height02(context),
//         Container(
//           padding: EdgeInsets.all(screenHeight * 0.015),
//           decoration: BoxDecoration(
//             color: AppColors.containerBackground(context),
//             borderRadius: BorderRadius.circular(16),
//             border: Border.all(color: AppColors.border(context)),
//           ),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               _buildSelectedItemsSection(),
//               SizedboxSpaccing.height015(context),
//               _buildSummaryRow('Date', DateFormat('MMMM dd, yyyy').format(widget.selectedDate ?? DateTime.now())),
//               SizedboxSpaccing.height015(context),
//               _buildSummaryRow('Number of Guests', _getGuestRangeText()),
//               SizedboxSpaccing.height015(context),
//               _buildSummaryRow('Slot', widget.selectedServiceTime ?? 'Not selected'),
//               SizedboxSpaccing.height015(context),
//               _buildPriceRow('Subtotal', widget.totalPrice),
//               SizedboxSpaccing.height015(context),
//               _buildPriceRow('Transport', widget.transportFee),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildSelectedItemsSection() {
//     if (widget.activeCategoryId == null) return SizedBox.shrink();
//
//     for (var category in widget.categories) {
//       if (category.id == widget.activeCategoryId) {
//         if (category.type == 'REGULAR') {
//           return _buildRegularPackageDetails(category);
//         } else if (category.type == 'MANUAL') {
//           return _buildManualItemsDetails(category);
//         }
//       }
//     }
//     return SizedBox.shrink();
//   }
//
//   Widget _buildRegularPackageDetails(Datum category) {
//     final selectedPackageId = widget.selectedPackages[category.id];
//     if (selectedPackageId == null) return SizedBox.shrink();
//
//     for (var package in category.packages ?? []) {
//       if (package.id == selectedPackageId) {
//         double salePrice = 0;
//         double originalPrice = 0;
//
//         if (widget.selectedGuestRangeIndex < (package.prices?.length ?? 0)) {
//           salePrice = package.prices![widget.selectedGuestRangeIndex].salePrice?.toDouble() ?? 0;
//           originalPrice = package.prices![widget.selectedGuestRangeIndex].originalPrice?.toDouble() ?? 0;
//         }
//
//         double savedAmount = originalPrice - salePrice;
//
//         return Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Text(package.name ?? '', style: AppTextStyles.textSize14(context, weight: FontWeight.w400)),
//             Row(
//               children: [
//                 Text('৳${salePrice.toStringAsFixed(2)}', style: AppTextStyles.textSize14(context, weight: FontWeight.w600)),
//                 if (savedAmount > 0) ...[
//                   SizedBox(width: 8),
//                   Text(
//                     '৳${originalPrice.toStringAsFixed(0)}',
//                     style: AppTextStyles.textSize12(context, color: AppColors.subtitle(context)).copyWith(decoration: TextDecoration.lineThrough),
//                   ),
//                 ],
//               ],
//             ),
//           ],
//         );
//       }
//     }
//     return SizedBox.shrink();
//   }
//
//   Widget _buildManualItemsDetails(Datum category) {
//     List<Map<String, dynamic>> selectedItems = [];
//     double totalSalePrice = 0;
//     double totalOriginalPrice = 0;
//
//     for (var package in category.packages ?? []) {
//       for (var item in package.items ?? []) {
//         final key = '${package.id}_${item.id}';
//         if (widget.selectedManualItems[category.id]?.contains(key) ?? false) {
//           double salePrice = 0;
//           double originalPrice = 0;
//
//           if (widget.selectedGuestRangeIndex < (item.prices?.length ?? 0)) {
//             salePrice = item.prices![widget.selectedGuestRangeIndex].salePrice?.toDouble() ?? 0;
//             originalPrice = item.prices![widget.selectedGuestRangeIndex].originalPrice?.toDouble() ?? 0;
//           }
//
//           totalSalePrice += salePrice;
//           totalOriginalPrice += originalPrice;
//
//           selectedItems.add({'name': item.name ?? '', 'salePrice': salePrice, 'originalPrice': originalPrice});
//         }
//       }
//     }
//
//     if (selectedItems.isEmpty) return SizedBox.shrink();
//
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text('${category.name ?? ''}', style: AppTextStyles.textSize14(context, weight: FontWeight.w600)),
//         SizedBox(height: 8),
//         Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             ...selectedItems.asMap().entries.map((entry) {
//               final index = entry.key;
//               final item = entry.value;
//               final isLast = index == selectedItems.length - 1;
//
//               return Padding(
//                 padding: EdgeInsets.only(bottom: isLast ? 0 : 8),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Expanded(
//                       child: Text('${item['name']}', style: AppTextStyles.textSize12(context, weight: FontWeight.w400)),
//                     ),
//                     Row(
//                       children: [
//                         Text('৳${item['salePrice'].toStringAsFixed(2)}', style: AppTextStyles.textSize12(context, weight: FontWeight.w500)),
//                         if (item['originalPrice'] > item['salePrice']) ...[
//                           SizedBox(width: 6),
//                           Text(
//                             '৳${item['originalPrice'].toStringAsFixed(0)}',
//                             style: AppTextStyles.textSize10(context, color: AppColors.subtitle(context)).copyWith(decoration: TextDecoration.lineThrough),
//                           ),
//                         ],
//                       ],
//                     ),
//                   ],
//                 ),
//               );
//             }),
//           ],
//         ),
//       ],
//     );
//   }
//
//   Widget _buildSummaryRow(String label, String value) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Text(label, style: AppTextStyles.textSize14(context, weight: FontWeight.w400)),
//         Expanded(
//           child: Text(
//             value,
//             style: AppTextStyles.textSize14(context, weight: FontWeight.w500),
//             textAlign: TextAlign.end,
//             maxLines: null,
//             softWrap: true,
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildPriceRow(String label, double amount, {bool isGreen = false}) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Text(label, style: AppTextStyles.textSize14(context, weight: FontWeight.w400)),
//         Text(
//           '৳${amount.toStringAsFixed(0)}',
//           style: AppTextStyles.textSize14(context, weight: FontWeight.w500, color: isGreen ? Colors.green : AppColors.textPrimary(context)),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildPaymentMethodSection(CookingCheckoutViewModel viewModel) {
//     final screenWidth = MediaQuery.of(context).size.width;
//
//     return Column(
//       children: [
//         SectionHeader(title: 'Payment Method', titleWidth: screenWidth * 0.6, showSeeAll: false),
//         SizedboxSpaccing.height02(context),
//         PaymentMethodWidget(selectedPaymentMethod: viewModel.selectedPaymentMethod, paymentMethods: viewModel.paymentMethods, onPaymentMethodChanged: (method) => viewModel.setPaymentMethod(method)),
//       ],
//     );
//   }
//
//   Widget _buildConfirmButton(
//     BuildContext context,
//     CookingCheckoutViewModel checkoutVM,
//     PostBookFamilyEventCookingViewModel bookingVM,
//     double total,
//     bool isButtonDisabled, // ✅ This parameter is passed correctly
//   ) {
//     return Container(
//       padding: EdgeInsets.all(15),
//       decoration: BoxDecoration(
//         color: AppColors.button(context),
//         border: Border(top: BorderSide(color: AppColors.border(context), width: 1)),
//       ),
//       child: Row(
//         children: [
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Text('Total Amount', style: AppTextStyles.textSize14(context, color: AppColors.whiteColor)),
//                 SizedBox(height: 4),
//                 Row(
//                   children: [
//                     Text(
//                       '৳${total.toStringAsFixed(2)}',
//                       style: AppTextStyles.textSize20(context, weight: FontWeight.w700, color: AppColors.whiteColor),
//                     ),
//                     if (widget.savedAmount > 0) ...[
//                       SizedBox(width: 8),
//                       Container(
//                         padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
//                         decoration: BoxDecoration(color: Colors.green.withOpacity(0.2), borderRadius: BorderRadius.circular(4)),
//                         child: Text(
//                           'Saved ৳${widget.savedAmount.toStringAsFixed(0)}',
//                           style: AppTextStyles.textSize12(context, color: Colors.greenAccent, weight: FontWeight.w600),
//                         ),
//                       ),
//                     ],
//                   ],
//                 ),
//               ],
//             ),
//           ),
//           // ✅ Wrap with AbsorbPointer to prevent taps when disabled
//           AbsorbPointer(
//             absorbing: isButtonDisabled,
//             child: GestureDetector(
//               onTap: _handleConfirmBooking, // ✅ Use the method directly
//               child: Container(
//                 height: 50,
//                 width: 140,
//                 decoration: BoxDecoration(
//                   color: isButtonDisabled
//                       ? AppColors.blackColor.withOpacity(0.5) // ✅ Visual feedback when disabled
//                       : AppColors.blackColor,
//                   borderRadius: BorderRadius.circular(8),
//                   border: Border.all(width: 1, color: AppColors.whiteColor),
//                 ),
//                 child:
//                     isButtonDisabled // ✅ Use the correct variable
//                     ? Center(child: LoadingAnimationWidget.progressiveDots(color: AppColors.whiteColor, size: 30))
//                     : Center(
//                         child: Row(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             Text(
//                               'Pay Now',
//                               style: AppTextStyles.textSize16(context, weight: FontWeight.w600, color: Colors.white),
//                             ),
//                             SizedBox(width: 8),
//                             Icon(Icons.arrow_forward, color: Colors.white, size: 18),
//                           ],
//                         ),
//                       ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

///For Ssl Integration using store id and Password

import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/components/header_appbar.dart';
import 'package:dinmajur_customer/configs/res/components/iagree_terms&condition/iagree_terms&condition.dart';
import 'package:dinmajur_customer/configs/res/components/payment_method/payment_method_component.dart';
import 'package:dinmajur_customer/configs/res/components/section_header/section_header.dart';
import 'package:dinmajur_customer/configs/res/sizedbox_spaccing.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:dinmajur_customer/configs/services/ssl_payment_service/ssl_payment.dart';
import 'package:dinmajur_customer/configs/utils/routes/routes_name.dart';
import 'package:dinmajur_customer/configs/utils/utils.dart';
import 'package:dinmajur_customer/view/screens/home/dorpdown_categories_selections_and_views/family_event_cooking/notifier/cooking_checkout_notifier.dart';
import 'package:dinmajur_customer/view_model/homeview_model/dropdown_categories_selection_view_models/family_event_cooking_view_model/book_family_event_cooking_view_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';

import '../../../../../model/home_models/dropdown_categories_selection_models/family_event_cooking_model/getall_family_event_cooking_model.dart';

class CookingCheckoutScreen extends StatefulWidget {
  final String customerName;
  final String customerPhone;
  final String customerAddress;
  final String userId;
  final List<Datum> categories;
  final Map<String, String?> selectedPackages; // REGULAR packages
  final Map<String, Set<String>> selectedManualItems; // MANUAL items
  final String? activeCategoryId;
  final int selectedGuestRangeIndex;
  final double totalPrice;
  final double savedAmount;
  final double transportFee;
  final DateTime? selectedDate;
  final String? selectedServiceTime;
  final Function(String)? onAddressUpdate;

  const CookingCheckoutScreen({
    Key? key,
    required this.customerName,
    required this.customerPhone,
    required this.customerAddress,
    required this.userId,
    required this.categories,
    required this.selectedPackages,
    required this.selectedManualItems,
    required this.activeCategoryId,
    required this.selectedGuestRangeIndex,
    required this.totalPrice,
    required this.savedAmount,
    required this.transportFee,
    required this.selectedDate,
    required this.selectedServiceTime,
    this.onAddressUpdate,
  }) : super(key: key);

  @override
  State<CookingCheckoutScreen> createState() => _CookingCheckoutScreenState();
}

class _CookingCheckoutScreenState extends State<CookingCheckoutScreen> {
  final TextEditingController _addressController = TextEditingController();
  bool _isTermsAccepted = false;

  @override
  void initState() {
    super.initState();
    _addressController.text = widget.customerAddress;
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  // Future<void> _handlePaymentResult({
  //   required CookingCheckoutViewModel viewModel,
  //   required SSLPaymentResult paymentResult,
  //   required String trackingId,
  // }) async {
  //   if (!mounted) return;
  //
  //   if (paymentResult.success) {
  //     _clearAllData();
  //     Navigator.pushReplacementNamed(
  //       context,
  //       RoutesName.beautyConfirmedScreen,
  //       arguments: {
  //         'trackingId': trackingId,
  //         'valId': paymentResult.validationId ?? 'N/A',
  //       },
  //     );
  //   } else if (paymentResult.status == 'FAILED') {
  //     WidgetsBinding.instance.addPostFrameCallback((_) {
  //       if (mounted) {
  //         Navigator.pushReplacementNamed(
  //           context,
  //           RoutesName.failedOrderScreenWidget,
  //           arguments: {
  //             'trackingId': trackingId,
  //             'valId': paymentResult.validationId ?? 'N/A',
  //             'reason': 'Payment transaction failed',
  //             'errorMessage': paymentResult.errorMessage ?? 'The payment could not be completed. Please try again.',
  //           },
  //         );
  //       }
  //     });
  //   } else if (paymentResult.status == 'CANCELLED') {
  //     WidgetsBinding.instance.addPostFrameCallback((_) {
  //       if (mounted) {
  //         Utils.flushBarErrorMessage("Payment was cancelled", context);
  //       }
  //     });
  //   } else {
  //     WidgetsBinding.instance.addPostFrameCallback((_) {
  //       if (mounted) {
  //         Utils.flushBarErrorMessage(
  //           paymentResult.errorMessage ?? "Payment status unclear",
  //           context,
  //         );
  //       }
  //     });
  //   }
  // }
  Future<void> _handlePaymentResult({
    required CookingCheckoutViewModel viewModel,
    required SSLPaymentResult paymentResult,
    required String trackingId,
  }) async {
    if (!mounted) return;

    if (paymentResult.success) {
      _clearAllData();
      Navigator.pushReplacementNamed(
        context,
        RoutesName.cookingConfirmedScreen,
        arguments: {
          'trackingId': trackingId,
          'valId': paymentResult.validationId ?? 'N/A',
        },
      );
    } else if (paymentResult.status == 'FAILED') {
      print("---------------------Handle Payment result - FAILED -----------");
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.pushReplacementNamed(
            context,
            RoutesName.cookingFailedCancelledPaymentScreen,
            arguments: {
              'trackingId': trackingId,
              'valId': paymentResult.validationId ?? 'N/A',
              'reason': 'Payment transaction failed',
              'errorMessage': paymentResult.errorMessage ?? 'The payment could not be completed. Please try again.',
              'isCancelled': false, // Payment failed
            },
          );
        }
      });
    } else if (paymentResult.status == 'CLOSED') {
      print("---------------------Handle Payment result - CLOSED -----------");
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.pushReplacementNamed(
            context,
            RoutesName.cookingFailedCancelledPaymentScreen,
            arguments: {
              'trackingId': trackingId,
              'valId': paymentResult.validationId ?? 'N/A',
              'reason': 'Payment cancelled by user',
              'errorMessage': 'You cancelled the payment. You can retry whenever you\'re ready.',
              'isCancelled': true, // Payment cancelled
            },
          );
        }
      });
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Utils.flushBarErrorMessage(
            paymentResult.errorMessage ?? "Payment status unclear",
            context,
          );
        }
      });
    }
  }

  void _clearAllData() {
    final checkoutVM = Provider.of<CookingCheckoutViewModel>(context, listen: false);
    checkoutVM.reset();

    _addressController.clear();
    setState(() {
      _isTermsAccepted = false;
    });
  }

  List<Map<String, dynamic>> _prepareTasksData() {
    List<Map<String, dynamic>> tasks = [];

    if (widget.activeCategoryId == null) return tasks;

    for (var category in widget.categories) {
      if (category.id == widget.activeCategoryId) {
        if (category.type == 'REGULAR') {
          // Handle REGULAR package
          final selectedPackageId = widget.selectedPackages[category.id];
          if (selectedPackageId != null) {
            for (var package in category.packages ?? []) {
              if (package.id == selectedPackageId) {
                if (widget.selectedGuestRangeIndex < (package.prices?.length ?? 0)) {
                  final priceInfo = package.prices![widget.selectedGuestRangeIndex];

                  tasks.add({
                    'packageId': package.id,
                    'categoryId': category.id,
                    'type': 'REGULAR',
                    'guestRangeIndex': widget.selectedGuestRangeIndex,
                    'price': priceInfo.salePrice,
                    'originalPrice': priceInfo.originalPrice,
                  });
                }
                break;
              }
            }
          }
        } else if (category.type == 'MANUAL') {
          // Handle MANUAL items
          for (var package in category.packages ?? []) {
            for (var item in package.items ?? []) {
              final key = '${package.id}_${item.id}';
              if (widget.selectedManualItems[category.id]?.contains(key) ?? false) {
                if (widget.selectedGuestRangeIndex < (item.prices?.length ?? 0)) {
                  final priceInfo = item.prices![widget.selectedGuestRangeIndex];

                  tasks.add({
                    'packageId': package.id,
                    'itemId': item.id,
                    'categoryId': category.id,
                    'type': 'MANUAL',
                    'guestRangeIndex': widget.selectedGuestRangeIndex,
                    'price': priceInfo.salePrice,
                    'originalPrice': priceInfo.originalPrice,
                  });
                }
              }
            }
          }
        }
        break;
      }
    }

    return tasks;
  }
  Map<String, dynamic> _prepareBookingPayload() {
    if (widget.activeCategoryId == null) {
      throw Exception('No active category selected');
    }

    // Find the active category
    Datum? activeCategory;
    for (var category in widget.categories) {
      if (category.id == widget.activeCategoryId) {
        activeCategory = category;
        break;
      }
    }

    if (activeCategory == null) {
      throw Exception('Active category not found');
    }

    final checkoutVM = Provider.of<CookingCheckoutViewModel>(context, listen: false);

    // Base booking data
    Map<String, dynamic> bookingPayload = {
      "booking": {
        "paymentType": checkoutVM.getPaymentMethodData(checkoutVM.selectedPaymentMethod).toUpperCase(),
        "fullAddress": _addressController.text,
        "fullName":widget.customerName,
        "phone":widget.customerPhone,
        "date": widget.selectedDate?.toIso8601String() ?? DateTime.now().toIso8601String(),
        "slot": widget.selectedServiceTime?.toUpperCase() ?? 'DAY',
      },
      "eventCookingCategoryId": activeCategory.id,
    };

    if (activeCategory.type == 'REGULAR') {
      // REGULAR type: Single package selection
      final selectedPackageId = widget.selectedPackages[activeCategory.id];

      if (selectedPackageId == null) {
        throw Exception('No package selected');
      }

      // Find the selected package to get price ID
      String? priceId;
      for (var package in activeCategory.packages ?? []) {
        if (package.id == selectedPackageId) {
          if (widget.selectedGuestRangeIndex < (package.prices?.length ?? 0)) {
            priceId = package.prices![widget.selectedGuestRangeIndex].id;
          }
          break;
        }
      }

      bookingPayload["packages"] =[
        {
          "packageId": selectedPackageId,
          "priceId": priceId,
        }
      ];
    } else if (activeCategory.type == 'MANUAL') {
      // MANUAL type: Multiple items selection
      bookingPayload["eventCookingCategoryId"] = activeCategory.id;

      // Group items by package
      Map<String, List<Map<String, String>>> packageItemsMap = {};

      for (var package in activeCategory.packages ?? []) {
        for (var item in package.items ?? []) {
          final key = '${package.id}_${item.id}';

          if (widget.selectedManualItems[activeCategory.id]?.contains(key) ?? false) {
            // Get the price ID for this item
            String? priceId;
            if (widget.selectedGuestRangeIndex < (item.prices?.length ?? 0)) {
              priceId = item.prices![widget.selectedGuestRangeIndex].id;
            }

            if (!packageItemsMap.containsKey(package.id)) {
              packageItemsMap[package.id!] = [];
            }

            packageItemsMap[package.id]!.add({
              "itemId": item.id!,
              "priceId": priceId ?? item.id!, // Fallback to item.id if price not found
            });
          }
        }
      }

      // Convert map to packages array
      List<Map<String, dynamic>> packages = [];
      packageItemsMap.forEach((packageId, items) {
        packages.add({
          "packageId": packageId,
          "items": items,
        });
      });

      bookingPayload["packages"] = packages;
    }

    return bookingPayload;
  }
  Future<void> _handleConfirmBooking() async {
    final checkoutVM = Provider.of<CookingCheckoutViewModel>(context, listen: false);
    final bookingViewModel = Provider.of<PostBookFamilyEventCookingViewModel>(context, listen: false);

    // Calculate total amount
    double totalAmount = widget.totalPrice + widget.transportFee;

    // Validate form
    String? validationError = checkoutVM.validateCheckoutDetails(
      fullName: widget.customerName,
      phone: widget.customerPhone,
      address: _addressController.text,
      paymentMethod: checkoutVM.selectedPaymentMethod,
    );

    if (validationError != null) {
      Utils.flushBarErrorMessage(validationError, context);
      return;
    }

    if (!_isTermsAccepted) {
      Utils.flushBarErrorMessage("Please accept the Terms & Conditions to proceed", context);
      return;
    }

    try {
      // Prepare booking payload
      Map<String, dynamic> bookingPayload = _prepareBookingPayload();

      print('Booking Payload: $bookingPayload');

      // Call booking API
      await bookingViewModel.bookFamilyEventCookingPostApi(
        context,
        bookingPayload,
            (String? trackingId) async {
          print('Success! TrackingId: $trackingId');

          if (trackingId == null || trackingId.isEmpty) {
            Navigator.pushReplacementNamed(
              context,
              RoutesName.failedOrderScreenWidget,
              arguments: {
                'trackingId': 'N/A',
                'valId': 'N/A',
                'reason': 'Booking creation failed',
                'errorMessage': 'Unable to create booking. Please try again.',
              },
            );
            return;
          }

          if (checkoutVM.selectedPaymentMethod == 'online') {
            final paymentResult = await checkoutVM.initiatePayment(
              trackingId: trackingId,
              totalAmount: totalAmount,
              customerName: widget.customerName,
              customerPhone: widget.customerPhone,
              customerEmail: null,
              customerAddress: _addressController.text.trim(),
            );
            await _handlePaymentResult(
              viewModel: checkoutVM,
              paymentResult: paymentResult,
              trackingId: trackingId,
            );
          } else if (checkoutVM.selectedPaymentMethod == 'cash') {
            _clearAllData();
            Navigator.pop(context);
            Navigator.pushNamed(
              context,
              RoutesName.cookingConfirmedScreen,
              arguments: {
                'trackingId': trackingId,
                'valId': "COD",
              },
            );
          } else {
            Navigator.pushReplacementNamed(
              context,
              RoutesName.failedOrderScreenWidget,
              arguments: {
                'trackingId': trackingId,
                'valId': 'N/A',
                'reason': 'Invalid payment method',
                'errorMessage': 'The selected payment method is not available.',
              },
            );
          }
        },
      );
    } catch (e) {
      print('Booking error: $e');

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.pushReplacementNamed(
            context,
            RoutesName.failedOrderScreenWidget,
            arguments: {
              'trackingId': 'N/A',
              'valId': 'N/A',
              'reason': 'Booking failed',
              'errorMessage': 'An error occurred while processing your booking. Please try again.',
            },
          );
        }
      });
    }
  }

  String _getGuestRangeText() {
    final ranges = ['25-30', '30-35', '40-50'];
    if (widget.selectedGuestRangeIndex < ranges.length) {
      return ranges[widget.selectedGuestRangeIndex];
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<CookingCheckoutViewModel, PostBookFamilyEventCookingViewModel>(
      builder: (context, checkoutVM, bookingVM, _) {
        double total = widget.totalPrice + widget.transportFee;
        bool isLoading = bookingVM.createBookFamilyEventCookingLoading;

        return WillPopScope(
          onWillPop: () async {
            Navigator.pop(context, false);
            return false;
          },
          child: Scaffold(
            backgroundColor: AppColors.containerBackground(context),
            body: SafeArea(
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context, false),
                    child: Container(
                      height: 60,
                      child: AppBarHeader("Checkout"),
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildCustomerDetailsCard(),
                          SizedboxSpaccing.height02(context),
                          _buildBookingSummary(),
                          SizedboxSpaccing.height02(context),
                          _buildPaymentMethodSection(checkoutVM),
                          SizedboxSpaccing.height01(context),
                          DynamicTermsCheckbox(
                            isAccepted: _isTermsAccepted,
                            onChanged: (value) {
                              setState(() {
                                _isTermsAccepted = value;
                              });
                            },
                            context: context,
                            onTermsTap: () => Navigator.pushNamed(context, RoutesName.termsAndCondition),
                            onPrivacyTap: () => Navigator.pushNamed(context, RoutesName.privacyPolicy),
                            onRefundTap: () => Navigator.pushNamed(context, RoutesName.refundPolicyScreen),
                            getButtonColor: (context) => AppColors.button(context),
                            getBorderColor: (context) => AppColors.border(context),
                            getWhiteColor: (context) => AppColors.whiteColor,
                            getTextStyle: (context, {weight}) => AppTextStyles.textSize12(context, weight: weight ?? FontWeight.w400),
                          ),
                          SizedboxSpaccing.height03(context)
                        ],
                      ),
                    ),
                  ),
                  _buildConfirmButton(context, checkoutVM, bookingVM, total, isLoading),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleEditAddress() async {
    final result = await Navigator.pushNamed(
      context,
      RoutesName.addLocationScreenWidget,
    );

    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        String newAddress = '';

        if (result['addressType'] == 'saved') {
          newAddress = result['fullAddress'] ?? '';
        } else if (result['addressType'] == 'new') {
          newAddress = result['fullAddress'] ?? '';
        }

        _addressController.text = newAddress;

        if (widget.onAddressUpdate != null && newAddress.isNotEmpty) {
          widget.onAddressUpdate!(newAddress);
        }
      });
    }
  }

  Widget _buildCustomerDetailsCard() {
    final screenHeight = MediaQuery.of(context).size.height;
    return Container(
      padding: EdgeInsets.all(screenHeight * 0.015),
      decoration: BoxDecoration(
        color: AppColors.containerBackground(context),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Customer Details', style: AppTextStyles.textSize14(context, weight: FontWeight.w500)),
              GestureDetector(
                onTap: _handleEditAddress,
                child: Container(
                  width: 80,
                  color: Colors.transparent,
                  alignment: Alignment.centerRight,
                  child: Text('Edit', style: AppTextStyles.textSize14(context, weight: FontWeight.w500)),
                ),
              ),
            ],
          ),
          SizedboxSpaccing.height01(context),
          _buildDetailRow('Name', widget.customerName),
          SizedboxSpaccing.height01(context),
          _buildDetailRow('Phone', widget.customerPhone),
          SizedboxSpaccing.height01(context),
          _buildDetailRow('Address', _addressController.text.isEmpty ? widget.customerAddress : _addressController.text, isMultiline: true),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isMultiline = false}) {
    if (isMultiline) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label :  ', style: AppTextStyles.textSize14(context, weight: FontWeight.w400)),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.textSize14(context, weight: FontWeight.w500, color: AppColors.subtitle(context)),
              maxLines: null,
              softWrap: true,
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        Text('$label :  ', style: AppTextStyles.textSize14(context, weight: FontWeight.w400)),
        Text(value, style: AppTextStyles.textSize14(context, weight: FontWeight.w500, color: AppColors.subtitle(context))),
      ],
    );
  }

  Widget _buildBookingSummary() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Column(
      children: [
        SectionHeader(title: 'Booking Summary', titleWidth: screenWidth * 0.6, showSeeAll: false),
        SizedboxSpaccing.height02(context),
        Container(
          padding: EdgeInsets.all(screenHeight * 0.015),
          decoration: BoxDecoration(
            color: AppColors.containerBackground(context),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border(context)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Show selected package/items details
              _buildSelectedItemsSection(),
              SizedboxSpaccing.height015(context),
              _buildSummaryRow('Date', DateFormat('MMMM dd, yyyy').format(widget.selectedDate ?? DateTime.now())),
              SizedboxSpaccing.height015(context),
              _buildSummaryRow('Number of Guests', _getGuestRangeText()),
              SizedboxSpaccing.height015(context),
              _buildSummaryRow('Slot', widget.selectedServiceTime ?? 'Not selected'),
              SizedboxSpaccing.height015(context),
              _buildPriceRow('Subtotal', widget.totalPrice),
              SizedboxSpaccing.height015(context),
              _buildPriceRow('Transport', widget.transportFee),
              // if (widget.savedAmount > 0) ...[
              //   SizedboxSpaccing.height015(context),
              //   _buildPriceRow('You Saved', widget.savedAmount, isGreen: true),
              // ],
              // SizedboxSpaccing.height02(context),
              // Divider(height: 1, color: AppColors.border(context)),
              // SizedboxSpaccing.height02(context),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //   children: [
              //     Text('Total Amount', style: AppTextStyles.textSize16(context, weight: FontWeight.w600)),
              //     Text(
              //       '৳${(widget.totalPrice + widget.transportFee).toStringAsFixed(0)}',
              //       style: AppTextStyles.textSize18(context, weight: FontWeight.w700, color: AppColors.buttonTextColor(context)),
              //     ),
              //   ],
              // ),
            ],
          ),
        ),
      ],
    );
  }


// Build selected items section
  Widget _buildSelectedItemsSection() {
    if (widget.activeCategoryId == null) return SizedBox.shrink();

    for (var category in widget.categories) {
      if (category.id == widget.activeCategoryId) {
        if (category.type == 'REGULAR') {
          return _buildRegularPackageDetails(category);
        } else if (category.type == 'MANUAL') {
          return _buildManualItemsDetails(category);
        }
      }
    }
    return SizedBox.shrink();
  }

// Build REGULAR package details
  Widget _buildRegularPackageDetails(Datum category) {
    final selectedPackageId = widget.selectedPackages[category.id];
    if (selectedPackageId == null) return SizedBox.shrink();

    for (var package in category.packages ?? []) {
      if (package.id == selectedPackageId) {
        double salePrice = 0;
        double originalPrice = 0;

        if (widget.selectedGuestRangeIndex < (package.prices?.length ?? 0)) {
          salePrice = package.prices![widget.selectedGuestRangeIndex].salePrice?.toDouble() ?? 0;
          originalPrice = package.prices![widget.selectedGuestRangeIndex].originalPrice?.toDouble() ?? 0;
        }

        double savedAmount = originalPrice - salePrice;

        return       Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              package.name ?? '',
              style: AppTextStyles.textSize14(context, weight: FontWeight.w400),
            ),
            Row(
              children: [
                Text(
                  '৳${salePrice.toStringAsFixed(2)}',
                  style: AppTextStyles.textSize14(context, weight: FontWeight.w600),
                ),
                if (savedAmount > 0) ...[
                  SizedBox(width: 8),
                  Text(
                    '৳${originalPrice.toStringAsFixed(0)}',
                    style: AppTextStyles.textSize12(context, color: AppColors.subtitle(context))
                        .copyWith(decoration: TextDecoration.lineThrough),
                  ),
                ],
              ],
            ),
          ],
        );
      }
    }
    return SizedBox.shrink();
  }

// Build MANUAL items details
  Widget _buildManualItemsDetails(Datum category) {
    List<Map<String, dynamic>> selectedItems = [];
    double totalSalePrice = 0;
    double totalOriginalPrice = 0;

    for (var package in category.packages ?? []) {
      for (var item in package.items ?? []) {
        final key = '${package.id}_${item.id}';
        if (widget.selectedManualItems[category.id]?.contains(key) ?? false) {
          double salePrice = 0;
          double originalPrice = 0;

          if (widget.selectedGuestRangeIndex < (item.prices?.length ?? 0)) {
            salePrice = item.prices![widget.selectedGuestRangeIndex].salePrice?.toDouble() ?? 0;
            originalPrice = item.prices![widget.selectedGuestRangeIndex].originalPrice?.toDouble() ?? 0;
          }

          totalSalePrice += salePrice;
          totalOriginalPrice += originalPrice;

          selectedItems.add({
            'name': item.name ?? '',
            'salePrice': salePrice,
            'originalPrice': originalPrice,
          });
        }
      }
    }

    if (selectedItems.isEmpty) return SizedBox.shrink();

    double totalSaved = totalOriginalPrice - totalSalePrice;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${category.name ?? ''}',
          style: AppTextStyles.textSize14(context, weight: FontWeight.w600,),
        ),
        SizedBox(height: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...selectedItems.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isLast = index == selectedItems.length - 1;

              return Padding(
                padding: EdgeInsets.only(bottom: isLast ? 0 : 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        '${item['name']}',
                        style: AppTextStyles.textSize12(context, weight: FontWeight.w400),
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          '৳${item['salePrice'].toStringAsFixed(2)}',
                          style: AppTextStyles.textSize12(context, weight: FontWeight.w500),
                        ),
                        if (item['originalPrice'] > item['salePrice']) ...[
                          SizedBox(width: 6),
                          Text(
                            '৳${item['originalPrice'].toStringAsFixed(0)}',
                            style: AppTextStyles.textSize10(context, color: AppColors.subtitle(context))
                                .copyWith(decoration: TextDecoration.lineThrough),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.textSize14(context, weight: FontWeight.w400)),
        Expanded(
          child: Text(
            value,
            style: AppTextStyles.textSize14(context, weight: FontWeight.w500),
            textAlign: TextAlign.end,
            maxLines: null,
            softWrap: true,
          ),
        ),
      ],
    );
  }

  Widget _buildPriceRow(String label, double amount, {bool isGreen = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.textSize14(context, weight: FontWeight.w400)),
        Text(
          '৳${amount.toStringAsFixed(0)}',
          style: AppTextStyles.textSize14(
            context,
            weight: FontWeight.w500,
            color: isGreen ? Colors.green : AppColors.textPrimary(context),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethodSection(CookingCheckoutViewModel viewModel) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Column(
      children: [
        SectionHeader(title: 'Payment Method', titleWidth: screenWidth * 0.6, showSeeAll: false),
        SizedboxSpaccing.height02(context),
        PaymentMethodWidget(
          selectedPaymentMethod: viewModel.selectedPaymentMethod,
          paymentMethods: viewModel.paymentMethods,
          onPaymentMethodChanged: (method) => viewModel.setPaymentMethod(method),
        ),
      ],
    );
  }

  Widget _buildConfirmButton(
      BuildContext context,
      CookingCheckoutViewModel checkoutVM,
      PostBookFamilyEventCookingViewModel bookingVM,
      double total,
      bool isLoading,
      ) {
    return Container(
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.button(context),
        border: Border(top: BorderSide(color: AppColors.border(context), width: 1)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Total Amount',
                  style: AppTextStyles.textSize14(context, color: AppColors.whiteColor),
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '৳${total.toStringAsFixed(2)}',
                      style: AppTextStyles.textSize20(context, weight: FontWeight.w700, color: AppColors.whiteColor),
                    ),
                    if (widget.savedAmount > 0) ...[
                      SizedBox(width: 8),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Saved ৳${widget.savedAmount.toStringAsFixed(0)}',
                          style: AppTextStyles.textSize12(context, color: Colors.greenAccent, weight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: isLoading ? null : _handleConfirmBooking,
            child: Container(
              height: 50,
              width: 140,
              decoration: BoxDecoration(
                color: isLoading ? AppColors.blackColor.withOpacity(0.6) : AppColors.blackColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(width: 1, color: AppColors.whiteColor),
              ),
              child: isLoading
                  ? Center(
                child: LoadingAnimationWidget.progressiveDots(color: AppColors.whiteColor, size: 30),
              )
                  : Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Pay Now', style: AppTextStyles.textSize16(context, weight: FontWeight.w600, color: Colors.white)),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward, color: Colors.white, size: 18),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
