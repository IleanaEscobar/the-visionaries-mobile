import 'package:flutter/material.dart';
import '../widgets/level_selector.dart';

class ControlPanel extends StatefulWidget {
  const ControlPanel({super.key});

  @override
  State<ControlPanel> createState() => _ControlPanelState();
}

class _ControlPanelState extends State<ControlPanel> {
  bool isOn = false;
  String selectedLevel = "High";

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
              child:
                  Image.asset('assets/images/logo.png', width: 40, height: 40),
            ),
          ),
          const SizedBox(height: 20),
          LevelSelector(
            selected: selectedLevel,
            onSelect: (lvl) {
              setState(() => selectedLevel = lvl);
            },
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () {
              setState(() => isOn = !isOn);
            },
            child: Text(isOn ? "On" : "Off"),
          ),
        ],
      ),
    );
  }
}
