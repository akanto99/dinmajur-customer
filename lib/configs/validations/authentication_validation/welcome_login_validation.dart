class WelcomeLoginValidation {
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

  // Validate Bangladeshi phone number (supports +88 prefix)
  static String? validateBangladeshiPhone(String? phone) {
    if (phone == null || phone.isEmpty) {
      return 'Please enter phone number';
    }

    // Remove spaces and special characters except +
    String cleanPhone = phone.replaceAll(RegExp(r'[\s\-()]'), '');

    // Handle +88 prefix
    if (cleanPhone.startsWith('+88')) {
      cleanPhone = cleanPhone.substring(3); // Remove +88
    } else if (cleanPhone.startsWith('88') && cleanPhone.length > 11) {
      cleanPhone = cleanPhone.substring(2); // Remove 88
    }

    // Remove any remaining non-digit characters
    cleanPhone = cleanPhone.replaceAll(RegExp(r'[^\d]'), '');

    // Check if it's a valid Bangladeshi mobile number
    // Bangladeshi mobile numbers: 10 digits starting with 1
    if (cleanPhone.length != 10) {
      return 'Phone number must be 10 digits';
    }

    if (!cleanPhone.startsWith('1')) {
      return 'Phone number must start with 1';
    }

    // Check for valid operator prefixes (now starting with 1)
    List<String> validPrefixes = ['13', '14', '15', '16', '17', '18', '19'];

    String prefix = cleanPhone.substring(0, 2);
    if (!validPrefixes.contains(prefix)) {
      return 'Please enter a valid Bangladeshi phone number';
    }

    return null; // Valid
  }

  // Clean phone number for API submission (removes +88, 88, spaces, etc.)
  static String cleanPhoneNumber(String phone) {
    String cleanPhone = phone.replaceAll(RegExp(r'[\s\-()]'), '');

    if (cleanPhone.startsWith('+88')) {
      cleanPhone = cleanPhone.substring(3);
    } else if (cleanPhone.startsWith('88') && cleanPhone.length > 11) {
      cleanPhone = cleanPhone.substring(2);
    }

    return cleanPhone.replaceAll(RegExp(r'[^\d]'), '');
  }

  // Validate login form (Full Name + Phone) - fullName is now optional
  static Map<String, String?> validateLoginForm({String? fullName, required String phone}) {
    Map<String, String?> errors = {};

    // Only validate fullName if it's provided
    if (fullName != null) {
      errors['fullName'] = validateFullName(fullName);
    }

    errors['phone'] = validateBangladeshiPhone(phone);

    return errors;
  }

  // Check if login form is valid - fullName is now optional
  static bool isLoginFormValid({String? fullName, required String phone}) {
    Map<String, String?> validations = validateLoginForm(fullName: fullName, phone: phone);

    return validations.values.every((error) => error == null);
  }

  // Get the first error message if any - fullName is now optional
  static String? getFirstLoginError({String? fullName, required String phone}) {
    Map<String, String?> validations = validateLoginForm(fullName: fullName, phone: phone);

    for (String? error in validations.values) {
      if (error != null) {
        return error;
      }
    }

    return null;
  }
}