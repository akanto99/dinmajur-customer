import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:async';
import 'package:dinmajur_customer/configs/res/app_url.dart';
import 'package:dinmajur_customer/configs/services/navigator_services/navigator_services_refreshToken.dart';
import 'package:dinmajur_customer/configs/services/session_expired_services/session_expired.dart';
import 'package:dinmajur_customer/configs/services/sse_notification_services/sse_notification_and_ordercount/notification_count_view_model.dart';
import 'package:dinmajur_customer/configs/services/sse_notification_services/sse_notification_and_ordercount/running_ordercount_view_model.dart';
import 'package:dinmajur_customer/configs/services/sse_notification_services/sse_notification_service.dart';
import 'package:dinmajur_customer/data/network/service_reconnector.dart';
import 'package:dinmajur_customer/data/network/token_manager.dart';
import 'package:dinmajur_customer/model/user/user_model.dart';
import 'package:dinmajur_customer/socket_connection_model/socket_provider_services/socket_provider.dart';
import 'package:dinmajur_customer/view_model/userview_model/userview_model.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http_parser/http_parser.dart';
import '../app_excaptions.dart';
import 'BaseApiServices.dart';

class NetworkApiService extends BaseApiServices {
  final TokenManager _tokenManager = TokenManager();
  final ServiceReconnector _serviceReconnector = ServiceReconnector();
  final Map<String, int> _retryAttempts = {};
  static const int _maxRetries = 2;

  /// All Get Api Response
  ///  Corrected
  @override
  Future getGetApiResponse(String url) async {
    dynamic responseJson;
    try {
      final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 30));
      responseJson = await _handleResponse(response, url, () => getGetApiResponse(url));
    } on SocketException catch (e) {
      // print('$e');
      throw FetchDataException('No Internet Connection');
    } on TimeoutException {
      throw FetchDataException('Request timeout. Please try again');
    }
    return responseJson;
  }

  /// Header Get Api
  /// Corrected
  @override
  Future<dynamic> getGetApiWithHeaderResponse(String url, {Map<String, String>? headers}) async {
    dynamic responseJson;
    try {
      final authHeaders = await _getAuthHeaders(headers);
      final response = await http.get(Uri.parse(url), headers: authHeaders).timeout(const Duration(seconds: 30));
      responseJson = await _handleResponse(response, url, () => getGetApiWithHeaderResponse(url, headers: headers));
    } on SocketException {
      throw FetchDataException('No Internet Connection');
    } on TimeoutException {
      throw FetchDataException('Request timeout. Please try again');
    }
    return responseJson;
  }

  @override
  Future getPostApiResponse(String url, dynamic data) async {
    dynamic responseJson;
    try {
      Response response = await post(Uri.parse(url), body: data).timeout(Duration(seconds: 30));
      // print(response.body);
      responseJson = await _handleResponse(response, url, () => getPostApiResponse(url, data));
    } on SocketException {
      throw FetchDataException('No Internet Connection');
    } on TimeoutException {
      throw FetchDataException('Request timeout. Please try again');
    }
    return responseJson;
  }

  ///Corected
  @override
  Future getPostApiWithOutBodyresponse(String url, {Map<String, String>? headers}) async {
    try {
      final authHeaders = await _getAuthHeaders(headers);
      final response = await http.post(Uri.parse(url), headers: authHeaders).timeout(const Duration(seconds: 30));
      return await _handleResponse(response, url, () => getPostApiWithOutBodyresponse(url, headers: headers));
    } on SocketException {
      throw FetchDataException('No Internet Connection');
    } on TimeoutException {
      throw FetchDataException('Request timeout. Please try again');
    }
  }

  ///Corrected
  @override
  Future gePostApiWithHeaderesponse(String url, dynamic data, {Map<String, String>? headers}) async {
    try {
      final authHeaders = await _getAuthHeaders(headers);
      final response = await http.post(Uri.parse(url), body: jsonEncode(data), headers: authHeaders).timeout(const Duration(seconds: 30));
      return await _handleResponse(response, url, () => gePostApiWithHeaderesponse(url, data));
    } on SocketException {
      throw FetchDataException('No Internet Connection');
    } on TimeoutException {
      throw FetchDataException('Request timeout. Please try again');
    }
  }

  /// OTP token Added here Response {otpverify}
  @override
  Future getOTPPostApiResponse(String url, dynamic data, {Map<String, String>? headers}) async {
    try {
      final response = await http.post(Uri.parse(url), body: jsonEncode(data), headers: headers ?? {'Content-Type': 'application/json'}).timeout(const Duration(seconds: 120));
      return await _handleResponse(response, url, () => getOTPPostApiResponse(url, data, headers: headers));
    } on SocketException {
      throw FetchDataException('No Internet Connection');
    } on TimeoutException {
      throw FetchDataException('Request timeout. Please try again');
    }
  }

  /// Multistep Registration { multiStep registration header access token pass, Create Services}
  @override
  Future<dynamic> getMultiStepPostApiResponse(String url, Map<String, dynamic> fields, {Map<String, String>? headers}) async {
    try {
      var response = await http
          .post(Uri.parse(url), headers: headers ?? {'Content-Type': 'application/json', 'Accept': 'application/json'}, body: jsonEncode(fields))
          .timeout(const Duration(seconds: 30));
      return await _handleResponse(response, url, () => getMultiStepPostApiResponse(url, fields, headers: headers));
    } on SocketException catch (e) {
      // print('$e');
      throw FetchDataException('No Internet Connection');
    } on TimeoutException {
      throw FetchDataException('Request timeout. Please try again');
    }
  }

  /// Image upload now accepts Uint8List imageBytes instead of Map<String,String> && header pass access token
  @override
  Future<dynamic> imageMultipartPostApiResponse(String url, Uint8List imageBytes, String fileName, String imageType, {Map<String, String>? headers}) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(url));
      if (headers != null) {
        request.headers.addAll(headers);
      }
      request.fields['imageType'] = imageType;
      MediaType contentType = _getContentType(fileName);
      var multipartFile = http.MultipartFile.fromBytes('image', imageBytes, filename: fileName, contentType: contentType);
      request.files.add(multipartFile);
      var streamedResponse = await request.send().timeout(const Duration(seconds: 30));
      var response = await http.Response.fromStream(streamedResponse);
      return returnResponse(response);
    } on SocketException {
      throw FetchDataException('No Internet Connection');
    } on TimeoutException {
      throw FetchDataException('Request timeout. Please try again');
    }
  }

  /// Document PDF image upload with documentType field
  @override
  Future<dynamic> documentPdfImageMultipartPostApiResponse(
    String url,
    Uint8List pdfImageBytes,
    String documentType,
    String fileName, { // Accept filename as parameter
    Map<String, String>? headers,
  }) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(url));

      if (headers != null) {
        request.headers.addAll(headers);
      }
      request.fields['documentType'] = documentType;
      MediaType contentType = _getContentType(fileName);
      var multipartFile = http.MultipartFile.fromBytes('document', pdfImageBytes, filename: fileName, contentType: contentType);
      request.files.add(multipartFile);
      var streamedResponse = await request.send().timeout(const Duration(seconds: 30));
      var response = await http.Response.fromStream(streamedResponse);
      return returnResponse(response);
    } on SocketException {
      throw FetchDataException('No Internet Connection');
    } on TimeoutException {
      throw FetchDataException('Request timeout. Please try again');
    }
  }

  /// Helper method to determine content type based on file extension
  MediaType _getContentType(String fileName) {
    String extension = fileName.toLowerCase().split('.').last;

    switch (extension) {
      case 'pdf':
        return MediaType('application', 'pdf');
      case 'jpg':
      case 'jpeg':
        return MediaType('image', 'jpeg');
      case 'png':
        return MediaType('image', 'png');
      case 'gif':
        return MediaType('image', 'gif');
      case 'bmp':
        return MediaType('image', 'bmp');
      case 'webp':
        return MediaType('image', 'webp');
      case 'doc':
        return MediaType('application', 'msword');
      case 'docx':
        return MediaType('application', 'vnd.openxmlformats-officedocument.wordprocessingml.document');
      case 'xls':
        return MediaType('application', 'vnd.ms-excel');
      case 'xlsx':
        return MediaType('application', 'vnd.openxmlformats-officedocument.spreadsheetml.sheet');
      case 'txt':
        return MediaType('text', 'plain');
      default:
        return MediaType('application', 'octet-stream');
    }
  }

  /// Patch Api Update Me
  /// Corrected
  @override
  Future getPatchApiResponse(String url, dynamic data, {Map<String, String>? headers}) async {
    dynamic responseJson;
    try {
      final authHeaders = await _getAuthHeaders(headers);
      final response = await http.patch(Uri.parse(url), headers: authHeaders, body: jsonEncode(data)).timeout(const Duration(seconds: 30));
      responseJson = await _handleResponse(response, url, () => getPatchApiResponse(url, data));
    } on SocketException {
      throw FetchDataException('No Internet Connection');
    } on TimeoutException {
      throw FetchDataException('Request timeout. Please try again');
    }
    return responseJson;
  }

  ///Corrected

  @override
  Future getsamePostApiResponse(String url, dynamic data, {Map<String, String>? headers}) async {
    dynamic responseJson;
    try {
      final authHeaders = await _getAuthHeaders(headers);
      http.Response response = await http.post(Uri.parse(url), body: jsonEncode(data), headers: authHeaders).timeout(const Duration(seconds: 30));
      responseJson = await _handleResponse(response, url, () => getsamePostApiResponse(url, data));
    } on SocketException {
      throw FetchDataException('No Internet Connection');
    } on TimeoutException {
      throw FetchDataException('Request timeout. Please try again');
    }
    return responseJson;
  }

  /// PUT API
  @override
  Future getPutApiResponse(String url, dynamic data, {Map<String, String>? headers}) async {
    dynamic responseJson;
    try {
      final response = await http.put(Uri.parse(url), body: jsonEncode(data), headers: headers ?? {'Content-Type': 'application/json'}).timeout(const Duration(seconds: 30));
      responseJson = await _handleResponse(response, url, () => getPutApiResponse(url, data, headers: headers));
    } on SocketException {
      throw FetchDataException('No Internet Connection');
    } on TimeoutException {
      throw FetchDataException('Request timeout. Please try again');
    }
    return responseJson;
  }

  /// Image Patch Response without Types
  @override
  Future getPatchApiImageResponse(String url, String fileName, Uint8List imageBytes, {Map<String, String>? headers}) async {
    dynamic responseJson;
    try {
      final authHeaders = await _getAuthHeaders(headers);
      var request = http.MultipartRequest('PATCH', Uri.parse(url));
      request.headers.addAll(authHeaders);
      request.files.add(http.MultipartFile.fromBytes('logo', imageBytes, filename: fileName));
      final streamedResponse = await request.send().timeout(const Duration(seconds: 30));
      final response = await http.Response.fromStream(streamedResponse);
      responseJson = await _handleResponse(response, url, () => getPatchApiImageResponse(url, fileName, imageBytes, headers: headers));
    } on SocketException {
      throw FetchDataException('No Internet Connection');
    } on TimeoutException {
      throw FetchDataException('Request timeout. Please try again');
    }

    return responseJson;
  }

  /// Image Patch Response with Types
  @override
  Future getPatchApiImageCoverResponse(String url, String fileName, Uint8List imageBytes, String imageType, {Map<String, String>? headers}) async {
    dynamic responseJson;
    try {
      final authHeaders = await _getAuthHeaders(headers);
      var request = http.MultipartRequest('PATCH', Uri.parse(url));
      request.headers.addAll(authHeaders);
      request.fields['imageType'] = imageType;
      MediaType contentType = _getContentType(fileName);
      request.files.add(http.MultipartFile.fromBytes('image', imageBytes, filename: fileName, contentType: contentType));

      final streamedResponse = await request.send().timeout(const Duration(seconds: 30));
      final response = await http.Response.fromStream(streamedResponse);
      responseJson = await _handleResponse(response, url, () => getPatchApiImageCoverResponse(url, fileName, imageBytes, imageType, headers: headers));
    } on SocketException {
      throw FetchDataException('No Internet Connection');
    } on TimeoutException {
      throw FetchDataException('Request timeout. Please try again');
    }

    return responseJson;
  }

  /// Document PDF Image Patch Response - Updated with token refresh handling
  @override
  Future<dynamic> getPatchApiDocumentPDFImageResponse(String url, Uint8List pdfImageBytes, String documentType, String fileName, {Map<String, String>? headers}) async {
    try {
      final authHeaders = await _getAuthHeaders(headers);
      var request = http.MultipartRequest('PATCH', Uri.parse(url));
      request.headers.addAll(authHeaders);
      request.fields['documentType'] = documentType;
      MediaType contentType = _getContentType(fileName);
      request.files.add(http.MultipartFile.fromBytes('document', pdfImageBytes, filename: fileName, contentType: contentType));

      final streamedResponse = await request.send().timeout(const Duration(seconds: 30));
      final response = await http.Response.fromStream(streamedResponse);
      return await _handleResponse(response, url, () => getPatchApiDocumentPDFImageResponse(url, pdfImageBytes, documentType, fileName, headers: headers));
    } on SocketException {
      throw FetchDataException('No Internet Connection');
    } on TimeoutException {
      throw FetchDataException('Request timeout. Please try again');
    }
  }

  /// Delete API
  @override
  Future getDeleteApiResponse(String url, {Map<String, String>? headers}) async {
    dynamic responseJson;
    try {
      final authHeaders = await _getAuthHeaders(headers);
      final response = await http.delete(Uri.parse(url), headers: authHeaders).timeout(const Duration(seconds: 30));
      responseJson = await _handleResponse(response, url, () => getDeleteApiResponse(url));
    } on SocketException {
      throw FetchDataException('No Internet Connection');
    } on TimeoutException {
      throw FetchDataException('Request timeout. Please try again');
    }
    return responseJson;
  }

  // Helper method to get headers with authentication
  Future<Map<String, String>> _getAuthHeaders([Map<String, String>? additionalHeaders]) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('accessToken');
    // print(accessToken);
    Map<String, String> headers = {'Content-Type': 'application/json', 'Accept': 'application/json'};

    if (accessToken != null && accessToken.isNotEmpty) {
      headers['Authorization'] = '$accessToken';
    }

    if (additionalHeaders != null) {
      headers.addAll(additionalHeaders);
    }

    return headers;
  }

  /// Handle API response with automatic token refresh
  Future<dynamic> _handleResponse(http.Response response, String originalUrl, Future<dynamic> Function() retryFunction) async {
    if (response.statusCode == 401) {
      final retryCount = _retryAttempts[originalUrl] ?? 0;
      if (retryCount >= _maxRetries) {
        _retryAttempts.remove(originalUrl);
        throw UnauthorisedException('Session expired. Please login again.');
      }
      if (!_shouldRefreshToken(originalUrl)) {
        throw UnauthorisedException('Authentication failed');
      }
      try {
        // TokenManager handles queueing, saving, and logout-on-403
        final newToken = await _tokenManager.refreshAccessToken();

        // Reconnect socket + SSE after getting new token
        await _serviceReconnector.reconnectAll(newToken);

        _retryAttempts[originalUrl] = retryCount + 1;
        final result = await retryFunction();
        _retryAttempts.remove(originalUrl);
        return result;
      } catch (e) {
        _retryAttempts.remove(originalUrl);
        rethrow;
      }
    }

    _retryAttempts.remove(originalUrl);
    return returnResponse(response);
  }

  /// Check if the URL should trigger token refresh
  bool _shouldRefreshToken(String url) {
    final excludedEndpoints = ['/auth_login', '/register', '/refresh-token', '/otp', '/verify', 'auth_login', 'register', 'refresh-token', 'otp', 'verify'];

    return !excludedEndpoints.any((endpoint) => url.toLowerCase().contains(endpoint.toLowerCase()));
  }

  /// Parse response based on status code
  dynamic returnResponse(http.Response response) {
    // final url = response.request?.url.toString() ?? "---------Unknown URL--------";
    // print("🌐 $url : ${response.statusCode}");
    // print("📦 ${response.body}");

    switch (response.statusCode) {
      case 200:
      case 201:
        dynamic responseJson = jsonDecode(response.body);
        return responseJson;
      case 400:
        throw BadRequestException(response.body.toString());
      case 401:
        throw UnauthorisedException(response.body.toString());
      case 403:
        throw UnauthorisedException(response.body.toString());
      case 404:
        dynamic responseJson = jsonDecode(response.body);
        return responseJson;
      case 409:
        throw BadRequestException(response.body.toString());
      case 500:
        throw FetchDataException("Server error");
      default:
        throw FetchDataException('Error occurred while communicating with server with status code ${response.statusCode}');
    }
  }
}
