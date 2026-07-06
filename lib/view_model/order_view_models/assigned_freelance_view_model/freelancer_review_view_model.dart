import 'package:dinmajur_customer/data/response/api_response.dart';
import 'package:dinmajur_customer/model/order_models/assigned_freelance_model/freelancer_review_model.dart';
import 'package:dinmajur_customer/respository/order_repositories/assigned_freelance_repository/freelancer_review_repository.dart';
import 'package:flutter/foundation.dart';

class FreelancerReviewViewModel with ChangeNotifier {
  final _myRepo = FreelancerReviewRepository();

  ApiResponse<FreelancerReviewModel> reViewData = ApiResponse.loading();

  void setReViewData(ApiResponse<FreelancerReviewModel> response) {
    reViewData = response;
    notifyListeners();
  }

  Future<void> fetchReviewsDataApi(String freelancerID) async {
    setReViewData(ApiResponse.loading());
    _myRepo
        .fetchReviewsData(freelancerID)
        .then((value) {
      setReViewData(ApiResponse.completed(value));
    })
        .onError((error, stackTrace) {
      setReViewData(ApiResponse.error(error.toString()));
    });
  }
}