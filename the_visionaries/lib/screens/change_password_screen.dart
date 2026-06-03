import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/app_language.dart';
import '../services/app_theme.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final current = _currentController.text;
    final newPass = _newController.text;
    final confirm = _confirmController.text;

    if (current.isEmpty || newPass.isEmpty || confirm.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr('change_password_empty'))),
      );
      return;
    }
    if (newPass != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr('change_password_mismatch'))),
      );
      return;
    }

    if (newPass.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password must be at least 6 characters')),
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
        password: current,
      );
      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPass);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.tr('change_password_success'))),
        );
        _currentController.clear();
        _newController.clear();
        _confirmController.clear();
        Navigator.pop(context);
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        String message = e.message ?? e.code;
        if (e.code == 'wrong-password') {
          message = 'Current password is incorrect.';
        } else if (e.code == 'weak-password') {
          message = 'New password is too weak. Use a stronger password.';
        } else if (e.code == 'requires-recent-login') {
          message =
              'Please log out and log back in before changing your password.';
        }
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 700;
    final contentMaxWidth = isTablet ? 700.0 : double.infinity;
    final titleSize = isTablet ? 24.0 : 20.0;

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
    final requiredColor = Colors.red;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                      context.tr('account_title'),
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

            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: contentMaxWidth),
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                      isTablet ? 32 : 24,
                      24,
                      isTablet ? 32 : 24,
                      24,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Description
                        Text(
                          context.tr('change_password_description'),
                          style: TextStyle(
                            color: labelColor,
                            fontSize: isTablet ? 17 : 15,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Current Password
                        _PasswordField(
                          label: context.tr('change_password_current'),
                          controller: _currentController,
                          isDark: isDark,
                          inputBorder: inputBorder,
                          labelColor: labelColor,
                          requiredColor: requiredColor,
                        ),
                        const SizedBox(height: 16),

                        // New Password
                        _PasswordField(
                          label: context.tr('change_password_new'),
                          controller: _newController,
                          isDark: isDark,
                          inputBorder: inputBorder,
                          labelColor: labelColor,
                          requiredColor: requiredColor,
                        ),
                        const SizedBox(height: 16),

                        // Confirm New Password
                        _PasswordField(
                          label: context.tr('change_password_confirm'),
                          controller: _confirmController,
                          isDark: isDark,
                          inputBorder: inputBorder,
                          labelColor: labelColor,
                          requiredColor: requiredColor,
                        ),
                        const SizedBox(height: 28),

                        // Change password button
                        SizedBox(
                          height: isTablet ? 58 : 54,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isDark
                                  ? const Color(0xFF202125)
                                  : const Color(0xFF1A4A8C),
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
                                    context.tr('change_password_button'),
                                    style: TextStyle(
                                      fontSize: isTablet ? 18 : 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Cancel button
                        SizedBox(
                          height: isTablet ? 58 : 54,
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
                              style: TextStyle(
                                fontSize: isTablet ? 18 : 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ],
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

class _PasswordField extends StatefulWidget {
  const _PasswordField({
    required this.label,
    required this.controller,
    required this.isDark,
    required this.inputBorder,
    required this.labelColor,
    required this.requiredColor,
  });

  final String label;
  final TextEditingController controller;
  final bool isDark;
  final Color inputBorder;
  final Color labelColor;
  final Color requiredColor;

  @override
  State<_PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<_PasswordField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: widget.label,
            style: TextStyle(
              color: widget.labelColor,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            children: [
              TextSpan(
                text: ' *',
                style: TextStyle(color: widget.requiredColor),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: widget.controller,
          obscureText: _obscure,
          style: TextStyle(
            color: widget.isDark ? Colors.white : const Color(0xFF1A3A6A),
          ),
          decoration: InputDecoration(
            suffixIcon: IconButton(
              icon: Icon(
                _obscure ? Icons.visibility_off : Icons.visibility,
                size: 20,
              ),
              color: widget.isDark
                  ? const Color(0xFFD0D0D0)
                  : const Color(0xFF8AA0BE),
              onPressed: () => setState(() => _obscure = !_obscure),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: widget.inputBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: widget.inputBorder, width: 2),
            ),
            filled: true,
            fillColor: widget.isDark ? const Color(0x00000000) : Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }
}
