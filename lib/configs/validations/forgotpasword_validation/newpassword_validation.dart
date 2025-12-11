import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NewPasswordValidation {
  // Password requirements
  bool hasMinLength = false;
  bool hasUpperCase = false;
  bool hasLowerCase = false;
  bool hasNumber = false;
  bool hasSpecialChar = false;

  double passwordStrength = 0.0;
  String strengthText = 'Too weak';
  Color strengthColor = Colors.red;

  NewPasswordValidation();

  void checkPasswordStrength(String password) {
    hasMinLength = password.length >= 8;
    hasUpperCase = password.contains(RegExp(r'[A-Z]'));
    hasLowerCase = password.contains(RegExp(r'[a-z]'));
    hasNumber = password.contains(RegExp(r'[0-9]'));
    hasSpecialChar = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

    int metRequirements = 0;
    if (hasMinLength) metRequirements++;
    if (hasUpperCase) metRequirements++;
    if (hasLowerCase) metRequirements++;
    if (hasNumber) metRequirements++;
    if (hasSpecialChar) metRequirements++;

    passwordStrength = metRequirements / 5.0;

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

  List<PasswordRequirement> getRequirements() {
    return [
      PasswordRequirement('At least 8 characters', hasMinLength),
      PasswordRequirement('Contains uppercase letter', hasUpperCase),
      PasswordRequirement('Contains lowercase letter', hasLowerCase),
      PasswordRequirement('Contains number', hasNumber),
      PasswordRequirement('Contains special character', hasSpecialChar),
    ];
  }

  bool isPasswordValid() {
    return passwordStrength >= 0.6;
  }

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

  // Updated method signatures to accept context for localization
  String? getValidationMessage(String phone, String password, String confirmPassword, BuildContext context) {
    String? phoneError = validateBangladeshiPhone(phone, context);
    if (phoneError != null) {
      return phoneError;
    }
    return _validatePasswords(password, confirmPassword, context);
  }

  String? getValidationMessageWithoutPhone(String password, String confirmPassword, BuildContext context) {
    return _validatePasswords(password, confirmPassword, context);
  }

  String? _validatePasswords(String password, String confirmPassword, BuildContext context) {
    if (password.isEmpty || password.length < 6) {
      return AppLocalizations.of(context)!.password_min_characters;
    }

    if (confirmPassword.isEmpty || confirmPassword.length < 6) {
      return AppLocalizations.of(context)!.reenter_password_min_characters;
    }

    if (password != confirmPassword) {
      return AppLocalizations.of(context)!.passwords_do_not_match;
    }

    // if (!isPasswordValid()) {
    //   return AppLocalizations.of(context)!.password_too_weak_requirements;
    // }

    return null;
  }

  String? validatePasswordStrength(String password, BuildContext context) {
    if (password.isEmpty) {
      return AppLocalizations.of(context)!.password_required;
    }

    if (password.length < 6) {
      return AppLocalizations.of(context)!.password_must_be_6;
    }

    if (!isPasswordValid()) {
      return AppLocalizations.of(context)!.password_too_weak_requirements;
    }

    return null;
  }

  String? validatePasswordMatch(String password, String confirmPassword, BuildContext context) {
    if (confirmPassword.isEmpty) {
      return AppLocalizations.of(context)!.please_confirm_password;
    }

    if (password != confirmPassword) {
      return AppLocalizations.of(context)!.passwords_reenter_do_not_match;
    }

    return null;
  }

  // ✅ Full Name Validation
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
      // Allows Bangla and English letters only
      return AppLocalizations.of(context)!.full_name_invalid_characters;
    }

    return null;
  }

  // UI builder methods unchanged...
  Widget buildRequirement(BuildContext context, String text, bool isMet) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            margin: const EdgeInsets.only(right: 10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: isMet ? Colors.green : AppColors.border(context), width: 1),
              color: isMet ? Colors.green : Colors.transparent,
            ),
            child: isMet ? Icon(Icons.check, size: 8, color: AppColors.whiteColor) : null,
          ),
          Flexible(
            child: Text(
              text,
              style: GoogleFonts.poppins(fontSize: 14, color: isMet ? Colors.green : AppColors.textPrimary(context), fontWeight: FontWeight.w400),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildProgressBar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LinearProgressIndicator(
          value: passwordStrength,
          backgroundColor: Colors.grey[300],
          borderRadius: BorderRadius.circular(4),
          valueColor: AlwaysStoppedAnimation<Color>(strengthColor),
          minHeight: 6,
        ),
        SizedBox(height: 8),
        Text(
          'Password strength: $strengthText',
          style: TextStyle(fontSize: 14, color: strengthColor, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget buildRequirementsList(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: getRequirements().map((requirement) => buildRequirement(context, requirement.text, requirement.isMet)).toList());
  }
}

// Helper class for password requirements
class PasswordRequirement {
  final String text;
  final bool isMet;

  PasswordRequirement(this.text, this.isMet);
}

// Extension class for additional validation methods (Optional)
extension NewPasswordValidationExtension on NewPasswordValidation {
  // Method for complete form validation (Registration)
  ValidationResult validateRegistrationForm({required String fullName, required String phone, required String password, required String confirmPassword, required BuildContext context}) {
    // ✅ Full name validation
    String? fullNameError = NewPasswordValidation.validateFullName(fullName, context);
    if (fullNameError != null) {
      return ValidationResult(isValid: false, errorMessage: fullNameError);
    }

    // Phone validation
    String? phoneError = NewPasswordValidation.validateBangladeshiPhone(phone, context);
    if (phoneError != null) {
      return ValidationResult(isValid: false, errorMessage: phoneError);
    }

    // Password validation
    String? passwordError = _validatePasswords(password, confirmPassword, context);
    if (passwordError != null) {
      return ValidationResult(isValid: false, errorMessage: passwordError);
    }

    return ValidationResult(isValid: true);
  }

  // Method for forgot password validation
  ValidationResult validateForgotPasswordForm({required String password, required String confirmPassword, required BuildContext context}) {
    String? passwordError = _validatePasswords(password, confirmPassword, context);
    if (passwordError != null) {
      return ValidationResult(isValid: false, errorMessage: passwordError);
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
