import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/app_language.dart';
import '../services/app_theme.dart';
import 'account_menu_screen.dart';
import 'language_settings_screen.dart';
import 'bluetooth_settings_screen.dart';

class SettingsMenuScreen extends StatelessWidget {
  const SettingsMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
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
                      context.tr('settings_title'),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: titleColor,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48), // balance back button
                ],
              ),
            ),
            Divider(color: dividerColor, thickness: 1.2, height: 1),
            const SizedBox(height: 8),

            // Account
            _SettingsItem(
              icon: Icons.account_circle_outlined,
              label: context.tr('settings_account'),
              iconColor: iconColor,
              textColor: itemColor,
              chevronColor: chevronColor,
              dividerColor: dividerColor,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AccountMenuScreen()),
              ),
            ),

            // Language
            _SettingsItem(
              icon: Icons.language,
              label: context.tr('settings_language'),
              iconColor: iconColor,
              textColor: itemColor,
              chevronColor: chevronColor,
              dividerColor: dividerColor,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const LanguageSettingsScreen(),
                ),
              ),
            ),

            // Bluetooth
            _SettingsItem(
              icon: Icons.bluetooth,
              label: context.tr('settings_bluetooth'),
              iconColor: iconColor,
              textColor: itemColor,
              chevronColor: chevronColor,
              dividerColor: dividerColor,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const BluetoothSettingsScreen(),
                ),
              ),
            ),

            const Spacer(),

            // Log Out
            Padding(
              padding: const EdgeInsets.only(bottom: 40),
              child: Center(
                child: SizedBox(
                  width: 210,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () => _logOut(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark
                          ? const Color(0xFF202125)
                          : const Color(0xFF1A3A6E),
                      foregroundColor: Colors.white,
                      shape: const StadiumBorder(),
                      elevation: 0,
                    ),
                    child: Text(
                      context.tr('settings_logout'),
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
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

  Future<void> _logOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    if (context.mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil('/start', (_) => false);
    }
  }
}

class _SettingsItem extends StatelessWidget {
  const _SettingsItem({
    required this.icon,
    required this.label,
    required this.iconColor,
    required this.textColor,
    required this.chevronColor,
    required this.dividerColor,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color iconColor;
  final Color textColor;
  final Color chevronColor;
  final Color dividerColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Icon(icon, color: iconColor, size: 26),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Icon(Icons.chevron_right, color: chevronColor, size: 24),
              ],
            ),
          ),
        ),
        Divider(color: dividerColor, thickness: 1, height: 1),
      ],
    );
  }
}
