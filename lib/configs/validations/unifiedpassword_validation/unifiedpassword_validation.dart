import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:dinmajur_customer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class UnifiedPasswordValidation {
  // Password requirements
  bool hasMinLength = false;
  bool hasUpperCase = false;
  bool hasLowerCase = false;
  bool hasNumber = false;
  bool hasSpecialChar = false;
  bool hasNoSpaces = true;

  double passwordStrength = 0.0;
  String strengthText = 'Too weak';
  Color strengthColor = Colors.red;

  // Constructor
  UnifiedPasswordValidation();

  // Method to check password strength
  void checkPasswordStrength(String password) {
    hasMinLength = password.length >= 8;
    hasUpperCase = password.contains(RegExp(r'[A-Z]'));
    hasLowerCase = password.contains(RegExp(r'[a-z]'));
    hasNumber = password.contains(RegExp(r'[0-9]'));
    hasSpecialChar = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    hasNoSpaces = !password.contains(' ');

    // Calculate strength
    int metRequirements = 0;
    if (hasMinLength) metRequirements++;
    if (hasUpperCase) metRequirements++;
    if (hasLowerCase) metRequirements++;
    if (hasNumber) metRequirements++;
    if (hasSpecialChar) metRequirements++;
    if (hasNoSpaces) metRequirements++;

    passwordStrength = metRequirements / 6.0;

    // Update strength text and color
    if (metRequirements <= 2) {
      strengthText = 'Too weak';
      strengthColor = AppColors.darkRedColor;
    } else if (metRequirements <= 3) {
      strengthText = 'Weak';
      strengthColor = Colors.orange;
    } else if (metRequirements <= 4) {
      strengthText = 'Good';
      strengthColor = Colors.blue;
    } else {
      strengthText = 'Strong';
      strengthColor = Colors.green;
    }
  }

  // Method to get password requirements list
  List<PasswordRequirement> getRequirements() {
    return [
      PasswordRequirement('At least 8 characters', hasMinLength),
      PasswordRequirement('Contains uppercase letter', hasUpperCase),
      PasswordRequirement('Contains lowercase letter', hasLowerCase),
      PasswordRequirement('Contains number', hasNumber),
      PasswordRequirement('Contains special character', hasSpecialChar),
      PasswordRequirement('No spaces allowed', hasNoSpaces),
    ];
  }

  // Method to validate password for form submission
  bool isPasswordValid() {
    return passwordStrength >= 0.5 && hasNoSpaces;
  }

  // FULL NAME VALIDATION

  static String? validateFullName(String? fullName, BuildContext context) {
    if (fullName == null || fullName.trim().isEmpty) {
      return AppLocalizations.of(context)!.enter_full_name;
    }

    if (fullName.trim().length < 3) {
      return AppLocalizations.of(context)!.full_name_min_length;
    }

    if (fullName.trim().length > 26) {
      return AppLocalizations.of(context)!.full_name_max_length;
    }

    if (!RegExp(r'^[a-zA-Z\u0980-\u09FF\s]+$').hasMatch(fullName.trim())) {
      return AppLocalizations.of(context)!.full_name_invalid_characters;
    }

    return null;
  }

  // PHONE VALIDATION

  static String? validateBangladeshiPhone(String? phone, BuildContext context) {
    if (phone == null || phone.isEmpty) {
      return AppLocalizations.of(context)!.enter_phone_number;
    }

    String cleanPhone = phone.replaceAll(RegExp(r'[^\d]'), '');

    if (cleanPhone.length != 11) {
      return AppLocalizations.of(context)!.phone_number_must_be_11;
    }

    if (!cleanPhone.startsWith('01')) {
      return AppLocalizations.of(context)!.invalid_phone_number;
    }

    List<String> validPrefixes = ['013', '014', '015', '016', '017', '018', '019'];
    String prefix = cleanPhone.substring(0, 3);

    if (!validPrefixes.contains(prefix)) {
      return AppLocalizations.of(context)!.invalid_phone_number;
    }

    return null;
  }

  // PASSWORD VALIDATION

  static String? validatePassword(String? password, BuildContext context) {
    if (password == null || password.isEmpty) {
      return AppLocalizations.of(context)!.password_required;
    }

    if (password.length < 6) {
      return AppLocalizations.of(context)!.password_must_be_6;
    }

    if (password.contains(' ')) {
      return AppLocalizations.of(context)!.password_cannot_contain_spaces;
    }

    return null;
  }

  static String? validateReenterPassword(String? reenterPassword, BuildContext context) {
    if (reenterPassword == null || reenterPassword.isEmpty) {
      return AppLocalizations.of(context)!.please_confirm_password;
    }

    if (reenterPassword.length < 6) {
      return AppLocalizations.of(context)!.reenter_password_min_characters;
    }

    if (reenterPassword.contains(' ')) {
      return AppLocalizations.of(context)!.reenter_password_cannot_contain_spaces;
    }

    return null;
  }

  static String? validatePasswordsMatch(String password, String reenterPassword, BuildContext context) {
    if (password != reenterPassword) {
      return AppLocalizations.of(context)!.passwords_do_not_match;
    }
    return null;
  }

  static String? validateOldPassword(String? oldPassword, BuildContext context) {
    if (oldPassword == null || oldPassword.isEmpty) {
      return AppLocalizations.of(context)!.enter_old_password;
    }

    if (oldPassword.length < 6) {
      return AppLocalizations.of(context)!.old_password_min_characters;
    }

    return null;
  }

  // COMBINED VALIDATIONS

  // For Registration (with full name and phone)
  static String? validateRegistration({
    required String fullName,
    required String phone,
    required String password,
    required String reenterPassword,
    required BuildContext context,
  }) {
    String? fullNameError = validateFullName(fullName, context);
    if (fullNameError != null) return fullNameError;

    String? phoneError = validateBangladeshiPhone(phone, context);
    if (phoneError != null) return phoneError;

    String? passwordError = validatePassword(password, context);
    if (passwordError != null) return passwordError;

    String? reenterError = validateReenterPassword(reenterPassword, context);
    if (reenterError != null) return reenterError;

    String? matchError = validatePasswordsMatch(password, reenterPassword, context);
    if (matchError != null) return matchError;

    return null;
  }

  // For Forgot Password (without phone, without old password)
  static String? validateForgotPassword({
    required String password,
    required String reenterPassword,
    required BuildContext context,
  }) {
    String? passwordError = validatePassword(password, context);
    if (passwordError != null) return passwordError;

    String? reenterError = validateReenterPassword(reenterPassword, context);
    if (reenterError != null) return reenterError;

    String? matchError = validatePasswordsMatch(password, reenterPassword, context);
    if (matchError != null) return matchError;

    return null;
  }

  // For Change Password (with old password, without phone)
  static String? validateChangePassword({
    required String oldPassword,
    required String newPassword,
    required String reenterPassword,
    required BuildContext context,
  }) {
    String? oldPasswordError = validateOldPassword(oldPassword, context);
    if (oldPasswordError != null) return oldPasswordError;

    String? passwordError = validatePassword(newPassword, context);
    if (passwordError != null) return passwordError;

    String? reenterError = validateReenterPassword(reenterPassword, context);
    if (reenterError != null) return reenterError;

    String? matchError = validatePasswordsMatch(newPassword, reenterPassword, context);
    if (matchError != null) return matchError;

    return null;
  }

  // UI WIDGETS

  Widget buildRequirement(BuildContext context, String text, bool isMet) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        children: [
          Container(
            width: 16,
            height: 16,
            margin: const EdgeInsets.only(right: 10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isMet ? Colors.green : AppColors.border(context),
                width: 1,
              ),
              color: isMet ? Colors.green : Colors.transparent,
            ),
            child: isMet
                ? Icon(
              Icons.check,
              size: 10,
              color: AppColors.whiteColor,
            )
                : null,
          ),
          Text(
            text,
            style: AppTextStyles.textSize14(context, weight: FontWeight.w400, color: isMet ? Colors.green : AppColors.textPrimary(context)),
          ),
        ],
      ),
    );
  }

  Widget buildRequirementsList(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: getRequirements()
          .map((requirement) =>
          buildRequirement(context, requirement.text, requirement.isMet))
          .toList(),
    );
  }
}

// Helper class for password requirements
class PasswordRequirement {
  final String text;
  final bool isMet;

  PasswordRequirement(this.text, this.isMet);
}

// Extension class for additional validation methods
extension UnifiedPasswordValidationExtension on UnifiedPasswordValidation {
  // Method for complete form validation (Registration)
  ValidationResult validateRegistrationForm({
    required String fullName,
    required String phone,
    required String password,
    required String confirmPassword,
    required BuildContext context,
  }) {
    String? error = UnifiedPasswordValidation.validateRegistration(
      fullName: fullName,
      phone: phone,
      password: password,
      reenterPassword: confirmPassword,
      context: context,
    );

    if (error != null) {
      return ValidationResult(isValid: false, errorMessage: error);
    }

    return ValidationResult(isValid: true);
  }

  // Method for forgot password validation
  ValidationResult validateForgotPasswordForm({
    required String password,
    required String confirmPassword,
    required BuildContext context,
  }) {
    String? error = UnifiedPasswordValidation.validateForgotPassword(
      password: password,
      reenterPassword: confirmPassword,
      context: context,
    );

    if (error != null) {
      return ValidationResult(isValid: false, errorMessage: error);
    }

    return ValidationResult(isValid: true);
  }

  // Method for change password validation
  ValidationResult validateChangePasswordForm({
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
    required BuildContext context,
  }) {
    String? error = UnifiedPasswordValidation.validateChangePassword(
      oldPassword: oldPassword,
      newPassword: newPassword,
      reenterPassword: confirmPassword,
      context: context,
    );

    if (error != null) {
      return ValidationResult(isValid: false, errorMessage: error);
    }

    return ValidationResult(isValid: true);
  }
}

// Helper class for validation results
class ValidationResult {
  final bool isValid;
  final String? errorMessage;

  ValidationResult({required this.isValid, this.errorMessage});
}