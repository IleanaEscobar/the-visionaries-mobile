import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/app_language.dart';
import '../services/app_theme.dart';

class ChangeUsernameScreen extends StatefulWidget {
  const ChangeUsernameScreen({super.key});

  @override
  State<ChangeUsernameScreen> createState() => _ChangeUsernameScreenState();
}

class _ChangeUsernameScreenState extends State<ChangeUsernameScreen> {
  final _controller = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final currentName = FirebaseAuth.instance.currentUser?.displayName ?? '';
    _controller.text = currentName;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final newName = _controller.text.trim();
    if (newName.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      await FirebaseAuth.instance.currentUser?.updateDisplayName(newName);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.tr('change_username_success'))),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 700;
    final contentMaxWidth = isTablet ? 680.0 : double.infinity;
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
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      isTablet ? 32 : 24,
                      isTablet ? 40 : 32,
                      isTablet ? 32 : 24,
                      24,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Username field
                        TextField(
                          controller: _controller,
                          style: TextStyle(
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF1A3A6A),
                          ),
                          decoration: InputDecoration(
                            prefixIcon: Icon(
                              Icons.edit_outlined,
                              color: isDark
                                  ? const Color(0xFFF2F2F2)
                                  : const Color(0xFF1A4A8C),
                              size: 22,
                            ),
                            hintText: context.tr('change_username_hint'),
                            hintStyle: TextStyle(
                              color: isDark
                                  ? const Color(0xFFCCCCCC)
                                  : const Color(0xFF8AA0BE),
                            ),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.clear, size: 20),
                              color: isDark
                                  ? const Color(0xFFCCCCCC)
                                  : const Color(0xFF8AA0BE),
                              onPressed: () => _controller.clear(),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: inputBorder),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: inputBorder,
                                width: 2,
                              ),
                            ),
                            filled: true,
                            fillColor: isDark
                                ? const Color(0x00000000)
                                : Colors.white,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: isTablet ? 18 : 16,
                            ),
                          ),
                        ),

                        Divider(
                          color: isDark
                              ? const Color(0xFFE5E5E5)
                              : const Color(0xFFD0D8E4),
                          height: 12,
                          thickness: 1,
                        ),

                        const SizedBox(height: 24),

                        // Submit button
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
                                    context.tr('change_username_button'),
                                    style: TextStyle(
                                      fontSize: isTablet ? 18 : 16,
                                      fontWeight: FontWeight.w600,
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
