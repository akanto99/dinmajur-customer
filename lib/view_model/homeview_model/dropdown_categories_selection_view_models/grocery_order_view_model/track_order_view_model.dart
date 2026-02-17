import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/sizedbox_spaccing.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:dinmajur_customer/configs/services/ssl_payment_service/ssl_payment.dart';
import 'package:dinmajur_customer/configs/utils/routes/routes_name.dart';
import 'package:dinmajur_customer/configs/utils/utils.dart';
import 'package:dinmajur_customer/model/home_models/socket_home_model/socket_get_all_orders_model/socket_orderdetails_model.dart';
import 'package:dinmajur_customer/socket_connection_model/screens_sockets/home_sceens_socket/get_all_orders_socket/socket_order_view_details.dart';
import 'package:dinmajur_customer/socket_connection_model/socket_provider_services/socket_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TrackOrderViewModel extends ChangeNotifier {
  // ── Dependencies ─────────────────────────────────────────────────────────────
  final String orderId;
  OrderDetailsSocketProvider? _orderDetailsProvider;
  SocketProvider? _socketProvider;

  TrackOrderViewModel({required this.orderId});

  // ── UI State ──────────────────────────────────────────────────────────────────
  bool _isTermsAccepted = false;
  bool _isReviewAccepted = false;
  String? _selectedPaymentMethod;

  // ── Internal State ────────────────────────────────────────────────────────────
  String? _previousDeliveryStatus;
  bool _hasNavigatedToDelivered = false;
  bool _isInitialized = false;
  VoidCallback? _socketReconnectCallback;

  // ── Getters ───────────────────────────────────────────────────────────────────
  bool get isTermsAccepted => _isTermsAccepted;
  bool get isReviewAccepted => _isReviewAccepted;
  String? get selectedPaymentMethod => _selectedPaymentMethod;
  bool get isInitialized => _isInitialized;

  final List<Map<String, dynamic>> paymentMethods = [
    {'method': 'online', 'title': 'Online Payment', 'icon': 'wallet',      'color': 0xFFEE4237},
    {'method': 'cash',   'title': 'Hand Cash',       'icon': 'sackDollar', 'color': 0xFF45A986},
  ];

  // ── Setters ───────────────────────────────────────────────────────────────────
  void setTermsAccepted(bool value) {
    _isTermsAccepted = value;
    notifyListeners();
  }

  void setReviewAccepted(bool value) {
    _isReviewAccepted = value;
    notifyListeners();
  }

  void setPaymentMethod(String method) {
    _selectedPaymentMethod = method;
    notifyListeners();
  }

  // ── Initialization ────────────────────────────────────────────────────────────
  Future<void> initialize({
    required BuildContext context,
    required OrderDetailsSocketProvider orderDetailsProvider,
    required SocketProvider socketProvider,
  }) async {
    if (!isContextValid(context)) return;

    print('🎬 [VM] Initializing screen for order: $orderId');

    _orderDetailsProvider = orderDetailsProvider;
    _socketProvider = socketProvider;

    _setupSocketReconnectListener(context: context);
    await _initializeWithRetry(context: context);

    _isInitialized = true;
    notifyListeners();
    print('✅ [VM] Initialization complete');
  }

  void _setupSocketReconnectListener({required BuildContext context}) {
    print('👂 [VM] Setting up socket reconnect listener');

    _socketReconnectCallback = () {
      print('🔌 [VM] Socket reconnected! Refreshing...');
      if (_isInitialized) {
        Future.delayed(const Duration(milliseconds: 500), () {
          handleRefresh(context: context);
        });
      }
    };

    _socketProvider?.onSocketReady(_socketReconnectCallback!);
  }

  Future<void> _initializeWithRetry({
    required BuildContext context,
    int maxRetries = 3,
  }) async {
    int retryCount = 0;

    while (retryCount < maxRetries) {
      try {
        print('🔄 [VM] Initialization attempt ${retryCount + 1}/$maxRetries');

        await _orderDetailsProvider!.initializeAndFetch(
          socketProvider: _socketProvider!,
          orderId: orderId,
          onSuccess: (model) => handleOrderDetailsUpdate(model: model, context: context),
          onError: (error) async {
            print('❌ [VM] Error during initialization: $error');
            if (error.contains('Invalid order ID')) {
              throw Exception(error);
            }
          },
        );

        print('✅ [VM] Initialization successful');
        return;
      } catch (e) {
        retryCount++;
        print('❌ [VM] Attempt $retryCount failed: $e');

        if (e.toString().contains('Invalid order ID')) {
          print('❌ [VM] Invalid order ID, stopping retries');
          return;
        }

        if (retryCount < maxRetries) {
          await _reconnectSocket();
          await Future.delayed(const Duration(seconds: 2));
        } else {
          print('❌ [VM] Max retries reached');
        }
      }
    }
  }

  Future<void> _reconnectSocket() async {
    try {
      print('🔌 [VM] Attempting to reconnect socket...');

      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('accessToken');

      if (accessToken == null || accessToken.isEmpty) {
        print('❌ [VM] No access token available');
        return;
      }

      await _socketProvider!.disconnect();
      await Future.delayed(const Duration(milliseconds: 500));
      await _socketProvider!.connectWithToken(accessToken: accessToken);
      await Future.delayed(const Duration(milliseconds: 1000));

      print('✅ [VM] Socket reconnected');
    } catch (e) {
      print('❌ [VM] Reconnection failed: $e');
    }
  }

  // ── Refresh ───────────────────────────────────────────────────────────────────
  Future<void> handleRefresh({required BuildContext context}) async {
    if (_socketProvider == null || _orderDetailsProvider == null) {
      print('⚠️ [VM] Cannot refresh: not ready');
      return;
    }

    print('🔄 [VM] Refreshing order details');

    try {
      if (!_socketProvider!.isConnected) {
        print('⚠️ [VM] Socket disconnected, reconnecting before refresh');
        await _reconnectSocket();
        await Future.delayed(const Duration(milliseconds: 500));
      }

      await _orderDetailsProvider!.refreshOrderDetails(
        socketProvider: _socketProvider!,
        orderId: orderId,
        onSuccess: (model) => handleOrderDetailsUpdate(model: model, context: context),
        onError: (error) {
          print('❌ [VM] Refresh error: $error');
          if (isContextValid(context)) {
            Utils.flushBarErrorMessage("Failed to update order details", context);
          }
        },
      );
    } catch (e) {
      print('❌ [VM] Refresh error: $e');
      if (isContextValid(context)) {
        Utils.flushBarErrorMessage("Failed to refresh order details", context);
      }
    }
  }

  // ── Order Update Handler ──────────────────────────────────────────────────────
  void handleOrderDetailsUpdate({
    required OrderDetailsModel model,
    required BuildContext context,
  }) {
    print('📊 [VM] Order details updated');

    final currentStatus = model.delivery?.status;

    if (currentStatus?.toUpperCase() == 'DELIVERED' &&
        _previousDeliveryStatus?.toUpperCase() != 'DELIVERED' &&
        !_hasNavigatedToDelivered) {
      print('🎉 [VM] Order delivered! Navigating...');
      _hasNavigatedToDelivered = true;
      notifyListeners();

      Future.delayed(const Duration(seconds: 2), () {
        if (isContextValid(context)) {
          Navigator.pushNamed(
            context,
            RoutesName.deliverdScreen,
            arguments: {'orderId': orderId},
          );
        }
      });
    }

    _previousDeliveryStatus = currentStatus;
  }

  // ── Step Calculator ───────────────────────────────────────────────────────────
  int getCurrentStepFromStatus(String? deliveryStatus) {
    if (deliveryStatus == null) return 0;
    switch (deliveryStatus.toUpperCase()) {
      case 'PENDING':
      case 'ACCEPTED':
        return 0;
      case 'PICKED_UP':
        return 1;
      case 'ARRIVED_DESTINATION':
        return 2;
      case 'DELIVERED':
        return 3;
      default:
        return 0;
    }
  }

  // ── Total Calculators ─────────────────────────────────────────────────────────
  double calculateSubtotal(Order order) {
    if (order.items == null) return 0;
    return order.items!.fold(0.0, (sum, item) {
      if (item.status?.toLowerCase() != 'not_found' &&
          item.totalPrice != null &&
          item.totalPrice! > 0) {
        return sum + item.totalPrice!;
      }
      return sum;
    });
  }

  double calculateTotal(Order order) {
    return calculateSubtotal(order) +
        (order.serviceFee?.toDouble() ?? 0) +
        (order.freelancerEarning?.toDouble() ?? 0);
  }

  int getFoundItemsCount(List<Item>? items) {
    if (items == null) return 0;
    return items.where((item) =>
    item.status?.toLowerCase() != 'not_found' &&
        item.totalPrice != null &&
        item.totalPrice! > 0).length;
  }

  // ── Time Formatters ───────────────────────────────────────────────────────────
  String formatAcceptedTime(DateTime acceptedAt) {
    return DateFormat('hh:mm a').format(acceptedAt.add(const Duration(hours: 6)));
  }

  String formatDate(DateTime? createdAt) {
    if (createdAt == null) return 'N/A';
    return DateFormat('dd/MM/yyyy').format(createdAt.add(const Duration(hours: 6)));
  }

  String formatTime(DateTime? createdAt) {
    if (createdAt == null) return 'N/A';
    return DateFormat('hh:mm a').format(createdAt.add(const Duration(hours: 6)));
  }

  // ── Phone Helpers ─────────────────────────────────────────────────────────────
  String cleanPhoneNumber(String phoneNumber) {
    String cleaned = phoneNumber.replaceAll(RegExp(r'[^0-9+]'), '');
    if (cleaned.startsWith('+88')) cleaned = cleaned.substring(3);
    else if (cleaned.startsWith('88')) cleaned = cleaned.substring(2);
    if (!cleaned.startsWith('0') && cleaned.length == 10) cleaned = '0$cleaned';
    return cleaned;
  }

  // ── Payment Handler ───────────────────────────────────────────────────────────
  Future<void> handlePayNow({
    required BuildContext context,
    required Order order,
  }) async {
    // 1. Payment method check
    if (_selectedPaymentMethod == null) {
      Utils.flushBarErrorMessage("Please select a payment method.", context);
      return;
    }

    // 2. Terms checks
    if (!_isTermsAccepted && !_isReviewAccepted) {
      Utils.flushBarErrorMessage(
        "Please accept the Terms & Conditions and confirm your review before paying.",
        context,
      );
      return;
    }
    if (!_isTermsAccepted) {
      Utils.flushBarErrorMessage(
        "Please accept the Terms & Conditions, Privacy Policy, and Return/Refund Policy.",
        context,
      );
      return;
    }
    if (!_isReviewAccepted) {
      Utils.flushBarErrorMessage(
        "Please confirm that you have reviewed the final items.",
        context,
      );
      return;
    }

    // 3. Cash → dialog
    if (_selectedPaymentMethod == 'cash') {
      await _handleCashPayment(context: context, order: order);
      return;
    }

    // 4. Online → SSL
    if (_selectedPaymentMethod == 'online') {
      await _handleOnlinePayment(context: context, order: order);
    }
  }

  Future<void> _handleCashPayment({
    required BuildContext context,
    required Order order,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: AppColors.containerBackground(context),
        title: Row(
          children: [
            Icon(Icons.payments_outlined, color: AppColors.button(context), size: 22),
            SizedboxSpaccing.width02(context),
            Text(
              'Hand Cash Payment',
              style: AppTextStyles.textSize16(context, weight: FontWeight.w600),
            ),
          ],
        ),
        content: Text(
          'You have selected Hand Cash. Please pay the delivery person the total amount upon delivery.\n\nDo you want to confirm this order?',
          style: AppTextStyles.textSize14(
            context,
            weight: FontWeight.w400,
            color: AppColors.subtitle(context),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Cancel',
              style: AppTextStyles.textSize14(
                context,
                weight: FontWeight.w500,
                color: AppColors.subtitle(context),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.button(context),
              foregroundColor: AppColors.whiteColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              elevation: 0,
            ),
            child: Text(
              'Confirm',
              style: AppTextStyles.textSize14(
                context,
                weight: FontWeight.w600,
                color: AppColors.whiteColor,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // TODO: call your cash confirm API/socket here
      print('✅ [VM] Cash payment confirmed for order: ${order.id}');
    }
  }

  Future<void> _handleOnlinePayment({
    required BuildContext context,
    required Order order,
  }) async {
    final double total = calculateTotal(order);
    final customer = _orderDetailsProvider?.orderDetailsModel?.customer;
    final delivery = _orderDetailsProvider?.orderDetailsModel?.delivery;

    final result = await SSLCommerzPaymentService().initiatePayment(
      trackingId: order.id ?? '',
      totalAmount: total,
      productCategory: "Delivery Service",
      customerName: customer?.fullName,
      customerPhone: customer?.phone,
      customerEmail: "",
      customerAddress: delivery?.destinationFullAddress,
    );

    if (!isContextValid(context)) return;

    if (result.success) {
      print('💳 [VM] SSL payment success: ${result.transactionId}');
      // TODO: navigate to success screen or call confirm API
    } else if (result.status == 'CANCELLED') {
      Utils.flushBarErrorMessage("Payment was cancelled.", context);
    } else {
      Utils.flushBarErrorMessage(
        result.errorMessage ?? 'Payment failed. Please try again.',
        context,
      );
    }
  }

  // ── Helper ────────────────────────────────────────────────────────────────────
  bool isContextValid(BuildContext context) {
    try {
      return context.mounted;
    } catch (_) {
      return false;
    }
  }

  // ── Dispose ───────────────────────────────────────────────────────────────────
  @override
  void dispose() {
    print('🗑️ [VM] Disposing ViewModel');
    if (_socketReconnectCallback != null && _socketProvider != null) {
      _socketProvider!.removeSocketReadyCallback(_socketReconnectCallback!);
      print('✅ [VM] Removed socket reconnect listener');
    }
    super.dispose();
  }
}