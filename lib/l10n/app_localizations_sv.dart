// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Swedish (`sv`).
class AppLocalizationsSv extends AppLocalizations {
  AppLocalizationsSv([String locale = 'sv']) : super(locale);

  @override
  String get logout_button => 'Logga ut';

  @override
  String get note => 'Anteckning';

  @override
  String get cancel => 'Avbryt';

  @override
  String get yes => 'Ja';

  @override
  String get delete => 'Radera';

  @override
  String get delete_account => 'Ta bort konto';

  @override
  String get sharing => 'Delning';

  @override
  String get ok => 'OK';

  @override
  String get login => 'Logga in';

  @override
  String get verify_email => 'Verifiera';

  @override
  String get register => 'Registrera';

  @override
  String get restart => 'Börja om';

  @override
  String get start_typing_your_note => 'Skriv din anteckning här';

  @override
  String get delete_note_prompt => 'Är du säker på att du vill radera den här anteckningen?';

  @override
  String get cannot_share_empty_note_prompt => 'Kan inte dela en tom anteckning!';

  @override
  String get generic_error_prompt => 'Ett fel har inträffat';

  @override
  String get logout_dialog_prompt => 'Är du säker på att du vill logga ut?';

  @override
  String get password_reset => 'Nollställ ditt lösenord';

  @override
  String get password_reset_dialog_prompt =>
      'Vi har nu skickat ett mejl till dig. Mejlet innehåller instruktioner om hur du kan nollställa ditt lösenord!';

  @override
  String get login_error_cannot_find_user => 'Kunde inte hitta en användare med de angivna uppgifterna!';

  @override
  String get login_error_wrong_credentials => 'Fel inloggningsuppgifter!';

  @override
  String get login_error_auth_error => 'Ett autentiseringsfel har inträffat!';

  @override
  String get login_view_prompt => 'Logga in för att kunna se dina anteckningar!';

  @override
  String get login_view_forgot_password => 'Glömt lösenord?';

  @override
  String get login_view_not_registered_yet => 'Inte registrerad än? Tryck här!';

  @override
  String get email_text_field_placeholder => 'Skriv din mejladress här';

  @override
  String get password_text_field_placeholder => 'Skriv ditt lösenord här';

  @override
  String get forgot_password => 'Glömt lösenord';

  @override
  String get forgot_password_view_generic_error =>
      'Vi kunde inte hantera din begäran. Var vänlig och skriv dina inloggningsuppgifter och prova igen!';

  @override
  String get forgot_password_view_prompt =>
      'Om du har glömt ditt lösenord, mata in din mejladress så kan vi skicka ett mejl till dig där du kan nollställa ditt lösenord!';

  @override
  String get forgot_password_view_send_me_link => 'Skicka mejlet';

  @override
  String get forgot_password_view_back_to_login => 'Tillbaka till inloggningsskärmen';

  @override
  String get register_error_weak_password =>
      'Ditt valda lösenord är inte säkert nog. Var vänlig och välj ett annat lösenord!';

  @override
  String get register_error_email_already_in_use =>
      'Mejladressen som du angav är redan tagen. Var vänlig och välj en annan mejladress!';

  @override
  String get register_error_generic => 'Kunde tyvärr inte hantera din begäran. Var vänlig försök igen senare.';

  @override
  String get register_error_invalid_email =>
      'Din valda mejladress verkar inte vara giltig. Var vänlig försök med en annan mejladress.';

  @override
  String get register_view_prompt => 'Mata in din mejladress och ditt lösenord för att se dina anteckningar!';

  @override
  String get register_view_already_registered => 'Redan registrerad? Logga in här!';

  @override
  String get verify_email_view_prompt =>
      'Vi har skickat ett mejl till din mejladress. Du behöver trycka på länken i mejlet för att verifiera din mejladress. Om du inte redan har fått mejlet efter en stund, tryck på knappen nedan för att skicka ett nytt mejl!';

  @override
  String get verify_email_send_email_verification => 'Skicka verifieringsmejlet igen';

  @override
  String notes_title(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count anteckningar',
      one: '1 anteckning',
      zero: 'Inga anteckningar än',
    );
    return '$_temp0';
  }
}
