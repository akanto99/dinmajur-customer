import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/sizedbox_spaccing.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:flutter/material.dart';
import '../../../../../model/home_models/socket_home_model/socket_get_all_orders_model/socket_get_allorders_model.dart';

class SocketOrderCard extends StatelessWidget {
  final Datum order;
  final VoidCallback? onViewDetails;


  const SocketOrderCard({
    Key? key,
    required this.order,
    this.onViewDetails,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    String status = _getStatus();
    return Container(
      decoration: BoxDecoration(
        color: AppColors.containerBackground(context),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(width: 1, color: _getStatusColor(status),
        ),
      ),
      padding: EdgeInsets.all(screenHeight * 0.02),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          SizedboxSpaccing.height01(context),
          Divider(height: 1, color: AppColors.border(context)),
          SizedboxSpaccing.height01(context),
          _buildBudget(context),
          SizedboxSpaccing.height01(context),
          _buildOrderInfo(context),
          SizedboxSpaccing.height01(context),
          Divider(height: 1, color: AppColors.border(context)),
          SizedboxSpaccing.height01(context),
          _buildDeliveryAddress(context),
          SizedboxSpaccing.height015(context),
          _buildViewDetailsButton(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    String status = _getStatus();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
               Icons.storefront,
               color: AppColors.textPrimary(context),
               size: 20,
             ),
           ),
           SizedboxSpaccing.width03(context),
           Column(
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
               Text(  "Customer Name",
                 style: AppTextStyles.textSize18(context, weight: FontWeight.w500),
               ),
               Text(
                 // 'Category: $category',
                 'Category: ${order.retailer?.businessType ?? 'N/A'}',
                 style: AppTextStyles.textSize14(
                   context,
                   weight: FontWeight.w400,
                   color: AppColors.subtitle(context),
                 ),
               ),
             ],
           ),
         ],
       ),
        Align(
          alignment: Alignment.topCenter,
          child: Container(
            height: 24,
            width: 80,
            decoration: BoxDecoration(
              color: _getStatusColor(status),
              borderRadius: BorderRadius.circular(100),
            ),
            child: Center(
              child: Text(
                status,
                style: AppTextStyles.textSize12(
                  context,
                  weight: FontWeight.w400,
                  color: AppColors.whiteColor,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBudget(BuildContext context) {
    String budget = _getBudget();
    return Text(
      'Budget: $budget',
      style: AppTextStyles.textSize14(context, weight: FontWeight.w400),
    );
  }

  Widget _buildOrderInfo(BuildContext context) {
    Map<String, String> orderDateTime = _getOrderDateTime();
    String orderDate = orderDateTime['date']!;
    String orderTime = orderDateTime['time']!;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Row(
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
        const Spacer(),
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
    );
  }

  Widget _buildDeliveryAddress(BuildContext context) {
    String deliveryAddress = _getDeliveryAddress();
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
              height: screenHeight * 0.03,
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
              child: Text(
                '${_getDistanceBetweenCustomerAndRetailer()} from ${ order.retailer?.businessName}',
                style: AppTextStyles.textSize14(
                  context,
                  weight: FontWeight.w400,
                  color: AppColors.button(context),
                ),
                softWrap: true,
                overflow: TextOverflow.visible,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildViewDetailsButton(BuildContext context) {
    return GestureDetector(
      onTap: onViewDetails ?? () {
        print('View details for order: ${order.order?.id}');
      },
      child: Container(
        height: 48,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: AppColors.button(context),
        ),
        child: Center(
          child: Text(
            'View Details',
            style: AppTextStyles.textSize16(
              context,
              weight: FontWeight.w600,
              color: AppColors.whiteColor,
            ),
          ),
        ),
      ),
    );
  }

  String _getBudget() {
    try {
      int? amount = order.order?.budget;
      double? amountInDouble = amount?.toDouble();
      return '\$${amountInDouble?.toStringAsFixed(2)}';
    } catch (e) {
      return '\$0.00';
    }
  }

  String _getStatus() {
    String? status = order.delivery?.status?.toUpperCase();

    switch (status) {
      case 'PENDING':
        return 'Pending';
      case 'RUNNING':
        return 'Running';
        case 'ACTIVE':
        return 'Active';
      case 'COMPLETED':
        return 'Completed';
      case 'CANCELLED':
        return 'Cancelled';
      default:
        return 'Pending';
    }
  }

  Map<String, String> _getOrderDateTime() {
    try {
      DateTime? dateTime = order.order?.createdAt;

      String orderDate =
          '${dateTime?.day.toString().padLeft(2, '0')}/'
          '${dateTime?.month.toString().padLeft(2, '0')}/'
          '${dateTime?.year}';

      String orderTime =
          '${dateTime?.hour.toString().padLeft(2, '0')}:'
          '${dateTime?.minute.toString().padLeft(2, '0')}';

      return {'date': orderDate, 'time': orderTime};
    } catch (e) {
      print('Error parsing date: $e');
      return {'date': 'N/A', 'time': 'N/A'};
    }
  }

  String _getDeliveryAddress() {
    try {
      String? fullAddress = order.delivery?.destination?.fullAddress;

      if (fullAddress!.isNotEmpty) {
        return fullAddress;
      }

      // Fallback to coordinates if no full address
      List<double>? coords = order.delivery?.destination?.coordinates;
      if (coords!.length >= 2) {
        return 'Lat: ${coords[1].toStringAsFixed(4)}, Lng: ${coords[0].toStringAsFixed(4)}';
      }

      return 'Address not available';
    } catch (e) {
      print('Error getting delivery address: $e');
      return 'Address not available';
    }
  }

  String _getDistanceBetweenCustomerAndRetailer() {
    try {
      String? distance = order.delivery?.distance;

      // Parse the distance string (e.g., "5.2 km" or "500 m")
      if (distance!.contains('km')) {
        return distance;
      } else if (distance.contains('m')) {
        return distance;
      } else {
        // If it's just a number, assume it's in meters
        double distanceValue = double.tryParse(distance) ?? 0;
        if (distanceValue < 1000) {
          return '${distanceValue.toInt()} meters';
        } else {
          return '${(distanceValue / 1000).toStringAsFixed(1)} km';
        }
      }
    } catch (e) {
      print('Error parsing distance: $e');
      return 'Distance not available';
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.red.withOpacity(0.9);
      case 'running':
        return const Color(0xff00424D);
        case 'active':
        return const Color(0xff00424D);
      case 'completed':
        return Colors.green.withOpacity(0.9);
      case 'cancelled':
        return Colors.grey.withOpacity(0.9);
      default:
        return Colors.grey;
    }
  }
}