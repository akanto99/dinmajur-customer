import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/components/header_appbar.dart';
import 'package:dinmajur_customer/configs/responsive/responsive_ui.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PaymentWebViewScreen extends StatefulWidget {
  final String paymentUrl;
  final String? trackingId;

  const PaymentWebViewScreen({
    Key? key,
    required this.paymentUrl,
    this.trackingId,
  }) : super(key: key);

  @override
  State<PaymentWebViewScreen> createState() => _PaymentWebViewScreenState();
}

class _PaymentWebViewScreenState extends State<PaymentWebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  double _progress = 0.0;
  bool _hasNavigatedBack = false; // Prevent multiple navigations

  @override
  void initState() {
    super.initState();
    print('Initial Payment URL: ${widget.paymentUrl}');
    _initializeWebView();
  }

  void _initializeWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            setState(() {
              _progress = progress / 100;
            });
          },
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
            });
            print('Page started loading: $url');
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
            print('Page finished loading: $url');
            // Check payment status after page loads
            _checkPaymentStatus(url);
          },
          onWebResourceError: (WebResourceError error) {
            print('WebView error: ${error.description}');
            setState(() {
              _isLoading = false;
            });
          },
          onNavigationRequest: (NavigationRequest request) {
            print('Navigation request: ${request.url}');

            // Allow navigation but don't check status here
            // Status will be checked in onPageFinished
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.paymentUrl));
  }

  void _checkPaymentStatus(String url) {
    // Prevent multiple navigation callbacks
    if (_hasNavigatedBack) return;

    print('Checking payment status for URL: $url');

    // More specific URL pattern matching for SSL Commerz
    // Adjust these patterns based on your actual callback URLs

    // Success patterns - be very specific
    if (url.contains('/payment-success') ||
        url.contains('/success?') ||
        url.contains('status=success') ||
        url.contains('payment_status=success')) {
      _handlePaymentSuccess();
    }
    // Failure patterns
    else if (url.contains('/payment-failed') ||
        url.contains('/fail?') ||
        url.contains('status=failed') ||
        url.contains('payment_status=failed')) {
      _handlePaymentFailure();
    }
    // Cancel patterns
    else if (url.contains('/payment-cancel') ||
        url.contains('/cancel?') ||
        url.contains('status=cancel') ||
        url.contains('payment_status=cancel')) {
      _handlePaymentCancel();
    }

    // Don't navigate back for intermediate pages like:
    // - SSL Commerz payment selection page
    // - bKash login/payment page
    // - Card input pages
    // These should be allowed to load normally
  }

  void _handlePaymentSuccess() {
    if (_hasNavigatedBack) return;

    _hasNavigatedBack = true;
    print('Payment Success!');

    // Add a small delay to ensure the page has fully loaded
    Future.delayed(Duration(milliseconds: 500), () {
      if (mounted) {
        print("A --------------${widget.trackingId}");
        Navigator.pop(context, {
          'status': 'success',
          'trackingId': widget.trackingId
        });
      }
    });
  }

  void _handlePaymentFailure() {
    if (_hasNavigatedBack) return;

    _hasNavigatedBack = true;
    print('Payment Failed!');

    Future.delayed(Duration(milliseconds: 500), () {
      if (mounted) {
        print("B --------------${widget.trackingId}");
        Navigator.pop(context, {
          'status': 'failed',
          'trackingId': widget.trackingId
        });
      }
    });
  }

  void _handlePaymentCancel() {
    if (_hasNavigatedBack) return;

    _hasNavigatedBack = true;
    print('Payment Cancelled!');

    Future.delayed(Duration(milliseconds: 500), () {
      print("C --------------${widget.trackingId}");
      if (mounted) {
        Navigator.pop(context, {
          'status': 'cancelled',
          'trackingId': widget.trackingId
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Handle Android back button
        _showExitConfirmation();
        return false; // Prevent default back behavior
      },
      child: SafeArea(
        child: Scaffold(
          backgroundColor: AppColors.containerBackground(context),
          body: ResPonsiveUi(
            mobile: _buildBody(),
            desktop: _buildBody(),
            tablet: _buildBody(),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    return Column(
      children: [
        // Header
        GestureDetector(
          onTap: () {
            _showExitConfirmation();
          },
          child: Container(
            height: 60,
            child: AppBarHeader("Payment Gateway"),
          ),
        ),

        // Progress indicator
        if (_isLoading)
          LinearProgressIndicator(
            value: _progress,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.button(context)),
          ),

        // WebView
        Expanded(
          child: Stack(
            children: [
              WebViewWidget(controller: _controller),

              // Loading overlay
              if (_isLoading)
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        color: AppColors.button(context),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Loading payment gateway...',
                        style: TextStyle(
                          color: AppColors.subtitle(context),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  void _showExitConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.containerBackground(context),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Text(
            'Exit Payment?',
            style: TextStyle(
              color: AppColors.textPrimary(context),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Text(
            'Are you sure you want to exit? Your payment will be cancelled.',
            style: TextStyle(
              color: AppColors.subtitle(context),
              fontSize: 14,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Continue Payment',
                style: TextStyle(
                  color: AppColors.button(context),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                _hasNavigatedBack = true;
                Navigator.pop(context, {'status': 'cancelled'}); // Close webview
              },
              child: Text(
                'Exit',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}