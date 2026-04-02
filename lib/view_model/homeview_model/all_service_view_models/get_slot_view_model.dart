import 'package:dinmajur_customer/data/response/api_response.dart';
import 'package:dinmajur_customer/model/home_models/all_service_models/get_timeslot_model.dart';
import 'package:dinmajur_customer/respository/home_repositories/all_service_repositories/get_slot_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

class GetSlotViewModel with ChangeNotifier {
  final _myRepo = GetSlotRepository();

  ApiResponse<GetTimeSlotModel> getSlotData = ApiResponse.loading();

  void setGetSlotData(ApiResponse<GetTimeSlotModel> response) {
    getSlotData = response;
    notifyListeners();
  }

  Future<void> fetchGetSlotDataApi(DateTime date, String serviceId) async {
    setGetSlotData(ApiResponse.loading());

    final String formattedDate = DateFormat('yyyy/MM/dd').format(date);

    _myRepo.fetchSlotGetApi(formattedDate,serviceId ).then((value) {
      setGetSlotData(ApiResponse.completed(value));
    }).onError((error, stackTrace) {
      if (kDebugMode) {
        print(error);
        print(stackTrace);
      }
      setGetSlotData(ApiResponse.error(error.toString()));
    });
  }
}