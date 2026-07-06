import 'package:dinmajur_customer/data/response/api_response.dart';
import 'package:dinmajur_customer/model/home_models/dropdown_categories_selection_models/beauty_and_salon_model/get_bookedslot_model.dart';
import 'package:dinmajur_customer/respository/home_repositories/dropdown_categories_selection_repositories/beauty_and_salon_repository/get_bookedslot_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

class GetBookedSlotViewModel with ChangeNotifier {
  final _myRepo = GetBookedSlotRepository();

  ApiResponse<GetBookedTimeSlotModel> getBookedSlotData = ApiResponse.loading();

  void setBookedSlotData(ApiResponse<GetBookedTimeSlotModel> response) {
    getBookedSlotData = response;
    notifyListeners();
  }

  Future<void> fetchGetBookedSlotDataApi(DateTime date) async {
    setBookedSlotData(ApiResponse.loading());

    final String formattedDate = DateFormat('yyyy/MM/dd').format(date);

    _myRepo.fetchBookedSlotGetApi(formattedDate).then((value) {
      setBookedSlotData(ApiResponse.completed(value));
    }).onError((error, stackTrace) {
      setBookedSlotData(ApiResponse.error(error.toString()));
    });
  }
}