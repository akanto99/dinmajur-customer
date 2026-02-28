import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/components/header_appbar.dart';
import 'package:dinmajur_customer/configs/res/sizedbox_spaccing.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:dinmajur_customer/configs/utils/routes/routes_name.dart';
import 'package:dinmajur_customer/data/response/status.dart';
import 'package:dinmajur_customer/model/home_models/nearby_retailers_and_order_models/get_order_details_model.dart';
import 'package:dinmajur_customer/view/navigation_bar.dart';
import 'package:dinmajur_customer/view_model/homeview_model/nearby_retailers_and_order_view_models/order_now_view_models/order_confirmed_getorderdetails_view_model.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';

class OrderConfirmedScreen extends StatefulWidget {
  final String orderId;

  const OrderConfirmedScreen({Key? key, required this.orderId}) : super(key: key);

  @override
  State<OrderConfirmedScreen> createState() => _OrderConfirmedScreenState();
}

class _OrderConfirmedScreenState extends State<OrderConfirmedScreen> {
  @override
  void initState() {
    super.initState();
    print('Order ID: ${widget.orderId}');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final getOrderDetailsModel = Provider.of<GetOrderDetailsViewModel>(context, listen: false);
      getOrderDetailsModel.fetchOrderDetailsData(widget.orderId);
    });
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
              child: Container(height: 60, child: AppBarHeader("Order Details")),
            ),
            Expanded(
              child: Consumer<GetOrderDetailsViewModel>(
                builder: (context, viewModel, child) {
                  switch (viewModel.orderDetailsData.status) {
                    case Status.LOADING:
                      return Center(child: LoadingAnimationWidget.progressiveDots(color: AppColors.button(context), size: 45));
                    case Status.ERROR:
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error_outline, size: 64, color: Colors.red),
                            SizedboxSpaccing.height02(context),
                            Text('Failed to load order details', style: AppTextStyles.textSize18(context, weight: FontWeight.w500)),
                            SizedboxSpaccing.height02(context),
                            ElevatedButton(
                              onPressed: () {
                                viewModel.fetchOrderDetailsData(widget.orderId);
                              },
                              child: Text('Retry'),
                            ),
                          ],
                        ),
                      );
                    case Status.COMPLETED:
                      final data = viewModel.orderDetailsData.data?.data;
                      if (data == null) {
                        return Center(child: Text('No data available'));
                      }
                      return _buildOrderDetailsContent(data);
                    default:
                      return Center(child: Text('Something went wrong'));
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderDetailsContent(Data data) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.all(screenHeight * 0.02),
        child: Column(
          children: [
            _buildOrderProgress(context),
            SizedboxSpaccing.height02(context),
            _buildConfirmationCard(context),
            SizedboxSpaccing.height02(context),
            _buildCustomerInfo(context, data),
            SizedboxSpaccing.height02(context),
            _buildOrderItems(context, data),
            SizedboxSpaccing.height02(context),
            if (data.order?.customerNote != null && data.order!.customerNote!.isNotEmpty) _buildCustomerNotes(context, data.order!.customerNote!),
            if (data.order?.customerNote != null && data.order!.customerNote!.isNotEmpty) SizedboxSpaccing.height02(context),
            _buildPaymentMethodSection(context, data),
            SizedboxSpaccing.height02(context),
            _buildActionButtons(context, screenWidth, data),
            SizedboxSpaccing.height02(context),
          ],
        ),
      ),
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
            "Your order has been placed successfully.",
            style: AppTextStyles.textSize16(context, weight: FontWeight.w500),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildOrderProgress(BuildContext context) {
    List<String> steps = ['Dinmajur', 'Pickup', 'Delivery', 'Complete'];
    List<IconData> stepIcons = [FontAwesomeIcons.user, FontAwesomeIcons.box, FontAwesomeIcons.truck, FontAwesomeIcons.check];
    final screenWidth = MediaQuery.of(context).size.width;

    return Column(
      children: [
        Container(
          width: screenWidth * 0.8,
          child: Row(
            children: List.generate(steps.length * 2 - 1, (index) {
              if (index.isEven) {
                int stepIndex = index ~/ 2;

                return Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.containerBackground(context),
                    border: Border.all(width: 1, color: AppColors.border(context)),
                  ),
                  child: Icon(stepIcons[stepIndex], color: Colors.grey, size: 16),
                );
              } else {
                return Expanded(child: Container(height: 2, color: AppColors.border(context)));
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
              return Expanded(
                child: Container(
                  height: 30,
                  child: Center(
                    child: Text(
                      steps[index],
                      style: AppTextStyles.textSize12(context, weight: FontWeight.w400, color: AppColors.subtitle(context)),
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

  Widget _buildCustomerInfo(BuildContext context, Data data) {
    final screenHeight = MediaQuery.of(context).size.height;
    final order = data.order;
    final retailer = data.retailer;
    final delivery = data.delivery;

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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: retailer?.logo?.url != null ? Colors.transparent : AppColors.appBackground(context),
                        borderRadius: BorderRadius.circular(8),
                        image: retailer?.logo?.url != null ? DecorationImage(image: NetworkImage(retailer!.logo!.url!), fit: BoxFit.cover) : null,
                      ),
                      child: retailer?.logo?.url == null ? Icon(Icons.storefront_outlined, color: AppColors.textPrimary(context), size: 24) : null,
                    ),
                    SizedboxSpaccing.width03(context),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            retailer?.businessName ?? 'Store Name',
                            style: AppTextStyles.textSize18(context, weight: FontWeight.w500, color: AppColors.button(context)),
                          ),
                          Text(
                            'Category: ${retailer?.businessType ?? "General Store"}',
                            style: AppTextStyles.textSize14(context, weight: FontWeight.w400, color: AppColors.subtitle(context)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Container(
              //   height: 24,
              //   width: 80,
              //   decoration: BoxDecoration(color: _getStatusColor(order?.status ?? 'PENDING'), borderRadius: BorderRadius.circular(100)),
              //   child: Center(
              //     child: Text(
              //       _getDisplayStatus(order?.status ?? 'PENDING'),
              //       style: AppTextStyles.textSize12(context, weight: FontWeight.w500, color: Colors.white),
              //     ),
              //   ),
              // ),
              Container(
                width: 94,
                height: 24,
                decoration: BoxDecoration(color: AppColors.textFieldFill(context), borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  width: 1,
                  color: AppColors.border(context)
                )),
                child: Center(child: Text('Order #${order?.id?.substring(order.id!.length - 3) ?? 'N/A'}', style: AppTextStyles.textSize12(context, weight: FontWeight.w400))),
              ),
            ],
          ),
          SizedboxSpaccing.height01(context),
          Divider(height: 1, color: AppColors.border(context)),
          SizedboxSpaccing.height01(context),
          Text('Budget: ৳${order?.budget?.toString() ?? '0'}', style: AppTextStyles.textSize14(context, weight: FontWeight.w500)),
          SizedboxSpaccing.height01(context),
          _buildOrderDateTime(context, order?.createdAt, order?.estimatedDeliveryTime ?? 'ASAP'),
          SizedboxSpaccing.height01(context),
          Divider(height: 1, color: AppColors.border(context)),
          SizedboxSpaccing.height01(context),
          _buildDeliveryAddress(context, delivery?.destinationFullAddress ?? 'No address provided', delivery?.distance ?? '0 km', retailer?.businessName ?? 'Store'),
        ],
      ),
    );
  }

  Widget _buildOrderDateTime(BuildContext context, DateTime? createdAt, String deliveryTime) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Convert to BD local time (UTC+6)
    DateTime? bdTime = createdAt?.add(Duration(hours: 6));

    String formattedDate = bdTime != null ? DateFormat('dd/MM/yyyy').format(bdTime) : DateTime.now().toString().split(' ')[0];

    // Format time in 12-hour format with AM/PM
    String formattedTime = bdTime != null ? DateFormat('hh:mm a').format(bdTime) : 'N/A';

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
              Text('By: $formattedTime', style: AppTextStyles.textSize14(context, weight: FontWeight.w400)),
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
            Text(formattedDate, style: AppTextStyles.textSize14(context, weight: FontWeight.w400)),
          ],
        ),
      ],
    );
  }
  Widget _buildDeliveryAddress(BuildContext context, String deliveryAddress, String distance, String retailerName) {
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
                  SizedboxSpaccing.height005(context),
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
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOrderItems(BuildContext context, Data data) {
    final screenHeight = MediaQuery.of(context).size.height;
    final items = data.order?.items ?? [];

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Total Order Items (${items.length})', style: AppTextStyles.textSize18(context, weight: FontWeight.w500)),
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
              if (items.isEmpty)
                Center(
                  child: Text('No items in this order', style: AppTextStyles.textSize14(context, color: AppColors.subtitle(context))),
                )
              else
                ...List.generate(items.length, (index) {
                  return Column(
                    children: [
                      _buildOrderItem(context, items[index]),
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
    double quantity = item.quantity ?? 0.0;
    String unit = item.unit ?? '';
    String itemQuantity = '${quantity.toStringAsFixed(quantity.truncateToDouble() == quantity ? 0 : 1)} $unit';

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
      ],
    );
  }

  Widget _buildCustomerNotes(BuildContext context, String notes) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      decoration: BoxDecoration(color: AppColors.containerBackground(context), borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border(context))),
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
          Divider(height: 1, color: AppColors.border(context)),
          Padding(
            padding: EdgeInsets.all(screenHeight * 0.02),
            child: Container(
              padding: EdgeInsets.all(screenHeight * 0.02),
              decoration: BoxDecoration(color: AppColors.textFieldFill(context), borderRadius: BorderRadius.circular(8), border: Border.all(width: 1, color: AppColors.border(context))),
              child: Align(alignment: Alignment.topLeft, child: Text(notes, style: AppTextStyles.textSize14(context, weight: FontWeight.w400, color: AppColors.textPrimary(context)))),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodSection(BuildContext context, Data data) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    // Get payment method provider from model
    String? paymentProvider = data.paymentMethod?.provider?.toLowerCase() ?? 'cash_on_delivery';

    // Map payment providers to display data
    final Map<String, Map<String, dynamic>> paymentMethodsMap = {
      'bkash': {'title': 'bKash', 'icon': FontAwesomeIcons.wallet, 'color': Color(0xFFE2136E)},
      'nagad': {'title': 'Nagad', 'icon': FontAwesomeIcons.wallet, 'color': Color(0xFFEE4237)},
      'cash_on_delivery': {'title': 'Hand Cash', 'icon': FontAwesomeIcons.sackDollar, 'color': Color(0xFF45A986)},
    };

    // Get the selected payment method details
    final selectedMethod = paymentMethodsMap[paymentProvider] ?? paymentMethodsMap['cash_on_delivery']!;

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
            child: Text('Payment Method', style: AppTextStyles.textSize18(context, weight: FontWeight.w500)),
          ),
          Container(
            padding: EdgeInsets.all(screenHeight * 0.02),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.border(context), width: 1)),
            ),
            child: Container(
              padding: EdgeInsets.all(screenHeight * 0.015),
              decoration: BoxDecoration(
                  color: AppColors.textFieldFill(context),
                  borderRadius: BorderRadius.circular(8)
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
                            color: selectedMethod['color'],
                            borderRadius: BorderRadius.circular(6)
                        ),
                        child: Icon(selectedMethod['icon'], size: 12, color: AppColors.whiteColor),
                      ),
                      SizedboxSpaccing.width03(context),
                      Text(
                          selectedMethod['title'],
                          style: AppTextStyles.textSize16(context, weight: FontWeight.w400)
                      ),
                    ],
                  ),
                  _buildSelectionIndicator(true),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectionIndicator(bool isSelected) {
    return Container(
      height: 20,
      width: 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: isSelected ? AppColors.button(context) : AppColors.border(context), width: 2),
        color: AppColors.whiteColor,
      ),
      child: Center(
        child: Container(
          height: 12,
          width: 12,
          decoration: BoxDecoration(shape: BoxShape.circle, color: isSelected ? AppColors.button(context) : AppColors.border(context)),
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, double screenWidth, Data data) {
    final order = data.order;
    return Column(
      children: [
        GestureDetector(
          onTap: (){
            Navigator.pushNamed(
              context,
              RoutesName.trackOrderViewdetailsSocketScreen,
              arguments: {
                'orderId': order?.id,
              },
            );
          },
          child: Container(
            height: 50,
            width: screenWidth * 0.75,
            decoration: BoxDecoration(color: AppColors.button(context), borderRadius: BorderRadius.circular(16)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Icon(Icons.arrow_forward_ios_rounded, color: Colors.transparent, size: 14),
                Text(
                  "Track Order",
                  style: AppTextStyles.textSize16(context, color: AppColors.whiteColor, weight: FontWeight.w600),
                ),
                Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 14),
              ],
            ),
          ),
        ),
        SizedboxSpaccing.height02(context),
        GestureDetector(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => NavigationScreen(initialIndex: 0))),
          child: Container(
            height: 50,
            width: screenWidth * 0.75,
            color: Colors.transparent,
            child: Center(
              child: Text("Back to Home", style: AppTextStyles.textSize16(context, weight: FontWeight.w600)),
            ),
          ),
        ),
      ],
    );
  }
}
