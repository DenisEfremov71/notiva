import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_sv.dart';

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
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en'), Locale('sv')];

  /// Label for the log out menu item/button
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logout_button;

  /// Title for a single note screen
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get note;

  /// Generic cancel button label
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Generic confirmation button label
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// Title of the delete note dialog
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Label for the delete account menu item/button
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get delete_account;

  /// Title of the sharing dialog
  ///
  /// In en, this message translates to:
  /// **'Sharing'**
  String get sharing;

  /// Generic OK button label
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// Login button label and login screen title
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// Title of the email verification screen
  ///
  /// In en, this message translates to:
  /// **'Verify email'**
  String get verify_email;

  /// Register button label and register screen title
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// Button label to restart the registration/verification flow
  ///
  /// In en, this message translates to:
  /// **'Restart'**
  String get restart;

  /// Placeholder text in the note editor
  ///
  /// In en, this message translates to:
  /// **'Start typing your note'**
  String get start_typing_your_note;

  /// Confirmation message in the delete note dialog
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this note?'**
  String get delete_note_prompt;

  /// Shown when the user tries to share an empty note
  ///
  /// In en, this message translates to:
  /// **'Cannot share an empty note!'**
  String get cannot_share_empty_note_prompt;

  /// Title of the generic error dialog
  ///
  /// In en, this message translates to:
  /// **'An error occurred'**
  String get generic_error_prompt;

  /// Confirmation message in the log out dialog
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out?'**
  String get logout_dialog_prompt;

  /// Title of the password reset confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Password reset'**
  String get password_reset;

  /// Message shown after a password reset email was sent
  ///
  /// In en, this message translates to:
  /// **'We have now sent you a password reset link. Please check your email for more information.'**
  String get password_reset_dialog_prompt;

  /// Login error when no user matches the entered email
  ///
  /// In en, this message translates to:
  /// **'Cannot find a user with the entered credentials!'**
  String get login_error_cannot_find_user;

  /// Login error when the password is wrong
  ///
  /// In en, this message translates to:
  /// **'Wrong credentials'**
  String get login_error_wrong_credentials;

  /// Generic login authentication error
  ///
  /// In en, this message translates to:
  /// **'Authentication error'**
  String get login_error_auth_error;

  /// Introductory text on the login screen
  ///
  /// In en, this message translates to:
  /// **'Please log in to your account in order to interact with and create notes!'**
  String get login_view_prompt;

  /// Button on the login screen that opens the forgot password screen
  ///
  /// In en, this message translates to:
  /// **'I forgot my password'**
  String get login_view_forgot_password;

  /// Button on the login screen that opens the register screen
  ///
  /// In en, this message translates to:
  /// **'Not registered yet? Register here!'**
  String get login_view_not_registered_yet;

  /// Hint text for the email input field
  ///
  /// In en, this message translates to:
  /// **'Enter your email here'**
  String get email_text_field_placeholder;

  /// Hint text for the password input field
  ///
  /// In en, this message translates to:
  /// **'Enter your password here'**
  String get password_text_field_placeholder;

  /// Title of the forgot password screen
  ///
  /// In en, this message translates to:
  /// **'Forgot Password'**
  String get forgot_password;

  /// Error shown when the password reset request fails
  ///
  /// In en, this message translates to:
  /// **'We could not process your request. Please make sure that you are a registered user, or if not, register a user now by going back one step.'**
  String get forgot_password_view_generic_error;

  /// Introductory text on the forgot password screen
  ///
  /// In en, this message translates to:
  /// **'If you forgot your password, simply enter your email and we will send you a password reset link.'**
  String get forgot_password_view_prompt;

  /// Button that sends a password reset email
  ///
  /// In en, this message translates to:
  /// **'Send me password reset link'**
  String get forgot_password_view_send_me_link;

  /// Button that returns to the login screen
  ///
  /// In en, this message translates to:
  /// **'Back to login page'**
  String get forgot_password_view_back_to_login;

  /// Registration error when the password is too weak
  ///
  /// In en, this message translates to:
  /// **'This password is not secure enough. Please choose another password!'**
  String get register_error_weak_password;

  /// Registration error when the email is already in use
  ///
  /// In en, this message translates to:
  /// **'This email is already registered to another user. Please choose another email!'**
  String get register_error_email_already_in_use;

  /// Generic registration error
  ///
  /// In en, this message translates to:
  /// **'Failed to register. Please try again later!'**
  String get register_error_generic;

  /// Registration error when the email address is invalid
  ///
  /// In en, this message translates to:
  /// **'The email address you entered appears to be invalid. Please try another email address!'**
  String get register_error_invalid_email;

  /// Introductory text on the register screen
  ///
  /// In en, this message translates to:
  /// **'Enter your email and password to see your notes!'**
  String get register_view_prompt;

  /// Button on the register screen that opens the login screen
  ///
  /// In en, this message translates to:
  /// **'Already registered? Login here!'**
  String get register_view_already_registered;

  /// Explanatory text on the email verification screen
  ///
  /// In en, this message translates to:
  /// **'We\'ve sent you an email verification. Please open it to verify your account. If you haven\'t received a verification email yet, press the button below!'**
  String get verify_email_view_prompt;

  /// Button that sends the verification email again
  ///
  /// In en, this message translates to:
  /// **'Send email verification'**
  String get verify_email_send_email_verification;

  /// Title of the notes list screen showing the number of notes
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No notes yet} =1{1 note} other{{count} notes}}'**
  String notes_title(int count);
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'sv'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'sv':
      return AppLocalizationsSv();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
