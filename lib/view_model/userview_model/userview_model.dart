import 'package:dinmajur_customer/configs/services/navigator_services/navigator_services_refreshToken.dart';
import 'package:dinmajur_customer/model/user/user_model.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
class UserViewModel with ChangeNotifier {
  String? _accessToken;
  String? get accessToken => _accessToken;

  String? _userId;
  String? get userId => _userId;

  String? _message;
  String? get message => _message;

  String? _role;
  String? get role => _role;

  bool _isLoggedIn = false;
  bool get isLoggedIn => _isLoggedIn;

  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;

  void setUserDetails(String accessToken, String message, String userId, String role) {
    _accessToken = accessToken;
    _message = message;
    _userId = userId;
    _role = role;
    _isLoggedIn = accessToken.isNotEmpty;
    notifyListeners();
  }

  Future<void> loadUserFromPrefs() async {
    final SharedPreferences sp = await SharedPreferences.getInstance();

    _accessToken = sp.getString('accessToken');
    _userId = sp.getString('userId');
    _role = sp.getString('role');
    _message = sp.getString('message');
    _isLoggedIn = _accessToken != null && _accessToken!.isNotEmpty;

    // Load the complete user model
    if (_isLoggedIn) {
      _currentUser = await getUser();
    }

    notifyListeners();
  }

  Future<bool> saveUser(UserModel userModel) async {
    final SharedPreferences sp = await SharedPreferences.getInstance();

    // Save all user data
    await sp.setString('accessToken', userModel.data?.accessToken ?? '');
    await sp.setString('refreshToken', userModel.data?.refreshToken ?? '');
    await sp.setString('userId', userModel.data?.user?.userId ?? '');
    await sp.setString('id', userModel.data?.user?.id ?? '');
    await sp.setString('phone', userModel.data?.user?.phone ?? '');
    await sp.setString('role', userModel.data?.user?.role ?? '');
    await sp.setString('userStatus', userModel.data?.user?.userStatus ?? '');
    await sp.setBool('isRegistered', userModel.data?.user?.isRegistered ?? false);
    await sp.setBool('isPhoneVerified', userModel.data?.user?.isPhoneVerified ?? false);
    await sp.setString('firstName', userModel.data?.user?.firstName ?? '');
    await sp.setString('lastName', userModel.data?.user?.lastName ?? '');

    // Handle ProfilePicture object properly
    String profilePictureUrl = userModel.data?.user?.profilePicture?.url ?? '';
    String profilePictureAltText = userModel.data?.user?.profilePicture?.altText ?? '';

    await sp.setString('profilePictureUrl', profilePictureUrl);
    await sp.setString('profilePictureAltText', profilePictureAltText);

    await sp.setBool('isDeliveryPerson', userModel.data?.user?.isDeliveryPerson ?? false);
    await sp.setBool('checkedJoinUs', userModel.data?.user?.checkedJoinUs ?? false);
    await sp.setBool('checkedSelectServices', userModel.data?.user?.checkedSelectServices ?? false);
    await sp.setBool('checkedSelectArea', userModel.data?.user?.checkedSelectArea ?? false);
    await sp.setString('message', userModel.message ?? '');

    // Update local state
    _currentUser = userModel;
    setUserDetails(
      userModel.data?.accessToken ?? '',
      userModel.message ?? '',
      userModel.data?.user?.userId ?? '',
      userModel.data?.user?.role ?? '',
    );

    notifyListeners();
    return true;
  }

  Future<UserModel> getUser() async {
    final SharedPreferences sp = await SharedPreferences.getInstance();

    // Create ProfilePicture object from stored values
    ProfilePicture? profilePicture;
    final profilePictureUrl = sp.getString('profilePictureUrl');
    final profilePictureAltText = sp.getString('profilePictureAltText');

    if (profilePictureUrl != null && profilePictureUrl.isNotEmpty) {
      profilePicture = ProfilePicture(
        url: profilePictureUrl,
        altText: profilePictureAltText,
      );
    }

    final userModel = UserModel(
      success: true,
      message: sp.getString('message'),
      data: Data(
        accessToken: sp.getString('accessToken'),
        refreshToken: sp.getString('refreshToken'),
        user: User(
          id: sp.getString('id'),
          userId: sp.getString('userId'),
          phone: sp.getString('phone'),
          role: sp.getString('role'),
          userStatus: sp.getString('userStatus'),
          isRegistered: sp.getBool('isRegistered') ?? false,
          isPhoneVerified: sp.getBool('isPhoneVerified') ?? false,
          firstName: sp.getString('firstName'),
          lastName: sp.getString('lastName'),
          profilePicture: profilePicture,
          isDeliveryPerson: sp.getBool('isDeliveryPerson') ?? false,
          checkedJoinUs: sp.getBool('checkedJoinUs') ?? false,
          checkedSelectServices: sp.getBool('checkedSelectServices') ?? false,
          checkedSelectArea: sp.getBool('checkedSelectArea') ?? false,
        ),
      ),
    );

    _currentUser = userModel;
    return userModel;
  }

  Future<bool> remove() async {
    final SharedPreferences sp = await SharedPreferences.getInstance();

    // Remove all stored user data
    await sp.remove('accessToken');
    await sp.remove('refreshToken');
    await sp.remove('userId');
    await sp.remove('id');
    await sp.remove('phone');
    await sp.remove('role');
    await sp.remove('userStatus');
    await sp.remove('isRegistered');
    await sp.remove('isPhoneVerified');
    await sp.remove('firstName');
    await sp.remove('lastName');
    await sp.remove('profilePictureUrl');
    await sp.remove('profilePictureAltText');
    await sp.remove('isDeliveryPerson');
    await sp.remove('checkedJoinUs');
    await sp.remove('checkedSelectServices');
    await sp.remove('checkedSelectArea');
    await sp.remove('message');

    // Clear local state
    _accessToken = null;
    _userId = null;
    _message = null;
    _role = null;
    _isLoggedIn = false;
    _currentUser = null;

    notifyListeners();
    return true;
  }

  // Method to handle automatic logout (called by NetworkApiService)
  Future<void> handleSessionExpired() async {
    await remove();
    await NavigationService().handleSessionExpired();
  }

  // Method to update tokens after refresh
  Future<void> updateTokens(String newAccessToken, String? newRefreshToken) async {
    final SharedPreferences sp = await SharedPreferences.getInstance();

    await sp.setString('accessToken', newAccessToken);
    if (newRefreshToken != null) {
      await sp.setString('refreshToken', newRefreshToken);
    }

    _accessToken = newAccessToken;

    // Update current user model if exists
    if (_currentUser?.data != null) {
      _currentUser!.data!.accessToken = newAccessToken;
      if (newRefreshToken != null) {
        _currentUser!.data!.refreshToken = newRefreshToken;
      }
    }

    notifyListeners();
  }

  // Helper method to check if user is authenticated
  bool get isAuthenticated {
    return _accessToken != null && _accessToken!.isNotEmpty;
  }

  // Helper method to get profile picture URL easily
  String? getProfilePictureUrl() {
    return _currentUser?.data?.user?.profilePicture?.url;
  }

  // Helper method to get user's full name
  String? getFullName() {
    final user = _currentUser?.data?.user;
    if (user?.firstName != null || user?.lastName != null) {
      return '${user?.firstName ?? ''} ${user?.lastName ?? ''}'.trim();
    }
    return null;
  }

  // Helper method to check if user has completed registration steps
  bool get hasCompletedRegistration {
    final user = _currentUser?.data?.user;
    return user?.checkedJoinUs == true &&
        user?.checkedSelectServices == true &&
        user?.checkedSelectArea == true;
  }
}






//

