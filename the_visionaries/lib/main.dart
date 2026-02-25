import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/start_screen.dart';
import 'screens/login_screen.dart';
import 'screens/create_account_screen.dart';
import 'screens/control_panel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      initialRoute: '/',
      routes: {
        '/': (_) => const StartScreen(),
        '/login': (_) => const LoginScreen(),
        '/create': (_) => const CreateAccountScreen(),
        '/control': (_) => const ControlPanel(),
      },
    );
  }
}
