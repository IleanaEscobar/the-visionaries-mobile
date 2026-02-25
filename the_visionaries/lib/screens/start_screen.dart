import 'package:flutter/material.dart';

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF7CC6FE), Color(0xFF3A8DFF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.remove_red_eye, size: 100, color: Colors.white),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/login'),
                child: const Text("Log in"),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => Navigator.pushNamed(context, '/create'),
                child: const Text("Create Account"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
