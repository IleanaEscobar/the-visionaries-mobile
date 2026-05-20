import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'screens/start_screen.dart';
import 'screens/login_screen.dart';
import 'screens/create_account_screen.dart';
import 'screens/control_panel.dart';
import 'services/app_language.dart';
import 'services/app_theme.dart';
import 'services/language_preference_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } on FirebaseException catch (e) {
    // On iOS, hot restart / scene lifecycle can occasionally attempt default
    // app initialization more than once in quick succession.
    if (e.code != 'duplicate-app') rethrow;
  }

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final AppLanguageController _languageController = AppLanguageController(
    initialLanguage: AppLanguage.spanish,
  );
  final AppThemeController _themeController = AppThemeController(
    initialMode: ThemeMode.light,
  );

  @override
  void initState() {
    super.initState();
    _loadSavedLanguage();
  }

  Future<void> _loadSavedLanguage() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final language = await LanguagePreferenceService.getUserLanguage(user.uid);
    _languageController.setLanguage(language);
  }

  @override
  void dispose() {
    _languageController.dispose();
    _themeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppThemeScope(
      controller: _themeController,
      child: AppLanguageScope(
        controller: _languageController,
        child: AnimatedBuilder(
          animation: Listenable.merge([_languageController, _themeController]),
          builder: (context, _) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: ThemeData.light(),
              darkTheme: ThemeData.dark(),
              themeMode: _themeController.themeMode,
              locale: _languageController.locale,
              localizationsDelegates: const [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: const [
                Locale('es'),
                Locale('en'),
                Locale('de'),
              ],
              initialRoute: '/',
              routes: {
                '/': (_) => const StartScreen(),
                '/login': (_) => const LoginScreen(),
                '/create': (_) => const CreateAccountScreen(),
                '/control': (_) => const ControlPanel(),
              },
            );
          },
        ),
      ),
    );
  }
}
