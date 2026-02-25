import 'package:flutter/material.dart';

class TwoFactorPhone extends StatelessWidget {
  const TwoFactorPhone({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Two-Factor Authentication")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const TextField(
              decoration: InputDecoration(labelText: "Phone Number"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/2fa-code'),
              child: const Text("Continue"),
            ),
          ],
        ),
      ),
    );
  }
}
