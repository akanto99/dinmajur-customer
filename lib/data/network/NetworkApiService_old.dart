//
//
//
// import 'dart:convert';
// import 'dart:io';
// import 'dart:typed_data';
// import 'package:dinmajur_customer/configs/res/app_url.dart';
// import 'package:dinmajur_customer/model/user/user_model.dart';
// import 'package:dinmajur_customer/view_model/userview_model/userview_model.dart';
// import 'package:http/http.dart' as http;
// import 'package:http/http.dart' as https;
// import 'package:shared_preferences/shared_preferences.dart';
// import '../app_excaptions.dart';
// import 'BaseApiServices.dart';
// import 'package:http_parser/http_parser.dart';
// import 'dart:async';
//
// class NetworkApiServiceOld extends BaseApiServices {
//   static bool _isRefreshing = false;
//   static List<Completer<String?>> _refreshQueue = [];
//
//   // Constants for better maintainability
//   static const Duration _defaultTimeout = Duration(seconds: 30);
//   static const Duration _uploadTimeout = Duration(seconds: 120);
//
//   /// GET API Response
//   @override
//   Future getGetApiResponse(String url) async {
//     try {
//       final response = await http.get(Uri.parse(url))
//           .timeout(_defaultTimeout);
//
//       return await _handleResponse(
//           response,
//           url,
//               () => getGetApiResponse(url)
//       );
//     } on SocketException {
//       throw FetchDataException('No Internet Connection');
//     } on TimeoutException {
//       throw FetchDataException('Request timeout. Please try again');
//     }
//   }
//
//   /// GET API with Headers
//   @override
//   Future<dynamic> getGetApiWithHeaderResponse(String url, {Map<String, String>? headers}) async {
//     try {
//       final authHeaders = await _getAuthHeaders(headers);
//
//       final response = await http.get(
//         Uri.parse(url),
//         headers: authHeaders,
//       ).timeout(_defaultTimeout);
//
//       return await _handleResponse(
//           response,
//           url,
//               () => getGetApiWithHeaderResponse(url, headers: headers)
//       );
//     } on SocketException {
//       throw FetchDataException('No Internet Connection');
//     } on TimeoutException {
//       throw FetchDataException('Request timeout. Please try again');
//     }
//   }
//
//   /// POST API Response (form-encoded)
//   @override
//   Future getPostApiResponse(String url, dynamic data) async {
//     try {
//       final response = await http.post(
//         Uri.parse(url),
//         body: data, // Assuming form-encoded data
//       ).timeout(_defaultTimeout);
//
//       return await _handleResponse(
//           response,
//           url,
//               () => getPostApiResponse(url, data)
//       );
//     } on SocketException {
//       throw FetchDataException('No Internet Connection');
//     } on TimeoutException {
//       throw FetchDataException('Request timeout. Please try again');
//     }
//   }
//
//   /// POST API with Headers (JSON-encoded)
//   @override
//   Future gePostApiWithHeaderesponse(String url, dynamic data, {Map<String, String>? headers}) async {
//     try {
//       final authHeaders = await _getAuthHeaders(headers);
//
//       final response = await http.post(
//         Uri.parse(url),
//         body: jsonEncode(data),
//         headers: authHeaders,
//       ).timeout(_uploadTimeout);
//
//       return await _handleResponse(
//           response,
//           url,
//               () => gePostApiWithHeaderesponse(url, data, headers: headers)
//       );
//     } on SocketException {
//       throw FetchDataException('No Internet Connection');
//     } on TimeoutException {
//       throw FetchDataException('Request timeout. Please try again');
//     }
//   }
//
//   /// OTP POST API Response
//   @override
//   Future getOTPPostApiResponse(String url, dynamic data, {Map<String, String>? headers}) async {
//     try {
//       final defaultHeaders = {
//         'Content-Type': 'application/json',
//       };
//
//       final finalHeaders = headers ?? defaultHeaders;
//       if (headers != null) {
//         finalHeaders.addAll(headers);
//       }
//
//       final response = await http.post(
//         Uri.parse(url),
//         body: jsonEncode(data),
//         headers: finalHeaders,
//       ).timeout(_uploadTimeout);
//
//       return await _handleResponse(
//           response,
//           url,
//               () => getOTPPostApiResponse(url, data, headers: headers)
//       );
//     } on SocketException {
//       throw FetchDataException('No Internet Connection');
//     } on TimeoutException {
//       throw FetchDataException('Request timeout. Please try again');
//     }
//   }
//
//   /// Multi-step POST API Response
//   @override
//   Future<dynamic> getMultiStepPostApiResponse(
//       String url,
//       Map<String, dynamic> fields, {
//         Map<String, String>? headers,
//       }) async {
//     try {
//       final authHeaders = await _getAuthHeaders(headers);
//
//       final response = await http.post(
//         Uri.parse(url),
//         headers: authHeaders,
//         body: jsonEncode(fields),
//       ).timeout(_defaultTimeout);
//
//       return await _handleResponse(
//           response,
//           url,
//               () => getMultiStepPostApiResponse(url, fields, headers: headers)
//       );
//     } on SocketException {
//       throw FetchDataException('No Internet Connection');
//     } on TimeoutException {
//       throw FetchDataException('Request timeout. Please try again');
//     }
//   }
//
//   /// Image Multipart POST API Response
//   @override
//   Future<dynamic> imageMultipartPostApiResponse(
//       String url,
//       String fileName,
//       String imageType,
//       Uint8List imageBytes, {
//         Map<String, String>? headers,
//       }) async {
//     try {
//       final authHeaders = await _getAuthHeaders(headers);
//
//       var request = http.MultipartRequest('POST', Uri.parse(url));
//       request.headers.addAll(authHeaders);
//       request.fields['imageType'] = imageType;
//
//       // Determine content type based on file extension
//       MediaType contentType = _getContentType(fileName);
//
//       var multipartFile = http.MultipartFile.fromBytes(
//         'profilePicture',
//         imageBytes,
//         filename: fileName,
//         contentType: contentType,
//       );
//       request.files.add(multipartFile);
//
//       var streamedResponse = await request.send().timeout(_defaultTimeout);
//       var response = await http.Response.fromStream(streamedResponse);
//
//       return await _handleResponse(
//           response,
//           url,
//               () => imageMultipartPostApiResponse(url, fileName, imageType, imageBytes, headers: headers)
//       );
//     } on SocketException {
//       throw FetchDataException('No Internet Connection');
//     } on TimeoutException {
//       throw FetchDataException('Request timeout. Please try again');
//     }
//   }
//
//   /// PATCH API Response
//   @override
//   Future getPatchApiResponse(String url, dynamic data, {Map<String, String>? headers}) async {
//     try {
//       final authHeaders = await _getAuthHeaders(headers);
//
//       final response = await http.patch(
//         Uri.parse(url),
//         headers: authHeaders,
//         body: jsonEncode(data),
//       ).timeout(_defaultTimeout);
//
//       return await _handleResponse(
//           response,
//           url,
//               () => getPatchApiResponse(url, data, headers: headers)
//       );
//     } on SocketException {
//       throw FetchDataException('No Internet Connection');
//     } on TimeoutException {
//       throw FetchDataException('Request timeout. Please try again');
//     }
//   }
//
//   /// PUT API Response
//   @override
//   Future getPutApiResponse(String url, dynamic data, {Map<String, String>? headers}) async {
//     try {
//       final authHeaders = await _getAuthHeaders(headers);
//
//       final response = await http.put(
//         Uri.parse(url),
//         body: jsonEncode(data),
//         headers: authHeaders,
//       ).timeout(_defaultTimeout);
//
//       return await _handleResponse(
//           response,
//           url,
//               () => getPutApiResponse(url, data, headers: headers)
//       );
//     } on SocketException {
//       throw FetchDataException('No Internet Connection');
//     } on TimeoutException {
//       throw FetchDataException('Request timeout. Please try again');
//     }
//   }
//
//   /// PATCH Image API Response
//   @override
//   Future getPatchApiImageResponse(String url, Uint8List imageBytes, {Map<String, String>? headers}) async {
//     try {
//       final authHeaders = await _getAuthHeaders(headers);
//
//       var request = http.MultipartRequest('PATCH', Uri.parse(url));
//       request.headers.addAll(authHeaders);
//
//       request.files.add(
//         http.MultipartFile.fromBytes(
//           'profilePicture',
//           imageBytes,
//           filename: 'profile_image.jpg',
//           contentType: MediaType('image', 'jpeg'),
//         ),
//       );
//
//       final streamedResponse = await request.send().timeout(_defaultTimeout);
//       final response = await http.Response.fromStream(streamedResponse);
//
//       return await _handleResponse(
//           response,
//           url,
//               () => getPatchApiImageResponse(url, imageBytes, headers: headers)
//       );
//     } on SocketException {
//       throw FetchDataException('No Internet Connection');
//     } on TimeoutException {
//       throw FetchDataException('Request timeout. Please try again');
//     }
//   }
//
//   /// Same POST API Response (for specific use cases)
//   @override
//   Future getsamePostApiResponse(String url, dynamic data, {Map<String, String>? headers}) async {
//     try {
//       final authHeaders = await _getAuthHeaders(headers);
//
//       final response = await http.post(
//         Uri.parse(url),
//         headers: authHeaders,
//         body: jsonEncode(data),
//       ).timeout(_defaultTimeout);
//
//       return await _handleResponse(
//           response,
//           url,
//               () => getsamePostApiResponse(url, data, headers: headers)
//       );
//     } on SocketException {
//       throw FetchDataException('No Internet Connection');
//     } on TimeoutException {
//       throw FetchDataException('Request timeout. Please try again');
//     }
//   }
//
//   /// DELETE API Response
//   @override
//   Future getDeleteApiResponse(String url, {Map<String, String>? headers}) async {
//     try {
//       final authHeaders = await _getAuthHeaders(headers);
//
//       final response = await http.delete(
//         Uri.parse(url),
//         headers: authHeaders,
//       ).timeout(_defaultTimeout);
//
//       return await _handleResponse(
//           response,
//           url,
//               () => getDeleteApiResponse(url, headers: headers)
//       );
//     } on SocketException {
//       throw FetchDataException('No Internet Connection');
//     } on TimeoutException {
//       throw FetchDataException('Request timeout. Please try again');
//     }
//   }
//
//   /// Helper method to get headers with authentication
//   Future<Map<String, String>> _getAuthHeaders([Map<String, String>? additionalHeaders]) async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     String? accessToken = prefs.getString('accessToken');
//
//     Map<String, String> headers = {
//       'Content-Type': 'application/json',
//       'Accept': 'application/json',
//     };
//
//     if (accessToken != null && accessToken.isNotEmpty) {
//       headers['Authorization'] = 'Bearer $accessToken';
//     }
//
//     if (additionalHeaders != null) {
//       headers.addAll(additionalHeaders);
//     }
//
//     return headers;
//   }
//
//   /// Enhanced response handler with automatic token refresh
//   Future<dynamic> _handleResponse(
//       http.Response response,
//       String originalUrl,
//       Future<dynamic> Function() retryFunction
//       ) async {
//     // Handle 401 Unauthorized - attempt token refresh
//     if (response.statusCode == 401 && _shouldRefreshToken(originalUrl)) {
//       try {
//         final newAccessToken = await _refreshAccessToken();
//         if (newAccessToken != null) {
//           // Retry the original request with new token
//           return await retryFunction();
//         } else {
//           // Refresh failed, logout user
//           await _handleLogout();
//           throw UnauthorisedExceptionLogin('Session expired. Please login again.');
//         }
//       } catch (e) {
//         await _handleLogout();
//         throw UnauthorisedExceptionLogin('Session expired. Please login again.');
//       }
//     }
//
//     return _returnResponse(response);
//   }
//
//   /// Check if the URL should trigger token refresh
//   bool _shouldRefreshToken(String url) {
//     final excludedEndpoints = [
//       '/login',
//       '/register',
//       '/refresh-token',
//       '/otp',
//       '/verify'
//     ];
//
//     return !excludedEndpoints.any((endpoint) => url.contains(endpoint));
//   }
//
//   /// Refresh access token with queue management
//   Future<String?> _refreshAccessToken() async {
//     if (_isRefreshing) {
//       // Wait for ongoing refresh
//       final completer = Completer<String?>();
//       _refreshQueue.add(completer);
//       return completer.future;
//     }
//
//     _isRefreshing = true;
//
//     try {
//       SharedPreferences prefs = await SharedPreferences.getInstance();
//       String? refreshToken = prefs.getString('refreshToken');
//
//       if (refreshToken == null || refreshToken.isEmpty) {
//         throw Exception('No refresh token available');
//       }
//
//       final response = await http.post(
//         Uri.parse('${AppUrl.baseUrl}${AppUrl.refreshTokenEndpoint}'),
//         headers: {
//           'Content-Type': 'application/json',
//         },
//         body: jsonEncode({
//           'refreshToken': refreshToken,
//         }),
//       ).timeout(_defaultTimeout);
//
//       if (response.statusCode == 200 || response.statusCode == 201) {
//         final responseData = jsonDecode(response.body);
//
//         if (responseData['success'] == true && responseData['data'] != null) {
//           // Parse the new user data
//           final userModel = UserModel.fromJson(responseData);
//
//           // Update stored user data
//           final userViewModel = UserViewModel();
//           await userViewModel.saveUser(userModel);
//
//           final newAccessToken = userModel.data?.accessToken;
//
//           // Notify all waiting requests
//           for (final completer in _refreshQueue) {
//             completer.complete(newAccessToken);
//           }
//           _refreshQueue.clear();
//
//           return newAccessToken;
//         }
//       }
//
//       throw Exception('Token refresh failed with status: ${response.statusCode}');
//     } catch (e) {
//       print('Token refresh error: $e');
//
//       // Notify all waiting requests of failure
//       for (final completer in _refreshQueue) {
//         completer.complete(null);
//       }
//       _refreshQueue.clear();
//
//       return null;
//     } finally {
//       _isRefreshing = false;
//     }
//   }
//
//   /// Handle logout when token refresh fails
//   Future<void> _handleLogout() async {
//     try {
//       final userViewModel = UserViewModel();
//       await userViewModel.remove();
//       print('User logged out due to token expiry');
//     } catch (e) {
//       print('Error during logout: $e');
//     }
//   }
//
//   /// Helper method to determine content type based on file extension
//   MediaType _getContentType(String fileName) {
//     final extension = fileName.toLowerCase().split('.').last;
//
//     final contentTypeMap = {
//       'pdf': MediaType('application', 'pdf'),
//       'jpg': MediaType('image', 'jpeg'),
//       'jpeg': MediaType('image', 'jpeg'),
//       'png': MediaType('image', 'png'),
//       'gif': MediaType('image', 'gif'),
//       'bmp': MediaType('image', 'bmp'),
//       'webp': MediaType('image', 'webp'),
//       'doc': MediaType('application', 'msword'),
//       'docx': MediaType('application', 'vnd.openxmlformats-officedocument.wordprocessingml.document'),
//       'xls': MediaType('application', 'vnd.ms-excel'),
//       'xlsx': MediaType('application', 'vnd.openxmlformats-officedocument.spreadsheetml.sheet'),
//       'txt': MediaType('text', 'plain'),
//     };
//
//     return contentTypeMap[extension] ?? MediaType('application', 'octet-stream');
//   }
//
//   /// Handle different HTTP response status codes
//   dynamic _returnResponse(https.Response response) {
//     switch (response.statusCode) {
//       case 200:
//       case 201:
//         dynamic responseJson = jsonDecode(response.body);
//         print('✅ Parsed response JSON: $responseJson');
//         return responseJson;
//       case 400:
//         throw BadRequestException(response.body.toString());
//       case 401:
//         throw UnauthorisedExceptionLogin(response.body.toString());
//       case 403:
//         throw UnauthorisedExceptionLogin(response.body.toString());
//       case 422:
//         final dynamic responseBody = jsonDecode(response.body);
//         final dynamic data = responseBody['data'];
//         if (data != null && data is Map<String, dynamic>) {
//           final List<dynamic>? emailErrors = data['email'];
//         }
//         throw UnauthorisedExceptionLogin("Unknown validation error occurred");
//       case 500:
//         throw FetchDataException("Server error");
//       case 404:
//         dynamic responseJson = jsonDecode(response.body);
//         return responseJson;
//       case 409:
//         throw BadRequestException(response.body.toString());
//       default:
//         throw FetchDataException('Error occurred while communicating with server' +
//             ' with status code ' + response.statusCode.toString());
//     }
//   }
//
//   /// Parse error message from response body
//   String _parseErrorMessage(String responseBody) {
//     try {
//       final json = jsonDecode(responseBody);
//       return json['message'] ?? json['error'] ?? 'Unknown error occurred';
//     } catch (e) {
//       return responseBody.isNotEmpty ? responseBody : 'Unknown error occurred';
//     }
//   }
//
//   /// Parse validation errors from 422 responses
//   String _parseValidationErrors(String responseBody) {
//     try {
//       final json = jsonDecode(responseBody);
//       final data = json['data'];
//
//       if (data != null && data is Map<String, dynamic>) {
//         final errors = <String>[];
//         data.forEach((field, messages) {
//           if (messages is List) {
//             errors.addAll(messages.map((msg) => '$field: $msg'));
//           }
//         });
//         return errors.isNotEmpty ? errors.join(', ') : 'Validation error occurred';
//       }
//
//       return json['message'] ?? 'Validation error occurred';
//     } catch (e) {
//       return 'Validation error occurred';
//     }
//   }
// }