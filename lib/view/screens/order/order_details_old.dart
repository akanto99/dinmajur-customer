import 'package:dinmajur_customer/configs/buttons/round_button.dart';
import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/sizedbox_spaccing.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:dinmajur_customer/configs/responsive/responsive_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class OrderDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> orderData;

  const OrderDetailsScreen({super.key, required this.orderData});

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  final TextEditingController _withdrawalController = TextEditingController();

  // Get status progress based on orderStatus
  List<Map<String, dynamic>> getOrderStatusSteps() {
    String orderStatus = widget.orderData["orderStatus"] ?? "order_placed";

    List<Map<String, dynamic>> steps = [
      {
        "icon": Icons.check_circle,
        "title": "Order Placed",
        "time": widget.orderData["date"] ?? "N/A",
        "isCompleted": true, // Always completed if order exists
      },
      {
        "icon": Icons.check_circle,
        "title": "Order Confirmed",
        "time": widget.orderData["date"] ?? "N/A",
        "isCompleted": orderStatus == "order_confirmed" ||
            orderStatus == "order_processing" ||
            orderStatus == "out_for_delivery" ||
            orderStatus == "completed",
      },
      {
        "icon": Icons.shopping_bag,
        "title": "Order Processing",
        "time": widget.orderData["date"] ?? "N/A",
        "isCompleted": orderStatus == "order_processing" ||
            orderStatus == "out_for_delivery" ||
            orderStatus == "completed",
      },
      {
        "icon": Icons.local_shipping,
        "title": "Out for Delivery",
        "time": "Estimated: Today",
        "isCompleted": orderStatus == "out_for_delivery" ||
            orderStatus == "completed",
      },
      {
        "icon": Icons.home,
        "title": "Delivered",
        "time": "Estimated: Today, 2:00 PM - 4:00 PM",
        "isCompleted": orderStatus == "completed",
      },
    ];

    return steps;
  }


  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.appBackground(context),
        body: ResPonsiveUi(mobile: body(), desktop: body(), tablet: body()),
      ),
    );
  }

  Widget body() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Column(
      children: [
        // Header AppBar
        Container(
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(24),
              bottomRight: Radius.circular(24),
            ),
            color: AppColors.containerBackground(context),
            border: Border(
              bottom: BorderSide(color: AppColors.border(context), width: 1.0),
            ),
          ),
          child: Center(
            child: Container(
              width: screenWidth * 0.9,
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child:                   Container(height: 20, width: 24, alignment: Alignment.centerLeft, child: SvgPicture.asset("assets/images/header_arrow.svg")),
                  ),
                  SizedboxSpaccing.width03(context),
                  Text("Track Order",
                      style: AppTextStyles.textSize20(context,
                          weight: FontWeight.w600,
                          color: AppColors.textPrimary(context))),
                  Spacer(),
                  Icon(Icons.mail_outline,
                      color: AppColors.textPrimary(context), size: 24),
                  SizedboxSpaccing.width02(context),
                  Icon(Icons.notifications_outlined,
                      color: AppColors.textPrimary(context), size: 24),
                ],
              ),
            ),
          ),
        ),
        SizedboxSpaccing.height02(context),

        // Scrollable Content
        Expanded(
          child: SingleChildScrollView(
            child: Container(
              width: screenWidth * 0.9,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Store Info Card
                  _buildStoreInfoCard(screenWidth, screenHeight),
                  SizedboxSpaccing.height02(context),

                  if (widget.orderData["orderStatus"] == "order_confirmed" ||
                      widget.orderData["orderStatus"] == "order_processing" ||
                      widget.orderData["orderStatus"] == "completed") ...[
                    _buildAcceptedRiderInfo(screenWidth, screenHeight),
                    SizedboxSpaccing.height02(context),
                  ],
                  // Order Status
                  _buildOrderStatus(screenWidth, screenHeight),
                  SizedboxSpaccing.height02(context),

                  // Order Items List
                  _buildOrderItemsList(screenWidth, screenHeight),
                  SizedboxSpaccing.height02(context),

                  // Delivery Address
                  _buildDeliveryAddress(screenWidth, screenHeight),
                  SizedboxSpaccing.height02(context),

                  // Payment Information
                  _buildPaymentInformation(screenWidth, screenHeight),
                  SizedboxSpaccing.height02(context),

                  // Action Buttons
                  _buildActionButtons(screenWidth, screenHeight),
                  SizedboxSpaccing.height02(context),

                  RoundButton(
                    title:  "Payment",
                    onPress: (){

                    },
                    iconData: Icons.arrow_forward_ios_rounded,
                    loading: false,
                  ),
                  SizedboxSpaccing.height02(context),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStoreInfoCard(double screenWidth, double screenHeight) {
    return Container(
      padding: EdgeInsets.all(screenHeight * 0.02),
      decoration: BoxDecoration(
        color: AppColors.containerBackground(context),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.shopping_cart,
                  color: AppColors.button(context), size: 20),
              SizedboxSpaccing.width02(context),
              Text(widget.orderData["storeName"],
                  style: AppTextStyles.textSize16(context,
                      weight: FontWeight.w600)),
              Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check, color: Color(0xFF4CAF50), size: 12),
                    SizedBox(width: 4),
                    Text(
                      widget.orderData["status"],
                      style: TextStyle(
                        color: Color(0xFF15803D),
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedboxSpaccing.height015(context),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Order ${widget.orderData["orderNo"]}",
                    style: AppTextStyles.textSize12(context,
                        color: AppColors.subtitle(context)),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Estimated Delivery",
                    style: AppTextStyles.textSize12(context,
                        color: AppColors.subtitle(context)),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    widget.orderData["date"],
                    style: AppTextStyles.textSize12(context,
                        weight: FontWeight.w500),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Today, 2:00 PM - 4:00 PM",
                    style: AppTextStyles.textSize12(context,
                        weight: FontWeight.w500),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAcceptedRiderInfo(double screenWidth, double screenHeight) {

    return Container(
      padding: EdgeInsets.all(screenHeight * 0.02),
      decoration: BoxDecoration(
        color: AppColors.containerBackground(context),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Rider Image
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.appBackground(context),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.button(context), width: 2),
            ),
            child: ClipOval(
              child: Icon(
                Icons.person,
                size: 32,
                color: AppColors.button(context),
              ),
            ),
          ),
          SizedboxSpaccing.width02(context),

          // Rider Name and Status
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Rider Assigned",
                  style: AppTextStyles.textSize12(context,
                      color: AppColors.subtitle(context)),
                ),
                SizedBox(height: 4),
                Text(
                  "John Doe",
                  style: AppTextStyles.textSize16(context,
                      weight: FontWeight.w600),
                ),
                SizedBox(height: 2),
                Row(
                  children: [
                    Icon(Icons.star, color: Colors.amber, size: 14),
                    SizedBox(width: 4),
                    Text(
                      "4.8",
                      style: AppTextStyles.textSize12(context,
                          weight: FontWeight.w500),
                    ),
                    SizedBox(width: 8),
                    Text(
                      "• 150+ deliveries",
                      style: AppTextStyles.textSize12(context,
                          color: AppColors.subtitle(context)),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Chat Button
          GestureDetector(
            onTap: () {
              // Handle chat action
              print("Chat with rider");
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.appBackground(context),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.button(context), width: 1),
              ),
              child: Icon(
                Icons.chat_bubble_outline,
                color: AppColors.button(context),
                size: 20,
              ),
            ),
          ),
          SizedboxSpaccing.width02(context),

          // Call Button
          GestureDetector(
            onTap: () {
              // Handle call action
              print("Call rider");
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.button(context),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.phone,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderStatus(double screenWidth, double screenHeight) {
    return Container(
      padding: EdgeInsets.all(screenHeight * 0.02),
      decoration: BoxDecoration(
        color: AppColors.containerBackground(context),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Order Status",
            style: AppTextStyles.textSize16(context, weight: FontWeight.w600),
          ),
          SizedboxSpaccing.height02(context),
          _buildStatusItem(
              Icons.check_circle, "Order Placed", "June 29, 2023 | 9:15 AM", true),
          _buildStatusItem(Icons.check_circle, "Order Confirmed",
              "June 29, 2023 | 9:30 AM", true),
          _buildStatusItem(Icons.shopping_bag, "Order Processing",
              "June 29, 2023 | 10:15 AM", false),
          _buildStatusItem(Icons.local_shipping, "Out for Delivery",
              "Estimated: Today, 1:00 PM", false),
          _buildStatusItem(Icons.home, "Delivered",
              "Estimated: Today, 2:00 PM - 4:00 PM", false, isLast: true),
        ],
      ),
    );
  }

  Widget _buildStatusItem(
      IconData icon, String title, String time, bool isCompleted,
      {bool isLast = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isCompleted
                    ? AppColors.button(context)
                    : AppColors.appBackground(context),
                shape: BoxShape.circle,
                border: Border.all(
                  color: isCompleted
                      ? AppColors.button(context)
                      : AppColors.border(context),
                  width: 2,
                ),
              ),
              child: Icon(
                icon,
                size: 16,
                color: isCompleted ? Colors.white : Colors.grey,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                color: isCompleted
                    ? AppColors.button(context)
                    : AppColors.border(context),
              ),
          ],
        ),
        SizedboxSpaccing.width02(context),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(top: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.textSize14(context,
                      weight: FontWeight.w500),
                ),
                SizedBox(height: 2),
                Text(
                  time,
                  style: AppTextStyles.textSize12(context,
                      color: AppColors.subtitle(context)),
                ),
                if (!isLast) SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOrderItemsList(double screenWidth, double screenHeight) {
    final ordersItem = widget.orderData["ordersItem"] as List<Map<String, dynamic>>;

    return Container(
      padding: EdgeInsets.all(screenHeight * 0.02),
      decoration: BoxDecoration(
        color: AppColors.containerBackground(context),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Order Items",
                style: AppTextStyles.textSize16(context, weight: FontWeight.w600),
              ),
              Text(
                "${ordersItem.length} items",
                style: AppTextStyles.textSize14(context,
                    color: AppColors.subtitle(context)),
              ),
            ],
          ),
          SizedboxSpaccing.height015(context),
          ...ordersItem.map((item) => _buildOrderItem(item, screenHeight)).toList(),
        ],
      ),
    );
  }

  Widget _buildOrderItem(Map<String, dynamic> item, double screenHeight) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: screenHeight * 0.01),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.appBackground(context),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.shopping_basket,
                color: Colors.grey[600], size: 24),
          ),
          SizedboxSpaccing.width02(context),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item["productname"],
                  style: AppTextStyles.textSize14(context,
                      weight: FontWeight.w500),
                ),
                SizedBox(height: 2),
                Text(
                  item["weight"],
                  style: AppTextStyles.textSize12(context,
                      color: AppColors.subtitle(context)),
                ),
              ],
            ),
          ),
          Text(
            "৳${item["price"]}",
            style: AppTextStyles.textSize14(context, weight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryAddress(double screenWidth, double screenHeight) {
    return Container(
      padding: EdgeInsets.all(screenHeight * 0.02),
      decoration: BoxDecoration(
        color: AppColors.containerBackground(context),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Delivery Address",
            style: AppTextStyles.textSize16(context, weight: FontWeight.w600),
          ),
          SizedboxSpaccing.height015(context),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.location_on,
                  color: AppColors.button(context), size: 20),
              SizedboxSpaccing.width02(context),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Home",
                      style: AppTextStyles.textSize14(context,
                          weight: FontWeight.w600),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "123 Main Street, Apt 4B\nNew York, NY 10001",
                      style: AppTextStyles.textSize12(context,
                          color: AppColors.subtitle(context)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentInformation(double screenWidth, double screenHeight) {
    final ordersItem = widget.orderData["ordersItem"] as List<Map<String, dynamic>>;
    double subtotal = ordersItem.fold(0, (sum, item) => sum + item["price"]);
    double deliveryFee = 50.0;
    double tax = subtotal * 0.05;
    double total = subtotal + deliveryFee + tax;

    // Get payment method from orderData
    String paymentMethod = widget.orderData["paymentMethod"] ?? "cash";

    return Container(
      padding: EdgeInsets.all(screenHeight * 0.02),
      decoration: BoxDecoration(
        color: AppColors.containerBackground(context),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Payment Information",
            style: AppTextStyles.textSize16(context, weight: FontWeight.w600),
          ),
          SizedboxSpaccing.height015(context),
          Row(
            children: [
            Container(
            height: 30,
            width: 30,
            decoration: BoxDecoration(
              color:  paymentMethod.toLowerCase() == "bkash"
                  ?Color(0xffDB2777) :AppColors.button(context),
              borderRadius: BorderRadius.circular(6),
            ),
                child: Icon(
                    paymentMethod.toLowerCase() == "bkash"
                        ? FontAwesomeIcons.wallet
                        : FontAwesomeIcons.sackDollar,
                    color: AppColors.whiteColor,
                    size: 15
                ),
              ),
              SizedboxSpaccing.width02(context),
              Text(
                paymentMethod.toLowerCase() == "bkash"
                    ? "bKash"
                    : "Hand Cash",
                style: AppTextStyles.textSize14(context,
                    weight: FontWeight.w500,color: paymentMethod.toLowerCase() == "bkash"
                      ?Color(0xffDB2777) :AppColors.button(context),),
              ),
            ],
          ),
          SizedboxSpaccing.height02(context),
          Divider(color: AppColors.border(context)),
          SizedboxSpaccing.height01(context),
          _buildPriceRow("Subtotal", "৳${subtotal.toStringAsFixed(2)}"),
          SizedboxSpaccing.height01(context),
          _buildPriceRow("Delivery Fee", "৳${deliveryFee.toStringAsFixed(2)}"),
          SizedboxSpaccing.height01(context),
          _buildPriceRow("Tax", "৳${tax.toStringAsFixed(2)}"),
          SizedboxSpaccing.height015(context),
          Divider(color: AppColors.border(context)),
          SizedboxSpaccing.height01(context),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Total",
                style: AppTextStyles.textSize16(context,
                    weight: FontWeight.w700),
              ),
              Text(
                "৳${total.toStringAsFixed(2)}",
                style: AppTextStyles.textSize16(context,
                    weight: FontWeight.w700),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.textSize14(context,
              color: AppColors.subtitle(context)),
        ),
        Text(
          value,
          style: AppTextStyles.textSize14(context, weight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildActionButtons(double screenWidth, double screenHeight) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.containerBackground(context),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.button(context)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.chat_outlined,
                    color: AppColors.button(context), size: 18),
                SizedboxSpaccing.width02(context),
                Text(
                  "Contact Seller",
                  style: TextStyle(
                    color: AppColors.button(context),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedboxSpaccing.width02(context),
        Expanded(
          child: Container(
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.button(context),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.receipt_long, color: Colors.white, size: 18),
                SizedboxSpaccing.width02(context),
                Text(
                  "View Receipt",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}