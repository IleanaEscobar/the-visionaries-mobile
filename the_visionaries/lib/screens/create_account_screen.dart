import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/app_language.dart';
import '../services/language_preference_service.dart';

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final _fullNameController = TextEditingController();
  final _userController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  AppLanguage _selectedLanguage = AppLanguage.spanish;
  bool _agreedToTerms = false;
  bool _initializedLanguage = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initializedLanguage) return;
    _selectedLanguage = context.appLanguage.language;
    _initializedLanguage = true;
  }

  void _createAccount() async {
    final languageController = context.appLanguage;
    final email = _userController.text.trim();
    final pass = _passwordController.text;
    final confirmPass = _confirmPasswordController.text;

    if (_fullNameController.text.trim().isEmpty ||
        email.isEmpty ||
        pass.isEmpty ||
        confirmPass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr('create_complete_all_fields'))),
      );
      return;
    }

    if (pass != confirmPass) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr('create_passwords_mismatch'))),
      );
      return;
    }

    if (!_agreedToTerms) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.tr('create_agree_terms'))));
      return;
    }

    setState(() => _isLoading = true);
    try {
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: pass);

      // Try to save language preferences, but do not block account creation.
      try {
        await LanguagePreferenceService.saveUserLanguage(
          uid: credential.user!.uid,
          language: _selectedLanguage,
          fullName: _fullNameController.text.trim(),
          email: email,
        );
      } catch (e) {
        // Log preference save failure but continue; user can set language in settings.
        debugPrint('Failed to save language preference: $e');
      }

      languageController.setLanguage(_selectedLanguage);
      if (mounted) {
        Navigator.pushNamed(context, '/control');
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? context.tr('create_failed'))),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showTermsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Terms and Agreements',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 40,
                        height: 40,
                        child: IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.close, color: Colors.black),
                          padding: EdgeInsets.zero,
                          alignment: Alignment.center,
                        ),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          '1. Acceptance of Terms',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'By creating an account and using The Visionaries app, you agree to these terms and conditions. If you do not agree, please do not use this application.',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF6E6E6E),
                          ),
                        ),
                        SizedBox(height: 16),
                        Text(
                          '2. User Responsibilities',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'You are responsible for maintaining the confidentiality of your account credentials and for all activities that occur under your account. You agree to notify us of any unauthorized use of your account.',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF6E6E6E),
                          ),
                        ),
                        SizedBox(height: 16),
                        Text(
                          '3. User Conduct',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'You agree not to use the app for any unlawful purposes or in any way that violates applicable laws or regulations. Prohibited activities include harassment, defamation, and dissemination of malware.',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF6E6E6E),
                          ),
                        ),
                        SizedBox(height: 16),
                        Text(
                          '4. Intellectual Property Rights',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'All content, features, and functionality of The Visionaries app are owned by The Visionaries, its licensors, or other providers of such material and are protected by international copyright and other intellectual property laws.',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF6E6E6E),
                          ),
                        ),
                        SizedBox(height: 16),
                        Text(
                          '5. Limitation of Liability',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'The Visionaries app is provided "as is" without warranties of any kind. We shall not be liable for any indirect, incidental, special, consequential, or punitive damages resulting from your use of or inability to use the app.',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF6E6E6E),
                          ),
                        ),
                        SizedBox(height: 16),
                        Text(
                          '6. Changes to Terms',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'We reserve the right to modify these terms at any time. Your continued use of the app following any changes constitutes your acceptance of the new terms.',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF6E6E6E),
                          ),
                        ),
                        SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() => _agreedToTerms = true);
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF24579D),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'I Agree',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _userController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  InputDecoration _fieldDecoration(String hintText) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: Color(0xFF8B8B8B), fontSize: 17),
      contentPadding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF0E6CC4), width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF0E6CC4), width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF0E6CC4), width: 1),
      ),
    );
  }

  Widget _languageOption(AppLanguage language) {
    return InkWell(
      onTap: () {
        context.appLanguage.setLanguage(language);
        setState(() => _selectedLanguage = language);
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: Checkbox(
                value: _selectedLanguage == language,
                onChanged: (_) {
                  context.appLanguage.setLanguage(language);
                  setState(() => _selectedLanguage = language);
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(2),
                ),
                side: const BorderSide(color: Color(0xFF1C1C1C), width: 1),
                activeColor: Colors.white,
                checkColor: Colors.black,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              language.label,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w400,
                color: Color(0xFF111111),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final createTitle = context.tr('create_title');
    final fullNameText = context.tr('create_full_name');
    final userIdText = context.tr('create_user_id');
    final passwordText = context.tr('create_password');
    final confirmPasswordText = context.tr('create_confirm_password');
    final hipaaText = context.tr('hipaa_note');
    final createButtonText = context.tr('create_button');

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 18, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                onPressed: () => Navigator.of(context).maybePop(),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.black,
                  size: 34,
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  createTitle,
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: SizedBox(
                  width: 341,
                  height: 56,
                  child: TextField(
                    controller: _fullNameController,
                    decoration: _fieldDecoration(fullNameText),
                    textInputAction: TextInputAction.next,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: SizedBox(
                  width: 341,
                  height: 56,
                  child: TextField(
                    controller: _userController,
                    decoration: _fieldDecoration(userIdText),
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: SizedBox(
                  width: 341,
                  height: 56,
                  child: TextField(
                    controller: _passwordController,
                    decoration: _fieldDecoration(passwordText),
                    obscureText: true,
                    textInputAction: TextInputAction.next,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: SizedBox(
                  width: 341,
                  height: 56,
                  child: TextField(
                    controller: _confirmPasswordController,
                    decoration: _fieldDecoration(confirmPasswordText),
                    obscureText: true,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _languageOption(AppLanguage.english),
              _languageOption(AppLanguage.spanish),
              _languageOption(AppLanguage.german),
              _languageOption(AppLanguage.guarani),
              const SizedBox(height: 80),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: Checkbox(
                      value: _agreedToTerms,
                      onChanged: (value) {
                        setState(() => _agreedToTerms = value ?? false);
                      },
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(2),
                      ),
                      side: const BorderSide(
                        color: Color(0xFF1C1C1C),
                        width: 1,
                      ),
                      activeColor: Colors.white,
                      checkColor: Colors.black,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
                      onTap: _showTermsDialog,
                      child: RichText(
                        text: TextSpan(
                          children: [
                            const TextSpan(
                              text: 'I agree to the ',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w400,
                                color: Colors.black,
                              ),
                            ),
                            TextSpan(
                              text: 'Terms and Agreements',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w400,
                                color: Color(0xFF0E6CC4),
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                hipaaText,
                style: const TextStyle(fontSize: 13, color: Color(0xFF6E6E6E)),
              ),
              const SizedBox(height: 16),
              Center(
                child: SizedBox(
                  width: 341,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _createAccount,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF24579D),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : Text(
                            createButtonText,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
