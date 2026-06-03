import 'package:flutter/material.dart';
import '../services/app_language.dart';

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 700;
    final buttonWidth = isTablet ? 380.0 : double.infinity;

    final loginText = context.tr('start_login');
    final continueText = context.tr('start_continue');

    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF4A90E2), Color(0xFFF4F7FC)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              isTablet ? 0 : 24,
              isTablet ? 36 : 24,
              isTablet ? 0 : 24,
              isTablet ? 36 : 24,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(flex: 2),
                Center(
                  child: Image.asset(
                    'assets/images/logo.png',
                    width: isTablet ? 210 : 148,
                    height: isTablet ? 206 : 145,
                    opacity: const AlwaysStoppedAnimation(1.0),
                  ),
                ),
                const Spacer(flex: 3),
                Center(
                  child: SizedBox(
                    width: buttonWidth,
                    height: isTablet ? 72 : 65,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pushNamed(context, '/login'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A4A8C),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                      ),
                      child: Text(
                        loginText,
                        style: TextStyle(
                          fontSize: isTablet ? 20 : 17,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Center(
                  child: SizedBox(
                    width: buttonWidth,
                    height: isTablet ? 72 : 65,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pushNamed(context, '/create'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A4A8C),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                      ),
                      child: Text(
                        continueText,
                        style: TextStyle(
                          fontSize: isTablet ? 20 : 17,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
