// import 'package:dinmajur_customer/configs/res/color.dart';
// import 'package:dinmajur_customer/configs/res/components/circle_network_image/circle_network_image.dart';
// import 'package:dinmajur_customer/configs/res/components/exception_errorstate/exception_errorstate.dart';
// import 'package:dinmajur_customer/configs/res/components/header_appbar.dart';
// import 'package:dinmajur_customer/configs/res/sizedbox_spaccing.dart';
// import 'package:dinmajur_customer/configs/res/text_styles.dart';
// import 'package:dinmajur_customer/configs/responsive/responsive_ui.dart';
// import 'package:dinmajur_customer/configs/services/ssl_payment_service/ssl_payment.dart';
// import 'package:dinmajur_customer/configs/utils/routes/routes_name.dart';
// import 'package:dinmajur_customer/configs/utils/utils.dart';
// import 'package:dinmajur_customer/configs/widgets/datetime_formatter.dart';
// import 'package:dinmajur_customer/data/response/status.dart';
// import 'package:dinmajur_customer/model/order_models/get_all_order_model.dart';
// import 'package:dinmajur_customer/view/navigation_bar.dart';
// import 'package:dinmajur_customer/view_model/order_view_models/running_orders_view_model.dart';
// import 'package:flutter/material.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:loading_animation_widget/loading_animation_widget.dart';
// import 'package:provider/provider.dart';
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
//   bool _isInitialized = false;
//
//   @override
//   void initState() {
//     super.initState();
//     final viewModel = Provider.of<RunningOrdersViewModel>(context, listen: false);
//     viewModel.clearAllDataSilent();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _initializeData();
//     });
//   }
//
//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     if (!_isInitialized) {
//       _isInitialized = true;
//     }
//   }
//
//   @override
//   void dispose() {
//     super.dispose();
//   }
//
//   void _initializeData() {
//     final viewModel = Provider.of<RunningOrdersViewModel>(context, listen: false);
//     if (_selectedTabIndex == 0) {
//       viewModel.fetchPendingOrdersGetDataApi();
//     } else if (_selectedTabIndex == 1) {
//       viewModel.fetchRunningOrdersGetDataApi();
//     } else if (_selectedTabIndex == 2) {
//       viewModel.fetchCompleteOrdersGetDataApi();
//     }
//   }
//
//   Future<void> _handleRefresh() async {
//     try {
//       final viewModel = Provider.of<RunningOrdersViewModel>(context, listen: false);
//       if (_selectedTabIndex == 0) {
//         await viewModel.fetchPendingOrdersGetDataApi(isRefresh: true);
//       } else if (_selectedTabIndex == 1) {
//         await viewModel.fetchRunningOrdersGetDataApi(isRefresh: true);
//       } else if (_selectedTabIndex == 2) {
//         await viewModel.fetchCompleteOrdersGetDataApi(isRefresh: true);
//       }
//     } catch (e) {
//       if (mounted) {
//         Utils.flushBarErrorMessage("Refresh failed", context);
//       }
//     }
//   }
//
//   // ─── SSL Commerz Pay Now ────────────────────────────────────────────────────
//   Future<void> _handlePayNow(BuildContext context, Datum datum) async {
//     String trackingId = '';
//     String productCategory = '';
//
//     if (datum.type == 'ORDER') {
//       trackingId = datum.orderId ?? '';
//       productCategory = 'Grocery Order';
//     } else if (datum.type == 'HOUSEKEEPER') {
//       trackingId = datum.houseKeeperBookingId ?? '';
//       productCategory = 'House Keeper';
//     } else if (datum.type == 'BEAUTY_SALON') {
//       trackingId = datum.beautySalonBookingId ?? '';
//       productCategory = 'Beauty Salon';
//     } else if (datum.type == 'EVENT_COOKING') {
//       trackingId = datum.eventCookingBookingId ?? '';
//       productCategory = 'Event Cooking';
//     }
//
//     if (trackingId.isEmpty) {
//       Utils.flushBarErrorMessage("Invalid order ID", context);
//       return;
//     }
//
//     final double totalAmount = (datum.total ?? 0).toDouble();
//     final customer = datum.customer;
//
//     try {
//       final result = await SSLCommerzPaymentService().initiatePayment(
//         trackingId: trackingId,
//         totalAmount: totalAmount,
//         productCategory: productCategory,
//         customerName: customer?.fullName,
//         customerPhone: customer?.phone,
//         customerEmail: '',
//         customerAddress:datum.fullAddress ?? '',
//       );
//       if (result.success) {
//         Utils.flushBarSuccessMessage("Payment successful!", context);
//       } else if (result.status == 'CANCELLED') {
//         Utils.flushBarErrorMessage("Payment cancelled", context);
//       } else {
//         Utils.flushBarErrorMessage(result.errorMessage ?? "Payment failed", context);
//       }
//     } catch (e) {
//       if (mounted) Navigator.of(context).pop();
//       Utils.flushBarErrorMessage("Payment error: $e", context);
//     }
//   }
//
//   // ─── Write Review Bottom Sheet ──────────────────────────────────────────────
//   void _showWriteReviewSheet(BuildContext context, Datum datum) {
//     int _selectedRating = 0;
//     final TextEditingController _feedbackController = TextEditingController();
//     int _charCount = 0;
//     final String? imageUrl = datum.freelancer?.profilePicture?.url;
//     final String freelancerName =
//     '${datum.freelancer?.firstName ?? ''} ${datum.freelancer?.lastName ?? ''}'.trim();
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (ctx) {
//         return StatefulBuilder(
//           builder: (context, setModalState) {
//             return Container(
//               margin: const EdgeInsets.only(top: 80),
//               decoration: BoxDecoration(
//                 color: AppColors.containerBackground(context),
//                 borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
//               ),
//               padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 24, left: 24, right: 24, top: 16),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   // Handle bar
//                   Container(
//                     width: 40,
//                     height: 6,
//                     decoration: BoxDecoration(color: AppColors.border(context), borderRadius: BorderRadius.circular(2)),
//                   ),
//                   const SizedBox(height: 20),
//
//                   // Title
//                   Text("Write a Review", style: AppTextStyles.textSize20(context, weight: FontWeight.w700)),
//                   const SizedBox(height: 6),
//                   Text(
//                     "Please rate your experience with the freelancer.",
//                     style: AppTextStyles.textSize14(context, color: AppColors.subtitle(context)),
//                     textAlign: TextAlign.center,
//                   ),
//                   const SizedBox(height: 24),
//
//                   // Freelancer Avatar
//                   CircleAvatarNetwork(
//                     imageUrl: imageUrl,
//                     name: freelancerName,
//                     size: 72,
//                     borderWidth: 1.5,
//                     borderColor: AppColors.border(context),
//                   ),
//                   const SizedBox(height: 12),
//
//                   Text(freelancerName, style: AppTextStyles.textSize18(context, weight: FontWeight.w600)),
//                   const SizedBox(height: 4),
//                   Text("How was their work?", style: AppTextStyles.textSize14(context, color: AppColors.subtitle(context))),
//                   const SizedBox(height: 16),
//
//                   // Star Rating
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: List.generate(5, (index) {
//                       return GestureDetector(
//                         onTap: () {
//                           setModalState(() {
//                             _selectedRating = index + 1;
//                           });
//                         },
//                         child: Padding(
//                           padding: const EdgeInsets.symmetric(horizontal: 6),
//                           child: Icon(
//                             _selectedRating > index ? FontAwesomeIcons.solidStar : FontAwesomeIcons.star,
//                             color: _selectedRating > index ? const Color(0xFFFACC15) : AppColors.border(context),
//                             size: 28,
//                           ),
//                         ),
//                       );
//                     }),
//                   ),
//                   const SizedBox(height: 24),
//
//                   // Additional Feedback Label
//                   Align(
//                     alignment: Alignment.centerLeft,
//                     child: Text("Additional Feedback", style: AppTextStyles.textSize14(context, weight: FontWeight.w600)),
//                   ),
//                   const SizedBox(height: 8),
//
//                   // Feedback TextField
//                   Container(
//                     decoration: BoxDecoration(
//                       color: AppColors.hintColor(context).withOpacity(0.08),
//                       borderRadius: BorderRadius.circular(12),
//                       border: Border.all(color: AppColors.border(context)),
//                     ),
//                     child: TextField(
//                       controller: _feedbackController,
//                       maxLines: 4,
//                       maxLength: 250,
//                       onChanged: (val) {
//                         setModalState(() {
//                           _charCount = val.length;
//                         });
//                       },
//                       decoration: InputDecoration(
//                         hintText: "Write your feedback here...",
//                         hintStyle: AppTextStyles.textSize14(context, color: AppColors.subtitle(context)),
//                         border: InputBorder.none,
//                         contentPadding: const EdgeInsets.all(12),
//                         counterText: "${_charCount}/250",
//                         counterStyle: AppTextStyles.textSize10(context, color: AppColors.subtitle(context)),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 20),
//
//                   // Buttons
//                   Row(
//                     children: [
//                       Expanded(
//                         child: GestureDetector(
//                           onTap: () => Navigator.of(context).pop(),
//                           child: Container(
//                             height: 48,
//                             decoration: BoxDecoration(color: AppColors.hintColor(context).withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
//                             child: Center(
//                               child: Text("Cancel", style: AppTextStyles.textSize14(context, weight: FontWeight.w500)),
//                             ),
//                           ),
//                         ),
//                       ),
//                       const SizedBox(width: 12),
//                       Expanded(
//                         child: GestureDetector(
//                           onTap: () {
//                             if (_selectedRating == 0) {
//                               Utils.flushBarErrorMessage("Please select a rating", context);
//                               return;
//                             }
//                             Navigator.of(context).pop();
//                             Utils.flushBarSuccessMessage("Review submitted successfully!", context);
//                           },
//                           child: Container(
//                             height: 48,
//                             decoration: BoxDecoration(color: AppColors.textPrimary(context), borderRadius: BorderRadius.circular(12)),
//                             child: Center(
//                               child: Text(
//                                 "Submit Review",
//                                 style: AppTextStyles.textSize14(context, weight: FontWeight.w600, color: AppColors.textSecondary(context)),
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             );
//           },
//         );
//       },
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Scaffold(
//         backgroundColor: AppColors.containerBackground(context),
//         body: ResPonsiveUi(mobile: body(), desktop: body(), tablet: body()),
//       ),
//     );
//   }
//
//   Widget body() {
//     final screenWidth = MediaQuery.of(context).size.width;
//
//     return Column(
//       children: [
//         GestureDetector(
//           onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => NavigationScreen(initialIndex: 0))),
//           child: AppBarHeader("Orders"),
//         ),
//         Container(
//           width: screenWidth,
//           height: 50,
//           color: AppColors.containerBackground(context),
//           child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [_buildTab("Pending", 0), _buildTab("Running", 1), _buildTab("Completed", 2)]),
//         ),
//         SizedboxSpaccing.height015(context),
//         Expanded(
//           child: RefreshIndicator(
//             onRefresh: _handleRefresh,
//             color: AppColors.textPrimary(context),
//             backgroundColor: AppColors.containerBackground(context),
//             displacement: 40,
//             strokeWidth: 2.0,
//             child: Container(width: screenWidth * 0.9, child: _getSelectedWidget()),
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildTab(String title, int index) {
//     final screenWidth = MediaQuery.of(context).size.width;
//     final isSelected = _selectedTabIndex == index;
//
//     return GestureDetector(
//       onTap: () {
//         setState(() {
//           _selectedTabIndex = index;
//         });
//         final viewModel = Provider.of<RunningOrdersViewModel>(context, listen: false);
//         if (index == 0) {
//           viewModel.resetPendingOrders();
//           viewModel.fetchPendingOrdersGetDataApi();
//         } else if (index == 1) {
//           viewModel.resetRunningOrders();
//           viewModel.fetchRunningOrdersGetDataApi();
//         } else if (index == 2) {
//           viewModel.resetCompleteOrders();
//           viewModel.fetchCompleteOrdersGetDataApi();
//         }
//       },
//       child: Container(
//         width: screenWidth * 0.3,
//         decoration: BoxDecoration(
//           color: Colors.transparent,
//           border: Border(bottom: BorderSide(color: AppColors.border(context), width: 1.0)),
//         ),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             const SizedBox(height: 2),
//             Text(
//               title,
//               style: AppTextStyles.textSize16(context, color: isSelected ? AppColors.button(context) : AppColors.form_hover(context), weight: FontWeight.w500),
//             ),
//             Container(width: screenWidth * 0.4, height: 2, color: isSelected ? AppColors.button(context) : AppColors.containerBackground(context)),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _getSelectedWidget() {
//     switch (_selectedTabIndex) {
//       case 0:
//         return WidgetPendingOrder();
//       case 1:
//         return WidgetRunningOrder();
//       case 2:
//         return WidgetCompletedOrder();
//       default:
//         return Container();
//     }
//   }
//
//   // ─── Pending Orders ─────────────────────────────────────────────────────────
//   Widget WidgetPendingOrder() {
//     final screenHeight = MediaQuery.of(context).size.height;
//     return Consumer<RunningOrdersViewModel>(
//       builder: (context, viewModel, child) {
//         switch (viewModel.pendingOrdersData.status) {
//           case Status.LOADING:
//             if (viewModel.pendingCurrentPage == 1) {
//               return Container(
//                 height: screenHeight,
//                 color: AppColors.containerBackground(context),
//                 child: Center(child: LoadingAnimationWidget.progressiveDots(color: AppColors.button(context), size: 45)),
//               );
//             }
//             break;
//           case Status.ERROR:
//             return Container(
//               height: screenHeight,
//               child: ErrorStateWidget(
//                 errorMessage: viewModel.pendingOrdersData.message.toString(),
//                 onRetry: () {
//                   viewModel.resetPendingOrders();
//                   viewModel.fetchPendingOrdersGetDataApi();
//                 },
//               ),
//             );
//           case Status.COMPLETED:
//             break;
//           default:
//             return Container();
//         }
//
//         final allOrders = viewModel.pendingAllOrders;
//         if (allOrders.isEmpty) {
//           return _buildEmptyState('No Pending Orders', 'You don\'t have any pending orders at the moment', FontAwesomeIcons.boxOpen);
//         }
//
//         return ListView.builder(
//           physics: const AlwaysScrollableScrollPhysics(),
//           itemCount: allOrders.length + (viewModel.pendingHasMore ? 1 : 0),
//           itemBuilder: (context, index) {
//             if (index < allOrders.length) {
//               return _buildOrderCard(allOrders[index], isPendingTab: true);
//             }
//             if (viewModel.pendingHasMore) {
//               return Consumer<RunningOrdersViewModel>(builder: (_, vm, __) => _buildLoadMoreButton(context, () => vm.loadMorePendingOrders(), vm.pendingLoadingMore));
//             }
//             return const SizedBox.shrink();
//           },
//         );
//       },
//     );
//   }
//
//   // ─── Running Orders ─────────────────────────────────────────────────────────
//   Widget WidgetRunningOrder() {
//     final screenHeight = MediaQuery.of(context).size.height;
//     return Consumer<RunningOrdersViewModel>(
//       builder: (context, viewModel, child) {
//         switch (viewModel.runningOrdersData.status) {
//           case Status.LOADING:
//             if (viewModel.runningCurrentPage == 1) {
//               return Container(
//                 height: screenHeight,
//                 color: AppColors.containerBackground(context),
//                 child: Center(child: LoadingAnimationWidget.progressiveDots(color: AppColors.button(context), size: 45)),
//               );
//             }
//             break;
//           case Status.ERROR:
//             return Container(
//               height: screenHeight,
//               child: ErrorStateWidget(
//                 errorMessage: viewModel.runningOrdersData.message.toString(),
//                 onRetry: () {
//                   viewModel.resetRunningOrders();
//                   viewModel.fetchRunningOrdersGetDataApi();
//                 },
//               ),
//             );
//           case Status.COMPLETED:
//             break;
//           default:
//             return Container();
//         }
//
//         final allOrders = viewModel.runningAllOrders;
//         if (allOrders.isEmpty) {
//           return _buildEmptyState('No Running Orders', 'You don\'t have any running orders at the moment', FontAwesomeIcons.boxOpen);
//         }
//
//         return ListView.builder(
//           physics: const AlwaysScrollableScrollPhysics(),
//           itemCount: allOrders.length + (viewModel.runningHasMore ? 1 : 0),
//           itemBuilder: (context, index) {
//             if (index < allOrders.length) {
//               return _buildOrderCard(allOrders[index], isRunningTab: true);
//             }
//             if (viewModel.runningHasMore) {
//               return Consumer<RunningOrdersViewModel>(builder: (context, vm, _) => _buildLoadMoreButton(context, () => vm.loadMoreRunningOrders(), vm.runningLoadingMore));
//             }
//             return const SizedBox.shrink();
//           },
//         );
//       },
//     );
//   }
//
//   // ─── Completed Orders ────────────────────────────────────────────────────────
//   Widget WidgetCompletedOrder() {
//     final screenHeight = MediaQuery.of(context).size.height;
//     return Consumer<RunningOrdersViewModel>(
//       builder: (context, viewModel, child) {
//         switch (viewModel.completeOrdersData.status) {
//           case Status.LOADING:
//             if (viewModel.completeCurrentPage == 1) {
//               return Container(
//                 height: screenHeight,
//                 color: AppColors.containerBackground(context),
//                 child: Center(child: LoadingAnimationWidget.progressiveDots(color: AppColors.button(context), size: 45)),
//               );
//             }
//             break;
//           case Status.ERROR:
//             return Container(
//               height: screenHeight,
//               child: ErrorStateWidget(
//                 errorMessage: viewModel.completeOrdersData.message.toString(),
//                 onRetry: () {
//                   viewModel.resetCompleteOrders();
//                   viewModel.fetchCompleteOrdersGetDataApi();
//                 },
//               ),
//             );
//           case Status.COMPLETED:
//             break;
//           default:
//             return Container();
//         }
//
//         final allOrders = viewModel.completeAllOrders;
//         if (allOrders.isEmpty) {
//           return _buildEmptyState('No Completed Orders', 'You don\'t have any completed orders yet', FontAwesomeIcons.checkCircle);
//         }
//
//         return ListView.builder(
//           physics: const AlwaysScrollableScrollPhysics(),
//           itemCount: allOrders.length + (viewModel.completeHasMore ? 1 : 0),
//           itemBuilder: (context, index) {
//             if (index < allOrders.length) {
//               return _buildOrderCard(allOrders[index], isCompletedTab: true);
//             }
//             if (viewModel.completeHasMore) {
//               return Consumer<RunningOrdersViewModel>(builder: (context, vm, _) => _buildLoadMoreButton(context, () => vm.loadMoreCompleteOrders(), vm.completeLoadingMore));
//             }
//             return const SizedBox.shrink();
//           },
//         );
//       },
//     );
//   }
//
//   Widget _buildEmptyState(String title, String subtitle, IconData icon) {
//     return ListView(
//       physics: const AlwaysScrollableScrollPhysics(),
//       children: [
//         Container(
//           height: MediaQuery.of(context).size.height * 0.6,
//           child: Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(icon, color: AppColors.subtitle(context), size: 50),
//                 const SizedBox(height: 16),
//                 Text(title, style: AppTextStyles.textSize16(context)),
//                 const SizedBox(height: 8),
//                 Text(
//                   subtitle,
//                   style: AppTextStyles.textSize12(context, color: AppColors.subtitle(context)),
//                   textAlign: TextAlign.center,
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }
//
//   // ─── Order Card ──────────────────────────────────────────────────────────────
//   Widget _buildOrderCard(Datum datum, {bool isPendingTab = false, bool isRunningTab = false, bool isCompletedTab = false}) {
//     final screenHeight = MediaQuery.of(context).size.height;
//     final screenWidth = MediaQuery.of(context).size.width;
//
//     String orderType = '';
//     String displayOrderId = '';
//     String orderIdForNavigation = '';
//
//     if (datum.type == 'BEAUTY_SALON') {
//       orderType = 'Premium Beauty Salon';
//       displayOrderId = datum.beautySalonBookingId ?? 'N/A';
//       orderIdForNavigation = datum.beautySalonBookingId ?? '';
//     } else if (datum.type == 'HOUSEKEEPER') {
//       orderType = 'Premium House Keeper';
//       displayOrderId = datum.houseKeeperBookingId ?? 'N/A';
//       orderIdForNavigation = datum.houseKeeperBookingId ?? '';
//     } else if (datum.type == 'ORDER') {
//       orderType = 'Grocery Order';
//       displayOrderId = datum.orderId ?? 'N/A';
//       orderIdForNavigation = datum.orderId ?? '';
//     } else if (datum.type == 'EVENT_COOKING') {
//       orderType = 'Family Event Cooking';
//       displayOrderId = datum.eventCookingBookingId ?? 'N/A';
//       orderIdForNavigation = datum.eventCookingBookingId ?? '';
//     }
//
//     String shortOrderId = displayOrderId.length > 6 ? displayOrderId.substring(displayOrderId.length - 6) : displayOrderId;
//
//     return Container(
//       margin: EdgeInsets.only(bottom: screenHeight * 0.02),
//       decoration: BoxDecoration(
//         color: AppColors.containerBackground(context),
//         borderRadius: BorderRadius.circular(8),
//         border: Border.all(width: 1, color: AppColors.border(context)),
//       ),
//       child: GestureDetector(
//         onTap: () {
//           if (datum.type == 'ORDER') {
//             if (isPendingTab || isRunningTab) {
//               Navigator.pushNamed(context, RoutesName.trackOrderViewdetailsSocketScreen, arguments: {'orderId': orderIdForNavigation});
//             } else {
//               Navigator.pushNamed(context, RoutesName.completeOrdersDetailsScreen, arguments: {'orderId': orderIdForNavigation});
//             }
//           } else if (datum.type == 'HOUSEKEEPER') {
//             Navigator.pushNamed(context, RoutesName.confirmedScreen, arguments: {'trackingId': orderIdForNavigation});
//           } else if (datum.type == 'BEAUTY_SALON') {
//             Navigator.pushNamed(context, RoutesName.beautyConfirmedScreen, arguments: {'trackingId': orderIdForNavigation});
//           } else if (datum.type == 'EVENT_COOKING') {
//             Navigator.pushNamed(context, RoutesName.cookingConfirmedScreen, arguments: {'trackingId': orderIdForNavigation});
//           }
//         },
//         child: Container(
//           padding: EdgeInsets.all(screenHeight * 0.02),
//           color: Colors.transparent,
//           child: Column(
//             children: [
//               // ── Header Row ──────────────────────────────────────────────────
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Expanded(
//                     child: Row(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Container(
//                           width: 40,
//                           height: 40,
//                           decoration: BoxDecoration(color: AppColors.hintColor(context).withOpacity(0.5), borderRadius: BorderRadius.circular(8)),
//                           child: Icon(_getIconForType(datum.type), color: AppColors.textPrimary(context), size: 16),
//                         ),
//                         SizedboxSpaccing.width03(context),
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 orderType,
//                                 style: AppTextStyles.textSize16(context, weight: FontWeight.w500, color: AppColors.textPrimary(context)),
//                                 overflow: TextOverflow.ellipsis,
//                               ),
//                               Text(
//                                 "Order #$shortOrderId",
//                                 style: AppTextStyles.textSize12(context, weight: FontWeight.w400, color: AppColors.subtitle(context)),
//                               ),
//                               if (datum.createdAt != null)
//                                 Text(
//                                   DateTimeFormatter.formatRelativeDateTime(datum.createdAt!),
//                                   style: AppTextStyles.textSize12(context, color: AppColors.subtitle(context), weight: FontWeight.w400),
//                                 ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                     decoration: BoxDecoration(color: _getStatusColor(datum.status ?? '').withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
//                     child: Text(
//                       datum.status ?? 'Unknown',
//                       style: AppTextStyles.textSize10(context, color: _getStatusColor(datum.status ?? ''), weight: FontWeight.w500),
//                     ),
//                   ),
//                 ],
//               ),
//
//               // ── Assigned Freelancer Section (Pending + Running + Completed) ─
//               if ((isRunningTab || isCompletedTab) && datum.freelancer != null) ...[
//                 SizedboxSpaccing.height015(context),
//                 _buildAssignedFreelancerSection(context, datum, isCompletedTab: isCompletedTab),
//               ],
//
//               if (isRunningTab)...[
//                 SizedboxSpaccing.height015(context),
//                 Divider(height: 1, color: AppColors.border(context)),
//               ],
//
//               // ── Footer Row ──────────────────────────────────────────────────
//               Container(
//                 height: screenHeight * 0.04,
//                 color: Colors.transparent,
//                 alignment: Alignment.bottomCenter,
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text("৳${datum.total ?? 0}", style: AppTextStyles.textSize14(context, weight: FontWeight.w400)),
//                     Row(
//                       children: [
//                         Text("View Details ", style: AppTextStyles.textSize14(context, weight: FontWeight.w400)),
//                         SizedboxSpaccing.width01(context),
//                         Icon(FontAwesomeIcons.arrowRight, size: 15),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//
//               // ── Pay Now + Write Review (Completed tab only) ─────────────────
//               if (isCompletedTab) ...[       SizedboxSpaccing.height015(context), Divider(height: 1, color: AppColors.border(context)),SizedboxSpaccing.height02(context), _buildCompletedActions(context, datum)],
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   // ─── Assigned Freelancer Section ─────────────────────────────────────────────
//   Widget _buildAssignedFreelancerSection(BuildContext context, Datum datum, {bool isCompletedTab = false}) {
//     final String name = '${datum.freelancer?.firstName ?? ''} ${datum.freelancer?.lastName ?? ''}'.trim();
//     final String displayName = name.isNotEmpty ? name : 'Freelancer';
//     final String? imageUrl = datum.freelancer?.profilePicture?.url;
//     // final String? rating = datum.freelancer?.s;
//     final String role = (datum.freelancer?.skills != null && datum.freelancer!.skills!.isNotEmpty)
//         ? datum.freelancer!.skills!.first.category ?? datum.freelancer?.role ?? ''
//         : datum.freelancer?.role ?? '';
//
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           "ASSIGNED FREELANCER",
//           style: AppTextStyles.textSize12(context, weight: FontWeight.w500, color: AppColors.subtitle(context)),
//         ),
//         const SizedBox(height: 10),
//         Container(
//           padding: const EdgeInsets.all(10),
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(16),
//             border: Border.all(width: 1, color: AppColors.border(context)),
//           ),
//           child: Row(
//             children: [
//               // Avatar — real network image with initials fallback
//               CircleAvatarNetwork(
//                 imageUrl: imageUrl,
//                 name: displayName,
//                 size: 44,
//                 borderWidth: 1.5,
//                 borderColor: AppColors.border(context),
//               ),
//               const SizedBox(width: 10),
//
//               // Name + role + rating
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       displayName,
//                       style: AppTextStyles.textSize14(context, weight: FontWeight.w500),
//                     ),
//                     if (role.isNotEmpty)
//                       Text(
//                         role,
//                         style: AppTextStyles.textSize12(context, color: AppColors.subtitle(context)),
//                       ),
//                     Row(
//                       children: [
//                         const Icon(FontAwesomeIcons.solidStar, color: Color(0xFFFACC15), size: 11),
//                         const SizedBox(width: 4),
//                         Text("0.0", style: AppTextStyles.textSize12(context, weight: FontWeight.w500)),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//
//               // Chat + Call icons (only for Pending/Running)
//               // if (!isCompletedTab) ...[
//                 _buildCircleAction(context, FontAwesomeIcons.solidComment, () {}),
//                 const SizedBox(width: 8),
//                 _buildCircleAction(context, FontAwesomeIcons.phone, () {}),
//               // ],
//             ],
//           ),
//         ),
//       ],
//     );
//   }
//   Widget _buildCircleAction(BuildContext context, IconData icon, VoidCallback onTap) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         width: 31,
//         height: 31,
//         decoration: BoxDecoration(color: AppColors.textPrimary(context), shape: BoxShape.circle),
//         child: Icon(icon, color: AppColors.containerBackground(context), size: 12),
//       ),
//     );
//   }
//
//   // ─── Completed Action Buttons ─────────────────────────────────────────────────
//   Widget _buildCompletedActions(BuildContext context, Datum datum) {
//     return Row(
//       children: [
//
//         // Pay Now
//         if(datum.paymentType=="CASH_ON_DELIVERY")...[
//           Expanded(
//             child: GestureDetector(
//               onTap: () => _handlePayNow(context, datum),
//               child: Container(
//                 height: 42,
//                 decoration: BoxDecoration(color: AppColors.textPrimary(context), borderRadius: BorderRadius.circular(12)),
//                 child: Center(
//                   child: Text(
//                     "Pay Now",
//                     style: AppTextStyles.textSize14(context, weight: FontWeight.w600, color: AppColors.textSecondary(context)),
//                   ),
//                 ),
//               ),
//             ),
//           ),
//           const SizedBox(width: 15),
//         ],
//
//         // Write Review
//         Expanded(
//           child: GestureDetector(
//             onTap: () => _showWriteReviewSheet(context, datum),
//             child: Container(
//               height: 42,
//               decoration: BoxDecoration(
//                 color: AppColors.containerBackground(context),
//                 borderRadius: BorderRadius.circular(8),
//                 border: Border.all(color: AppColors.border(context), width: 1),
//               ),
//               child: Center(
//                 child: Text("Write Review", style: AppTextStyles.textSize14(context, weight: FontWeight.w500)),
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildLoadMoreButton(BuildContext context, VoidCallback onPressed, bool isLoading) {
//     final screenWidth = MediaQuery.of(context).size.width;
//     return Container(
//       padding: const EdgeInsets.symmetric(vertical: 16),
//       child: Center(
//         child: GestureDetector(
//           onTap: isLoading ? null : onPressed,
//           child: Container(
//             height: 50,
//             width: screenWidth * 0.8,
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(8),
//               border: Border.all(width: 1, color: AppColors.border(context)),
//               color: AppColors.containerBackground(context),
//             ),
//             child: Center(
//               child: isLoading
//                   ? LoadingAnimationWidget.progressiveDots(color: AppColors.button(context), size: 40)
//                   : Text("Load More", style: AppTextStyles.textSize16(context, weight: FontWeight.w500)),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   IconData _getIconForType(String? type) {
//     switch (type) {
//       case 'BEAUTY_SALON':
//         return FontAwesomeIcons.scissors;
//       case 'HOUSEKEEPER':
//         return FontAwesomeIcons.broom;
//       case 'EVENT_COOKING':
//         return FontAwesomeIcons.bowlRice;
//       case 'ORDER':
//         return FontAwesomeIcons.store;
//       default:
//         return FontAwesomeIcons.fileInvoice;
//     }
//   }
//
//   Color _getStatusColor(String status) {
//     switch (status.toUpperCase()) {
//       case 'PENDING':
//         return AppColors.darkRedColor;
//       case 'RUNNING':
//         return AppColors.button(context);
//       case 'COMPLETED':
//         return AppColors.oceanGreenColor;
//       case 'CANCELLED':
//         return const Color(0xFFDC2626);
//       default:
//         return const Color(0xFF6B7280);
//     }
//   }
// }

import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/components/header_appbar.dart';
import 'package:dinmajur_customer/configs/res/sizedbox_spaccing.dart';
import 'package:dinmajur_customer/configs/responsive/responsive_ui.dart';
import 'package:dinmajur_customer/configs/services/ssl_payment_service/ssl_payment.dart';
import 'package:dinmajur_customer/configs/utils/utils.dart';
import 'package:dinmajur_customer/model/order_models/get_all_order_model.dart';
import 'package:dinmajur_customer/view/navigation_bar.dart';
import 'package:dinmajur_customer/view/screens/order/tabs/order_list_tab.dart';
import 'package:dinmajur_customer/view/screens/order/widgets/order_tab_bar.dart';
import 'package:dinmajur_customer/view_model/order_view_models/running_orders_view_model.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  int _selectedTabIndex = 0;

  RunningOrdersViewModel get _orderViewModel =>
      Provider.of<RunningOrdersViewModel>(context, listen: false);

  @override
  void initState() {
    super.initState();
    _orderViewModel.clearAllDataSilent();
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchCurrentTab());
  }

  // ─── Tab switching ──────────────────────────────────────────────────────────
  void _onTabChanged(int index) {
    setState(() => _selectedTabIndex = index);
    switch (index) {
      case 0:
        _orderViewModel.resetPendingOrders();
        _orderViewModel.fetchPendingOrdersGetDataApi();
        break;
      case 1:
        _orderViewModel.resetRunningOrders();
        _orderViewModel.fetchRunningOrdersGetDataApi();
        break;
      case 2:
        _orderViewModel.resetCompleteOrders();
        _orderViewModel.fetchCompleteOrdersGetDataApi();
        break;
    }
  }

  void _fetchCurrentTab() {
    switch (_selectedTabIndex) {
      case 0: _orderViewModel.fetchPendingOrdersGetDataApi(); break;
      case 1: _orderViewModel.fetchRunningOrdersGetDataApi(); break;
      case 2: _orderViewModel.fetchCompleteOrdersGetDataApi(); break;
    }
  }

  // ─── Pull to refresh ────────────────────────────────────────────────────────
  Future<void> _handleRefresh() async {
    try {
      switch (_selectedTabIndex) {
        case 0: await _orderViewModel.fetchPendingOrdersGetDataApi(isRefresh: true); break;
        case 1: await _orderViewModel.fetchRunningOrdersGetDataApi(isRefresh: true); break;
        case 2: await _orderViewModel.fetchCompleteOrdersGetDataApi(isRefresh: true); break;
      }
    } catch (_) {
      if (mounted) Utils.flushBarErrorMessage("Refresh failed", context);
    }
  }

  Future<void> _handlePayNow(BuildContext context, Datum datum) async {
    String trackingId = '';
    String productCategory = '';

    switch (datum.type) {
      case 'ORDER':
        trackingId = datum.orderId ?? '';
        productCategory = 'Grocery Order';
        break;
      case 'HOUSEKEEPER':
        trackingId = datum.houseKeeperBookingId ?? '';
        productCategory = 'House Keeper';
        break;
      case 'BEAUTY_SALON':
        trackingId = datum.beautySalonBookingId ?? '';
        productCategory = 'Beauty Salon';
        break;
      case 'EVENT_COOKING':
        trackingId = datum.eventCookingBookingId ?? '';
        productCategory = 'Event Cooking';
        break;
    }

    if (trackingId.isEmpty) {
      Utils.flushBarErrorMessage("Invalid order ID", context);
      return;
    }

    try {
      final result = await SSLCommerzPaymentService().initiatePayment(
        trackingId: trackingId,
        totalAmount: (datum.total ?? 0).toDouble(),
        productCategory: productCategory,
        customerName: datum.customer?.fullName,
        customerPhone: datum.customer?.phone,
        customerEmail: '',
        customerAddress: datum.fullAddress ?? '',
      );

      if (result.success) {
        Utils.flushBarSuccessMessage("Payment successful!", context);

        // ✅ Refresh ONLY this specific order by its booking ID — safe against
        // list reordering because we match by ID, not by index.
        _orderViewModel.refreshSingleOrder(trackingId);

      } else if (result.status == 'CANCELLED') {
        Utils.flushBarErrorMessage("Payment cancelled", context);
      } else {
        Utils.flushBarErrorMessage(result.errorMessage ?? "Payment failed", context);
      }
    } catch (e) {
      Utils.flushBarErrorMessage("Payment error: $e", context);
    }
  }

  // ─── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.containerBackground(context),
        body: ResPonsiveUi(mobile: _body(), desktop: _body(), tablet: _body()),
      ),
    );
  }

  Widget _body() {
    final screenWidth = MediaQuery.of(context).size.width;

    return Column(
      children: [
        GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => NavigationScreen(initialIndex: 0)),
          ),
          child: AppBarHeader("Orders"),
        ),
        OrderTabBar(
          selectedIndex: _selectedTabIndex,
          onTabChanged: _onTabChanged,
        ),
        SizedboxSpaccing.height015(context),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _handleRefresh,
            color: AppColors.textPrimary(context),
            backgroundColor: AppColors.containerBackground(context),
            displacement: 40,
            strokeWidth: 2.0,
            child: Container(
              width: screenWidth * 0.9,
              child: _buildCurrentTab(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCurrentTab() {
    return Consumer<RunningOrdersViewModel>(
      builder: (context, orderViewModel, _) {
        switch (_selectedTabIndex) {
          case 0:
            return OrderListTab(
              apiResponse: orderViewModel.pendingOrdersData,
              orders: orderViewModel.pendingAllOrders,
              currentPage: orderViewModel.pendingCurrentPage,
              hasMore: orderViewModel.pendingHasMore,
              loadingMore: orderViewModel.pendingLoadingMore,
              isPendingTab: true,
              emptyTitle: 'No Pending Orders',
              emptySubtitle: 'You don\'t have any pending orders at the moment',
              emptyIcon: FontAwesomeIcons.boxOpen,
              onRetry: () {
                orderViewModel.resetPendingOrders();
                orderViewModel.fetchPendingOrdersGetDataApi();
              },
              onLoadMore: orderViewModel.loadMorePendingOrders,
              onPayNow: _handlePayNow,
            );
          case 1:
            return OrderListTab(
              apiResponse: orderViewModel.runningOrdersData,
              orders: orderViewModel.runningAllOrders,
              currentPage: orderViewModel.runningCurrentPage,
              hasMore: orderViewModel.runningHasMore,
              loadingMore: orderViewModel.runningLoadingMore,
              isRunningTab: true,
              emptyTitle: 'No Running Orders',
              emptySubtitle: 'You don\'t have any running orders at the moment',
              emptyIcon: FontAwesomeIcons.boxOpen,
              onRetry: () {
                orderViewModel.resetRunningOrders();
                orderViewModel.fetchRunningOrdersGetDataApi();
              },
              onLoadMore: orderViewModel.loadMoreRunningOrders,
              onPayNow: _handlePayNow,
            );
          case 2:
            return OrderListTab(
              apiResponse: orderViewModel.completeOrdersData,
              orders: orderViewModel.completeAllOrders,
              currentPage: orderViewModel.completeCurrentPage,
              hasMore: orderViewModel.completeHasMore,
              loadingMore: orderViewModel.completeLoadingMore,
              isCompletedTab: true,
              emptyTitle: 'No Completed Orders',
              emptySubtitle: 'You don\'t have any completed orders yet',
              emptyIcon: FontAwesomeIcons.checkCircle,
              onRetry: () {
                orderViewModel.resetCompleteOrders();
                orderViewModel.fetchCompleteOrdersGetDataApi();
              },
              onLoadMore: orderViewModel.loadMoreCompleteOrders,
              onPayNow: _handlePayNow,
            );
          default:
            return const SizedBox.shrink();
        }
      },
    );
  }
}