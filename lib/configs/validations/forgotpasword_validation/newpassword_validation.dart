import 'package:dinmajur_customer/configs/res/color.dart';
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

  // Constructor
  NewPasswordValidation();

  // Method to check password strength
  void checkPasswordStrength(String password) {
    hasMinLength = password.length >= 8;
    hasUpperCase = password.contains(RegExp(r'[A-Z]'));
    hasLowerCase = password.contains(RegExp(r'[a-z]'));
    hasNumber = password.contains(RegExp(r'[0-9]'));
    hasSpecialChar = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

    // Calculate strength
    int metRequirements = 0;
    if (hasMinLength) metRequirements++;
    if (hasUpperCase) metRequirements++;
    if (hasLowerCase) metRequirements++;
    if (hasNumber) metRequirements++;
    if (hasSpecialChar) metRequirements++;

    passwordStrength = metRequirements / 5.0;

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
    ];
  }

  // Method to validate password for form submission
  bool isPasswordValid() {
    return passwordStrength >= 0.6; // At least 60% strength (3 out of 5 requirements)
  }

  // Static method to validate Bangladeshi phone number
  static String? validateBangladeshiPhone(String? phone) {
    if (phone == null || phone.isEmpty) {
      return 'Please enter phone number';
    }

    // Remove any spaces or special characters
    String cleanPhone = phone.replaceAll(RegExp(r'[^\d]'), '');

    // Check if it's a valid Bangladeshi mobile number
    // Bangladeshi mobile numbers: 11 digits starting with 01
    if (cleanPhone.length != 11) {
      return 'Phone number must be 11 digits';
    }

    if (!cleanPhone.startsWith('01')) {
      return 'Please enter a valid Bangladeshi phone number';
    }

    // Check for valid operator prefixes
    List<String> validPrefixes = [
      '013', '014', '015', '016', '017', '018', '019'
    ];

    String prefix = cleanPhone.substring(0, 3);
    if (!validPrefixes.contains(prefix)) {
      return 'Please enter a valid Bangladeshi phone number';
    }

    return null; // Valid
  }

  // Overloaded method for validation with phone (Registration scenario)
  String? getValidationMessage(String phone, String password, String confirmPassword) {
    // Validate phone first
    String? phoneError = validateBangladeshiPhone(phone);
    if (phoneError != null) {
      return phoneError;
    }

    // Then validate passwords
    return _validatePasswords(password, confirmPassword);
  }

  // Overloaded method for validation without phone (Forgot Password scenario)
  String? getValidationMessageWithoutPhone(String password, String confirmPassword) {
    return _validatePasswords(password, confirmPassword);
  }

  // Private method to validate passwords (common logic)
  String? _validatePasswords(String password, String confirmPassword) {
    if (password.isEmpty || password.length < 8) {
      return 'Please enter your password & at least 8 characters';
    }

    if (confirmPassword.isEmpty || confirmPassword.length < 8) {
      return 'Please re-enter your password & at least 8 characters';
    }

    if (password != confirmPassword) {
      return 'Passwords do not match';
    }

    if (!isPasswordValid()) {
      return 'Password is too weak. Please meet at least 3 requirements.';
    }

    return null; // No error
  }

  // Method to validate only password strength (for real-time feedback)
  String? validatePasswordStrength(String password) {
    if (password.isEmpty) {
      return 'Password is required';
    }

    if (password.length < 8) {
      return 'Password must be at least 8 characters';
    }

    if (!isPasswordValid()) {
      return 'Password is too weak. Please meet at least 3 requirements.';
    }

    return null; // No error
  }

  // Method to validate password match
  String? validatePasswordMatch(String password, String confirmPassword) {
    if (confirmPassword.isEmpty) {
      return 'Please confirm your password';
    }

    if (password != confirmPassword) {
      return 'Passwords & Re-enter Passwords do not match';
    }

    return null; // No error
  }

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
              border: Border.all(
                color: isMet ? Colors.green : AppColors.border(context),
                width: 1,
              ),
              color: isMet ? Colors.green : Colors.transparent,
            ),
            child: isMet
                ? Icon(
              Icons.check,
              size: 8,
              color: AppColors.whiteColor,
            )
                : null,
          ),
          Flexible(
            child: Text(
              text,
              style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: isMet ? Colors.green : AppColors.textPrimary(context),
                  fontWeight: FontWeight.w400
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Method to build progress bar widget
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
          style: TextStyle(
            fontSize: 14,
            color: strengthColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget buildRequirementsList(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: getRequirements()
          .map((requirement) => buildRequirement(context, requirement.text, requirement.isMet))
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

// Extension class for additional validation methods (Optional)
extension NewPasswordValidationExtension on NewPasswordValidation {

  // Method for complete form validation (Registration)
  ValidationResult validateRegistrationForm({
    required String phone,
    required String password,
    required String confirmPassword,
  }) {
    // Check phone
    String? phoneError = NewPasswordValidation.validateBangladeshiPhone(phone);
    if (phoneError != null) {
      return ValidationResult(isValid: false, errorMessage: phoneError);
    }

    // Check passwords
    String? passwordError = _validatePasswords(password, confirmPassword);
    if (passwordError != null) {
      return ValidationResult(isValid: false, errorMessage: passwordError);
    }

    return ValidationResult(isValid: true);
  }

  // Method for forgot password validation
  ValidationResult validateForgotPasswordForm({
    required String password,
    required String confirmPassword,
  }) {
    String? passwordError = _validatePasswords(password, confirmPassword);
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