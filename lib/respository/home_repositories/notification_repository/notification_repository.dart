import 'package:dinmajur_customer/configs/res/app_url.dart';
import 'package:dinmajur_customer/data/network/BaseApiServices.dart';
import 'package:dinmajur_customer/data/network/NetworkApiService.dart';
import 'package:dinmajur_customer/model/home_models/notification_model/get_notificationlist_model.dart';

class NotificationListRepository {
  BaseApiServices _apiServices = NetworkApiService();

  Future<NotificationListModel> fetchNotificationListGetApi({
    String? type,
    required int page,
    required int limit,
  }) async {
    try {
      String url = AppUrl.notificationGetAPI;

      // Build query parameters
      List<String> queryParams = [];

      if (type != null && type.isNotEmpty) {
        queryParams.add('type=$type');
      }

      queryParams.add('page=$page');
      queryParams.add('limit=$limit');

      // Append query params to URL
      if (queryParams.isNotEmpty) {
        url = '$url?${queryParams.join('&')}';
      }

      dynamic response = await _apiServices.getGetApiWithHeaderResponse(url);

      return NotificationListModel.fromJson(response);
    } catch (e) {
      throw e;
    }
  }
}