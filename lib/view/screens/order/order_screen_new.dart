// import 'package:dinmajur_customer/configs/res/color.dart';
// import 'package:dinmajur_customer/configs/res/components/exception_errorstate/exception_errorstate.dart';
// import 'package:dinmajur_customer/configs/res/components/header_appbar.dart';
// import 'package:dinmajur_customer/configs/res/sizedbox_spaccing.dart';
// import 'package:dinmajur_customer/configs/res/text_styles.dart';
// import 'package:dinmajur_customer/configs/responsive/responsive_ui.dart';
// import 'package:dinmajur_customer/configs/utils/routes/routes_name.dart';
// import 'package:dinmajur_customer/configs/utils/utils.dart';
// import 'package:dinmajur_customer/configs/widgets/datetime_formatter.dart';
// import 'package:dinmajur_customer/data/response/status.dart';
// import 'package:dinmajur_customer/model/order_models/get_all_order_model.dart';
// import 'package:dinmajur_customer/view/navigation_bar.dart';
// import 'package:dinmajur_customer/view_model/order_view_models/complete_orders_view_model.dart';
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
//
//   @override
//   void initState() {
//     super.initState();
//     // Fetch running orders data when widget initializes
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       final runningOrderViewModel = Provider.of<RunningOrdersViewModel>(context, listen: false);
//       // runningOrderViewModel.fetchRunningOrdersGetDataApi();
//       runningOrderViewModel.fetchPendingOrdersGetDataApi();
//     });
//   }
//
//   Future<void> _handleRefresh() async {
//     try {
//       debugPrint('🔄 OrderScreen: Pull to refresh triggered');
//
//       // 2. Refresh orders based on selected tab
//       if (_selectedTabIndex == 0) {
//         // Running orders tab
//         final pendingOrderViewModel = Provider.of<RunningOrdersViewModel>(context, listen: false);
//         await pendingOrderViewModel.fetchPendingOrdersGetDataApi();
//         debugPrint('🔄 OrderScreen: Running orders refreshed');
//       }
//       if (_selectedTabIndex == 1) {
//         // Running orders tab
//         final runningOrderViewModel = Provider.of<RunningOrdersViewModel>(context, listen: false);
//         await runningOrderViewModel.fetchRunningOrdersGetDataApi();
//         debugPrint('🔄 OrderScreen: Running orders refreshed');
//       } else if (_selectedTabIndex == 2) {
//         // Completed orders tab
//         final completeOrderViewModel = Provider.of<CompleteOrdersViewModel>(context, listen: false);
//         await completeOrderViewModel.fetchCompleteOrdersGetDataApi();
//         debugPrint('🔄 OrderScreen: Completed orders refreshed');
//       }
//
//       debugPrint('🔄 OrderScreen: Refresh completed successfully');
//     } catch (e) {
//       debugPrint('🔄 OrderScreen: Refresh failed - $e');
//       if (mounted) {
//         Utils.flushBarErrorMessage("Refresh failed", context);
//       }
//     }
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
//     final screenHeight = MediaQuery.of(context).size.height;
//
//     return Column(
//       children: [
//         // Header AppBar
//         GestureDetector(
//           onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => NavigationScreen(initialIndex: 0))),
//           child: AppBarHeader("Orders"),
//         ),
//
//         /// Tabs
//         Container(
//           width: screenWidth,
//           height: 50,
//           color: AppColors.containerBackground(context),
//           child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [_buildTab("Pending", 0), _buildTab("Running", 1), _buildTab("Completed", 2)]),
//         ),
//         SizedboxSpaccing.height015(context),
//
//         // Content
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
//     final screenHeight = MediaQuery.of(context).size.height;
//     final screenWidth = MediaQuery.of(context).size.width;
//     final isSelected = _selectedTabIndex == index;
//
//     return GestureDetector(
//       onTap: () {
//         setState(() {
//           _selectedTabIndex = index;
//         });
//
//         // Fetch orders data when any tab is clicked
//         if (index == 0) {
//           // Running tab clicked - reload running orders
//           final pendingOrderViewModel = Provider.of<RunningOrdersViewModel>(context, listen: false);
//           pendingOrderViewModel.fetchPendingOrdersGetDataApi();
//         }
//         if (index == 1) {
//           // Running tab clicked - reload running orders
//           final runningOrderViewModel = Provider.of<RunningOrdersViewModel>(context, listen: false);
//           runningOrderViewModel.fetchRunningOrdersGetDataApi();
//         } else if (index == 2) {
//           // Complete tab clicked - reload completed orders
//           final completeOrderViewModel = Provider.of<CompleteOrdersViewModel>(context, listen: false);
//           completeOrderViewModel.fetchCompleteOrdersGetDataApi();
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
//             SizedBox(height: 2),
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
//   Widget WidgetPendingOrder() {
//     final screenHeight = MediaQuery.of(context).size.height;
//     final screenWidth = MediaQuery.of(context).size.width;
//
//     return Consumer<RunningOrdersViewModel>(
//       builder: (context, viewModel, child) {
//         switch (viewModel.pendingOrdersData.status) {
//           case Status.LOADING:
//             return Container(
//               height: screenHeight,
//               color: AppColors.containerBackground(context),
//               child: Center(
//                 child: Container(height: 15, width: 50, child: LoadingAnimationWidget.progressiveDots(color: AppColors.button(context), size: 45)),
//               ),
//             );
//           case Status.ERROR:
//             return Container(
//               height: screenHeight,
//               child: ErrorStateWidget(
//                 errorMessage: viewModel.pendingOrdersData.message.toString(),
//                 onRetry: () {
//                   viewModel.fetchPendingOrdersGetDataApi();              },
//               ),
//             );
//             //
//             //   Center(
//             //   child: Column(
//             //     mainAxisAlignment: MainAxisAlignment.center,
//             //     children: [
//             //       Icon(Icons.error_outline, color: Colors.red, size: 60),
//             //       SizedBox(height: 16),
//             //       Text('Error loading orders', style: AppTextStyles.textSize16(context)),
//             //       SizedBox(height: 8),
//             //       Text(
//             //         viewModel.pendingOrdersData.message.toString(),
//             //         style: AppTextStyles.textSize12(context, color: AppColors.subtitle(context)),
//             //         textAlign: TextAlign.center,
//             //       ),
//             //       SizedBox(height: 16),
//             //       ElevatedButton(
//             //         onPressed: () {
//             //           viewModel.fetchPendingOrdersGetDataApi();
//             //         },
//             //         child: Text('Retry'),
//             //       ),
//             //     ],
//             //   ),
//             // );
//
//           case Status.COMPLETED:
//             final orderData = viewModel.pendingOrdersData.data;
//
//             if (orderData == null || orderData.data == null || orderData.data!.data == null || orderData.data!.data!.isEmpty) {
//               // ✅ IMPORTANT: Wrap empty state with ListView to enable pull-to-refresh
//               return ListView(
//                 physics: AlwaysScrollableScrollPhysics(),
//                 children: [
//                   Container(
//                     height: MediaQuery.of(context).size.height * 0.6,
//                     child: Center(
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Icon(FontAwesomeIcons.boxOpen, color: AppColors.subtitle(context), size: 50),
//                           SizedBox(height: 16),
//                           Text('No Pending Orders', style: AppTextStyles.textSize16(context)),
//                           SizedBox(height: 8),
//                           Text(
//                             'You don\'t have any pending orders at the moment',
//                             style: AppTextStyles.textSize12(context, color: AppColors.subtitle(context)),
//                             textAlign: TextAlign.center,
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ],
//               );
//             }
//
//             return RefreshIndicator(
//               onRefresh: () async {
//                 await viewModel.fetchPendingOrdersGetDataApi();
//               },
//               child: ListView.builder(
//                 itemCount: orderData.data!.data!.length,
//                 itemBuilder: (context, index) {
//                   final datum = orderData.data!.data![index];
//                   return _buildOrderCard(datum, screenWidth, screenHeight, isPendingTab: true);
//                 },
//               ),
//             );
//
//           default:
//             return Container();
//         }
//       },
//     );
//   }
//
//   Widget WidgetRunningOrder() {
//     final screenHeight = MediaQuery.of(context).size.height;
//     final screenWidth = MediaQuery.of(context).size.width;
//
//     return Consumer<RunningOrdersViewModel>(
//       builder: (context, viewModel, child) {
//         switch (viewModel.runningOrdersData.status) {
//           case Status.LOADING:
//             return Container(
//               height: screenHeight,
//               color: AppColors.containerBackground(context),
//               child: Center(
//                 child: Container(height: 15, width: 50, child: LoadingAnimationWidget.progressiveDots(color: AppColors.button(context), size: 45)),
//               ),
//             );
//           case Status.ERROR:
//             return Container(
//               height: screenHeight,
//               child: ErrorStateWidget(
//                 errorMessage: viewModel.runningOrdersData.message.toString(),
//                 onRetry: () {
//                   viewModel.fetchRunningOrdersGetDataApi();
//                   },
//               ),
//             );
//
//           case Status.COMPLETED:
//             final orderData = viewModel.runningOrdersData.data;
//
//             if (orderData == null || orderData.data == null || orderData.data!.data == null || orderData.data!.data!.isEmpty) {
//               // ✅ IMPORTANT: Wrap empty state with ListView to enable pull-to-refresh
//               return ListView(
//                 physics: AlwaysScrollableScrollPhysics(),
//                 children: [
//                   Container(
//                     height: MediaQuery.of(context).size.height * 0.6,
//                     child: Center(
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Icon(FontAwesomeIcons.boxOpen, color: AppColors.subtitle(context), size: 50),
//                           SizedBox(height: 16),
//                           Text('No Running Orders', style: AppTextStyles.textSize16(context)),
//                           SizedBox(height: 8),
//                           Text(
//                             'You don\'t have any running orders at the moment',
//                             style: AppTextStyles.textSize12(context, color: AppColors.subtitle(context)),
//                             textAlign: TextAlign.center,
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ],
//               );
//             }
//
//             return RefreshIndicator(
//               onRefresh: () async {
//                 await viewModel.fetchRunningOrdersGetDataApi();
//               },
//               child: ListView.builder(
//                 itemCount: orderData.data!.data!.length,
//                 itemBuilder: (context, index) {
//                   final datum = orderData.data!.data![index];
//                   return _buildOrderCard(datum, screenWidth, screenHeight, isRunningTab: true);
//                 },
//               ),
//             );
//
//           default:
//             return Container();
//         }
//       },
//     );
//   }
//
//   Widget WidgetCompletedOrder() {
//     final screenHeight = MediaQuery.of(context).size.height;
//     final screenWidth = MediaQuery.of(context).size.width;
//
//     return Consumer<CompleteOrdersViewModel>(
//       builder: (context, viewModel, child) {
//         switch (viewModel.completeOrdersData.status) {
//           case Status.LOADING:
//             return Container(
//               height: screenHeight,
//               color: AppColors.containerBackground(context),
//               child: Center(
//                 child: Container(height: 15, width: 50, child: LoadingAnimationWidget.progressiveDots(color: AppColors.button(context), size: 45)),
//               ),
//             );
//
//           case Status.ERROR:
//             return Container(
//               height: screenHeight,
//               child: ErrorStateWidget(
//                 errorMessage: viewModel.completeOrdersData.message.toString(),
//                 onRetry: () {
//                   viewModel.fetchCompleteOrdersGetDataApi();
//                 },
//               ),
//             );
//           case Status.COMPLETED:
//             final orderData = viewModel.completeOrdersData.data;
//
//             if (orderData == null || orderData.data == null || orderData.data!.data == null || orderData.data!.data!.isEmpty) {
//               // ✅ IMPORTANT: Wrap empty state with ListView to enable pull-to-refresh
//               return ListView(
//                 physics: AlwaysScrollableScrollPhysics(),
//                 children: [
//                   Container(
//                     height: MediaQuery.of(context).size.height * 0.6,
//                     child: Center(
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Icon(FontAwesomeIcons.checkCircle, color: AppColors.subtitle(context), size: 50),
//                           SizedBox(height: 16),
//                           Text('No Completed Orders', style: AppTextStyles.textSize16(context)),
//                           SizedBox(height: 8),
//                           Text(
//                             'You don\'t have any completed orders yet',
//                             style: AppTextStyles.textSize12(context, color: AppColors.subtitle(context)),
//                             textAlign: TextAlign.center,
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ],
//               );
//             }
//
//             return RefreshIndicator(
//               onRefresh: () async {
//                 await viewModel.fetchCompleteOrdersGetDataApi();
//               },
//               child: ListView.builder(
//                 itemCount: orderData.data!.data!.length,
//                 itemBuilder: (context, index) {
//                   final datum = orderData.data!.data![index];
//                   return _buildOrderCard(datum, screenWidth, screenHeight);
//                 },
//               ),
//             );
//
//           default:
//             return Container();
//         }
//       },
//     );
//   }
//
//   Widget _buildOrderCard(Datum datum, double screenWidth, double screenHeight, {bool isPendingTab = false, bool isRunningTab = false}) {
//     // Extract data based on type
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
//     }
//
//     // Get last 6 characters of order ID for display
//     String shortOrderId = displayOrderId.length > 6 ? displayOrderId.substring(displayOrderId.length - 6) : displayOrderId;
//
//     return Container(
//       margin: EdgeInsets.only(bottom: screenHeight * 0.02),
//       decoration: BoxDecoration(color: AppColors.containerBackground(context),
//           borderRadius: BorderRadius.circular(8),
//         border: Border.all(width: 1, color: AppColors.border(context)),
//       ),
//       child: GestureDetector(
//         onTap: () {
//           // Navigate based on type
//           if (datum.type == 'ORDER') {
//             // For grocery orders
//             if (isPendingTab || isRunningTab) {
//               Navigator.pushNamed(context, RoutesName.trackOrderViewdetailsSocketScreen, arguments: {'orderId': orderIdForNavigation});
//             } else {
//               Navigator.pushNamed(context, RoutesName.completeOrdersDetailsScreen, arguments: {'orderId': orderIdForNavigation});
//             }
//           } else if (datum.type == 'HOUSEKEEPER') {
//             Navigator.pushNamed(context, RoutesName.confirmedScreen, arguments: {'trackingId': orderIdForNavigation});
//
//             // Navigate to House Keeper screen
//             // Navigator.pushNamed(
//             //   context,
//             //   RoutesName.houseKeeperOrderDetailsScreen, // Replace with your actual route
//             //   arguments: {'bookingId': orderIdForNavigation},
//             // );
//           } else if (datum.type == 'BEAUTY_SALON') {
//             Navigator.pushNamed(
//               context,
//               RoutesName.beautyConfirmedScreen,
//               arguments: {'trackingId': orderIdForNavigation},
//             );
//             // Navigate to Beauty Salon screen
//             // Navigator.pushNamed(
//             //   context,
//             //   RoutesName.beautySalonOrderDetailsScreen, // Replace with your actual route
//             //   arguments: {'bookingId': orderIdForNavigation},
//             // );
//           }
//         },
//         child: Container(
//           padding: EdgeInsets.all(screenHeight * 0.02),
//           color: Colors.transparent,
//           child: Column(
//             children: [
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
//                             mainAxisAlignment: MainAxisAlignment.start,
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
//                     padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                     decoration: BoxDecoration(color: _getStatusColor(datum.status ?? '').withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
//                     child: Text(
//                       datum.status ?? 'Unknown',
//                       style: AppTextStyles.textSize10(context, color: _getStatusColor(datum.status ?? ''), weight: FontWeight.w500),
//                     ),
//                   ),
//                 ],
//               ),
//               SizedboxSpaccing.height015(context),
//               Divider(height: 1,color: AppColors.border(context),),
//
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
//                      SizedboxSpaccing.width01(context),
//                         Icon(FontAwesomeIcons.arrowRight, size: 15,)
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   // Helper method to get icon based on type
//   IconData _getIconForType(String? type) {
//     switch (type) {
//       case 'BEAUTY_SALON':
//         return FontAwesomeIcons.scissors; // or FontAwesomeIcons.spa
//       case 'HOUSEKEEPER':
//         return FontAwesomeIcons.broom; // or FontAwesomeIcons.home
//       case 'ORDER':
//         return FontAwesomeIcons.store;
//       default:
//         return FontAwesomeIcons.fileInvoice;
//     }
//   }
//
//
//
//
//   Color _getStatusColor(String status) {
//     switch (status.toUpperCase()) {
//       case 'PENDING':
//         return AppColors.darkRedColor; // Yellow
//       case 'RUNNING':
//         return AppColors.button(context); // Blue
//       case 'COMPLETED':
//         return AppColors.oceanGreenColor; // Green
//       case 'CANCELLED':
//         return Color(0xFFDC2626); // Red
//       default:
//         return Color(0xFF6B7280); // Gray
//     }
//   }
// }

import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/components/exception_errorstate/exception_errorstate.dart';
import 'package:dinmajur_customer/configs/res/components/header_appbar.dart';
import 'package:dinmajur_customer/configs/res/sizedbox_spaccing.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:dinmajur_customer/configs/responsive/responsive_ui.dart';
import 'package:dinmajur_customer/configs/utils/routes/routes_name.dart';
import 'package:dinmajur_customer/configs/utils/utils.dart';
import 'package:dinmajur_customer/configs/widgets/datetime_formatter.dart';
import 'package:dinmajur_customer/data/response/status.dart';
import 'package:dinmajur_customer/model/order_models/get_all_order_model.dart';
import 'package:dinmajur_customer/view/navigation_bar.dart';
import 'package:dinmajur_customer/view_model/order_view_models/running_orders_view_model.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  int _selectedTabIndex = 0;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();

    // Clear data silently (without notifyListeners) to prevent cached data display
    final viewModel = Provider.of<RunningOrdersViewModel>(context, listen: false);
    viewModel.clearAllDataSilent();

    // Schedule data fetching after the build is complete
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Only initialize once when first building
    if (!_isInitialized) {
      _isInitialized = true;
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  // Initialize data based on selected tab
  void _initializeData() {
    final viewModel = Provider.of<RunningOrdersViewModel>(context, listen: false);

    // Fetch fresh data for current tab
    if (_selectedTabIndex == 0) {
      viewModel.fetchPendingOrdersGetDataApi();
    } else if (_selectedTabIndex == 1) {
      viewModel.fetchRunningOrdersGetDataApi();
    } else if (_selectedTabIndex == 2) {
      viewModel.fetchCompleteOrdersGetDataApi();
    }
  }

  Future<void> _handleRefresh() async {
    try {
      debugPrint('🔄 OrderScreen: Pull to refresh triggered');

      final viewModel = Provider.of<RunningOrdersViewModel>(context, listen: false);

      if (_selectedTabIndex == 0) {
        await viewModel.fetchPendingOrdersGetDataApi(isRefresh: true);
        debugPrint('🔄 OrderScreen: Pending orders refreshed');
      } else if (_selectedTabIndex == 1) {
        await viewModel.fetchRunningOrdersGetDataApi(isRefresh: true);
        debugPrint('🔄 OrderScreen: Running orders refreshed');
      } else if (_selectedTabIndex == 2) {
        await viewModel.fetchCompleteOrdersGetDataApi(isRefresh: true);
        debugPrint('🔄 OrderScreen: Complete orders refreshed');
      }

      debugPrint('🔄 OrderScreen: Refresh completed successfully');
    } catch (e) {
      debugPrint('🔄 OrderScreen: Refresh failed - $e');
      if (mounted) {
        Utils.flushBarErrorMessage("Refresh failed", context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.containerBackground(context),
        body: ResPonsiveUi(mobile: body(), desktop: body(), tablet: body()),
      ),
    );
  }

  Widget body() {
    final screenWidth = MediaQuery.of(context).size.width;

    return Column(
      children: [
        GestureDetector(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => NavigationScreen(initialIndex: 0))),
          child: AppBarHeader("Orders"),
        ),
        Container(
          width: screenWidth,
          height: 50,
          color: AppColors.containerBackground(context),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [_buildTab("Pending", 0), _buildTab("Running", 1), _buildTab("Completed", 2)]),
        ),
        SizedboxSpaccing.height015(context),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _handleRefresh,
            color: AppColors.textPrimary(context),
            backgroundColor: AppColors.containerBackground(context),
            displacement: 40,
            strokeWidth: 2.0,
            child: Container(width: screenWidth * 0.9, child: _getSelectedWidget()),
          ),
        ),
      ],
    );
  }

  Widget _buildTab(String title, int index) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSelected = _selectedTabIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTabIndex = index;
        });

        final viewModel = Provider.of<RunningOrdersViewModel>(context, listen: false);

        if (index == 0) {
          viewModel.resetPendingOrders();
          viewModel.fetchPendingOrdersGetDataApi();
        } else if (index == 1) {
          viewModel.resetRunningOrders();
          viewModel.fetchRunningOrdersGetDataApi();
        } else if (index == 2) {
          viewModel.resetCompleteOrders();
          viewModel.fetchCompleteOrdersGetDataApi();
        }
      },
      child: Container(
        width: screenWidth * 0.3,
        decoration: BoxDecoration(
          color: Colors.transparent,
          border: Border(bottom: BorderSide(color: AppColors.border(context), width: 1.0)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(height: 2),
            Text(
              title,
              style: AppTextStyles.textSize16(context, color: isSelected ? AppColors.button(context) : AppColors.form_hover(context), weight: FontWeight.w500),
            ),
            Container(width: screenWidth * 0.4, height: 2, color: isSelected ? AppColors.button(context) : AppColors.containerBackground(context)),
          ],
        ),
      ),
    );
  }

  Widget _getSelectedWidget() {
    switch (_selectedTabIndex) {
      case 0:
        return WidgetPendingOrder();
      case 1:
        return WidgetRunningOrder();
      case 2:
        return WidgetCompletedOrder();
      default:
        return Container();
    }
  }




// For Pending Orders ListView:
  Widget WidgetPendingOrder() {
    final screenHeight = MediaQuery.of(context).size.height;

    return Consumer<RunningOrdersViewModel>(
      builder: (context, viewModel, child) {
        switch (viewModel.pendingOrdersData.status) {
          case Status.LOADING:
            if (viewModel.pendingCurrentPage == 1) {
              return Container(
                height: screenHeight,
                color: AppColors.containerBackground(context),
                child: Center(
                  child: LoadingAnimationWidget.progressiveDots(
                    color: AppColors.button(context),
                    size: 45,
                  ),
                ),
              );
            }
            break;

          case Status.ERROR:
            return Container(
              height: screenHeight,
              child: ErrorStateWidget(
                errorMessage: viewModel.pendingOrdersData.message.toString(),
                onRetry: () {
                  viewModel.resetPendingOrders();
                  viewModel.fetchPendingOrdersGetDataApi();
                },
              ),
            );

          case Status.COMPLETED:
            break;

          default:
            return Container();
        }

        final allOrders = viewModel.pendingAllOrders;

        if (allOrders.isEmpty) {
          return _buildEmptyState(
            'No Pending Orders',
            'You don\'t have any pending orders at the moment',
            FontAwesomeIcons.boxOpen,
          );
        }

        return ListView.builder(
          physics: AlwaysScrollableScrollPhysics(),
          itemCount: allOrders.length + (viewModel.pendingHasMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index < allOrders.length) {
              return _buildOrderCard(allOrders[index], isPendingTab: true);
            }

            // Load more button - MUST be wrapped in Consumer
            if (viewModel.pendingHasMore) {
              // Create a NEW Consumer here to listen to loading state changes
              return Consumer<RunningOrdersViewModel>(
                builder: (_, vm, __) {
                  print('🔄 Pending Load More Button Rebuilding - Loading: ${vm.pendingLoadingMore}');
                  return _buildLoadMoreButton(
                    context,
                        () => vm.loadMorePendingOrders(),
                    vm.pendingLoadingMore,
                  );
                },
              );
            }

            return SizedBox.shrink();
          },
        );
      },
    );
  }

// Apply the same pattern to WidgetRunningOrder and WidgetCompletedOrder
  Widget WidgetRunningOrder() {
    final screenHeight = MediaQuery.of(context).size.height;

    return Consumer<RunningOrdersViewModel>(
      builder: (context, viewModel, child) {
        switch (viewModel.runningOrdersData.status) {
          case Status.LOADING:
            if (viewModel.runningCurrentPage == 1) {
              return Container(
                height: screenHeight,
                color: AppColors.containerBackground(context),
                child: Center(
                  child: LoadingAnimationWidget.progressiveDots(
                    color: AppColors.button(context),
                    size: 45,
                  ),
                ),
              );
            }
            break;

          case Status.ERROR:
            return Container(
              height: screenHeight,
              child: ErrorStateWidget(
                errorMessage: viewModel.runningOrdersData.message.toString(),
                onRetry: () {
                  viewModel.resetRunningOrders();
                  viewModel.fetchRunningOrdersGetDataApi();
                },
              ),
            );

          case Status.COMPLETED:
            break;

          default:
            return Container();
        }

        final allOrders = viewModel.runningAllOrders;

        if (allOrders.isEmpty) {
          return _buildEmptyState(
            'No Running Orders',
            'You don\'t have any running orders at the moment',
            FontAwesomeIcons.boxOpen,
          );
        }

        return ListView.builder(
          physics: AlwaysScrollableScrollPhysics(),
          itemCount: allOrders.length + (viewModel.runningHasMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index < allOrders.length) {
              return _buildOrderCard(allOrders[index], isRunningTab: true);
            }

            if (viewModel.runningHasMore) {
              return Consumer<RunningOrdersViewModel>(
                builder: (context, vm, _) {
                  return _buildLoadMoreButton(
                    context,
                        () => vm.loadMoreRunningOrders(),
                    vm.runningLoadingMore,
                  );
                },
              );
            }

            return SizedBox.shrink();
          },
        );
      },
    );
  }

  Widget WidgetCompletedOrder() {
    final screenHeight = MediaQuery.of(context).size.height;

    return Consumer<RunningOrdersViewModel>(
      builder: (context, viewModel, child) {
        switch (viewModel.completeOrdersData.status) {
          case Status.LOADING:
            if (viewModel.completeCurrentPage == 1) {
              return Container(
                height: screenHeight,
                color: AppColors.containerBackground(context),
                child: Center(
                  child: LoadingAnimationWidget.progressiveDots(
                    color: AppColors.button(context),
                    size: 45,
                  ),
                ),
              );
            }
            break;

          case Status.ERROR:
            return Container(
              height: screenHeight,
              child: ErrorStateWidget(
                errorMessage: viewModel.completeOrdersData.message.toString(),
                onRetry: () {
                  viewModel.resetCompleteOrders();
                  viewModel.fetchCompleteOrdersGetDataApi();
                },
              ),
            );

          case Status.COMPLETED:
            break;

          default:
            return Container();
        }

        final allOrders = viewModel.completeAllOrders;

        if (allOrders.isEmpty) {
          return _buildEmptyState(
            'No Completed Orders',
            'You don\'t have any completed orders yet',
            FontAwesomeIcons.checkCircle,
          );
        }

        return ListView.builder(
          physics: AlwaysScrollableScrollPhysics(),
          itemCount: allOrders.length + (viewModel.completeHasMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index < allOrders.length) {
              return _buildOrderCard(allOrders[index]);
            }

            if (viewModel.completeHasMore) {
              return Consumer<RunningOrdersViewModel>(
                builder: (context, vm, _) {
                  return _buildLoadMoreButton(
                    context,
                        () => vm.loadMoreCompleteOrders(),
                    vm.completeLoadingMore,
                  );
                },
              );
            }

            return SizedBox.shrink();
          },
        );
      },
    );
  }

  Widget _buildEmptyState(String title, String subtitle, IconData icon) {
    return ListView(
      physics: AlwaysScrollableScrollPhysics(),
      children: [
        Container(
          height: MediaQuery.of(context).size.height * 0.6,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: AppColors.subtitle(context), size: 50),
                SizedBox(height: 16),
                Text(title, style: AppTextStyles.textSize16(context)),
                SizedBox(height: 8),
                Text(
                  subtitle,
                  style: AppTextStyles.textSize12(context, color: AppColors.subtitle(context)),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOrderCard(Datum datum, {bool isPendingTab = false, bool isRunningTab = false}) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    String orderType = '';
    String displayOrderId = '';
    String orderIdForNavigation = '';

    if (datum.type == 'BEAUTY_SALON') {
      orderType = 'Premium Beauty Salon';
      displayOrderId = datum.beautySalonBookingId ?? 'N/A';
      orderIdForNavigation = datum.beautySalonBookingId ?? '';
    } else if (datum.type == 'HOUSEKEEPER') {
      orderType = 'Premium House Keeper';
      displayOrderId = datum.houseKeeperBookingId ?? 'N/A';
      orderIdForNavigation = datum.houseKeeperBookingId ?? '';
    } else if (datum.type == 'ORDER') {
      orderType = 'Grocery Order';
      displayOrderId = datum.orderId ?? 'N/A';
      orderIdForNavigation = datum.orderId ?? '';
    }else if (datum.type == 'EVENT_COOKING') {
      orderType = 'Family Event Cooking';
      displayOrderId = datum.eventCookingBookingId ?? 'N/A';
      orderIdForNavigation = datum.eventCookingBookingId ?? '';
    }

    String shortOrderId = displayOrderId.length > 6 ? displayOrderId.substring(displayOrderId.length - 6) : displayOrderId;

    return Container(
      margin: EdgeInsets.only(bottom: screenHeight * 0.02),
      decoration: BoxDecoration(
        color: AppColors.containerBackground(context),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(width: 1, color: AppColors.border(context)),
      ),
      child: GestureDetector(
        onTap: () {
          if (datum.type == 'ORDER') {
            if (isPendingTab || isRunningTab) {
              Navigator.pushNamed(context, RoutesName.trackOrderViewdetailsSocketScreen, arguments: {'orderId': orderIdForNavigation});
            } else {
              Navigator.pushNamed(context, RoutesName.completeOrdersDetailsScreen, arguments: {'orderId': orderIdForNavigation});
            }
          } else if (datum.type == 'HOUSEKEEPER') {
            Navigator.pushNamed(context, RoutesName.confirmedScreen, arguments: {'trackingId': orderIdForNavigation});
          } else if (datum.type == 'BEAUTY_SALON') {
            Navigator.pushNamed(context, RoutesName.beautyConfirmedScreen, arguments: {'trackingId': orderIdForNavigation});
          }else if (datum.type == 'EVENT_COOKING') {
            Navigator.pushNamed(context, RoutesName.cookingConfirmedScreen, arguments: {'trackingId': orderIdForNavigation});
          }
        },
        child: Container(
          padding: EdgeInsets.all(screenHeight * 0.02),
          color: Colors.transparent,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(color: AppColors.hintColor(context).withOpacity(0.5), borderRadius: BorderRadius.circular(8)),
                          child: Icon(_getIconForType(datum.type), color: AppColors.textPrimary(context), size: 16),
                        ),
                        SizedboxSpaccing.width03(context),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                orderType,
                                style: AppTextStyles.textSize16(context, weight: FontWeight.w500, color: AppColors.textPrimary(context)),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                "Order #$shortOrderId",
                                style: AppTextStyles.textSize12(context, weight: FontWeight.w400, color: AppColors.subtitle(context)),
                              ),
                              if (datum.createdAt != null)
                                Text(
                                  DateTimeFormatter.formatRelativeDateTime(datum.createdAt!),
                                  style: AppTextStyles.textSize12(context, color: AppColors.subtitle(context), weight: FontWeight.w400),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: _getStatusColor(datum.status ?? '').withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                    child: Text(
                      datum.status ?? 'Unknown',
                      style: AppTextStyles.textSize10(context, color: _getStatusColor(datum.status ?? ''), weight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
              SizedboxSpaccing.height015(context),
              Divider(height: 1, color: AppColors.border(context)),
              Container(
                height: screenHeight * 0.04,
                color: Colors.transparent,
                alignment: Alignment.bottomCenter,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("৳${datum.total ?? 0}", style: AppTextStyles.textSize14(context, weight: FontWeight.w400)),
                    Row(
                      children: [
                        Text("View Details ", style: AppTextStyles.textSize14(context, weight: FontWeight.w400)),
                        SizedboxSpaccing.width01(context),
                        Icon(FontAwesomeIcons.arrowRight, size: 15),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildLoadMoreButton(BuildContext context, VoidCallback onPressed, bool isLoading) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: GestureDetector(
          onTap: isLoading ? null : onPressed, // Disable tap when loading
          child: Container(
            height: 50,
            width: screenWidth * 0.8,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                width: 1,
                color: AppColors.border(context),
              ),
              color: AppColors.containerBackground(context),
            ),
            child: Center(
              child: isLoading
                  ? LoadingAnimationWidget.progressiveDots(
                color: AppColors.button(context),
                size: 40,
              )
                  : Text(
                "Load More",
                style: AppTextStyles.textSize16(
                  context,
                  weight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  IconData _getIconForType(String? type) {
    switch (type) {
      case 'BEAUTY_SALON':
        return FontAwesomeIcons.scissors;
      case 'HOUSEKEEPER':
        return FontAwesomeIcons.broom;
      case 'ORDER':
        return FontAwesomeIcons.store;
      default:
        return FontAwesomeIcons.fileInvoice;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return AppColors.darkRedColor;
      case 'RUNNING':
        return AppColors.button(context);
      case 'COMPLETED':
        return AppColors.oceanGreenColor;
      case 'CANCELLED':
        return Color(0xFFDC2626);
      default:
        return Color(0xFF6B7280);
    }
  }
}
