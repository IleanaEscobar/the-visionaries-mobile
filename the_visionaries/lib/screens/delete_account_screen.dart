import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/app_language.dart';
import '../services/app_theme.dart';

class DeleteAccountScreen extends StatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  State<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends State<DeleteAccountScreen> {
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _deleteAccount() async {
    final password = _passwordController.text;

    if (password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr('delete_account_password_required'))),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null || user.email == null) {
        throw FirebaseAuthException(
          code: 'no-user',
          message: 'No user is currently signed in.',
        );
      }

      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );
      await user.reauthenticateWithCredential(credential);
      await user.delete();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr('delete_account_success'))),
      );
      Navigator.of(context).pushNamedAndRemoveUntil('/', (_) => false);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      var message = e.message ?? e.code;
      if (e.code == 'wrong-password') {
        message = context.tr('delete_account_wrong_password');
      } else if (e.code == 'requires-recent-login') {
        message = context.tr('delete_account_requires_recent_login');
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.appTheme.isDark;
    final bg = isDark ? const Color(0xFF3F3F42) : Colors.white;
    final titleColor = isDark
        ? const Color(0xFFF4F4F4)
        : const Color(0xFF1A4A8C);
    final dividerColor = isDark
        ? const Color(0xFFE5E5E5)
        : const Color(0xFFD0D8E4);
    final inputBorder = isDark
        ? const Color(0xFFE5E5E5)
        : const Color(0xFF065791);
    final labelColor = isDark
        ? const Color(0xFFF2F2F2)
        : const Color(0xFF1A3A6A);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: titleColor, size: 26),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Text(
                      context.tr('delete_account_title'),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: titleColor,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            Divider(color: dividerColor, thickness: 1.2, height: 1),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      context.tr('delete_account_description'),
                      style: TextStyle(
                        color: labelColor,
                        fontSize: 15,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      context.tr('delete_account_current_password'),
                      style: TextStyle(
                        color: labelColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black,
                      ),
                      decoration: InputDecoration(
                        hintText: context.tr('change_password_current'),
                        hintStyle: TextStyle(
                          color: isDark
                              ? const Color(0xFFB0B0B0)
                              : const Color(0xFF8A8A8A),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 14,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: BorderSide(color: inputBorder),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: BorderSide(color: inputBorder),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: BorderSide(
                            color: inputBorder,
                            width: 1.4,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    SizedBox(
                      height: 54,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _deleteAccount,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFB71C1C),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          elevation: 0,
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
                                context.tr('delete_account_button'),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 54,
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: isDark
                              ? const Color(0xFF121212)
                              : const Color(0xFF1A4A8C),
                          backgroundColor: isDark
                              ? const Color(0xFFD9D9D9)
                              : Colors.transparent,
                          side: BorderSide(
                            color: isDark
                                ? const Color(0xFFD9D9D9)
                                : const Color(0xFF1A4A8C),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        child: Text(
                          context.tr('change_password_cancel'),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
