// import 'package:dinmajur_customer/configs/res/color.dart';
// import 'package:dinmajur_customer/configs/res/components/header_appbar.dart';
// import 'package:dinmajur_customer/configs/responsive/responsive_ui.dart';
// import 'package:flutter/material.dart';
// import 'package:webview_flutter/webview_flutter.dart';
//
// class PaymentWebViewScreen extends StatefulWidget {
//   final String paymentUrl;
//   final String? trackingId;
//
//   const PaymentWebViewScreen({Key? key, required this.paymentUrl, this.trackingId}) : super(key: key);
//
//   @override
//   State<PaymentWebViewScreen> createState() => _PaymentWebViewScreenState();
// }
//
// class _PaymentWebViewScreenState extends State<PaymentWebViewScreen> {
//   late final WebViewController _controller;
//   bool _isLoading = true;
//   double _progress = 0.0;
//   bool _hasNavigatedBack = false;
//
//   @override
//   void initState() {
//     super.initState();
//     print('Initial Payment URL: ${widget.paymentUrl}');
//     _initializeWebView();
//   }
//
//   void _initializeWebView() {
//     _controller = WebViewController()
//       ..setJavaScriptMode(JavaScriptMode.unrestricted)
//       ..setBackgroundColor(Colors.white)
//       ..setNavigationDelegate(
//         NavigationDelegate(
//           onProgress: (int progress) {
//             if (!_hasNavigatedBack) {
//               setState(() {
//                 _progress = progress / 100;
//               });
//             }
//           },
//           onPageStarted: (String url) {
//             if (!_hasNavigatedBack) {
//               setState(() {
//                 _isLoading = true;
//               });
//               print('Page started loading: $url');
//             }
//           },
//           onPageFinished: (String url) {
//             if (_hasNavigatedBack) return;
//
//             setState(() {
//               _isLoading = false;
//             });
//             print('Page finished loading: $url');
//             _checkPaymentStatus(url);
//           },
//           onWebResourceError: (WebResourceError error) {
//             print('WebView error: ${error.description}');
//             if (!_hasNavigatedBack) {
//               setState(() {
//                 _isLoading = false;
//               });
//             }
//           },
//           onNavigationRequest: (NavigationRequest request) {
//             print('Navigation request: ${request.url}');
//             return NavigationDecision.navigate;
//           },
//         ),
//       )
//       ..loadRequest(Uri.parse(widget.paymentUrl));
//   }
//
//   void _checkPaymentStatus(String url) {
//     if (_hasNavigatedBack) return;
//
//     print('Checking payment status for URL: $url');
//
//     if (url.contains('/payment-success') || url.contains('/success?') || url.contains('status=success') || url.contains('payment_status=success')) {
//       _handlePaymentSuccess();
//     } else if (url.contains('/payment-failed') || url.contains('/fail?') || url.contains('status=failed') || url.contains('payment_status=failed')) {
//       _handlePaymentFailure();
//     } else if (url.contains('/payment-cancel') || url.contains('/cancel?') || url.contains('status=cancel') || url.contains('payment_status=cancel')) {
//       _handlePaymentCancel();
//     }
//   }
//
//   void _handlePaymentSuccess() {
//     if (_hasNavigatedBack) return;
//     _hasNavigatedBack = true;
//
//     print('Payment Success!');
//     print("A --------------${widget.trackingId}");
//
//     if (mounted) {
//       Navigator.pop(context, {'status': 'success', 'trackingId': widget.trackingId});
//     }
//   }
//
//   void _handlePaymentFailure() {
//     if (_hasNavigatedBack) return;
//     _hasNavigatedBack = true;
//
//     print('Payment Failed!');
//     print("B --------------${widget.trackingId}");
//
//     if (mounted) {
//       Navigator.pop(context, {'status': 'failed', 'trackingId': widget.trackingId});
//     }
//   }
//
//   void _handlePaymentCancel() {
//     if (_hasNavigatedBack) return;
//     _hasNavigatedBack = true;
//
//     print('Payment Cancelled!');
//     print("C --------------${widget.trackingId}");
//
//     if (mounted) {
//       Navigator.pop(context, {'status': 'cancelled', 'trackingId': widget.trackingId});
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: () async {
//         _showExitConfirmation();
//         return false;
//       },
//       child: SafeArea(
//         child: Scaffold(
//           backgroundColor: AppColors.containerBackground(context),
//           body: ResPonsiveUi(mobile: _buildBody(), desktop: _buildBody(), tablet: _buildBody()),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildBody() {
//     return Column(
//       children: [
//         GestureDetector(
//           onTap: () {
//             _showExitConfirmation();
//           },
//           child: Container(height: 60, child: AppBarHeader("Payment Gateway")),
//         ),
//         if (_isLoading) LinearProgressIndicator(value: _progress, backgroundColor: Colors.grey[200], valueColor: AlwaysStoppedAnimation<Color>(AppColors.button(context))),
//         Expanded(
//           child: Stack(
//             children: [
//               WebViewWidget(controller: _controller),
//               if (_isLoading)
//                 Center(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       CircularProgressIndicator(color: AppColors.button(context)),
//                       SizedBox(height: 16),
//                       Text('Loading payment gateway...', style: TextStyle(color: AppColors.subtitle(context), fontSize: 14)),
//                     ],
//                   ),
//                 ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
//
//   void _showExitConfirmation() {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           backgroundColor: AppColors.containerBackground(context),
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//           title: Text(
//             'Exit Payment?',
//             style: TextStyle(color: AppColors.textPrimary(context), fontSize: 18, fontWeight: FontWeight.w600),
//           ),
//           content: Text('Are you sure you want to exit? Your payment will be cancelled.', style: TextStyle(color: AppColors.subtitle(context), fontSize: 14)),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: Text(
//                 'Continue Payment',
//                 style: TextStyle(color: AppColors.button(context), fontWeight: FontWeight.w500),
//               ),
//             ),
//             TextButton(
//               onPressed: () {
//                 Navigator.pop(context);
//                 _hasNavigatedBack = true;
//                 Navigator.pop(context, {'status': 'cancelled'});
//               },
//               child: Text(
//                 'Exit',
//                 style: TextStyle(color: Colors.red, fontWeight: FontWeight.w500),
//               ),
//             ),
//           ],
//         );
//       },
//     );
//   }
// }
