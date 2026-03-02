import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class ControlPanel extends StatefulWidget {
  const ControlPanel({super.key});

  @override
  State<ControlPanel> createState() => _ControlPanelState();
}

class _ControlPanelState extends State<ControlPanel> {
  bool isOn = false;
  double fanSpeed = 0.0;
  double lastSpeed = 50.0; // Store last non-zero speed
  final DatabaseReference _dbRef = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL:
        'https://the-visionaries-mobile.firebaseio.com', // Replace with your Firebase database URL
  ).ref();

  Future<void> sendFanSpeed(double speed) async {
    try {
      await _dbRef.child('devices/fan/speed').set(speed.toStringAsFixed(0));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Control Panel")),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFFE4F4FF),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Image.asset(
                'assets/images/logo.png',
                width: 40,
                height: 40,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            "Fan Speed: ${fanSpeed.toStringAsFixed(0)}%",
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Slider(
            value: fanSpeed,
            min: 0,
            max: 100,
            divisions: 100,
            label: fanSpeed.toStringAsFixed(0),
            onChanged: (value) {
              setState(() {
                fanSpeed = value;
                if (value > 0) {
                  lastSpeed = value;
                  isOn = true;
                } else {
                  isOn = false;
                }
              });
              sendFanSpeed(value);
            },
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () {
              setState(() {
                if (isOn) {
                  // Turn off: set speed to 0
                  fanSpeed = 0.0;
                  isOn = false;
                } else {
                  // Turn on: restore last speed
                  fanSpeed = lastSpeed;
                  isOn = true;
                }
              });
              sendFanSpeed(fanSpeed);
            },
            child: Text(isOn ? "On" : "Off"),
          ),
        ],
      ),
    );
  }
}
