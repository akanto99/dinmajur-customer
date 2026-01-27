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
// import 'package:dinmajur_customer/model/home_models/dropdown_categories_selection_models/beauty_and_salon_model/getall_premium_home_beauty_salon_model.dart';
// import 'package:dinmajur_customer/view/screens/home/dorpdown_categories_selections_and_views/beauty_and_salon/notifier/checkout_notifier.dart';
// import 'package:dinmajur_customer/view/screens/home/payment_webview_helper_class/payment_webview.dart';
// import 'package:dinmajur_customer/view_model/homeview_model/dropdown_categories_selection_view_models/beauty_and_salon_view_model/book_premium_home_beauty_salon_view_model.dart';
// import 'package:dinmajur_customer/view_model/homeview_model/dropdown_categories_selection_view_models/beauty_and_salon_view_model/getall_premium_home_beauty_salon_view_model.dart';
// import 'package:flutter/material.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:intl/intl.dart';
// import 'package:loading_animation_widget/loading_animation_widget.dart';
// import 'package:provider/provider.dart';
//
// class CheckoutScreen extends StatefulWidget {
//   final String customerName;
//   final String customerPhone;
//   final String customerAddress;
//   final String userId;
//   final List<Datum> categories;
//   final Map<String, int> serviceQuantities;
//   final double totalPrice;
//   final double transportFee;
//   final Function(String)? onAddressUpdate;
//
//   const CheckoutScreen({
//     Key? key,
//     required this.customerName,
//     required this.customerPhone,
//     required this.customerAddress,
//     required this.userId,
//     required this.categories,
//     required this.serviceQuantities,
//     required this.totalPrice,
//     required this.transportFee,
//     required this.onAddressUpdate,
//   }) : super(key: key);
//
//   @override
//   State<CheckoutScreen> createState() => _CheckoutScreenState();
// }
//
// class _CheckoutScreenState extends State<CheckoutScreen> {
//   final TextEditingController _fullNameController = TextEditingController();
//   final TextEditingController _phoneController = TextEditingController();
//   final TextEditingController _addressController = TextEditingController();
//   final TextEditingController _specialRequestController = TextEditingController();
//   final TextEditingController _dateController = TextEditingController();
//   bool _isTermsAccepted = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _fullNameController.text = widget.customerName;
//     _phoneController.text = widget.customerPhone;
//     _addressController.text = widget.customerAddress;
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       final checkoutVM = Provider.of<CheckoutBeautySalonViewModel>(context, listen: false);
//       if (checkoutVM.selectedDate != null) {
//         _dateController.text = DateFormat('MMMM dd, yyyy').format(checkoutVM.selectedDate!);
//       }
//     });
//   }
//
//   @override
//   void dispose() {
//     _fullNameController.dispose();
//     _phoneController.dispose();
//     _addressController.dispose();
//     _specialRequestController.dispose();
//     _dateController.dispose();
//     super.dispose();
//   }
//
//   void _clearAllData() {
//     final checkoutVM = Provider.of<CheckoutBeautySalonViewModel>(context, listen: false);
//     checkoutVM.reset();
//
//     _fullNameController.clear();
//     _phoneController.clear();
//     _addressController.clear();
//     _specialRequestController.clear();
//     _dateController.clear();
//     setState(() {
//       _isTermsAccepted = false;
//     });
//   }
//
//   Future<void> _handleConfirmBooking() async {
//     final checkoutVM = Provider.of<CheckoutBeautySalonViewModel>(context, listen: false);
//     final bookingViewModel = Provider.of<PostBookPremiumHomeBeautySalonViewModel>(context, listen: false);
//
//     // ✅ Use bookingViewModel's loading state instead
//     if (bookingViewModel.createBookPremiumHomeBeautySalonLoading) {
//       print('⚠️ Already processing payment, ignoring duplicate tap');
//       return;
//     }
//
//     // Calculate total amount
//     double subtotal = checkoutVM.calculateTotal(serviceQuantities: widget.serviceQuantities, categories: widget.categories);
//     double totalAmount = subtotal + widget.transportFee;
//
//     // Validate form
//     String? validationError = checkoutVM.validateCheckoutDetails(
//       fullName: _fullNameController.text,
//       phone: _phoneController.text,
//       address: _addressController.text,
//       paymentMethod: checkoutVM.selectedPaymentMethod,
//     );
//
//     if (validationError != null) {
//       Utils.flushBarErrorMessage(validationError, context);
//       return;
//     }
//     if (!_isTermsAccepted) {
//       Utils.flushBarErrorMessage("Please accept the Terms & Conditions to proceed", context);
//       return;
//     }
//
//     // Prepare tasks data
//     List<Map<String, dynamic>> tasks = checkoutVM.prepareTasksData(serviceQuantities: widget.serviceQuantities, categories: widget.categories);
//
//     // Prepare booking data
//     Map<String, dynamic> bookingData = checkoutVM.prepareBookingData(
//       userId: widget.userId,
//       fullName: _fullNameController.text,
//       phone: _phoneController.text,
//       address: _addressController.text,
//       specialRequest: _specialRequestController.text,
//       selectedDate: checkoutVM.selectedDate!,
//       serviceTime: checkoutVM.selectedServiceTime!,
//       tasks: tasks,
//       paymentMethod: checkoutVM.selectedPaymentMethod,
//       source:"android",
//     );
//
//     print('Booking Data: $bookingData');
//
//     try {
//       // Call booking API with paymentUrl and trackingId callback
//       await bookingViewModel.bookPremiumHomeBeautySalonPostApi(context, bookingData, (String? paymentUrl, String? trackingId) async {
//         print('Success! Payment URL: $paymentUrl, TrackingId: $trackingId');
//
//         if (trackingId == null || trackingId.isEmpty) {
//           Navigator.pushReplacementNamed(
//             context,
//             RoutesName.failedOrderScreenWidget,
//             arguments: {'trackingId': 'N/A', 'valId': 'N/A', 'reason': 'Booking creation failed', 'errorMessage': 'Unable to create booking. Please try again.'},
//           );
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
//           // Handle payment result from WebView
//           if (result != null && result is Map<String, dynamic>) {
//             String status = result['status'] ?? '';
//
//             if (status == 'success') {
//               // Payment successful
//               _clearAllData();
//               Navigator.pop(context);
//
//               Navigator.pushNamed(context, RoutesName.beautyConfirmedScreen, arguments: {'trackingId': trackingId, 'valId': 'ONLINE_PAYMENT'});
//             } else if (status == 'failed') {
//               // Payment failed
//               print("---------------------Payment FAILED -----------");
//               WidgetsBinding.instance.addPostFrameCallback((_) {
//                 if (mounted) {
//                   Navigator.pushReplacementNamed(
//                     context,
//                     RoutesName.beautyFailedCancelledPaymentScreen,
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
//                     RoutesName.beautyFailedCancelledPaymentScreen,
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
//           Navigator.pop(context);
//           Navigator.pushNamed(context, RoutesName.beautyConfirmedScreen, arguments: {'trackingId': trackingId, 'valId': "COD"});
//         } else {
//           // No payment URL received for online payment
//           Utils.flushBarErrorMessage("Payment gateway URL not available", context);
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
//   @override
//   Widget build(BuildContext context) {
//     return Consumer2<CheckoutBeautySalonViewModel, PostBookPremiumHomeBeautySalonViewModel>(
//       builder: (context, checkoutVM, bookingVM, _) {
//         double subtotal = checkoutVM.calculateTotal(serviceQuantities: widget.serviceQuantities, categories: widget.categories);
//         double total = subtotal + widget.transportFee;
//         double saved = checkoutVM.calculateSaved(serviceQuantities: widget.serviceQuantities, categories: widget.categories);
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
//                           _buildSelectedServicesList(checkoutVM, subtotal, saved),
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
//                   _buildConfirmButton(context, checkoutVM, bookingVM, total, saved),
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
//   Widget _buildDetailRow1(String label, String value) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Text('$label', style: AppTextStyles.textSize14(context, weight: FontWeight.w400)),
//         Expanded(
//           child: Text(
//             value,
//             style: AppTextStyles.textSize14(context, weight: FontWeight.w400),
//             textAlign: TextAlign.end,
//             maxLines: null,
//             softWrap: true,
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildPaymentMethodSection(CheckoutBeautySalonViewModel viewModel) {
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
//   Widget _buildSelectedServicesList(CheckoutBeautySalonViewModel checkoutVM, double subtotal, double saved) {
//     // Get all selected services from all categories
//     List<Map<String, dynamic>> selectedServices = [];
//
//     for (var category in widget.categories) {
//       if (category.items != null) {
//         for (var service in category.items!) {
//           int qty = widget.serviceQuantities[service.id ?? ''] ?? 0;
//           if (qty > 0) {
//             selectedServices.add({'service': service, 'quantity': qty});
//           }
//         }
//       }
//     }
//
//     if (selectedServices.isEmpty) {
//       return SizedBox.shrink();
//     }
//
//     double total = subtotal + widget.transportFee;
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
//               ...selectedServices.map((item) {
//                 Item service = item['service'];
//                 int quantity = item['quantity'];
//
//                 // Get prices from the service
//                 double originalPrice = service.originalPrice?.toDouble() ?? 0;
//                 double discountedPrice = service.salePrice?.toDouble() ?? originalPrice;
//
//                 // Total prices (multiplied by quantity)
//                 double totalOriginalPrice = originalPrice * quantity;
//                 double totalDiscountedPrice = discountedPrice * quantity;
//
//                 // Check if there's an actual discount
//                 bool hasDiscount = service.discountValue != null && originalPrice > discountedPrice && originalPrice > 0;
//
//                 return Container(
//                   padding: EdgeInsets.only(bottom: screenHeight * 0.02),
//                   child: Row(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Expanded(
//                         child: Row(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Expanded(
//                               child: Text("${service.name ?? ''}($quantity)", style: AppTextStyles.textSize14(context, weight: FontWeight.w400), maxLines: null, softWrap: true),
//                             ),
//                             SizedBox(width: 8),
//                             Row(
//                               crossAxisAlignment: CrossAxisAlignment.end,
//                               children: [
//                                 Text('৳${totalDiscountedPrice.toStringAsFixed(2)}', style: AppTextStyles.textSize14(context, weight: FontWeight.w400)),
//                                 if (hasDiscount) ...[
//                                   SizedboxSpaccing.width01(context),
//                                   Text(
//                                     '৳${totalOriginalPrice.toStringAsFixed(2)}',
//                                     style: AppTextStyles.textSize12(context, color: AppColors.subtitle(context)).copyWith(decoration: TextDecoration.lineThrough),
//                                   ),
//                                 ],
//                               ],
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 );
//               }).toList(),
//               _buildDetailRow1('Date', DateFormat('MMMM dd, yyyy').format(checkoutVM.selectedDate ?? DateTime.now())),
//               SizedboxSpaccing.height02(context),
//               _buildDetailRow1('Slot', checkoutVM.selectedServiceTime ?? 'Not selected'),
//               SizedboxSpaccing.height02(context),
//               _buildPriceRow('Transport', widget.transportFee),
//               SizedboxSpaccing.height02(context),
//               _buildPriceRow('Subtotal', subtotal),
//             ],
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
//           '৳${amount.toStringAsFixed(2)}',
//           style: AppTextStyles.textSize14(context, weight: FontWeight.w400, color: isGreen ? Colors.green : AppColors.textPrimary(context)),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildConfirmButton(BuildContext context, CheckoutBeautySalonViewModel checkoutVM, PostBookPremiumHomeBeautySalonViewModel bookingVM, double total, double saved) {
//     int totalItems = checkoutVM.getTotalItems(widget.serviceQuantities);
//
//     // ✅ Disable button when processing OR when loading0
//     bool isButtonDisabled = bookingVM.createBookPremiumHomeBeautySalonLoading;
//
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
//                 Text('Total Services ($totalItems item${totalItems > 1 ? 's' : ''})', style: AppTextStyles.textSize12(context, color: AppColors.whiteColor)),
//                 SizedBox(height: 4),
//                 Row(
//                   children: [
//                     Text(
//                       '৳${total.toStringAsFixed(2)}',
//                       style: AppTextStyles.textSize18(context, weight: FontWeight.w600, color: AppColors.whiteColor),
//                     ),
//                     if (saved > 0) ...[
//                       SizedBox(width: 8),
//                       Text(
//                         'Saved ৳${saved.toStringAsFixed(2)}',
//                         style: AppTextStyles.textSize12(context, color: Colors.green, weight: FontWeight.w500),
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
//               onTap: _handleConfirmBooking,
//               child: Container(
//                 height: 40,
//                 width: 140,
//                 decoration: BoxDecoration(
//                   color: isButtonDisabled
//                       ? AppColors.blackColor.withOpacity(0.5) // ✅ Visual feedback when disabled
//                       : AppColors.blackColor,
//                   borderRadius: BorderRadius.circular(8),
//                   border: Border.all(width: 1, color: AppColors.whiteColor),
//                 ),
//                 child: isButtonDisabled
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
import 'package:dinmajur_customer/model/home_models/dropdown_categories_selection_models/beauty_and_salon_model/getall_premium_home_beauty_salon_model.dart';
import 'package:dinmajur_customer/view/screens/home/dorpdown_categories_selections_and_views/beauty_and_salon/notifier/checkout_notifier.dart';
import 'package:dinmajur_customer/view_model/homeview_model/dropdown_categories_selection_view_models/beauty_and_salon_view_model/book_premium_home_beauty_salon_view_model.dart';
import 'package:dinmajur_customer/view_model/homeview_model/dropdown_categories_selection_view_models/beauty_and_salon_view_model/getall_premium_home_beauty_salon_view_model.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';

class CheckoutScreen extends StatefulWidget {
  final String customerName;
  final String customerPhone;
  final String customerAddress;
  final String userId;
  final List<Datum> categories;
  final Map<String, int> serviceQuantities;
  final double totalPrice;
  final double transportFee;
  final Function(String)? onAddressUpdate;

  const CheckoutScreen({
    Key? key,
    required this.customerName,
    required this.customerPhone,
    required this.customerAddress,
    required this.userId,
    required this.categories,
    required this.serviceQuantities,
    required this.totalPrice,
    required this.transportFee,
    required this.onAddressUpdate,
  }) : super(key: key);

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _specialRequestController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  bool _isTermsAccepted = false;
  @override
  void initState() {
    super.initState();
    _fullNameController.text = widget.customerName;
    _phoneController.text = widget.customerPhone;
    _addressController.text = widget.customerAddress;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final checkoutVM = Provider.of<CheckoutBeautySalonViewModel>(context, listen: false);
      if (checkoutVM.selectedDate != null) {
        _dateController.text = DateFormat('MMMM dd, yyyy').format(checkoutVM.selectedDate!);
      }
    });
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _specialRequestController.dispose();
    _dateController.dispose();
    super.dispose();
  }
  Future<void> _handlePaymentResult({
    required CheckoutBeautySalonViewModel viewModel,
    required SSLPaymentResult paymentResult,
    required String trackingId,
  }) async {
    if (!mounted) return;

    if (paymentResult.success) {
      _clearAllData();
      Navigator.pushReplacementNamed(
        context,
        RoutesName.beautyConfirmedScreen,
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
            RoutesName.beautyFailedCancelledPaymentScreen,
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
            RoutesName.beautyFailedCancelledPaymentScreen,
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
    final checkoutVM = Provider.of<CheckoutBeautySalonViewModel>(context, listen: false);
    checkoutVM.reset();

    _fullNameController.clear();
    _phoneController.clear();
    _addressController.clear();
    _specialRequestController.clear();
    _dateController.clear();
    setState(() {
      _isTermsAccepted = false;
    });
  }

  Future<void> _handleConfirmBooking() async {
    final checkoutVM = Provider.of<CheckoutBeautySalonViewModel>(context, listen: false);
    final bookingViewModel = Provider.of<PostBookPremiumHomeBeautySalonViewModel>(context, listen: false);

    // Calculate total amount
    double subtotal = checkoutVM.calculateTotal(
      serviceQuantities: widget.serviceQuantities,
      categories: widget.categories,
    );
    double totalAmount = subtotal + widget.transportFee;

    // Validate form
    String? validationError = checkoutVM.validateCheckoutDetails(
      fullName: _fullNameController.text,
      phone: _phoneController.text,
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
    // Prepare tasks data
    List<Map<String, dynamic>> tasks = checkoutVM.prepareTasksData(
      serviceQuantities: widget.serviceQuantities,
      categories: widget.categories,
    );

    // Prepare booking data
    Map<String, dynamic> bookingData = checkoutVM.prepareBookingData(
      userId: widget.userId,
      fullName: _fullNameController.text,
      phone: _phoneController.text,
      address: _addressController.text,
      specialRequest: _specialRequestController.text,
      selectedDate: checkoutVM.selectedDate!,
      serviceTime: checkoutVM.selectedServiceTime!,
      tasks: tasks,
      paymentMethod: checkoutVM.selectedPaymentMethod,
    );

    print('Booking Data: $bookingData');

    try {
      // Call booking API
      await bookingViewModel.bookPremiumHomeBeautySalonPostApi(
        context,
        bookingData,
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
              customerName: _fullNameController.text.trim(),
              customerPhone: _phoneController.text.trim(),
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
              RoutesName.beautyConfirmedScreen,
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

  @override
  Widget build(BuildContext context) {
    return Consumer2<CheckoutBeautySalonViewModel, PostBookPremiumHomeBeautySalonViewModel>(
      builder: (context, checkoutVM, bookingVM, _) {
        double subtotal = checkoutVM.calculateTotal(
          serviceQuantities: widget.serviceQuantities,
          categories: widget.categories,
        );
        double total = subtotal + widget.transportFee;
        double saved = checkoutVM.calculateSaved(
          serviceQuantities: widget.serviceQuantities,
          categories: widget.categories,
        );

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
                          _buildSelectedServicesList(checkoutVM, subtotal, saved),
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
                  _buildConfirmButton(context, checkoutVM, bookingVM, total, saved),
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

  Widget _buildDetailRow1(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('$label', style: AppTextStyles.textSize14(context, weight: FontWeight.w400)),
        Expanded(
          child: Text(
            value,
            style: AppTextStyles.textSize14(context, weight: FontWeight.w400),
            textAlign: TextAlign.end,
            maxLines: null,
            softWrap: true,
          ),
        ),
      ],
    );
  }


  Widget _buildPaymentMethodSection(CheckoutBeautySalonViewModel viewModel) {
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


  Widget _buildSelectedServicesList(CheckoutBeautySalonViewModel checkoutVM, double subtotal, double saved) {
    // Get all selected services from all categories
    List<Map<String, dynamic>> selectedServices = [];

    for (var category in widget.categories) {
      if (category.items != null) {
        for (var service in category.items!) {
          int qty = widget.serviceQuantities[service.id ?? ''] ?? 0;
          if (qty > 0) {
            selectedServices.add({
              'service': service,
              'quantity': qty,
            });
          }
        }
      }
    }

    if (selectedServices.isEmpty) {
      return SizedBox.shrink();
    }

    double total = subtotal + widget.transportFee;
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
              ...selectedServices.map((item) {
                Item service = item['service'];
                int quantity = item['quantity'];

                // Get prices from the service
                double originalPrice = service.originalPrice?.toDouble() ?? 0;
                double discountedPrice = service.salePrice?.toDouble() ?? originalPrice;

                // Total prices (multiplied by quantity)
                double totalOriginalPrice = originalPrice * quantity;
                double totalDiscountedPrice = discountedPrice * quantity;

                // Check if there's an actual discount
                bool hasDiscount = service.discountValue != null && originalPrice > discountedPrice && originalPrice > 0;

                return Container(
                  padding: EdgeInsets.only(bottom: screenHeight * 0.02),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                "${service.name ?? ''}($quantity)",
                                style: AppTextStyles.textSize14(context, weight: FontWeight.w400),
                                maxLines: null,
                                softWrap: true,
                              ),
                            ),
                            SizedBox(width: 8),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '৳${totalDiscountedPrice.toStringAsFixed(2)}',
                                  style: AppTextStyles.textSize14(context, weight: FontWeight.w400),
                                ),
                                if (hasDiscount) ...[
                                  SizedboxSpaccing.width01(context),
                                  Text(
                                    '৳${totalOriginalPrice.toStringAsFixed(2)}',
                                    style: AppTextStyles.textSize12(context, color: AppColors.subtitle(context))
                                        .copyWith(decoration: TextDecoration.lineThrough),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              _buildDetailRow1('Date', DateFormat('MMMM dd, yyyy').format(checkoutVM.selectedDate ?? DateTime.now())),
              SizedboxSpaccing.height02(context),
              _buildDetailRow1('Slot', checkoutVM.selectedServiceTime ?? 'Not selected'),
              SizedboxSpaccing.height02(context),
              _buildPriceRow('Transport', widget.transportFee),
              SizedboxSpaccing.height02(context),
              _buildPriceRow('Subtotal', subtotal),
              // if (saved > 0) ...[
              //   SizedboxSpaccing.height02(context),
              //   _buildPriceRow('Saved', saved, isGreen: true),
              // ],
              // Divider(height: 20, color: AppColors.border(context)),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //   children: [
              //     Text('Total', style: AppTextStyles.textSize16(context, weight: FontWeight.w600)),
              //     Text(
              //       '৳${total.toStringAsFixed(2)}',
              //       style: AppTextStyles.textSize18(context, weight: FontWeight.w700, color: AppColors.button(context)),
              //     ),
              //   ],
              // ),
            ],
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
          '৳${amount.toStringAsFixed(2)}',
          style: AppTextStyles.textSize14(context, weight: FontWeight.w400, color: isGreen ? Colors.green : AppColors.textPrimary(context)),
        ),
      ],
    );
  }

  Widget _buildConfirmButton(
      BuildContext context,
      CheckoutBeautySalonViewModel checkoutVM,
      PostBookPremiumHomeBeautySalonViewModel bookingVM,
      double total,
      double saved,
      ) {
    int totalItems = checkoutVM.getTotalItems(widget.serviceQuantities);
    bool isLoading = bookingVM.createBookPremiumHomeBeautySalonLoading;

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
                  'Total Services ($totalItems item${totalItems > 1 ? 's' : ''})',
                  style: AppTextStyles.textSize12(context, color: AppColors.whiteColor),
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '৳${total.toStringAsFixed(2)}',
                      style: AppTextStyles.textSize18(context, weight: FontWeight.w600, color: AppColors.whiteColor),
                    ),
                    if (saved > 0) ...[
                      SizedBox(width: 8),
                      Text(
                        'Saved ৳${saved.toStringAsFixed(2)}',
                        style: AppTextStyles.textSize12(context, color: Colors.green, weight: FontWeight.w500),
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
              height: 40,
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
