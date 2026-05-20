import 'package:firebase_database/firebase_database.dart';

import 'app_language.dart';

class LanguagePreferenceService {
  LanguagePreferenceService._();

  static const String _databaseUrl =
      'https://the-visionaries-mobile-default-rtdb.firebaseio.com';

  static final DatabaseReference _usersRef = FirebaseDatabase.instanceFor(
    app: FirebaseDatabase.instance.app,
    databaseURL: _databaseUrl,
  ).ref('users');

  static Future<void> saveUserLanguage({
    required String uid,
    required AppLanguage language,
    String? fullName,
    String? email,
  }) async {
    final updates = <String, Object?>{'preferences/language': language.code};
    if (fullName != null && fullName.isNotEmpty) {
      updates['profile/fullName'] = fullName;
    }
    if (email != null && email.isNotEmpty) {
      updates['profile/email'] = email;
    }

    await _usersRef.child(uid).update(updates);
  }

  static Future<AppLanguage> getUserLanguage(String uid) async {
    try {
      final snapshot = await _usersRef
          .child(uid)
          .child('preferences/language')
          .get();
      return AppLanguageX.fromCode(snapshot.value as String?);
    } catch (e) {
      // If language preference cannot be read (permission denied, no data, etc.),
      // default to Spanish and allow app to continue.
      return AppLanguage.spanish;
    }
  }
}
