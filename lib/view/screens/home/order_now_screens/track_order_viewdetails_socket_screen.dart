import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/components/header_appbar.dart';
import 'package:dinmajur_customer/configs/res/sizedbox_spaccing.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:dinmajur_customer/configs/utils/routes/routes_name.dart';
import 'package:dinmajur_customer/configs/utils/utils.dart';
import 'package:dinmajur_customer/model/home_models/socket_home_model/socket_get_all_orders_model/socket_orderdetails_model.dart';
import 'package:dinmajur_customer/socket_connection_model/screens_sockets/home_sceens_socket/get_all_orders_socket/socket_order_view_details.dart';
import 'package:dinmajur_customer/socket_connection_model/socket_provider_services/socket_provider.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class TrackOrderViewdetailsSocketScreen extends StatefulWidget {
  final String orderId;
  const TrackOrderViewdetailsSocketScreen({Key? key, required this.orderId}) : super(key: key);

  @override
  State<TrackOrderViewdetailsSocketScreen> createState() => _TrackOrderViewdetailsSocketScreenState();
}


class _TrackOrderViewdetailsSocketScreenState extends State<TrackOrderViewdetailsSocketScreen> with WidgetsBindingObserver {
  int _currentStep = 0;

  OrderDetailsModel? _orderDetailsModel;
  bool _isLoadingOrderDetails = false;
  String? _orderDetailsError;
  bool _orderDetailsSocketInitialized = false;

  SocketProvider? _socketProvider;
  OrderDetailsSocketProvider? _orderDetailsSocketProvider;
  bool _isDisposed = false;
  bool _hasRequestedOrder = false;

  bool _isProcessing = false;

  String? _previousDeliveryStatus;
  bool _hasNavigatedToDelivered = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isDisposed && mounted) {
        _initializeAndFetch();
      }
    });
  }
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed) {
      print('📱 App resumed - re-initializing socket listeners');

      // Longer delay to ensure main.dart completes reconnection
      Future.delayed(Duration(milliseconds: 2000), () {
        if (!_isDisposed && mounted) {
          _handleAppResumed();
        }
      });
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.hidden) {
      print('📱 App paused/inactive/hidden - marking for re-initialization');
      // Mark that we need to re-initialize on resume
      _orderDetailsSocketInitialized = false;
    }
  }

  Future<void> _handleAppResumed() async {
    if (_isDisposed || !mounted) return;

    print('📱 Handling app resume with full re-initialization');

    try {
      setState(() {
        _isProcessing = true;
        _orderDetailsError = null;
      });

      // Re-get providers
      _socketProvider = Provider.of<SocketProvider>(context, listen: false);
      _orderDetailsSocketProvider = Provider.of<OrderDetailsSocketProvider>(context, listen: false);

      // ✅ Wait for socket to reconnect
      print('⏳ Waiting for socket reconnection...');
      int waitAttempts = 0;
      const maxWaitAttempts = 20; // Wait up to 10 seconds

      while (_socketProvider?.isConnected != true && waitAttempts < maxWaitAttempts) {
        if (_isDisposed || !mounted) return;

        await Future.delayed(Duration(milliseconds: 500));
        _socketProvider = Provider.of<SocketProvider>(context, listen: false);
        waitAttempts++;
        print('⏳ Attempt ${waitAttempts}/$maxWaitAttempts - Connected: ${_socketProvider?.isConnected}');
      }

      if (_socketProvider?.isConnected != true) {
        throw Exception('Socket reconnection timeout');
      }

      print('✅ Socket reconnected');

      // ✅ CRITICAL: Wait for user registration to complete
      await Future.delayed(Duration(milliseconds: 1500));

      // ✅ CRITICAL: Clear ALL old listeners completely
      _orderDetailsSocketProvider!.clearOrderDetailsListeners();

      // ✅ Force reset the socket provider completely
      _orderDetailsSocketProvider!.reset();

      await Future.delayed(Duration(milliseconds: 300));

      // ✅ Re-initialize with the NEW socket instance
      _orderDetailsSocketProvider!.initializeWithSocketProvider(_socketProvider!);

      await Future.delayed(Duration(milliseconds: 500));

      // ✅ Reset flags
      _orderDetailsSocketInitialized = true;
      _hasRequestedOrder = false;

      print('✅ Socket providers re-initialized, fetching data...');

      // ✅ Re-fetch with fresh listeners on NEW socket
      await _fetchOrderDetailsFromSocket();

    } catch (e) {
      print('❌ Resume handling failed: $e');
      if (mounted && !_isDisposed) {
        setState(() {
          _isProcessing = false;
          _orderDetailsError = 'Failed to reconnect. Pull to refresh.';
        });
      }
    }
  }

  Future<void> _initializeAndFetch() async {
    if (_isDisposed || !mounted) return;

    try {
      setState(() {
        _isLoadingOrderDetails = true;
        _orderDetailsError = null;
      });

      // Get providers
      _socketProvider = Provider.of<SocketProvider>(context, listen: false);
      _orderDetailsSocketProvider = Provider.of<OrderDetailsSocketProvider>(context, listen: false);

      // ✅ NEW: Wait for socket connection with timeout
      print('🔌 Checking socket connection...');

      int waitAttempts = 0;
      const maxWaitAttempts = 20; // Wait up to 10 seconds (20 x 500ms)

      while (!_socketProvider!.isConnected && waitAttempts < maxWaitAttempts) {
        if (_isDisposed || !mounted) return;

        print('⏳ Socket not connected yet, waiting... (attempt ${waitAttempts + 1}/$maxWaitAttempts)');
        await Future.delayed(Duration(milliseconds: 500));

        // Re-get provider in case it updated
        _socketProvider = Provider.of<SocketProvider>(context, listen: false);
        waitAttempts++;
      }

      // Check if socket is now connected
      if (!_socketProvider!.isConnected) {
        throw Exception('Could not connect to server. Please check your connection and try again.');
      }

      print('✅ Socket connected successfully');

      // Initialize socket provider (setup listeners)
      _orderDetailsSocketProvider!.initializeWithSocketProvider(_socketProvider!);
      await Future.delayed(Duration(milliseconds: 300));

      setState(() {
        _orderDetailsSocketInitialized = true;
      });

      // Fetch order details
      await _fetchOrderDetailsFromSocket();

    } catch (e) {
      print('❌ Initialization failed: $e');
      if (mounted && !_isDisposed) {
        setState(() {
          _orderDetailsError = e.toString().replaceAll('Exception: ', '');
          _isLoadingOrderDetails = false;
        });
      }
    }
  }

  Future<void> _handleRefresh() async {
    if (_isDisposed || !mounted || _isProcessing) return;

    print('🔄 Refresh triggered - full re-initialization');

    setState(() {
      _isProcessing = true;
      _orderDetailsError = null;
    });

    try {
      // Re-get providers
      _socketProvider = Provider.of<SocketProvider>(context, listen: false);
      _orderDetailsSocketProvider = Provider.of<OrderDetailsSocketProvider>(context, listen: false);

      // Check socket connection
      if (_socketProvider?.isConnected != true) {
        throw Exception('Socket not connected. Please try again.');
      }

      // ✅ CRITICAL: Full reset and re-initialization
      print('🔄 Clearing old listeners and resetting...');

      _orderDetailsSocketProvider!.clearOrderDetailsListeners();
      _orderDetailsSocketProvider!.reset();

      await Future.delayed(Duration(milliseconds: 300));

      // ✅ Re-initialize with current socket
      print('🔄 Re-initializing socket providers...');
      _orderDetailsSocketProvider!.initializeWithSocketProvider(_socketProvider!);

      await Future.delayed(Duration(milliseconds: 500));

      _orderDetailsSocketInitialized = true;
      _hasRequestedOrder = false;

      // ✅ Fetch with fresh listeners
      await _fetchOrderDetailsFromSocket();

    } catch (e) {
      print('❌ Refresh failed: $e');
      if (mounted && !_isDisposed) {
        setState(() {
          _isProcessing = false;
          _orderDetailsError = 'Refresh failed: ${e.toString()}';
        });
      }
    }
  }
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isDisposed) {
      _socketProvider = Provider.of<SocketProvider>(context, listen: false);
      _orderDetailsSocketProvider = Provider.of<OrderDetailsSocketProvider>(context, listen: false);
    }
  }

  // ✅ MAIN FETCH FUNCTION - Just emit and listen
  Future<void> _fetchOrderDetailsFromSocket() async {
    if (!_orderDetailsSocketInitialized || _isDisposed || _hasRequestedOrder || !mounted) {
      print('⚠️ Cannot fetch: initialized=$_orderDetailsSocketInitialized, disposed=$_isDisposed, requested=$_hasRequestedOrder, mounted=$mounted');
      return;
    }

    try {
      _hasRequestedOrder = true;

      setState(() {
        _isProcessing = true;
        _orderDetailsError = null;
      });

      String orderId = widget.orderId.trim();
      if (orderId.isEmpty || orderId == 'N/A') {
        throw Exception('Invalid order ID: $orderId');
      }

      // ✅ Verify socket is still connected
      if (!_socketProvider!.isConnected) {
        throw Exception('Socket disconnected during fetch');
      }

      print('📤 Emitting request-order-details for: $orderId');

      // ✅ Setup FRESH listeners (these will be on the new socket instance)
      _orderDetailsSocketProvider!.setOrderDetailsListener((OrderDetailsModel model) {
        print('✅ Received order details via listener');
        if (mounted && !_isDisposed) {
          try {
            _checkDeliveryStatusForNavigation(model.delivery?.status);

            setState(() {
              _orderDetailsModel = model;
              _isProcessing = false;
              _isLoadingOrderDetails = false;
              _orderDetailsError = null;
            });

            print('✅ State updated with new order details');
          } catch (e) {
            print('❌ Error updating state: $e');
          }
        }
      });

      _orderDetailsSocketProvider!.setOrderDetailsErrorListener((error) {
        print('❌ Received error via listener: $error');
        if (mounted && !_isDisposed) {
          setState(() {
            _isProcessing = false;
            _isLoadingOrderDetails = false;
            _orderDetailsError = error;
          });
        }
      });

      // ✅ Small delay to ensure listeners are registered
      await Future.delayed(Duration(milliseconds: 200));

      // ✅ Emit request on the NEW socket
      await _orderDetailsSocketProvider!.viewOrderDetails(orderId);

      print('📤 Request emitted successfully');

      // Timeout handler
      Future.delayed(Duration(seconds: 20), () {
        if (mounted && !_isDisposed && _isProcessing) {
          print('⏱️ Request timeout');
          setState(() {
            _isProcessing = false;
            _isLoadingOrderDetails = false;
            _orderDetailsError = 'Request timeout - please try again';
          });
          _hasRequestedOrder = false;
        }
      });
    } catch (e) {
      print('❌ Fetch error: $e');
      _hasRequestedOrder = false;
      if (mounted && !_isDisposed) {
        setState(() {
          _isProcessing = false;
          _isLoadingOrderDetails = false;
          _orderDetailsError = 'Failed to fetch: $e';
        });
      }
    }
  }

  void _checkDeliveryStatusForNavigation(String? currentStatus) {
    if (_hasNavigatedToDelivered || !mounted || _isDisposed) return;

    bool shouldNavigate = false;

    if (currentStatus?.toUpperCase() == 'DELIVERED' &&
        _previousDeliveryStatus?.toUpperCase() != 'DELIVERED') {
      print('Status changed to DELIVERED - will navigate in 2 seconds');
      shouldNavigate = true;
    }

    if (shouldNavigate) {
      _hasNavigatedToDelivered = true;

      Future.delayed(Duration(milliseconds: 2000), () {
        if (mounted && !_isDisposed) {
          Navigator.pushNamed(
              context,
              RoutesName.deliverdScreen,
              arguments: {'orderId': widget.orderId}
          );
        }
      });
    }

    _previousDeliveryStatus = currentStatus;
  }

  @override
  void dispose() {
    _isDisposed = true;
    WidgetsBinding.instance.removeObserver(this);

    try {
      if (_orderDetailsSocketProvider != null) {
        _orderDetailsSocketProvider!.clearOrderDetailsListeners();
      }
    } catch (e) {
      print('Error clearing listeners: $e');
    }

    _socketProvider = null;
    _orderDetailsSocketProvider = null;
    super.dispose();
  }
  int _getCurrentStepFromStatus(String? deliveryStatus) {
    if (deliveryStatus == null) return 0;

    switch (deliveryStatus.toUpperCase()) {
      case 'PENDING':
        return 0;
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
      body: SafeArea(child: body()),
    );
  }

  Widget body() {
    return Column(
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(height: 60, child: AppBarHeader("Track Order Details")),
        ),
        Expanded(child: _buildContent()),
      ],
    );
  }

  Widget _buildContent() {
    // Show loading if processing
    if (_isProcessing) {
      return Center(
          child: LoadingAnimationWidget.progressiveDots(
              color: AppColors.button(context),
              size: 45
          )
      );
    }

    // Show error only if no data
    if (_orderDetailsError != null && _orderDetailsModel?.order == null) {
      return _buildErrorState();
    }

    // Show data if available
    if (_orderDetailsModel?.order != null) {
      return _buildOrderDetailsContent();
    }

    // Fallback
    return Center(
        child: LoadingAnimationWidget.progressiveDots(
            color: AppColors.button(context),
            size: 45
        )
    );
  }


  Widget _buildErrorState() {
    return RefreshIndicator(
      onRefresh: _handleRefresh,
      color: AppColors.button(context),
      backgroundColor: AppColors.containerBackground(context),
      displacement: 40,
      strokeWidth: 2.0,
      child: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(), // ✅ Required for RefreshIndicator
        child: Container(
          height: MediaQuery.of(context).size.height - 200, // ✅ Minimum height for scrolling
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(  FontAwesomeIcons.boxOpen, size: 50, color: Colors.red),
                  SizedboxSpaccing.height02(context),
                  Text(
                    'Unable to Load Order',
                    style: AppTextStyles.textSize18(context, weight: FontWeight.w500),
                    textAlign: TextAlign.center,
                  ),
                  SizedboxSpaccing.height01(context),
                  Text(
                    'We couldn\'t fetch the order details. Pull to refresh and try again.',
                    style: AppTextStyles.textSize14(context, color: AppColors.subtitle(context)),
                    textAlign: TextAlign.center,
                  ),
                  SizedboxSpaccing.height03(context),
                  ElevatedButton.icon(
                    onPressed: _handleRefresh,
                    icon: Icon(Icons.refresh),
                    label: Text('Refresh'),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.button(context),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12)
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildOrderDetailsContent() {
    final screenHeight = MediaQuery.of(context).size.height;
    final order = _orderDetailsModel!.order!;
    final retailer = _orderDetailsModel!.retailer;
    final delivery = _orderDetailsModel!.delivery;
    final customer = _orderDetailsModel!.customer;
    final freelancer = _orderDetailsModel!.freelancer;

    // Set current step based on delivery status
    _currentStep = _getCurrentStepFromStatus(delivery?.status);
    bool isPending = delivery?.status?.toUpperCase() == 'PENDING';
    return RefreshIndicator(
      onRefresh: _handleRefresh,
      color: AppColors.button(context),
      backgroundColor: AppColors.containerBackground(context),
      displacement: 40,
      strokeWidth: 2.0,
      child: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: Container(
          padding: EdgeInsets.all(screenHeight * 0.02),
          child: Column(
            children: [
              _buildOrderProgress(context, delivery?.status),
              SizedboxSpaccing.height02(context),
              _buildCustomerInfo(context, customer, retailer, order, delivery, freelancer),
              SizedboxSpaccing.height02(context),
              if (!isPending) ...[_buildContactSection(context, freelancer), SizedboxSpaccing.height02(context)],
              _buildCustomerOrderItems(context, order.items),
              SizedboxSpaccing.height02(context),
              if (order.customerNote != null && order.customerNote!.isNotEmpty) _buildCustomerNotes(context, order.customerNote!),
              if (order.customerNote != null && order.customerNote!.isNotEmpty) SizedboxSpaccing.height02(context),
              _buildDeliveryItemsSection(context, order.items),
              SizedboxSpaccing.height02(context),
              Divider(height: 1, color: AppColors.border(context)),
              SizedboxSpaccing.height01(context),
              _buildTotalSection(context, order),
              SizedboxSpaccing.height02(context),
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

    // Hide progress if status is pending
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

    return Column(
      children: [
        Container(
          width: screenWidth * 0.8,
          child: Row(
            children: List.generate(steps.length * 2 - 1, (index) {
              if (index.isEven) {
                int stepIndex = index ~/ 2;
                bool isActive = stepIndex <= _currentStep;

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
                return Expanded(child: Container(height: 2, color: lineIndex < _currentStep ? AppColors.button(context) : AppColors.border(context)));
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
              bool isActive = index <= _currentStep;
              bool isCurrent = index == _currentStep;
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

          // Freelancer Info Section
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
          // SizedboxSpaccing.height005(context),
          // Row(
          //   children: [
          //     Text('Income: ', style: AppTextStyles.textSize14(context, weight: FontWeight.w500)),
          //     Text('৳${order.freelancerEarning ?? 0}', style: AppTextStyles.textSize14(context, weight: FontWeight.w400)),
          //   ],
          // ),
          SizedboxSpaccing.height01(context),
          _buildOrderDateTime(context, order.createdAt, order.estimatedDeliveryTime),
          SizedboxSpaccing.height02(context),
          _buildDeliveryAddress(context, delivery),
        ],
      ),
    );
  }

  String _formatAcceptedTime(DateTime acceptedAt) {
    // Convert to BD time (UTC+6)
    DateTime bdTime = acceptedAt.add(Duration(hours: 6));
    return DateFormat('hh:mm a').format(bdTime);
  }

  Widget _buildOrderDateTime(BuildContext context, DateTime? createdAt, String? estimatedTime) {
    String formattedDate = 'N/A';
    String formattedTime = 'N/A';

    if (createdAt != null) {
      // Convert UTC to Bangladesh Time (UTC+6)
      DateTime bdTime = createdAt.add(Duration(hours: 6));

      // Format date
      formattedDate = DateFormat('dd/MM/yyyy').format(bdTime);

      // Format time with AM/PM
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
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Center(child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)));
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
                      decoration: BoxDecoration(shape: BoxShape.circle, color: freelancerPhone.isNotEmpty && freelancerPhone != 'N/A' ? AppColors.containerBackground(context) : Colors.grey),
                      child: Icon(Icons.message, color: AppColors.textPrimary(context), size: 18),
                    ),
                  ),
                  SizedboxSpaccing.width02(context),
                  GestureDetector(
                    onTap: freelancerPhone.isNotEmpty && freelancerPhone != 'N/A' ? () => _makePhoneCall(freelancerPhone) : null,
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(shape: BoxShape.circle, color: freelancerPhone.isNotEmpty && freelancerPhone != 'N/A' ? AppColors.containerBackground(context) : Colors.grey),
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

  int _getFoundItemsCount(List<Item>? items) {
    if (items == null) return 0;
    return items.where((item) => item.status?.toLowerCase() != 'not_found' && item.totalPrice != null && item.totalPrice! > 0).length;
  }

  Widget _buildTotalSection(BuildContext context, Order order) {
    // Calculate subtotal from items
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
    double total = subtotal + serviceFee;
    int foundItems = _getFoundItemsCount(order.items);

    return Container(
      decoration: BoxDecoration(color: AppColors.containerBackground(context), borderRadius: BorderRadius.circular(12)),
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
          SizedboxSpaccing.height01(context),
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
          SizedboxSpaccing.height01(context),
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
          SizedboxSpaccing.height01(context),
          Divider(height: 1, color: AppColors.border(context)),
          SizedboxSpaccing.height01(context),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total Amount:', style: AppTextStyles.textSize16(context, weight: FontWeight.w600)),
              Text('৳${total.toStringAsFixed(0)}', style: AppTextStyles.textSize16(context, weight: FontWeight.w600)),
            ],
          ),
          // SizedboxSpaccing.height005(context),
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //   children: [
          //     Text(
          //       'Your Earnings:',
          //       style: AppTextStyles.textSize14(context, weight: FontWeight.w400, color: Colors.green),
          //     ),
          //     Text(
          //       '৳${order.freelancerEarning ?? 0}',
          //       style: AppTextStyles.textSize14(context, weight: FontWeight.w400, color: Colors.green),
          //     ),
          //   ],
          // ),
        ],
      ),
    );
  }

  ///Call And WhatsApp Functionality:
  String _cleanPhoneNumber(String phoneNumber) {
    // Remove all non-digit characters except '+'
    String cleaned = phoneNumber.replaceAll(RegExp(r'[^0-9+]'), '');

    // Remove +88 or 88 prefix if present
    if (cleaned.startsWith('+88')) {
      cleaned = cleaned.substring(3); // Remove '+88'
    } else if (cleaned.startsWith('88')) {
      cleaned = cleaned.substring(2); // Remove '88'
    }

    // Ensure it starts with 0 (BD format)
    if (!cleaned.startsWith('0') && cleaned.length == 10) {
      cleaned = '0$cleaned';
    }

    return cleaned;
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    String cleanNumber = _cleanPhoneNumber(phoneNumber);

    // For phone dialer, use the clean 11-digit number starting with 0
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

    // For WhatsApp, add +880 prefix and remove leading 0
    if (cleanNumber.startsWith('0')) {
      cleanNumber = cleanNumber.substring(1); // Remove leading 0
    }

    // Add Bangladesh country code
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
}
