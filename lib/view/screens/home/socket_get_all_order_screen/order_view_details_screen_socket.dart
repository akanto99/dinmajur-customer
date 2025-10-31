import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/components/header_appbar.dart';
import 'package:dinmajur_customer/configs/res/sizedbox_spaccing.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:dinmajur_customer/model/home_models/socket_home_model/socket_get_all_orders_model/socket_orderdetails_model.dart';
import 'package:dinmajur_customer/socket_connection_model/screens_sockets/home_sceens_socket/get_all_orders_socket/socket_order_view_details.dart';
import 'package:dinmajur_customer/socket_connection_model/socket_provider_services/socket_provider.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';

class OrderDetailsSocketScreen extends StatefulWidget {
  final String orderId;

  const OrderDetailsSocketScreen({Key? key, required this.orderId,}) : super(key: key);

  @override
  State<OrderDetailsSocketScreen> createState() => _OrderDetailsSocketScreenState();
}

class _OrderDetailsSocketScreenState extends State<OrderDetailsSocketScreen> {
  int _currentStep = 0;
  OrderDetailsModel? _orderDetailsModel;
  bool _isLoadingOrderDetails = false;
  String? _orderDetailsError;
  bool _orderDetailsSocketInitialized = false;

  SocketProvider? _socketProvider;
  OrderDetailsSocketProvider? _orderDetailsSocketProvider;
  bool _isDisposed = false;
  bool _hasRequestedOrder = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ///Initialte View Details Order Socket
      if (!_isDisposed && mounted) {
        _initializeProviders();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isDisposed) {
      _socketProvider = Provider.of<SocketProvider>(context, listen: false);
      _orderDetailsSocketProvider = Provider.of<OrderDetailsSocketProvider>(context, listen: false);
    }
  }

  Future<void> _initializeProviders() async {
    if (_isDisposed || !mounted) return;

    try {
      if (widget.orderId.isEmpty || widget.orderId == 'N/A') {
        throw Exception('Invalid order ID: ${widget.orderId}');
      }

      _socketProvider = Provider.of<SocketProvider>(context, listen: false);
      _orderDetailsSocketProvider = Provider.of<OrderDetailsSocketProvider>(context, listen: false);

      if (_socketProvider == null || _orderDetailsSocketProvider == null) {
        throw Exception('Providers not available');
      }

      await _waitForSocketConnection(_socketProvider!);

      if (!_socketProvider!.isConnected) {
        throw Exception('Main socket not connected after timeout');
      }

      _orderDetailsSocketProvider!.initializeWithSocketProvider(_socketProvider!);
      await Future.delayed(Duration(milliseconds: 500));

      if (mounted && !_isDisposed) {
        setState(() {
          _orderDetailsSocketInitialized = true;
        });
        await _fetchOrderDetailsFromSocket();
      }
    } catch (e) {
      if (mounted && !_isDisposed) {
        setState(() {
          _orderDetailsError = 'Failed to initialize: $e';
          _isLoadingOrderDetails = false;
        });
      }
    }
  }

  Future<void> _waitForSocketConnection(SocketProvider socketProvider) async {
    int attempts = 0;
    const maxAttempts = 30;
    const delayMs = 500;

    while (attempts < maxAttempts && !socketProvider.isConnected && !_isDisposed && mounted) {
      await Future.delayed(Duration(milliseconds: delayMs));
      attempts++;
    }
  }

  Future<void> _fetchOrderDetailsFromSocket() async {
    if (!_orderDetailsSocketInitialized || _isDisposed || _hasRequestedOrder || !mounted) {
      return;
    }

    try {
      _hasRequestedOrder = true;

      if (mounted) {
        setState(() {
          _isLoadingOrderDetails = true;
          _orderDetailsError = null;
        });
      }

      String orderId = widget.orderId.trim();
      if (orderId.isEmpty || orderId == 'N/A') {
        throw Exception('Invalid order ID: $orderId');
      }

      _orderDetailsSocketProvider!.setOrderDetailsListener((OrderDetailsModel orderDetailsModel) {
        if (mounted && !_isDisposed) {
          try {
            setState(() {
              _orderDetailsModel = orderDetailsModel;
              _isLoadingOrderDetails = false;
              _orderDetailsError = null;
            });
          } catch (e) {
            // Handle setState error silently
          }
        }
      });

      _orderDetailsSocketProvider!.setOrderDetailsErrorListener((error) {
        if (mounted && !_isDisposed) {
          setState(() {
            _isLoadingOrderDetails = false;
            _orderDetailsError = error;
          });
        }
      });

      await _orderDetailsSocketProvider!.viewOrderDetails(orderId);

      Future.delayed(Duration(seconds: 20), () {
        if (mounted && !_isDisposed && _isLoadingOrderDetails) {
          setState(() {
            _isLoadingOrderDetails = false;
            _orderDetailsError = 'Request timeout - please try again';
          });
          _hasRequestedOrder = false;
        }
      });
    } catch (e) {
      _hasRequestedOrder = false;
      if (mounted && !_isDisposed) {
        setState(() {
          _isLoadingOrderDetails = false;
          _orderDetailsError = 'Failed to fetch order details: $e';
        });
      }
    }
  }

  Future<void> _retryOrderDetails() async {
    _hasRequestedOrder = false;

    if (mounted) {
      setState(() {
        _orderDetailsError = null;
      });
    }

    await Future.delayed(Duration(milliseconds: 500));

    if (!_orderDetailsSocketInitialized) {
      await _initializeProviders();
    } else {
      await _fetchOrderDetailsFromSocket();
    }
  }

  @override
  void dispose() {
    _isDisposed = true;

    try {
      if (_orderDetailsSocketProvider != null) {
        _orderDetailsSocketProvider!.clearOrderDetailsListeners();
      }
    } catch (e) {
      // Handle error silently
    }

    _socketProvider = null;
    _orderDetailsSocketProvider = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.containerBackground(context),
      body: SafeArea(
        child: Column(
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(height: 60, child: AppBarHeader("Order Details")),
            ),
            Expanded(child: _buildContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoadingOrderDetails) {
      return Container(height: 15, width: 50, child: LoadingAnimationWidget.progressiveDots(color: AppColors.button(context), size: 45));
    }

    if (_orderDetailsError != null) {
      return _buildErrorState();
    }

    if (_orderDetailsModel?.order != null) {
      return _buildOrderDetailsContent();
    }
    return Container(height: 15, width: 50, child: LoadingAnimationWidget.progressiveDots(color: AppColors.button(context), size: 45));
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red),
            SizedboxSpaccing.height02(context),
            Text(
              'Failed to load order details',
              style: AppTextStyles.textSize18(context, weight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
            SizedboxSpaccing.height01(context),
            Text(
              'Order ID: ${widget.orderId}',
              style: AppTextStyles.textSize12(context, color: AppColors.subtitle(context)),
              textAlign: TextAlign.center,
            ),
            SizedboxSpaccing.height03(context),
            ElevatedButton.icon(
              onPressed: _retryOrderDetails,
              icon: Icon(Icons.refresh),
              label: Text('Retry'),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.button(context), foregroundColor: Colors.white, padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
            ),
          ],
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

    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.all(screenHeight * 0.02),
        child: Column(
          children: [
            _buildOrderProgress(context, order.status),
            SizedboxSpaccing.height02(context),
            _buildCustomerInfo(context, order, retailer, delivery, customer),
            SizedboxSpaccing.height02(context),
            _buildOrderItems(context, order),
            SizedboxSpaccing.height02(context),
            _buildCustomerNotes(context),
            SizedboxSpaccing.height03(context),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderProgress(BuildContext context, String? orderStatus) {
    if (orderStatus != null) {
      switch (orderStatus.toUpperCase()) {
        case 'PENDING':
          _currentStep = 0;
          break;
        case 'PICKUP':
          _currentStep = 1;
          break;
        case 'DELIVERY':
          _currentStep = 2;
          break;
        case 'COMPLETED':
        case 'COMPLETE':
          _currentStep = 3;
          break;
      }
    }

    List<String> steps = ['Dinmajur', 'Pickup', 'Delivery', 'Complete'];
    List<IconData> stepIcons = [Icons.shopping_cart, Icons.local_shipping, Icons.delivery_dining, Icons.check];
    final screenWidth = MediaQuery.of(context).size.width;

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
                  child: Icon(stepIcons[stepIndex], color: isActive ? Colors.white : Colors.grey, size: 20),
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

  Widget _buildCustomerInfo(BuildContext context, Order order, Retailer? retailer, Delivery? delivery,Customer? customer,) {
    final screenHeight = MediaQuery.of(context).size.height;
    String retailerName = retailer?.businessName ??'Unknown Retailer';
    String retailerType = retailer?.businessType ??'';

    return Container(
      padding: EdgeInsets.all(screenHeight * 0.02),
      decoration: BoxDecoration(
        color: AppColors.containerBackground(context),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(width: 1, color: _getStatusColor(order.status ?? 'PENDING')),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(color: AppColors.appBackground(context), borderRadius: BorderRadius.circular(8)),
                    child: Icon(Icons.storefront_outlined, color: AppColors.textPrimary(context), size: 24),
                  ),
                  SizedboxSpaccing.width03(context),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Customer Name ${customer?.phone??"No name provided"}", style: AppTextStyles.textSize18(context, weight: FontWeight.w500, color: AppColors.button(context))),
                      Text('Category: $retailerType', style: AppTextStyles.textSize14(context, weight: FontWeight.w400, color: AppColors.subtitle(context))),
                    ],
                  ),
                ],
              ),
              Container(
                height: 24,
                width: 80,
                decoration: BoxDecoration(color: _getStatusColor(order.status ?? 'PENDING'), borderRadius: BorderRadius.circular(100)),
                child: Center(
                  child: Text(
                    _getDisplayStatus(order.status ?? 'PENDING'),
                    style: AppTextStyles.textSize12(context, weight: FontWeight.w500, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          SizedboxSpaccing.height01(context),
          Divider(height: 1, color: AppColors.border(context)),
          SizedboxSpaccing.height01(context),
          Text('Budget: ৳${(order.budget ?? 0).toStringAsFixed(2)}', style: AppTextStyles.textSize14(context, weight: FontWeight.w500)),
          SizedboxSpaccing.height01(context),
          _buildOrderDateTime(context, order),
          SizedboxSpaccing.height01(context),
          Divider(height: 1, color: AppColors.border(context)),
          SizedboxSpaccing.height01(context),
          _buildDeliveryAddress(context, delivery, retailerName),
        ],
      ),
    );
  }

  String _getDisplayStatus(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return 'Pending';
      case 'RUNNING':
        return 'Running';
      case 'ACTIVE':
        return 'Active';
      case 'COMPLETED':
        return 'Completed';
      default:
        return 'Pending';
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return Colors.red.withOpacity(0.9);
      case 'RUNNING':
        return Color(0xff00424D);
      case 'ACTIVE':
        return Color(0xff00424D);
      case 'COMPLETE':
      case 'COMPLETED':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Widget _buildOrderDateTime(BuildContext context, Order order) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    String orderDate = 'Unknown';
    String orderTime = 'Unknown';

    if (order.createdAt != null) {
      DateTime createdAt = order.createdAt!;
      orderDate = '${createdAt.day}/${createdAt.month}/${createdAt.year}';
      orderTime = '${createdAt.hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')}';
    }

    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              Container(
                height: screenHeight * 0.03,
                width: screenWidth * 0.05,
                alignment: Alignment.center,
                child: Container(
                  height: 12,
                  width: 12,
                  decoration: BoxDecoration(color: AppColors.button(context), shape: BoxShape.circle),
                ),
              ),
              SizedboxSpaccing.width02(context),
              Text('By: $orderTime', style: AppTextStyles.textSize14(context, weight: FontWeight.w400)),
            ],
          ),
        ),
        Row(
          children: [
            Container(
              height: screenHeight * 0.03,
              width: screenWidth * 0.05,
              alignment: Alignment.center,
              child: Container(
                height: 12,
                width: 12,
                decoration: BoxDecoration(color: AppColors.button(context), shape: BoxShape.circle),
              ),
            ),
            SizedboxSpaccing.width02(context),
            Text(orderDate, style: AppTextStyles.textSize14(context, weight: FontWeight.w400)),
          ],
        ),
      ],
    );
  }

  Widget _buildDeliveryAddress(BuildContext context, Delivery? delivery, String retailerName) {
    String deliveryAddress = delivery?.destinationFullAddress ?? 'No address provided';
    String distance = _getFormattedDistance(delivery?.distance);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;


    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: screenHeight * 0.03,
              width: screenWidth * 0.05,
              alignment: Alignment.center,
              child: Icon(Icons.location_on, size: 16, color: AppColors.button(context)),
            ),
            SizedboxSpaccing.width02(context),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Delivery Address', style: AppTextStyles.textSize14(context, weight: FontWeight.w500)),
                  Text(deliveryAddress, style: AppTextStyles.textSize14(context, weight: FontWeight.w400)),
                ],
              ),
            ),
          ],
        ),
        SizedboxSpaccing.height01(context),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: screenHeight * 0.025,
              width: screenWidth * 0.05,
              alignment: Alignment.center,
              child: Icon(Icons.directions_car_filled, size: 16, color: AppColors.button(context)),
            ),
            SizedboxSpaccing.width02(context),
            Expanded(
              child: Container(
                height: screenHeight * 0.025,
                alignment: Alignment.centerLeft,
                child: Text(
                  '$distance from $retailerName',
                  style: AppTextStyles.textSize14(context, weight: FontWeight.w400, color: AppColors.button(context)),
                  softWrap: true,
                  overflow: TextOverflow.visible,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _getFormattedDistance(String? distanceString) {
    if (distanceString == null || distanceString.isEmpty) return '0 km';

    // If the distance already contains 'km' or 'm', return as is
    if (distanceString.contains('km') || distanceString.contains('m')) {
      return distanceString;
    }

    // Try to parse as number (assuming meters)
    try {
      double distanceInMeters = double.parse(distanceString);
      if (distanceInMeters > 1000) {
        return '${(distanceInMeters / 1000).toStringAsFixed(1)} km';
      } else {
        return '${distanceInMeters.toInt()} m';
      }
    } catch (e) {
      return distanceString; // Return original if parsing fails
    }
  }

  Widget _buildOrderItems(BuildContext context, Order order) {
    List<Item> items = order.items ?? [];
    final screenHeight = MediaQuery.of(context).size.height;


    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Order Items (${items.length})', style: AppTextStyles.textSize18(context, weight: FontWeight.w500)),
            SizedBox(),
          ],
        ),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Method 1: Using ListView.separated approach manually
              ...List.generate(items.length, (index) {
                return Column(
                  children: [
                    _buildOrderItem(context, items[index]),
                    // Add divider only if it's not the last item
                    if (index < items.length - 1) ...[SizedboxSpaccing.height01(context), Divider(height: 1, color: AppColors.border(context)), SizedboxSpaccing.height01(context)],
                  ],
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOrderItem(BuildContext context, Item item) {
    String itemName = item.name ?? 'Unknown Item';
    String itemQuantity = '${item.quantity?.toStringAsFixed(item.quantity!.truncateToDouble() == item.quantity ? 0 : 1)} ${item.unit ?? ''}';
    String itemPrice = '${(item.totalPrice ?? 0).toStringAsFixed(2)}';

    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Text(itemName, style: AppTextStyles.textSize14(context, weight: FontWeight.w400)),
        ),
        Text(
          itemQuantity,
          style: AppTextStyles.textSize14(context, weight: FontWeight.w400),
          textAlign: TextAlign.center,
        ),
        // Expanded(
        //   flex: 1,
        //   child: Text(itemPrice, style: AppTextStyles.poppins14(context, weight: FontWeight.w500), textAlign: TextAlign.end),
        // ),
      ],
    );
  }

  Widget _buildCustomerNotes(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    String notes = "No customer notes available for this order.";

    return Container(
      padding: EdgeInsets.all(screenHeight * 0.02),
      decoration: BoxDecoration(
        color: AppColors.containerBackground(context),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.note, size: 20, color: AppColors.textPrimary(context)),
              SizedboxSpaccing.width02(context),
              Text('Customer Notes', style: AppTextStyles.textSize18(context, weight: FontWeight.w500)),
            ],
          ),
          SizedboxSpaccing.height01(context),
          Container(
            width: double.infinity,
            constraints: BoxConstraints(minHeight: 85),
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.textFieldFill(context),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(width: 1, color: AppColors.border(context)),
            ),
            child: Align(
              alignment: Alignment.topLeft,
              child: Text(
                notes,
                style: AppTextStyles.textSize14(context, weight: FontWeight.w400, color: AppColors.subtitle(context)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
