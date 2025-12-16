class AutheticationValidation {
  // Validate Full Name
  static String? validateFullName(String? fullName) {
    if (fullName == null || fullName.trim().isEmpty) {
      return 'Please enter your full name';
    }

    if (fullName.trim().length < 3) {
      return 'Full name must be at least 3 characters';
    }

    if (fullName.trim().length > 26) {
      return 'Full name cannot exceed 26 characters';
    }

    if (!RegExp(r'^[a-zA-Z\u0980-\u09FF\s]+$').hasMatch(fullName.trim())) {
      // Allows Bangla and English letters only
      return 'Full name can only contain letters';
    }

    return null; // Valid
  }

  // Validate Bangladeshi phone number
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

  static String? validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return 'Please enter your password';
    }

    // Check minimum length
    if (password.length < 6) {
      return 'Password must be at least 6 characters';
    }

    // Check for spaces
    if (password.contains(' ')) {
      return 'Password cannot contain spaces';
    }

    // Old validation code (removed uppercase, lowercase, special character requirements)
    // bool hasMinLength = password.length >= 6;
    // bool hasNoSpaces = !password.contains(' ');
    // bool hasLowercase = password.contains(RegExp(r'[a-z]'));
    // bool hasUppercase = password.contains(RegExp(r'[A-Z]'));
    // bool hasSpecialChar = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>_+=\-\[\]\\;/~`]'));

    // if (!hasMinLength || !hasNoSpaces || !hasLowercase || !hasUppercase || !hasSpecialChar) {
    //   return 'Password must be at least 6 characters with uppercase, lowercase, special character, and no spaces';
    // }

    return null; // Valid
  }



  /// Validate re-entered password
  static String? validateReenterPassword(String? reenterPassword) {
    if (reenterPassword == null || reenterPassword.isEmpty) {
      return 'Please re-enter your password';
    }

    // Check minimum length
    if (reenterPassword.length < 6) {
      return 'Re-enter Password must be at least 6 characters';
    }

    // Check for spaces
    if (reenterPassword.contains(' ')) {
      return 'Re-enter Password cannot contain spaces';
    }

    // Old validation code (removed uppercase, lowercase, special character requirements)
    // bool hasMinLength = reenterPassword.length >= 6;
    // bool hasNoSpaces = !reenterPassword.contains(' ');
    // bool hasLowercase = reenterPassword.contains(RegExp(r'[a-z]'));
    // bool hasUppercase = reenterPassword.contains(RegExp(r'[A-Z]'));
    // bool hasSpecialChar = reenterPassword.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>_+=\-\[\]\\;/~`]'));

    // if (!hasMinLength || !hasNoSpaces || !hasLowercase || !hasUppercase || !hasSpecialChar) {
    //   return 'Password must be at least 6 characters with uppercase, lowercase, special character, and no spaces';
    // }

    return null; // Valid
  }

  static String? validatePasswordsMatch(String password, String reenterPassword) {
    if (password != reenterPassword) {
      return 'Passwords do not match';
    }
    return null;
  }

  /// Comprehensive validation for all fields
  static Map<String, String?> validateAllFields({
    required String fullName,
    required String phone,
    required String password,
    required String reenterPassword,
  }) {
    return {
      'fullName': validateFullName(fullName),
      'phone': validateBangladeshiPhone(phone),
      'password': validatePassword(password),
      'reenterPassword': validateReenterPassword(reenterPassword),
      'passwordMatch': validatePasswordsMatch(password, reenterPassword), // Add this line
    };
  }


  // Check if all validations pass
  static bool isFormValid({
    required String fullName,
    required String phone,
    required String password,
    required String reenterPassword,
  }) {
    Map<String, String?> validations = validateAllFields(
      fullName: fullName,
      phone: phone,
      password: password,
      reenterPassword: reenterPassword,
    );

    return validations.values.every((error) => error == null);
  }

  // Get the first error message if any
  static String? getFirstError({
    required String fullName,
    required String phone,
    required String password,
    required String reenterPassword,
  }) {
    Map<String, String?> validations = validateAllFields(
      fullName: fullName,
      phone: phone,
      password: password,
      reenterPassword: reenterPassword,
    );

    for (String? error in validations.values) {
      if (error != null) {
        return error;
      }
    }

    return null;
  }
}