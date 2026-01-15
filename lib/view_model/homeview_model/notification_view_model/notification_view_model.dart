//
// import 'package:dinmajur_customer/data/response/api_response.dart';
// import 'package:dinmajur_customer/model/home_models/location_model/get_location_model.dart';
// import 'package:dinmajur_customer/model/home_models/notification_model/get_notificationlist_model.dart';
// import 'package:dinmajur_customer/respository/home_repositories/location_repository/get_locationlist_repository.dart';
// import 'package:dinmajur_customer/respository/home_repositories/notification_repository/notification_repository.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/foundation.dart';
//
// class GetNotificationViewModel with ChangeNotifier {
//   final _myRepo = NotificationListRepository();
//
//
//   ApiResponse<NotificationListModel> notificationListData = ApiResponse.loading();
//
//   setNotificationListLoading(ApiResponse<NotificationListModel> response) {
//     notificationListData = response;
//     notifyListeners();
//   }
//
//
//   Future<void> fetchLocationListApi() async {
//     setNotificationListLoading(ApiResponse.loading());
//
//     _myRepo.fetchNotificationListGetApi().then((value){
//       print(value);
//       setNotificationListLoading(ApiResponse.completed(value));
//
//
//     }).onError((error, stackTrace){
//       if (kDebugMode) {
//         print(error);
//         print(stackTrace);
//       }
//       setNotificationListLoading(ApiResponse.error(error.toString()));
//     });
//   }
//
// }
///Corrected
// import 'package:dinmajur_customer/data/response/api_response.dart';
// import 'package:dinmajur_customer/model/home_models/notification_model/get_notificationlist_model.dart';
// import 'package:dinmajur_customer/respository/home_repositories/notification_repository/notification_repository.dart';
// import 'package:flutter/foundation.dart';
//
// class GetNotificationViewModel with ChangeNotifier {
//   final _myRepo = NotificationListRepository();
//
//   ApiResponse<NotificationListModel> notificationListData = ApiResponse.loading();
//
//   setNotificationListLoading(ApiResponse<NotificationListModel> response) {
//     notificationListData = response;
//     notifyListeners();
//   }
//
//   Future<void> fetchLocationListApi({String? type}) async {
//     setNotificationListLoading(ApiResponse.loading());
//
//     _myRepo.fetchNotificationListGetApi(type: type).then((value) {
//       print(value);
//       setNotificationListLoading(ApiResponse.completed(value));
//     }).onError((error, stackTrace) {
//       if (kDebugMode) {
//         print(error);
//         print(stackTrace);
//       }
//       setNotificationListLoading(ApiResponse.error(error.toString()));
//     });
//   }
// }

///Corrected
import 'package:dinmajur_customer/data/response/api_response.dart';
import 'package:dinmajur_customer/model/home_models/notification_model/get_notificationlist_model.dart';
import 'package:dinmajur_customer/respository/home_repositories/notification_repository/notification_repository.dart';
import 'package:flutter/foundation.dart';

class GetNotificationViewModel with ChangeNotifier {
  final _myRepo = NotificationListRepository();

  ApiResponse<NotificationListModel> notificationListData = ApiResponse.loading();

  // Pagination state for all notifications
  int _currentPage = 1;
  int _limit = 10;
  List<Datum> _allNotifications = [];
  bool _hasMore = true;
  bool _loadingMore = false;
  String? _currentType; // Track current filter type

  // Getters
  int get currentPage => _currentPage;
  List<Datum> get allNotifications => _allNotifications;
  bool get hasMore => _hasMore;
  bool get loadingMore => _loadingMore;

  setNotificationListLoading(ApiResponse<NotificationListModel> response) {
    notificationListData = response;
    notifyListeners();
  }

  // Reset pagination
  void resetNotifications() {
    _currentPage = 1;
    _allNotifications.clear();
    _hasMore = true;
    _loadingMore = false;
    notifyListeners();
  }

  // Clear all data silently
  void clearAllDataSilent() {
    _currentPage = 1;
    _allNotifications = [];
    _hasMore = true;
    _loadingMore = false;
    _currentType = null;
    notificationListData = ApiResponse.loading();
  }

  // ✅ Fetch notifications with pagination
  Future<void> fetchLocationListApi({
    String? type,
    bool isRefresh = false,
    bool isLoadMore = false
  }) async {
    // If type changed, reset everything
    if (type != _currentType) {
      resetNotifications();
      _currentType = type;
    }

    if (isRefresh) {
      resetNotifications();
      _currentType = type;
    }

    // Only show full screen loading for initial page
    if (_currentPage == 1 && !isLoadMore) {
      setNotificationListLoading(ApiResponse.loading());
    }

    try {
      final value = await _myRepo.fetchNotificationListGetApi(
        type: type,
        page: _currentPage,
        limit: _limit,
      );

      // Merge or replace notifications
      if (_currentPage == 1) {
        _allNotifications = value.data ?? [];
      } else {
        _allNotifications.addAll(value.data ?? []);
      }

      // Check if there are more pages
      int totalPages = value.meta?.totalPages ?? 0;
      _hasMore = _currentPage < totalPages;

      // Create updated model with all notifications
      NotificationListModel updatedModel = NotificationListModel(
        success: value.success,
        message: value.message,
        meta: value.meta,
        data: _allNotifications,
      );

      setNotificationListLoading(ApiResponse.completed(updatedModel));

      if (kDebugMode) {
        print('✅ Notifications loaded - Page: $_currentPage, Total: ${_allNotifications.length}, HasMore: $_hasMore');
      }
    } catch (error, stackTrace) {
      if (kDebugMode) {
        print('❌ Error loading notifications: $error');
        print(stackTrace);
      }
      setNotificationListLoading(ApiResponse.error(error.toString()));
    }
  }

  // ✅ Load more notifications
  Future<void> loadMoreNotifications({String? type}) async {
    if (_loadingMore || !_hasMore) {
      if (kDebugMode) {
        print('⚠️ Load more blocked - Loading: $_loadingMore, HasMore: $_hasMore');
      }
      return;
    }

    if (kDebugMode) {
      print('🔄 Starting load more - Setting loading to TRUE');
    }

    _loadingMore = true;
    notifyListeners();

    _currentPage++;

    try {
      await fetchLocationListApi(type: type, isLoadMore: true);

      if (kDebugMode) {
        print('✅ Load more completed - Setting loading to FALSE');
      }
    } catch (error) {
      if (kDebugMode) {
        print('❌ Load more failed: $error');
      }
    } finally {
      _loadingMore = false;
      notifyListeners();
    }
  }
}