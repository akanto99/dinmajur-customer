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
// In WelcomeLoginValidation:

  static String? validateBangladeshiPhone(String? phone) {
    if (phone == null || phone.isEmpty) {
      return 'Please enter phone number';
    }

    String cleanPhone = phone.replaceAll(RegExp(r'[\s\-()]'), '');

    // Remove +88 or 88 prefix if present
    if (cleanPhone.startsWith('+88')) {
      cleanPhone = cleanPhone.substring(3);
    } else if (cleanPhone.startsWith('88') && cleanPhone.length > 11) {
      cleanPhone = cleanPhone.substring(2);
    }

    cleanPhone = cleanPhone.replaceAll(RegExp(r'[^\d]'), '');

    // ✅ Auto-normalize: if 10 digits starting with 1, prepend 0
    if (cleanPhone.length == 10 && cleanPhone.startsWith('1')) {
      cleanPhone = '0$cleanPhone';
    }

    if (cleanPhone.length != 11) {
      return 'Phone number must be 11 digits';
    }

    if (!cleanPhone.startsWith('0')) {
      return 'Phone number must start with 0';
    }

    List<String> validPrefixes = ['013', '014', '015', '016', '017', '018', '019'];
    if (!validPrefixes.contains(cleanPhone.substring(0, 3))) {
      return 'Please enter a valid Bangladeshi phone number';
    }

    return null; // Valid
  }

// ✅ New helper: normalize before sending to API
  static String normalizePhone(String phone) {
    String clean = phone.replaceAll(RegExp(r'[\s\-()+]'), '');
    clean = clean.replaceAll(RegExp(r'[^\d]'), '');

    if (clean.startsWith('88') && clean.length > 11) {
      clean = clean.substring(2);
    }

    // Prepend 0 if 10 digits starting with 1
    if (clean.length == 10 && clean.startsWith('1')) {
      clean = '0$clean';
    }

    return clean;
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