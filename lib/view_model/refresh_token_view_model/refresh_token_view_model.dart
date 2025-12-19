import 'dart:async';
import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/sizedbox_spaccing.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:dinmajur_customer/configs/services/session_expired_services/session_expired.dart';
import 'package:dinmajur_customer/configs/services/navigator_services/navigator_services_refreshToken.dart';
import 'package:dinmajur_customer/model/user/user_model.dart';
import 'package:dinmajur_customer/respository/refresh_token_repository/refresh_token_repository.dart';
import 'package:dinmajur_customer/view_model/userview_model/userview_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RefreshTokenViewModel with ChangeNotifier {
  RefreshTokenRepository? _refreshTokenRepo;
  UserViewModel? _userViewModel;

  RefreshTokenRepository get refreshTokenRepo {
    _refreshTokenRepo ??= RefreshTokenRepository();
    return _refreshTokenRepo!;
  }

  UserViewModel get userViewModel {
    _userViewModel ??= UserViewModel();
    return _userViewModel!;
  }

  static bool _isRefreshing = false;
  static List<Completer<String?>> _refreshQueue = [];

  bool get isRefreshing => _isRefreshing;

  /// Refresh access token
  Future<String?> refreshToken() async {
    // If already refreshing, wait for the result
    if (_isRefreshing) {
      final completer = Completer<String?>();
      _refreshQueue.add(completer);
      return completer.future;
    }

    _isRefreshing = true;
    notifyListeners();

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? refreshToken = prefs.getString('refreshToken');

      if (refreshToken == null || refreshToken.isEmpty) {
        print('❌ No refresh token available in storage');
        await _handleSessionExpired();
        return null;
      }

      print('🔄 Attempting to refresh access token...');
      print('🔑 Using refresh token: ${refreshToken.substring(0, 20)}...');

      final response = await refreshTokenRepo.refreshAccessToken(refreshToken);

      print('🔄 Refresh token API response: $response');

      if (response['success'] == true && response['data'] != null) {
        final data = response['data'];
        final newAccessToken = data['accessToken'];
        final newRefreshToken = data['refreshToken'];

        if (newAccessToken != null && newAccessToken.isNotEmpty) {
          final currentUser = await userViewModel.getUser();

          // Create updated user model with new tokens
          final updatedUserModel = UserModel(
            success: true,
            message: response['message'] ?? 'Token refreshed successfully',
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
                profilePicture: data['user']['profilePicture'] != null
                    ? ProfilePicture(
                    url: data['user']['profilePicture']['url'],
                    altText: data['user']['profilePicture']['altText'])
                    : null,
                isDeliveryPerson: currentUser.data?.user?.isDeliveryPerson ?? false,
                checkedJoinUs: currentUser.data?.user?.checkedJoinUs ?? false,
                checkedSelectServices: currentUser.data?.user?.checkedSelectServices ?? false,
                checkedSelectArea: currentUser.data?.user?.checkedSelectArea ?? false,
              ),
            ),
          );

          await userViewModel.saveUser(updatedUserModel);

          print('✅ Access token refreshed successfully');
          print('🔑 New access token: ${newAccessToken.substring(0, 20)}...');

          // Notify all waiting requests
          for (final completer in _refreshQueue) {
            completer.complete(newAccessToken);
          }
          _refreshQueue.clear();

          return newAccessToken;
        } else {
          print('❌ Invalid access token received in refresh response');
          await _handleSessionExpired();
          return null;
        }
      } else {
        print('❌ Invalid response format from refresh token API');
        await _handleSessionExpired();
        return null;
      }
    } catch (e) {
      print('❌ Token refresh error: $e');

      // ✅ Check if it's a 401 error (refresh token expired)
      if (e.toString().contains('401') ||
          e.toString().contains('Unauthorised') ||
          e.toString().contains('UnauthorisedException')) {
        print('❌ REFRESH TOKEN EXPIRED (401) - SHOWING SESSION EXPIRED DIALOG');

        // Clear queue before showing dialog
        for (final completer in _refreshQueue) {
          completer.complete(null);
        }
        _refreshQueue.clear();

        // Show session expired dialog
        _showSessionExpiredDialog();
        return null;
      } else {
        print('❌ Refresh token API failed with non-401 error - NOT LOGGING OUT');
        // For network/server errors, don't logout
        for (final completer in _refreshQueue) {
          completer.complete(null);
        }
        _refreshQueue.clear();
      }

      return null;
    } finally {
      _isRefreshing = false;
      notifyListeners();
    }
  }

  /// Show session expired dialog
  Future<void> _showSessionExpiredDialog() async {
    final context = SessionExpiredService.navigatorKey.currentContext;

    if (context == null) {
      print('❌ No context available for dialog');
      await _handleSessionExpired();
      return;
    }

    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        final screenWidth = MediaQuery.of(context).size.width * 1;
        final screenHeight = MediaQuery.of(context).size.height * 1;
        return WillPopScope(
          onWillPop: () async => false,
          child: AlertDialog(
            backgroundColor: AppColors.appBackground(context),
            insetPadding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.05,
                vertical: screenHeight * 0.02),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            contentPadding: EdgeInsets.zero,
            content: Container(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05, vertical: screenWidth * 0.05),
              decoration: BoxDecoration(
                // color: AppColors.containerBackground(context),
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.flushbarColor(context),
                    offset: const Offset(0, 2),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Session Expired',style: AppTextStyles.textSize20(context,weight: FontWeight.w500,color: AppColors.darkRedColor),)),
                  SizedboxSpaccing.height02(context),
                  Text("Your session has expired.Don't worry, we kept all of your filters and breakdowns in place.\nPlease login again to continue.",style: AppTextStyles.textSize14(context,weight:
                  FontWeight.w400),textAlign: TextAlign.center,),
                  SizedboxSpaccing.height02(context),



                  GestureDetector(
                    onTap: ()async {
                      Navigator.of(context).pop(); // Close dialog
                      await _handleSessionExpired(); // Navigate to welcome screen
                    },
                    child: Container(
                      width: screenWidth * 0.3,
                      height: 42,
                      decoration: BoxDecoration(
                        color: AppColors.button(context),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                            'Login Again',
                            style: AppTextStyles.textSize14(context, weight: FontWeight.w500,color: AppColors.whiteColor)
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

          ),
        );
      },
    );
  }

  /// Handle session expired - clear data and navigate to welcome screen
  Future<void> _handleSessionExpired() async {
    final navigationService = SessionExpiredService();
    await navigationService.handleSessionExpired();

    for (final completer in _refreshQueue) {
      completer.complete(null);
    }
    _refreshQueue.clear();
  }

  /// Check if refresh token exists
  Future<bool> hasRefreshToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? refreshToken = prefs.getString('refreshToken');
    return refreshToken != null && refreshToken.isNotEmpty;
  }

  /// Clear refresh queue
  void clearQueue() {
    for (final completer in _refreshQueue) {
      completer.complete(null);
    }
    _refreshQueue.clear();
  }
}