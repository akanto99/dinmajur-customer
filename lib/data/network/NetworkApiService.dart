import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:async';
import 'package:dinmajur_customer/configs/res/app_url.dart';
import 'package:dinmajur_customer/configs/services/session_expired_services/session_expired.dart';
import 'package:dinmajur_customer/model/user/user_model.dart';
import 'package:dinmajur_customer/view_model/userview_model/userview_model.dart';
import 'package:http/http.dart' as https;
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http_parser/http_parser.dart';
import '../app_excaptions.dart';
import 'BaseApiServices.dart';

class NetworkApiService extends BaseApiServices {
  static bool _isRefreshing = false;
  static List<Completer<String?>> _refreshQueue = [];
  static Map<String, int> _retryAttempts = {};
  static const int _maxRetries = 2;

  /// All Get Api Response
  @override
  Future getGetApiResponse(String url) async {
    dynamic responseJson;
    try {
      final response = await https.get(Uri.parse(url)).timeout(const Duration(seconds: 30));
      responseJson = await _handleResponse(response, url, () => getGetApiResponse(url));
    } on SocketException catch (e) {
      print('$e');
      throw FetchDataException('No Internet Connection');
    } on TimeoutException {
      throw FetchDataException('Request timeout. Please try again');
    }
    return responseJson;
  }

  /// Header Get Api
  @override
  Future<dynamic> getGetApiWithHeaderResponse(String url, {Map<String, String>? headers}) async {
    dynamic responseJson;
    try {
      final authHeaders = await _getAuthHeaders(headers);

      final response = await https.get(Uri.parse(url), headers: authHeaders).timeout(const Duration(seconds: 30));

      responseJson = await _handleResponse(response, url, () => getGetApiWithHeaderResponse(url, headers: headers));
      print("-----${response.body}");
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
    print(responseJson);
    print("A");
    try {
      Response response = await post(Uri.parse(url), body: data).timeout(Duration(seconds: 30));
      print(response.body);
      responseJson = await _handleResponse(response, url, () => getPostApiResponse(url, data));
    } on SocketException {
      throw FetchDataException('No Internet Connection');
    } on TimeoutException {
      throw FetchDataException('Request timeout. Please try again');
    }
    return responseJson;
  }

  @override
  Future getPostApiWithOutBodyresponse(String url, {Map<String, String>? headers}) async {
    try {
      final authHeaders = await _getAuthHeaders(headers);

      final response = await https.post(Uri.parse(url), headers: authHeaders).timeout(const Duration(seconds: 30));

      return await _handleResponse(response, url, () => getPostApiWithOutBodyresponse(url, headers: headers));
    } on SocketException {
      throw FetchDataException('No Internet Connection');
    } on TimeoutException {
      throw FetchDataException('Request timeout. Please try again');
    }
  }

  // @override
  // Future gePostApiWithHeaderesponse(String url, dynamic data, {Map<String, String>? headers}) async {
  //   try {
  //     final response = await https.post(Uri.parse(url), body: jsonEncode(data), headers: headers ?? {'Content-Type': 'application/json'}).timeout(const Duration(seconds: 120));
  //     return await _handleResponse(response, url, () => gePostApiWithHeaderesponse(url, data, headers: headers));
  //   } on SocketException {
  //     throw FetchDataException('No Internet Connection');
  //   } on TimeoutException {
  //     throw FetchDataException('Request timeout. Please try again');
  //   }
  // }
  // @override
  // Future gePostApiWithHeaderesponse(String url, dynamic data, {Map<String, String>? headers}) async {
  //   try {
  //     final authHeaders = await _getAuthHeaders(headers);
  //
  //     // Corrected: Moved .timeout() to the end of the post call
  //     final response = await https.post(Uri.parse(url), body: jsonEncode(data), headers: authHeaders).timeout(const Duration(seconds: 30));
  //
  //     return await _handleResponse(response, url, () => gePostApiWithHeaderesponse(url, data, headers: authHeaders));
  //   } on SocketException {
  //     throw FetchDataException('No Internet Connection');
  //   } on TimeoutException {
  //     throw FetchDataException('Request timeout. Please try again');
  //   }
  // }
  ///Corrected
  // ✅ Fetch auth headers fresh each time (including on retries)
  // ✅ Pass null for headers so retry will fetch fresh headers
  @override
  Future gePostApiWithHeaderesponse(String url, dynamic data, {Map<String, String>? headers}) async {
    try {
      // ✅ Fetch auth headers fresh each time (including on retries)
      final authHeaders = await _getAuthHeaders(headers);
      final response = await https.post(Uri.parse(url), body: jsonEncode(data), headers: authHeaders).timeout(const Duration(seconds: 30));
      // ✅ Pass null for headers so retry will fetch fresh headers
      return await _handleResponse(response, url, () => gePostApiWithHeaderesponse(url, data), // Don't pass old headers
      );
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
      final response = await https.post(Uri.parse(url), body: jsonEncode(data), headers: headers ?? {'Content-Type': 'application/json'}).timeout(const Duration(seconds: 120));
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
      var response = await https
          .post(Uri.parse(url), headers: headers ?? {'Content-Type': 'application/json', 'Accept': 'application/json'}, body: jsonEncode(fields))
          .timeout(const Duration(seconds: 30));
      return await _handleResponse(response, url, () => getMultiStepPostApiResponse(url, fields, headers: headers));
    } on SocketException catch (e) {
      print('$e');
      throw FetchDataException('No Internet Connection');
    } on TimeoutException {
      throw FetchDataException('Request timeout. Please try again');
    }
  }

  /// Image upload now accepts Uint8List imageBytes instead of Map<String,String> && header pass access token
  @override
  Future<dynamic> imageMultipartPostApiResponse(String url, Uint8List imageBytes, String fileName, String imageType, {Map<String, String>? headers}) async {
    try {
      var request = https.MultipartRequest('POST', Uri.parse(url));
      if (headers != null) {
        request.headers.addAll(headers);
      }
      // Add the imageType field
      request.fields['imageType'] = imageType;

      // Determine content type based on file extension
      MediaType contentType = _getContentType(fileName);
      var multipartFile = https.MultipartFile.fromBytes('image', imageBytes, filename: fileName, contentType: contentType);
      request.files.add(multipartFile);
      var streamedResponse = await request.send().timeout(const Duration(seconds: 30));
      var response = await https.Response.fromStream(streamedResponse);
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
      var request = https.MultipartRequest('POST', Uri.parse(url));

      if (headers != null) {
        request.headers.addAll(headers);
      }

      // Add the documentType field
      request.fields['documentType'] = documentType;

      // Determine content type based on file extension
      MediaType contentType = _getContentType(fileName);

      // Add the file with 'document' key and dynamic filename
      var multipartFile = https.MultipartFile.fromBytes(
        'document',
        pdfImageBytes,
        filename: fileName, // Use the dynamic filename
        contentType: contentType, // Use appropriate content type
      );

      request.files.add(multipartFile);

      var streamedResponse = await request.send().timeout(const Duration(seconds: 30));
      var response = await https.Response.fromStream(streamedResponse);
      print("---Status: ${response.statusCode}");
      print("---Response: ${response.body}");
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
  @override
  Future getPatchApiResponse(String url, dynamic data, {Map<String, String>? headers}) async {
    dynamic responseJson;
    try {
      final response = await https
          .patch(
            Uri.parse(url),
            headers: {
              'Content-Type': 'application/json',
              ...?headers, // Merge additional headers (like authorization)
            },
            body: jsonEncode(data),
          )
          .timeout(const Duration(seconds: 30));
      print(" ${response.statusCode}");
      print(" ${response.body}");
      responseJson = await _handleResponse(response, url, () => getPatchApiResponse(url, data, headers: headers));
    } on SocketException {
      throw FetchDataException('No Internet Connection');
    } on TimeoutException {
      throw FetchDataException('Request timeout. Please try again');
    }
    return responseJson;
  }

  /// Same url, data, header ------>   {Create Area Address}
  @override
  Future getsamePostApiResponse(String url, dynamic data, {Map<String, String>? headers}) async {
    dynamic responseJson;
    try {
      https.Response response = await https
          .post(
            Uri.parse(url),
            headers: headers ?? {'Content-Type': 'application/json'},
            body: jsonEncode(data), // Encode data as JSON
          )
          .timeout(const Duration(seconds: 30));
      responseJson = await _handleResponse(response, url, () => getsamePostApiResponse(url, data, headers: headers));
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
      print('🔄 Making PUT request to: $url');
      print('📤 PUT Data: ${jsonEncode(data)}');
      print('📋 Headers: $headers');

      final response = await https.put(Uri.parse(url), body: jsonEncode(data), headers: headers ?? {'Content-Type': 'application/json'}).timeout(const Duration(seconds: 30));

      print('📥 PUT Response Status: ${response.statusCode}');
      print('📥 PUT Response Body: ${response.body}');

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
      // Get auth headers (includes access token)
      final authHeaders = await _getAuthHeaders(headers);

      var request = https.MultipartRequest('PATCH', Uri.parse(url));
      request.headers.addAll(authHeaders);

      request.files.add(https.MultipartFile.fromBytes('logo', imageBytes, filename: fileName));

      final streamedResponse = await request.send().timeout(const Duration(seconds: 30));
      final response = await https.Response.fromStream(streamedResponse);

      // Use _handleResponse for proper token refresh handling
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
      // Get auth headers (includes access token)
      final authHeaders = await _getAuthHeaders(headers);

      var request = https.MultipartRequest('PATCH', Uri.parse(url));
      request.headers.addAll(authHeaders);

      // Add the imageType field
      request.fields['imageType'] = imageType;

      // Determine content type based on file extension
      MediaType contentType = _getContentType(fileName);
      request.files.add(https.MultipartFile.fromBytes('image', imageBytes, filename: fileName, contentType: contentType));

      final streamedResponse = await request.send().timeout(const Duration(seconds: 30));
      final response = await https.Response.fromStream(streamedResponse);

      // Use _handleResponse for proper token refresh handling
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
      // Get auth headers (includes access token)
      final authHeaders = await _getAuthHeaders(headers);

      var request = https.MultipartRequest('PATCH', Uri.parse(url));
      request.headers.addAll(authHeaders);

      // Add the documentType field
      request.fields['documentType'] = documentType;

      // Determine content type based on file extension
      MediaType contentType = _getContentType(fileName);

      request.files.add(https.MultipartFile.fromBytes('document', pdfImageBytes, filename: fileName, contentType: contentType));

      final streamedResponse = await request.send().timeout(const Duration(seconds: 30));
      final response = await https.Response.fromStream(streamedResponse);

      print("---Status: ${response.statusCode}");
      print("---Response: ${response.body}");

      // Use _handleResponse for proper token refresh handling
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
      final response = await https.delete(Uri.parse(url), headers: headers ?? {'Content-Type': 'application/json'}).timeout(const Duration(seconds: 30));

      print('delete Response Status: ${response.statusCode}');
      print('delete Response Body: ${response.body}');

      responseJson = await _handleResponse(response, url, () => getDeleteApiResponse(url, headers: headers));
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

    Map<String, String> headers = {'Content-Type': 'application/json', 'Accept': 'application/json'};

    if (accessToken != null && accessToken.isNotEmpty) {
      headers['Authorization'] = '$accessToken';
    }

    if (additionalHeaders != null) {
      headers.addAll(additionalHeaders);
    }

    return headers;
  }

  Future<String?> _refreshAccessToken() async {
    // If already refreshing, wait for the result
    if (_isRefreshing) {
      final completer = Completer<String?>();
      _refreshQueue.add(completer);
      return completer.future;
    }

    _isRefreshing = true;

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? refreshToken = prefs.getString('refreshToken');

      if (refreshToken == null || refreshToken.isEmpty) {
        print('❌ No refresh token available in storage');
        await _handleLogout();

        for (final completer in _refreshQueue) {
          completer.complete(null);
        }
        _refreshQueue.clear();

        throw Exception('Refresh token expired');
      }

      print('🔄 Attempting to refresh access token...');
      print('🔑 Using refresh token: ${refreshToken.substring(0, 20)}...');

      final response = await https
          .post(
            Uri.parse('${AppUrl.baseUrl}${AppUrl.refreshTokenEndpoint}'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': refreshToken, // ✅ Pass as Authorization header
            },
            body: jsonEncode({'refreshToken': refreshToken}),
          )
          .timeout(const Duration(seconds: 30));

      print('🔄 Refresh token API response status: ${response.statusCode}');
      print('🔄 Refresh token API response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);

        if (responseData['success'] == true && responseData['data'] != null) {
          final data = responseData['data'];
          final newAccessToken = data['accessToken'];
          final newRefreshToken = data['refreshToken'];

          if (newAccessToken != null && newAccessToken.isNotEmpty) {
            // ✅ Get current user data
            final userViewModel = UserViewModel();
            final currentUser = await userViewModel.getUser();

            // ✅ Create updated user model with new access token
            // but PRESERVE the existing refresh token (server doesn't return new one)
            final updatedUserModel = UserModel(
              success: true,
              message: responseData['message'] ?? 'Token refreshed successfully',
              data: Data(
                accessToken: newAccessToken,
                refreshToken: newRefreshToken,
                user: User(
                  id: data['user']['_id'] ?? data['user']['id'],
                  userId: data['user']['id'],
                  phone: data['user']['phone'],
                  role: data['user']['role'],
                  userStatus: data['user']['userStatus'],
                  isRegistered: data['user']['isRegistered'],
                  isPhoneVerified: data['user']['isPhoneVerified'],
                  firstName: data['user']['firstName'],
                  lastName: data['user']['lastName'],
                  profilePicture: data['user']['profilePicture'] != null ? ProfilePicture(url: data['user']['profilePicture']['url'], altText: data['user']['profilePicture']['altText']) : null,
                  isDeliveryPerson: currentUser.data?.user?.isDeliveryPerson ?? false,
                  checkedJoinUs: currentUser.data?.user?.checkedJoinUs ?? false,
                  checkedSelectServices: currentUser.data?.user?.checkedSelectServices ?? false,
                  checkedSelectArea: currentUser.data?.user?.checkedSelectArea ?? false,
                ),
              ),
            );

            // ✅ Save updated user data
            await userViewModel.saveUser(updatedUserModel);

            print('✅ Access token refreshed successfully');
            print('🔑 New access token: ${newAccessToken.substring(0, 20)}...');
            print('🔄 Refresh token preserved: ${currentUser.data?.refreshToken?.substring(0, 20)}...');

            // Notify all waiting requests with success
            for (final completer in _refreshQueue) {
              completer.complete(newAccessToken);
            }
            _refreshQueue.clear();

            return newAccessToken;
          } else {
            print('❌ Invalid access token received in refresh response');
            throw Exception('Invalid access token received');
          }
        } else {
          print('❌ Invalid response format from refresh token API');
          throw Exception('Invalid response format');
        }
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        // ✅ ONLY logout when refresh token itself is expired/invalid
        print('❌ REFRESH TOKEN EXPIRED (401/403) - LOGGING OUT USER');
        await _handleLogout();

        for (final completer in _refreshQueue) {
          completer.complete(null);
        }
        _refreshQueue.clear();

        throw Exception('Refresh token expired');
      } else {
        // ✅ Other errors (500, network issues) - DON'T logout
        print('❌ Refresh token API failed with status: ${response.statusCode} - NOT LOGGING OUT');

        for (final completer in _refreshQueue) {
          completer.complete(null);
        }
        _refreshQueue.clear();

        throw Exception('Token refresh failed with status: ${response.statusCode}');
      }
    } on SocketException {
      throw FetchDataException('No Internet Connection');
    } on TimeoutException {
      throw FetchDataException('Request timeout. Please try again');
    } catch (e) {
      if (e.toString().contains('Refresh token expired')) {
        for (final completer in _refreshQueue) {
          completer.complete(null);
        }
        _refreshQueue.clear();
      } else {
        // For other errors, still notify waiting requests
        for (final completer in _refreshQueue) {
          completer.complete(null);
        }
        _refreshQueue.clear();
      }

      return null;
    } finally {
      _isRefreshing = false;
    }
  }

  /// Handle API response with automatic token refresh
  Future<dynamic> _handleResponse(https.Response response, String originalUrl, Future<dynamic> Function() retryFunction) async {
    print('📡 Response from $originalUrl: ${response.statusCode}');

    if (response.statusCode == 401) {
      print('🔒 Unauthorized response detected for: $originalUrl');

      // ✅ Check retry count for this URL
      int retryCount = _retryAttempts[originalUrl] ?? 0;

      if (retryCount >= _maxRetries) {
        print('🛑 Max retries ($retryCount) exceeded for: $originalUrl');
        _retryAttempts.remove(originalUrl);
        throw UnauthorisedException('Session expired. Please login again.');
      }

      // Check if this is an API call that should trigger refresh
      if (_shouldRefreshToken(originalUrl)) {
        print('🔄 Attempting token refresh for URL: $originalUrl (Retry: ${retryCount + 1}/$_maxRetries)');

        try {
          final newAccessToken = await _refreshAccessToken();

          if (newAccessToken != null && newAccessToken.isNotEmpty) {
            print('✅ Token refreshed successfully, retrying original request');

            // ✅ Increment retry counter
            _retryAttempts[originalUrl] = retryCount + 1;

            // Retry the original request with new token
            final result = await retryFunction();

            // ✅ Success - clear retry counter
            _retryAttempts.remove(originalUrl);

            return result;
          } else {
            print('❌ Token refresh returned null - refresh token likely expired');
            _retryAttempts.remove(originalUrl);
            throw UnauthorisedException('Session expired. Please login again.');
          }
        } catch (e) {
          print('❌ Token refresh exception: $e');
          _retryAttempts.remove(originalUrl);

          if (e.toString().contains('Refresh token expired')) {
            throw UnauthorisedException('Session expired. Please login again.');
          } else {
            throw FetchDataException('Unable to refresh session: ${e.toString()}');
          }
        }
      } else {
        print('🔒 401 response for excluded endpoint: $originalUrl');
        throw UnauthorisedException('Authentication failed');
      }
    }

    // ✅ Success response - clear any retry counters for this URL
    _retryAttempts.remove(originalUrl);

    return returnResponse(response);
  }

  /// Handle logout only when both tokens are expired/invalid
  Future<void> _handleLogout() async {
    try {
      final navigationService = SessionExpiredService();
      await navigationService.handleSessionExpired();
      print('🚪 User logged out due to token expiry');
    } catch (e) {
      print('❌ Error during logout: $e');
    }
  }

  /// Check if the URL should trigger token refresh
  bool _shouldRefreshToken(String url) {
    final excludedEndpoints = ['/login', '/register', '/refresh-token', '/otp', '/verify', 'login', 'register', 'refresh-token', 'otp', 'verify'];

    return !excludedEndpoints.any((endpoint) => url.toLowerCase().contains(endpoint.toLowerCase()));
  }

  /// Static method to clear retry attempts
  static void clearRetryAttempts() {
    _retryAttempts.clear();
  }

  /// Parse response based on status code
  dynamic returnResponse(https.Response response) {
    switch (response.statusCode) {
      case 200:
      case 201:
        dynamic responseJson = jsonDecode(response.body);
        print('✅ Parsed response JSON: $responseJson');
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
