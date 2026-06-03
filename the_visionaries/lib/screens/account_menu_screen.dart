import 'package:flutter/material.dart';
import '../services/app_language.dart';
import '../services/app_theme.dart';
import 'change_username_screen.dart';
import 'change_password_screen.dart';
import 'delete_account_screen.dart';

class AccountMenuScreen extends StatelessWidget {
  const AccountMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 700;
    final contentMaxWidth = isTablet ? 700.0 : double.infinity;
    final titleSize = isTablet ? 24.0 : 20.0;
    final itemFontSize = isTablet ? 20.0 : 17.0;
    final itemIconSize = isTablet ? 30.0 : 26.0;
    final horizontalPad = isTablet ? 28.0 : 20.0;

    final isDark = context.appTheme.isDark;
    final bg = isDark ? const Color(0xFF3F3F42) : Colors.white;
    final titleColor = isDark
        ? const Color(0xFFF4F4F4)
        : const Color(0xFF1A4A8C);
    final itemColor = isDark
        ? const Color(0xFFF2F2F2)
        : const Color(0xFF1A3A6A);
    final iconColor = isDark
        ? const Color(0xFFF2F2F2)
        : const Color(0xFF1A4A8C);
    final dividerColor = isDark
        ? const Color(0xFFE5E5E5)
        : const Color(0xFFD0D8E4);
    final chevronColor = isDark
        ? const Color(0xFFF2F2F2)
        : const Color(0xFF1A4A8C);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: contentMaxWidth),
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
                const SizedBox(height: 8),

                // Change Username
                _AccountItem(
                  icon: Icons.edit_outlined,
                  label: context.tr('account_change_username'),
                  iconColor: iconColor,
                  textColor: itemColor,
                  chevronColor: chevronColor,
                  dividerColor: dividerColor,
                  fontSize: itemFontSize,
                  iconSize: itemIconSize,
                  horizontalPadding: horizontalPad,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ChangeUsernameScreen(),
                    ),
                  ),
                ),

                // Change Password
                _AccountItem(
                  icon: Icons.lock_outline,
                  label: context.tr('account_change_password'),
                  iconColor: iconColor,
                  textColor: itemColor,
                  chevronColor: chevronColor,
                  dividerColor: dividerColor,
                  fontSize: itemFontSize,
                  iconSize: itemIconSize,
                  horizontalPadding: horizontalPad,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ChangePasswordScreen(),
                    ),
                  ),
                ),

                _AccountItem(
                  icon: Icons.delete_forever_outlined,
                  label: context.tr('account_delete_account'),
                  iconColor: iconColor,
                  textColor: itemColor,
                  chevronColor: chevronColor,
                  dividerColor: dividerColor,
                  fontSize: itemFontSize,
                  iconSize: itemIconSize,
                  horizontalPadding: horizontalPad,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const DeleteAccountScreen(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AccountItem extends StatelessWidget {
  const _AccountItem({
    required this.icon,
    required this.label,
    required this.iconColor,
    required this.textColor,
    required this.chevronColor,
    required this.dividerColor,
    required this.fontSize,
    required this.iconSize,
    required this.horizontalPadding,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color iconColor;
  final Color textColor;
  final Color chevronColor;
  final Color dividerColor;
  final double fontSize;
  final double iconSize;
  final double horizontalPadding;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: 16,
            ),
            child: Row(
              children: [
                Icon(icon, color: iconColor, size: iconSize),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: textColor,
                      fontSize: fontSize,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Icon(Icons.chevron_right, color: chevronColor, size: iconSize),
              ],
            ),
          ),
        ),
        Divider(color: dividerColor, thickness: 1, height: 1),
      ],
    );
  }
}
