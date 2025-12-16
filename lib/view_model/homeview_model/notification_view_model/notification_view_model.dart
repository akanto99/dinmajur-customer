
import 'package:dinmajur_customer/data/response/api_response.dart';
import 'package:dinmajur_customer/model/home_models/location_model/get_location_model.dart';
import 'package:dinmajur_customer/model/home_models/notification_model/get_notificationlist_model.dart';
import 'package:dinmajur_customer/respository/home_repositories/location_repository/get_locationlist_repository.dart';
import 'package:dinmajur_customer/respository/home_repositories/notification_repository/notification_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

class GetNotificationViewModel with ChangeNotifier {
  final _myRepo = NotificationListRepository();


  ApiResponse<NotificationListModel> notificationListData = ApiResponse.loading();

  setNotificationListLoading(ApiResponse<NotificationListModel> response) {
    notificationListData = response;
    notifyListeners();
  }


  Future<void> fetchLocationListApi() async {
    setNotificationListLoading(ApiResponse.loading());

    _myRepo.fetchNotificationListGetApi().then((value){
      print(value);
      setNotificationListLoading(ApiResponse.completed(value));


    }).onError((error, stackTrace){
      if (kDebugMode) {
        print(error);
        print(stackTrace);
      }
      setNotificationListLoading(ApiResponse.error(error.toString()));
    });
  }

}