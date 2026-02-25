import 'package:flutter/material.dart';

class LevelSelector extends StatelessWidget {
  final String selected;
  final Function(String) onSelect;

  const LevelSelector({
    super.key,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    List<String> levels = ["High", "Med", "Low"];

    return Column(
      children: levels.map((level) {
        final isSelected = level == selected;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: GestureDetector(
            onTap: () => onSelect(level),
            child: CircleAvatar(
              radius: 28,
              backgroundColor: isSelected ? Colors.blue : Colors.transparent,
              child: Text(
                level,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.blue,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
