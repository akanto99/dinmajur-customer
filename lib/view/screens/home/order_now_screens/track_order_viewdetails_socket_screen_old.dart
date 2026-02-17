import 'dart:async';
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
import 'package:dinmajur_customer/model/home_models/socket_home_model/socket_get_all_orders_model/socket_orderdetails_model.dart';
import 'package:dinmajur_customer/socket_connection_model/screens_sockets/home_sceens_socket/get_all_orders_socket/socket_order_view_details.dart';
import 'package:dinmajur_customer/socket_connection_model/socket_provider_services/socket_provider.dart';
import 'package:dinmajur_customer/view/navigation_bar.dart';
import 'package:dinmajur_customer/view/screens/home/order_now_screens/helper_widget/dual_terms&conditons_widget.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class TrackOrderViewdetailsSocketScreenOld extends StatefulWidget {
  final String orderId;
  const TrackOrderViewdetailsSocketScreenOld({Key? key, required this.orderId}) : super(key: key);

  @override
  State<TrackOrderViewdetailsSocketScreenOld> createState() => _TrackOrderViewdetailsSocketScreenOldState();
}

class _TrackOrderViewdetailsSocketScreenOldState extends State<TrackOrderViewdetailsSocketScreenOld> with WidgetsBindingObserver {
  OrderDetailsSocketProvider? _orderDetailsProvider;
  SocketProvider? _socketProvider;

  String? _previousDeliveryStatus;
  bool _hasNavigatedToDelivered = false;
  bool _isInitialized = false;
  bool _isTermsAccepted = false;
  bool _isReviewAccepted = false;
  String? _selectedPaymentMethod;
  VoidCallback? _socketReconnectCallback;


  final List<Map<String, dynamic>> _paymentMethods = [
    {'method': 'online', 'title': 'Online Payment', 'icon': 'wallet', 'color': 0xFFEE4237},
    {'method': 'cash',   'title': 'Hand Cash',       'icon': 'sackDollar', 'color': 0xFF45A986},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeScreen();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed && _isInitialized) {
      print('🔄 [SCREEN] App resumed - refreshing data');
      _handleRefresh();
    }
  }

  /// ✅ SIMPLIFIED: Setup listener ONLY for future reconnections
  void _setupSocketReconnectListener() {
    print('👂 [SCREEN] Setting up socket reconnect listener');

    _socketReconnectCallback = () {
      print('🔌 [SCREEN] Socket reconnected! Refreshing order details...');

      // Only refresh if screen is already initialized
      if (mounted && _isInitialized) {
        Future.delayed(Duration(milliseconds: 500), () {
          if (mounted) {
            _handleRefresh();
          }
        });
      }
    };

    // ✅ Register callback - but don't trigger on initial connection
    _socketProvider?.onSocketReady(_socketReconnectCallback!);
  }

  /// ✅ SIMPLIFIED: Initialize once with auto-retry on failure
  Future<void> _initializeScreen() async {
    if (!mounted) return;

    print('🎬 [SCREEN] Initializing screen for order: ${widget.orderId}');

    _socketProvider = Provider.of<SocketProvider>(context, listen: false);
    _orderDetailsProvider = Provider.of<OrderDetailsSocketProvider>(context, listen: false);

    // Setup reconnect listener BEFORE fetching data
    _setupSocketReconnectListener();

    // Initial fetch with retry logic
    await _initializeWithRetry();

    _isInitialized = true;
    print('✅ [SCREEN] Screen initialization complete');
  }

  /// ✅ NEW: Initialize with automatic retry and reconnection
  Future<void> _initializeWithRetry({int maxRetries = 3}) async {
    int retryCount = 0;

    while (retryCount < maxRetries) {
      try {
        print('🔄 [SCREEN] Initialization attempt ${retryCount + 1}/$maxRetries');

        // Attempt to initialize and fetch
        await _orderDetailsProvider!.initializeAndFetch(
          socketProvider: _socketProvider!,
          orderId: widget.orderId,
          onSuccess: _handleOrderDetailsUpdate,
          onError: (error) async {
            if (mounted) {
              print('❌ [SCREEN] Error during initialization: $error');

              // Don't retry if it's an invalid order ID
              if (error.contains('Invalid order ID')) {
                throw Exception(error);
              }
            }
          },
        );

        // If we reach here, initialization was successful
        print('✅ [SCREEN] Initialization successful');
        return;
      } catch (e) {
        retryCount++;
        print('❌ [SCREEN] Initialization attempt $retryCount failed: $e');

        // If it's an invalid order ID, don't retry
        if (e.toString().contains('Invalid order ID')) {
          print('❌ [SCREEN] Invalid order ID, stopping retries');
          return;
        }

        if (retryCount < maxRetries) {
          // Try to reconnect socket before retrying
          await _reconnectAndRetry();

          // Wait before next retry
          await Future.delayed(Duration(seconds: 2));
        } else {
          print('❌ [SCREEN] Max retries reached, showing error state');
        }
      }
    }
  }

  /// ✅ NEW: Reconnect socket and retry fetching
  Future<void> _reconnectAndRetry() async {
    try {
      print('🔌 [SCREEN] Attempting to reconnect socket...');

      // Get access token
      final prefs = await SharedPreferences.getInstance();
      String? accessToken = prefs.getString('accessToken');

      if (accessToken == null || accessToken.isEmpty) {
        print('❌ [SCREEN] No access token available');
        return;
      }

      // Disconnect existing connection
      await _socketProvider!.disconnect();
      await Future.delayed(Duration(milliseconds: 500));

      // Reconnect with token
      await _socketProvider!.connectWithToken(accessToken: accessToken);
      await Future.delayed(Duration(milliseconds: 1000));

      // if (_socketProvider!.isConnected) {
      //   print('✅ [SCREEN] Socket reconnected successfully');
      // } else {
      //   print('⚠️ [SCREEN] Socket not connected, attempting auto-reconnect');
      //   await _socketProvider!.autoReconnect();
      // }
    } catch (e) {
      print('❌ [SCREEN] Reconnection failed: $e');
    }
  }

  /// ✅ SIMPLIFIED: Single refresh method with reconnection logic
  Future<void> _handleRefresh() async {
    if (!mounted || _socketProvider == null || _orderDetailsProvider == null) {
      print('⚠️ [SCREEN] Cannot refresh: screen not ready');
      return;
    }

    print('🔄 [SCREEN] Refreshing order details');

    try {
      // Check socket connection before refresh
      if (!_socketProvider!.isConnected) {
        print('⚠️ [SCREEN] Socket disconnected, attempting reconnection before refresh');
        await _reconnectAndRetry();
        await Future.delayed(Duration(milliseconds: 500));
      }

      await _orderDetailsProvider!.refreshOrderDetails(
        socketProvider: _socketProvider!,
        orderId: widget.orderId,
        onSuccess: _handleOrderDetailsUpdate,
        onError: (error) {
          print('❌ [SCREEN] Error during refresh: $error');
          if (mounted) {
            Utils.flushBarErrorMessage("Failed to update order details", context);
          }
        },
      );
    } catch (e) {
      print('❌ [SCREEN] Refresh error: $e');
      if (mounted) {
        Utils.flushBarErrorMessage("Failed to refresh order details", context);
      }
    }
  }

  void _handleOrderDetailsUpdate(OrderDetailsModel model) {
    if (!mounted) return;

    print('📊 [SCREEN] Order details updated');

    // Check for delivery status changes
    String? currentStatus = model.delivery?.status;

    if (currentStatus?.toUpperCase() == 'DELIVERED' && _previousDeliveryStatus?.toUpperCase() != 'DELIVERED' && !_hasNavigatedToDelivered) {
      print('🎉 [SCREEN] Order delivered! Navigating to delivery screen...');
      _hasNavigatedToDelivered = true;

      Future.delayed(Duration(seconds: 2), () {
        if (mounted) {
          Navigator.pushNamed(context, RoutesName.deliverdScreen, arguments: {'orderId': widget.orderId});
        }
      });
    }

    _previousDeliveryStatus = currentStatus;
  }

  @override
  void dispose() {
    print('🗑️ [SCREEN] Disposing screen');
    WidgetsBinding.instance.removeObserver(this);

    // ✅ Remove socket reconnect callback
    if (_socketReconnectCallback != null && _socketProvider != null) {
      _socketProvider!.removeSocketReadyCallback(_socketReconnectCallback!);
      print('✅ [SCREEN] Removed socket reconnect listener');
    }

    super.dispose();
  }

  int _getCurrentStepFromStatus(String? deliveryStatus) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.containerBackground(context),
      body: SafeArea(
        child: Column(
          children: [
            GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => NavigationScreen(initialIndex: 0))),
              child: Container(height: 60, child: AppBarHeader("Track Order Details")),
            ),
            Expanded(child: _buildContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Consumer<OrderDetailsSocketProvider>(
      builder: (context, provider, child) {
        // Loading state
        if (provider.isLoading) {
          return Center(child: LoadingAnimationWidget.progressiveDots(color: AppColors.button(context), size: 45));
        }

        // Error state (only if no data available)
        if (provider.error != null && provider.orderDetailsModel == null) {
          return _buildErrorState(provider.error!);
        }

        // Data available
        if (provider.orderDetailsModel != null) {
          return _buildOrderDetailsContent(provider.orderDetailsModel!);
        }

        // Default loading
        return Center(child: LoadingAnimationWidget.progressiveDots(color: AppColors.button(context), size: 45));
      },
    );
  }

  Widget _buildErrorState(String error) {
    return RefreshIndicator(
      onRefresh: _handleRefresh,
      color: AppColors.button(context),
      backgroundColor: AppColors.containerBackground(context),
      child: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: Container(
          height: MediaQuery.of(context).size.height - 200,
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(FontAwesomeIcons.boxOpen, size: 50, color: Colors.red),
                  SizedboxSpaccing.height02(context),
                  Text(
                    'Unable to Load Order',
                    style: AppTextStyles.textSize18(context, weight: FontWeight.w500),
                    textAlign: TextAlign.center,
                  ),
                  SizedboxSpaccing.height01(context),
                  Text(
                    error,
                    style: AppTextStyles.textSize14(context, color: AppColors.subtitle(context)),
                    textAlign: TextAlign.center,
                  ),
                  SizedboxSpaccing.height03(context),
                  ElevatedButton.icon(
                    onPressed: _handleRefresh,
                    icon: Icon(Icons.refresh),
                    label: Text('Retry'),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.button(context), foregroundColor: Colors.white, padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOrderDetailsContent(OrderDetailsModel model) {
    final screenHeight = MediaQuery.of(context).size.height;
    final order = model.order!;
    final retailer = model.retailer;
    final delivery = model.delivery;
    final customer = model.customer;
    final freelancer = model.freelancer;

    bool isPending = delivery?.status?.toUpperCase() == 'PENDING';
    bool isArriveDestination = delivery?.status?.toUpperCase() == 'ARRIVED_DESTINATION';

    return RefreshIndicator(
      onRefresh: _handleRefresh,
      color: AppColors.button(context),
      backgroundColor: AppColors.containerBackground(context),
      child: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: Container(
          padding: EdgeInsets.all(screenHeight * 0.02),
          child: Column(
            children: [
              _buildOrderProgress(context, delivery?.status),
              SizedboxSpaccing.height02(context),
              if (isPending)...[_buildConfirmationCard(context),
                SizedboxSpaccing.height02(context),],
              _buildCustomerInfo(context, customer, retailer, order, delivery, freelancer),
              SizedboxSpaccing.height02(context),
              if (!isPending) ...[_buildContactSection(context, freelancer), SizedboxSpaccing.height02(context)],
              _buildCustomerOrderItems(context, order.items),
              SizedboxSpaccing.height02(context),
              if (order.customerNote != null && order.customerNote!.isNotEmpty) ...[_buildCustomerNotes(context, order.customerNote!), SizedboxSpaccing.height02(context)],
              if (!isPending)...[ _buildDeliveryItemsSection(context, order.items),
                SizedboxSpaccing.height02(context),
                _buildTotalSection(context, order),
                SizedboxSpaccing.height02(context),
              ],

              if(isArriveDestination)...[
                _buildPaymentMethodSection(context),
                SizedboxSpaccing.height02(context),
                DualTermsCheckbox(
                  isTermsAccepted: _isTermsAccepted,
                  isReviewAccepted: _isReviewAccepted,
                  onTermsChanged: (value) => setState(() => _isTermsAccepted = value),
                  onReviewChanged: (value) => setState(() => _isReviewAccepted = value),
                  context: context,
                  onTermsTap: () => Navigator.pushNamed(context, RoutesName.termsAndCondition),
                  onPrivacyTap: () => Navigator.pushNamed(context, RoutesName.privacyPolicy),
                  onRefundTap: () => Navigator.pushNamed(context, RoutesName.refundPolicyScreen),
                  getButtonColor: (ctx) => AppColors.button(ctx),
                  getBorderColor: (ctx) => AppColors.border(ctx),
                  getWhiteColor: (ctx) => AppColors.whiteColor,
                  getTextStyle: (ctx, {weight}) =>
                      AppTextStyles.textSize14(ctx, weight: weight ?? FontWeight.w400),
                ),
                SizedboxSpaccing.height02(context),
                _buildPayNowButton(context,order),   // ← ADD THIS
                SizedboxSpaccing.height02(context),
              ]
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderProgress(BuildContext context, String? deliveryStatus) {
    List<String> steps = ['Dinmajur', 'Pickup', 'Delivery', 'Complete'];
    List<IconData> stepIcons = [FontAwesomeIcons.user, FontAwesomeIcons.box, FontAwesomeIcons.truck, FontAwesomeIcons.check];
    final screenWidth = MediaQuery.of(context).size.width;

    bool isPending = deliveryStatus?.toUpperCase() == 'PENDING';

    if (isPending) {
      return Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.orange.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.orange, width: 1),
        ),
        child: Row(
          children: [
            Icon(Icons.hourglass_empty, color: Colors.orange, size: 24),
            SizedboxSpaccing.width03(context),
            Expanded(
              child: Text(
                'Order is pending. Waiting for freelancer acceptance...',
                style: AppTextStyles.textSize14(context, weight: FontWeight.w500, color: Colors.orange),
              ),
            ),
          ],
        ),
      );
    }

    int currentStep = _getCurrentStepFromStatus(deliveryStatus);

    return Column(
      children: [
        Container(
          width: screenWidth * 0.8,
          child: Row(
            children: List.generate(steps.length * 2 - 1, (index) {
              if (index.isEven) {
                int stepIndex = index ~/ 2;
                bool isActive = stepIndex <= currentStep;

                return Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isActive ? AppColors.button(context) : AppColors.containerBackground(context),
                    border: Border.all(width: 1, color: isActive ? AppColors.button(context) : AppColors.border(context)),
                  ),
                  child: Icon(stepIcons[stepIndex], color: isActive ? Colors.white : Colors.grey, size: 16),
                );
              } else {
                int lineIndex = (index - 1) ~/ 2;
                return Expanded(child: Container(height: 2, color: lineIndex < currentStep ? AppColors.button(context) : AppColors.border(context)));
              }
            }),
          ),
        ),
        SizedboxSpaccing.height01(context),
        Container(
          width: screenWidth * 0.92,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(steps.length, (index) {
              bool isActive = index <= currentStep;
              bool isCurrent = index == currentStep;

              return Expanded(
                child: Container(
                  height: 30,
                  width: 70,
                  child: Center(
                    child: Text(
                      steps[index],
                      style: AppTextStyles.textSize12(context, weight: isCurrent ? FontWeight.w600 : FontWeight.w400, color: isActive ? AppColors.textPrimary(context) : AppColors.subtitle(context)),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildCustomerInfo(BuildContext context, Customer? customer, Retailer? retailer, Order order, Delivery? delivery, Freelancer? freelancer) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      padding: EdgeInsets.all(screenHeight * 0.02),
      decoration: BoxDecoration(
        color: AppColors.containerBackground(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(width: 1, color: AppColors.oceanGreenColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(color: AppColors.textPrimary(context), borderRadius: BorderRadius.circular(8)),
                      child: Icon(FontAwesomeIcons.store, color: AppColors.containerBackground(context), size: 16),
                    ),
                    SizedboxSpaccing.width03(context),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            customer?.fullName ?? 'N/A',
                            style: AppTextStyles.textSize18(context, weight: FontWeight.w500, color: AppColors.textPrimary(context)),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'Under: ${retailer?.businessName ?? 'N/A'}',
                            style: AppTextStyles.textSize14(context, weight: FontWeight.w400, color: AppColors.subtitle(context)),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedboxSpaccing.width02(context),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: AppColors.textFieldFill(context), borderRadius: BorderRadius.circular(8)),
                child: Text('Order #${order.id?.substring(order.id!.length - 6) ?? 'N/A'}', style: AppTextStyles.textSize12(context, weight: FontWeight.w400)),
              ),
            ],
          ),
          SizedboxSpaccing.height02(context),
          if (freelancer != null && delivery?.status?.toUpperCase() != 'PENDING') ...[
            Container(
              padding: EdgeInsets.all(screenHeight * 0.015),
              decoration: BoxDecoration(
                color: AppColors.textFieldFill(context),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border(context)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.button(context)),
                        child: ClipOval(
                          child: freelancer.profilePicture?.url != null && freelancer.profilePicture!.url!.isNotEmpty
                              ? Image.network(freelancer.profilePicture!.url!, width: 40, height: 40, fit: BoxFit.cover)
                              : Icon(Icons.person, color: Colors.white, size: 20),
                        ),
                      ),
                      SizedboxSpaccing.width03(context),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${freelancer?.firstName ?? ''} ${freelancer?.lastName ?? ''}'.trim(),
                            style: AppTextStyles.textSize14(context, weight: FontWeight.w500, color: AppColors.button(context)),
                          ),
                          Row(
                            children: [
                              Icon(Icons.star, size: 14, color: Colors.amber),
                              SizedboxSpaccing.width01(context),
                              Text('${freelancer.rating?.toStringAsFixed(1) ?? 'N/A'}', style: AppTextStyles.textSize12(context, weight: FontWeight.w400)),
                              SizedboxSpaccing.width02(context),
                              Text(
                                '• ${freelancer.totalOrders ?? 0} orders',
                                style: AppTextStyles.textSize12(context, weight: FontWeight.w400, color: AppColors.subtitle(context)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  if (freelancer.acceptedAt != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Accepted at',
                          style: AppTextStyles.textSize10(context, weight: FontWeight.w400, color: AppColors.subtitle(context)),
                        ),
                        Text(
                          _formatAcceptedTime(freelancer.acceptedAt!),
                          style: AppTextStyles.textSize12(context, weight: FontWeight.w500, color: AppColors.button(context)),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            SizedboxSpaccing.height02(context),
          ],
          Row(
            children: [
              Text('Budget: ', style: AppTextStyles.textSize14(context, weight: FontWeight.w500)),
              Text('৳${order.budget ?? 0}', style: AppTextStyles.textSize14(context, weight: FontWeight.w400)),
            ],
          ),
          SizedboxSpaccing.height01(context),
          _buildOrderDateTime(context, order.createdAt, order.estimatedDeliveryTime),
          SizedboxSpaccing.height02(context),
          _buildDeliveryAddress(context, delivery),
        ],
      ),
    );
  }

  String _formatAcceptedTime(DateTime acceptedAt) {
    DateTime bdTime = acceptedAt.add(Duration(hours: 6));
    return DateFormat('hh:mm a').format(bdTime);
  }

  Widget _buildOrderDateTime(BuildContext context, DateTime? createdAt, String? estimatedTime) {
    String formattedDate = 'N/A';
    String formattedTime = 'N/A';

    if (createdAt != null) {
      DateTime bdTime = createdAt.add(Duration(hours: 6));
      formattedDate = DateFormat('dd/MM/yyyy').format(bdTime);
      formattedTime = DateFormat('hh:mm a').format(bdTime);
    }

    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              Container(
                height: 12,
                width: 20,
                child: Center(
                  child: Container(
                    height: 12,
                    width: 12,
                    decoration: BoxDecoration(color: AppColors.button(context), shape: BoxShape.circle),
                  ),
                ),
              ),
              SizedboxSpaccing.width02(context),
              Text('By: $formattedTime', style: AppTextStyles.textSize14(context, weight: FontWeight.w400)),
            ],
          ),
        ),
        Row(
          children: [
            Container(
              height: 12,
              width: 20,
              child: Center(
                child: Container(
                  height: 12,
                  width: 12,
                  decoration: BoxDecoration(color: AppColors.button(context), shape: BoxShape.circle),
                ),
              ),
            ),
            SizedboxSpaccing.width02(context),
            Text(formattedDate, style: AppTextStyles.textSize14(context, weight: FontWeight.w400)),
          ],
        ),
      ],
    );
  }

  Widget _buildDeliveryAddress(BuildContext context, Delivery? delivery) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 22,
          width: 20,
          alignment: Alignment.bottomCenter,
          child: Icon(Icons.location_on, size: 16, color: AppColors.button(context)),
        ),
        SizedboxSpaccing.width02(context),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Delivery Address',
                style: AppTextStyles.textSize16(context, weight: FontWeight.w500, color: AppColors.button(context)),
              ),
              SizedboxSpaccing.height005(context),
              Text(
                delivery?.destinationFullAddress ?? 'No address available',
                style: AppTextStyles.textSize14(context, weight: FontWeight.w400, color: AppColors.subtitle(context)),
              ),
              SizedboxSpaccing.height005(context),
              Row(
                children: [
                  Icon(FontAwesomeIcons.car, size: 12, color: AppColors.subtitle(context)),
                  SizedboxSpaccing.width02(context),
                  Text(
                    '${delivery?.distance ?? 'N/A'} from Store',
                    style: AppTextStyles.textSize14(context, weight: FontWeight.w400, color: AppColors.button(context)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContactSection(BuildContext context, Freelancer? freelancer) {
    final screenHeight = MediaQuery.of(context).size.height;
    String freelancerPhone = freelancer?.phone ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Contact With Delivery Person', style: AppTextStyles.textSize18(context, weight: FontWeight.w500)),
        SizedboxSpaccing.height01(context),
        Divider(height: 1, color: AppColors.border(context)),
        SizedboxSpaccing.height02(context),
        Container(
          padding: EdgeInsets.symmetric(horizontal: screenHeight * 0.02, vertical: screenHeight * 0.015),
          decoration: BoxDecoration(
            color: AppColors.textFieldFill(context),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border(context)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.button(context)),
                    child: ClipOval(
                      child: freelancer?.profilePicture?.url != null && freelancer!.profilePicture!.url!.isNotEmpty
                          ? Image.network(
                        freelancer.profilePicture!.url!,
                        width: 34,
                        height: 34,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(Icons.person, color: Colors.white, size: 20);
                        },
                      )
                          : Icon(Icons.person, color: Colors.white, size: 20),
                    ),
                  ),
                  SizedboxSpaccing.width03(context),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${freelancer?.firstName ?? ''} ${freelancer?.lastName ?? ''}'.trim().isEmpty ? 'N/A' : '${freelancer?.firstName ?? ''} ${freelancer?.lastName ?? ''}'.trim(),
                        style: AppTextStyles.textSize14(context, weight: FontWeight.w500, color: AppColors.button(context)),
                      ),
                      Text(freelancerPhone.isEmpty ? 'N/A' : freelancerPhone, style: AppTextStyles.textSize12(context, weight: FontWeight.w400)),
                    ],
                  ),
                ],
              ),
              Row(
                children: [
                  GestureDetector(
                    onTap: freelancerPhone.isNotEmpty && freelancerPhone != 'N/A' ? () => _openWhatsApp(freelancerPhone) : null,
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.border(context) ),
                      child: Icon(Icons.message, color: AppColors.textPrimary(context), size: 18),
                    ),
                  ),
                  SizedboxSpaccing.width02(context),
                  GestureDetector(
                    onTap: freelancerPhone.isNotEmpty && freelancerPhone != 'N/A' ? () => _makePhoneCall(freelancerPhone) : null,
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(shape: BoxShape.circle, color:  AppColors.border(context)),
                      child: Icon(Icons.call, color: AppColors.textPrimary(context), size: 18),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCustomerOrderItems(BuildContext context, List<Item>? items) {
    final screenHeight = MediaQuery.of(context).size.height;
    if (items == null || items.isEmpty) {
      return SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Customer Order Items (${items.length})', style: AppTextStyles.textSize18(context, weight: FontWeight.w500)),
        SizedboxSpaccing.height01(context),
        Divider(height: 1, color: AppColors.border(context)),
        SizedboxSpaccing.height02(context),
        Container(
          padding: EdgeInsets.all(screenHeight * 0.02),
          decoration: BoxDecoration(
            color: AppColors.containerBackground(context),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border(context)),
          ),
          child: Column(
            children: List.generate(items.length, (index) {
              final item = items[index];
              return Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(item.name ?? 'N/A', style: AppTextStyles.textSize14(context, weight: FontWeight.w400)),
                      ),
                      Text(
                        '${item.quantity ?? 0} ${item.unit ?? ''}',
                        style: AppTextStyles.textSize14(context, weight: FontWeight.w400, color: AppColors.subtitle(context)),
                      ),
                    ],
                  ),
                  if (index < items.length - 1) ...[SizedboxSpaccing.height01(context), Divider(height: 1, color: AppColors.border(context)), SizedboxSpaccing.height01(context)],
                ],
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildCustomerNotes(BuildContext context, String customerNote) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.containerBackground(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(screenHeight * 0.02),
            child: Row(
              children: [
                Icon(FontAwesomeIcons.solidMessage, size: 18, color: AppColors.textPrimary(context)),
                SizedboxSpaccing.width02(context),
                Text('Customer Notes', style: AppTextStyles.textSize18(context, weight: FontWeight.w500)),
              ],
            ),
          ),
          Divider(height: 1, color: AppColors.border(context)),
          Padding(
            padding: EdgeInsets.all(screenHeight * 0.02),
            child: Container(
              padding: EdgeInsets.all(screenHeight * 0.02),
              decoration: BoxDecoration(
                color: AppColors.textFieldFill(context),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(width: 1, color: AppColors.border(context)),
              ),
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(
                  customerNote,
                  style: AppTextStyles.textSize14(context, weight: FontWeight.w400, color: AppColors.textPrimary(context)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryItemsSection(BuildContext context, List<Item>? items) {
    final screenHeight = MediaQuery.of(context).size.height;
    if (items == null || items.isEmpty) {
      return SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Delivery Items', style: AppTextStyles.textSize18(context, weight: FontWeight.w500)),
        SizedboxSpaccing.height01(context),
        Divider(height: 1, color: AppColors.border(context)),
        SizedboxSpaccing.height02(context),
        Container(
          decoration: BoxDecoration(
            color: AppColors.containerBackground(context),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border(context)),
          ),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(screenHeight * 0.015),
                decoration: BoxDecoration(
                  color: AppColors.containerBackground(context),
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text('Item Name', style: AppTextStyles.textSize14(context, weight: FontWeight.w600)),
                    ),
                    Expanded(
                      child: Text(
                        'Weight/Pcs/Qty',
                        style: AppTextStyles.textSize14(context, weight: FontWeight.w600),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'Price',
                        style: AppTextStyles.textSize14(context, weight: FontWeight.w600),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
              ),
              Divider(height: 1, color: AppColors.border(context)),
              ...List.generate(items.length, (index) {
                final item = items[index];
                bool isNotFound = item.status?.toLowerCase() == 'not_found' || item.totalPrice == null || item.totalPrice == 0;

                return Column(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: screenHeight * 0.015, vertical: screenHeight * 0.012),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: Text(
                                  item.name ?? 'N/A',
                                  style: AppTextStyles.textSize14(
                                    context,
                                    weight: FontWeight.w400,
                                  ).copyWith(decoration: isNotFound ? TextDecoration.lineThrough : null, decorationColor: isNotFound ? Colors.red : null, decorationThickness: isNotFound ? 2.0 : null),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  '${item.quantity ?? 0} ${item.unit ?? ''}',
                                  style: AppTextStyles.textSize14(
                                    context,
                                    weight: FontWeight.w400,
                                    color: AppColors.subtitle(context),
                                  ).copyWith(decoration: isNotFound ? TextDecoration.lineThrough : null, decorationColor: isNotFound ? Colors.red : null, decorationThickness: isNotFound ? 2.0 : null),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  isNotFound ? '' : '৳${item.totalPrice ?? 0}',
                                  style: AppTextStyles.textSize14(context, weight: FontWeight.w400, color: AppColors.subtitle(context)),
                                  textAlign: TextAlign.right,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            "Dinmajur's comment:",
                            style: AppTextStyles.textSize14(context, weight: FontWeight.w400).copyWith(decoration: TextDecoration.underline, decorationThickness: 1.0),
                          ),
                          Text(
                            (item.comment == null || item.comment!.isEmpty) ? 'N/A' : item.comment!,
                            style: AppTextStyles.textSize12(context, weight: FontWeight.w400, color: AppColors.subtitle(context)),
                          ),
                          SizedboxSpaccing.height005(context),
                        ],
                      ),
                    ),
                    if (index < items.length - 1) Divider(height: 1, color: AppColors.border(context), indent: screenHeight * 0.015, endIndent: screenHeight * 0.015),
                  ],
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildConfirmationCard(BuildContext context) {
    return Container(
      height: 132,
      padding: EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.containerBackground(context),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(width: 1, color: AppColors.border(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Order Confirmed!",
            style: AppTextStyles.textSize24(context, weight: FontWeight.w600, color: AppColors.button(context)),
          ),
          SizedboxSpaccing.height012(context),
          Text(
            "Dinmajur will accept orders within a short time.",
            style: AppTextStyles.textSize16(context, weight: FontWeight.w500),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodSection(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Column(
      children: [
        SectionHeader(title: 'Payment Method', titleWidth: screenWidth * 0.6, showSeeAll: false),
        SizedboxSpaccing.height02(context),
        PaymentMethodWidget(
          selectedPaymentMethod: _selectedPaymentMethod,
          paymentMethods: _paymentMethods,
          onPaymentMethodChanged: (method) => setState(() => _selectedPaymentMethod = method),
        ),
      ],
    );
  }

  Widget _buildPayNowButton(BuildContext context,Order order) {
    return GestureDetector(
      onTap: () => _handlePayNow(context, order),
      child: Container(
          height: 48,
          width: double.infinity,
          decoration: BoxDecoration(
              color: AppColors.button(context),
              borderRadius: BorderRadius.circular(8)
          ),
          child:Center(
            child:  Text(
              'Pay Now',
              style: AppTextStyles.textSize16(context, weight: FontWeight.w600, color: AppColors.whiteColor),
            ),
          )
      ),
    );
  }

  int _getFoundItemsCount(List<Item>? items) {
    if (items == null) return 0;
    return items.where((item) => item.status?.toLowerCase() != 'not_found' && item.totalPrice != null && item.totalPrice! > 0).length;
  }

  Widget _buildTotalSection(BuildContext context, Order order) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    double subtotal = 0;
    if (order.items != null) {
      subtotal = order.items!.fold(0.0, (sum, item) {
        if (item.status?.toLowerCase() != 'not_found' && item.totalPrice != null && item.totalPrice! > 0) {
          return sum + item.totalPrice!;
        }
        return sum;
      });
    }

    double serviceFee = order.serviceFee?.toDouble() ?? 0;
    double deliveryFee = order.freelancerEarning?.toDouble() ?? 0;
    double total = subtotal + serviceFee + deliveryFee;
    int foundItems = _getFoundItemsCount(order.items);

    return Column(
      children: [
        SectionHeader(title: 'Payment Summary', titleWidth: screenWidth * 0.6, showSeeAll: false),
        SizedboxSpaccing.height02(context),
        Container(
          decoration: BoxDecoration(
            color: AppColors.containerBackground(context),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border(context)),
          ),
          padding: EdgeInsets.all(screenHeight * 0.02),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Order:',
                    style: AppTextStyles.textSize14(context, weight: FontWeight.w400, color: AppColors.subtitle(context)),
                  ),
                  Text('$foundItems items', style: AppTextStyles.textSize14(context, weight: FontWeight.w400)),
                ],
              ),
              SizedboxSpaccing.height015(context),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Subtotal:',
                    style: AppTextStyles.textSize14(context, weight: FontWeight.w400, color: AppColors.subtitle(context)),
                  ),
                  Text('৳${subtotal.toStringAsFixed(0)}', style: AppTextStyles.textSize14(context, weight: FontWeight.w400)),
                ],
              ),
              SizedboxSpaccing.height015(context),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Delivery Fee:',
                    style: AppTextStyles.textSize14(context, weight: FontWeight.w400, color: AppColors.subtitle(context)),
                  ),
                  Text('৳${deliveryFee.toStringAsFixed(0)}', style: AppTextStyles.textSize14(context, weight: FontWeight.w400)),
                ],
              ),
              SizedboxSpaccing.height015(context),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Service Fee:',
                    style: AppTextStyles.textSize14(context, weight: FontWeight.w400, color: AppColors.subtitle(context)),
                  ),
                  Text('৳${serviceFee.toStringAsFixed(0)}', style: AppTextStyles.textSize14(context, weight: FontWeight.w400)),
                ],
              ),
              SizedboxSpaccing.height015(context),
              Divider(height: 1, color: AppColors.border(context)),
              SizedboxSpaccing.height015(context),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total Amount:', style: AppTextStyles.textSize16(context, weight: FontWeight.w600)),
                  Text('৳${total.toStringAsFixed(0)}', style: AppTextStyles.textSize16(context, weight: FontWeight.w600)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _cleanPhoneNumber(String phoneNumber) {
    String cleaned = phoneNumber.replaceAll(RegExp(r'[^0-9+]'), '');

    if (cleaned.startsWith('+88')) {
      cleaned = cleaned.substring(3);
    } else if (cleaned.startsWith('88')) {
      cleaned = cleaned.substring(2);
    }

    if (!cleaned.startsWith('0') && cleaned.length == 10) {
      cleaned = '0$cleaned';
    }

    return cleaned;
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    String cleanNumber = _cleanPhoneNumber(phoneNumber);
    final Uri phoneUri = Uri(scheme: 'tel', path: cleanNumber);

    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      if (mounted) {
        Utils.flushBarErrorMessage("Could not launch phone dialer", context);
      }
    }
  }

  Future<void> _openWhatsApp(String phoneNumber) async {
    String cleanNumber = _cleanPhoneNumber(phoneNumber);

    if (cleanNumber.startsWith('0')) {
      cleanNumber = cleanNumber.substring(1);
    }

    String whatsappNumber = '+880$cleanNumber';
    final Uri whatsappUri = Uri.parse('https://wa.me/$whatsappNumber');

    if (await canLaunchUrl(whatsappUri)) {
      await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        Utils.flushBarErrorMessage("Could not open WhatsApp", context);
      }
    }
  }


  Future<void> _handlePayNow(BuildContext context, Order order) async {
    // ── 1. Payment method check ────────────────────────────────────────────
    if (_selectedPaymentMethod == null) {
      Utils.flushBarErrorMessage("Please select a payment method.", context);
      return;
    }

    // ── 2. Terms & conditions check ────────────────────────────────────────
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

    // ── 3. Hand Cash → confirmation dialog ────────────────────────────────
    if (_selectedPaymentMethod == 'cash') {
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
        print('✅ Cash payment confirmed for order: ${order.id}');
      }
      return;
    }

// ── 4. Online → SSL payment ────────────────────────────────────────────
    if (_selectedPaymentMethod == 'online') {
      double subtotal = order.items?.fold(0.0, (sum, item) {
        if (item.status?.toLowerCase() != 'not_found' &&
            item.totalPrice != null &&
            item.totalPrice! > 0) {
          return sum! + item.totalPrice!;
        }
        return sum!;
      }) ??
          0.0;

      double total = subtotal +
          (order.serviceFee?.toDouble() ?? 0) +
          (order.freelancerEarning?.toDouble() ?? 0);

      final customer = _orderDetailsProvider?.orderDetailsModel?.customer;
      final delivery = _orderDetailsProvider?.orderDetailsModel?.delivery;

      final result = await SSLCommerzPaymentService().initiatePayment(  // ← FIXED name
        trackingId: order.id ?? '',
        totalAmount: total,
        productCategory: "Delivery Service",
        customerName: customer?.fullName,
        customerPhone: customer?.phone,
        customerEmail: "",
        customerAddress: delivery?.destinationFullAddress,
      );

      if (!mounted) return;

      if (result.success) {
        print('💳 SSL payment success: ${result.transactionId}');
        // TODO: navigate to success screen or call your confirm API
      } else if (result.status == 'CANCELLED') {
        Utils.flushBarErrorMessage("Payment was cancelled.", context);
      } else {
        Utils.flushBarErrorMessage(
          result.errorMessage ?? 'Payment failed. Please try again.',
          context,
        );
      }
    }
  }
}
