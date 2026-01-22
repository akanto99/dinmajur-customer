import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_bn.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('bn'),
    Locale('en'),
  ];

  /// No description provided for @first_name.
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get first_name;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome to DinMajur'**
  String get welcome;

  /// No description provided for @welcome_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Busy life, simple solution'**
  String get welcome_subtitle;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @log_in.
  ///
  /// In en, this message translates to:
  /// **'Log In'**
  String get log_in;

  /// No description provided for @log_in_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Please enter your login credential'**
  String get log_in_subtitle;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Your Name'**
  String get fullName;

  /// No description provided for @fullName_hint.
  ///
  /// In en, this message translates to:
  /// **'Enter your full name'**
  String get fullName_hint;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Mobile Number'**
  String get phone;

  /// No description provided for @phone_hint.
  ///
  /// In en, this message translates to:
  /// **'01XXXXXXXXX'**
  String get phone_hint;

  /// No description provided for @phone_hint_new.
  ///
  /// In en, this message translates to:
  /// **'1XXXXXXXXX'**
  String get phone_hint_new;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @password_hint.
  ///
  /// In en, this message translates to:
  /// **'Enter 6 characters or more'**
  String get password_hint;

  /// No description provided for @forgot_password.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password'**
  String get forgot_password;

  /// No description provided for @sign_in.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get sign_in;

  /// No description provided for @login_with_otp.
  ///
  /// In en, this message translates to:
  /// **'Login with OTP'**
  String get login_with_otp;

  /// No description provided for @new_user.
  ///
  /// In en, this message translates to:
  /// **'New user?'**
  String get new_user;

  /// No description provided for @registartion_screen.
  ///
  /// In en, this message translates to:
  /// **'--------------------------Registration Screen-------------------'**
  String get registartion_screen;

  /// No description provided for @registration_title.
  ///
  /// In en, this message translates to:
  /// **'Registration'**
  String get registration_title;

  /// No description provided for @create_account.
  ///
  /// In en, this message translates to:
  /// **'Create an Account'**
  String get create_account;

  /// No description provided for @slogan.
  ///
  /// In en, this message translates to:
  /// **'Daily Work, Daily Earn!'**
  String get slogan;

  /// No description provided for @mobile_number_required.
  ///
  /// In en, this message translates to:
  /// **'Mobile Number *'**
  String get mobile_number_required;

  /// No description provided for @new_password.
  ///
  /// In en, this message translates to:
  /// **'Password*'**
  String get new_password;

  /// No description provided for @reenter_password.
  ///
  /// In en, this message translates to:
  /// **'Re-enter Password*'**
  String get reenter_password;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @wait.
  ///
  /// In en, this message translates to:
  /// **'Waiting...'**
  String get wait;

  /// No description provided for @already_have_account.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get already_have_account;

  /// No description provided for @login_now.
  ///
  /// In en, this message translates to:
  /// **'Login Now'**
  String get login_now;

  /// No description provided for @loading_validation.
  ///
  /// In en, this message translates to:
  /// **'Loading validation...'**
  String get loading_validation;

  /// No description provided for @loading_requirements.
  ///
  /// In en, this message translates to:
  /// **'Loading requirements...'**
  String get loading_requirements;

  /// No description provided for @error_try_again.
  ///
  /// In en, this message translates to:
  /// **'An error occurred. Please try again.'**
  String get error_try_again;

  /// No description provided for @enter_full_name.
  ///
  /// In en, this message translates to:
  /// **'Please enter your full name'**
  String get enter_full_name;

  /// No description provided for @full_name_min_length.
  ///
  /// In en, this message translates to:
  /// **'Full name must be at least 3 characters long'**
  String get full_name_min_length;

  /// No description provided for @full_name_max_length.
  ///
  /// In en, this message translates to:
  /// **'Name cannot exceed 26 characters'**
  String get full_name_max_length;

  /// No description provided for @full_name_invalid_characters.
  ///
  /// In en, this message translates to:
  /// **'Full name can only contain letters and spaces'**
  String get full_name_invalid_characters;

  /// No description provided for @otp_screen.
  ///
  /// In en, this message translates to:
  /// **'----------------------------------------------OTP Screen-------------------------'**
  String get otp_screen;

  /// No description provided for @otp_verification_title.
  ///
  /// In en, this message translates to:
  /// **'OTP Verification'**
  String get otp_verification_title;

  /// No description provided for @verify_your_number.
  ///
  /// In en, this message translates to:
  /// **'Verify Your Number'**
  String get verify_your_number;

  /// No description provided for @sent_code_to_number.
  ///
  /// In en, this message translates to:
  /// **'Sent a code to your number'**
  String get sent_code_to_number;

  /// No description provided for @please_enter_valid_otp.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid 4-digit OTP'**
  String get please_enter_valid_otp;

  /// No description provided for @havent_received_code.
  ///
  /// In en, this message translates to:
  /// **'Haven’t received the code?'**
  String get havent_received_code;

  /// No description provided for @send_again.
  ///
  /// In en, this message translates to:
  /// **'Send Again'**
  String get send_again;

  /// No description provided for @otp_sent_success.
  ///
  /// In en, this message translates to:
  /// **'A new OTP has been sent'**
  String get otp_sent_success;

  /// No description provided for @verification_success.
  ///
  /// In en, this message translates to:
  /// **'---------------------Verification Screen-------------------------'**
  String get verification_success;

  /// No description provided for @verification_title.
  ///
  /// In en, this message translates to:
  /// **'Verification'**
  String get verification_title;

  /// No description provided for @verification_success_title.
  ///
  /// In en, this message translates to:
  /// **'Verification Successful!'**
  String get verification_success_title;

  /// No description provided for @verification_success_message.
  ///
  /// In en, this message translates to:
  /// **'Your phone number has been\nsuccessfully verified.'**
  String get verification_success_message;

  /// No description provided for @continue_to_app.
  ///
  /// In en, this message translates to:
  /// **'Continue to App'**
  String get continue_to_app;

  /// No description provided for @setup_profile_later.
  ///
  /// In en, this message translates to:
  /// **'I\'ll set up my profile later'**
  String get setup_profile_later;

  /// No description provided for @forgot_screen.
  ///
  /// In en, this message translates to:
  /// **'----------------------------------Forgot Screen-------------------------'**
  String get forgot_screen;

  /// No description provided for @forgot_password_title.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgot_password_title;

  /// No description provided for @mobile_number_placeholder.
  ///
  /// In en, this message translates to:
  /// **'01XXXXXXXXX'**
  String get mobile_number_placeholder;

  /// No description provided for @error_enter_phone.
  ///
  /// In en, this message translates to:
  /// **'Please enter phone number'**
  String get error_enter_phone;

  /// No description provided for @error_valid_phone.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid phone number'**
  String get error_valid_phone;

  /// No description provided for @new_password_screen.
  ///
  /// In en, this message translates to:
  /// **'--------------------New Password Screen-------------------------'**
  String get new_password_screen;

  /// No description provided for @new_password_title.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get new_password_title;

  /// No description provided for @password_required.
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get password_required;

  /// No description provided for @reenter_password_required.
  ///
  /// In en, this message translates to:
  /// **'Re-enter password *'**
  String get reenter_password_required;

  /// No description provided for @password_matched.
  ///
  /// In en, this message translates to:
  /// **'Passwords matched'**
  String get password_matched;

  /// No description provided for @password_notmatched.
  ///
  /// In en, this message translates to:
  /// **'Passwords not matched'**
  String get password_notmatched;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @invalid_token.
  ///
  /// In en, this message translates to:
  /// **'Invalid token'**
  String get invalid_token;

  /// No description provided for @password_changed_success.
  ///
  /// In en, this message translates to:
  /// **'Password Changed Successfully'**
  String get password_changed_success;

  /// No description provided for @unexpected_error.
  ///
  /// In en, this message translates to:
  /// **'Unexpected error occurred'**
  String get unexpected_error;

  /// No description provided for @password_validation.
  ///
  /// In en, this message translates to:
  /// **'--------------------Password Validation------------------------'**
  String get password_validation;

  /// No description provided for @password_too_weak.
  ///
  /// In en, this message translates to:
  /// **'Too weak'**
  String get password_too_weak;

  /// No description provided for @password_weak.
  ///
  /// In en, this message translates to:
  /// **'Weak'**
  String get password_weak;

  /// No description provided for @password_good.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get password_good;

  /// No description provided for @password_strong.
  ///
  /// In en, this message translates to:
  /// **'Strong'**
  String get password_strong;

  /// No description provided for @enter_phone_number.
  ///
  /// In en, this message translates to:
  /// **'Please enter phone number'**
  String get enter_phone_number;

  /// No description provided for @phone_number_must_be_11.
  ///
  /// In en, this message translates to:
  /// **'Phone number must be 11 digits'**
  String get phone_number_must_be_11;

  /// No description provided for @invalid_phone_number.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid Bangladeshi phone number'**
  String get invalid_phone_number;

  /// No description provided for @password_min_characters.
  ///
  /// In en, this message translates to:
  /// **'Please enter your password & at least 6 characters'**
  String get password_min_characters;

  /// No description provided for @reenter_password_min_characters.
  ///
  /// In en, this message translates to:
  /// **'Please re-enter your password & at least 6 characters'**
  String get reenter_password_min_characters;

  /// No description provided for @passwords_do_not_match.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwords_do_not_match;

  /// No description provided for @password_too_weak_requirements.
  ///
  /// In en, this message translates to:
  /// **'Password is too weak. Please meet at least 3 requirements.'**
  String get password_too_weak_requirements;

  /// No description provided for @password_must_be_6.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get password_must_be_6;

  /// No description provided for @please_confirm_password.
  ///
  /// In en, this message translates to:
  /// **'Please confirm your password'**
  String get please_confirm_password;

  /// No description provided for @passwords_reenter_do_not_match.
  ///
  /// In en, this message translates to:
  /// **'Passwords & Re-enter Passwords do not match'**
  String get passwords_reenter_do_not_match;

  /// No description provided for @password_cannot_contain_spaces.
  ///
  /// In en, this message translates to:
  /// **'Password cannot contain spaces'**
  String get password_cannot_contain_spaces;

  /// No description provided for @reenter_password_cannot_contain_spaces.
  ///
  /// In en, this message translates to:
  /// **'Re-enter password cannot contain spaces'**
  String get reenter_password_cannot_contain_spaces;

  /// No description provided for @enter_old_password.
  ///
  /// In en, this message translates to:
  /// **'Please enter your old password'**
  String get enter_old_password;

  /// No description provided for @old_password_min_characters.
  ///
  /// In en, this message translates to:
  /// **'Old password must be at least 6 characters'**
  String get old_password_min_characters;

  /// No description provided for @navigation_bar.
  ///
  /// In en, this message translates to:
  /// **'--------------------navigation_bar------------------------'**
  String get navigation_bar;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @offers.
  ///
  /// In en, this message translates to:
  /// **'Offers'**
  String get offers;

  /// No description provided for @order.
  ///
  /// In en, this message translates to:
  /// **'Order'**
  String get order;

  /// No description provided for @draft.
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get draft;

  /// No description provided for @callus.
  ///
  /// In en, this message translates to:
  /// **'Call Us'**
  String get callus;

  /// No description provided for @home_screen.
  ///
  /// In en, this message translates to:
  /// **'--------------------Home Screen ------------------------'**
  String get home_screen;

  /// No description provided for @storeType_retail.
  ///
  /// In en, this message translates to:
  /// **'Retail'**
  String get storeType_retail;

  /// No description provided for @storeType_grocery.
  ///
  /// In en, this message translates to:
  /// **'Grocery'**
  String get storeType_grocery;

  /// No description provided for @storeType_restaurant.
  ///
  /// In en, this message translates to:
  /// **'Restaurant'**
  String get storeType_restaurant;

  /// No description provided for @storeType_pharmacy.
  ///
  /// In en, this message translates to:
  /// **'Pharmacy'**
  String get storeType_pharmacy;

  /// No description provided for @storeType_electronics.
  ///
  /// In en, this message translates to:
  /// **'Electronics'**
  String get storeType_electronics;

  /// No description provided for @storeType_clothing.
  ///
  /// In en, this message translates to:
  /// **'Clothing'**
  String get storeType_clothing;

  /// No description provided for @storeType_housekeeper.
  ///
  /// In en, this message translates to:
  /// **'Premium House Keeper'**
  String get storeType_housekeeper;

  /// No description provided for @storeType_beauty_salon.
  ///
  /// In en, this message translates to:
  /// **'Premium Home Beauty & Salon'**
  String get storeType_beauty_salon;

  /// No description provided for @storeType_family_event_cooking.
  ///
  /// In en, this message translates to:
  /// **'Family Event Cooking'**
  String get storeType_family_event_cooking;

  /// No description provided for @select_store_type.
  ///
  /// In en, this message translates to:
  /// **'What do you need?'**
  String get select_store_type;

  /// No description provided for @select_store_type_hint.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get select_store_type_hint;

  /// No description provided for @select_dropdown_hint.
  ///
  /// In en, this message translates to:
  /// **'Primium House Keeper'**
  String get select_dropdown_hint;

  /// No description provided for @nearby_stores.
  ///
  /// In en, this message translates to:
  /// **'Nearby Stores ({count})'**
  String nearby_stores(Object count);

  /// No description provided for @see_all.
  ///
  /// In en, this message translates to:
  /// **'See All'**
  String get see_all;

  /// No description provided for @available.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get available;

  /// No description provided for @distance_away.
  ///
  /// In en, this message translates to:
  /// **'{distance}m away'**
  String distance_away(Object distance);

  /// No description provided for @delivery_time.
  ///
  /// In en, this message translates to:
  /// **'Delivery within 30-60 minutes'**
  String get delivery_time;

  /// No description provided for @order_now.
  ///
  /// In en, this message translates to:
  /// **'Order Now'**
  String get order_now;

  /// No description provided for @empty_inbox.
  ///
  /// In en, this message translates to:
  /// **'Empty Inbox'**
  String get empty_inbox;

  /// No description provided for @no_notification.
  ///
  /// In en, this message translates to:
  /// **'No Notification Yet'**
  String get no_notification;

  /// No description provided for @drawer_screen.
  ///
  /// In en, this message translates to:
  /// **'--------------------Drawer Screen ------------------------'**
  String get drawer_screen;

  /// No description provided for @profile_menu.
  ///
  /// In en, this message translates to:
  /// **'Profile Menu'**
  String get profile_menu;

  /// No description provided for @wishlist.
  ///
  /// In en, this message translates to:
  /// **'Wishlist'**
  String get wishlist;

  /// No description provided for @review.
  ///
  /// In en, this message translates to:
  /// **'Reviews'**
  String get review;

  /// No description provided for @account_settings.
  ///
  /// In en, this message translates to:
  /// **'Account Settings'**
  String get account_settings;

  /// No description provided for @view_profile.
  ///
  /// In en, this message translates to:
  /// **'View Profile'**
  String get view_profile;

  /// No description provided for @change_password.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get change_password;

  /// No description provided for @payment_method.
  ///
  /// In en, this message translates to:
  /// **'Payment Method'**
  String get payment_method;

  /// No description provided for @view_earn.
  ///
  /// In en, this message translates to:
  /// **'View Earn'**
  String get view_earn;

  /// No description provided for @reviews.
  ///
  /// In en, this message translates to:
  /// **'Reviews'**
  String get reviews;

  /// No description provided for @support.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get support;

  /// No description provided for @sign_out.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get sign_out;

  /// No description provided for @logout_confirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you\'d like to Log Out?'**
  String get logout_confirm;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @log_out.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get log_out;

  /// No description provided for @no_data_found.
  ///
  /// In en, this message translates to:
  /// **'No data found'**
  String get no_data_found;

  /// No description provided for @save_address.
  ///
  /// In en, this message translates to:
  /// **'Save Addresses'**
  String get save_address;

  /// No description provided for @orders.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get orders;

  /// No description provided for @promo_codes.
  ///
  /// In en, this message translates to:
  /// **'Promo Codes'**
  String get promo_codes;

  /// No description provided for @terms_conditions.
  ///
  /// In en, this message translates to:
  /// **'Terms & Condition'**
  String get terms_conditions;

  /// No description provided for @privacy_policy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacy_policy;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @chooseYourLanguage.
  ///
  /// In en, this message translates to:
  /// **'Choose your language'**
  String get chooseYourLanguage;

  /// No description provided for @selectLanguageDesc.
  ///
  /// In en, this message translates to:
  /// **'Select your preferred language to use\nDinmajur Customer app easily'**
  String get selectLanguageDesc;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['bn', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'bn':
      return AppLocalizationsBn();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
