import 'package:flutter/material.dart';
import '../services/app_language.dart';

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
        child: Stack(
          children: [
            Positioned(
              top: 236,
              left: 127,
              child: Image.asset(
                'assets/images/logo.png',
                width: 148,
                height: 145,
                opacity: const AlwaysStoppedAnimation(1.0),
              ),
            ),
            Positioned(
              top: 581,
              left: 31,
              child: SizedBox(
                width: 340,
                height: 65,
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
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 667,
              left: 31,
              child: SizedBox(
                width: 340,
                height: 65,
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
                    style: const TextStyle(
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
