///Corrected

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
//   int _selectedTabIndex = 0;
//
//   NotificationCountViewModel? _countViewModel;
//
//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     if (!_sseListenerInitialized) {
//       _countViewModel = Provider.of<NotificationCountViewModel>(context, listen: false);
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
//       final countViewModel = _countViewModel ?? Provider.of<NotificationCountViewModel>(context, listen: false);
//       _previousSSECount = countViewModel.notificationCount;
//     });
//   }
//
//   void _initializeSSECountListener() {
//     try {
//       if (_countViewModel == null) {
//         debugPrint('❌ NotificationScreen: ViewModel not initialized');
//         return;
//       }
//
//       if (!_countViewModel!.isInitialized) {
//         final sseService = Provider.of<SSENotificationService>(context, listen: false);
//         _countViewModel!.initializeCountListener(sseService.notificationCountStream, sseService.notificationIncrementStream);
//       }
//
//       _countViewModel!.addListener(_onSSECountChanged);
//
//       debugPrint('✅ NotificationScreen: SSE listener initialized');
//     } catch (e) {
//       debugPrint('❌ NotificationScreen: Error initializing count listener: $e');
//     }
//   }
//
//   void _onSSECountChanged() {
//     if (!mounted) {
//       debugPrint('⚠️ NotificationScreen: Widget disposed, ignoring count change');
//       return;
//     }
//
//     if (_countViewModel == null) {
//       debugPrint('⚠️ NotificationScreen: ViewModel is null');
//       return;
//     }
//
//     final currentCount = _countViewModel!.notificationCount;
//
//     debugPrint('🔔 SSE Count changed: $_previousSSECount -> $currentCount');
//
//     if (currentCount > _previousSSECount && currentCount > 0) {
//       if (mounted) {
//         setState(() {
//           _showNewNotificationBanner = true;
//         });
//       }
//     }
//
//     _previousSSECount = currentCount;
//   }
//
//   Future<void> _handleRefreshNotifications() async {
//     final viewModel = Provider.of<GetNotificationViewModel>(context, listen: false);
//     final type = _selectedTabIndex == 1 ? 'PROMOTION' : null;
//     await viewModel.fetchLocationListApi(type: type);
//
//     if (mounted) {
//       setState(() {
//         _showNewNotificationBanner = false;
//       });
//     }
//   }
//
//   void _onTabChanged(int index) {
//     setState(() {
//       _selectedTabIndex = index;
//     });
//
//     final viewModel = Provider.of<GetNotificationViewModel>(context, listen: false);
//     final type = index == 1 ? 'PROMOTION' : null;
//     viewModel.fetchLocationListApi(type: type);
//   }
//
//   String _getFilterType(int tabIndex) {
//     switch (tabIndex) {
//       case 1:
//         return 'PROMOTION';
//       default:
//         return 'ALL';
//     }
//   }
//
//   @override
//   void dispose() {
//     debugPrint('🔴 NotificationScreen: Disposing...');
//
//     if (_countViewModel != null) {
//       _countViewModel!.removeListener(_onSSECountChanged);
//       debugPrint('✅ NotificationScreen: Listener removed');
//     }
//
//     _countViewModel = null;
//
//     super.dispose();
//     debugPrint('✅ NotificationScreen: Disposed successfully');
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
//
//     return Column(
//       children: [
//         GestureDetector(onTap: () => Navigator.pop(context), child: AppBarHeader("Notifications")),
//
//         SizedboxSpaccing.height02(context),
//
//         Container(
//           width: screenWidth * 0.9,
//           alignment: Alignment.centerLeft,
//           child: Container(
//             width: screenWidth * 0.45,
//             height: 35,
//             decoration: BoxDecoration(
//               color: AppColors.containerBackground(context),
//               borderRadius: BorderRadius.circular(6),
//               border: Border.all(color: AppColors.border(context), width: 1),
//             ),
//             child: Row(children: [_buildCustomTab('All', 0), _buildCustomTab('Promo', 1)]),
//           ),
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
//                       final type = _selectedTabIndex == 1 ? 'PROMOTION' : null;
//                       viewModel.fetchLocationListApi(type: type);
//                     },
//                   );
//
//                 case Status.COMPLETED:
//                   final allNotifications = viewModel.notificationListData.data?.data ?? [];
//                   final meta = viewModel.notificationListData.data?.meta;
//
//                   return _buildNotificationList(allNotifications, meta, screenWidth, screenHeight, _getFilterType(_selectedTabIndex));
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
//   Widget _buildCustomTab(String title, int index) {
//     final isSelected = _selectedTabIndex == index;
//     return Expanded(
//       child: GestureDetector(
//         onTap: () => _onTabChanged(index),
//         child: Container(
//           decoration: BoxDecoration(color: isSelected ? AppColors.button(context) : Colors.transparent, borderRadius: BorderRadius.circular(6)),
//           child: Center(
//             child: Text(
//               title,
//               style: AppTextStyles.textSize14(context, weight: isSelected ? FontWeight.w600 : FontWeight.w500, color: isSelected ? Colors.white : AppColors.textPrimary(context)),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildNotificationList(List<Datum> notifications, Meta? meta, double screenWidth, double screenHeight, String filterType) {
//     if (notifications.isEmpty) {
//       return Column(
//         children: [
//           SizedboxSpaccing.height02(context),
//           Container(
//             width: screenWidth * 0.9,
//             height: 190,
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(12),
//               border: Border.all(width: 1, color: AppColors.border(context)),
//             ),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(filterType == 'PROMOTION' ? Icons.local_offer : Icons.notifications_none, size: 40, color: Colors.grey.shade400),
//                 SizedboxSpaccing.height02(context),
//                 Text(
//                   filterType == 'ALL' ? 'No Notifications' : 'No Promotions',
//                   style: AppTextStyles.textSize16(context, weight: FontWeight.w600, color: AppColors.textPrimary(context)),
//                 ),
//                 SizedboxSpaccing.width03(context),
//                 Text(
//                   'You\'re all caught up!',
//                   style: AppTextStyles.textSize14(context, weight: FontWeight.w400, color: AppColors.textPrimary(context)),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       );
//     }
//
//     return RefreshIndicator(
//       onRefresh: _handleRefreshNotifications,
//       child: Column(
//         children: [
//           SizedboxSpaccing.height02(context),
//
//           // New Notification Banner (only show on "All" tab)
//           if (filterType == 'ALL')
//             Consumer<NotificationCountViewModel>(
//               builder: (context, countViewModel, _) {
//                 if (_showNewNotificationBanner && countViewModel.hasNotifications) {
//                   return Column(
//                     children: [
//                       GestureDetector(
//                         onTap: _handleRefreshNotifications,
//                         child: Container(
//                           width: screenWidth * 0.9,
//                           padding: EdgeInsets.symmetric(horizontal: screenHeight * 0.02, vertical: 5),
//                           decoration: BoxDecoration(gradient: LinearGradient(colors: [AppColors.button(context), AppColors.button(context).withOpacity(0.5)])),
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               Container(
//                                 padding: const EdgeInsets.all(5),
//                                 decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
//                                 child: const Icon(Icons.notifications_active, color: Colors.white, size: 14),
//                               ),
//                               SizedboxSpaccing.width03(context),
//                               Expanded(
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Text(
//                                       'New Notifications',
//                                       style: AppTextStyles.textSize14(context, color: AppColors.whiteColor, weight: FontWeight.w600),
//                                     ),
//                                     const SizedBox(height: 2),
//                                     Text(
//                                       'Tap to refresh and see updates',
//                                       style: AppTextStyles.textSize12(context, color: AppColors.whiteColor, weight: FontWeight.w600),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                               const Icon(FontAwesomeIcons.arrowUp, color: AppColors.whiteColor, size: 18),
//                             ],
//                           ),
//                         ),
//                       ),
//                       SizedboxSpaccing.height02(context),
//                     ],
//                   );
//                 }
//                 return const SizedBox.shrink();
//               },
//             ),
//           // if (filterType == 'ALL' && meta?.unreadCount != null && meta!.unreadCount! > 0)
//           //   Container(
//           //     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//           //     color: Colors.blue.shade50,
//           //     child: Row(
//           //       children: [
//           //         Icon(Icons.info_outline, size: 18, color: Colors.blue.shade700),
//           //         const SizedBox(width: 8),
//           //         Text(
//           //           'You have ${meta.unreadCount} unread notification${meta.unreadCount! > 1 ? 's' : ''}',
//           //           style: TextStyle(
//           //             fontSize: 13,
//           //             color: Colors.blue.shade700,
//           //             fontWeight: FontWeight.w500,
//           //           ),
//           //         ),
//           //       ],
//           //     ),
//           //   ),
//           // Notification List
//           Expanded(
//             child: Container(
//               width: screenWidth * 0.9,
//               child: ListView.separated(
//                 itemCount: notifications.length,
//                 separatorBuilder: (context, index) => const SizedBox(height: 12),
//                 itemBuilder: (context, index) {
//                   final notification = notifications[index];
//                   return _buildNotificationCard(notification, screenHeight, screenWidth);
//                 },
//               ),
//             ),
//           ),
//           SizedboxSpaccing.height025(context),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildNotificationCard(Datum notification, double screenWidth, double screenHeight) {
//     final isUnread = notification.read == false;
//     String trackingId = notification.data?.trackingId ?? '';
//     String? status = notification.data?.status;
//
//     // Check if notification is tappable
//     final isTappable = notification.type == 'ORDER' || notification.type == 'HOUSE_KEEPER_BOOKING' || notification.type == 'BEAUTY_SALON_BOOKING' || notification.type == 'EVENT_COOKING_BOOKING';
//     return GestureDetector(
//       onTap: isTappable
//           ? () {
//               if (notification.type == 'ORDER') {
//                 if (status == 'PENDING' || status == 'RUNNING' || status == 'ARRIVED_DESTINATION' || status == 'PICKED_UP') {
//                   Navigator.pushNamed(context, RoutesName.trackOrderViewdetailsSocketScreen, arguments: {'orderId': trackingId});
//                 } else {
//                   Navigator.pushNamed(context, RoutesName.completeOrdersDetailsScreen, arguments: {'orderId': trackingId});
//                 }
//               } else if (notification.type == 'HOUSE_KEEPER_BOOKING') {
//                 Navigator.pushNamed(context, RoutesName.confirmedScreen, arguments: {'trackingId': trackingId});
//               } else if (notification.type == 'BEAUTY_SALON_BOOKING') {
//                 Navigator.pushNamed(context, RoutesName.beautyConfirmedScreen, arguments: {'trackingId': trackingId});
//               } else if (notification.type == 'EVENT_COOKING_BOOKING') {
//                 Navigator.pushNamed(context, RoutesName.cookingConfirmedScreen, arguments: {'trackingId': trackingId});
//               }
//             }
//           : null,
//       child: Container(
//         decoration: BoxDecoration(
//           color: isUnread ? (Theme.of(context).brightness == Brightness.dark ? AppColors.button(context).withOpacity(0.5) : Colors.blue.shade50) : AppColors.containerBackground(context),
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(color: isUnread ? Colors.blue.shade100 : AppColors.border(context), width: 1),
//           boxShadow: [
//             BoxShadow(color: Theme.of(context).brightness == Brightness.dark ? Colors.black.withOpacity(0.3) : Colors.grey.withOpacity(0.05), spreadRadius: 0, blurRadius: 8, offset: Offset(0, 2)),
//             BoxShadow(color: Theme.of(context).brightness == Brightness.dark ? Colors.black.withOpacity(0.2) : Colors.grey.withOpacity(0.08), spreadRadius: 0, blurRadius: 4, offset: Offset(0, 1)),
//           ],
//         ),
//         child: Padding(
//           padding: EdgeInsets.symmetric(horizontal: screenHeight * 0.02, vertical: screenHeight * 0.02),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   _getNotificationIcon(notification.type ?? ''),
//                   SizedboxSpaccing.width03(context),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         if (notification.title != null && notification.title!.isNotEmpty)
//                           Row(
//                             children: [
//                               Expanded(
//                                 child: Text(
//                                   notification.title!,
//                                   style: AppTextStyles.textSize14(context, color: AppColors.textPrimary(context), weight: FontWeight.w500),
//                                 ),
//                               ),
//                               if (_shouldShowViewBadge(notification.type)) ...[
//                                 const SizedBox(width: 12),
//                                 Container(
//                                   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
//                                   decoration: BoxDecoration(color: AppColors.button(context), borderRadius: BorderRadius.circular(4)),
//                                   child: Text(
//                                     'VIEW',
//                                     style: AppTextStyles.textSize10(context, color: AppColors.whiteColor, weight: FontWeight.w600),
//                                   ),
//                                 ),
//                               ],
//                             ],
//                           ),
//                         Row(
//                           children: [
//                             Expanded(
//                               child: Text(
//                                 notification.message ?? 'No message',
//                                 style: AppTextStyles.textSize12(context, color: AppColors.textPrimary(context), weight: FontWeight.w400),
//                               ),
//                             ),
//                             if ((notification.title == null || notification.title!.isEmpty) && _shouldShowViewBadge(notification.type)) ...[
//                               const SizedBox(width: 8),
//                               Container(
//                                 padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
//                                 decoration: BoxDecoration(color: AppColors.button(context), borderRadius: BorderRadius.circular(4)),
//                                 child: Text(
//                                   'VIEW',
//                                   style: AppTextStyles.textSize10(context, color: AppColors.whiteColor, weight: FontWeight.w600),
//                                 ),
//                               ),
//                             ],
//                           ],
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
//   bool _shouldShowViewBadge(String? type) {
//     if (type == null) return false;
//     return type == 'ORDER' || type == 'HOUSE_KEEPER_BOOKING' || type == 'BEAUTY_SALON_BOOKING' || type == 'EVENT_COOKING_BOOKING';
//   }
//
//   Widget _getNotificationIcon(String type) {
//     IconData icon;
//     Color color;
//
//     switch (type.toUpperCase()) {
//       case 'SYSTEM':
//         icon = Icons.settings;
//         color = Colors.blueGrey;
//         break;
//       case 'ORDER':
//         icon = Icons.shopping_bag;
//         color = Colors.blue;
//         break;
//       case 'HOUSE_KEEPER_BOOKING':
//         icon = Icons.cleaning_services;
//         color = Colors.teal;
//         break;
//       case 'BEAUTY_SALON_BOOKING':
//         icon = Icons.spa;
//         color = Colors.pink;
//         break;
//       case 'EVENT_COOKING_BOOKING':
//         icon = Icons.restaurant_menu;
//         color = Colors.orange;
//         break;
//       case 'PROMOTION':
//         icon = Icons.local_offer;
//         color = Colors.purple;
//         break;
//       case 'SPECIAL_OFFER':
//         icon = Icons.discount;
//         color = Colors.deepOrange;
//         break;
//       case 'ANNOUNCEMENT':
//         icon = Icons.campaign;
//         color = Colors.indigo;
//         break;
//       case 'REMINDER':
//         icon = Icons.alarm;
//         color = Colors.amber;
//         break;
//       case 'LIMITED_DISCOUNT':
//         icon = Icons.local_fire_department;
//         color = Colors.red;
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

  NotificationCountViewModel? _countViewModel;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_sseListenerInitialized) {
      _countViewModel = Provider.of<NotificationCountViewModel>(context, listen: false);
      _initializeSSECountListener();
      _sseListenerInitialized = true;
    }
  }

  @override
  void initState() {
    super.initState();

    // Clear data silently to prevent cached data display
    final viewModel = Provider.of<GetNotificationViewModel>(context, listen: false);
    viewModel.clearAllDataSilent();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Fetch fresh data for current tab
      Provider.of<GetNotificationViewModel>(context, listen: false).fetchLocationListApi();

      final countViewModel = _countViewModel ?? Provider.of<NotificationCountViewModel>(context, listen: false);
      _previousSSECount = countViewModel.notificationCount;
    });
  }

  void _initializeSSECountListener() {
    try {
      if (_countViewModel == null) {
        debugPrint('❌ NotificationScreen: ViewModel not initialized');
        return;
      }

      if (!_countViewModel!.isInitialized) {
        final sseService = Provider.of<SSENotificationService>(context, listen: false);
        _countViewModel!.initializeCountListener(sseService.notificationCountStream, sseService.notificationIncrementStream);
      }

      _countViewModel!.addListener(_onSSECountChanged);

      debugPrint('✅ NotificationScreen: SSE listener initialized');
    } catch (e) {
      debugPrint('❌ NotificationScreen: Error initializing count listener: $e');
    }
  }

  void _onSSECountChanged() {
    if (!mounted) {
      debugPrint('⚠️ NotificationScreen: Widget disposed, ignoring count change');
      return;
    }

    if (_countViewModel == null) {
      debugPrint('⚠️ NotificationScreen: ViewModel is null');
      return;
    }

    final currentCount = _countViewModel!.notificationCount;

    debugPrint('🔔 SSE Count changed: $_previousSSECount -> $currentCount');

    if (currentCount > _previousSSECount && currentCount > 0) {
      if (mounted) {
        setState(() {
          _showNewNotificationBanner = true;
        });
      }
    }

    _previousSSECount = currentCount;
  }

  Future<void> _handleRefreshNotifications() async {
    final viewModel = Provider.of<GetNotificationViewModel>(context, listen: false);
    final type = _selectedTabIndex == 1 ? 'PROMOTION' : null;
    await viewModel.fetchLocationListApi(type: type, isRefresh: true);

    if (mounted) {
      setState(() {
        _showNewNotificationBanner = false;
      });
    }
  }

  void _onTabChanged(int index) {
    setState(() {
      _selectedTabIndex = index;
    });

    final viewModel = Provider.of<GetNotificationViewModel>(context, listen: false);
    final type = index == 1 ? 'PROMOTION' : null;

    // Reset and fetch new data for the selected tab
    viewModel.resetNotifications();
    viewModel.fetchLocationListApi(type: type);
  }

  String _getFilterType(int tabIndex) {
    switch (tabIndex) {
      case 1:
        return 'PROMOTION';
      default:
        return 'ALL';
    }
  }

  @override
  void dispose() {
    debugPrint('🔴 NotificationScreen: Disposing...');

    if (_countViewModel != null) {
      _countViewModel!.removeListener(_onSSECountChanged);
      debugPrint('✅ NotificationScreen: Listener removed');
    }

    _countViewModel = null;

    super.dispose();
    debugPrint('✅ NotificationScreen: Disposed successfully');
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
        GestureDetector(onTap: () => Navigator.pop(context), child: AppBarHeader("Notifications")),

        SizedboxSpaccing.height02(context),

        Container(
          width: screenWidth * 0.9,
          alignment: Alignment.centerLeft,
          child: Container(
            width: screenWidth * 0.45,
            height: 35,
            decoration: BoxDecoration(
              color: AppColors.containerBackground(context),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.border(context), width: 1),
            ),
            child: Row(children: [_buildCustomTab('All', 0), _buildCustomTab('Promo', 1)]),
          ),
        ),

        Expanded(
          child: Consumer<GetNotificationViewModel>(
            builder: (context, viewModel, child) {
              switch (viewModel.notificationListData.status) {
                case Status.LOADING:
                  // Only show full screen loading for initial page
                  if (viewModel.currentPage == 1) {
                    return Center(child: LoadingAnimationWidget.progressiveDots(color: AppColors.button(context), size: 45));
                  }
                  break;

                case Status.ERROR:
                  return ErrorStateWidget(
                    errorMessage: viewModel.notificationListData.message.toString(),
                    onRetry: () {
                      final type = _selectedTabIndex == 1 ? 'PROMOTION' : null;
                      viewModel.resetNotifications();
                      viewModel.fetchLocationListApi(type: type);
                    },
                  );

                case Status.COMPLETED:
                  break;

                default:
                  return const SizedBox.shrink();
              }

              // Use the paginated notifications from viewModel
              final allNotifications = viewModel.allNotifications;
              final meta = viewModel.notificationListData.data?.meta;

              return _buildNotificationList(allNotifications, meta, screenWidth, screenHeight, _getFilterType(_selectedTabIndex));
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
        onTap: () => _onTabChanged(index),
        child: Container(
          decoration: BoxDecoration(color: isSelected ? AppColors.button(context) : Colors.transparent, borderRadius: BorderRadius.circular(6)),
          child: Center(
            child: Text(
              title,
              style: AppTextStyles.textSize14(context, weight: isSelected ? FontWeight.w600 : FontWeight.w500, color: isSelected ? Colors.white : AppColors.textPrimary(context)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationList(List<Datum> notifications, Meta? meta, double screenWidth, double screenHeight, String filterType) {
    if (notifications.isEmpty) {
      return RefreshIndicator(
        onRefresh: _handleRefreshNotifications,
        child: ListView(
          physics: AlwaysScrollableScrollPhysics(),
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
                  Icon(filterType == 'PROMOTION' ? Icons.local_offer : Icons.notifications_none, size: 40, color: Colors.grey.shade400),
                  SizedboxSpaccing.height02(context),
                  Text(
                    filterType == 'ALL' ? 'No Notifications' : 'No Promotions',
                    style: AppTextStyles.textSize16(context, weight: FontWeight.w600, color: AppColors.textPrimary(context)),
                  ),
                  SizedboxSpaccing.width03(context),
                  Text(
                    'You\'re all caught up!',
                    style: AppTextStyles.textSize14(context, weight: FontWeight.w400, color: AppColors.textPrimary(context)),
                  ),
                ],
              ),
            ),
          ],
        ),
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
                          padding: EdgeInsets.symmetric(horizontal: screenHeight * 0.02, vertical: 5),
                          decoration: BoxDecoration(gradient: LinearGradient(colors: [AppColors.button(context), AppColors.button(context).withOpacity(0.5)])),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                                child: const Icon(Icons.notifications_active, color: Colors.white, size: 14),
                              ),
                              SizedboxSpaccing.width03(context),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'New Notifications',
                                      style: AppTextStyles.textSize14(context, color: AppColors.whiteColor, weight: FontWeight.w600),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Tap to refresh and see updates',
                                      style: AppTextStyles.textSize12(context, color: AppColors.whiteColor, weight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(FontAwesomeIcons.arrowUp, color: AppColors.whiteColor, size: 18),
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

          // Notification List with Load More
          Expanded(
            child: Container(
              width: screenWidth * 0.9,
              child: Consumer<GetNotificationViewModel>(
                builder: (context, viewModel, _) {
                  return ListView.builder(
                    physics: AlwaysScrollableScrollPhysics(),
                    itemCount: notifications.length + (viewModel.hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index < notifications.length) {
                        return Padding(padding: const EdgeInsets.only(bottom: 12), child: _buildNotificationCard(notifications[index], screenHeight, screenWidth));
                      }

                      // Load More Button
                      if (viewModel.hasMore) {
                        return Consumer<GetNotificationViewModel>(
                          builder: (context, vm, _) {
                            return _buildLoadMoreButton(context, () {
                              final type = _selectedTabIndex == 1 ? 'PROMOTION' : null;
                              vm.loadMoreNotifications(type: type);
                            }, vm.loadingMore);
                          },
                        );
                      }

                      return SizedBox.shrink();
                    },
                  );
                },
              ),
            ),
          ),
          SizedboxSpaccing.height025(context),
        ],
      ),
    );
  }

  Widget _buildLoadMoreButton(BuildContext context, VoidCallback onPressed, bool isLoading) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: GestureDetector(
          onTap: isLoading ? null : onPressed,
          child: Container(
            height: 50,
            width: screenWidth * 0.8,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(width: 1, color: AppColors.border(context)),
              color: AppColors.containerBackground(context),
            ),
            child: Center(
              child: isLoading
                  ? LoadingAnimationWidget.progressiveDots(color: AppColors.button(context), size: 40)
                  : Text("Load More", style: AppTextStyles.textSize16(context, weight: FontWeight.w500)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationCard(Datum notification, double screenWidth, double screenHeight) {
    final isUnread = notification.isNew == true;
    String trackingId = notification.data?.trackingId ?? '';
    String? status = notification.data?.status;

    final isTappable = notification.type == 'ORDER' || notification.type == 'HOUSE_KEEPER_BOOKING' || notification.type == 'BEAUTY_SALON_BOOKING' || notification.type == 'EVENT_COOKING_BOOKING';

    return GestureDetector(
      onTap: isTappable
          ? () {
              if (notification.type == 'ORDER') {
                if (status == 'PENDING' || status == 'RUNNING' || status == 'ARRIVED_DESTINATION' || status == 'PICKED_UP') {
                  Navigator.pushNamed(context, RoutesName.trackOrderViewdetailsSocketScreen, arguments: {'orderId': trackingId});
                } else {
                  Navigator.pushNamed(context, RoutesName.completeOrdersDetailsScreen, arguments: {'orderId': trackingId});
                }
              } else if (notification.type == 'HOUSE_KEEPER_BOOKING') {
                Navigator.pushNamed(context, RoutesName.confirmedScreen, arguments: {'trackingId': trackingId});
              } else if (notification.type == 'BEAUTY_SALON_BOOKING') {
                Navigator.pushNamed(context, RoutesName.beautyConfirmedScreen, arguments: {'trackingId': trackingId});
              } else if (notification.type == 'EVENT_COOKING_BOOKING') {
                Navigator.pushNamed(context, RoutesName.cookingConfirmedScreen, arguments: {'trackingId': trackingId});
              }
            }
          : null,
      child: Container(
        decoration: BoxDecoration(
          color: isUnread ? (Theme.of(context).brightness == Brightness.dark ? AppColors.button(context).withOpacity(0.5) : Colors.blue.shade50) : AppColors.containerBackground(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isUnread ? Colors.blue.shade100 : AppColors.border(context), width: 1),
          boxShadow: [
            BoxShadow(color: Theme.of(context).brightness == Brightness.dark ? Colors.black.withOpacity(0.3) : Colors.grey.withOpacity(0.05), spreadRadius: 0, blurRadius: 8, offset: Offset(0, 2)),
            BoxShadow(color: Theme.of(context).brightness == Brightness.dark ? Colors.black.withOpacity(0.2) : Colors.grey.withOpacity(0.08), spreadRadius: 0, blurRadius: 4, offset: Offset(0, 1)),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: screenHeight * 0.02, vertical: screenHeight * 0.02),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _getNotificationIcon(notification.type ?? ''),
                  SizedboxSpaccing.width03(context),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (notification.title != null && notification.title!.isNotEmpty)
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  notification.title!,
                                  style: AppTextStyles.textSize14(context, color: AppColors.textPrimary(context), weight: FontWeight.w500),
                                ),
                              ),
                              if (_shouldShowViewBadge(notification.type)) ...[
                                const SizedBox(width: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(color: AppColors.button(context), borderRadius: BorderRadius.circular(4)),
                                  child: Text(
                                    'VIEW',
                                    style: AppTextStyles.textSize10(context, color: AppColors.whiteColor, weight: FontWeight.w600),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                notification.message ?? 'No message',
                                style: AppTextStyles.textSize12(context, color: AppColors.textPrimary(context), weight: FontWeight.w400),
                              ),
                            ),
                            if ((notification.title == null || notification.title!.isEmpty) && _shouldShowViewBadge(notification.type)) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(color: AppColors.button(context), borderRadius: BorderRadius.circular(4)),
                                child: Text(
                                  'VIEW',
                                  style: AppTextStyles.textSize10(context, color: AppColors.whiteColor, weight: FontWeight.w600),
                                ),
                              ),
                            ],
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.access_time, size: 14, color: Colors.grey.shade500),
                                const SizedBox(width: 4),
                                Text(
                                  notification.createdAt != null ? timeago.format(notification.createdAt!) : 'Unknown time',
                                  style: AppTextStyles.textSize12(context, color: Colors.grey.shade600, weight: FontWeight.w500),
                                ),
                              ],
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

  bool _shouldShowViewBadge(String? type) {
    if (type == null) return false;
    return type == 'ORDER' || type == 'HOUSE_KEEPER_BOOKING' || type == 'BEAUTY_SALON_BOOKING' || type == 'EVENT_COOKING_BOOKING';
  }

  Widget _getNotificationIcon(String type) {
    IconData icon;
    Color color;

    switch (type.toUpperCase()) {
      case 'SYSTEM':
        icon = Icons.settings;
        color = Colors.blueGrey;
        break;
      case 'ORDER':
        icon = Icons.shopping_bag;
        color = Colors.blue;
        break;
      case 'HOUSE_KEEPER_BOOKING':
        icon = Icons.cleaning_services;
        color = Colors.teal;
        break;
      case 'BEAUTY_SALON_BOOKING':
        icon = Icons.spa;
        color = Colors.pink;
        break;
      case 'EVENT_COOKING_BOOKING':
        icon = Icons.restaurant_menu;
        color = Colors.orange;
        break;
      case 'PROMOTION':
        icon = Icons.local_offer;
        color = Colors.purple;
        break;
      case 'SPECIAL_OFFER':
        icon = Icons.discount;
        color = Colors.deepOrange;
        break;
      case 'ANNOUNCEMENT':
        icon = Icons.campaign;
        color = Colors.indigo;
        break;
      case 'REMINDER':
        icon = Icons.alarm;
        color = Colors.amber;
        break;
      case 'LIMITED_DISCOUNT':
        icon = Icons.local_fire_department;
        color = Colors.red;
        break;
      default:
        icon = Icons.notifications;
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(5)),
      child: Icon(icon, size: 24, color: color),
    );
  }
}
