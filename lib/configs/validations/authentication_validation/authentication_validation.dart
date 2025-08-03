class AutheticationValidation {
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

    // Check all conditions and return a single comprehensive message
    bool hasMinLength = password.length >= 8;
    bool hasNoSpaces = !password.contains(' ');
    bool hasLowercase = password.contains(RegExp(r'[a-z]'));
    bool hasUppercase = password.contains(RegExp(r'[A-Z]'));
    bool hasSpecialChar = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>_+=\-\[\]\\;/~`]'));

    if (!hasMinLength || !hasNoSpaces || !hasLowercase || !hasUppercase || !hasSpecialChar) {
      return 'Password must be at least 8 characters with uppercase, lowercase, special character, and no spaces';
    }

    return null; // Valid
  }



  /// Validate re-entered password
  static String? validateReenterPassword(String? reenterPassword) {
    if (reenterPassword == null || reenterPassword.isEmpty) {
      return 'Please re-enter your password';
    }

    // Check all conditions and return a single comprehensive message
    bool hasMinLength = reenterPassword.length >= 8;
    bool hasNoSpaces = !reenterPassword.contains(' ');
    bool hasLowercase = reenterPassword.contains(RegExp(r'[a-z]'));
    bool hasUppercase = reenterPassword.contains(RegExp(r'[A-Z]'));
    bool hasSpecialChar = reenterPassword.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>_+=\-\[\]\\;/~`]'));

    if (!hasMinLength || !hasNoSpaces || !hasLowercase || !hasUppercase || !hasSpecialChar) {
      return 'Password must be at least 8 characters with uppercase, lowercase, special character, and no spaces';
    }

    return null; // Valid
  }



  /// Comprehensive validation for all fields
  static Map<String, String?> validateAllFields({
    required String phone,
    required String password,
    required String reenterPassword,
  }) {
    return {
      'phone': validateBangladeshiPhone(phone),
      'password': validatePassword(password),
      'reenterPassword': validateReenterPassword(reenterPassword),
    };
  }

  // Check if all validations pass
  static bool isFormValid({
    required String phone,
    required String password,
    required String reenterPassword,
  }) {
    Map<String, String?> validations = validateAllFields(
      phone: phone,
      password: password,
      reenterPassword: reenterPassword,
    );

    return validations.values.every((error) => error == null);
  }

  // Get the first error message if any
  static String? getFirstError({
    required String phone,
    required String password,
    required String reenterPassword,
  }) {
    Map<String, String?> validations = validateAllFields(
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