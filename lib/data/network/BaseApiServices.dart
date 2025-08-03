
import 'dart:typed_data';

abstract class BaseApiServices {

  ///All Get Api Response {}
  Future<dynamic> getGetApiResponse(String url);
  Future<dynamic> getGetApiWithHeaderResponse(String url, {Map<String, String>? headers});

  ///All Post Api Response {login, otpApi, emailvalidation}
  Future<dynamic> getPostApiResponse(String url, dynamic data);
  Future<dynamic> gePostApiWithHeaderesponse(String url, dynamic data, {Map<String, String>? headers});


  ///Otp token Added here Response {otpverify}
  Future<dynamic> getOTPPostApiResponse(String url, dynamic data, {Map<String, String>? headers});

  ///Multistep Registration { multiStep registration header access token pass, Create_Services }
  Future<dynamic> getMultiStepPostApiResponse(String url, Map<String, dynamic> fields, {Map<String, String>? headers});

  /// Image upload now accepts Uint8List imageBytes instead of Map<String,String> && header pass access token
  Future<dynamic> imageMultipartPostApiResponse(
      String url,
      String fileName,
      String imageType,
      Uint8List imageBytes,
      {Map<String, String>? headers}
      );


  ///Patch API {UpdateMe APi, }
   Future getPatchApiResponse(String url, dynamic data, {Map<String, String>? headers});
  Future<dynamic> getPatchApiImageResponse(String url, Uint8List imageBytes, {Map<String, String>? headers});

  ///Same url, data, header ------>   {Create Area Address}
  Future<dynamic> getsamePostApiResponse(String url, dynamic data, {Map<String, String>? headers});



  ///All Put Api Response - Add this method ,portpolio update
  Future getPutApiResponse(String url, dynamic data, {Map<String, String>? headers});


  ///Delete
  Future getDeleteApiResponse(String url, {Map<String, String>? headers});

}
