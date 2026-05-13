import 'package:firebase_database/firebase_database.dart';

import 'app_language.dart';

class LanguagePreferenceService {
  LanguagePreferenceService._();

  static final DatabaseReference _usersRef = FirebaseDatabase.instance.ref(
    'users',
  );

  static Future<void> saveUserLanguage({
    required String uid,
    required AppLanguage language,
    String? fullName,
    String? email,
  }) async {
    await _usersRef.child(uid).update({
      'preferences/language': language.code,
      'profile/fullName': fullName,
      'profile/email': email,
    });
  }

  static Future<AppLanguage> getUserLanguage(String uid) async {
    final snapshot = await _usersRef
        .child(uid)
        .child('preferences/language')
        .get();
    return AppLanguageX.fromCode(snapshot.value as String?);
  }
}
