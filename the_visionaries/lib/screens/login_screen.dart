import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/app_language.dart';
import '../services/language_preference_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _userController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  void _login() async {
    final languageController = context.appLanguage;
    final userId = _userController.text.trim();
    final pass = _passwordController.text;

    if (userId.isEmpty || pass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr('login_missing_fields'))),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: userId,
        password: pass,
      );

      // Do not block successful login if preferences are temporarily unreadable.
      try {
        final savedLanguage = await LanguagePreferenceService.getUserLanguage(
          credential.user!.uid,
        );
        languageController.setLanguage(savedLanguage);
      } catch (_) {}

      if (mounted) {
        Navigator.pushNamed(context, '/control');
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? context.tr('login_failed'))),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _userController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final welcomeText = context.tr('login_welcome_back');
    final userIdText = context.tr('login_user_id');
    final passwordText = context.tr('login_password');
    final loginText = context.tr('login_button');

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: 12,
              left: 8,
              child: IconButton(
                onPressed: () => Navigator.of(context).maybePop(),
                icon: const Icon(
                  Icons.arrow_back_ios_new,
                  color: Color(0xFF1A1A1A),
                ),
              ),
            ),
            Positioned(
              top: 80,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  welcomeText,
                  style: const TextStyle(
                    fontFamily: 'Source Sans 3',
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    height: 1,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 168,
              left: 30.5,
              child: SizedBox(
                width: 341,
                height: 132,
                child: Column(
                  children: [
                    SizedBox(
                      width: 341,
                      height: 56,
                      child: TextField(
                        controller: _userController,
                        decoration: InputDecoration(
                          labelText: userIdText,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFF065791),
                              width: 1,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFF065791),
                              width: 1,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFF065791),
                              width: 1,
                            ),
                          ),
                        ),
                        keyboardType: TextInputType.emailAddress,
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: 341,
                      height: 56,
                      child: TextField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: passwordText,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFF065791),
                              width: 1,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFF065791),
                              width: 1,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFF065791),
                              width: 1,
                            ),
                          ),
                        ),
                        obscureText: true,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 382,
              left: 31,
              child: SizedBox(
                width: 340,
                height: 65,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A4A8C),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : Text(
                          loginText,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
