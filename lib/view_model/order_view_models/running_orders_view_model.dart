// import 'package:dinmajur_customer/data/response/api_response.dart';
// import 'package:dinmajur_customer/model/order_models/get_all_order_model.dart';
// import 'package:dinmajur_customer/respository/order_repositories/running_order_repository.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/foundation.dart';
//
// class RunningOrdersViewModel with ChangeNotifier {
//   final _myRepo = GetRunningOrderRepository();
//
//   ApiResponse<GetAllOrderModel> runningOrdersData = ApiResponse.loading();
//   ApiResponse<GetAllOrderModel> pendingOrdersData = ApiResponse.loading();
//
//   setPendingOrdersData(ApiResponse<GetAllOrderModel> response){
//     pendingOrdersData = response ;
//     notifyListeners();
//   }
//
//   setRunningOrdersData(ApiResponse<GetAllOrderModel> response){
//     runningOrdersData = response ;
//     notifyListeners();
//   }
//
//
//   Future<void> fetchRunningOrdersGetDataApi ()async{
//
//     setRunningOrdersData(ApiResponse.loading());
//
//     _myRepo.fetchRunningOrderGetApi().then((value){
//       print(value);
//       setRunningOrdersData(ApiResponse.completed(value));
//
//
//     }).onError((error, stackTrace){
//       if (kDebugMode) {
//         print(error);
//         print(stackTrace);
//       }
//       setRunningOrdersData(ApiResponse.error(error.toString()));
//     });
//   }
//
//   Future<void> fetchPendingOrdersGetDataApi ()async{
//
//     setPendingOrdersData(ApiResponse.loading());
//
//     _myRepo.fetchPendingOrderGetApi().then((value){
//       print(value);
//       setPendingOrdersData(ApiResponse.completed(value));
//
//
//     }).onError((error, stackTrace){
//       if (kDebugMode) {
//         print(error);
//         print(stackTrace);
//       }
//       setPendingOrdersData(ApiResponse.error(error.toString()));
//     });
//   }
//
//
//
//
// }

import 'package:dinmajur_customer/data/response/api_response.dart';
import 'package:dinmajur_customer/model/order_models/get_all_order_model.dart';
import 'package:dinmajur_customer/respository/order_repositories/running_order_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:collection/collection.dart';

class RunningOrdersViewModel with ChangeNotifier {
  final _myRepo = GetRunningOrderRepository();

  ApiResponse<GetAllOrderModel> runningOrdersData = ApiResponse.loading();
  ApiResponse<GetAllOrderModel> pendingOrdersData = ApiResponse.loading();
  ApiResponse<GetAllOrderModel> completeOrdersData = ApiResponse.loading();

  // Pagination state for pending orders
  int _pendingCurrentPage = 1;
  int _pendingLimit = 10;
  List<Datum> _pendingAllOrders = [];
  bool _pendingHasMore = true;
  bool _pendingLoadingMore = false;

  // Pagination state for running orders
  int _runningCurrentPage = 1;
  int _runningLimit = 10;
  List<Datum> _runningAllOrders = [];
  bool _runningHasMore = true;
  bool _runningLoadingMore = false;

  // Pagination state for complete orders
  int _completeCurrentPage = 1;
  int _completeLimit = 10;
  List<Datum> _completeAllOrders = [];
  bool _completeHasMore = true;
  bool _completeLoadingMore = false;

  // Getters for pending orders
  int get pendingCurrentPage => _pendingCurrentPage;
  List<Datum> get pendingAllOrders => _pendingAllOrders;
  bool get pendingHasMore => _pendingHasMore;
  bool get pendingLoadingMore => _pendingLoadingMore;

  // Getters for running orders
  int get runningCurrentPage => _runningCurrentPage;
  List<Datum> get runningAllOrders => _runningAllOrders;
  bool get runningHasMore => _runningHasMore;
  bool get runningLoadingMore => _runningLoadingMore;

  // Getters for complete orders
  int get completeCurrentPage => _completeCurrentPage;
  List<Datum> get completeAllOrders => _completeAllOrders;
  bool get completeHasMore => _completeHasMore;
  bool get completeLoadingMore => _completeLoadingMore;

  setPendingOrdersData(ApiResponse<GetAllOrderModel> response) {
    pendingOrdersData = response;
    notifyListeners();
  }

  setRunningOrdersData(ApiResponse<GetAllOrderModel> response) {
    runningOrdersData = response;
    notifyListeners();
  }

  setCompleteOrdersData(ApiResponse<GetAllOrderModel> response) {
    completeOrdersData = response;
    notifyListeners();
  }

  // Reset pending orders pagination
  void resetPendingOrders() {
    _pendingCurrentPage = 1;
    _pendingAllOrders.clear();
    _pendingHasMore = true;
    _pendingLoadingMore = false;
    notifyListeners();
  }

  // Reset running orders pagination
  void resetRunningOrders() {
    _runningCurrentPage = 1;
    _runningAllOrders.clear();
    _runningHasMore = true;
    _runningLoadingMore = false;
    notifyListeners();
  }

  // Reset complete orders pagination
  void resetCompleteOrders() {
    _completeCurrentPage = 1;
    _completeAllOrders.clear();
    _completeHasMore = true;
    _completeLoadingMore = false;
    notifyListeners();
  }

  // Clear all cached data (call when navigating to screen)
  void clearAllData() {
    _pendingCurrentPage = 1;
    _pendingAllOrders = [];
    _pendingHasMore = true;
    _pendingLoadingMore = false;

    _runningCurrentPage = 1;
    _runningAllOrders = [];
    _runningHasMore = true;
    _runningLoadingMore = false;

    _completeCurrentPage = 1;
    _completeAllOrders = [];
    _completeHasMore = true;
    _completeLoadingMore = false;

    pendingOrdersData = ApiResponse.loading();
    runningOrdersData = ApiResponse.loading();
    completeOrdersData = ApiResponse.loading();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  // Synchronous clear without notifying listeners
  void clearAllDataSilent() {
    _pendingCurrentPage = 1;
    _pendingAllOrders = [];
    _pendingHasMore = true;
    _pendingLoadingMore = false;

    _runningCurrentPage = 1;
    _runningAllOrders = [];
    _runningHasMore = true;
    _runningLoadingMore = false;

    _completeCurrentPage = 1;
    _completeAllOrders = [];
    _completeHasMore = true;
    _completeLoadingMore = false;

    pendingOrdersData = ApiResponse.loading();
    runningOrdersData = ApiResponse.loading();
    completeOrdersData = ApiResponse.loading();
  }

  // ✅ FIXED: Fetch pending orders with proper async/await
  Future<void> fetchPendingOrdersGetDataApi({bool isRefresh = false, bool isLoadMore = false}) async {
    if (isRefresh) {
      resetPendingOrders();
    }

    // Only show full screen loading for initial page
    if (_pendingCurrentPage == 1 && !isLoadMore) {
      setPendingOrdersData(ApiResponse.loading());
    }

    try {
      final value = await _myRepo.fetchPendingOrderGetApi(page: _pendingCurrentPage, limit: _pendingLimit);

      if (_pendingCurrentPage == 1) {
        _pendingAllOrders = value.data?.data ?? [];
      } else {
        _pendingAllOrders.addAll(value.data?.data ?? []);
      }

      int totalPages = value.data?.meta?.totalPages ?? 0;
      _pendingHasMore = _pendingCurrentPage < totalPages;

      GetAllOrderModel updatedModel = GetAllOrderModel(
        success: value.success,
        message: value.message,
        data: Data(meta: value.data?.meta, data: _pendingAllOrders),
      );

      setPendingOrdersData(ApiResponse.completed(updatedModel));

      if (kDebugMode) {
        print('✅ Pending orders loaded - Page: $_pendingCurrentPage, Total: ${_pendingAllOrders.length}, HasMore: $_pendingHasMore');
      }
    } catch (error, stackTrace) {
      if (kDebugMode) {
        print('❌ Error loading pending orders: $error');
        print(stackTrace);
      }
      setPendingOrdersData(ApiResponse.error(error.toString()));
    }
  }

  // ✅ FIXED: Load more pending orders with proper loading state
  Future<void> loadMorePendingOrders() async {
    if (_pendingLoadingMore || !_pendingHasMore) {
      if (kDebugMode) {
        print('⚠️ Load more blocked - Loading: $_pendingLoadingMore, HasMore: $_pendingHasMore');
      }
      return;
    }

    if (kDebugMode) {
      print('🔄 Starting load more - Setting loading to TRUE');
    }

    _pendingLoadingMore = true;
    notifyListeners(); // ✅ This should trigger the loading animation

    _pendingCurrentPage++;

    try {
      await fetchPendingOrdersGetDataApi(isLoadMore: true);

      if (kDebugMode) {
        print('✅ Load more completed - Setting loading to FALSE');
      }
    } catch (error) {
      if (kDebugMode) {
        print('❌ Load more failed: $error');
      }
    } finally {
      _pendingLoadingMore = false;
      notifyListeners(); // ✅ This should hide the loading animation
    }
  }

  // ✅ FIXED: Fetch running orders with proper async/await
  Future<void> fetchRunningOrdersGetDataApi({bool isRefresh = false, bool isLoadMore = false}) async {
    if (isRefresh) {
      resetRunningOrders();
    }

    if (_runningCurrentPage == 1 && !isLoadMore) {
      setRunningOrdersData(ApiResponse.loading());
    }

    try {
      final value = await _myRepo.fetchRunningOrderGetApi(page: _runningCurrentPage, limit: _runningLimit);

      if (_runningCurrentPage == 1) {
        _runningAllOrders = value.data?.data ?? [];
      } else {
        _runningAllOrders.addAll(value.data?.data ?? []);
      }

      int totalPages = value.data?.meta?.totalPages ?? 0;
      _runningHasMore = _runningCurrentPage < totalPages;

      GetAllOrderModel updatedModel = GetAllOrderModel(
        success: value.success,
        message: value.message,
        data: Data(meta: value.data?.meta, data: _runningAllOrders),
      );

      setRunningOrdersData(ApiResponse.completed(updatedModel));

      if (kDebugMode) {
        print('✅ Running orders loaded - Page: $_runningCurrentPage, Total: ${_runningAllOrders.length}');
      }
    } catch (error, stackTrace) {
      if (kDebugMode) {
        print('❌ Error loading running orders: $error');
        print(stackTrace);
      }
      setRunningOrdersData(ApiResponse.error(error.toString()));
    }
  }

  // ✅ FIXED: Load more running orders
  Future<void> loadMoreRunningOrders() async {
    if (_runningLoadingMore || !_runningHasMore) return;

    if (kDebugMode) {
      print('🔄 Starting load more running - Setting loading to TRUE');
    }

    _runningLoadingMore = true;
    notifyListeners();

    _runningCurrentPage++;

    try {
      await fetchRunningOrdersGetDataApi(isLoadMore: true);

      if (kDebugMode) {
        print('✅ Load more running completed');
      }
    } catch (error) {
      if (kDebugMode) {
        print('❌ Load more running failed: $error');
      }
    } finally {
      _runningLoadingMore = false;
      notifyListeners();
    }
  }

  // ✅ FIXED: Fetch complete orders with proper async/await
  Future<void> fetchCompleteOrdersGetDataApi({bool isRefresh = false, bool isLoadMore = false}) async {
    if (isRefresh) {
      resetCompleteOrders();
    }

    if (_completeCurrentPage == 1 && !isLoadMore) {
      setCompleteOrdersData(ApiResponse.loading());
    }

    try {
      final value = await _myRepo.fetchCompleteOrderGetApi(page: _completeCurrentPage, limit: _completeLimit);

      if (_completeCurrentPage == 1) {
        _completeAllOrders = value.data?.data ?? [];
      } else {
        _completeAllOrders.addAll(value.data?.data ?? []);
      }

      int totalPages = value.data?.meta?.totalPages ?? 0;
      _completeHasMore = _completeCurrentPage < totalPages;

      GetAllOrderModel updatedModel = GetAllOrderModel(
        success: value.success,
        message: value.message,
        data: Data(meta: value.data?.meta, data: _completeAllOrders),
      );

      setCompleteOrdersData(ApiResponse.completed(updatedModel));

      if (kDebugMode) {
        print('✅ Complete orders loaded - Page: $_completeCurrentPage, Total: ${_completeAllOrders.length}');
      }
    } catch (error, stackTrace) {
      if (kDebugMode) {
        print('❌ Error loading complete orders: $error');
        print(stackTrace);
      }
      setCompleteOrdersData(ApiResponse.error(error.toString()));
    }
  }

  // ✅ FIXED: Load more complete orders
  Future<void> loadMoreCompleteOrders() async {
    if (_completeLoadingMore || !_completeHasMore) return;

    if (kDebugMode) {
      print('🔄 Starting load more complete - Setting loading to TRUE');
    }

    _completeLoadingMore = true;
    notifyListeners();

    _completeCurrentPage++;

    try {
      await fetchCompleteOrdersGetDataApi(isLoadMore: true);

      if (kDebugMode) {
        print('✅ Load more complete completed');
      }
    } catch (error) {
      if (kDebugMode) {
        print('❌ Load more complete failed: $error');
      }
    } finally {
      _completeLoadingMore = false;
      notifyListeners();
    }
  }

  ///Single order udpate:
  Future<void> refreshSingleCompletedOrder(String bookingId) async {
    try {
      // Search across all loaded pages (re-fetch page 1 up to current page)
      for (int page = 1; page <= _completeCurrentPage; page++) {
        final value = await _myRepo.fetchCompleteOrderGetApi(page: page, limit: _completeLimit);

        final freshOrders = value.data?.data ?? [];

        // Find the target order in this page's results
        final updatedOrder = freshOrders.firstWhereOrNull(
          (order) => order.orderId == bookingId || order.houseKeeperBookingId == bookingId || order.beautySalonBookingId == bookingId || order.eventCookingBookingId == bookingId || order
              .servicesBookingId == bookingId,
        );

        if (updatedOrder != null) {
          // Found it — replace by ID in our local list, regardless of index
          final localIndex = _completeAllOrders.indexWhere(
            (order) => order.orderId == bookingId || order.houseKeeperBookingId == bookingId || order.beautySalonBookingId == bookingId || order.eventCookingBookingId == bookingId || order
                .servicesBookingId == bookingId,
          );

          if (localIndex != -1) {
            _completeAllOrders[localIndex] = updatedOrder;

            // Rebuild the ApiResponse with the updated list
            setCompleteOrdersData(
              ApiResponse.completed(
                GetAllOrderModel(
                  success: completeOrdersData.data?.success,
                  message: completeOrdersData.data?.message,
                  data: Data(meta: completeOrdersData.data?.data?.meta, data: List.from(_completeAllOrders)),
                ),
              ),
            );
          }
          return; // Found and updated — stop searching pages
        }
      }
    } catch (error) {
      if (kDebugMode) {
        print('❌ refreshSingleCompletedOrder error: $error');
      }
    }
  }

  Future<void> refreshSingleOrder(String bookingId) async {
    // Try running orders first
    final runningIndex = _runningAllOrders.indexWhere(
          (order) =>
      order.orderId == bookingId ||
          order.houseKeeperBookingId == bookingId ||
          order.beautySalonBookingId == bookingId ||
          order.eventCookingBookingId == bookingId ||
          order.servicesBookingId == bookingId ,
    );

    if (runningIndex != -1) {
      // It's in running list — refresh from running API
      for (int page = 1; page <= _runningCurrentPage; page++) {
        final value = await _myRepo.fetchRunningOrderGetApi(page: page, limit: _runningLimit);
        final updatedOrder = (value.data?.data ?? []).firstWhereOrNull(
              (order) =>
          order.orderId == bookingId ||
              order.houseKeeperBookingId == bookingId ||
              order.beautySalonBookingId == bookingId ||
              order.eventCookingBookingId == bookingId ||
              order.servicesBookingId == bookingId ,
        );

        if (updatedOrder != null) {
          _runningAllOrders[runningIndex] = updatedOrder;
          setRunningOrdersData(ApiResponse.completed(GetAllOrderModel(
            success: runningOrdersData.data?.success,
            message: runningOrdersData.data?.message,
            data: Data(meta: runningOrdersData.data?.data?.meta, data: List.from(_runningAllOrders)),
          )));
          return;
        }
      }
    } else {
      // It's in completed list — refresh from completed API
      await refreshSingleCompletedOrder(bookingId);
    }
  }
}
