import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dinmajur_customer/configs/res/app_url.dart';
import 'package:dinmajur_customer/configs/services/session_expired_services/session_expired.dart';
import 'package:dinmajur_customer/model/user/user_model.dart';
import 'package:dinmajur_customer/view_model/userview_model/userview_model.dart';
import '../app_excaptions.dart';

class TokenManager {
  static final TokenManager _instance = TokenManager._internal();
  factory TokenManager() => _instance;
  TokenManager._internal();

  bool _isRefreshing = false;
  final List<Completer<String?>> _refreshQueue = [];

  /// Returns new access token, or throws.
  /// Caller should NOT catch — let it bubble to _handleResponse.
  Future<String> refreshAccessToken() async {
    // Queue concurrent calls instead of firing multiple refresh requests
    if (_isRefreshing) {
      final completer = Completer<String?>();
      _refreshQueue.add(completer);
      final token = await completer.future;
      if (token == null) throw UnauthorisedException('Session expired.');
      return token;
    }

    _isRefreshing = true;

    try {
      final prefs = await SharedPreferences.getInstance();
      final refreshToken = prefs.getString('refreshToken');

      if (refreshToken == null || refreshToken.isEmpty) {
        await _logout();
        _notifyQueue(null);
        throw UnauthorisedException('Session expired. Please login again.');
      }

      final response = await http
          .post(
            Uri.parse('${AppUrl.baseUrl}${AppUrl.refreshTokenEndpoint}'),
            headers: {'Content-Type': 'application/json', 'Authorization': refreshToken},
            body: jsonEncode({'refreshToken': refreshToken}),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final newToken = await _parseAndSaveTokens(response);
        _notifyQueue(newToken);
        return newToken;
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        // Refresh token itself expired → logout
        await _logout();
        _notifyQueue(null);
        throw UnauthorisedException('Session expired. Please login again.');
      } else {
        // Server/network error — do NOT logout
        _notifyQueue(null);
        throw FetchDataException('Token refresh failed: ${response.statusCode}');
      }
    } on SocketException {
      _notifyQueue(null);
      throw FetchDataException('No Internet Connection');
    } on TimeoutException {
      _notifyQueue(null);
      throw FetchDataException('Request timeout. Please try again');
    } finally {
      _isRefreshing = false;
    }
  }

  Future<String> _parseAndSaveTokens(http.Response response) async {
    final data = jsonDecode(response.body);
    if (data['success'] != true || data['data'] == null) {
      throw FetchDataException('Invalid refresh token response format');
    }

    final payload = data['data'];
    final newAccessToken = payload['accessToken'] as String?;
    final newRefreshToken = payload['refreshToken'] as String?;

    if (newAccessToken == null || newAccessToken.isEmpty) {
      throw FetchDataException('Invalid access token in refresh response');
    }

    // Persist updated tokens via UserViewModel
    final userViewModel = UserViewModel();
    final u = payload['user'];
    await userViewModel.saveUser(
      UserModel(
        success: true,
        message: data['message'] ?? 'Token refreshed',
        data: Data(
          accessToken: newAccessToken,
          refreshToken: newRefreshToken,
          user: User(
            id: u['_id'] ?? u['id'],
            userId: u['id'],
            phone: u['phone'],
            role: u['role'],
            userStatus: u['userStatus'],
            profilePicture: u['profilePicture'] != null ? ProfilePicture(url: u['profilePicture']['url'], altText: u['profilePicture']['altText']) : null,
          ),
        ),
      ),
    );

    return newAccessToken;
  }

  void _notifyQueue(String? token) {
    for (final c in _refreshQueue) {
      token != null ? c.complete(token) : c.complete(null);
    }
    _refreshQueue.clear();
  }

  Future<void> _logout() async {
    try {
      await SessionExpiredService().handleSessionExpired();
    } catch (e) {
    }
  }
}
