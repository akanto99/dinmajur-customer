import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ChangePasswordValidation {
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
  ChangePasswordValidation();

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

  // Method to get validation error message
  String? getValidationMessage(String password, String confirmPassword) {
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
            style: GoogleFonts.hindSiliguri(
              fontSize: 14,
              color: isMet ? Colors.green : AppColors.textPrimary(context),
              fontWeight: FontWeight.w400,
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
        const SizedBox(height: 8),
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