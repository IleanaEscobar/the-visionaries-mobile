import 'package:flutter/material.dart';

enum AppLanguage { spanish, english, german, guarani }

extension AppLanguageX on AppLanguage {
  String get code {
    switch (this) {
      case AppLanguage.spanish:
        return 'es';
      case AppLanguage.english:
        return 'en';
      case AppLanguage.german:
        return 'de';
      case AppLanguage.guarani:
        return 'gn';
    }
  }

  String get label {
    switch (this) {
      case AppLanguage.spanish:
        return 'Español';
      case AppLanguage.english:
        return 'English';
      case AppLanguage.german:
        return 'Deutsch';
      case AppLanguage.guarani:
        return 'Guaraní';
    }
  }

  static AppLanguage fromCode(String? code) {
    switch (code) {
      case 'en':
        return AppLanguage.english;
      case 'de':
        return AppLanguage.german;
      case 'gn':
        return AppLanguage.guarani;
      case 'es':
      default:
        return AppLanguage.spanish;
    }
  }

  static AppLanguage fromLabel(String label) {
    for (final language in AppLanguage.values) {
      if (language.label == label) {
        return language;
      }
    }
    return AppLanguage.spanish;
  }
}

class AppLanguageController extends ChangeNotifier {
  AppLanguageController({AppLanguage initialLanguage = AppLanguage.spanish})
    : _language = initialLanguage;

  AppLanguage _language;

  AppLanguage get language => _language;

  // Guarani is handled by custom strings in this app; Material widgets fallback
  // to Spanish locale because Flutter does not provide `gn` localizations.
  Locale get locale {
    if (_language == AppLanguage.guarani) {
      return const Locale('es');
    }
    return Locale(_language.code);
  }

  void setLanguage(AppLanguage language) {
    if (_language == language) return;
    _language = language;
    notifyListeners();
  }

  String text(String key) {
    final languageMap =
        _localizedValues[_language] ?? _localizedValues.values.first;
    return languageMap[key] ??
        _localizedValues[AppLanguage.spanish]![key] ??
        key;
  }
}

class AppLanguageScope extends InheritedNotifier<AppLanguageController> {
  const AppLanguageScope({
    required AppLanguageController controller,
    required super.child,
    super.key,
  }) : super(notifier: controller);

  static AppLanguageController of(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<AppLanguageScope>();
    assert(scope != null, 'AppLanguageScope not found in widget tree');
    return scope!.notifier!;
  }
}

const Map<AppLanguage, Map<String, String>> _localizedValues = {
  AppLanguage.spanish: {
    'start_login': 'Iniciar sesión',
    'start_continue': 'Crear cuenta',
    'login_welcome_back': '¡Bienvenido de nuevo!',
    'login_user_id': 'Correo electrónico',
    'login_password': 'Contraseña',
    'login_button': 'Iniciar sesión',
    'login_missing_fields': 'Por favor ingresa correo electrónico y contraseña',
    'login_failed': 'Error al iniciar sesión',
    'create_title': 'Crear cuenta',
    'create_full_name': 'Nombre completo',
    'create_user_id': 'Correo electrónico',
    'create_password': 'Contraseña',
    'create_confirm_password': 'Confirmar contraseña',
    'create_button': 'Crear cuenta',
    'create_complete_all_fields': 'Por favor completa todos los campos',
    'create_passwords_mismatch': 'Las contraseñas no coinciden',
    'create_agree_terms':
        'Debes aceptar los Términos de uso y la Política de privacidad',
    'create_failed': 'No se pudo crear la cuenta',
    'terms_label': 'Acepto los Términos de uso y la Política de privacidad',
    'control_title': 'Panel de control',
    'ble_connected': 'BLE: Conectado',
    'ble_disconnected': 'BLE: Desconectado',
    'disconnect_ble': 'Desconectar BLE',
    'connect_ble': 'Conectar BLE',
    'speed_high': 'Alta',
    'speed_medium': 'Media',
    'speed_low': 'Baja',
    'fan_status_label': 'Estado del ventilador',
    'fan_status_on': 'Encendido',
    'fan_status_off': 'Apagado',
    'power_on': 'Encender',
    'power_off': 'Apagar',
    'device_not_found': 'Dispositivo "{deviceName}" no encontrado',
    'ble_error': 'Error BLE: {error}',
    'control_popup_message':
        'Para acceder al panel de control del ventilador, se requiere conexión Bluetooth.',
    'control_popup_connect_device': 'Conectar dispositivo',
    'settings_title': 'Menú de ajustes',
    'settings_account': 'Cuenta',
    'settings_language': 'Idioma',
    'settings_bluetooth': 'Bluetooth',
    'settings_logout': 'Cerrar sesión',
    'account_title': 'Cuenta',
    'account_change_username': 'Cambiar nombre de usuario',
    'account_change_password': 'Cambiar contraseña',
    'account_delete_account': 'Eliminar cuenta',
    'delete_account_title': 'Eliminar cuenta',
    'delete_account_description':
        'Esta acción elimina tu cuenta de forma permanente. Ingresa tu contraseña actual para continuar.',
    'delete_account_current_password': 'Contraseña actual',
    'delete_account_password_required': 'Ingresa tu contraseña actual',
    'delete_account_wrong_password': 'La contraseña actual es incorrecta.',
    'delete_account_requires_recent_login':
        'Vuelve a iniciar sesión e inténtalo otra vez para eliminar tu cuenta.',
    'delete_account_success': 'Cuenta eliminada correctamente',
    'delete_account_button': 'Eliminar cuenta',
    'change_username_hint': 'Nombre de usuario',
    'change_username_button': 'Cambiar nombre de usuario',
    'change_username_success': 'Nombre de usuario actualizado',
    'change_password_description':
        'Ingresa tu contraseña actual y tu nueva contraseña.',
    'change_password_current': 'Contraseña actual',
    'change_password_new': 'Nueva contraseña',
    'change_password_confirm': 'Confirmar nueva contraseña',
    'change_password_button': 'Cambiar contraseña',
    'change_password_cancel': 'Cancelar',
    'change_password_success': 'Contraseña actualizada',
    'change_password_mismatch': 'Las contraseñas no coinciden',
    'change_password_empty': 'Por favor completa todos los campos',
    'language_title': 'Idioma',
    'bluetooth_title': 'Bluetooth',
    'bluetooth_status_connected': 'Conectado',
    'bluetooth_status_disconnected': 'Desconectado',
    'bluetooth_connect': 'Conectar',
    'bluetooth_disconnect': 'Desconectar',
  },
  AppLanguage.english: {
    'start_login': 'Log in',
    'start_continue': 'Create Account',
    'login_welcome_back': 'Welcome back!',
    'login_user_id': 'Email',
    'login_password': 'Password',
    'login_button': 'Log in',
    'login_missing_fields': 'Please enter email and password',
    'login_failed': 'Login failed',
    'create_title': 'Create Account',
    'create_full_name': 'Full Name',
    'create_user_id': 'Email',
    'create_password': 'Password',
    'create_confirm_password': 'Confirm Password',
    'create_button': 'Create Account',
    'create_complete_all_fields': 'Please complete all fields',
    'create_passwords_mismatch': 'Passwords do not match',
    'create_agree_terms': 'Please agree to the Terms of Use and Privacy Policy',
    'create_failed': 'Account creation failed',
    'terms_label': 'I agree to the Terms of Use and Privacy Policy',
    'control_title': 'Control Panel',
    'ble_connected': 'BLE: Connected',
    'ble_disconnected': 'BLE: Disconnected',
    'disconnect_ble': 'Disconnect BLE',
    'connect_ble': 'Connect BLE',
    'speed_high': 'High',
    'speed_medium': 'Medium',
    'speed_low': 'Low',
    'fan_status_label': 'Fan Status',
    'fan_status_on': 'On',
    'fan_status_off': 'Off',
    'power_on': 'On',
    'power_off': 'Off',
    'device_not_found': 'Device "{deviceName}" not found',
    'ble_error': 'BLE error: {error}',
    'control_popup_message':
        'To access the fan control panel, Bluetooth connection is required.',
    'control_popup_connect_device': 'Connect to Device',
    'settings_title': 'Settings Menu',
    'settings_account': 'Account',
    'settings_language': 'Language',
    'settings_bluetooth': 'Bluetooth',
    'settings_logout': 'Log Out',
    'account_title': 'Account',
    'account_change_username': 'Change Username',
    'account_change_password': 'Change Password',
    'account_delete_account': 'Delete Account',
    'delete_account_title': 'Delete Account',
    'delete_account_description':
        'This action permanently deletes your account. Enter your current password to continue.',
    'delete_account_current_password': 'Current Password',
    'delete_account_password_required': 'Please enter your current password',
    'delete_account_wrong_password': 'Current password is incorrect.',
    'delete_account_requires_recent_login':
        'Please sign in again and then try deleting your account.',
    'delete_account_success': 'Account deleted successfully',
    'delete_account_button': 'Delete Account',
    'change_username_hint': 'Username',
    'change_username_button': 'Change username',
    'change_username_success': 'Username updated',
    'change_password_description':
        'Enter your current password and your new password.',
    'change_password_current': 'Current Password',
    'change_password_new': 'New Password',
    'change_password_confirm': 'Confirm New Password',
    'change_password_button': 'Change password',
    'change_password_cancel': 'Cancel',
    'change_password_success': 'Password updated',
    'change_password_mismatch': 'Passwords do not match',
    'change_password_empty': 'Please complete all fields',
    'language_title': 'Language',
    'bluetooth_title': 'Bluetooth',
    'bluetooth_status_connected': 'Connected',
    'bluetooth_status_disconnected': 'Disconnected',
    'bluetooth_connect': 'Connect',
    'bluetooth_disconnect': 'Disconnect',
  },
  AppLanguage.german: {
    'start_login': 'Anmelden',
    'start_continue': 'Konto erstellen',
    'login_welcome_back': 'Willkommen zurück!',
    'login_user_id': 'E-Mail',
    'login_password': 'Passwort',
    'login_button': 'Anmelden',
    'login_missing_fields': 'Bitte E-Mail und Passwort eingeben',
    'login_failed': 'Anmeldung fehlgeschlagen',
    'create_title': 'Konto erstellen',
    'create_full_name': 'Vollständiger Name',
    'create_user_id': 'E-Mail',
    'create_password': 'Passwort',
    'create_confirm_password': 'Passwort bestätigen',
    'create_button': 'Konto erstellen',
    'create_complete_all_fields': 'Bitte alle Felder ausfüllen',
    'create_passwords_mismatch': 'Passwörter stimmen nicht überein',
    'create_agree_terms':
        'Bitte stimmen Sie den Nutzungsbedingungen und der Datenschutzrichtlinie zu',
    'create_failed': 'Kontoerstellung fehlgeschlagen',
    'terms_label':
        'Ich stimme den Nutzungsbedingungen und der Datenschutzrichtlinie zu',
    'control_title': 'Steuerfeld',
    'ble_connected': 'BLE: Verbunden',
    'ble_disconnected': 'BLE: Getrennt',
    'disconnect_ble': 'BLE trennen',
    'connect_ble': 'BLE verbinden',
    'speed_high': 'Hoch',
    'speed_medium': 'Mittel',
    'speed_low': 'Niedrig',
    'fan_status_label': 'Lüfterstatus',
    'fan_status_on': 'An',
    'fan_status_off': 'Aus',
    'power_on': 'Ein',
    'power_off': 'Aus',
    'device_not_found': 'Gerät "{deviceName}" nicht gefunden',
    'ble_error': 'BLE-Fehler: {error}',
    'control_popup_message':
        'Um auf das Lüfter-Steuerfeld zuzugreifen, ist eine Bluetooth-Verbindung erforderlich.',
    'control_popup_connect_device': 'Gerät verbinden',
    'settings_title': 'Einstellungsmenü',
    'settings_account': 'Konto',
    'settings_language': 'Sprache',
    'settings_bluetooth': 'Bluetooth',
    'settings_logout': 'Abmelden',
    'account_title': 'Konto',
    'account_change_username': 'Benutzername ändern',
    'account_change_password': 'Passwort ändern',
    'account_delete_account': 'Konto löschen',
    'delete_account_title': 'Konto löschen',
    'delete_account_description':
        'Diese Aktion löscht dein Konto dauerhaft. Gib dein aktuelles Passwort ein, um fortzufahren.',
    'delete_account_current_password': 'Aktuelles Passwort',
    'delete_account_password_required': 'Bitte gib dein aktuelles Passwort ein',
    'delete_account_wrong_password': 'Das aktuelle Passwort ist nicht korrekt.',
    'delete_account_requires_recent_login':
        'Bitte melde dich erneut an und versuche dann, dein Konto zu löschen.',
    'delete_account_success': 'Konto erfolgreich gelöscht',
    'delete_account_button': 'Konto löschen',
    'change_username_hint': 'Benutzername',
    'change_username_button': 'Benutzername ändern',
    'change_username_success': 'Benutzername aktualisiert',
    'change_password_description':
        'Gib dein aktuelles Passwort und dein neues Passwort ein.',
    'change_password_current': 'Aktuelles Passwort',
    'change_password_new': 'Neues Passwort',
    'change_password_confirm': 'Neues Passwort bestätigen',
    'change_password_button': 'Passwort ändern',
    'change_password_cancel': 'Abbrechen',
    'change_password_success': 'Passwort aktualisiert',
    'change_password_mismatch': 'Passwörter stimmen nicht überein',
    'change_password_empty': 'Bitte alle Felder ausfüllen',
    'language_title': 'Sprache',
    'bluetooth_title': 'Bluetooth',
    'bluetooth_status_connected': 'Verbunden',
    'bluetooth_status_disconnected': 'Getrennt',
    'bluetooth_connect': 'Verbinden',
    'bluetooth_disconnect': 'Trennen',
  },
  AppLanguage.guarani: {
    'start_login': 'Eike hag̃ua',
    'start_continue': 'Ejapo cuenta',
    'login_welcome_back': '¡Ejujey porãite!',
    'login_user_id': 'Correo electrónico',
    'login_password': 'Ñe’ẽñemi',
    'login_button': 'Eike hag̃ua',
    'login_missing_fields': 'Emoinge correo electrónico ha ñe’ẽñemi',
    'login_failed': 'Ndoikói jeike',
    'create_title': 'Ejapo cuenta',
    'create_full_name': 'Téra tee',
    'create_user_id': 'Correo electrónico',
    'create_password': 'Ñe’ẽñemi',
    'create_confirm_password': 'Emoneĩ ñe’ẽñemi',
    'create_button': 'Ejapo cuenta',
    'create_complete_all_fields': 'Emyenyhẽ opaite tenda',
    'create_passwords_mismatch': 'Umi ñe’ẽñemi ndojojái',
    'create_agree_terms':
        'Emoneĩ va’erã Términos de uso ha Política de privacidad',
    'create_failed': 'Ndaikatúi ojapo cuenta',
    'terms_label': 'Amoneĩ Términos de uso ha Política de privacidad',
    'control_title': 'Panel de control',
    'ble_connected': 'BLE: Ojoaju',
    'ble_disconnected': 'BLE: Oñemboja’o',
    'disconnect_ble': 'Emboja’o BLE',
    'connect_ble': 'Embojoaju BLE',
    'speed_high': 'Yvate',
    'speed_medium': 'Mbyte',
    'speed_low': 'Michĩ',
    'fan_status_label': 'Estado ventilador',
    'fan_status_on': 'Mboguata',
    'fan_status_off': 'Mbogue',
    'power_on': 'Mboguata',
    'power_off': 'Mbogue',
    'device_not_found': 'Ndojejuhúi dispositivo "{deviceName}"',
    'ble_error': 'Jejavy BLE: {error}',
    'control_popup_message':
        'Reike hag̃ua panel de control-pe, tekotevẽ Bluetooth ojoaju.',
    'control_popup_connect_device': 'Embojoaju dispositivo',
    'settings_title': 'Mohenda porã',
    'settings_account': 'Kuénta',
    'settings_language': 'Ñe’ẽ',
    'settings_bluetooth': 'Bluetooth',
    'settings_logout': 'Ñemosẽ',
    'account_title': 'Kuénta',
    'account_change_username': 'Emoambue téra',
    'account_change_password': 'Emoambue ñe\'ẽñemi',
    'account_delete_account': 'Embogue cuenta',
    'delete_account_title': 'Embogue cuenta',
    'delete_account_description':
        'Ko tembiapo omboguéta nde cuenta opaite ára hag̃ua. Emoinge nde ñe\'ẽñemi ko\'ag̃agua.',
    'delete_account_current_password': 'Ñe\'ẽñemi ag̃agua',
    'delete_account_password_required': 'Emoinge nde ñe\'ẽñemi ag̃agua',
    'delete_account_wrong_password': 'Nde ñe\'ẽñemi ag̃agua ndoikói.',
    'delete_account_requires_recent_login':
        'Eike jey ha upéi eha\'ã embogue nde cuenta.',
    'delete_account_success': 'Cuenta oñembogue porã',
    'delete_account_button': 'Embogue cuenta',
    'change_username_hint': 'Téra',
    'change_username_button': 'Emoambue téra',
    'change_username_success': 'Téra oñemoambue',
    'change_password_description':
        'Emoinge nde ñe\'ẽñemi ag̃agua ha peteĩ pyahu.',
    'change_password_current': 'Ñe\'ẽñemi ag̃agua',
    'change_password_new': 'Ñe\'ẽñemi pyahu',
    'change_password_confirm': 'Emoneĩ ñe\'ẽñemi pyahu',
    'change_password_button': 'Emoambue ñe\'ẽñemi',
    'change_password_cancel': 'Emboty',
    'change_password_success': 'Ñe\'ẽñemi oñemoambue',
    'change_password_mismatch': 'Umi ñe\'ẽñemi ndojojái',
    'change_password_empty': 'Emyenyhẽ opaite tenda',
    'language_title': 'Ñe’ẽ',
    'bluetooth_title': 'Bluetooth',
    'bluetooth_status_connected': 'Ojoaju',
    'bluetooth_status_disconnected': 'Oñemboja\'o',
    'bluetooth_connect': 'Embojoaju',
    'bluetooth_disconnect': 'Emboja\'o',
  },
};

extension AppLanguageTextX on BuildContext {
  AppLanguageController get appLanguage => AppLanguageScope.of(this);

  String tr(String key, {Map<String, String> params = const {}}) {
    var value = appLanguage.text(key);
    for (final entry in params.entries) {
      value = value.replaceAll('{${entry.key}}', entry.value);
    }
    return value;
  }
}
