import 'package:shared_preferences/shared_preferences.dart';
// 4. Fixed ForgotPasswordHelper
class ForgotPasswordHelper {
  static const String _userIdKey = 'forgot_user_id';
  static const String _tokenKey = 'forgot_token';
  static const String _phoneKey = 'forgot_phone';
  static const String _roleKey = 'forgot_role';
  static const String _newPasswordTokenKey = 'forgot_new_password_token';


  /// Save forgot password data to SharedPreferences
  static Future<void> saveForgotPasswordData({
    required String userId,
    required String token,
    required String phone,
    required String role,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userIdKey, userId);
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_phoneKey, phone);
    await prefs.setString(_roleKey, role); // Fixed: Save role, not phone
  }

  static Future<void> saveNewPasswordToken(String newPasswordToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_newPasswordTokenKey, newPasswordToken);
  }


  /// Get forgot password user ID
  static Future<String?> getForgotUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userIdKey);
  }

  /// Get forgot password token
  static Future<String?> getForgotToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  /// Get forgot password phone
  static Future<String?> getForgotPhone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_phoneKey);
  }

  /// Get forgot password role
  static Future<String?> getForgotRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_roleKey);
  }
  /// Save new password token (received after OTP verification)
     static Future<String?> getNewPasswordToken() async {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_newPasswordTokenKey);
    }

  /// Get all forgot password data at once
  static Future<Map<String, String?>> getAllForgotPasswordData() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'userId': prefs.getString(_userIdKey),
      'token': prefs.getString(_tokenKey),
      'phone': prefs.getString(_phoneKey),
      'role': prefs.getString(_roleKey),
      'newPasswordToken': prefs.getString(_newPasswordTokenKey),
    };
  }

  /// Clear all forgot password data
  static Future<void> clearForgotPasswordData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userIdKey);
    await prefs.remove(_tokenKey);
    await prefs.remove(_phoneKey);
    await prefs.remove(_roleKey);
    await prefs.remove(_newPasswordTokenKey);
  }

  /// Clear only the new password token (after successful password reset)
  static Future<void> clearNewPasswordToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_newPasswordTokenKey);
  }
}