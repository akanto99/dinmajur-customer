// import 'package:dinmajur_customer/configs/res/color.dart';
// import 'package:dinmajur_customer/configs/res/components/exception_errorstate/exception_errorstate.dart';
// import 'package:dinmajur_customer/configs/res/components/header_appbar.dart';
// import 'package:dinmajur_customer/configs/res/sizedbox_spaccing.dart';
// import 'package:dinmajur_customer/configs/res/text_styles.dart';
// import 'package:dinmajur_customer/configs/responsive/responsive_ui.dart';
// import 'package:dinmajur_customer/configs/services/sse_notification_services/sse_notification_and_ordercount/notification_count_view_model.dart';
// import 'package:dinmajur_customer/configs/services/sse_notification_services/sse_notification_service.dart';
// import 'package:dinmajur_customer/configs/utils/routes/routes_name.dart';
// import 'package:dinmajur_customer/data/response/status.dart';
// import 'package:dinmajur_customer/model/home_models/notification_model/get_notificationlist_model.dart';
// import 'package:dinmajur_customer/view_model/homeview_model/notification_view_model/notification_view_model.dart';
// import 'package:flutter/material.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:loading_animation_widget/loading_animation_widget.dart';
// import 'package:provider/provider.dart';
// import 'package:timeago/timeago.dart' as timeago;
//
// class NotificationsListScreen extends StatefulWidget {
//   const NotificationsListScreen({Key? key}) : super(key: key);
//
//   @override
//   State<NotificationsListScreen> createState() => _NotificationsListScreenState();
// }
//
// class _NotificationsListScreenState extends State<NotificationsListScreen> {
//   bool _sseListenerInitialized = false;
//   int _previousSSECount = 0;
//   bool _showNewNotificationBanner = false;
//
//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     if (!_sseListenerInitialized) {
//       _initializeSSECountListener();
//       _sseListenerInitialized = true;
//     }
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       Provider.of<GetNotificationViewModel>(context, listen: false).fetchLocationListApi();
//
//       // Get initial count
//       final countViewModel = Provider.of<NotificationCountViewModel>(context, listen: false);
//       _previousSSECount = countViewModel.notificationCount;
//     });
//   }
//
//   void _initializeSSECountListener() {
//     try {
//       final sseService = Provider.of<SSENotificationService>(context, listen: false);
//       final countViewModel = Provider.of<NotificationCountViewModel>(context, listen: false);
//
//       // Connect only count stream
//       countViewModel.initializeCountListener(sseService.notificationCountStream);
//
//       // Listen to count changes
//       countViewModel.addListener(_onSSECountChanged);
//     } catch (e) {
//       debugPrint('❌ NotificationScreen: Error initializing count listener: $e');
//     }
//   }
//
//   void _onSSECountChanged() {
//     final countViewModel = Provider.of<NotificationCountViewModel>(context, listen: false);
//     final currentCount = countViewModel.notificationCount;
//
//     debugPrint('🔔 SSE Count changed: $_previousSSECount -> $currentCount');
//
//     // Show banner if count increased (new notification arrived)
//     if (currentCount > _previousSSECount && currentCount > 0) {
//       setState(() {
//         _showNewNotificationBanner = true;
//       });
//     }
//
//     _previousSSECount = currentCount;
//   }
//
//   Future<void> _handleRefreshNotifications() async {
//     final viewModel = Provider.of<GetNotificationViewModel>(context, listen: false);
//     await viewModel.fetchLocationListApi();
//
//     setState(() {
//       _showNewNotificationBanner = false;
//     });
//   }
//
//   @override
//   void dispose() {
//     final countViewModel = Provider.of<NotificationCountViewModel>(context, listen: false);
//     countViewModel.removeListener(_onSSECountChanged);
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.containerBackground(context),
//       body: SafeArea(
//         child: ResPonsiveUi(mobile: body(), desktop: body(), tablet: body()),
//       ),
//     );
//   }
//
//   Widget body() {
//     final screenWidth = MediaQuery.of(context).size.width * 1;
//     final screenHeight = MediaQuery.of(context).size.height * 1;
//     return Column(
//       children: [
//         GestureDetector(
//           onTap: () {
//             Navigator.pop(context);
//           },
//           child: AppBarHeader("Notifications"),
//         ),
//
//         Expanded(
//           child: Consumer<GetNotificationViewModel>(
//             builder: (context, viewModel, child) {
//               switch (viewModel.notificationListData.status) {
//                 case Status.LOADING:
//                   return Center(child: LoadingAnimationWidget.progressiveDots(color: AppColors.button(context), size: 45));
//
//                 case Status.ERROR:
//                   return ErrorStateWidget(
//                     errorMessage: viewModel.notificationListData.message.toString(),
//                     onRetry: () {
//                       viewModel.fetchLocationListApi();
//                     },
//                   );
//
//                 case Status.COMPLETED:
//                   final notifications = viewModel.notificationListData.data?.data?.data ?? [];
//                   final meta = viewModel.notificationListData.data?.data?.meta;
//
//                   if (notifications.isEmpty) {
//                     return Column(
//                       children: [
//                         SizedBox(height: 20),
//                         Container(
//                           width: screenWidth * 0.9,
//                           height: 190,
//                           decoration: BoxDecoration(
//                             borderRadius: BorderRadius.circular(24),
//                             border: Border.all(width: 1, color: AppColors.border(context)),
//                           ),
//                           child: Column(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               Icon(Icons.notifications_none, size: 50, color: Colors.grey.shade400),
//                               SizedboxSpaccing.height02(context),
//                               Text(
//                                 'No Notifications',
//                                 style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.textPrimary(context)),
//                               ),
//                               SizedboxSpaccing.width03(context),
//                               Text('You\'re all caught up!', style: TextStyle(fontSize: 14, color: AppColors.textPrimary(context))),
//                             ],
//                           ),
//                         ),
//                       ],
//                     );
//                   }
//
//                   return RefreshIndicator(
//                     onRefresh: () async {
//                       await _handleRefreshNotifications();
//                     },
//                     child: Column(
//                       children: [
//                         SizedboxSpaccing.height025(context),
//                         // New Notification Banner
//                         Consumer<NotificationCountViewModel>(
//                           builder: (context, countViewModel, _) {
//                             if (_showNewNotificationBanner && countViewModel.hasNotifications) {
//                               return Column(
//                                 children: [
//                                   GestureDetector(
//                                     onTap: _handleRefreshNotifications,
//                                     child: Container(
//                                       width: screenWidth * 0.9,
//                                       padding: EdgeInsets.symmetric(horizontal: screenHeight * 0.02, vertical: 5),
//                                       decoration: BoxDecoration(gradient: LinearGradient(colors: [AppColors.button(context), AppColors.button(context).withOpacity(0.5)])),
//                                       child: Row(
//                                         mainAxisAlignment: MainAxisAlignment.center,
//                                         children: [
//                                           Container(
//                                             padding: const EdgeInsets.all(5),
//                                             decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
//                                             child: const Icon(Icons.notifications_active, color: Colors.white, size: 14),
//                                           ),
//                                           SizedboxSpaccing.width03(context),
//                                           Expanded(
//                                             child: Column(
//                                               crossAxisAlignment: CrossAxisAlignment.start,
//                                               children: [
//                                                 Text(
//                                                   'New Notifications',
//                                                   style: AppTextStyles.textSize14(context, color: AppColors.whiteColor, weight: FontWeight.w600),
//                                                 ),
//                                                 const SizedBox(height: 2),
//                                                 Text(
//                                                   'Tap to refresh and see updates',
//                                                   style: AppTextStyles.textSize12(context, color: AppColors.whiteColor, weight: FontWeight.w600),
//                                                 ),
//                                               ],
//                                             ),
//                                           ),
//                                           const Icon(FontAwesomeIcons.arrowUp, color: AppColors.whiteColor, size: 18),
//                                         ],
//                                       ),
//                                     ),
//                                   ),
//                                   SizedboxSpaccing.height02(context),
//                                 ],
//                               );
//                             }
//                             return const SizedBox.shrink();
//                           },
//                         ),
//
//                         // Unread Count Banner
//                         if (meta?.unreadCount != null && meta!.unreadCount! > 0)
//                           Container(
//                             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                             color: Colors.blue.shade50,
//                             child: Row(
//                               children: [
//                                 Icon(Icons.info_outline, size: 18, color: Colors.blue.shade700),
//                                 const SizedBox(width: 8),
//                                 Text(
//                                   'You have ${meta.unreadCount} unread notification${meta.unreadCount! > 1 ? 's' : ''}',
//                                   style: TextStyle(fontSize: 13, color: Colors.blue.shade700, fontWeight: FontWeight.w500),
//                                 ),
//                               ],
//                             ),
//                           ),
//
//                         // Notification List
//                         Expanded(
//                           child: ListView.separated(
//                             padding: EdgeInsets.symmetric(horizontal: screenHeight * 0.02),
//                             itemCount: notifications.length,
//                             separatorBuilder: (context, index) => const SizedBox(height: 12),
//                             itemBuilder: (context, index) {
//                               final notification = notifications[index];
//                               return _buildNotificationCard(notification, screenHeight, screenWidth);
//                             },
//                           ),
//                         ),
//                         SizedboxSpaccing.height025(context),
//                       ],
//                     ),
//                   );
//
//                 default:
//                   return const SizedBox.shrink();
//               }
//             },
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildNotificationCard(Datum notification, double screenWidth, double screenHeight) {
//     final isUnread = notification.read == false;
//     String orderIdForNavigation = '';
//     String? status;
//
//     if (notification.source == 'DELIVERY') {
//       orderIdForNavigation = notification.data?.params?.orderId ?? '';
//       status = notification.data?.status;
//     } else if (notification.source == 'BEAUTY_SALON') {
//       orderIdForNavigation = notification.data?.params?.beautySalonBookingId ?? '';
//       status = notification.data?.status;
//     } else if (notification.source == 'HOUSE_KEEPER') {
//       orderIdForNavigation = notification.data?.params?.houseKeeperBookingId ?? '';
//       status = notification.data?.status;
//     } else if (notification.source == 'EVENT_COOKING') {
//       orderIdForNavigation = notification.data?.params?.eventCookingBookingId ?? '';
//       status = notification.data?.status;
//     }
//
//     return GestureDetector(
//       onTap: () {
//         if (notification.source == 'DELIVERY') {
//           // For grocery orders
//           if (status == 'PENDING' || status == 'RUNNING' || status == 'ARRIVED_DESTINATION' || status == 'PICKED_UP') {
//             Navigator.pushNamed(context, RoutesName.trackOrderViewdetailsSocketScreen, arguments: {'orderId': orderIdForNavigation});
//           } else {
//             Navigator.pushNamed(context, RoutesName.completeOrdersDetailsScreen, arguments: {'orderId': orderIdForNavigation});
//           }
//         } else if (notification.source == 'HOUSE_KEEPER') {
//           Navigator.pushNamed(context, RoutesName.confirmedScreen, arguments: {'trackingId': orderIdForNavigation});
//         } else if (notification.source == 'BEAUTY_SALON') {
//           Navigator.pushNamed(context, RoutesName.beautyConfirmedScreen, arguments: {'trackingId': orderIdForNavigation});
//         } else if (notification.source == 'EVENT_COOKING') {
//           Navigator.pushNamed(context, RoutesName.cookingConfirmedScreen, arguments: {'trackingId': orderIdForNavigation});
//         }
//       },
//       child: Container(
//         decoration: BoxDecoration(
//           color: isUnread ? (Theme.of(context).brightness == Brightness.dark ? AppColors.button(context).withOpacity(0.5) : Colors.blue.shade50) : AppColors.containerBackground(context),
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(color: isUnread ? Colors.blue.shade100 : AppColors.border(context), width: 1),
//         ),
//         child: Padding(
//           padding: EdgeInsets.symmetric(horizontal: screenHeight * 0.02, vertical: screenHeight * 0.02),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   _getNotificationIcon(notification.source ?? ''),
//                   SizedboxSpaccing.width03(context),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Row(
//                           children: [
//                             Expanded(
//                               child: Text(
//                                 notification.data?.title ?? '',
//                                 style: AppTextStyles.textSize14(context, color: AppColors.textPrimary(context), weight: FontWeight.w500),
//                               ),
//                             ),
//                             // if (isUnread)
//                             //   Container(
//                             //     width: 8,
//                             //     height: 8,
//                             //     decoration: BoxDecoration(color: Colors.blue.shade600, shape: BoxShape.circle),
//                             //   ),
//                             if (notification.priority != null && notification.priority!.isNotEmpty) ...[
//                               const SizedBox(width: 12),
//                               Container(
//                                 padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
//                                 decoration: BoxDecoration(color: _getPriorityColor(notification.priority!), borderRadius: BorderRadius.circular(4)),
//                                 child: Text(
//                                   notification.priority!.toUpperCase(),
//                                   style: AppTextStyles.textSize10(context, color: AppColors.whiteColor, weight: FontWeight.w600),
//                                 ),
//                               ),
//                             ],
//                           ],
//                         ),
//
//                         Text(
//                           notification.message ?? 'No message',
//                           style: AppTextStyles.textSize12(context, color: AppColors.textPrimary(context), weight: FontWeight.w400),
//                         ),
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Row(
//                               children: [
//                                 Icon(Icons.access_time, size: 14, color: Colors.grey.shade500),
//                                 const SizedBox(width: 4),
//                                 Text(
//                                   notification.createdAt != null ? timeago.format(notification.createdAt!) : 'Unknown time',
//                                   style: AppTextStyles.textSize12(context, color: Colors.grey.shade600, weight: FontWeight.w500),
//                                 ),
//                               ],
//                             ),
//                             Text(
//                               _formatStatus(notification.data?.status ?? ''),
//                               style: AppTextStyles.textSize12(context, color: _getStatusColor(notification.data?.status ?? ''), weight: FontWeight.w400),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   String _formatStatus(String status) {
//     if (status.isEmpty) return '';
//
//     switch (status.toUpperCase()) {
//       case 'PENDING':
//         return 'Pending';
//       case 'ARRIVED_DESTINATION':
//         return 'Arrived';
//       case 'CONFIRMED':
//         return 'Confirmed';
//       case 'PICKED_UP':
//         return 'Picked Up';
//       case 'DELIVERED':
//         return 'Delivered';
//       case 'COMPLETED':
//         return 'Completed';
//       default:
//         return '';
//     }
//   }
//
//   Color _getStatusColor(String status) {
//     switch (status.toUpperCase()) {
//       case 'PENDING':
//         return Colors.orange;
//       case 'ARRIVED_DESTINATION':
//         return Colors.blue;
//       case 'CONFIRMED':
//         return Colors.green;
//       case 'PICKED_UP':
//         return Colors.purple;
//       case 'DELIVERED':
//         return Colors.teal;
//       case 'COMPLETED':
//         return Colors.green.shade700;
//       default:
//         return Colors.grey;
//     }
//   }
//
//   Widget _getNotificationIcon(String source) {
//     IconData icon;
//     Color color;
//
//     switch (source.toUpperCase()) {
//       case 'DELIVERY':
//         icon = Icons.shopping_bag;
//         color = AppColors.textPrimary(context);
//         break;
//       case 'HOUSE_KEEPER':
//         icon = Icons.cleaning_services;
//         color = AppColors.textPrimary(context);
//         break;
//       case 'BEAUTY_SALON':
//         icon = Icons.spa;
//         color = AppColors.textPrimary(context);
//         break;
//       case 'EVENT_COOKING':
//         icon = Icons.restaurant_menu;
//         color = AppColors.textPrimary(context);
//         break;
//       case 'PROMOTION':
//         icon = Icons.local_offer;
//         color = Colors.purple;
//         break;
//       case 'OFFER':
//         icon = Icons.discount;
//         color = Colors.orange;
//         break;
//       default:
//         icon = Icons.notifications;
//         color = Colors.grey;
//     }
//
//     return Container(
//       padding: const EdgeInsets.all(8),
//       decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(5)),
//       child: Icon(icon, size: 24, color: color),
//     );
//   }
//
//   Color _getPriorityColor(String priority) {
//     switch (priority.toLowerCase()) {
//       case 'high':
//         return Colors.red;
//       case 'medium':
//         return Colors.orange;
//       case 'low':
//         return Colors.blue;
//       default:
//         return Colors.grey;
//     }
//   }
// }
import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/components/exception_errorstate/exception_errorstate.dart';
import 'package:dinmajur_customer/configs/res/components/header_appbar.dart';
import 'package:dinmajur_customer/configs/res/sizedbox_spaccing.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:dinmajur_customer/configs/responsive/responsive_ui.dart';
import 'package:dinmajur_customer/configs/services/sse_notification_services/sse_notification_and_ordercount/notification_count_view_model.dart';
import 'package:dinmajur_customer/configs/services/sse_notification_services/sse_notification_service.dart';
import 'package:dinmajur_customer/configs/utils/routes/routes_name.dart';
import 'package:dinmajur_customer/data/response/status.dart';
import 'package:dinmajur_customer/model/home_models/notification_model/get_notificationlist_model.dart';
import 'package:dinmajur_customer/view_model/homeview_model/notification_view_model/notification_view_model.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

class NotificationsListScreen extends StatefulWidget {
  const NotificationsListScreen({Key? key}) : super(key: key);

  @override
  State<NotificationsListScreen> createState() => _NotificationsListScreenState();
}

class _NotificationsListScreenState extends State<NotificationsListScreen> {
  bool _sseListenerInitialized = false;
  int _previousSSECount = 0;
  bool _showNewNotificationBanner = false;
  int _selectedTabIndex = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_sseListenerInitialized) {
      _initializeSSECountListener();
      _sseListenerInitialized = true;
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<GetNotificationViewModel>(context, listen: false).fetchLocationListApi();

      final countViewModel = Provider.of<NotificationCountViewModel>(context, listen: false);
      _previousSSECount = countViewModel.notificationCount;
    });
  }

  void _initializeSSECountListener() {
    try {
      final sseService = Provider.of<SSENotificationService>(context, listen: false);
      final countViewModel = Provider.of<NotificationCountViewModel>(context, listen: false);

      countViewModel.initializeCountListener(sseService.notificationCountStream);
      countViewModel.addListener(_onSSECountChanged);
    } catch (e) {
      debugPrint('❌ NotificationScreen: Error initializing count listener: $e');
    }
  }

  void _onSSECountChanged() {
    final countViewModel = Provider.of<NotificationCountViewModel>(context, listen: false);
    final currentCount = countViewModel.notificationCount;

    debugPrint('🔔 SSE Count changed: $_previousSSECount -> $currentCount');

    if (currentCount > _previousSSECount && currentCount > 0) {
      setState(() {
        _showNewNotificationBanner = true;
      });
    }

    _previousSSECount = currentCount;
  }

  Future<void> _handleRefreshNotifications() async {
    final viewModel = Provider.of<GetNotificationViewModel>(context, listen: false);
    await viewModel.fetchLocationListApi();

    setState(() {
      _showNewNotificationBanner = false;
    });
  }

  List<Datum> _filterNotifications(List<Datum> notifications, int tabIndex) {
    switch (tabIndex) {
      case 1: // Promotions
        return notifications.where((n) => n.source?.toUpperCase() == 'PROMOTION').toList();
      case 2: // Offers
        return notifications.where((n) => n.source?.toUpperCase() == 'OFFER').toList();
      default: // All
        return notifications;
    }
  }

  String _getFilterType(int tabIndex) {
    switch (tabIndex) {
      case 1:
        return 'PROMOTION';
      case 2:
        return 'OFFER';
      default:
        return 'ALL';
    }
  }

  @override
  void dispose() {
    final countViewModel = Provider.of<NotificationCountViewModel>(context, listen: false);
    countViewModel.removeListener(_onSSECountChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.containerBackground(context),
      body: SafeArea(
        child: ResPonsiveUi(mobile: body(), desktop: body(), tablet: body()),
      ),
    );
  }

  Widget body() {
    final screenWidth = MediaQuery.of(context).size.width * 1;
    final screenHeight = MediaQuery.of(context).size.height * 1;

    return Column(
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: AppBarHeader("Notifications"),
        ),

        SizedboxSpaccing.height02(context),

        Container(
         width: screenWidth*0.9,
          alignment: Alignment.centerLeft,
          child: Container(
            width: screenWidth*0.6,
            height: 35,
            decoration: BoxDecoration(
              color: AppColors.containerBackground(context),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.border(context), width: 1),
            ),
            child: Row(
              children: [
                _buildCustomTab('All', 0),
                _buildCustomTab('Promo', 1),
                _buildCustomTab('Offers', 2),
              ],
            ),
          ),
        ),

        Expanded(
          child: Consumer<GetNotificationViewModel>(
            builder: (context, viewModel, child) {
              switch (viewModel.notificationListData.status) {
                case Status.LOADING:
                  return Center(
                    child: LoadingAnimationWidget.progressiveDots(
                      color: AppColors.button(context),
                      size: 45,
                    ),
                  );

                case Status.ERROR:
                  return ErrorStateWidget(
                    errorMessage: viewModel.notificationListData.message.toString(),
                    onRetry: () => viewModel.fetchLocationListApi(),
                  );

                case Status.COMPLETED:
                  final allNotifications = viewModel.notificationListData.data?.data?.data ?? [];
                  final meta = viewModel.notificationListData.data?.data?.meta;
                  final filteredNotifications = _filterNotifications(allNotifications, _selectedTabIndex);

                  return _buildNotificationList(
                    filteredNotifications,
                    meta,
                    screenWidth,
                    screenHeight,
                    _getFilterType(_selectedTabIndex),
                  );

                default:
                  return const SizedBox.shrink();
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCustomTab(String title, int index) {
    final isSelected = _selectedTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTabIndex = index;
          });
        },
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? AppColors.button(context) : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Center(
            child: Text(
              title,
              style: AppTextStyles.textSize14(
                context,
                weight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? Colors.white : AppColors.textPrimary(context),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationList(
      List<Datum> notifications,
      Meta? meta,
      double screenWidth,
      double screenHeight,
      String filterType,
      ) {
    if (notifications.isEmpty) {
      return Column(
        children: [
          SizedboxSpaccing.height02(context),
          Container(
            width: screenWidth * 0.9,
            height: 190,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(width: 1, color: AppColors.border(context)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  filterType == 'PROMOTION'
                      ? Icons.local_offer
                      : filterType == 'OFFER'
                      ? Icons.discount
                      : Icons.notifications_none,
                  size: 40,
                  color: Colors.grey.shade400,
                ),
                SizedboxSpaccing.height02(context),
                Text(
                  filterType == 'ALL'
                      ? 'No Notifications'
                      : filterType == 'PROMOTION'
                      ? 'No Promotions'
                      : 'No Offers',
                  style: AppTextStyles.textSize16(context,weight: FontWeight.w600,   color: AppColors.textPrimary(context),),
                ),
                SizedboxSpaccing.width03(context),
                Text(
                  'You\'re all caught up!',
                  style: AppTextStyles.textSize14(context,weight: FontWeight.w400,   color: AppColors.textPrimary(context),),

                ),
              ],
            ),
          ),
        ],
      );
    }

    return RefreshIndicator(
      onRefresh: _handleRefreshNotifications,
      child: Column(
        children: [
          SizedboxSpaccing.height02(context),

          // New Notification Banner (only show on "All" tab)
          if (filterType == 'ALL')
            Consumer<NotificationCountViewModel>(
              builder: (context, countViewModel, _) {
                if (_showNewNotificationBanner && countViewModel.hasNotifications) {
                  return Column(
                    children: [
                      GestureDetector(
                        onTap: _handleRefreshNotifications,
                        child: Container(
                          width: screenWidth * 0.9,
                          padding: EdgeInsets.symmetric(
                            horizontal: screenHeight * 0.02,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.button(context),
                                AppColors.button(context).withOpacity(0.5),
                              ],
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.notifications_active,
                                  color: Colors.white,
                                  size: 14,
                                ),
                              ),
                              SizedboxSpaccing.width03(context),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'New Notifications',
                                      style: AppTextStyles.textSize14(
                                        context,
                                        color: AppColors.whiteColor,
                                        weight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Tap to refresh and see updates',
                                      style: AppTextStyles.textSize12(
                                        context,
                                        color: AppColors.whiteColor,
                                        weight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                FontAwesomeIcons.arrowUp,
                                color: AppColors.whiteColor,
                                size: 18,
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedboxSpaccing.height02(context),
                    ],
                  );
                }
                return const SizedBox.shrink();
              },
            ),

          // Unread Count Banner (only show on "All" tab)
          if (filterType == 'ALL' && meta?.unreadCount != null && meta!.unreadCount! > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.blue.shade50,
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 18, color: Colors.blue.shade700),
                  const SizedBox(width: 8),
                  Text(
                    'You have ${meta.unreadCount} unread notification${meta.unreadCount! > 1 ? 's' : ''}',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.blue.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

          // Notification List
          Expanded(
            child: Container(
              width: screenWidth*0.9,
              child: ListView.separated(
                itemCount: notifications.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final notification = notifications[index];
                  return _buildNotificationCard(notification, screenHeight, screenWidth);
                },
              ),
            ),
          ),
          SizedboxSpaccing.height025(context),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(Datum notification, double screenWidth, double screenHeight) {
    final isUnread = notification.read == false;
    String orderIdForNavigation = '';
    String? status;

    if (notification.source == 'DELIVERY') {
      orderIdForNavigation = notification.data?.params?.orderId ?? '';
      status = notification.data?.status;
    } else if (notification.source == 'BEAUTY_SALON') {
      orderIdForNavigation = notification.data?.params?.beautySalonBookingId ?? '';
      status = notification.data?.status;
    } else if (notification.source == 'HOUSE_KEEPER') {
      orderIdForNavigation = notification.data?.params?.houseKeeperBookingId ?? '';
      status = notification.data?.status;
    } else if (notification.source == 'EVENT_COOKING') {
      orderIdForNavigation = notification.data?.params?.eventCookingBookingId ?? '';
      status = notification.data?.status;
    }

    return GestureDetector(
      onTap: () {
        if (notification.source == 'DELIVERY') {
          if (status == 'PENDING' || status == 'RUNNING' || status == 'ARRIVED_DESTINATION' || status == 'PICKED_UP') {
            Navigator.pushNamed(
              context,
              RoutesName.trackOrderViewdetailsSocketScreen,
              arguments: {'orderId': orderIdForNavigation},
            );
          } else {
            Navigator.pushNamed(
              context,
              RoutesName.completeOrdersDetailsScreen,
              arguments: {'orderId': orderIdForNavigation},
            );
          }
        } else if (notification.source == 'HOUSE_KEEPER') {
          Navigator.pushNamed(
            context,
            RoutesName.confirmedScreen,
            arguments: {'trackingId': orderIdForNavigation},
          );
        } else if (notification.source == 'BEAUTY_SALON') {
          Navigator.pushNamed(
            context,
            RoutesName.beautyConfirmedScreen,
            arguments: {'trackingId': orderIdForNavigation},
          );
        } else if (notification.source == 'EVENT_COOKING') {
          Navigator.pushNamed(
            context,
            RoutesName.cookingConfirmedScreen,
            arguments: {'trackingId': orderIdForNavigation},
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: isUnread
              ? (Theme.of(context).brightness == Brightness.dark
              ? AppColors.button(context).withOpacity(0.5)
              : Colors.blue.shade50)
              : AppColors.containerBackground(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isUnread ? Colors.blue.shade100 : AppColors.border(context),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.black.withOpacity(0.3)
                  : Colors.grey.withOpacity(0.05),
              spreadRadius: 0,
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
            // Optional: Add a subtle second shadow for more depth
            BoxShadow(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.black.withOpacity(0.2)
                  : Colors.grey.withOpacity(0.08),
              spreadRadius: 0,
              blurRadius: 4,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: screenHeight * 0.02,
            vertical: screenHeight * 0.02,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _getNotificationIcon(notification.source ?? ''),
                  SizedboxSpaccing.width03(context),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                notification.data?.title ?? '',
                                style: AppTextStyles.textSize14(
                                  context,
                                  color: AppColors.textPrimary(context),
                                  weight: FontWeight.w500,
                                ),
                              ),
                            ),
                            if (notification.priority != null && notification.priority!.isNotEmpty) ...[
                              const SizedBox(width: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: _getPriorityColor(notification.priority!),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  notification.priority!.toUpperCase(),
                                  style: AppTextStyles.textSize10(
                                    context,
                                    color: AppColors.whiteColor,
                                    weight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        Text(
                          notification.message ?? 'No message',
                          style: AppTextStyles.textSize12(
                            context,
                            color: AppColors.textPrimary(context),
                            weight: FontWeight.w400,
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.access_time, size: 14, color: Colors.grey.shade500),
                                const SizedBox(width: 4),
                                Text(
                                  notification.createdAt != null
                                      ? timeago.format(notification.createdAt!)
                                      : 'Unknown time',
                                  style: AppTextStyles.textSize12(
                                    context,
                                    color: Colors.grey.shade600,
                                    weight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              _formatStatus(notification.data?.status ?? ''),
                              style: AppTextStyles.textSize12(
                                context,
                                color: _getStatusColor(notification.data?.status ?? ''),
                                weight: FontWeight.w400,
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
          ),
        ),
      ),
    );
  }

  String _formatStatus(String status) {
    if (status.isEmpty) return '';

    switch (status.toUpperCase()) {
      case 'PENDING':
        return 'Pending';
      case 'ARRIVED_DESTINATION':
        return 'Arrived';
      case 'CONFIRMED':
        return 'Confirmed';
      case 'PICKED_UP':
        return 'Picked Up';
      case 'DELIVERED':
        return 'Delivered';
      case 'COMPLETED':
        return 'Completed';
      default:
        return '';
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return Colors.orange;
      case 'ARRIVED_DESTINATION':
        return Colors.blue;
      case 'CONFIRMED':
        return Colors.green;
      case 'PICKED_UP':
        return Colors.purple;
      case 'DELIVERED':
        return Colors.teal;
      case 'COMPLETED':
        return Colors.green.shade700;
      default:
        return Colors.grey;
    }
  }

  Widget _getNotificationIcon(String source) {
    IconData icon;
    Color color;

    switch (source.toUpperCase()) {
      case 'DELIVERY':
        icon = Icons.shopping_bag;
        color = AppColors.textPrimary(context);
        break;
      case 'HOUSE_KEEPER':
        icon = Icons.cleaning_services;
        color = AppColors.textPrimary(context);
        break;
      case 'BEAUTY_SALON':
        icon = Icons.spa;
        color = AppColors.textPrimary(context);
        break;
      case 'EVENT_COOKING':
        icon = Icons.restaurant_menu;
        color = AppColors.textPrimary(context);
        break;
      case 'PROMOTION':
        icon = Icons.local_offer;
        color = Colors.purple;
        break;
      case 'OFFER':
        icon = Icons.discount;
        color = Colors.orange;
        break;
      default:
        icon = Icons.notifications;
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Icon(icon, size: 24, color: color),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}