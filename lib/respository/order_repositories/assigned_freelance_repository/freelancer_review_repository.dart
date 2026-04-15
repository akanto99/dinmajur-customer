import 'package:dinmajur_customer/configs/res/app_url.dart';
import 'package:dinmajur_customer/data/network/BaseApiServices.dart';
import 'package:dinmajur_customer/data/network/NetworkApiService.dart';
import 'package:dinmajur_customer/model/order_models/assigned_freelance_model/freelancer_review_model.dart';

class FreelancerReviewRepository {
  BaseApiServices _apiServices = NetworkApiService();

  Future<FreelancerReviewModel> fetchReviewsData( String freelancerID) async {
    try {
      dynamic response = await _apiServices.getGetApiWithHeaderResponse("${AppUrl.viewFreelancerReview}?freelancerId=$freelancerID");
      return response =FreelancerReviewModel.fromJson(response);
    } catch (e) {
      throw e;
    }
  }
}