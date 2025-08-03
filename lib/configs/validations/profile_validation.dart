import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../utils/utils.dart'; // Adjust the import as needed
class ProfileValidators {
  static bool validateFirstName(String text, BuildContext context) {
    if (text.isEmpty || text.length < 3) {
      Utils.flushBarErrorMessage(
          "First name is required and must be at least 3 characters long.", context);
      return false;
    }

    if (RegExp(r'[0-9]').hasMatch(text)) {
      Utils.flushBarErrorMessage(
          "First name cannot contain any numbers.", context);
      return false;
    }

    return true;
  }

  static bool validateLastName(String text, BuildContext context) {
    if (text.isEmpty || text.length < 3) {
      Utils.flushBarErrorMessage(
          "Last name is required and must be at least 3 characters long.", context);
      return false;
    }

    if (RegExp(r'[0-9]').hasMatch(text)) {
      Utils.flushBarErrorMessage(
          "Last name cannot contain any numbers.", context);
      return false;
    }

    return true;
  }

  static bool validateFullNameLength(
      String firstName, String lastName, BuildContext context) {
    final combinedLength = (firstName + lastName).length;
    print("First Name: $firstName");
    print("Last Name: $lastName");
    print("Combined Length: $combinedLength");

    if (combinedLength > 24) {
      Utils.flushBarErrorMessage(
          "Combined length of first and last name must not exceed 24 characters.", context);
      return false;
    }
    return true;
  }

  static bool validateWorkHeadline(String text, BuildContext context) {
    if (text.isEmpty || text.length < 5) {
      Utils.flushBarErrorMessage("Work headline is required.", context);
      return false;
    }
    return true;
  }

  static bool validatePerDaySalary(String text, BuildContext context) {
    if (text.isEmpty) {
      Utils.flushBarErrorMessage("Salary is required.", context);
      return false;
    }

    final salary = int.tryParse(text.replaceAll(RegExp(r'[^0-9]'), ''));
    if (salary == null || salary <= 0) {
      Utils.flushBarErrorMessage("Salary must be a valid number greater than 0.", context);
      return false;
    }

    return true;
  }

  static bool validateEmail(String text, BuildContext context) {
    if (text.isEmpty) {
      Utils.flushBarErrorMessage("Email address is required.", context);
      return false;
    }

    final emailRegex = RegExp(
        r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
    );

    if (!emailRegex.hasMatch(text)) {
      Utils.flushBarErrorMessage("Please enter a valid email address.", context);
      return false;
    }

    return true;
  }

  static bool validateGender(String text, BuildContext context) {
    if (text.isEmpty) {
      Utils.flushBarErrorMessage("Gender must be selected.", context);
      return false;
    }

    return true;
  }

  static bool validateDOB(String text, BuildContext context) {
    if (text.isEmpty) {
      Utils.flushBarErrorMessage("Date of birth is required.", context);
      return false;
    }

    try {
      DateTime dob = DateFormat('dd/MM/yyyy').parse(text);
      DateTime today = DateTime.now();
      int age = today.year - dob.year;
      if (dob.month > today.month || (dob.month == today.month && dob.day > today.day)) {
        age--;
      }

      if (age < 18) {
        Utils.flushBarErrorMessage("You must be at least 18 years old.", context);
        return false;
      }
    } catch (e) {
      Utils.flushBarErrorMessage("Please select a valid date of birth.", context);
      return false;
    }

    return true;
  }
}
