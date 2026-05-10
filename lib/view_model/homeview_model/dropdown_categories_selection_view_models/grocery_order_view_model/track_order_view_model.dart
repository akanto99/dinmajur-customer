// import 'package:dinmajur_customer/configs/res/color.dart';
// import 'package:dinmajur_customer/configs/res/sizedbox_spaccing.dart';
// import 'package:dinmajur_customer/configs/res/text_styles.dart';
// import 'package:dinmajur_customer/configs/services/ssl_payment_service/ssl_payment.dart';
// import 'package:dinmajur_customer/configs/utils/routes/routes_name.dart';
// import 'package:dinmajur_customer/configs/utils/utils.dart';
// import 'package:dinmajur_customer/model/home_models/socket_home_model/socket_get_all_orders_model/socket_orderdetails_model.dart';
// import 'package:dinmajur_customer/socket_connection_model/screens_sockets/home_sceens_socket/get_all_orders_socket/socket_order_view_details.dart';
// import 'package:dinmajur_customer/socket_connection_model/socket_provider_services/socket_provider.dart';
// import 'package:dinmajur_customer/view_model/homeview_model/dropdown_categories_selection_view_models/grocery_order_view_model/grocery_ordernow_view_model.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// class TrackOrderViewModel extends ChangeNotifier {
//   // ── Dependencies ──────────────────────────────────────────────────────────────
//   final String orderId;
//   OrderDetailsSocketProvider? _orderDetailsProvider;
//   SocketProvider? _socketProvider;
//
//   TrackOrderViewModel({required this.orderId});
//
//   // ── UI State ──────────────────────────────────────────────────────────────────
//   bool _isTermsAccepted = false;
//   bool _isReviewAccepted = false;
//   String? _selectedPaymentMethod;
//
//   // ── Internal State ────────────────────────────────────────────────────────────
//   String? _previousDeliveryStatus;
//   bool _hasNavigatedToDelivered = false;
//   bool _isInitialized = false;
//   VoidCallback? _socketReconnectCallback;
//
//   // ── Getters ───────────────────────────────────────────────────────────────────
//   bool get isTermsAccepted => _isTermsAccepted;
//   bool get isReviewAccepted => _isReviewAccepted;
//   String? get selectedPaymentMethod => _selectedPaymentMethod;
//   bool get isInitialized => _isInitialized;
//
//   final List<Map<String, dynamic>> paymentMethods = [
//     {'method': 'online', 'title': 'Online Payment', 'icon': 'wallet',      'color': 0xFFEE4237},
//     {'method': 'cash',   'title': 'Hand Cash',       'icon': 'sackDollar', 'color': 0xFF45A986},
//   ];
//
//   // ── Setters ───────────────────────────────────────────────────────────────────
//   void setTermsAccepted(bool value) { _isTermsAccepted = value; notifyListeners(); }
//   void setReviewAccepted(bool value) { _isReviewAccepted = value; notifyListeners(); }
//   void setPaymentMethod(String method) { _selectedPaymentMethod = method; notifyListeners(); }
//
//   // ─────────────────────────────────────────────────────────────────────────────
//   // INITIALIZE — called once per screen lifetime from initState
//   // ─────────────────────────────────────────────────────────────────────────────
//   // Future<void> initialize({
//   //   required BuildContext context,
//   //   required OrderDetailsSocketProvider orderDetailsProvider,
//   //   required SocketProvider socketProvider,
//   // }) async {
//   //   if (!isContextValid(context)) return;
//   //
//   //   print('🎬 [VM] initialize() for orderId: $orderId');
//   //
//   //   _orderDetailsProvider = orderDetailsProvider;
//   //   _socketProvider = socketProvider;
//   //
//   //   // ✅ Always reset provider state so previous screen's data never shows
//   //   _orderDetailsProvider!.reset();
//   //
//   //   // ✅ Setup socket reconnect listener FIRST
//   //   _setupSocketReconnectListener(context: context);
//   //
//   //   // ✅ Then fetch
//   //   await _fetchWithRetry(context: context);
//   //
//   //   _isInitialized = true;
//   //   notifyListeners();
//   //   print('✅ [VM] Initialization complete');
//   // }
//
//   Future<void> initialize({
//     required BuildContext context,
//     required OrderDetailsSocketProvider orderDetailsProvider,
//     required SocketProvider socketProvider,
//   }) async {
//     if (!isContextValid(context)) return;
//
//     _orderDetailsProvider = orderDetailsProvider;
//     _socketProvider = socketProvider;
//     _orderDetailsProvider!.reset();
//
//     // ✅ Connect socket first if not connected
//     if (!_socketProvider!.isConnected) {
//       print('🔌 [VM] Socket not connected — connecting before fetch...');
//       final prefs = await SharedPreferences.getInstance();
//       final accessToken = prefs.getString('accessToken');
//       if (accessToken != null && accessToken.isNotEmpty) {
//         await _socketProvider!.connectWithToken(accessToken: accessToken);
//         // Give it time to establish connection
//         await Future.delayed(const Duration(milliseconds: 1500));
//       }
//     }
//
//     _setupSocketReconnectListener(context: context);
//     await _fetchWithRetry(context: context);
//
//     _isInitialized = true;
//     notifyListeners();
//   }
//   // ─────────────────────────────────────────────────────────────────────────────
//   // SOCKET RECONNECT LISTENER
//   // When the socket reconnects (after network loss/resume), auto-refetch
//   // ─────────────────────────────────────────────────────────────────────────────
//   void _setupSocketReconnectListener({required BuildContext context}) {
//     // Remove old callback first to avoid duplicates
//     if (_socketReconnectCallback != null && _socketProvider != null) {
//       _socketProvider!.removeSocketReadyCallback(_socketReconnectCallback!);
//     }
//
//     _socketReconnectCallback = () {
//       print('🔌 [VM] Socket reconnected — re-fetching order details...');
//       if (_isInitialized) {
//         Future.delayed(const Duration(milliseconds: 800), () {
//           if (isContextValid(context)) {
//             handleRefresh(context: context);
//           }
//         });
//       }
//     };
//
//     _socketProvider?.onSocketReady(_socketReconnectCallback!);
//     print('👂 [VM] Socket reconnect listener registered');
//   }
//
//   // ─────────────────────────────────────────────────────────────────────────────
//   // FETCH WITH RETRY — tries up to 3 times with socket reconnect between attempts
//   // ─────────────────────────────────────────────────────────────────────────────
//   Future<void> _fetchWithRetry({
//     required BuildContext context,
//     int maxRetries = 3,
//   }) async {
//     for (int attempt = 1; attempt <= maxRetries; attempt++) {
//       try {
//         print('🔄 [VM] Fetch attempt $attempt/$maxRetries');
//
//         await _orderDetailsProvider!.initializeAndFetch(
//           socketProvider: _socketProvider!,
//           orderId: orderId,
//           onSuccess: (model) => handleOrderDetailsUpdate(model: model, context: context),
//           onError: (error) {
//             print('❌ [VM] Server error: $error');
//             if (error.contains('Invalid order ID')) throw Exception(error);
//           },
//         );
//
//         print('✅ [VM] Fetch initiated on attempt $attempt');
//         return;
//       } catch (e) {
//         print('❌ [VM] Attempt $attempt failed: $e');
//
//         if (e.toString().contains('Invalid order ID')) {
//           print('❌ [VM] Stopping retries — invalid order ID');
//           return;
//         }
//
//         if (attempt < maxRetries) {
//           print('🔌 [VM] Reconnecting socket before retry...');
//           await _reconnectSocket();
//           await Future.delayed(const Duration(seconds: 3));
//         } else {
//           print('❌ [VM] All $maxRetries attempts exhausted');
//         }
//       }
//     }
//   }
//
//   // ─────────────────────────────────────────────────────────────────────────────
//   // REFRESH — pull-to-refresh or app resume
//   // ─────────────────────────────────────────────────────────────────────────────
//   Future<void> handleRefresh({required BuildContext context}) async {
//     if (_socketProvider == null || _orderDetailsProvider == null) {
//       print('⚠️ [VM] Cannot refresh: providers not ready');
//       return;
//     }
//
//     print('🔄 [VM] handleRefresh()');
//
//     try {
//       // Reconnect socket if needed
//       if (!_socketProvider!.isConnected) {
//         print('⚠️ [VM] Socket disconnected — reconnecting before refresh');
//         await _reconnectSocket();
//         await Future.delayed(const Duration(milliseconds: 500));
//       }
//
//       await _orderDetailsProvider!.refreshOrderDetails(
//         socketProvider: _socketProvider!,
//         orderId: orderId,
//         onSuccess: (model) => handleOrderDetailsUpdate(model: model, context: context),
//         onError: (error) {
//           print('❌ [VM] Refresh error: $error');
//           if (isContextValid(context)) {
//             Utils.flushBarErrorMessage("Failed to update order details", context);
//           }
//         },
//       );
//     } catch (e) {
//       print('❌ [VM] handleRefresh error: $e');
//       if (isContextValid(context)) {
//         Utils.flushBarErrorMessage("Failed to refresh order details", context);
//       }
//     }
//   }
//
//   // ─────────────────────────────────────────────────────────────────────────────
//   // SOCKET RECONNECT HELPER
//   // ─────────────────────────────────────────────────────────────────────────────
//   Future<void> _reconnectSocket() async {
//     try {
//       print('🔌 [VM] _reconnectSocket()');
//
//       final prefs = await SharedPreferences.getInstance();
//       final accessToken = prefs.getString('accessToken');
//
//       if (accessToken == null || accessToken.isEmpty) {
//         print('❌ [VM] No access token');
//         return;
//       }
//
//       await _socketProvider!.disconnect();
//       await Future.delayed(const Duration(milliseconds: 500));
//       await _socketProvider!.connectWithToken(accessToken: accessToken);
//       await Future.delayed(const Duration(milliseconds: 1000));
//
//       print('✅ [VM] Socket reconnected');
//     } catch (e) {
//       print('❌ [VM] Socket reconnect failed: $e');
//     }
//   }
//
//   // ─────────────────────────────────────────────────────────────────────────────
//   // ORDER UPDATE HANDLER
//   // Called by provider whenever new data arrives
//   // ─────────────────────────────────────────────────────────────────────────────
//   void handleOrderDetailsUpdate({
//     required OrderDetailsModel model,
//     required BuildContext context,
//   }) {
//     print('📊 [VM] handleOrderDetailsUpdate — status: ${model.delivery?.status}');
//
//     final currentStatus = model.delivery?.status;
//
//     // Navigate to delivered screen only once
//     if (currentStatus?.toUpperCase() == 'DELIVERED' &&
//         _previousDeliveryStatus?.toUpperCase() != 'DELIVERED' &&
//         !_hasNavigatedToDelivered) {
//       print('🎉 [VM] Order delivered — navigating in 2s');
//       _hasNavigatedToDelivered = true;
//       notifyListeners();
//
//       Future.delayed(const Duration(seconds: 2), () {
//         if (isContextValid(context)) {
//           Navigator.pushNamed(
//             context,
//             RoutesName.deliverdScreen,
//             arguments: {'orderId': orderId},
//           );
//         }
//       });
//     }
//
//     _previousDeliveryStatus = currentStatus;
//   }
//
//   // ─────────────────────────────────────────────────────────────────────────────
//   // STEP CALCULATOR
//   // ─────────────────────────────────────────────────────────────────────────────
//   int getCurrentStepFromStatus(String? deliveryStatus) {
//     if (deliveryStatus == null) return 0;
//     switch (deliveryStatus.toUpperCase()) {
//       case 'PENDING':
//       case 'ACCEPTED': return 0;
//       case 'PICKED_UP': return 1;
//       case 'ARRIVED_DESTINATION': return 2;
//       case 'DELIVERED': return 3;
//       default: return 0;
//     }
//   }
//
//   // ─────────────────────────────────────────────────────────────────────────────
//   // TOTAL CALCULATORS
//   // ─────────────────────────────────────────────────────────────────────────────
//   double calculateSubtotal(Order order) {
//     if (order.items == null) return 0;
//     return order.items!.fold(0.0, (sum, item) {
//       if (item.status?.toLowerCase() != 'not_found' &&
//           item.totalPrice != null &&
//           item.totalPrice! > 0) {
//         return sum + item.totalPrice!;
//       }
//       return sum;
//     });
//   }
//
//   double calculateTotal(Order order) =>(order.totalAmount?.toDouble() ?? 0) ;
//
//
//   int getFoundItemsCount(List<Item>? items) {
//     if (items == null) return 0;
//     return items.where((item) =>
//     item.status?.toLowerCase() != 'not_found' &&
//         item.totalPrice != null &&
//         item.totalPrice! > 0).length;
//   }
//
//   // ─────────────────────────────────────────────────────────────────────────────
//   // TIME FORMATTERS
//   // ─────────────────────────────────────────────────────────────────────────────
//   String formatAcceptedTime(DateTime acceptedAt) =>
//       DateFormat('hh:mm a').format(acceptedAt.add(const Duration(hours: 6)));
//
//   String formatDate(DateTime? createdAt) {
//     if (createdAt == null) return 'N/A';
//     return DateFormat('dd/MM/yyyy').format(createdAt.add(const Duration(hours: 6)));
//   }
//
//   String formatTime(DateTime? createdAt) {
//     if (createdAt == null) return 'N/A';
//     return DateFormat('hh:mm a').format(createdAt.add(const Duration(hours: 6)));
//   }
//
//   // ─────────────────────────────────────────────────────────────────────────────
//   // PHONE HELPERS
//   // ─────────────────────────────────────────────────────────────────────────────
//   String cleanPhoneNumber(String phoneNumber) {
//     String cleaned = phoneNumber.replaceAll(RegExp(r'[^0-9+]'), '');
//     if (cleaned.startsWith('+88')) cleaned = cleaned.substring(3);
//     else if (cleaned.startsWith('88')) cleaned = cleaned.substring(2);
//     if (!cleaned.startsWith('0') && cleaned.length == 10) cleaned = '0$cleaned';
//     return cleaned;
//   }
//
//   // ─────────────────────────────────────────────────────────────────────────────
//   // PAY NOW
//   // ─────────────────────────────────────────────────────────────────────────────
//   Future<void> handlePayNow({
//     required BuildContext context,
//     required Order order,
//     required Payment payment,
//     required Delivery delivery,
//   }) async {
//     if (_selectedPaymentMethod == null) {
//       Utils.flushBarErrorMessage("Please select a payment method.", context);
//       return;
//     }
//     if (!_isTermsAccepted && !_isReviewAccepted) {
//       Utils.flushBarErrorMessage(
//           "Please accept the Terms & Conditions and confirm your review before paying.", context);
//       return;
//     }
//     if (!_isTermsAccepted) {
//       Utils.flushBarErrorMessage(
//           "Please accept the Terms & Conditions, Privacy Policy, and Return/Refund Policy.", context);
//       return;
//     }
//     if (!_isReviewAccepted) {
//       Utils.flushBarErrorMessage(
//           "Please confirm that you have reviewed the final items.", context);
//       return;
//     }
//
//     if (_selectedPaymentMethod == 'cash') {
//       await _handleCashPayment(context: context, payment: payment);
//     } else if (_selectedPaymentMethod == 'online') {
//       print('${payment.toJson()}');
//       await _handleOnlinePayment(context: context, order: order, delivery: delivery);
//     }
//   }
//
//   Future<void> _handleCashPayment({
//     required BuildContext context,
//     required Payment payment,
//   }) async {
//     final confirmed = await showDialog<bool>(
//       context: context,
//       barrierDismissible: false,
//       barrierColor: AppColors.showDialougeBackground(context),
//       builder: (ctx) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         backgroundColor: AppColors.containerBackground(context),
//         title: Row(
//           children: [
//             Icon(Icons.payments_outlined, color: AppColors.button(context), size: 22),
//             SizedboxSpaccing.width02(context),
//             Text('Waiting for Approval',
//                 style: AppTextStyles.textSize16(context, weight: FontWeight.w600)),
//           ],
//         ),
//         content: Text(
//           'You have selected Hand Cash.\n\nDinmajur needs to approve your cash payment request.\nPlease pay the delivery person the total amount upon delivery.\n\nDo you want to confirm this order?',
//           style: AppTextStyles.textSize14(context,
//               weight: FontWeight.w400, color: AppColors.subtitle(context)),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(ctx, false),
//             child: Text('Cancel',
//                 style: AppTextStyles.textSize14(context,
//                     weight: FontWeight.w500, color: AppColors.subtitle(context))),
//           ),
//           ElevatedButton(
//             onPressed: () => Navigator.pop(ctx, true),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: AppColors.button(context),
//               foregroundColor: AppColors.whiteColor,
//               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//               elevation: 0,
//             ),
//             child: Text('Confirm',
//                 style: AppTextStyles.textSize14(context,
//                     weight: FontWeight.w600, color: AppColors.whiteColor)),
//           ),
//         ],
//       ),
//     );
//
//     if (confirmed == true) {
//       if (!isContextValid(context)) return;
//
//       final groceryVM = Provider.of<GroceryOrdernowViewModel>(context, listen: false);
//        print("======================================================${payment.id}");
//       final fields = {
//         'paymentId': payment.id,
//         'paymentType': 'CASH_ON_DELIVERY',
//       };
//
//       await groceryVM.groceryPaymentPatchApi(
//         context,
//         fields,
//             () {
//           print('✅ [VM] Cash payment confirmed for payment ID: ${payment.id}');
//           handleRefresh(context: context);
//         },
//       );
//     }
//   }
//
//   Future<void> _handleOnlinePayment({
//     required BuildContext context,
//     required Order order,
//     required Delivery delivery,
//   }) async {
//     final double total = calculateTotal(order);
//     final customer = _orderDetailsProvider?.orderDetailsModel?.customer;
//     final delivery = _orderDetailsProvider?.orderDetailsModel?.delivery;
//
//     final result = await SSLCommerzPaymentService().initiatePayment(
//       trackingId: delivery?.trackingId ?? '',
//       totalAmount: total,
//       productCategory: "Delivery Service",
//       customerName: customer?.fullName,
//       customerPhone: customer?.phone,
//       customerEmail: "",
//       customerAddress: delivery?.destinationFullAddress,
//     );
//
//     if (!isContextValid(context)) return;
//
//     if (result.success) {
//       print('💳 [VM] SSL payment success: ${result.transactionId}');
//       handleRefresh(context: context);
//     } else if (result.status == 'CANCELLED') {
//       Utils.flushBarErrorMessage("Payment was cancelled.", context);
//     } else {
//       Utils.flushBarErrorMessage(
//           result.errorMessage ?? 'Payment failed. Please try again.', context);
//     }
//   }
//
//   // ─────────────────────────────────────────────────────────────────────────────
//   // HELPERS
//   // ─────────────────────────────────────────────────────────────────────────────
//   bool isContextValid(BuildContext context) {
//     try { return context.mounted; } catch (_) { return false; }
//   }
//
//   // ─────────────────────────────────────────────────────────────────────────────
//   // DISPOSE
//   // ─────────────────────────────────────────────────────────────────────────────
//   @override
//   void dispose() {
//     print('🗑️ [VM] Disposing TrackOrderViewModel');
//
//     if (_socketReconnectCallback != null && _socketProvider != null) {
//       _socketProvider!.removeSocketReadyCallback(_socketReconnectCallback!);
//     }
//
//     // ✅ Reset the shared provider so its stale data doesn't survive
//     _orderDetailsProvider?.reset();
//
//     super.dispose();
//   }
// }

///Customer
import 'dart:async';
import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/sizedbox_spaccing.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:dinmajur_customer/configs/services/ssl_payment_service/ssl_payment.dart';
import 'package:dinmajur_customer/configs/utils/routes/routes_name.dart';
import 'package:dinmajur_customer/configs/utils/utils.dart';
import 'package:dinmajur_customer/model/home_models/socket_home_model/socket_get_all_orders_model/socket_orderdetails_model.dart';
import 'package:dinmajur_customer/socket_connection_model/screens_sockets/home_sceens_socket/get_all_orders_socket/socket_order_view_details.dart';
import 'package:dinmajur_customer/socket_connection_model/socket_provider_services/socket_manager.dart';
import 'package:dinmajur_customer/view_model/homeview_model/dropdown_categories_selection_view_models/grocery_order_view_model/grocery_ordernow_view_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TrackOrderViewModel extends ChangeNotifier {
  // ── Dependencies ──────────────────────────────────────────────────────────────
  final String orderId;
  OrderDetailsSocketProvider? _orderDetailsProvider;
  SocketManager? _socketManager;

  TrackOrderViewModel({required this.orderId});

  // ── UI State ──────────────────────────────────────────────────────────────────
  bool _isTermsAccepted = false;
  bool _isReviewAccepted = false;
  String? _selectedPaymentMethod;

  // ── Internal State ────────────────────────────────────────────────────────────
  String? _previousDeliveryStatus;
  bool _hasNavigatedToDelivered = false;
  bool _isInitialized = false;

  /// Fires whenever SocketManager connects/reconnects — we re-fetch order details.
  VoidCallback? _onSocketConnectedCallback;

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
  void setTermsAccepted(bool value)  { _isTermsAccepted  = value; notifyListeners(); }
  void setReviewAccepted(bool value) { _isReviewAccepted = value; notifyListeners(); }
  void setPaymentMethod(String method) { _selectedPaymentMethod = method; notifyListeners(); }

  // ═══════════════════════════════════════════════════════════════════════════
  // INITIALIZE — called once per screen lifetime from initState
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> initialize({
    required BuildContext context,
    required OrderDetailsSocketProvider orderDetailsProvider,
    required SocketManager socketManager,
  }) async {
    if (!isContextValid(context)) return;

    debugPrint('🎬 [VM] initialize() for orderId: $orderId');

    _orderDetailsProvider = orderDetailsProvider;
    _socketManager        = socketManager;

    // Always wipe stale data from a previous screen visit
    _orderDetailsProvider!.reset();

    // Register a callback on SocketManager so that when the socket
    // (re)connects — after network loss, app resume, etc — we automatically
    // re-fetch fresh order details without any manual intervention.
    _registerSocketReconnectCallback(context: context);

    // Ensure socket is connected before fetching.
    // SocketManager.connect() is idempotent: NavigationScreen already called
    // it on startup, so this only does real work if we're offline.
    if (!_socketManager!.isConnected) {
      debugPrint('🔌 [VM] Socket not connected — connecting before first fetch…');
      final token = await _getAccessToken();
      if (token != null) await _socketManager!.connect(token);
    }

    await _fetchWithRetry(context: context);

    _isInitialized = true;
    notifyListeners();
    debugPrint('✅ [VM] Initialization complete');
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SOCKET RECONNECT CALLBACK
  // SocketManager.onConnected fires every time the socket connects/reconnects.
  // We hook into it so the screen self-heals after network loss or app resume.
  // ═══════════════════════════════════════════════════════════════════════════

  void _registerSocketReconnectCallback({required BuildContext context}) {
    // Remove old callback to avoid stacking duplicates on hot-reload / re-init
    final previous = _onSocketConnectedCallback;
    if (previous != null && _socketManager?.onConnected == previous) {
      _socketManager?.onConnected = null;
    }

    _onSocketConnectedCallback = () {
      debugPrint('🔌 [VM] Socket reconnected — re-fetching order details…');
      if (_isInitialized) {
        // Small delay so the socket handshake fully completes before emitting
        Future.delayed(const Duration(milliseconds: 800), () {
          if (isContextValid(context)) {
            handleRefresh(context: context);
          }
        });
      }
    };

    _socketManager?.onConnected = _onSocketConnectedCallback;
    debugPrint('👂 [VM] Socket reconnect callback registered');
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // FETCH WITH RETRY
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> _fetchWithRetry({
    required BuildContext context,
    int maxRetries = 3,
  }) async {
    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        debugPrint('🔄 [VM] Fetch attempt $attempt/$maxRetries');

        await _orderDetailsProvider!.initializeAndFetch(
          socketManager: _socketManager!,
          orderId: orderId,
          onSuccess: (model) => handleOrderDetailsUpdate(model: model, context: context),
          onError: (error) {
            debugPrint('❌ [VM] Server error: $error');
            if (error.contains('Invalid order ID')) throw Exception(error);
          },
        );

        debugPrint('✅ [VM] Fetch initiated on attempt $attempt');
        return;
      } catch (e) {
        debugPrint('❌ [VM] Attempt $attempt failed: $e');

        if (e.toString().contains('Invalid order ID')) {
          debugPrint('❌ [VM] Stopping retries — invalid order ID');
          return;
        }

        if (attempt < maxRetries) {
          debugPrint('🔌 [VM] Reconnecting socket before retry…');
          await _reconnectSocket();
          await Future.delayed(const Duration(seconds: 3));
        } else {
          debugPrint('❌ [VM] All $maxRetries attempts exhausted');
        }
      }
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // REFRESH — pull-to-refresh, app resume, or return from another screen
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> handleRefresh({required BuildContext context}) async {
    if (_socketManager == null || _orderDetailsProvider == null) {
      debugPrint('⚠️ [VM] Cannot refresh: providers not ready');
      return;
    }

    debugPrint('🔄 [VM] handleRefresh()');

    try {
      if (!_socketManager!.isConnected) {
        debugPrint('⚠️ [VM] Socket disconnected — reconnecting before refresh');
        await _reconnectSocket();
        await Future.delayed(const Duration(milliseconds: 500));
      }

      await _orderDetailsProvider!.refreshOrderDetails(
        socketManager: _socketManager!,
        orderId: orderId,
        onSuccess: (model) => handleOrderDetailsUpdate(model: model, context: context),
        onError: (error) {
          debugPrint('❌ [VM] Refresh error: $error');
          if (isContextValid(context)) {
            Utils.flushBarErrorMessage('Failed to update order details', context);
          }
        },
      );
    } catch (e) {
      debugPrint('❌ [VM] handleRefresh error: $e');
      if (isContextValid(context)) {
        Utils.flushBarErrorMessage('Failed to refresh order details', context);
      }
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SOCKET RECONNECT HELPER
  // SocketManager already has its own retry loop (see _reconnectWithRetry),
  // but we also call connect() directly here so the VM controls the timing.
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> _reconnectSocket() async {
    try {
      debugPrint('🔌 [VM] _reconnectSocket()');
      final token = await _getAccessToken();
      if (token == null) {
        debugPrint('❌ [VM] No access token — cannot reconnect');
        return;
      }
      // SocketManager.connect() destroys the old socket and creates a fresh one
      await _socketManager!.connect(token);
      await Future.delayed(const Duration(milliseconds: 1000));
      debugPrint('✅ [VM] Socket reconnected');
    } catch (e) {
      debugPrint('❌ [VM] Socket reconnect failed: $e');
    }
  }

  Future<String?> _getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');
    if (token == null || token.isEmpty) return null;
    return token;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ORDER UPDATE HANDLER
  // ═══════════════════════════════════════════════════════════════════════════

  void handleOrderDetailsUpdate({
    required OrderDetailsModel model,
    required BuildContext context,
  }) {
    debugPrint('📊 [VM] handleOrderDetailsUpdate — status: ${model.delivery?.status}');

    final currentStatus = model.delivery?.status;

    // Navigate to delivered screen only once
    if (currentStatus?.toUpperCase() == 'DELIVERED' &&
        _previousDeliveryStatus?.toUpperCase() != 'DELIVERED' &&
        !_hasNavigatedToDelivered) {
      debugPrint('🎉 [VM] Order delivered — navigating in 2s');
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

  // ═══════════════════════════════════════════════════════════════════════════
  // STEP CALCULATOR
  // ═══════════════════════════════════════════════════════════════════════════

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

  // ═══════════════════════════════════════════════════════════════════════════
  // TOTAL CALCULATORS
  // ═══════════════════════════════════════════════════════════════════════════

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

  double calculateTotal(Order order) => order.totalAmount?.toDouble() ?? 0;

  int getFoundItemsCount(List<Item>? items) {
    if (items == null) return 0;
    return items
        .where((item) =>
    item.status?.toLowerCase() != 'not_found' &&
        item.totalPrice != null &&
        item.totalPrice! > 0)
        .length;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // TIME FORMATTERS
  // ═══════════════════════════════════════════════════════════════════════════

  String formatAcceptedTime(DateTime acceptedAt) =>
      DateFormat('hh:mm a').format(acceptedAt.add(const Duration(hours: 6)));

  String formatDate(DateTime? createdAt) {
    if (createdAt == null) return 'N/A';
    return DateFormat('dd/MM/yyyy').format(createdAt.add(const Duration(hours: 6)));
  }

  String formatTime(DateTime? createdAt) {
    if (createdAt == null) return 'N/A';
    return DateFormat('hh:mm a').format(createdAt.add(const Duration(hours: 6)));
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // PHONE HELPERS
  // ═══════════════════════════════════════════════════════════════════════════

  String cleanPhoneNumber(String phoneNumber) {
    String cleaned = phoneNumber.replaceAll(RegExp(r'[^0-9+]'), '');
    if (cleaned.startsWith('+88'))      cleaned = cleaned.substring(3);
    else if (cleaned.startsWith('88'))  cleaned = cleaned.substring(2);
    if (!cleaned.startsWith('0') && cleaned.length == 10) cleaned = '0$cleaned';
    return cleaned;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // PAY NOW
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> handlePayNow({
    required BuildContext context,
    required Order order,
    required Payment payment,
    required Delivery delivery,
  }) async {
    if (_selectedPaymentMethod == null) {
      Utils.flushBarErrorMessage('Please select a payment method.', context);
      return;
    }
    if (!_isTermsAccepted && !_isReviewAccepted) {
      Utils.flushBarErrorMessage(
          'Please accept the Terms & Conditions and confirm your review before paying.', context);
      return;
    }
    if (!_isTermsAccepted) {
      Utils.flushBarErrorMessage(
          'Please accept the Terms & Conditions, Privacy Policy, and Return/Refund Policy.', context);
      return;
    }
    if (!_isReviewAccepted) {
      Utils.flushBarErrorMessage(
          'Please confirm that you have reviewed the final items.', context);
      return;
    }

    if (_selectedPaymentMethod == 'cash') {
      await _handleCashPayment(context: context, payment: payment);
    }
    else if (_selectedPaymentMethod == 'online') {
      debugPrint('${payment.toJson()}');
      await _handleOnlinePayment(context: context, order: order, delivery: delivery);
    }
  }

  Future<void> _handleCashPayment({
    required BuildContext context,
    required Payment payment,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      barrierColor: AppColors.showDialougeBackground(context),
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: AppColors.containerBackground(context),
        title: Row(
          children: [
            Icon(Icons.payments_outlined, color: AppColors.button(context), size: 22),
            SizedboxSpaccing.width02(context),
            Text('Waiting for Approval',
                style: AppTextStyles.textSize16(context, weight: FontWeight.w600)),
          ],
        ),
        content: Text(
          'You have selected Hand Cash.\n\nDinmajur needs to approve your cash payment request.\nPlease pay the delivery person the total amount upon delivery.\n\nDo you want to confirm this order?',
          style: AppTextStyles.textSize14(context,
              weight: FontWeight.w400, color: AppColors.subtitle(context)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel',
                style: AppTextStyles.textSize14(context,
                    weight: FontWeight.w500, color: AppColors.subtitle(context))),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.button(context),
              foregroundColor: AppColors.whiteColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              elevation: 0,
            ),
            child: Text('Confirm',
                style: AppTextStyles.textSize14(context,
                    weight: FontWeight.w600, color: AppColors.whiteColor)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      if (!isContextValid(context)) return;

      final groceryVM = Provider.of<GroceryOrdernowViewModel>(context, listen: false);
      debugPrint('====== payment.id: ${payment.id}');
      final fields = {
        'paymentId': payment.id,
        'paymentType': 'CASH_ON_DELIVERY',
      };

      await groceryVM.groceryPaymentPatchApi(
        context,
        fields,
            () {
          debugPrint('✅ [VM] Cash payment confirmed for payment ID: ${payment.id}');
          handleRefresh(context: context);
        },
      );
    }
  }

  Future<void> _handleOnlinePayment({
    required BuildContext context,
    required Order order,
    required Delivery delivery,
  }) async {
    final double total      = calculateTotal(order);
    final customer          = _orderDetailsProvider?.orderDetailsModel?.customer;
    final deliveryModel     = _orderDetailsProvider?.orderDetailsModel?.delivery;

    final result = await SSLCommerzPaymentService().initiatePayment(
      trackingId:       deliveryModel?.trackingId ?? '',
      totalAmount:      total,
      productCategory:  'Delivery Service',
      customerName:     customer?.fullName,
      customerPhone:    customer?.phone,
      customerEmail:    '',
      customerAddress:  deliveryModel?.destinationFullAddress,
    );

    if (!isContextValid(context)) return;

    if (result.success) {
      debugPrint('💳 [VM] SSL payment success: ${result.transactionId}');
      handleRefresh(context: context);
    } else if (result.status == 'CANCELLED') {
      Utils.flushBarErrorMessage('Payment was cancelled.', context);
    } else {
      Utils.flushBarErrorMessage(
          result.errorMessage ?? 'Payment failed. Please try again.', context);
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // HELPERS
  // ═══════════════════════════════════════════════════════════════════════════

  bool isContextValid(BuildContext context) {
    try {
      return context.mounted;
    } catch (_) {
      return false;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // DISPOSE
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  void dispose() {
    debugPrint('🗑️ [VM] Disposing TrackOrderViewModel');

    // Unregister our socket reconnect callback so it doesn't fire after dispose
    if (_socketManager?.onConnected == _onSocketConnectedCallback) {
      _socketManager?.onConnected = null;
    }
    _onSocketConnectedCallback = null;

    // Clear socket listeners and reset provider state
    if (_socketManager != null && _orderDetailsProvider != null) {
      _orderDetailsProvider!.clearAll(_socketManager!);
    }

    super.dispose();
  }
}