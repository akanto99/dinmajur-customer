import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/components/header_appbar.dart';
import 'package:dinmajur_customer/configs/res/sizedbox_spaccing.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:dinmajur_customer/view/navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';


class OrderConfirmedScreen extends StatefulWidget {
  // final String orderId;
  final String? businessType;
  final String? retailerName;

  const OrderConfirmedScreen({
    Key? key,
    // required this.orderId,
    this.businessType,
    this.retailerName,
  }) : super(key: key);

  @override
  State<OrderConfirmedScreen> createState() => _OrderConfirmedScreenState();
}

class _OrderConfirmedScreenState extends State<OrderConfirmedScreen> {
  int _currentStep = 0;

  @override
  void initState() {
    super.initState();
    // No socket initialization needed anymore
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.containerBackground(context),
      body: SafeArea(
        child: Column(
          children: [
            GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context)=>NavigationScreen(initialIndex: 0,))),
              child: Container(
                height: 60,
                child: AppBarHeader("Order Details"),
              ),
            ),
            Expanded(child: _buildContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    // Direct content display - no loading states
    return _buildOrderDetailsContent();
  }

  Widget _buildOrderDetailsContent() {
    final screenHeight = MediaQuery.of(context).size.height*1;
    final screenWidth = MediaQuery.of(context).size.width*1;

    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.all(screenHeight * 0.02),
        child: Column(
          children: [
            _buildOrderProgress(context),
            SizedboxSpaccing.height02(context),
        Container(
         height: 132,
          padding: EdgeInsets.symmetric(horizontal:screenHeight * 0.02),
          decoration: BoxDecoration(
            color: AppColors.containerBackground(context),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(width: 1, color: AppColors.border(context)),
          ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Order Confirmed!",style: AppTextStyles.textSize24(context,weight: FontWeight.w600,color: AppColors.button(context)),),
            SizedboxSpaccing.height01(context),
            Text("Your order has been placed successfully.",style: AppTextStyles.textSize16(context,weight: FontWeight.w500,),textAlign: TextAlign.center,)
          ],
        ),
        ),

            SizedboxSpaccing.height02(context),
            _buildCustomerInfo(context),
            SizedboxSpaccing.height02(context),
            _buildOrderItems(context),
            SizedboxSpaccing.height02(context),
            _buildCustomerNotes(context),
            SizedboxSpaccing.height02(context),
            _buildPaymentMethodSection(context),
            SizedboxSpaccing.height02(context),
            Container(
              height: 50,
              width: screenWidth * 0.75,
              decoration: BoxDecoration(
                  color: AppColors.button(context), borderRadius: BorderRadius.circular(16)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Icon(Icons.arrow_forward_ios_rounded, color: Colors.transparent, size: 14),
                  Text("Track Order",
                      style: AppTextStyles.textSize16(context,
                          color: AppColors.whiteColor, weight: FontWeight.w600)),
                  Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 14),
                ],
              ),
            ),
            SizedboxSpaccing.height02(context),
            GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context)=>NavigationScreen(initialIndex: 0,))),
              child: Container(
                height: 50,
                width: screenWidth * 0.75,
                color: Colors.transparent,
                child: Center(
                  child: Text("Back to Home",
                      style: AppTextStyles.textSize16(context, weight: FontWeight.w600)),
                ),
              ),
            ),
            SizedboxSpaccing.height02(context),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderProgress(BuildContext context) {
    List<String> steps = ['Dinmajur', 'Pickup', 'Delivery', 'Complete'];
    List<IconData> stepIcons = [
      Icons.shopping_cart,
      Icons.local_shipping,
      Icons.delivery_dining,
      Icons.check
    ];
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
                    color: isActive
                        ? AppColors.button(context)
                        : AppColors.containerBackground(context),
                    border: Border.all(
                      width: 1,
                      color: isActive
                          ? AppColors.button(context)
                          : AppColors.border(context),
                    ),
                  ),
                  child: Icon(
                    stepIcons[stepIndex],
                    color: isActive ? Colors.white : Colors.grey,
                    size: 20,
                  ),
                );
              } else {
                int lineIndex = (index - 1) ~/ 2;
                return Expanded(
                  child: Container(
                    height: 2,
                    color: lineIndex < _currentStep
                        ? AppColors.button(context)
                        : AppColors.border(context),
                  ),
                );
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
                      style: AppTextStyles.textSize12(
                        context,
                        weight: isCurrent ? FontWeight.w600 : FontWeight.w400,
                        color: isActive
                            ? AppColors.textPrimary(context)
                            : AppColors.subtitle(context),
                      ),
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

  Widget _buildCustomerInfo(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    // Dummy data
    String status = 'PENDING';
    double totalAmount = 1250.50;
    String orderDate = '15/10/2025';
    String orderTime = '14:30';
    String deliveryAddress = '123 Main Street, Chittagong, Bangladesh';
    String distance = '2.5 km';

    return Container(
      padding: EdgeInsets.all(screenHeight * 0.02),
      decoration: BoxDecoration(
        color: AppColors.containerBackground(context),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(width: 1, color: Color(0xff45A986)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.appBackground(context),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.storefront_outlined,
                  color: AppColors.textPrimary(context),
                  size: 24,
                ),
              ),
              SizedboxSpaccing.width03(context),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.retailerName ?? 'Customer',
                      style: AppTextStyles.textSize18(
                        context,
                        weight: FontWeight.w500,
                        color: AppColors.button(context),
                      ),
                    ),
                    Text(
                      'Category: ${widget.businessType ?? "General Store"}',
                      style: AppTextStyles.textSize14(
                        context,
                        weight: FontWeight.w400,
                        color: AppColors.subtitle(context),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                height: 24,
                width: 80,
                decoration: BoxDecoration(
                  color: _getStatusColor(status),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Center(
                  child: Text(
                    _getDisplayStatus(status),
                    style: AppTextStyles.textSize12(
                      context,
                      weight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedboxSpaccing.height01(context),
          Text(
            'Total Amount: ${totalAmount.toStringAsFixed(2)}',
            style: AppTextStyles.textSize14(context, weight: FontWeight.w500),
          ),
          SizedboxSpaccing.height01(context),
          _buildOrderDateTime(context, orderDate, orderTime),
          SizedboxSpaccing.height01(context),
          Divider(height: 1, color: AppColors.border(context)),
          SizedboxSpaccing.height01(context),
          _buildDeliveryAddress(context, deliveryAddress, distance),
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
      case 'COMPLETE':
      case 'COMPLETED':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Widget _buildOrderDateTime(BuildContext context, String orderDate, String orderTime) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

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
                  decoration: BoxDecoration(
                    color: AppColors.button(context),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              SizedboxSpaccing.width02(context),
              Text(
                'By: $orderTime',
                style: AppTextStyles.textSize14(context, weight: FontWeight.w400),
              ),
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
                decoration: BoxDecoration(
                  color: AppColors.button(context),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            SizedboxSpaccing.width02(context),
            Text(
              orderDate,
              style: AppTextStyles.textSize14(context, weight: FontWeight.w400),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDeliveryAddress(BuildContext context, String deliveryAddress, String distance) {
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
              child: Icon(
                Icons.location_on,
                size: 16,
                color: AppColors.button(context),
              ),
            ),
            SizedboxSpaccing.width02(context),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Delivery Address',
                    style: AppTextStyles.textSize14(context, weight: FontWeight.w500),
                  ),
                  Text(
                    deliveryAddress,
                    style: AppTextStyles.textSize14(context, weight: FontWeight.w400),
                  ),
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
              child: Icon(
                Icons.directions_car_filled,
                size: 16,
                color: AppColors.button(context),
              ),
            ),
            SizedboxSpaccing.width02(context),
            Expanded(
              child: Container(
                height: screenHeight * 0.025,
                alignment: Alignment.centerLeft,
                child: Text(
                  '$distance from ${widget.retailerName ?? "Retailer"}',
                  style: AppTextStyles.textSize14(
                    context,
                    weight: FontWeight.w400,
                    color: AppColors.button(context),
                  ),
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

  Widget _buildOrderItems(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    // Dummy order items
    List<Map<String, dynamic>> dummyItems = [
      {'name': 'Rice (Chinigura)', 'quantity': 5.0, 'unit': 'kg', 'price': 450.00},
      {'name': 'Onion', 'quantity': 2.0, 'unit': 'kg', 'price': 120.00},
      {'name': 'Potatoes', 'quantity': 3.0, 'unit': 'kg', 'price': 90.00},
      {'name': 'Cooking Oil', 'quantity': 2.0, 'unit': 'ltr', 'price': 360.00},
      {'name': 'Sugar', 'quantity': 1.0, 'unit': 'kg', 'price': 75.00},
    ];

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Total Order Items  (${dummyItems.length})',
              style: AppTextStyles.textSize18(context, weight: FontWeight.w500),
            ),
            SizedBox()
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
              ...List.generate(dummyItems.length, (index) {
                return Column(
                  children: [
                    _buildOrderItem(context, dummyItems[index]),
                    if (index < dummyItems.length - 1) ...[
                      SizedboxSpaccing.height01(context),
                      Divider(height: 1, color: AppColors.border(context)),
                      SizedboxSpaccing.height01(context),
                    ],
                  ],
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOrderItem(BuildContext context, Map<String, dynamic> item) {
    String itemName = item['name'] ?? 'Unknown Item';
    double quantity = item['quantity'] ?? 0.0;
    String unit = item['unit'] ?? '';
    String itemQuantity = '${quantity.toStringAsFixed(quantity.truncateToDouble() == quantity ? 0 : 1)} $unit';

    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Text(
            itemName,
            style: AppTextStyles.textSize14(context, weight: FontWeight.w400),
          ),
        ),
        Text(
          itemQuantity,
          style: AppTextStyles.textSize14(context, weight: FontWeight.w400),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildCustomerNotes(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    String notes = "Please deliver before 6 PM. Call me when you arrive.";

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
              Icon(
                Icons.note,
                size: 20,
                color: AppColors.textPrimary(context),
              ),
              SizedboxSpaccing.width02(context),
              Text(
                'Customer Notes',
                style: AppTextStyles.textSize14(context, weight: FontWeight.w500),
              ),
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
                style: AppTextStyles.textSize14(
                  context,
                  weight: FontWeight.w400,
                  color: AppColors.subtitle(context),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildDinmajurCard(BuildContext context, Map<String, dynamic> dinmajur) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.containerBackground(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(width: 1, color: AppColors.border(context)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.button(context),
            child: Text(
              dinmajur['firstName'][0].toUpperCase(),
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          ),
          SizedboxSpaccing.width03(context),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${dinmajur['firstName']} ${dinmajur['lastName']}',
                  style: AppTextStyles.textSize14(context, weight: FontWeight.w500),
                ),
                Text(
                  dinmajur['phone'],
                  style: AppTextStyles.textSize12(
                    context,
                    color: AppColors.subtitle(context),
                  ),
                ),
                Text(
                  'Distance: ${dinmajur['distance']}',
                  style: AppTextStyles.textSize12(
                    context,
                    color: AppColors.button(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

// Add these state variables at the top of _OrderConfirmedScreenState class
  String? selectedPaymentMethod;
  Map<String, dynamic>? selectedMethodData;

// Payment methods data
  final List<Map<String, dynamic>> paymentMethods = [
    {
      'method': 'bkash',
      'title': 'bkash',
      'subtitle': 'Pay with Bkash',
      'icon': FontAwesomeIcons.wallet,
      'color': Color(0xFFE2136E),
    },
    {
      'method': 'cash',
      'title': 'hand cash',
      'subtitle': 'Cash on delivery',
      'icon': FontAwesomeIcons.sackDollar,
      'color': Color(0xFF45A986),
    },
  ];

// Replace the payment method section with this complete widget
  Widget _buildPaymentMethodSection(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      width: screenWidth * 0.9,
      decoration: BoxDecoration(
        color: AppColors.containerBackground(context),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(width: 1, color: AppColors.border(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(screenHeight * 0.02),
            child: Text(
              'Payment Method',
              style: AppTextStyles.textSize18(context, weight: FontWeight.w500),
            ),
          ),
          Container(
            padding: EdgeInsets.all(screenHeight * 0.02),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: AppColors.border(context), width: 1),
              ),
            ),
            child: Column(
              children: paymentMethods.asMap().entries.map((entry) {
                final index = entry.key;
                final methodData = entry.value;

                final method = methodData['method'];
                final title = methodData['title'];
                final icon = methodData['icon'];
                final iconColor = methodData['color'];
                final isSelected = selectedPaymentMethod == method;

                // ✅ Remove bottom padding for the last item
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: index == paymentMethods.length - 1
                        ? 0
                        : screenHeight * 0.01,
                  ),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedPaymentMethod = method;
                        selectedMethodData = methodData;
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.all(screenHeight * 0.015),
                      decoration: BoxDecoration(
                        color: AppColors.textFieldFill(context),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                height: 24,
                                width: 24,
                                decoration: BoxDecoration(
                                  color: iconColor,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Icon(
                                  icon,
                                  size: 12,
                                  color: AppColors.whiteColor,
                                ),
                              ),
                              SizedboxSpaccing.width03(context),
                              Text(
                                title,
                                style: AppTextStyles.textSize16(
                                  context,
                                  weight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                          _buildSelectionIndicator(isSelected),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }


// Selection indicator widget
  Widget _buildSelectionIndicator(bool isSelected) {
    return Container(
      height: 20,
      width: 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected
              ? AppColors.button(context)
              : AppColors.border(context),
          width: 2,
        ),
        color: AppColors.whiteColor ,
      ),
      child: Center(
        child: Container(
          height: 12,
          width: 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isSelected
                ? AppColors.button(context)
                : AppColors.border(context),
          ),
        ),
      )
    );
  }
}