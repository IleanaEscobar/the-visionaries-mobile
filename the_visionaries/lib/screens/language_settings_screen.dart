import 'package:flutter/material.dart';
import '../services/app_language.dart';
import '../services/app_theme.dart';
import '../services/language_preference_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LanguageSettingsScreen extends StatelessWidget {
  const LanguageSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 700;
    final contentMaxWidth = isTablet ? 700.0 : double.infinity;
    final titleSize = isTablet ? 24.0 : 20.0;
    final itemFontSize = isTablet ? 20.0 : 17.0;

    final isDark = context.appTheme.isDark;
    final bg = isDark ? const Color(0xFF3F3F42) : Colors.white;
    final titleColor = isDark
        ? const Color(0xFFF4F4F4)
        : const Color(0xFF1A4A8C);
    final dividerColor = isDark
        ? const Color(0xFFE5E5E5)
        : const Color(0xFFD0D8E4);
    final current = context.appLanguage.language;

    final languages = [
      (AppLanguage.spanish, 'Español'),
      (AppLanguage.english, 'English'),
      (AppLanguage.german, 'Deutsch'),
      (AppLanguage.guarani, 'Guaraní'),
    ];

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: contentMaxWidth),
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.arrow_back,
                          color: titleColor,
                          size: isTablet ? 30 : 26,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Expanded(
                        child: Text(
                          context.tr('language_title'),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: titleColor,
                            fontSize: titleSize,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      SizedBox(width: isTablet ? 56 : 48),
                    ],
                  ),
                ),
                Divider(color: dividerColor, thickness: 1.2, height: 1),
                const SizedBox(height: 8),

                ...languages.map((entry) {
                  final (lang, label) = entry;
                  final isSelected = current == lang;
                  final textColor = isDark
                      ? const Color(0xFFF2F2F2)
                      : const Color(0xFF1A3A6A);

                  return Column(
                    children: [
                      InkWell(
                        onTap: () async {
                          context.appLanguage.setLanguage(lang);
                          final uid = FirebaseAuth.instance.currentUser?.uid;
                          if (uid != null) {
                            await LanguagePreferenceService.saveUserLanguage(
                              uid: uid,
                              language: lang,
                              fullName: FirebaseAuth
                                  .instance
                                  .currentUser
                                  ?.displayName,
                              email: FirebaseAuth.instance.currentUser?.email,
                            );
                          }
                        },
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: isTablet ? 28 : 20,
                            vertical: 16,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  label,
                                  style: TextStyle(
                                    color: textColor,
                                    fontSize: itemFontSize,
                                    fontWeight: isSelected
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                  ),
                                ),
                              ),
                              if (isSelected)
                                Icon(
                                  Icons.check,
                                  color: titleColor,
                                  size: isTablet ? 26 : 22,
                                ),
                            ],
                          ),
                        ),
                      ),
                      Divider(color: dividerColor, thickness: 1, height: 1),
                    ],
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
