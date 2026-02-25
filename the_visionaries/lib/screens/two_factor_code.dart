import 'package:flutter/material.dart';

class TwoFactorCode extends StatelessWidget {
  const TwoFactorCode({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Enter Code")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const TextField(
              decoration: InputDecoration(labelText: "Authentication Code"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/control'),
              child: const Text("Verify"),
            ),
          ],
        ),
      ),
    );
  }
}
