import 'package:flutter/material.dart';

class TwoFactorPhone extends StatelessWidget {
  const TwoFactorPhone({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 700;

    return Scaffold(
      appBar: AppBar(title: const Text("Two-Factor Authentication")),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: isTablet ? 560 : 380),
          child: Padding(
            padding: EdgeInsets.all(isTablet ? 28 : 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  decoration: const InputDecoration(labelText: "Phone Number"),
                  style: TextStyle(fontSize: isTablet ? 18 : 16),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: isTablet ? 58 : 48,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pushNamed(context, '/2fa-code'),
                    child: Text(
                      "Continue",
                      style: TextStyle(fontSize: isTablet ? 18 : 16),
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
