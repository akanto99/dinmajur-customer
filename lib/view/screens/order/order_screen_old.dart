// import 'package:dinmajur_customer/configs/res/color.dart';
// import 'package:dinmajur_customer/configs/res/components/header_appbar.dart';
// import 'package:dinmajur_customer/configs/res/sizedbox_spaccing.dart';
// import 'package:dinmajur_customer/configs/res/text_styles.dart';
// import 'package:dinmajur_customer/configs/responsive/responsive_ui.dart';
// import 'package:dinmajur_customer/configs/utils/routes/routes_name.dart';
// import 'package:dinmajur_customer/view/navigation_bar.dart';
// import 'package:dinmajur_customer/view/screens/home/order_now_screens/order_confirmed_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
//
// class OrderScreen extends StatefulWidget {
//   const OrderScreen({super.key});
//
//   @override
//   State<OrderScreen> createState() => _OrderScreenState();
// }
//
// class _OrderScreenState extends State<OrderScreen> {
//   int _selectedTabIndex = 0;
//   List<Map<String, dynamic>> activeOrders = [
//     {
//       "orderID": "jus938734433",
//       "orderNo": "#FBZ-2305",
//       "storeName": "Fresh Bazaar",
//       "date": "June 28, 2023",
//       "itemCount": 3,
//       "totalAmount": "\$45.98",
//       "status": "Available",
//       "orderStatus":"order_placed",
//       "processingStatus": "Processing",
//       "attachmentName": "Grocery List 1",
//       "attachmentSize": "3 items • 2.3 MB • JPG",
//       "paymentMethod":"cash",
//       "ordersItem": [
//         {"productname": "Tomato", "weight": "2 kg", "price": 120},
//         {"productname": "Rice", "weight": "6 kg", "price": 300},
//         {"productname": "Milk", "weight": "250 ml", "price": 50},
//       ],
//     },
//     {
//       "orderID": "jus938734434",
//       "orderNo": "#FBZ-2306",
//       "storeName": "Fresh Bazaar",
//       "date": "June 28, 2023",
//       "itemCount": 3,
//       "totalAmount": "\$72.40",
//       "status": "Available",
//       "orderStatus":"order_confirmed",
//       "processingStatus": "Processing",
//       "attachmentName": "Grocery List 2",
//       "attachmentSize": "3 items • 2.8 MB • JPG",
//       "paymentMethod":"bkash",
//       "ordersItem": [
//         {"productname": "Potato", "weight": "5 kg", "price": 200},
//         {"productname": "Chicken", "weight": "1.5 kg", "price": 450},
//         {"productname": "Onion", "weight": "2 kg", "price": 120},
//       ],
//     },
//     {
//       "orderID": "jus938734435",
//       "orderNo": "#FBZ-2307",
//       "storeName": "Fresh Bazaar",
//       "date": "June 28, 2023",
//       "itemCount": 3,
//       "totalAmount": "\$39.90",
//       "status": "Available",
//       "orderStatus":"order_processing",
//       "processingStatus": "Processing",
//       "attachmentName": "Grocery List 3",
//       "attachmentSize": "3 items • 2.1 MB • JPG",
//       "paymentMethod":"bkash",
//       "ordersItem": [
//         {"productname": "Apple", "weight": "1.5 kg", "price": 300},
//         {"productname": "Eggs", "weight": "12 pcs", "price": 180},
//         {"productname": "Bread", "weight": "400 g", "price": 90},
//       ],
//     },
//   ];
//
//   List<Map<String, dynamic>> completedOrders = [
//     {
//       "orderID": "jus938734436",
//       "orderNo": "#FBZ-2204",
//       "storeName": "Fresh Bazaar",
//       "date": "June 15, 2023",
//       "itemCount": 5,
//       "totalAmount": "\$67.50",
//       "status": "Delivered",
//       "orderStatus":"completed",
//       "processingStatus": "Processing",
//       "attachmentName": "Grocery List 2",
//       "attachmentSize": "5 items • 3.1 MB • JPG",
//       "paymentMethod":"bkash",
//       "ordersItem": [
//         {"productname": "Fish", "weight": "2 kg", "price": 600},
//         {"productname": "Cucumber", "weight": "1 kg", "price": 80},
//         {"productname": "Carrot", "weight": "1 kg", "price": 100},
//         {"productname": "Sugar", "weight": "2 kg", "price": 220},
//         {"productname": "Oil", "weight": "1 liter", "price": 250},
//       ],
//     },
//   ];
//
//   List<Map<String, dynamic>> cancelledOrders = [
//     {
//       "orderID": "jus938734437",
//       "orderNo": "#FBZ-2103",
//       "storeName": "Fresh Bazaar",
//       "date": "June 10, 2023",
//       "itemCount": 2,
//       "totalAmount": "\$30.00",
//       "status": "Cancelled",
//       "orderStatus":"cancelled",
//       "processingStatus": "Processing",
//       "attachmentName": "Grocery List 3",
//       "attachmentSize": "2 items • 1.5 MB • JPG",
//       "paymentMethod":"bkash",
//       "ordersItem": [],
//     },
//   ];
//
//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Scaffold(
//         backgroundColor: AppColors.appBackground(context),
//         body: ResPonsiveUi(mobile: body(), desktop: body(), tablet: body()),
//       ),
//     );
//   }
//
//   Widget body() {
//     final screenWidth = MediaQuery.of(context).size.width;
//     final screenHeight = MediaQuery.of(context).size.height;
//
//     return Column(
//       children: [
//         // Header AppBar
//         Container(
//           height: 60,
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.only(bottomLeft: Radius.circular(24), bottomRight: Radius.circular(24)),
//             color: AppColors.containerBackground(context),
//             border: Border(bottom: BorderSide(color: AppColors.border(context), width: 1.0)),
//           ),
//           child: Center(
//             child: Container(
//               width: screenWidth * 0.9,
//               child: Row(
//                 children: [
//                   GestureDetector(
//                       onTap: () {
//                         Navigator.push(context, MaterialPageRoute(builder: (context)=>NavigationScreen(initialIndex: 0)));
//                       },child: Container(height: 20, width: 24, alignment: Alignment.centerLeft,
//                      color: Colors.transparent,
//                       child: SvgPicture.asset("assets/images/header_arrow.svg"))),
//                   SizedboxSpaccing.width03(context),
//                   Text(
//                     "My Orders",
//                     style: AppTextStyles.textSize24(context, weight: FontWeight.w600, color: AppColors.textPrimary(context)),
//                   ),
//                   Spacer(),
//                   Icon(Icons.mail_outline, color: AppColors.textPrimary(context), size: 24),
//                   SizedboxSpaccing.width02(context),
//                   Icon(Icons.notifications_outlined, color: AppColors.textPrimary(context), size: 24),
//                 ],
//               ),
//             ),
//           ),
//         ),
//         SizedboxSpaccing.height025(context),
//
//         /// Tabs
//         Container(
//           width: screenWidth,
//           height: 50,
//           color: AppColors.containerBackground(context),
//           child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [_buildTab("Active", 0), _buildTab("Completed", 1), _buildTab("Cancelled", 2)]),
//         ),
//         SizedboxSpaccing.height015(context),
//
//         // Content
//         Expanded(
//           child: Container(width: screenWidth * 0.9, child: _getSelectedWidget()),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildTab(String title, int index) {
//     final screenHeight = MediaQuery.of(context).size.height;
//     final screenWidth = MediaQuery.of(context).size.width;
//     final isSelected = _selectedTabIndex == index;
//
//     return GestureDetector(
//       onTap: () {
//         setState(() {
//           _selectedTabIndex = index;
//         });
//       },
//       child: Container(
//         width: screenWidth * 0.32,
//         decoration: BoxDecoration(
//           color: Colors.transparent,
//           border: Border(bottom: BorderSide(color: AppColors.border(context), width: 1.0)),
//         ),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             SizedBox(height: 2),
//             Text(
//               title,
//               style: AppTextStyles.textSize16(context, color: isSelected ? AppColors.button(context) : AppColors.form_hover(context), weight: FontWeight.w500),
//             ),
//             Container(width: screenWidth * 0.32, height: 2, color: isSelected ? AppColors.button(context) : AppColors.containerBackground(context)),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _getSelectedWidget() {
//     switch (_selectedTabIndex) {
//       case 0:
//         return WidgetActiveOrder();
//       case 1:
//         return WidgetCompletedOrder();
//       case 2:
//         return WidgetCancelledOrder();
//       default:
//         return Container();
//     }
//   }
//
//   Widget WidgetActiveOrder() {
//     final screenHeight = MediaQuery.of(context).size.height;
//     final screenWidth = MediaQuery.of(context).size.width;
//
//     return ListView.builder(
//       itemCount: activeOrders.length,
//       itemBuilder: (context, index) {
//         final order = activeOrders[index];
//         return _buildOrderCard(order, screenWidth, screenHeight);
//       },
//     );
//   }
//
//   Widget WidgetCompletedOrder() {
//     final screenHeight = MediaQuery.of(context).size.height;
//     final screenWidth = MediaQuery.of(context).size.width;
//
//     return ListView.builder(
//       itemCount: completedOrders.length,
//       itemBuilder: (context, index) {
//         final order = completedOrders[index];
//         return _buildOrderCard(order, screenWidth, screenHeight);
//       },
//     );
//   }
//
//   Widget WidgetCancelledOrder() {
//     final screenHeight = MediaQuery.of(context).size.height;
//     final screenWidth = MediaQuery.of(context).size.width;
//
//     return ListView.builder(
//       // padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       itemCount: cancelledOrders.length,
//       itemBuilder: (context, index) {
//         final order = cancelledOrders[index];
//         return _buildOrderCard(order, screenWidth, screenHeight);
//       },
//     );
//   }
//
//   Widget _buildOrderCard(Map<String, dynamic> order, double screenWidth, double screenHeight) {
//     return Container(
//       margin: EdgeInsets.only(bottom: screenHeight * 0.02),
//       decoration: BoxDecoration(color: AppColors.containerBackground(context), borderRadius: BorderRadius.circular(8)),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           /// Store Header
//           Container(
//             padding: EdgeInsets.all(screenHeight * 0.02),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   children: [
//                     Icon(Icons.shopping_cart, color: AppColors.button(context), size: 16),
//                     SizedboxSpaccing.width02(context),
//                     Text(order["storeName"], style: AppTextStyles.textSize14(context, weight: FontWeight.w500)),
//                     Spacer(),
//                     // Status Badge
//                     Container(
//                       height: 20,
//                       width: 81,
//                       decoration: BoxDecoration(color: Color(0xFFDCFCE7), borderRadius: BorderRadius.circular(50)),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Icon(Icons.check, color: Color(0xFF4CAF50), size: 12),
//                           SizedBox(width: 5),
//                           Text(
//                             order["status"],
//                             style: TextStyle(color: Color(0xFF15803D), fontSize: 10, fontWeight: FontWeight.w400),
//                           ),
//                         ],
//                       ),
//                     ),
//                     SizedBox(width: 10),
//                     // Processing Badge
//                     Container(
//                       height: 20,
//                       width: 81,
//                       decoration: BoxDecoration(color: Color(0xFFDBEAFE), borderRadius: BorderRadius.circular(50)),
//                       child: Center(
//                         child: Text(
//                           order["processingStatus"],
//                           style: TextStyle(color: Color(0xFF1D4ED8), fontSize: 10, fontWeight: FontWeight.w500),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//                 SizedboxSpaccing.height01(context),
//
//                 // Order Number and Date
//                 Text("Order ${order["orderNo"]} • ${order["date"]}", style: AppTextStyles.textSize12(context, color: AppColors.subtitle(context))),
//               ],
//             ),
//           ),
//           Divider(height: 1, color: AppColors.border(context)),
//
//           /// Items and Price
//           Container(
//             padding: EdgeInsets.only(top: screenHeight * 0.015, left: screenHeight * 0.02, right: screenHeight * 0.02, bottom: screenHeight * 0.02),
//             child: Column(
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                       "Items (${order["itemCount"]})",
//                       style: AppTextStyles.textSize14(context, weight: FontWeight.w400, color: AppColors.subtitle(context)),
//                     ),
//                     Text(order["totalAmount"], style: AppTextStyles.textSize14(context, weight: FontWeight.w500)),
//                   ],
//                 ),
//                 SizedboxSpaccing.height015(context),
//                 Row(
//                   children: [
//                     Container(
//                       width: 40,
//                       height: 40,
//                       decoration: BoxDecoration(color: AppColors.appBackground(context), borderRadius: BorderRadius.circular(6)),
//                       child: Icon(Icons.format_list_bulleted_rounded, color: Colors.grey[600], size: 24),
//                     ),
//                     SizedboxSpaccing.width02(context),
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(order["attachmentName"], style: AppTextStyles.textSize14(context, weight: FontWeight.w500)),
//                           SizedBox(height: 2),
//                           Text(
//                             order["attachmentSize"],
//                             style: AppTextStyles.textSize12(context, color: AppColors.subtitle(context), weight: FontWeight.w400),
//                           ),
//                         ],
//                       ),
//                     ),
//
//                     GestureDetector(
//                         onTap: () {
//                           // Navigator.push(context, MaterialPageRoute(builder: (context)=>OrderConfirmedScreen()));
//                         },child: Icon(FontAwesomeIcons.solidEye, color: Colors.grey[600], size: 16)),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//
//           Divider(height: 1, color: AppColors.border(context)),
//           // Action Buttons
//           Container(
//             height: 45,
//             child: Row(
//               children: [
//                 Container(
//                   height: 45,
//                   width: screenWidth * 0.45,
//                   decoration: BoxDecoration(
//                     border: Border(right: BorderSide(width: 1, color: AppColors.border(context))),
//                   ),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Icon(Icons.chat_outlined, size: 16, color: AppColors.button(context)),
//                       SizedboxSpaccing.width02(context),
//                       Text(
//                         "Contact",
//                         style: TextStyle(color: AppColors.button(context), fontSize: 14, fontWeight: FontWeight.w500),
//                       ),
//                     ],
//                   ),
//                 ),
//
//                 // In task_screen.dart, replace the GestureDetector's onTap method around line 367:
//
//                 GestureDetector(
//                   onTap: () {
//                     Navigator.pushNamed(
//                         context,
//                         RoutesName.orderDetailsScreen,
//                         arguments: order  // Changed from {OrderData: order} to just order
//                     );
//                   },
//                   child: Container(
//                     height: 45,
//                     width: screenWidth * 0.45,
//                     color: Colors.transparent,
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Icon(Icons.arrow_forward_outlined, size: 16, color: AppColors.button(context)),
//                         SizedboxSpaccing.width02(context),
//                         Text(
//                           "Track Order",
//                           style: TextStyle(color: AppColors.button(context), fontSize: 14, fontWeight: FontWeight.w500),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
